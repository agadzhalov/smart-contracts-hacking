// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Test, console} from "forge-std/Test.sol";
import {Game} from "../../src/randomness-vulnerabilities-1/Game.sol";
import {AttackGame} from "../../src/randomness-vulnerabilities-1/AttackGame.sol";

contract GameTest is Test {

    Game game;
    AttackGame attacker;

    address userOne = makeAddr("userOne");

    function setUp() public {
        game = new Game();
        attacker = new AttackGame(address(game));
        vm.deal(address(game), 10 ether);
    }

    function testAttackGame() public {
        vm.startPrank(userOne);
        attacker.attack();
        vm.stopPrank();

        // checks all of the funds from contract were stolen
        assertEq(address(game).balance, 0 ether);
        // checks the attack got all the funds
        assertEq(address(attacker).balance, 10 ether);
    }

}