# ERC721 NFT Smart Contract

A comprehensive ERC721 NFT smart contract built with Solidity and OpenZeppelin, featuring advanced functionality including royalty support, pausability, and batch minting.

## Features

- **ERC721 Standard**: Full compliance with the ERC721 standard
- **URI Storage**: Support for token metadata URIs
- **Royalty Support**: ERC2981 royalty standard implementation
- **Access Control**: Ownable pattern for administrative functions
- **Pausability**: Emergency pause/unpause functionality
- **Reentrancy Protection**: Secure against reentrancy attacks
- **Batch Minting**: Efficient multiple token minting (max 25 tokens)
- **Token Burning**: Controlled token destruction

## Contract Functions

### Core Functions
- `mint(address to, string memory tokenURI)` - Mint a single NFT
- `multipleMint(address to, string[] memory tokenURIs)` - Mint multiple NFTs (max 25)
- `burn(uint256 tokenID)` - Burn a specific token
- `totalSupply()` - Get total number of tokens minted

### Administrative Functions
- `setDefaultRoyalty(address receiver, uint96 feeNumerator)` - Set royalty configuration
- `pause()` - Pause all contract operations
- `unpause()` - Resume contract operations

## Events

- `TokenMinted(address indexed to, uint256 tokenId)` - Emitted when a token is minted
- `TokenBurnt(uint256 tokenId)` - Emitted when a token is burned
- `MultipleTokensMinted(address to, uint256[] tokenIds)` - Emitted when multiple tokens are minted

## Development

### Prerequisites
- [Foundry](https://getfoundry.sh/)
- Solidity ^0.8.28

### Installation
```bash
# Clone the repository
git clone <your-repo-url>
cd ERC721

# Install dependencies
forge install
```

### Compilation
```bash
forge build
```

### Testing
```bash
forge test
```

The test suite includes 28 comprehensive tests covering:
- Single and batch minting
- Token burning
- Pause/unpause functionality
- Royalty management
- Access control
- Edge cases and error conditions

### Gas Optimization
The contract is optimized for gas efficiency with:
- Optimizer enabled (200 runs)
- Efficient storage patterns
- Minimal external calls

## Contract Details

- **Name**: MyNFT
- **Symbol**: MFT
- **Standard**: ERC721 with URI Storage
- **Royalty**: ERC2981 compliant
- **Access**: Ownable pattern
- **Security**: ReentrancyGuard and Pausable

## License

MIT License - see LICENSE file for details 