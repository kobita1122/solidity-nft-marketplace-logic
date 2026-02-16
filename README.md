# Solidity NFT Marketplace Logic

This repository contains the essential smart contract logic for building a decentralized NFT marketplace. It focuses on security and gas efficiency, providing a robust backend for any NFT trading platform.

## Features
* **Listing Management:** Users can list their NFTs by specifying the contract address, Token ID, and price.
* **Escrow-less Trading:** Uses the `setApprovalForAll` pattern so NFTs stay in the user's wallet until the moment of sale.
* **Security Checks:** Includes `ReentrancyGuard` and ownership verification to prevent common exploits.
* **Event Logging:** Detailed events for every action (List, Buy, Cancel) to facilitate easy frontend indexing.

## How it Works
1. **Approve:** The NFT owner approves the marketplace contract.
2. **List:** The owner calls `listItem()` with a price in Wei.
3. **Buy:** A buyer calls `buyItem()` and sends the required ETH.
4. **Settlement:** The contract transfers ETH to the seller and the NFT to the buyer in a single atomic transaction.



## Tech Stack
* **Language:** Solidity 0.8.20
* **Library:** OpenZeppelin
