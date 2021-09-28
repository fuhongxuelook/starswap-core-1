// Copyright (c) The Elements Stuidio Core Contributors
// SPDX-License-Identifier: Apache-2.0

// TODO: replace the address with admin address
address 0x3db7a2da7444995338a2413b151ee437 {
module TokenSwapFarmRouter {
    use 0x3db7a2da7444995338a2413b151ee437::TokenSwap;
    use 0x3db7a2da7444995338a2413b151ee437::TokenSwapFarm;

    const ERROR_ROUTER_INVALID_TOKEN_PAIR: u64 = 1001;

    public fun add_farm_pool<TokenX: store, TokenY: store>(account: &signer, release_per_second: u128) {
        let order = TokenSwap::compare_token<TokenX, TokenY>();
        assert(order != 0, ERROR_ROUTER_INVALID_TOKEN_PAIR);
        if (order == 1) {
            TokenSwapFarm::add_farm<TokenX, TokenY>(account, release_per_second);
        } else {
            TokenSwapFarm::add_farm<TokenY, TokenX>(account, release_per_second);
        };
    }

    public fun reset_farm_activation<TokenX: store, TokenY: store>(account: &signer,
                                                                   active: bool) {
        let order = TokenSwap::compare_token<TokenX, TokenY>();
        assert(order != 0, ERROR_ROUTER_INVALID_TOKEN_PAIR);
        if (order == 1) {
            TokenSwapFarm::reset_farm_activation<TokenX, TokenY>(account, active);
        } else {
            TokenSwapFarm::reset_farm_activation<TokenY, TokenX>(account, active);
        };
    }

    public fun stake<TokenX: store, TokenY: store>(account: &signer, amount: u128) {
        let order = TokenSwap::compare_token<TokenX, TokenY>();
        assert(order != 0, ERROR_ROUTER_INVALID_TOKEN_PAIR);
        if (order == 1) {
            TokenSwapFarm::stake<TokenX, TokenY>(account, amount);
        } else {
            TokenSwapFarm::stake<TokenY, TokenX>(account, amount);
        };
    }

    public fun unstake<TokenX: store, TokenY: store>(account: &signer, amount: u128) {
        let order = TokenSwap::compare_token<TokenX, TokenY>();
        assert(order != 0, ERROR_ROUTER_INVALID_TOKEN_PAIR);
        if (order == 1) {
            TokenSwapFarm::unstake<TokenX, TokenY>(account, amount);
        } else {
            TokenSwapFarm::unstake<TokenY, TokenX>(account, amount);
        }
    }

    /// Havest governance token from pool
    public fun harvest<TokenX: store, TokenY: store>(account: &signer, amount: u128) {
        let order = TokenSwap::compare_token<TokenX, TokenY>();
        assert(order != 0, ERROR_ROUTER_INVALID_TOKEN_PAIR);
        if (order == 1) {
            TokenSwapFarm::harvest<TokenX, TokenY>(account, amount);
        } else {
            TokenSwapFarm::harvest<TokenY, TokenX>(account, amount);
        }
    }

    /// Get gain count
    public fun lookup_gain<TokenX: store, TokenY: store>(account: address): u128 {
        let order = TokenSwap::compare_token<TokenX, TokenY>();
        assert(order != 0, ERROR_ROUTER_INVALID_TOKEN_PAIR);
        if (order == 1) {
            TokenSwapFarm::lookup_gain<TokenX, TokenY>(account)
        } else {
            TokenSwapFarm::lookup_gain<TokenY, TokenX>(account)
        }
    }

    /// Query all stake amount
    public fun query_total_stake<TokenX: store, TokenY: store>(): u128 {
        let order = TokenSwap::compare_token<TokenX, TokenY>();
        assert(order != 0, ERROR_ROUTER_INVALID_TOKEN_PAIR);
        if (order == 1) {
            TokenSwapFarm::query_total_stake<TokenX, TokenY>()
        } else {
            TokenSwapFarm::query_total_stake<TokenY, TokenX>()
        }
    }

    /// Query all stake amount
    public fun query_stake<TokenX: store, TokenY: store>(account: address): u128 {
        let order = TokenSwap::compare_token<TokenX, TokenY>();
        assert(order != 0, ERROR_ROUTER_INVALID_TOKEN_PAIR);
        if (order == 1) {
            TokenSwapFarm::query_stake<TokenX, TokenY>(account)
        } else {
            TokenSwapFarm::query_stake<TokenY, TokenX>(account)
        }
    }

    public fun query_info<TokenX: store, TokenY: store>(): (bool, u128, u128, u128) {
        let order = TokenSwap::compare_token<TokenX, TokenY>();
        assert(order != 0, ERROR_ROUTER_INVALID_TOKEN_PAIR);
        if (order == 1) {
            TokenSwapFarm::query_info<TokenX, TokenY>()
        } else {
            TokenSwapFarm::query_info<TokenY, TokenX>()
        }
    }

    /// Query release per second
    public fun query_release_per_second<TokenX: store, TokenY: store>(): u128 {
        let order = TokenSwap::compare_token<TokenX, TokenY>();
        assert(order != 0, ERROR_ROUTER_INVALID_TOKEN_PAIR);
        if (order == 1) {
            TokenSwapFarm::query_release_per_second<TokenX, TokenY>()
        } else {
            TokenSwapFarm::query_release_per_second<TokenY, TokenX>()
        }
    }
}
}