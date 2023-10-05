// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Test, console} from "forge-std/Test.sol";
import {IERC721} from "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import {OpenOcean} from "../../src/erc721-2/OpenOcean.sol";
import {DummyERC721} from "../../src/utils/DummyERC721.sol";

contract OpenOceanTest is Test {
    
    OpenOcean public oc;
    DummyERC721 public cutiesNft;
    DummyERC721 public rareNft;

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
        _mintRareBooblesNfts();
    }

    function testCutiesNftMinted() public {
        assertEq(cutiesNft.balanceOf(userOne), 100);
    }

    function testMarketplace() public {
        // 2. From user1: List Crypto Cuties token IDs 1 - 10, for 5 ETH each
        _listCryptoCuties();
        // 2.1  Test that the itemsCounter is 10
        assertEq(oc.itemsCounter(), 10);
        // 2.2 Test that the marketplace contract owns 10 Crypto Cuties NFTs
        assertEq(cutiesNft.balanceOf(address(oc)), 10);

        // 2.3 Check that all the parameters of the last item that was listed are correct
        uint256 _lastItemId = oc.itemsCounter();
        assertEq(oc.getItemById(_lastItemId).itemId, _lastItemId);
        assertEq(oc.getItemById(_lastItemId).collectionContract, address(cutiesNft));
        assertEq(oc.getItemById(_lastItemId).tokenId, 10);
        assertEq(oc.getItemById(_lastItemId).price, 5 ether);
        assertEq(oc.getItemById(_lastItemId).seller, userOne);
        assertEq(oc.getItemById(_lastItemId).isSold, false);

        // 3. From user3: List Rare Boobles token IDs 1 - 5, for 7 ETH each
        _listRareBoobles();
        // 3.1 Test that the itemsCounter is 15
        assertEq(oc.itemsCounter(), 15);

        // 3.2 Test that the marketplace contract owns 5 Rare Boobles NFTs
        assertEq(rareNft.balanceOf(address(oc)), 5);

        // 3.3 Check that all the parameters of the last item that was listed are correct
        uint256 _latestLastItem = oc.itemsCounter();
        assertEq(oc.getItemById(_latestLastItem).itemId, _latestLastItem);
        assertEq(oc.getItemById(_latestLastItem).collectionContract, address(rareNft));
        assertEq(oc.getItemById(_latestLastItem).tokenId, 5);
        assertEq(oc.getItemById(_latestLastItem).price, 7 ether);
        assertEq(oc.getItemById(_latestLastItem).seller, userThree);
        assertEq(oc.getItemById(_latestLastItem).isSold, false);
    }

    function _listCryptoCuties() private {
        vm.startPrank(userOne);
        for (uint i = 1; i <= 10; i++) {
            cutiesNft.approve(address(oc), i);
            oc.listItem(address(cutiesNft), i, 5 ether);
        }
        vm.stopPrank();
    }

    function _listRareBoobles() private {
        vm.startPrank(userThree);
        for (uint i = 1; i <= 5; i++) {
            rareNft.approve(address(oc), i);
            oc.listItem(address(rareNft), i, 7 ether);
        }
        vm.stopPrank();
    }

    function _mintCutiesNfts() private {
        vm.startPrank(userOne);
        cutiesNft = new DummyERC721("Crypto Cuties", "CC", MAX_SUPPLY);
        cutiesNft.mintBulk(100);
        vm.stopPrank();
    }

    function _mintRareBooblesNfts() private {
        vm.startPrank(userThree);
        rareNft = new DummyERC721("RareBoobles", "RB", MAX_SUPPLY);
        rareNft.mintBulk(100);
        vm.stopPrank();
    }

    function _setInitialAccountBalances() private {
        vm.deal(deployer, 10 ether);
        vm.deal(userOne, 10 ether);
        vm.deal(userTwo, 10 ether);
        vm.deal(userThree, 10 ether);
    }

}