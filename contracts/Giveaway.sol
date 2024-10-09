// SPDX-License-Identifier: MIT

/*

██████╗ ███████╗██╗███╗   ██╗███████╗██╗  ██╗    ██████╗ ██████╗  ██████╗ ████████╗ ██████╗  ██████╗ ██████╗ ██╗     
██╔══██╗██╔════╝██║████╗  ██║██╔════╝╚██╗██╔╝    ██╔══██╗██╔══██╗██╔═══██╗╚══██╔══╝██╔═══██╗██╔════╝██╔═══██╗██║     
██║  ██║█████╗  ██║██╔██╗ ██║█████╗   ╚███╔╝     ██████╔╝██████╔╝██║   ██║   ██║   ██║   ██║██║     ██║   ██║██║     
██║  ██║██╔══╝  ██║██║╚██╗██║██╔══╝   ██╔██╗     ██╔═══╝ ██╔══██╗██║   ██║   ██║   ██║   ██║██║     ██║   ██║██║     
██████╔╝██║     ██║██║ ╚████║███████╗██╔╝ ██╗    ██║     ██║  ██║╚██████╔╝   ██║   ╚██████╔╝╚██████╗╚██████╔╝███████╗
╚═════╝ ╚═╝     ╚═╝╚═╝  ╚═══╝╚══════╝╚═╝  ╚═╝    ╚═╝     ╚═╝  ╚═╝ ╚═════╝    ╚═╝    ╚═════╝  ╚═════╝ ╚═════╝ ╚══════╝
-------------------------------------------- dfinex.ai ------------------------------------------------------------

*/

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/utils/Pausable.sol";

// The main contract for the giveaway
contract DFinexGiveaway is Ownable, ReentrancyGuard, Pausable {
    // Use of SafeERC20 for the IERC20 interface for safe handling of ERC20 tokens.
    using SafeERC20 for IERC20;

    // Private field to store the address of the reward token contract.
    IERC20 private rewardToken;

    // Mapping to track the last claim time for each user
    mapping(address => uint256) private _lastClaimTime;

    // The interval after which users can claim again (24 hours)
    uint256 public constant CLAIM_INTERVAL = 24 hours;

    // The amount of tokens to be given in each claim (1 token with 18 decimal places)
    uint256 public constant TOKEN_AMOUNT = 1 * 10 ** 18;

    // Constructor to initialize the contract with the reward token address
    constructor(address tokenAddress) Ownable(msg.sender) {
        rewardToken = IERC20(tokenAddress);
    }

    // Function to allow users to claim their tokens
    function execute() external whenNotPaused nonReentrant {
        // Ensures that the user can only claim once every 24 hours
        require(block.timestamp >= _lastClaimTime[msg.sender] + CLAIM_INTERVAL, "Giveaway: You can only claim once every 24 hours");
        
        // Check that the contract has enough tokens to fulfill the claim
        require(rewardToken.balanceOf(address(this)) >= TOKEN_AMOUNT, "Giveaway: Insufficient tokens in contract");

        // Update the last claim time for the user
        _lastClaimTime[msg.sender] = block.timestamp;

        // Transfer the tokens to the user
        rewardToken.safeTransfer(msg.sender, TOKEN_AMOUNT);
    }

    // Function to check how much time is left until the next claim is possible
    function getTimeUntilNextClaim() external view returns (uint256) {
        // Calculate the time left until the next claim can be made
        if (_lastClaimTime[msg.sender] + CLAIM_INTERVAL > block.timestamp) {
            return (_lastClaimTime[msg.sender] + CLAIM_INTERVAL) - block.timestamp; // Return the remaining time
        } else {
            return 0; // If the claim is possible, return 0
        }
    }

    // Function to get the last claim time of the user
    function getLastClaimTime() external view returns (uint256) {
        return _lastClaimTime[msg.sender]; // Return the last claim time
    }

    // Function for the owner to deposit tokens into the contract
    function depositTokens(uint256 amount) external onlyOwner {
        // Transfer tokens from the owner's account to the contract's address
        require(rewardToken.transferFrom(msg.sender, address(this), amount), "Giveaway: Transfer failed");
    }

    // Functions for managing pause
    function pause() external onlyOwner {
        _pause();
    }

    function unpause() external onlyOwner {
        _unpause();
    }
}
