// Copyright (c) The Elements Stuidio Core Contributors
// SPDX-License-Identifier: Apache-2.0

address 0x3db7a2da7444995338a2413b151ee437 {
module TokenSwapGovScript {

    use 0x3db7a2da7444995338a2413b151ee437::TokenSwapGov;

    /// Initial as genesis that will create pool list by Starswap Ecnomic Model list
    public(script) fun genesis_initialize(account: signer) {
        TokenSwapGov::genesis_initialize(&account);
    }

    /// Harverst TBD by given pool type, call ed by user
    public(script) fun dispatch<PoolType: store>(account: signer, acceptor: address, amount: u128) {
        TokenSwapGov::dispatch<PoolType>(&account, acceptor, amount);
    }
}
}