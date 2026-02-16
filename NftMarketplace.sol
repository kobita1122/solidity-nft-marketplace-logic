// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

contract NftMarketplace is ReentrancyGuard {
    struct Listing {
        address seller;
        uint256 price;
    }

    // Mapping from NFT Contract -> Token ID -> Listing Data
    mapping(address => mapping(uint256 => Listing)) private s_listings;

    event ItemListed(address indexed seller, address indexed nftAddress, uint256 indexed tokenId, uint256 price);
    event ItemCanceled(address indexed seller, address indexed nftAddress, uint256 indexed tokenId);
    event ItemBought(address indexed buyer, address indexed nftAddress, uint256 indexed tokenId, uint256 price);

    error NotOwner();
    error AlreadyListed(address nftAddress, uint256 tokenId);
    error NotListed(address nftAddress, uint256 tokenId);
    error PriceMustBeAboveZero();
    error NotApprovedForMarketplace();
    error PriceNotMet(address nftAddress, uint256 tokenId, uint256 price);

    function listItem(address nftAddress, uint256 tokenId, uint256 price) external {
        if (price <= 0) revert PriceMustBeAboveZero();
        IERC721 nft = IERC721(nftAddress);
        if (nft.ownerOf(tokenId) != msg.sender) revert NotOwner();
        if (s_listings[nftAddress][tokenId].price > 0) revert AlreadyListed(nftAddress, tokenId);
        if (nft.getApproved(tokenId) != address(this) && !nft.isApprovedForAll(msg.sender, address(this))) {
            revert NotApprovedForMarketplace();
        }

        s_listings[nftAddress][tokenId] = Listing(msg.sender, price);
        emit ItemListed(msg.sender, nftAddress, tokenId, price);
    }

    function cancelListing(address nftAddress, uint256 tokenId) external nonReentrant {
        if (s_listings[nftAddress][tokenId].seller != msg.sender) revert NotOwner();
        delete s_listings[nftAddress][tokenId];
        emit ItemCanceled(msg.sender, nftAddress, tokenId);
    }

    function buyItem(address nftAddress, uint256 tokenId) external payable nonReentrant {
        Listing memory listedItem = s_listings[nftAddress][tokenId];
        if (listedItem.price <= 0) revert NotListed(nftAddress, tokenId);
        if (msg.value < listedItem.price) revert PriceNotMet(nftAddress, tokenId, listedItem.price);

        delete s_listings[nftAddress][tokenId];
        IERC721(nftAddress).safeTransferFrom(listedItem.seller, msg.sender, tokenId);
        
        (bool success, ) = payable(listedItem.seller).call{value: msg.value}("");
        require(success, "Transfer failed");

        emit ItemBought(msg.sender, nftAddress, tokenId, listedItem.price);
    }

    function getListing(address nftAddress, uint256 tokenId) external view returns (Listing memory) {
        return s_listings[nftAddress][tokenId];
    }
}
