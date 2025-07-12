// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Test} from "forge-std/Test.sol";
import {MyNFT} from "../src/ERC721NFT.sol";
import {IERC2981} from "lib/openzeppelin-contracts/contracts/interfaces/IERC2981.sol";

contract NFTTest is Test {
    MyNFT public nft;

    address owner = address(1);
    address user = address(2);
    address attacker = address(3);

    function setUp() public {
        vm.prank(owner);
        nft = new MyNFT();
    }

    // Testing {mint} function

    function testMint() public {
        string memory uri = "ipfs//qm12345678";

        vm.prank(owner);
        nft.mint(owner, uri);
        assertEq(nft.totalSupply(), 1);

        vm.prank(attacker);
        vm.expectRevert();
        nft.mint(user, uri);
    }

    function testMintEvent() public {
        string memory uri = "ipfs/1";

        vm.prank(owner);
        vm.expectEmit(true, true, false, false);
        emit MyNFT.TokenMinted(user, 1);
        nft.mint(user, uri);
    }

    function testMintZeroAddr() public {
        string memory uri = "ipfs/qm1234566";

        vm.prank(owner);
        vm.expectRevert("Invalid address");
        nft.mint(address(0), uri);
    }

    // Testing {multipleMint} function

    function testBatchMint() public {
        uint256 arraySize = 19;
        string[] memory URIs = new string[](arraySize);

        for (uint256 i = 0; i < arraySize; i++) {
            URIs[i] = string(abi.encodePacked("ipfs/", vm.toString(i)));
        }
        vm.prank(owner);
        nft.multipleMint(user, URIs);
        assertEq(nft.totalSupply(), arraySize);
    }

    function testBatchMintEvent() public {
        uint256 arraySize = 19;
        string[] memory URIs = new string[](arraySize);

        for (uint256 i = 0; i < arraySize; i++) {
            URIs[i] = string(abi.encodePacked("ipfs/", vm.toString(i)));
        }

        uint256[] memory expectedTokenIds = new uint256[](arraySize);
        for (uint256 i = 0; i < arraySize; i++) {
            expectedTokenIds[i] = i;
        }

        vm.prank(owner);
        vm.expectEmit(true, true, false, false);
        emit MyNFT.MultipleTokensMinted(user, expectedTokenIds);
        nft.multipleMint(user, URIs);
    }

    function testBatchMintEmptyArray() public {
        string[] memory URIs = new string[](0);

        vm.prank(owner);
        vm.expectRevert("Empty URIs");
        nft.multipleMint(user, URIs);
    }

    function testBatchMintEmptyURIs() public {
        string[] memory URIs = new string[](3);
        URIs[0] = "ipfs/val";
        URIs[1] = "";
        URIs[2] = "ipfs/val";

        vm.prank(owner);
        vm.expectRevert("Empty URI");
        nft.multipleMint(user, URIs);
    }

    function testBatchMintZeroAddr() public {
        string[] memory URIs = new string[](3);
        URIs[0] = "1";
        URIs[1] = "2";
        URIs[2] = "3";

        vm.prank(owner);
        vm.expectRevert("Invalid Address");
        nft.multipleMint(address(0), URIs);
    }

    function testBatchMintNonOwner() public {
        uint256 arraySize = 19;
        string[] memory URIs = new string[](arraySize);

        for (uint256 i = 0; i < arraySize; i++) {
            URIs[i] = string(abi.encodePacked("ipfs/", vm.toString(i)));
        }
        vm.prank(attacker);
        vm.expectRevert();
        nft.multipleMint(attacker, URIs);
    }

    function testBatchMintMoreThanLimit() public {
        uint256 arraySize = 30;
        string[] memory URIs = new string[](arraySize);

        for (uint256 i = 0; i < arraySize; i++) {
            URIs[i] = string(abi.encodePacked("ipfs/", vm.toString(i)));
        }
        vm.prank(owner);
        vm.expectRevert("Too many tokens");
        nft.multipleMint(user, URIs);
    }

    function testBatchMintLimit() public {
        uint256 arraySize = 25;
        string[] memory URIs = new string[](arraySize);

        for (uint256 i = 0; i < arraySize; i++) {
            URIs[i] = string(abi.encodePacked("ipfs/", vm.toString(i)));
        }
        vm.prank(owner);
        nft.multipleMint(user, URIs);
        assertEq(nft.totalSupply(), arraySize);
    }

    function testBatchMintSingle() public {
        string[] memory URIs = new string[](1);
        URIs[0] = "ipfs/1";

        vm.prank(owner);
        nft.multipleMint(user, URIs);
        assertEq(nft.totalSupply(), 1);
    }

    function testBatchMintMoreThanLimitNonOwner() public {
        uint256 arraySize = 30;
        string[] memory URIs = new string[](arraySize);

        for (uint256 i = 0; i < arraySize; i++) {
            URIs[i] = string(abi.encodePacked("ipfs/", vm.toString(i)));
        }
        vm.prank(attacker);
        vm.expectRevert();
        nft.multipleMint(attacker, URIs);
    }

    // Testing functions when Paused

    function testMintWhilePaused() public {
        string memory uri = "ipfs/1";

        vm.prank(owner);
        nft.pause();
        vm.expectRevert();
        nft.mint(user, uri);
    }

    function testBatchMintWhilePaused() public {
        uint256 arraySize = 10;
        string[] memory URIs = new string[](arraySize);

        for (uint256 i = 0; i < arraySize; i++) {
            URIs[i] = string(abi.encodePacked("ipfs/", vm.toString(i)));
        }

        vm.prank(owner);
        nft.pause();
        vm.expectRevert();
        nft.multipleMint(user, URIs);
    }

    function testBurnWhilePaused() public {
        string memory uri = "ipfs/1";

        vm.startPrank(owner);
        nft.mint(user, uri);
        vm.stopPrank();

        vm.startPrank(owner);
        nft.pause();
        vm.stopPrank();

        vm.startPrank(user);
        vm.expectRevert();
        nft.burn(1);
        vm.stopPrank();
    }

    function testRoyaltyWhilePaused() public {
        vm.prank(owner);
        nft.pause();
        vm.expectRevert();
        nft.setDefaultRoyalty(user, 5000);
    }

    function testPauseNonOwner() public {
        vm.prank(user);
        vm.expectRevert();
        nft.pause();
    }

    function testUnpauseNonOwner() public {
        vm.prank(user);
        vm.expectRevert();
        nft.unpause();
    }

    function testUnpauseEnablesMint() public {
        string memory uri = "ipfs/1";
        vm.prank(owner);
        nft.pause();

        vm.prank(owner);
        nft.unpause();

        vm.prank(owner);
        nft.mint(user, uri);

        assertEq(nft.totalSupply(), 1);
    }

    // Testing {burn} function

    function testBurn() public {
        string memory uri = "ipfs/1";
        // Test burning by admin, user

        vm.prank(owner);
        nft.mint(user, uri);

        vm.startPrank(owner);
        vm.expectEmit(true, false, false, false);
        emit MyNFT.TokenBurnt(1);
        nft.burn(1);
        vm.stopPrank();
    }

    function testBurnByNonOwner() public {
        string memory uri = "ipfs/1";

        vm.prank(owner);
        nft.mint(user, uri);

        // Test burning by an attacker

        vm.prank(attacker);
        vm.expectRevert();
        nft.burn(1);
    }

    function testBurnNonExist() public {
        vm.prank(owner);
        vm.expectRevert();
        nft.burn(999);
    }

    // Testing {Royalty} functionality

    function testRoyalty() public {
        vm.prank(owner);
        vm.expectRevert();
        nft.setDefaultRoyalty(address(0), 5000);
    }

    function testRoyaltyNonOwner() public {
        vm.startPrank(attacker);
        vm.expectRevert();
        nft.setDefaultRoyalty(user, 0);
        vm.stopPrank();
    }

    function testRoyaltySuccess() public {
        vm.prank(owner);
        nft.setDefaultRoyalty(user, 5000);
    }

    function testRoyaltyInfo() public {
        vm.prank(owner);
        nft.setDefaultRoyalty(user, 500);
        (address receiver, uint256 royaltyAmount) = nft.royaltyInfo(1, 10_000);
        assertEq(receiver, user);
        assertEq(royaltyAmount, 500);
    }

    function testSupportedInterface() public view {
        bool supported = nft.supportsInterface(type(IERC2981).interfaceId);
        assertTrue(supported);
    }
}
