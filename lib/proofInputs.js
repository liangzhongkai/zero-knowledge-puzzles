const {
    initPoseidon,
    hashLeaf,
    hashClaimLeaf,
    buildMerkleTree,
    getMerkleProof,
    poseidonHash,
    TREE_DEPTH,
} = require("./merkle");

async function buildWhitelistWitness(secret, allSecrets, leafIndex) {
    await initPoseidon();
    const leaves = allSecrets.map((s) => hashLeaf(s));
    const tree = buildMerkleTree(leaves);
    const proof = getMerkleProof(tree, leafIndex);
    return {
        root: proof.root,
        secret: secret.toString(),
        pathElements: proof.pathElements,
        pathIndices: proof.pathIndices,
    };
}

async function buildVoteWitness({ secret, vote, pollId, allSecrets, leafIndex }) {
    await initPoseidon();
    const leaves = allSecrets.map((s) => hashLeaf(s));
    const tree = buildMerkleTree(leaves);
    const proof = getMerkleProof(tree, leafIndex);
    const nullifier = poseidonHash([secret, pollId]).toString();
    const voteCommitment = poseidonHash([vote, secret, pollId]).toString();

    return {
        root: proof.root,
        pollId: pollId.toString(),
        nullifier,
        voteCommitment,
        secret: secret.toString(),
        vote: vote.toString(),
        pathElements: proof.pathElements,
        pathIndices: proof.pathIndices,
    };
}

async function buildClaimWitness({ secret, amount, distributionId, entries, leafIndex }) {
    await initPoseidon();
    const leaves = entries.map((e) => hashClaimLeaf(e.secret, e.amount));
    const tree = buildMerkleTree(leaves);
    const proof = getMerkleProof(tree, leafIndex);
    const nullifier = poseidonHash([secret, distributionId]).toString();

    return {
        root: proof.root,
        distributionId: distributionId.toString(),
        nullifier,
        amount: amount.toString(),
        secret: secret.toString(),
        pathElements: proof.pathElements,
        pathIndices: proof.pathIndices,
    };
}

module.exports = {
    TREE_DEPTH,
    buildWhitelistWitness,
    buildVoteWitness,
    buildClaimWitness,
};
