//! account: alice, 10000000000000 0x1::STC::STC
//! account: joe
//! account: admin, 0x3db7a2da7444995338a2413b151ee437, 10000000000000 0x1::STC::STC
//! account: liquidier, 10000000000000 0x1::STC::STC
//! account: exchanger
//! account: tokenholder, 0x49156896A605F092ba1862C50a9036c9


//! new-transaction
//! sender: tokenholder
address alice = {{alice}};
script {
    use 0x49156896A605F092ba1862C50a9036c9::TokenMock::{Self, WUSDT};

    fun init_token(signer: signer) {
        let precision: u8 = 9; //STC precision is also 9.
        TokenMock::register_token<WUSDT>(&signer, precision);
    }
}
// check: EXECUTED


//! new-transaction
//! sender: admin
address alice = {{alice}};
script {
    use 0x49156896A605F092ba1862C50a9036c9::TokenMock::{WUSDT};
    use 0x3db7a2da7444995338a2413b151ee437::TokenSwap;
    use 0x1::STC::STC;

    fun register_token_pair(signer: signer) {
        //token pair register must be swap admin account
        TokenSwap::register_swap_pair<STC, WUSDT>(&signer);
        assert(TokenSwap::swap_pair_exists<STC, WUSDT>(), 111);
    }
}

//! new-transaction
//! sender: alice
address alice = {{alice}};
script {
    use 0x1::Debug;
    use 0x49156896A605F092ba1862C50a9036c9::TokenMock::WUSDT;
    use 0x3db7a2da7444995338a2413b151ee437::CommonHelper;
    use 0x1::STC::STC;
    use 0x1::Math;
    //use 0x3db7a2da7444995338a2413b151ee437::TokenSwap;
    use 0x3db7a2da7444995338a2413b151ee437::TokenSwapRouter;
    use 0x3db7a2da7444995338a2413b151ee437::TokenSwapLibrary;

    fun main(signer: signer) {
        let precision: u8 = 9; //STC precision is also 9.

        let scaling_factor = Math::pow(10, (precision as u64));// STC/WUSDT = 1:5
        let stc_amount: u128 = 1000 * scaling_factor;
        let usdt_amount: u128 = 1000 * scaling_factor;

        CommonHelper::safe_mint<WUSDT>(&signer, usdt_amount);
        ////////////////////////////////////////////////////////////////////////////////////////////
        // Add liquidity, STC/WUSDT = 1:1
        let amount_stc_desired: u128 = 1 * scaling_factor;
        let amount_usdt_desired: u128 = 1 * scaling_factor;
        let amount_stc_min: u128 = stc_amount;
        let amount_usdt_min: u128 = usdt_amount;
        TokenSwapRouter::add_liquidity<STC, WUSDT>(&signer,
            amount_stc_desired, amount_usdt_desired, amount_stc_min, amount_usdt_min);
        let total_liquidity: u128 = TokenSwapRouter::total_liquidity<STC, WUSDT>();
        assert(total_liquidity > 0, 10000);

        let (reserve_x, reserve_y) = TokenSwapRouter::get_reserves<STC, WUSDT>();
        //Debug::print<u128>(&reserve_x);
        //Debug::print<u128>(&reserve_y);
        assert(reserve_x >= amount_stc_desired, 10001);
        // assert(reserve_y >=, 10002);

        let amount_out_1 = TokenSwapLibrary::get_amount_out(10 * scaling_factor, reserve_x, reserve_y);
        Debug::print<u128>(&amount_out_1);
        // assert(1 * scaling_factor >= (1 * scaling_factor * reserve_y) / reserve_x * (997 / 1000), 1003);

        let amount_out_2 = TokenSwapLibrary::quote(amount_stc_desired, reserve_x, reserve_y);
        Debug::print<u128>(&amount_out_2);
        // assert(amount_out_2 <= amount_usdt_desired, 1004);

        let amount_out_3 = TokenSwapLibrary::get_amount_in(100, 100000000, 10000000000);
        Debug::print<u128>(&amount_out_3);
        //assert(amount_out_3 >= amount_stc_desired, 1005);
    }
}