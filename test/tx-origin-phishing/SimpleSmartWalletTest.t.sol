// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {SimpleSmartWallet} from "../../src/tx-origin-phishing/SimpleSmartWallet.sol";
import {Charity} from "../../src/tx-origin-phishing/Charity.sol";

contract SimpleSmartWalletTest is Test {

    SimpleSmartWallet simpleWallet;
    Charity charity;

    address manager = makeAddr("manager");
    address attacker = makeAddr("attacker");

    uint256 constant FUNDS = 2800 ether;
    uint256 constant ONE_ETH = 1 ether;

    function setUp() public {
        vm.deal(manager, FUNDS + ONE_ETH);
        vm.startPrank(manager);
        simpleWallet = new SimpleSmartWallet{value: FUNDS}();
        vm.stopPrank();

        vm.startPrank(attacker);
        charity = new Charity(address(simpleWallet));
        vm.stopPrank();
    }

    function testTxOriginAttack() public {
        assertEq(address(simpleWallet).balance, FUNDS);
        vm.startPrank(manager, manager);
        
        (bool successTransfer, ) = address(charity).call{value: 0.1 ether}("");
        assertEq(successTransfer, true);
        assertTrue(address(charity).balance > FUNDS);
        assertEq(address(simpleWallet).balance, 0);

        vm.stopPrank();
    }
}