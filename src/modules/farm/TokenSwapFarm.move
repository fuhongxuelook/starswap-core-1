// Copyright (c) The Elements Stuidio Core Contributors
// SPDX-License-Identifier: Apache-2.0

// TODO: replace the address with admin address
address 0x3db7a2da7444995338a2413b151ee437 {
module TokenSwapFarm {
    use 0x1::Signer;
    use 0x1::Token;
    use 0x1::Account;
    use 0x1::Event;
    use 0x1::Errors;
    use 0x3db7a2da7444995338a2413b151ee437::YieldFarming;
    use 0x3db7a2da7444995338a2413b151ee437::TBD;
    use 0x3db7a2da7444995338a2413b151ee437::TokenSwap::LiquidityToken;
    use 0x3db7a2da7444995338a2413b151ee437::TokenSwapRouter;
    use 0x3db7a2da7444995338a2413b151ee437::TokenSwapGovPoolType::{PoolTypeLiquidityMint};

    const ERR_FARM_PARAM_ERROR: u64 = 101;

    /// Event emitted when farm been added
    struct AddFarmEvent has drop, store {
        /// token code of X type
        x_token_code: Token::TokenCode,
        /// token code of X type
        y_token_code: Token::TokenCode,
        /// signer of farm add
        signer: address,
        /// admin address
        admin: address,
    }

    /// Event emitted when farm been added
    struct ActivationStateEvent has drop, store {
        /// token code of X type
        x_token_code: Token::TokenCode,
        /// token code of X type
        y_token_code: Token::TokenCode,
        /// signer of farm add
        signer: address,
        /// admin address
        admin: address,
        /// Activation state
        activation_state: bool,
    }

    /// Event emitted when stake been called
    struct StakeEvent has drop, store {
        /// token code of X type
        x_token_code: Token::TokenCode,
        /// token code of X type
        y_token_code: Token::TokenCode,
        /// signer of stake user
        signer: address,
        // value of stake user
        amount: u128,
        /// admin address
        admin: address,
    }

    /// Event emitted when unstake been called
    struct UnstakeEvent has drop, store {
        /// token code of X type
        x_token_code: Token::TokenCode,
        /// token code of X type
        y_token_code: Token::TokenCode,
        /// signer of stake user
        signer: address,
        /// admin address
        admin: address,
    }

    struct FarmPoolEvent has key, store {
        add_farm_event_handler: Event::EventHandle<AddFarmEvent>,
        activation_state_event_handler: Event::EventHandle<ActivationStateEvent>,
        stake_event_handler: Event::EventHandle<StakeEvent>,
        unstake_event_handler: Event::EventHandle<UnstakeEvent>,
    }

    struct FarmCapability<TokenX, TokenY> has key, store {
        cap: YieldFarming::ParameterModifyCapability<PoolTypeLiquidityMint, Token::Token<LiquidityToken<TokenX, TokenY>>>,
        release_per_seconds: u128,
    }

    struct FarmHarvestCapability<TokenX, TokenY> has key, store {
        cap: YieldFarming::HarvestCapability<PoolTypeLiquidityMint, Token::Token<LiquidityToken<TokenX, TokenY>>>,
    }

    /// Initialize farm big pool
    public fun initialize_farm_pool(account: &signer, token: Token::Token<TBD::TBD>) {
        YieldFarming::initialize<
            PoolTypeLiquidityMint,
            TBD::TBD>(account, token);

        move_to(account, FarmPoolEvent {
            add_farm_event_handler: Event::new_event_handle<AddFarmEvent>(account),
            activation_state_event_handler: Event::new_event_handle<ActivationStateEvent>(account),
            stake_event_handler: Event::new_event_handle<StakeEvent>(account),
            unstake_event_handler: Event::new_event_handle<UnstakeEvent>(account),
        });
    }

    /// Initialize Liquidity pair gov pool, only called by token issuer
    public fun add_farm<TokenX: store, TokenY: store>(
        account: &signer,
        release_per_seconds: u128) acquires FarmPoolEvent {
        // Only called by the genesis
        TBD::assert_genesis_address(account);

        // To determine how many amount release in every period
        let cap = YieldFarming::add_asset<
            PoolTypeLiquidityMint,
            Token::Token<LiquidityToken<TokenX, TokenY>>>(
            account, release_per_seconds, 0);

        move_to(account, FarmCapability<TokenX, TokenY> { cap, release_per_seconds });

        //// TODO (BobOng): Add to DAO
        // GovernanceDaoProposal::plugin<
        //    PoolTypeProposal<TokenX, TokenY, GovTokenT>,
        //    GovTokenT>(account, modify_cap);

        // Emit add farm event
        let admin = Signer::address_of(account);
        let farm_pool_event = borrow_global_mut<FarmPoolEvent>(admin);
        Event::emit_event(&mut farm_pool_event.add_farm_event_handler,
            AddFarmEvent {
                y_token_code: Token::token_code<TokenX>(),
                x_token_code: Token::token_code<TokenY>(),
                signer: Signer::address_of(account),
                admin,
            });
    }

    /// Reset activation of farm from token type X and Y
    public fun reset_farm_activation<TokenX: store, TokenY: store>(
        account: &signer,
        active: bool) acquires FarmPoolEvent, FarmCapability {
        TBD::assert_genesis_address(account);
        let admin_addr = Signer::address_of(account);
        let cap = borrow_global_mut<FarmCapability<TokenX, TokenY>>(admin_addr);

        YieldFarming::modify_parameter<
            PoolTypeLiquidityMint,
            TBD::TBD,
            Token::Token<LiquidityToken<TokenX, TokenY>>
        >(
            &cap.cap,
            admin_addr,
            cap.release_per_seconds,
            active,
        );

        let farm_pool_event = borrow_global_mut<FarmPoolEvent>(admin_addr);
        Event::emit_event(&mut farm_pool_event.activation_state_event_handler,
            ActivationStateEvent {
                y_token_code: Token::token_code<TokenX>(),
                x_token_code: Token::token_code<TokenY>(),
                signer: Signer::address_of(account),
                admin: admin_addr,
                activation_state: active,
            });
    }

    /// Stake liquidity Token pair
    public fun stake<TokenX: store, TokenY: store>(account: &signer,
                                                   amount: u128) acquires FarmCapability, FarmHarvestCapability, FarmPoolEvent {
        let account_addr = Signer::address_of(account);
        if (!Account::is_accept_token<TBD::TBD>(account_addr)) {
            Account::do_accept_token<TBD::TBD>(account);
        };

        // Actual stake
        let farm_cap = borrow_global_mut<FarmCapability<TokenX, TokenY>>(TBD::token_address());
        let harvest_cap = inner_stake<TokenX, TokenY>(account, amount, farm_cap);

        // Store a capability to account
        move_to(account, harvest_cap);

        // Emit stake event
        let farm_stake_event = borrow_global_mut<FarmPoolEvent>(TBD::token_address());
        Event::emit_event(&mut farm_stake_event.stake_event_handler,
            StakeEvent {
                y_token_code: Token::token_code<TokenX>(),
                x_token_code: Token::token_code<TokenY>(),
                signer: account_addr,
                admin: TBD::token_address(),
                amount,
            });
    }

    /// Unstake liquidity Token pair
    public fun unstake<TokenX: store,
                       TokenY: store>(account: &signer, amount: u128) acquires FarmCapability, FarmHarvestCapability, FarmPoolEvent {

        let account_addr = Signer::address_of(account);
        // Actual stake
        let farm_cap = borrow_global_mut<FarmCapability<TokenX, TokenY>>(TBD::token_address());
        let farm_harvest_cap = move_from<FarmHarvestCapability<TokenX, TokenY>>(account_addr);
        let harvest_cap = inner_unstake<TokenX, TokenY>(account, amount, farm_cap, farm_harvest_cap);

        move_to(account, harvest_cap);

        // Emit unstake event
        let farm_stake_event = borrow_global_mut<FarmPoolEvent>(TBD::token_address());
        Event::emit_event(&mut farm_stake_event.unstake_event_handler,
            UnstakeEvent {
                y_token_code: Token::token_code<TokenX>(),
                x_token_code: Token::token_code<TokenY>(),
                signer: account_addr,
                admin: TBD::token_address(),
            });
    }

    /// Harvest reward from token pool
    public fun harvest<TokenX: store,
                       TokenY: store>(account: &signer, amount: u128) acquires FarmHarvestCapability {
        let account_addr = Signer::address_of(account);
        let farm_harvest_cap = borrow_global_mut<FarmHarvestCapability<TokenX, TokenY>>(account_addr);

        let token = YieldFarming::harvest<
            PoolTypeLiquidityMint,
            TBD::TBD,
            Token::Token<LiquidityToken<TokenX, TokenY>>>(
            account_addr,
            TBD::token_address(),
            amount,
            &farm_harvest_cap.cap,
        );
        Account::deposit<TBD::TBD>(account_addr, token);
    }

    /// Return calculated APY
    public fun lookup_gain<TokenX: store, TokenY: store>(account: address): u128 {
        YieldFarming::query_gov_token_amount<
            PoolTypeLiquidityMint,
            TBD::TBD,
            Token::Token<LiquidityToken<TokenX, TokenY>>
        >(account, TBD::token_address())
    }

    /// Query all stake amount
    public fun query_info<TokenX: store, TokenY: store>(): (bool, u128, u128, u128) {
        YieldFarming::query_info<PoolTypeLiquidityMint, Token::Token<LiquidityToken<TokenX, TokenY>>>(TBD::token_address())
    }

    /// Query all stake amount
    public fun query_total_stake<TokenX: store, TokenY: store>(): u128 {
        YieldFarming::query_total_stake<
            PoolTypeLiquidityMint,
            Token::Token<LiquidityToken<TokenX, TokenY>>
        >(TBD::token_address())
    }

    /// Query stake amount from user
    public fun query_stake<TokenX: store, TokenY: store>(account: address): u128 {
        YieldFarming::query_stake<
            PoolTypeLiquidityMint,
            Token::Token<LiquidityToken<TokenX, TokenY>>
        >(account)
    }

    /// Query release per second
    public fun query_release_per_second<TokenX: store, TokenY: store>(): u128 acquires FarmCapability {
        let cap = borrow_global<FarmCapability<TokenX, TokenY>>(TBD::token_address());
        cap.release_per_seconds
    }

    /// Inner stake operation that unstake all from pool and combind new amount to total asset, then restake.
    fun inner_stake<TokenX: store, TokenY: store>(account: &signer,
                                                  amount: u128,
                                                  farm_cap: &FarmCapability<TokenX, TokenY>)
    : FarmHarvestCapability<TokenX, TokenY> acquires FarmHarvestCapability {
        let account_addr = Signer::address_of(account);
        // If stake exist, unstake all withdraw staking, and set reward token to buffer pool
        let own_token = if (YieldFarming::exists_stake_at_address<PoolTypeLiquidityMint, Token::Token<LiquidityToken<TokenX, TokenY>>>(account_addr)) {
            let FarmHarvestCapability<TokenX, TokenY> { cap : unwrap_harvest_cap } =
                move_from<FarmHarvestCapability<TokenX, TokenY>>(account_addr);

            // Unstake all liquidity token and reward token
            let (own_token, reward_token) = YieldFarming::unstake<
                PoolTypeLiquidityMint,
                TBD::TBD,
                Token::Token<LiquidityToken<TokenX, TokenY>>
            >(account, TBD::token_address(), unwrap_harvest_cap);
            Account::deposit<TBD::TBD>(account_addr, reward_token);
            own_token
        } else {
            Token::zero<LiquidityToken<TokenX, TokenY>>()
        };


        // Withdraw addtion token. Addtionally, combine addtion token and own token.
        let addition_token = TokenSwapRouter::withdraw_liquidity_token<TokenX, TokenY>(account, amount);
        let total_token = Token::join<LiquidityToken<TokenX, TokenY>>(own_token, addition_token);
        let total_amount = Token::value<LiquidityToken<TokenX, TokenY>>(&total_token);

        let new_harvest_cap = YieldFarming::stake<
            PoolTypeLiquidityMint,
            TBD::TBD,
            Token::Token<LiquidityToken<TokenX, TokenY>>>(
            account,
            TBD::token_address(),
            total_token,
            total_amount,
            &farm_cap.cap
        );
        FarmHarvestCapability<TokenX, TokenY> { cap: new_harvest_cap }
    }

    /// Inner unstake operation that unstake all from pool and combind new amount to total asset, then restake.
    fun inner_unstake<TokenX: store, TokenY: store>(account: &signer,
                                                    amount: u128,
                                                    farm_cap: &FarmCapability<TokenX, TokenY>,
                                                    harvest_cap: FarmHarvestCapability<TokenX, TokenY>)
    : FarmHarvestCapability<TokenX, TokenY> {
        let account_addr = Signer::address_of(account);
        let FarmHarvestCapability { cap: unwrap_harvest_cap } = harvest_cap;
        assert(amount > 0, Errors::invalid_state(ERR_FARM_PARAM_ERROR));

        // unstake all from pool
        let (own_asset_token, reward_token) = YieldFarming::unstake<
            PoolTypeLiquidityMint,
            TBD::TBD,
            Token::Token<LiquidityToken<TokenX, TokenY>>
        >(account, TBD::token_address(), unwrap_harvest_cap);

        // Process reward token
        Account::deposit<TBD::TBD>(account_addr, reward_token);

        // Process asset token
        let withdraw_asset_token = Token::withdraw<LiquidityToken<TokenX, TokenY>>(&mut own_asset_token, amount);
        TokenSwapRouter::deposit_liquidity_token<TokenX, TokenY>(account_addr, withdraw_asset_token);

        let own_asset_amount = Token::value<LiquidityToken<TokenX, TokenY>>(&own_asset_token);

        // Restake to pool
        let new_harvest_cap = YieldFarming::stake<
            PoolTypeLiquidityMint,
            TBD::TBD,
            Token::Token<LiquidityToken<TokenX, TokenY>>>(
            account,
            TBD::token_address(),
            own_asset_token,
            own_asset_amount,
            &farm_cap.cap
        );
        FarmHarvestCapability<TokenX, TokenY> { cap: new_harvest_cap }
    }
}
}