pragma circom 2.1.4;

include "../lib/MerkleProof.circom";

// Production pattern: prove membership in an allowlist Merkle root without revealing
// which leaf (secret) you are. Only root is public; identity stays private.
//
// Public:  root
// Private: secret, pathElements[levels], pathIndices[levels]

template Whitelist(levels) {
    signal input root;
    signal input secret;
    signal input pathElements[levels];
    signal input pathIndices[levels];
    signal output out;

    component leaf = IdentityLeaf();
    leaf.secret <== secret;

    component proof = MerkleProof(levels);
    proof.leaf <== leaf.leaf;
    proof.root <== root;
    for (var i = 0; i < levels; i++) {
        proof.pathElements[i] <== pathElements[i];
        proof.pathIndices[i] <== pathIndices[i];
    }

    out <== 1;
}

component main {public [root]} = Whitelist(8);
