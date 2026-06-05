// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.19;

/// @notice Minimal Groth16 verifier interface (snarkjs export compatible).
interface IZKVerifier {
    function verifyProof(
        uint256[2] calldata _pA,
        uint256[2][2] calldata _pB,
        uint256[2] calldata _pC,
        uint256[] calldata _pubSignals
    ) external view returns (bool);
}
