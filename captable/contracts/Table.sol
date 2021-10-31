// SPDX-License-Identifier: MIT
pragma solidity ^0.8.3;

// external imports
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "hardhat/console.sol"; // console.log();

// internal imports
import "./util.sol";
import "./Shares.sol";

/*
* What do we have?
* We're trying to emulate the captable of a company.
* A company has a bunch of different kinds of stock.
* A company can also issue new stock.
* What is stock?
* Stock is either voting or non-voting.
*/

/*
* Here's the overarching philosophy:
* We've got a general company smart contract
* The actual solidity doesn't do a whole lot
* Most of what should happen happens via typescript interfaces
*/

struct MeasurableERC20 {
    uint value;
    address addr;
}

struct Proposal {
    string description;
}

contract Company {
    /*
    * Variables
    */

    string name;
    string ticker;
    address[] administrators;
    MeasurableERC20[] shares;
    Proposal[] proposals;

    /*
    * Constructor
    */

    constructor(string memory _name, string memory _ticker) {
        administrators.push(msg.sender);
        name = _name;
        ticker = _ticker;
    }

    /*
    * Modifiers
    */

    modifier administrators_only() {
        bool flag = false;

        for (uint i = 0; i < administrators.length; i++) {
            flag = flag || (msg.sender == administrators[i]);
        }

        require(flag, "This function is accessible to administrators only!");
        _;
    }

    modifier shareholders_only() {
        bool flag = false;

        for (uint idx = 0; idx < shares.length; idx++) {
            flag = flag || (ERC20(shares[idx].addr).balanceOf(msg.sender) > 0);
        }

        require(flag, "This function is accessible to shareholders only!");
        _;
    }

    /*
    * External Functions
    */

    function add_administrator(address target) external administrators_only returns (bool) {
        return gated_append(target, administrators);
    }

    function add_proposal(Proposal memory new_proposal) external shareholders_only {
        proposals.push(new_proposal);
    }

    /*
    * Getters
    */

    function get_num_stocks() external view returns(uint) {
        return shares.length;
    }
}