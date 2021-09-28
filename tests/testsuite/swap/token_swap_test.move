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
//! sender: alice
address alice = {{alice}};
script {
    use 0x49156896A605F092ba1862C50a9036c9::TokenMock::{WUSDT};
    use 0x3db7a2da7444995338a2413b151ee437::CommonHelper;
    use 0x1::Math;

    fun init_account(signer: signer) {
        let precision: u8 = 9; //STC precision is also 9.
        let scaling_factor = Math::pow(10, (precision as u64));
        let usdt_amount: u128 = 50000 * scaling_factor;
        CommonHelper::safe_mint<WUSDT>(&signer, usdt_amount);
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
// check: EXECUTED


////! new-transaction
////! sender: liquidier
//// mint some WUSDT to liquidier
//address alice = {{alice}};
//address liquidier = {{liquidier}};
//script{
//    use 0x49156896A605F092ba1862C50a9036c9::TokenMock;
//    use 0x1::Account;
//    use 0x1::Token;
//    fun init_liquidier(signer: signer) {
//        let usdt_amount = 100000000;
//        Account::do_accept_token<TokenMock::WUSDT>(&signer);
//        let usdt_token = Token::mint<TokenMock::WUSDT>(&signer, usdt_amount);
//        Account::deposit_to_self(&signer, usdt_token);
//        assert(Account::balance<TokenMock::WUSDT>(@liquidier) == 100000000, 42);
//    }
//}
//
//// check: EXECUTED


//! new-transaction
//! sender: alice
address alice = {{alice}};
script{
    use 0x1::STC;
    use 0x49156896A605F092ba1862C50a9036c9::TokenMock;
    use 0x3db7a2da7444995338a2413b151ee437::TokenSwap;
    use 0x3db7a2da7444995338a2413b151ee437::TokenSwap::LiquidityToken;
    use 0x1::Account;

    fun main(signer: signer) {
        Account::do_accept_token<LiquidityToken<STC::STC, TokenMock::WUSDT>>(&signer);
        // STC/WUSDT = 1:2
        let stc_amount = 10000;
        let usdt_amount = 20000;
        let stc = Account::withdraw<STC::STC>( &signer, stc_amount);
        let usdx = Account::withdraw<TokenMock::WUSDT>( &signer, usdt_amount);
        let liquidity_token = TokenSwap::mint<STC::STC, TokenMock::WUSDT>(stc, usdx);
        Account::deposit_to_self( &signer, liquidity_token);

        let (x, y) = TokenSwap::get_reserves<STC::STC, TokenMock::WUSDT>();
        assert(x == stc_amount, 111);
        assert(y == usdt_amount, 112);
    }
}
// check: EXECUTED

//! new-transaction
//! sender: alice
address alice = {{alice}};
script {
    use 0x1::STC;
    use 0x49156896A605F092ba1862C50a9036c9::TokenMock;
    use 0x3db7a2da7444995338a2413b151ee437::TokenSwap;
    use 0x3db7a2da7444995338a2413b151ee437::TokenSwapLibrary;
    use 0x1::Account;
    use 0x1::Token;
    fun main(signer: signer) {
        let stc_amount = 100000;
        let stc = Account::withdraw<STC::STC>( &signer, stc_amount);
        let (x, y) = TokenSwap::get_reserves<STC::STC, TokenMock::WUSDT>();
        let amount_out = TokenSwapLibrary::get_amount_out(stc_amount, x, y);
        let (stc_token, usdt_token) = TokenSwap::swap<STC::STC, TokenMock::WUSDT>(stc, amount_out, Token::zero<TokenMock::WUSDT>(), 0);
        Token::destroy_zero(stc_token);
        Account::deposit_to_self(&signer, usdt_token);
    }
}

// check: EXECUTED

//! new-transaction
//! sender: alice
address alice = {{alice}};
script{
    use 0x1::STC;
    use 0x1::Account;
    use 0x1::Signer;
    use 0x49156896A605F092ba1862C50a9036c9::TokenMock;
    use 0x3db7a2da7444995338a2413b151ee437::TokenSwap;
    use 0x3db7a2da7444995338a2413b151ee437::TokenSwap::LiquidityToken;
    // use 0x1::Debug;

    fun main(signer: signer) {
        let liquidity_balance = Account::balance<LiquidityToken<STC::STC, TokenMock::WUSDT>>(Signer::address_of( &signer));
        let liquidity = Account::withdraw<LiquidityToken<STC::STC, TokenMock::WUSDT>>( &signer, liquidity_balance);
        let (stc, usdx) = TokenSwap::burn<STC::STC, TokenMock::WUSDT>(liquidity);
        Account::deposit_to_self(&signer, stc);
        Account::deposit_to_self(&signer, usdx);

        let (x, y) = TokenSwap::get_reserves<STC::STC, TokenMock::WUSDT>();
        assert(x == 0, 111);
        assert(y == 0, 112);
    }
}
// check: EXECUTED
