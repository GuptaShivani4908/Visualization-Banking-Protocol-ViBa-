// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

/**
 * @title Visualization Banking Protocol (ViBa)
 * @dev Self-sovereign identity solution for Core Chain users
 */
contract VisualizationBankingProtocol {
    // State variables
    address public owner;
    
    // Struct to represent user identity data
    struct Identity {
        bytes32 dataHash;        // Hash of user's identity data (stored off-chain)
        uint256 creationTime;    // Timestamp when the identity was created
        bool isActive;           // Status of the identity
    }
    
    // Mapping from user address to their identity
    mapping(address => Identity) public identities;
    
    // Events
    event IdentityCreated(address indexed user, bytes32 dataHash, uint256 timestamp);
    event IdentityUpdated(address indexed user, bytes32 newDataHash, uint256 timestamp);
    event IdentityStatusChanged(address indexed user, bool isActive, uint256 timestamp);
    
    // Constructor
    constructor() {
        owner = msg.sender;
    }
    
    /**
     * @dev Create or update a user's self-sovereign identity
     * @param dataHash Hash of the user's identity data stored off-chain
     * @notice This function allows users to register or update their identity
     */
    function registerIdentity(bytes32 dataHash) external {
        require(dataHash != bytes32(0), "Invalid data hash");
        
        if (identities[msg.sender].creationTime == 0) {
            // Create new identity
            identities[msg.sender] = Identity({
                dataHash: dataHash,
                creationTime: block.timestamp,
                isActive: true
            });
            
            emit IdentityCreated(msg.sender, dataHash, block.timestamp);
        } else {
            // Update existing identity
            identities[msg.sender].dataHash = dataHash;
            
            emit IdentityUpdated(msg.sender, dataHash, block.timestamp);
        }
    }
    
    /**
     * @dev Toggle active status of user's identity
     * @notice This function allows users to activate or deactivate their identity
     */
    function toggleIdentityStatus() external {
        require(identities[msg.sender].creationTime > 0, "Identity does not exist");
        
        identities[msg.sender].isActive = !identities[msg.sender].isActive;
        
        emit IdentityStatusChanged(
            msg.sender, 
            identities[msg.sender].isActive, 
            block.timestamp
        );
    }
    
    /**
     * @dev Verify if a user has an active identity with the given data hash
     * @param user Address of the user to verify
     * @param expectedDataHash The expected hash of the user's identity data
     * @return bool True if the user has an active identity with the expected hash
     */
    function verifyIdentity(address user, bytes32 expectedDataHash) external view returns (bool) {
        Identity memory identity = identities[user];
        return (
            identity.isActive && 
            identity.creationTime > 0 && 
            identity.dataHash == expectedDataHash
        );
    }
}
