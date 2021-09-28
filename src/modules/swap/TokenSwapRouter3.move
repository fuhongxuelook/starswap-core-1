// Copyright (c) The Elements Stuidio Core Contributors
// SPDX-License-Identifier: Apache-2.0

// TODO: replace the address with admin address
address 0x3db7a2da7444995338a2413b151ee437 {
module TokenSwapRouter3 {

    use 0x3db7a2da7444995338a2413b151ee437::TokenSwapRouter;
    use 0x3db7a2da7444995338a2413b151ee437::TokenSwapRouter2;
    use 0x3db7a2da7444995338a2413b151ee437::TokenSwapLibrary;

    const ERROR_ROUTER_PARAMETER_INVALID: u64 = 1001;
    const ERROR_ROUTER_Y_OUT_LESSTHAN_EXPECTED: u64 = 1002;
    const ERROR_ROUTER_X_IN_OVER_LIMIT_MAX: u64 = 1003;

    public fun get_amount_in<X: store, R: store, T: store, Y: store>(amount_y_out: u128): (u128, u128, u128) {
        let (t_in, r_in) = TokenSwapRouter2::get_amount_in<R, T, Y>(amount_y_out);

        let (reserve_x, reserve_r) = TokenSwapRouter::get_reserves<X, R>();
        let x_in = TokenSwapLibrary::get_amount_in(r_in, reserve_x, reserve_r);

        (t_in, r_in, x_in)
    }

    public fun get_amount_out<X: store, R: store, T: store, Y: store>(amount_x_in: u128): (u128, u128, u128) {
        let (r_out, t_out) = TokenSwapRouter2::get_amount_out<X, R, T>(amount_x_in);

        let (reserve_t, reserve_y) = TokenSwapRouter::get_reserves<T, Y>();
        let y_out = TokenSwapLibrary::get_amount_out(t_out, reserve_t, reserve_y);

        (r_out, t_out, y_out)
    }

    public fun swap_exact_token_for_token<X: store, R: store, T: store, Y: store>(
        signer: &signer,
        amount_x_in: u128,
        amount_y_out_min: u128) {
        // calculate actual y out
        let (r_out, t_out, y_out) = get_amount_out<X, R, T, Y>(amount_x_in);
        assert(y_out >= amount_y_out_min, ERROR_ROUTER_Y_OUT_LESSTHAN_EXPECTED);

        // do actual swap
        TokenSwapRouter::swap_exact_token_for_token<X, R>(signer, amount_x_in, r_out);
        TokenSwapRouter::swap_exact_token_for_token<R, T>(signer, r_out, t_out);
        TokenSwapRouter::swap_exact_token_for_token<T, Y>(signer, t_out, amount_y_out_min);
    }

    public fun swap_token_for_exact_token<X: store, R: store, T: store, Y: store>(
        signer: &signer,
        amount_x_in_max: u128,
        amount_y_out: u128) {
        // calculate actual x in
        let (t_in, r_in, x_in) = get_amount_in<X, R, T, Y>(amount_y_out);
        assert(x_in <= amount_x_in_max, ERROR_ROUTER_X_IN_OVER_LIMIT_MAX);

        TokenSwapRouter::swap_token_for_exact_token<X, R>(signer, amount_x_in_max, r_in);
        TokenSwapRouter::swap_token_for_exact_token<R, T>(signer, r_in, t_in);
        TokenSwapRouter::swap_token_for_exact_token<T, Y>(signer, t_in, amount_y_out);
    }
}
}