// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.19;

import "./IZKVerifier.sol";

/// @title ZK one-time airdrop claim
/// @notice Public signals: [root, distributionId, nullifier, amount].
///         Leaf binds `amount`; nullifier blocks replay per distribution.
contract ZKClaim {
    IZKVerifier public immutable verifier;
    address public owner;

    struct Distribution {
        uint256 root;
        address beneficiary;
        uint256 totalClaimed;
        uint256 cap;
        bool active;
    }

    mapping(uint256 => Distribution) public distributions;
    mapping(uint256 => bool) public nullifierUsed;

    event DistributionCreated(uint256 indexed distributionId, uint256 indexed root, address beneficiary);
    event Claimed(
        uint256 indexed distributionId,
        address indexed claimant,
        uint256 nullifier,
        uint256 amount
    );

    error NotOwner();
    error InvalidProof();
    error DistributionInactive();
    error RootMismatch();
    error NullifierAlreadyUsed();
    error CapExceeded();

    modifier onlyOwner() {
        if (msg.sender != owner) revert NotOwner();
        _;
    }

    constructor(IZKVerifier _verifier) {
        verifier = _verifier;
        owner = msg.sender;
    }

    function createDistribution(
        uint256 distributionId,
        uint256 root,
        address beneficiary,
        uint256 cap
    ) external onlyOwner {
        distributions[distributionId] = Distribution({
            root: root,
            beneficiary: beneficiary,
            totalClaimed: 0,
            cap: cap,
            active: true
        });
        emit DistributionCreated(distributionId, root, beneficiary);
    }

    receive() external payable {}

    /// @param pubSignals [root, distributionId, nullifier, amount]
    function claim(
        uint256[2] calldata proofA,
        uint256[2][2] calldata proofB,
        uint256[2] calldata proofC,
        uint256[] calldata pubSignals
    ) external {
        if (pubSignals.length != 4) revert InvalidProof();
        if (!verifier.verifyProof(proofA, proofB, proofC, pubSignals)) {
            revert InvalidProof();
        }

        uint256 root = pubSignals[0];
        uint256 distributionId = pubSignals[1];
        uint256 nullifier = pubSignals[2];
        uint256 amount = pubSignals[3];

        Distribution storage dist = distributions[distributionId];
        if (!dist.active) revert DistributionInactive();
        if (dist.root != root) revert RootMismatch();
        if (nullifierUsed[nullifier]) revert NullifierAlreadyUsed();
        if (dist.totalClaimed + amount > dist.cap) revert CapExceeded();

        nullifierUsed[nullifier] = true;
        dist.totalClaimed += amount;

        (bool ok, ) = dist.beneficiary.call{value: amount}("");
        require(ok, "transfer failed");

        emit Claimed(distributionId, msg.sender, nullifier, amount);
    }
}
