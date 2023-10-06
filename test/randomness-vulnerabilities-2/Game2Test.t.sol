// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Test, console} from "forge-std/Test.sol";
import {Game2} from "../../src/randomness-vulnerabilities-2/Game2.sol";
import {Attack} from "../../src/randomness-vulnerabilities-2/AttackGame2.sol";

contract TestRV2 is Test {
    uint128 public constant GAME_POT = 20 ether;
    uint128 public constant GAME_FEE = 1 ether;
    uint256 init_attacker_bal;

    Game2 game;
    Attack attack;

    address deployer;
    address attacker;

    function setUp() public {
        deployer = address(1);
        attacker = address(2);
        vm.deal(attacker, 10 ether);

        vm.prank(deployer);
        game = new Game2();
        vm.deal(address(game), GAME_POT);

        vm.prank(attacker);
        attack = new Attack(address(game));

        uint256 inGame = address(game).balance;
        assertEq(inGame, GAME_POT);

        init_attacker_bal = address(attacker).balance;
    }

    function test_Attack() public {
        for (uint i = 0; i < 5; i++) {
            attack.attack{value: 1 ether}();
            vm.roll(block.number + 1);
        }

        assertEq(address(game).balance, 0);
        assertEq(address(attacker).balance >= init_attacker_bal + GAME_POT, true);
    }
}