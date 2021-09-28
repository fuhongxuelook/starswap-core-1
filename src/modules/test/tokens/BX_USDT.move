

address 0x3db7a2da7444995338a2413b151ee437 {
module BX_USDT {
    use 0x1::Token;
    use 0x1::Account;

    /// BX_USDT token marker.
    struct BX_USDT has copy, drop, store {}

    /// precision of BX_USDT token.
    const PRECISION: u8 = 9;

    /// BX_USDT initialization.
    public fun init(account: &signer) {
        Token::register_token<BX_USDT>(account, PRECISION);
        Account::do_accept_token<BX_USDT>(account);
    }

    public fun mint(account: &signer, amount: u128) {
        let token = Token::mint<BX_USDT>(account, amount);
        Account::deposit_to_self<BX_USDT>(account, token)
    }
}

module BXUSDTScripts {
    use 0x3db7a2da7444995338a2413b151ee437::BX_USDT;

    public(script) fun init(account: signer) {
        BX_USDT::init(&account);
    }

    public(script) fun mint(account: signer, amount: u128) {
        BX_USDT::mint(&account, amount);
    }
}

}