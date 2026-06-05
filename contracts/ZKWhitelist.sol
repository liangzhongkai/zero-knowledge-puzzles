// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.19;

import "./IZKVerifier.sol";

/// @title ZK whitelist gate
/// @notice On-chain gate: valid Groth16 proof that a private secret is in `root` allowlist.
///         Prover does not reveal which leaf; only the Merkle root is public.
contract ZKWhitelist {
    IZKVerifier public immutable verifier;
    address public owner;

    /// @dev Active allowlist roots (e.g. snapshot of eligible addresses hashed to leaves).
    mapping(uint256 => bool) public allowedRoots;

    event RootRegistered(uint256 indexed root, address indexed registrar);
    event WhitelistAccess(address indexed caller, uint256 indexed root);

    error NotOwner();
    error InvalidProof();
    error UnknownRoot();

    modifier onlyOwner() {
        if (msg.sender != owner) revert NotOwner();
        _;
    }

    constructor(IZKVerifier _verifier) {
        verifier = _verifier;
        owner = msg.sender;
    }

    function transferOwnership(address newOwner) external onlyOwner {
        owner = newOwner;
    }

    function registerRoot(uint256 root) external onlyOwner {
        allowedRoots[root] = true;
        emit RootRegistered(root, msg.sender);
    }

    /// @param pubSignals [root] — must match circuit public inputs order.
    function proveAccess(
        uint256[2] calldata proofA,
        uint256[2][2] calldata proofB,
        uint256[2] calldata proofC,
        uint256[] calldata pubSignals
    ) external {
        if (pubSignals.length != 1) revert InvalidProof();
        if (!allowedRoots[pubSignals[0]]) revert UnknownRoot();
        if (!verifier.verifyProof(proofA, proofB, proofC, pubSignals)) {
            revert InvalidProof();
        }
        emit WhitelistAccess(msg.sender, pubSignals[0]);
    }
}
