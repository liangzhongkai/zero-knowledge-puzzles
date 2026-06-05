// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.19;

import "./IZKVerifier.sol";

/// @dev Test double only — never deploy to production.
contract MockZKVerifier is IZKVerifier {
    bool public shouldVerify;

    constructor(bool _shouldVerify) {
        shouldVerify = _shouldVerify;
    }

    function setShouldVerify(bool v) external {
        shouldVerify = v;
    }

    function verifyProof(
        uint256[2] calldata,
        uint256[2][2] calldata,
        uint256[2] calldata,
        uint256[] calldata
    ) external view returns (bool) {
        return shouldVerify;
    }
}
