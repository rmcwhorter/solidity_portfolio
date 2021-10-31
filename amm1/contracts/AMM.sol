// SPDX-License-Identifier: MIT
pragma solidity ^0.8.3;

import "./IERC20.sol";

struct Order {
    address a_wallet;
    address b_wallet;
    uint256 source_quantity_to_sell;
    uint256 min_price_target_by_source;
    uint64 uuid; // maybe unnecessary?
}

contract AMM {
    // we want to make a market for two different ERC-20 tokens at specific addresses

    address asset_a_address;
    address asset_b_address;

    address escrow_a_address = address(this);
    address escrow_b_address = address(this);

    uint256 current_min_a_to_b_price;
    uint256 current_min_b_to_a_price;

    uint256 current_min_a_to_b_idx;
    uint256 current_min_b_to_a_idx;

    Order[] orders_a_to_b;
    Order[] orders_b_to_a;

    function request_order(
        address a_wallet,
        address b_wallet,
        bool is_a_to_b,
        uint256 source_quantity_to_sell,
        uint256 min_price_target_by_source
    ) external returns (bool) {
        // to validate this order, we have to check that the balance at the right ERC20 contract for the right ERC20 wallet is greater than the quantity
        bool out;

        if (is_a_to_b) {
            out =
                IERC20(asset_a_address).allowance(a_wallet, address(this)) >=
                source_quantity_to_sell;
        } else {
            out =
                IERC20(asset_b_address).allowance(b_wallet, address(this)) >=
                source_quantity_to_sell;
        }

        if (out) {
            // we create the order and append it to the right book
            if (is_a_to_b) {
                orders_a_to_b.push(
                    Order(
                        a_wallet,
                        b_wallet,
                        source_quantity_to_sell,
                        min_price_target_by_source,
                        1230
                    )
                );

                if (min_price_target_by_source < current_min_a_to_b_price) {
                    current_min_a_to_b_price = min_price_target_by_source;
                    current_min_a_to_b_idx = orders_a_to_b.length - 1;
                }
            } else {
                orders_b_to_a.push(
                    Order(
                        a_wallet,
                        b_wallet,
                        source_quantity_to_sell,
                        min_price_target_by_source,
                        1230
                    )
                );
                if (min_price_target_by_source < current_min_b_to_a_price) {
                    current_min_b_to_a_price = min_price_target_by_source;
                    current_min_b_to_a_idx = orders_b_to_a.length - 1;
                }
            }
        }

        return out;
    }

    // actually this probably isn't necessary, we can be incrementalists
    /*function check_set_mins() private {
        for (uint256 idx = 0; idx < orders_a_to_b.length; idx++) {
            if (orders_a_to_b[idx].min_price_target_by_source < current_min_a_to_b_price) {
                current_min_a_to_b_price = orders_a_to_b[idx].min_price_target_by_source;
                current_min_a_to_b_idx = idx;
            }
        }

        for (uint256 idx = 0; idx < orders_b_to_a.length; idx++) {
            if (orders_b_to_a[idx].min_price_target_by_source < current_min_b_to_a_price) {
                current_min_b_to_a_price = orders_b_to_a[idx].min_price_target_by_source;
                current_min_b_to_a_idx = idx;
            }
        }
    }*/

    function tick() private {
        uint256 current_max_a_to_b_price = 1 / current_min_b_to_a_price;

        // if this inequality holds, then there are two people who are willing to trade with each other.
        if (current_min_a_to_b_idx <= current_max_a_to_b_price) {
            // there exists a valid trade
            execute_extreme_trade();
            update_state();
            tick();
            // DANGER: Depending on how the order book evolves, it's plausible that you could wind up with more than the recusion limit worth of valid transactions
        } else {
            // pass
        }
    }

    function update_state() private {
        // we want to go and find the extreme trades
        for (uint256 idx = 0; idx < orders_a_to_b.length; idx++) {
            if (
                orders_a_to_b[idx].min_price_target_by_source <=
                current_min_a_to_b_idx
            ) {
                current_min_a_to_b_price = orders_a_to_b[idx]
                    .min_price_target_by_source;
                current_min_a_to_b_idx = idx;
            }
        }

        for (uint256 idx = 0; idx < orders_b_to_a.length; idx++) {
            if (
                orders_b_to_a[idx].min_price_target_by_source <=
                current_min_b_to_a_idx
            ) {
                current_min_b_to_a_price = orders_b_to_a[idx]
                    .min_price_target_by_source;
                current_min_b_to_a_idx = idx;
            }
        }
    }

    function execute_extreme_trade() private returns (bool) {
        // we go and find the lowest
        
        // how do we pick p, subject to current_min_a_to_b_idx <= p <= current_max_a_to_b_price;
        // let's just set it to the average
        uint256 current_max_a_to_b_price = 1 / current_min_b_to_a_price; 
        uint256 p = (current_min_a_to_b_idx + current_max_a_to_b_price) >> 1; // we just take the average
        // ok, so which trade is constraining us?
        uint256 a_source_quantity = orders_a_to_b[current_min_a_to_b_idx]
            .source_quantity_to_sell;
        uint256 b_source_quantity = orders_b_to_a[current_min_b_to_a_idx]
            .source_quantity_to_sell;

        bool rst;
        if (p * a_source_quantity <= b_source_quantity) {
            // Alice is the constraining factor

            // we send all of a_source to Bob in exchange for p*a_source worth of b_source

            rst = catch_execute_swap(
                a_source_quantity,
                a_source_quantity * p,
                orders_a_to_b[current_min_a_to_b_idx].a_wallet,
                orders_b_to_a[current_min_b_to_a_idx].a_wallet,
                orders_b_to_a[current_min_b_to_a_idx].b_wallet,
                orders_a_to_b[current_min_a_to_b_idx].b_wallet
            );

            if (rst) {
                // the trade succeeded
                // now we've got to go adjust the order book
                // we can just delete Alice's order straight up, because we filled it
                // for Bob, we have to alter his outstanding order

                orders_a_to_b[current_min_a_to_b_idx] = orders_a_to_b[
                    orders_a_to_b.length - 1
                ];
                orders_a_to_b.pop();
                // writes the last element to the old element, pops the last element

                orders_b_to_a[current_min_b_to_a_idx].source_quantity_to_sell =
                    orders_b_to_a[current_min_b_to_a_idx]
                        .source_quantity_to_sell -
                    (a_source_quantity * p);
            } else {
                // pass, we don't alter the order book because we didn't do anything.
                // [DANGER]: Because we aren't altering any state, we should just go execute the same stuff again because it looks as if this is still the best trade to make, even though it results in a failure during the swap.
            }
        } else {
            // Bob is the constraining factor
            // we send all of b_source to Alice from Bob in exchange for pinv*b_source worth of a_source from Alice to Bob.

            rst = catch_execute_swap(
                b_source_quantity / p,
                b_source_quantity,
                orders_a_to_b[current_min_a_to_b_idx].a_wallet,
                orders_b_to_a[current_min_b_to_a_idx].a_wallet,
                orders_b_to_a[current_min_b_to_a_idx].b_wallet,
                orders_a_to_b[current_min_a_to_b_idx].b_wallet
            );

            if (rst) {
                // the trade succeeded
                // now we've got to go adjust the order book
                // we can just delete Bob's order straight up, because we filled it
                // for Alice, we have to alter her outstanding order

                orders_b_to_a[current_min_b_to_a_idx] = orders_b_to_a[
                    orders_b_to_a.length - 1
                ];
                orders_b_to_a.pop();

                orders_a_to_b[current_min_a_to_b_idx].source_quantity_to_sell =
                    orders_a_to_b[current_min_a_to_b_idx]
                        .source_quantity_to_sell -
                    b_source_quantity /
                    p;
            } else {
                // pass, we don't alter the order book because we didn't do anything.
                // [DANGER]: Because we aren't altering any state, we should just go execute the same stuff again because it looks as if this is still the best trade to make, even though it results in a failure during the swap.
            }
        }

        return rst;
    }

    function catch_execute_swap(
        uint256 a_amount,
        uint256 b_amount,
        address a_source,
        address a_target,
        address b_source,
        address b_target
    ) private returns (bool) {
        IERC20 a_contract = IERC20(asset_a_address);
        IERC20 b_contract = IERC20(asset_b_address);

        // first, we have to check allowances for bpth TXs
        if (
            (a_contract.allowance(a_source, address(this)) >= a_amount) &&
            (b_contract.allowance(b_source, address(this)) >= b_amount)
        ) {
            // the allowances are correct.

            // we transfer each to an escrow account, before we go and transfer for real, just in case one TX fails after one succeeds.

            if (a_contract.transferFrom(a_source, escrow_a_address, a_amount)) {
                // the transfer succeeded
                // do the next escrow transfer
                if (
                    b_contract.transferFrom(
                        b_source,
                        escrow_b_address,
                        b_amount
                    )
                ) {
                    // the transfer succeeded
                    // we can go do the final transfers out of the escrow accounts into the target accounts.
                    // these should always succeed.
                    a_contract.transfer(a_target, a_amount);
                    b_contract.transfer(b_target, b_amount);
                    return true;
                } else {
                    // the transaction failed, we go roll back the older escrow transfer
                    a_contract.transfer(a_source, a_amount);
                    return false;
                }
            } else {
                // the transfer failed, exit false
                return false;
            }
        } else {
            // [ERROR]: we don't have the correct allowances, exit
            return false;
        }
    }
}
