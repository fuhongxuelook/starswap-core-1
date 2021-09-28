address 0x3db7a2da7444995338a2413b151ee437 {
module TestHelper {
    use 0x1::Token;
    use 0x1::Account;
    use 0x1::Signer;
    use 0x1::STC::STC ;
    use 0x1::Timestamp;
    use 0x1::NFT;
    use 0x1::ChainId;
    use 0x1::Oracle;
    use 0x1::CoreAddresses;
    use 0x3db7a2da7444995338a2413b151ee437::SwapTestHelper;
    use 0x3db7a2da7444995338a2413b151ee437::CommonHelper;
    use 0x49156896A605F092ba1862C50a9036c9::TokenMock::{Self, WETH, WUSDT, WDAI, WBTC};
    use 0x9350502a3af6c617e9a42fa9e306a385::BX_USDT::BX_USDT;

    struct GenesisSignerCapability has key {
        cap: Account::SignerCapability,
    }

    const PRECISION_9: u8 = 9;
    const PRECISION_18: u8 = 18;

    public fun before_test() {
        let stdlib = Account::create_genesis_account(CoreAddresses::GENESIS_ADDRESS());
        Timestamp::initialize(&stdlib, 1631244104193u64);
        Token::register_token<STC>(&stdlib, PRECISION_9);
        ChainId::initialize(&stdlib, 254);

        Oracle::initialize(&stdlib);
        NFT::initialize(&stdlib);

        let cap = Account::remove_signer_capability( &stdlib);
        let genesis_cap = GenesisSignerCapability { cap: cap };
        move_to( &stdlib, genesis_cap);

        let admin_signer = Account::create_genesis_account(SwapTestHelper::get_admin_address());
        let token_holder_signer = Account::create_genesis_account(SwapTestHelper::get_token_holder_address());
        let bx_usdt_signer = Account::create_genesis_account(SwapTestHelper::get_bx_usdt_address());
        let fee_signer = Account::create_genesis_account(SwapTestHelper::get_fee_address());

        // init swap pool
        init_tokens(&token_holder_signer);
//        init_account_with_stc(&admin_signer, 100000u128);
        SwapTestHelper::init_fee_token(&bx_usdt_signer);
        SwapTestHelper::init_token_pairs_register(&admin_signer);
        SwapTestHelper::init_token_pairs_liquidity(&token_holder_signer);
        CommonHelper::safe_accept_token<BX_USDT>(&fee_signer);
    }


    fun genesis_signer(): signer acquires GenesisSignerCapability {
        let genesis_cap = borrow_global<GenesisSignerCapability>(CoreAddresses::GENESIS_ADDRESS());
        Account::create_signer_with_cap(&genesis_cap.cap)
    }

    public fun init_tokens(account: &signer){
        TokenMock::register_token<WETH>(account, PRECISION_18);
        TokenMock::register_token<WUSDT>(account, PRECISION_18);
        TokenMock::register_token<WDAI>(account, PRECISION_18);
        TokenMock::register_token<WBTC>(account, PRECISION_18);
    }

    public fun init_account_with_stc(account: &signer, amount: u128) acquires GenesisSignerCapability {
        let account_address = Signer::address_of(account);
        if (account_address != SwapTestHelper::get_admin_address()) {
            Account::create_genesis_account(account_address);
        };

        if (amount > 0) {
            deposit_stc_to(account, amount);
            let stc_balance = Account::balance<STC>(account_address);
            assert(stc_balance == amount, 999);
        };
    }

    public fun deposit_stc_to(account: &signer, amount: u128) acquires GenesisSignerCapability {
        let is_accept_token = Account::is_accepts_token<STC>(Signer::address_of(account));
        if (!is_accept_token) {
            Account::do_accept_token<STC>(account);
        };
        let stc_token = Token::mint<STC>(&genesis_signer(), amount);
        Account::deposit<STC>(Signer::address_of(account), stc_token);
    }

    public fun mint_stc_to(amount: u128): Token::Token<STC> acquires GenesisSignerCapability {
        Token::mint<STC>(&genesis_signer(), amount)
    }

    public fun set_timestamp(time: u64) acquires GenesisSignerCapability {
        let genesis_cap = borrow_global<GenesisSignerCapability>(CoreAddresses::GENESIS_ADDRESS());
        let genesis_account = Account::create_signer_with_cap(&genesis_cap.cap);
        Timestamp::update_global_time(&genesis_account, time);
    }
}
}