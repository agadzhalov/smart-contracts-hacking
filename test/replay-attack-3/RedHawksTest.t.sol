// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "forge-std/console.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import {RedHawksVIP} from "src/replay-attack-3/RedHawksVIP.sol";
import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";

/**
@dev run "forge test --match-contract RA2 -vvvvv" 
*/
contract RedHawksTest is Test {

    using ECDSA for bytes32;

    address deployer = makeAddr("deployer");
    address voucherSigner;
    uint256 signerKey;
    address user1 = makeAddr("user1");
    address attacker = makeAddr("attacker");

    uint256 private constant INIT_ETHER = 1000 ether;
    bytes32 private constant _TYPE_HASH = keccak256('EIP712Domain(uint256 chainId,address verifyingContract)');

    RedHawksVIP redhaw;

    function setUp() public {
        (voucherSigner, signerKey) = makeAddrAndKey("vaucher");
        vm.deal(deployer, INIT_ETHER);
        vm.deal(voucherSigner, INIT_ETHER);

        vm.prank(deployer);
        
        redhaw = new RedHawksVIP(voucherSigner);
        
        // Sign message
        uint8 v;
        bytes32 r;
        bytes32 s;
        bytes32 dataHash =_hashTypedDataV4(
        keccak256(
                abi.encode(
                    keccak256(
                        'VoucherData(uint256 amountOfTickets,string password)' 
                    ),
                    2,
                    keccak256(bytes("1245")) // Only hash string
                )
            )
        );
         

        (v, r, s) = vm.sign(signerKey, dataHash);
        bytes memory signature = abi.encodePacked(r, s, v);
        address signer = dataHash.recover(signature);
        console.log(signer, voucherSigner);
        redhaw.mint(2, "1245", signature);
        assertEq(redhaw.balanceOf(address(this)), 2);
    }

    function testExploit() public {
        
    }

    function _domainSeparatorV4() internal view returns (bytes32) {
        return keccak256(abi.encode(_TYPE_HASH, block.chainid, address(redhaw)));
    }


    function _hashTypedDataV4(bytes32 structHash)
        internal
        view
        virtual
        returns (bytes32)
    {
        return
            ECDSA.toTypedDataHash(_domainSeparatorV4(), structHash);
    }
}