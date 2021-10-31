// SPDX-License-Identifier: MIT
pragma solidity ^0.8.3;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "hardhat/console.sol"; // console.log();

/*
* What do we have?
* We're trying to emulate the captable of a company.
* A company has a bunch of different kinds of stock.
* A company can also issue new stock.
* What is stock?
* Stock is either voting or non-voting.
*/

struct MeasurableERC20 {
    uint value;
    address addr;
}

contract Proposal {
    address[] administrators;
    uint num_voted;
    uint yea;
    uint nay;
    MeasurableERC20[] MEASURE;
    string discription;

    /*
    * Anyone can vote, they vote using their balance in the ERC20_SHARES
    */

    //! length of ERC20_SHARES and MEASURE must be equal!

    modifier administrators_only() {
        bool flag = false;

        for (uint i = 0; i < administrators.length; i++) {
            flag = flag || (msg.sender == administrators[i]);
        }

        require(flag, "This function is accessible to administrators only!");
        _;
    }

    constructor() {
        administrators.push(msg.sender);



    }

    // this returns the amount of votes you applied to yea or nay
    function vote(bool for_or_against) external returns (uint) {
        uint out = 0;

        for (uint idx = 0; idx < MEASURE.length; idx++) {
            out += MEASURE[idx].value * ERC20(MEASURE[idx].ctr).balanceOf(msg.sender);
        }

        if (for_or_against) {
            yea += out;
        } else {
            nay += out;
        }

        if (out > 0) {
            num_voted += 1;
        } // else pass

        return out;
    }

    function state() external returns (uint,uint,uint) {
        // returns the number of yeas, the number of nays, and the number of nonzero voters who voted
        return (yea,nay,num_voted);
    }

}

contract Company {
    string name;
    string ticker;
    address[] administrators;
    MeasurableERC20[] shares;

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

    constructor(string memory _name, string memory _ticker) {
        administrators.push(msg.sender);
        name = _name;
        ticker = _ticker;

        /*
        * What do we do?
        * Firstly, we've got to issue shares according to some scheme.
        * Let's say we know before hand that we're issueing FounderShares, EmployeeShares, and GeneralShares in the order {500, 150, 1000}.
        * Let's allocate all of them to the Company contract first, and transfer them around later
        */

        // rather than minting to *this* contract, we mint to msg.sender since afaik he's the controller of everything that's going on right here.
        address mint_addr = address(this); // using msg.sender didn't change anything
        fs = new FounderShares("CompanyFounderShares", "CGS", 500, mint_addr);
        es = new EmployeeShares("CompanyEmployeeShares", "CES", 150, mint_addr);
        gs = new GeneralShares("CompanyGeneralShares", "CFS", 1000, mint_addr);

        /*
        * We've got to send shares to the founders.
        * 250 to Ryan
        * 250 to Tim
        */

        address Ryan = 0x70997970C51812dc3A010C7d01b50e0d17dc79C8;
        address Tim = 0x3C44CdDdB6a900fa2b585dd299e03d12FA4293BC;

        fs.approve(address(this), 500);
        fs.transferFrom(mint_addr, Ryan, 250);
        fs.transferFrom(mint_addr, Tim, 250);

        /*
        * We've got to send shares to employees.
        */

        address Employee1 = 0x3C44CdDdB6a900fa2b585dd299e03d12FA4293BC; // all get 50 shares
        address Employee2 = 0x15d34AAf54267DB7D7c367839AAf71A00a2C6A65;
        address Employee3 = 0x9965507D1a55bcC2695C58ba16FB37d819B0A4dc;

        es.approve(address(this), 150);
        es.transferFrom(mint_addr, Employee1, 50);
        es.transferFrom(mint_addr, Employee2, 50);
        es.transferFrom(mint_addr, Employee3, 50);

        /*
        * Now the general shares, that go to investors.
        */

        address Geoff = 0x976EA74026E726554dB657fA54763abd0C3a0aa9;
        address Peter = 0x14dC79964da2C08b23698B3D3cc7Ca32193d9955;
        address a16z = 0x23618e81E3f5cdF7f54C3d65f7FBc0aBf5B21E8f;

        gs.approve(address(this), 1000);
        gs.transferFrom(mint_addr, Geoff, 500);
        gs.transferFrom(mint_addr, Peter, 250);
        gs.transferFrom(mint_addr, a16z, 250);

        /*
        * How would we issue a new funding round?
        */
    }



}