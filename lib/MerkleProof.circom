pragma circom 2.1.4;

include "../node_modules/circomlib/circuits/poseidon.circom";

// Poseidon Merkle inclusion: leaf + siblings + direction bits reconstruct root.
// pathIndices[i] = 0 => current node is left child (hash current || sibling)
// pathIndices[i] = 1 => current node is right child (hash sibling || current)
template MerkleProof(levels) {
    signal input leaf;
    signal input root;
    signal input pathElements[levels];
    signal input pathIndices[levels];

    signal levelHashes[levels + 1];
    levelHashes[0] <== leaf;

    component hashers[levels];

    for (var i = 0; i < levels; i++) {
        pathIndices[i] * (pathIndices[i] - 1) === 0;

        hashers[i] = Poseidon(2);
        hashers[i].inputs[0] <== pathIndices[i] * (pathElements[i] - levelHashes[i]) + levelHashes[i];
        hashers[i].inputs[1] <== pathIndices[i] * (levelHashes[i] - pathElements[i]) + pathElements[i];
        levelHashes[i + 1] <== hashers[i].out;
    }

    root === levelHashes[levels];
}

// Single-field identity leaf (whitelist / voter / claimant secret).
template IdentityLeaf() {
    signal input secret;
    signal output leaf;

    component h = Poseidon(1);
    h.inputs[0] <== secret;
    leaf <== h.out;
}

// Leaf binds secret + claim amount (prevents changing amount at claim time).
template ClaimLeaf() {
    signal input secret;
    signal input amount;
    signal output leaf;

    component h = Poseidon(2);
    h.inputs[0] <== secret;
    h.inputs[1] <== amount;
    leaf <== h.out;
}
