// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "forge-std/console.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import {Pool} from "src/flash-loan-1/Pool.sol";

/**
@dev run "forge test --match-contract RA2 -vvvvv" 
*/
contract FLTest is Test {

    address deployer = makeAddr("deployer");
    address user = makeAddr("user");

    uint256 private constant INIT_ETHER = 1000 ether;
    bytes32 private constant _TYPE_HASH = keccak256('EIP712Domain(uint256 chainId,address verifyingContract)');

    Pool pool;

    function setUp() public {
        vm.prank(deployer);
        pool = new Pool();
        
    }

    function testExploit() public {
    }

}