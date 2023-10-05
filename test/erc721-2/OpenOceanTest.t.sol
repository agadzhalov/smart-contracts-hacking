// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Test, console} from "forge-std/Test.sol";
import {IERC721} from "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import {OpenOcean} from "../../src/erc721-2/OpenOcean.sol";
import {DummyERC721} from "../../src/utils/DummyERC721.sol";

contract OpenOceanTest is Test {
    
    OpenOcean public oc;
    DummyERC721 public cutiesNft;

    address private deployer = makeAddr("deployer");
    address private userOne = makeAddr("userOne");
    address private userTwo = makeAddr("userTwo");
    address private userThree = makeAddr("userThree");

    uint256 public constant MAX_SUPPLY = 10000;

    function setUp() public {
        _setInitialAccountBalances();

        vm.startPrank(deployer);
        //1. Deploy the marketplace contract from the deployer account
        oc = new OpenOcean();
        vm.stopPrank();

        // initial mint of Crypto Cuties
        _mintCutiesNfts();
    }

    function testCutiesNftMinted() public {
        assertEq(cutiesNft.balanceOf(userOne), 100);
    }

    function testMarketplace() public {
        // 2. From user1: List Crypto Cuties token IDs 1 - 10, for 5 ETH each
        _listCryptoCuties();
        // 2.1  Test that the itemsCounter is 10
        assertEq(oc.itemsCounter(), 10);
    }

    function _listCryptoCuties() private {
        vm.startPrank(userOne);
        for (uint i=1; i<=10; i++) {
            cutiesNft.approve(address(oc), i);
            oc.listItem(address(cutiesNft), i, 5 ether);
        }
        vm.stopPrank();
    }

    function _mintCutiesNfts() private {
        vm.startPrank(userOne);
        cutiesNft = new DummyERC721("Crypto Cuties", "CC", MAX_SUPPLY);
        cutiesNft.mintBulk(100);
        vm.stopPrank();
    }

    function _setInitialAccountBalances() private {
        vm.deal(deployer, 10 ether);
        vm.deal(userOne, 10 ether);
        vm.deal(userTwo, 10 ether);
        vm.deal(userThree, 10 ether);
    }

}