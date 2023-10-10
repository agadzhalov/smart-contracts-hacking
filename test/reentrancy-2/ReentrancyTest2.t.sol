// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {ApesAirdrop} from "../../src/Reentrancy-2/ApesAirdrop.sol";
//import {Attack} from "../../src/Reentrancy-1/Attack.sol";

contract ReentrancyTest1 is Test {

    ApesAirdrop apes;

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
        apes = new ApesAirdrop();
        vm.stopPrank();

        vm.startPrank(attacker);
        //attack = new Attack(address(bank));
        vm.stopPrank();

    }

    function testReentrancyTwo() public {

    }

}