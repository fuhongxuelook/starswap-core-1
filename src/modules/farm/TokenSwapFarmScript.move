// Copyright (c) The Elements Stuidio Core Contributors
// SPDX-License-Identifier: Apache-2.0

// TODO: replace the address with admin address
address 0x3db7a2da7444995338a2413b151ee437 {
module TokenSwapFarmScript {
    use 0x3db7a2da7444995338a2413b151ee437::TokenSwapFarmRouter;

    /// Called by admin account
    public(script) fun add_farm_pool<TokenX: store, TokenY: store>(account: signer, release_per_second: u128) {
        TokenSwapFarmRouter::add_farm_pool<TokenX, TokenY>(&account, release_per_second);
    }


    public(script) fun reset_farm_activation<TokenX: store, TokenY: store>(account: signer, active: bool) {
        TokenSwapFarmRouter::reset_farm_activation<TokenX, TokenY>(&account, active);
    }

    /// Stake liquidity token
    public(script) fun stake<TokenX: store, TokenY: store>(account: signer, amount: u128) {
        TokenSwapFarmRouter::stake<TokenX, TokenY>(&account, amount);
    }

    /// Unstake liquidity token
    public(script) fun unstake<TokenX: store, TokenY: store>(account: signer, amount: u128) {
        TokenSwapFarmRouter::unstake<TokenX, TokenY>(&account, amount);
    }

    /// Havest governance token from pool
    public(script) fun harvest<TokenX: store, TokenY: store>(account: signer, amount: u128) {
        TokenSwapFarmRouter::harvest<TokenX, TokenY>(&account, amount);
    }

    /// Get gain count
    public fun lookup_gain<TokenX: store, TokenY: store>(account: address): u128 {
        TokenSwapFarmRouter::lookup_gain<TokenX, TokenY>(account)
    }

    /// Query an info from farm which combinded TokenX and TokenY
    public fun query_info<TokenX: store, TokenY: store>(): (bool, u128, u128, u128) {
        TokenSwapFarmRouter::query_info<TokenX, TokenY>()
    }

    /// Query all stake amount
    public fun query_total_stake<TokenX: store, TokenY: store>(): u128 {
        TokenSwapFarmRouter::query_total_stake<TokenX, TokenY>()
    }

    /// Query all stake amount
    public fun query_stake<TokenX: store, TokenY: store>(account: address): u128 {
        TokenSwapFarmRouter::query_stake<TokenX, TokenY>(account)
    }

    /// Query release per second
    public fun query_release_per_second<TokenX: store, TokenY: store>(): u128 {
        TokenSwapFarmRouter::query_release_per_second<TokenX, TokenY>()
    }
}
}