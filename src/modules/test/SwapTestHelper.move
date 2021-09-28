address 0x3db7a2da7444995338a2413b151ee437 {
module SwapTestHelper {
    use 0x1::Token;
    use 0x1::Account;
    use 0x1::STC::STC ;

    use 0x3db7a2da7444995338a2413b151ee437::TokenSwapRouter;
    use 0x9350502a3af6c617e9a42fa9e306a385::BX_USDT::BX_USDT;
    use 0x49156896A605F092ba1862C50a9036c9::TokenMock::{WETH, WUSDT, WDAI, WBTC};


    const PRECISION_9: u8 = 9;
    const PRECISION_18: u8 = 18;
    //    const GENESIS_ADDRESS : address = @0x4fe7BBbFcd97987b966415F01995a229;
    const TOKEN_HOLDER_ADDRESS : address = @0x49156896A605F092ba1862C50a9036c9;
    const ADMIN_ADDRESS : address = @0x3db7a2da7444995338a2413b151ee437;
    const BX_USDT_ADDRESS : address = @0x9350502a3af6c617e9a42fa9e306a385;
    const FEE_ADDRESS : address = @0xd231d9da8e37fc3d9ff3f576cf978535;

    public fun get_admin_address(): address {
        ADMIN_ADDRESS
    }

    public fun get_token_holder_address(): address {
        TOKEN_HOLDER_ADDRESS
    }

    public fun get_bx_usdt_address(): address {
        BX_USDT_ADDRESS
    }

    public fun get_fee_address(): address {
        FEE_ADDRESS
    }

    public fun init_token_pairs_register(account: &signer){
        TokenSwapRouter::register_swap_pair<WETH, WUSDT>(account);
        assert(TokenSwapRouter::swap_pair_exists<WETH, WUSDT>(), 111);

        TokenSwapRouter::register_swap_pair<WUSDT, WDAI>(account);
        assert(TokenSwapRouter::swap_pair_exists<WUSDT, WDAI>(), 112);

        TokenSwapRouter::register_swap_pair<WDAI, WBTC>(account);
        assert(TokenSwapRouter::swap_pair_exists<WDAI, WBTC>(), 113);

        TokenSwapRouter::register_swap_pair<STC, WETH>(account);
        assert(TokenSwapRouter::swap_pair_exists<STC, WETH>(), 114);

        TokenSwapRouter::register_swap_pair<WBTC, WETH>(account);
        assert(TokenSwapRouter::swap_pair_exists<WBTC, WETH>(), 115);

        TokenSwapRouter::register_swap_pair<STC, BX_USDT>(account);
        assert(TokenSwapRouter::swap_pair_exists<STC, BX_USDT>(), 116);

        TokenSwapRouter::register_swap_pair<WETH, BX_USDT>(account);
        assert(TokenSwapRouter::swap_pair_exists<WETH, BX_USDT>(), 117);
    }

    public fun init_token_pairs_liquidity(account: &signer) {
        TokenSwapRouter::add_liquidity<WETH, WUSDT>(account, 5000, 100000, 100, 100);
        TokenSwapRouter::add_liquidity<WUSDT, WDAI>(account, 20000, 30000, 100, 100);
        TokenSwapRouter::add_liquidity<WDAI, WBTC>(account, 100000, 4000, 100, 100);
        TokenSwapRouter::add_liquidity<STC, WETH>(account, 200000, 10000, 100, 100);
        TokenSwapRouter::add_liquidity<WETH, WBTC>(account, 60000, 5000, 100, 100);
        TokenSwapRouter::add_liquidity<STC, BX_USDT>(account, 160000, 5000, 100, 100);
        TokenSwapRouter::add_liquidity<WETH, BX_USDT>(account, 6000, 20000, 100, 100);
    }

    public fun init_fee_token(account: &signer) {
        Token::register_token<BX_USDT>(account, PRECISION_9);
        Account::do_accept_token<BX_USDT>(account);
        let token = Token::mint<BX_USDT>(account, 5000000u128);
        Account::deposit_to_self(account, token);
    }

}
}