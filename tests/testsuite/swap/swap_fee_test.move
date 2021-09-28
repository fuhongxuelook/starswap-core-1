//! account: admin, 0x3db7a2da7444995338a2413b151ee437, 200000 0x1::STC::STC
//! account: feetokenholder, 0x9350502a3af6c617e9a42fa9e306a385, 400000 0x1::STC::STC
//! account: feeadmin, 0xd231d9da8e37fc3d9ff3f576cf978535
//! account: exchanger, 100000 0x1::STC::STC
//! account: alice, 500000 0x1::STC::STC
//! account: tokenholder, 0x49156896A605F092ba1862C50a9036c9


//! new-transaction
//! sender: tokenholder
address alice = {{alice}};
script {
    use 0x49156896A605F092ba1862C50a9036c9::TokenMock::{Self, WETH, WUSDT, WDAI};

    fun token_init(signer: signer) {
        TokenMock::register_token<WETH>(&signer, 18u8);
        TokenMock::register_token<WUSDT>(&signer, 18u8);
        TokenMock::register_token<WDAI>(&signer, 18u8);
    }
}

// check: EXECUTED

//! new-transaction
//! sender: alice
address alice = {{alice}};
script {
    use 0x49156896A605F092ba1862C50a9036c9::TokenMock::{WETH, WUSDT, WDAI};
    use 0x3db7a2da7444995338a2413b151ee437::CommonHelper;

    fun init_account(signer: signer) {
        CommonHelper::safe_mint<WETH>(&signer, 600000u128);
        CommonHelper::safe_mint<WUSDT>(&signer, 500000u128);
        CommonHelper::safe_mint<WDAI>(&signer, 200000u128);
    }
}
// check: EXECUTED


//! new-transaction
//! sender: feetokenholder
address alice = {{alice}};
script {
    use 0x9350502a3af6c617e9a42fa9e306a385::BX_USDT::BX_USDT;
    use 0x1::Token;
    use 0x1::Account;

    fun fee_token_init(signer: signer) {
        Token::register_token<BX_USDT>(&signer, 9);
        Account::do_accept_token<BX_USDT>(&signer);
        let token = Token::mint<BX_USDT>(&signer, 500000u128);
        Account::deposit_to_self(&signer, token);
    }
}

// check: EXECUTED


//! new-transaction
//! sender: exchanger
address alice = {{alice}};
script {
    use 0x49156896A605F092ba1862C50a9036c9::TokenMock::{WETH};
    use 0x1::Account;

    fun accept_token(signer: signer) {
        Account::do_accept_token<WETH>(&signer);
    }
}
// check: EXECUTED


//! new-transaction
//! sender: alice
address alice = {{alice}};
script {
    use 0x1::Account;
    use 0x9350502a3af6c617e9a42fa9e306a385::BX_USDT::BX_USDT;

    fun accept_token(signer: signer) {
        Account::do_accept_token<BX_USDT>(&signer);
    }
}
// check: EXECUTED


//! new-transaction
//! sender: feeadmin
address alice = {{alice}};
script {
    use 0x1::Account;
    use 0x9350502a3af6c617e9a42fa9e306a385::BX_USDT::BX_USDT;

    fun accept_token(signer: signer) {
        Account::do_accept_token<BX_USDT>(&signer);
    }
}
// check: EXECUTED


//! new-transaction
//! sender: exchanger
address alice = {{alice}};
address exchanger = {{exchanger}};
script {
    use 0x49156896A605F092ba1862C50a9036c9::TokenMock::{WETH};
    use 0x3db7a2da7444995338a2413b151ee437::CommonHelper;

    fun transfer(signer: signer) {
        CommonHelper::safe_mint<WETH>(&signer, 100000u128);
    }
}

// check: EXECUTED


//! new-transaction
//! sender: feetokenholder
address alice = {{alice}};
address exchanger = {{exchanger}};
script {
    use 0x3db7a2da7444995338a2413b151ee437::CommonHelper;
    use 0x9350502a3af6c617e9a42fa9e306a385::BX_USDT::BX_USDT;

    fun transfer(signer: signer) {
        CommonHelper::transfer<BX_USDT>(&signer, @alice, 300000u128);
    }
}

// check: EXECUTED


//! new-transaction
//! sender: admin
address alice = {{alice}};
script {
    use 0x49156896A605F092ba1862C50a9036c9::TokenMock::{WETH, WUSDT};
    use 0x3db7a2da7444995338a2413b151ee437::TokenSwapRouter;
    use 0x1::STC::STC;
    use 0x9350502a3af6c617e9a42fa9e306a385::BX_USDT::BX_USDT;

    fun register_token_pair(signer: signer) {
        //token pair register must be swap admin account
        TokenSwapRouter::register_swap_pair<WETH, WUSDT>(&signer);
        assert(TokenSwapRouter::swap_pair_exists<WETH, WUSDT>(), 111);

        TokenSwapRouter::register_swap_pair<STC, WETH>(&signer);
        assert(TokenSwapRouter::swap_pair_exists<STC, WETH>(), 112);

        TokenSwapRouter::register_swap_pair<STC, BX_USDT>(&signer);
        assert(TokenSwapRouter::swap_pair_exists<STC, BX_USDT>(), 113);

        TokenSwapRouter::register_swap_pair<WETH, BX_USDT>(&signer);
        assert(TokenSwapRouter::swap_pair_exists<WETH, BX_USDT>(), 114);
    }
}

// check: EXECUTED


//! new-transaction
//! sender: alice
address alice = {{alice}};
script {
    use 0x3db7a2da7444995338a2413b151ee437::TokenSwapRouter;
    use 0x1::STC::STC;
    use 0x49156896A605F092ba1862C50a9036c9::TokenMock::{WETH, WUSDT};
    use 0x9350502a3af6c617e9a42fa9e306a385::BX_USDT::BX_USDT;

    fun add_liquidity(signer: signer) {
        // for the first add liquidity
        TokenSwapRouter::add_liquidity<WETH, WUSDT>(&signer, 10000, 20000, 100, 100);
        TokenSwapRouter::add_liquidity<STC, WETH>(&signer, 100000, 30000, 100, 100);

        TokenSwapRouter::add_liquidity<STC, BX_USDT>(&signer, 20000, 5000, 100, 100);
        TokenSwapRouter::add_liquidity<WETH, BX_USDT>(&signer, 50000, 180000, 100, 100);
    }
}

// check: EXECUTED


//! new-transaction
//! sender: exchanger
address alice = {{alice}};
address feeadmin = {{feeadmin}};
script {
    use 0x3db7a2da7444995338a2413b151ee437::TokenSwap;
    use 0x3db7a2da7444995338a2413b151ee437::TokenSwapRouter;
    use 0x3db7a2da7444995338a2413b151ee437::TokenSwapLibrary;
    use 0x1::STC::STC;
    use 0x49156896A605F092ba1862C50a9036c9::TokenMock::{WETH};
    use 0x9350502a3af6c617e9a42fa9e306a385::BX_USDT::BX_USDT;

    use 0x3db7a2da7444995338a2413b151ee437::CommonHelper;
    use 0x1::Debug;
    use 0x1::Signer;

    fun swap_exact_token_for_token_swap_fee_setup(signer: signer) {
        let amount_x_in = 20000;
        let amount_y_out_min = 10;
        let fee_balance = CommonHelper::get_safe_balance<BX_USDT>(@feeadmin);
        assert(fee_balance == 0, 201);

        let (reserve_x, reserve_y) = TokenSwapRouter::get_reserves<STC, WETH>();
        let y_out = TokenSwapLibrary::get_amount_out(amount_x_in, reserve_x, reserve_y); 
        let y_out_without_fee = TokenSwapLibrary::get_amount_out_without_fee(amount_x_in, reserve_x, reserve_y); 
        let swap_fee = y_out_without_fee - y_out;
        TokenSwapRouter::swap_exact_token_for_token<STC, WETH>(&signer, amount_x_in, amount_y_out_min);
        if (! TokenSwap::get_swap_fee_on()){
          let account_address = Signer::address_of(&signer);
          TokenSwapRouter::swap_exact_token_for_token_swap_fee_setup<STC, WETH>(account_address, amount_x_in, y_out, reserve_x, reserve_y);
        };

        let (reserve_p, reserve_q) = TokenSwapRouter::get_reserves<WETH, BX_USDT>();
        let fee_out = TokenSwapLibrary::get_amount_out_without_fee(swap_fee, reserve_p, reserve_q);
        let fee_balance = CommonHelper::get_safe_balance<BX_USDT>(@feeadmin);
        
        Debug::print<u128>(&y_out);
        Debug::print<u128>(&y_out_without_fee);
        Debug::print<u128>(&swap_fee);
        Debug::print<u128>(&fee_out);
        Debug::print<u128>(&fee_balance);
        assert(fee_balance == fee_out, (fee_balance as u64));
        assert(fee_balance > 0, (fee_balance as u64));
    }
}
//the case: token pay for fee and fee token pair exist
// check: EXECUTED



//! new-transaction
//! sender: exchanger
address alice = {{alice}};
address feeadmin = {{feeadmin}};
script {
    use 0x3db7a2da7444995338a2413b151ee437::TokenSwap;
    use 0x3db7a2da7444995338a2413b151ee437::TokenSwapRouter;
    use 0x3db7a2da7444995338a2413b151ee437::TokenSwapLibrary;
    use 0x1::STC::STC;
    use 0x49156896A605F092ba1862C50a9036c9::TokenMock::{WETH};
    use 0x9350502a3af6c617e9a42fa9e306a385::BX_USDT::BX_USDT;

    use 0x3db7a2da7444995338a2413b151ee437::CommonHelper;
    use 0x1::Debug;
    use 0x1::Signer;

    fun swap_token_for_exact_token_swap_fee_setup(signer: signer) {
        let amount_x_in_max = 8000;
        let amount_y_out = 1000;
        let fee_balance_start = CommonHelper::get_safe_balance<BX_USDT>(@feeadmin);
        assert(fee_balance_start > 0, 202);

        let (reserve_x, reserve_y) = TokenSwapRouter::get_reserves<STC, WETH>();
        let x_in = TokenSwapLibrary::get_amount_in(amount_y_out, reserve_x, reserve_y); 
        let x_in_without_fee = TokenSwapLibrary::get_amount_in_without_fee(amount_y_out, reserve_x, reserve_y); 
        let swap_fee = x_in - x_in_without_fee;
        TokenSwapRouter::swap_token_for_exact_token<STC, WETH>(&signer, amount_x_in_max, amount_y_out);
        if (! TokenSwap::get_swap_fee_on()){
            let account_address = Signer::address_of(&signer);
            TokenSwapRouter::swap_token_for_exact_token_swap_fee_setup<STC, WETH>(account_address, x_in, amount_y_out, reserve_x, reserve_y);
        };

        let (reserve_p, reserve_q) = TokenSwapRouter::get_reserves<STC, BX_USDT>();
        let fee_out = TokenSwapLibrary::get_amount_out_without_fee(swap_fee, reserve_p, reserve_q);
        let fee_balance_end = CommonHelper::get_safe_balance<BX_USDT>(@feeadmin);
        let fee_balance_change = fee_balance_end - fee_balance_start;
        
        Debug::print<u128>(&x_in);
        Debug::print<u128>(&x_in_without_fee);
        Debug::print<u128>(&swap_fee);
        Debug::print<u128>(&fee_out);
        Debug::print<u128>(&fee_balance_change);
        assert(fee_balance_change == fee_out, (fee_balance_change as u64));
        assert(fee_balance_change > 0, (fee_balance_change as u64));
    }
}
//the case: token pay for fee and fee token pair exist
// check: EXECUTED



//! new-transaction
//! sender: exchanger
address alice = {{alice}};
address feeadmin = {{feeadmin}};
script {
    use 0x3db7a2da7444995338a2413b151ee437::TokenSwap;
    use 0x3db7a2da7444995338a2413b151ee437::TokenSwapRouter;
    use 0x3db7a2da7444995338a2413b151ee437::TokenSwapLibrary;
    use 0x49156896A605F092ba1862C50a9036c9::TokenMock::{WETH, WUSDT};
    use 0x9350502a3af6c617e9a42fa9e306a385::BX_USDT::BX_USDT;

    use 0x3db7a2da7444995338a2413b151ee437::CommonHelper;
    use 0x1::Debug;
    use 0x1::Signer;

    fun pay_for_token_and_fee_token_pair_not_exist(signer: signer) {
        let amount_x_in = 20000;
        let amount_y_out_min = 10;
        let fee_balance_start = CommonHelper::get_safe_balance<BX_USDT>(@feeadmin);

        let (reserve_x, reserve_y) = TokenSwapRouter::get_reserves<WETH, WUSDT>();
        let y_out = TokenSwapLibrary::get_amount_out(amount_x_in, reserve_x, reserve_y); 
        let y_out_without_fee = TokenSwapLibrary::get_amount_out_without_fee(amount_x_in, reserve_x, reserve_y); 
        let swap_fee = y_out_without_fee - y_out;
        TokenSwapRouter::swap_exact_token_for_token<WETH, WUSDT>(&signer, amount_x_in, amount_y_out_min);
        if (! TokenSwap::get_swap_fee_on()){
            let account_address = Signer::address_of(&signer);
            TokenSwapRouter::swap_exact_token_for_token_swap_fee_setup<WETH, WUSDT>(account_address, amount_x_in, y_out, reserve_x, reserve_y);
        };

        let fee_balance_end = CommonHelper::get_safe_balance<BX_USDT>(@feeadmin);
        let fee_balance_change = fee_balance_end - fee_balance_start;
        
        Debug::print<u128>(&y_out);
        Debug::print<u128>(&y_out_without_fee);
        Debug::print<u128>(&swap_fee);
        assert(fee_balance_change == 0, 204);
    }
}
//the case: token pay for fee and fee token pair not exist
// check: EXECUTED