address 0x3db7a2da7444995338a2413b151ee437 {
module SwapRouterTest {
    use 0x3db7a2da7444995338a2413b151ee437::TokenSwapRouter3;
    use 0x1::STC::STC;
    use 0x49156896A605F092ba1862C50a9036c9::TokenMock::{WETH, WUSDT,WDAI};
    use 0x3db7a2da7444995338a2413b151ee437::TestHelper;
    use 0x3db7a2da7444995338a2413b151ee437::CommonHelper;
    use 0x1::Signer;
    use 0x1::Debug;

    #[test(sender = @0x5f1288f6687eb8ba746081641bc4342e)]
//    #[test(a = @0x1, b = @0x2)]
    public fun test_swap_exact_token_for_token_router3(sender: signer) {
        TestHelper::before_test();
        TestHelper::init_account_with_stc(&sender, 100000);

        let amount_x_in = 15000;
        let amount_y_out_min = 10;
        let token_balance = CommonHelper::get_safe_balance<WDAI>(Signer::address_of(&sender));
        assert(token_balance == 0, 201);

        let (r_out, t_out, expected_token_balance) = TokenSwapRouter3::get_amount_out<STC, WETH, WUSDT, WDAI>(amount_x_in);
        TokenSwapRouter3::swap_exact_token_for_token<STC, WETH, WUSDT, WDAI>(&sender, amount_x_in, amount_y_out_min);

        // TokenSwapRouter::swap_exact_token_for_token<STC, WETH>(&signer, amount_x_in, r_out);
        // TokenSwapRouter::swap_exact_token_for_token<WETH, WUSDT>(&signer, r_out, t_out);
        // TokenSwapRouter::swap_exact_token_for_token<WUSDT, WDAI>(&signer, t_out, amount_y_out_min);

        let token_balance = CommonHelper::get_safe_balance<WDAI>(Signer::address_of(&sender));
        Debug::print<u128>(&r_out);
        Debug::print<u128>(&t_out);
        Debug::print<u128>(&token_balance);

        Debug::print<u128>(&amount_y_out_min);
        Debug::print<u128>(&expected_token_balance);
        assert(token_balance == expected_token_balance, (token_balance as u64));
        assert(token_balance >= amount_y_out_min, (token_balance as u64));
    }

}
}