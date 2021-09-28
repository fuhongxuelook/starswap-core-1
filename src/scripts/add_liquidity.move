// Copyright (c) The Elements Stuidio Core Contributors
// SPDX-License-Identifier: Apache-2.0
// check: EXECUTED
//

script {
    use 0x3db7a2da7444995338a2413b151ee437::TokenSwapRouter;

    fun main<X: store, Y: store>(account: signer,
                                 amount_x_desired: u128,
                                 amount_y_desired: u128,
                                 amount_x_min: u128,
                                 amount_y_min: u128) {
        TokenSwapRouter::add_liquidity<X, Y>(
            &account,
            amount_x_desired,
            amount_y_desired,
            amount_x_min,
            amount_y_min);
    }
}
