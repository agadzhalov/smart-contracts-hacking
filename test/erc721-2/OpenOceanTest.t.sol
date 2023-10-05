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

        // 4.3 Try to purchase item number 3 with the correct amount of ETH, and make sure the transaction goes through
        vm.startPrank(userTwo);
        oc.purchase{value: 5 ether}(3);
        assertEq(oc.getItemById(3).isSold, true);

        // 4.4 Try to purchase item number 3 again, and make sure the transaction is reverted with the relevant error message
        vm.expectRevert(bytes("item is sold"));
        oc.purchase{value: 5 ether}(3);

        // 4.5 Make sure that User2 owns item number 3
        assertEq(cutiesNft.ownerOf(oc.getItemById(3).tokenId), userTwo);

        // 4.6 Make sure that the User1 got the right amount of ETH for the sale
        assertEq(userOne.balance, 15 ether);

        // 4.7 Try to purchase item number 11 with the correct amount of ETH, make sure the transaction goes through
        oc.purchase{value: 7 ether}(11);
        assertEq(oc.getItemById(11).isSold, true);
        vm.stopPrank();

        // 4.8 Make sure that User2 owns item number 11
        assertEq(rareNft.ownerOf(oc.getItemById(11).tokenId), userTwo);

        // 4.9 Make sure that User3 got the right amount of ETH for the sale
        assertEq(userThree.balance, 17 ether);
    }

    // 4.1 Try to purchase itemId 100 (doesn't exist), and make sure the transaction is reverted
    function testNonExistingIdPurchaseShouldRevert() public {
        vm.expectRevert();
        vm.startPrank(userTwo);
        oc.purchase(101);
        vm.stopPrank();
    }  

    // 4.2 Try to purchase item number 3, without providing any ETH, and make sure the transaction is reverted
    function testPurchasheWithoutEthShouldRevert() public {
        vm.expectRevert();
        oc.purchase(3);
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
        vm.deal(userTwo, 30 ether);
        vm.deal(userThree, 10 ether);
    }

}