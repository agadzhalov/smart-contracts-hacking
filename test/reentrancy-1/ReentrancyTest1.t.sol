// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {EtherBank} from "../../src/Reentrancy-1/EtherBank.sol";
import {Attack} from "../../src/Reentrancy-1/Attack.sol";

contract ReentrancyTest1 is Test {

    EtherBank bank;
    Attack attack;

    address deployer = makeAddr("deployer");
    address userOne = makeAddr("userOne");
    address userTwo = makeAddr("userTwo");
    address userThree = makeAddr("userThree");
    address userFour = makeAddr("userFour");
    address attacker = makeAddr("attacker");

    uint256 private constant INIT_BALANCE = 10 ether;

    function setUp() public {
        vm.deal(userOne, INIT_BALANCE);
        vm.deal(userTwo, INIT_BALANCE);
        vm.deal(userThree, INIT_BALANCE);
        vm.deal(userFour, INIT_BALANCE);
        vm.deal(attacker, INIT_BALANCE);

        vm.startPrank(deployer);
        bank = new EtherBank();
        vm.stopPrank();

        vm.startPrank(attacker);
        attack = new Attack(address(bank));
        vm.stopPrank();

        _depositEth();
    }

    function testReentrancyOne() public {
        address attackAddress = address(attack);
        vm.startPrank(attackAddress);
        vm.deal(attackAddress, INIT_BALANCE);

        bank.depositETH{value: 0.1 ether}();
        bank.withdrawETH();
        vm.stopPrank();
        assertEq(address(bank).balance, 0 ether);
        assertEq(attackAddress.balance, INIT_BALANCE + 40 ether);
    }

    function _depositEth() private {
        vm.startPrank(userOne);
        bank.depositETH{value: INIT_BALANCE}();
        vm.stopPrank();

        vm.startPrank(userTwo);
        bank.depositETH{value: INIT_BALANCE}();
        vm.stopPrank();

        vm.startPrank(userThree);
        bank.depositETH{value: INIT_BALANCE}();
        vm.stopPrank();

        vm.startPrank(userFour);
        bank.depositETH{value: INIT_BALANCE}();
        vm.stopPrank();
        
    }



}