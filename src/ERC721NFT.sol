// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "lib/openzeppelin-contracts/contracts/access/Ownable.sol";
import "lib/openzeppelin-contracts/contracts/utils/ReentrancyGuard.sol";
import "lib/openzeppelin-contracts/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "lib/openzeppelin-contracts/contracts/token/common/ERC2981.sol";
import "lib/openzeppelin-contracts/contracts/utils/Pausable.sol";

contract MyNFT is ERC721URIStorage, Ownable, ReentrancyGuard, ERC2981, Pausable {
    uint256 private tokenCounterID;

    event TokenMinted(address indexed to, uint256 tokenId);
    event TokenBurnt(uint256 tokenId);
    event MultipleTokensMinted(address to, uint256[] tokenIds);

    constructor() ERC721("MyNFT", "MFT") Ownable(msg.sender) ReentrancyGuard() {}

    function supportsInterface(bytes4 interfaceId) public view override(ERC721URIStorage, ERC2981) returns (bool) {
        return super.supportsInterface(interfaceId);
    }

    function mint(address to, string memory tokenURI) external onlyOwner whenNotPaused {
        require(to != address(0), "Invalid address");
        require(bytes(tokenURI).length > 0, "Empty URI");
        tokenCounterID++;
        _safeMint(to, tokenCounterID);
        _setTokenURI(tokenCounterID, tokenURI);

        emit TokenMinted(to, tokenCounterID);
    }

    function multipleMint(address to, string[] memory tokenURIs) external onlyOwner whenNotPaused {
        require(to != address(0), "Invalid Address");
        require(tokenURIs.length <= 25, "Too many tokens"); // set the limit of minting multiple NFTs
        require(tokenURIs.length > 0, "Empty URIs");

        uint256[] memory tokenIds = new uint256[](tokenURIs.length);

        for (uint256 i = 0; i < tokenURIs.length; i++) {
            require(bytes(tokenURIs[i]).length > 0, "Empty URI");
            tokenCounterID++;
            _safeMint(to, tokenCounterID);
            _setTokenURI(tokenCounterID, tokenURIs[i]);
            tokenIds[i] = tokenCounterID;
        }

        emit MultipleTokensMinted(to, tokenIds);
    }

    function burn(uint256 tokenID) external onlyOwner nonReentrant whenNotPaused {
        ownerOf(tokenID);
        _burn(tokenID);

        emit TokenBurnt(tokenID);
    }

    function setDefaultRoyalty(address receiver, uint96 feeNumerator) external onlyOwner whenNotPaused {
        require(receiver != address(0));
        _setDefaultRoyalty(receiver, feeNumerator);
    }

    function pause() external onlyOwner {
        _pause();
    }

    function unpause() external onlyOwner {
        _unpause();
    }

    function totalSupply() public view returns (uint256) {
        return tokenCounterID;
    }
}
