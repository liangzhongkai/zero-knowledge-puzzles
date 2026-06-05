pragma circom 2.1.4;

include "../lib/MerkleProof.circom";
include "../node_modules/circomlib/circuits/poseidon.circom";

// Airdrop / reward claim with double-spend protection:
// - Leaf = Poseidon(secret, amount) so amount is bound to eligibility
// - nullifier = Poseidon(secret, distributionId) marks one-time claim on-chain
//
// Public:  root, distributionId, nullifier, amount
// Private: secret, pathElements, pathIndices

template Claim(levels) {
    signal input root;
    signal input distributionId;
    signal input nullifier;
    signal input amount;

    signal input secret;
    signal input pathElements[levels];
    signal input pathIndices[levels];

    component leaf = ClaimLeaf();
    leaf.secret <== secret;
    leaf.amount <== amount;

    component proof = MerkleProof(levels);
    proof.leaf <== leaf.leaf;
    proof.root <== root;
    for (var i = 0; i < levels; i++) {
        proof.pathElements[i] <== pathElements[i];
        proof.pathIndices[i] <== pathIndices[i];
    }

    component nf = Poseidon(2);
    nf.inputs[0] <== secret;
    nf.inputs[1] <== distributionId;
    nullifier === nf.out;
}

component main {public [root, distributionId, nullifier, amount]} = Claim(8);
