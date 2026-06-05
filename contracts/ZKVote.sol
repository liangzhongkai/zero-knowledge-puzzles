// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.19;

import "./IZKVerifier.sol";

/// @title ZK anonymous vote (eligible-set Merkle + nullifier)
/// @notice Public signals: [root, pollId, nullifier, voteCommitment].
///         `nullifier` prevents double voting; `voteCommitment` hides ballot + identity for off-chain tally.
contract ZKVote {
    IZKVerifier public immutable verifier;
    address public owner;

    struct Poll {
        uint256 root;
        bool active;
    }

    mapping(uint256 => Poll) public polls;
    mapping(uint256 => bool) public nullifierUsed;

    event PollCreated(uint256 indexed pollId, uint256 indexed root);
    event VoteCast(uint256 indexed pollId, uint256 nullifier, uint256 voteCommitment);

    error NotOwner();
    error InvalidProof();
    error PollInactive();
    error RootMismatch();
    error NullifierAlreadyUsed();

    modifier onlyOwner() {
        if (msg.sender != owner) revert NotOwner();
        _;
    }

    constructor(IZKVerifier _verifier) {
        verifier = _verifier;
        owner = msg.sender;
    }

    function createPoll(uint256 pollId, uint256 root) external onlyOwner {
        polls[pollId] = Poll({root: root, active: true});
        emit PollCreated(pollId, root);
    }

    function closePoll(uint256 pollId) external onlyOwner {
        polls[pollId].active = false;
    }

    /// @param pubSignals [root, pollId, nullifier, voteCommitment]
    function castVote(
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
        uint256 pollId = pubSignals[1];
        uint256 nullifier = pubSignals[2];
        uint256 voteCommitment = pubSignals[3];

        Poll storage poll = polls[pollId];
        if (!poll.active) revert PollInactive();
        if (poll.root != root) revert RootMismatch();
        if (nullifierUsed[nullifier]) revert NullifierAlreadyUsed();

        nullifierUsed[nullifier] = true;
        emit VoteCast(pollId, nullifier, voteCommitment);
    }
}
