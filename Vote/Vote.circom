pragma circom 2.1.4;

include "../lib/MerkleProof.circom";
include "../node_modules/circomlib/circuits/poseidon.circom";

// Anonymous eligible voting:
// - Merkle root = eligible voter set (same leaf as Whitelist: Poseidon(secret))
// - nullifier = Poseidon(secret, pollId) published on-chain to block double voting
// - voteCommitment = Poseidon(vote, secret, pollId) for tally without revealing identity
//
// Public:  root, pollId, nullifier, voteCommitment
// Private: secret, vote (0|1), pathElements, pathIndices

template Vote(levels) {
    signal input root;
    signal input pollId;
    signal input nullifier;
    signal input voteCommitment;

    signal input secret;
    signal input vote;
    signal input pathElements[levels];
    signal input pathIndices[levels];

    vote * (vote - 1) === 0;

    component leaf = IdentityLeaf();
    leaf.secret <== secret;

    component proof = MerkleProof(levels);
    proof.leaf <== leaf.leaf;
    proof.root <== root;
    for (var i = 0; i < levels; i++) {
        proof.pathElements[i] <== pathElements[i];
        proof.pathIndices[i] <== pathIndices[i];
    }

    component nf = Poseidon(2);
    nf.inputs[0] <== secret;
    nf.inputs[1] <== pollId;
    nullifier === nf.out;

    component vc = Poseidon(3);
    vc.inputs[0] <== vote;
    vc.inputs[1] <== secret;
    vc.inputs[2] <== pollId;
    voteCommitment === vc.out;
}

component main {public [root, pollId, nullifier, voteCommitment]} = Vote(8);
