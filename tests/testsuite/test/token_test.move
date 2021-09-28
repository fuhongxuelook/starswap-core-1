//! account: alice, 50000 0x1::STC::STC
//! account: admin


//! new-transaction
//! sender: alice
address alice = {{alice}};
script {
    use 0x1::Debug;
    use 0x49156896A605F092ba1862C50a9036c9::TokenMock::WUSDT;
    use 0x1::STC::STC;
    use 0x3db7a2da7444995338a2413b151ee437::TokenSwap;

    fun main(_signer: signer) {
        let ret = TokenSwap::compare_token<STC, WUSDT>();
        Debug::print<u8>(&ret);
        assert(ret == 1, 10000);
    }
}
// check: EXECUTED
