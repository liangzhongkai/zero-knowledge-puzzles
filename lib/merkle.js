/**
 * Off-chain Poseidon Merkle tree helpers (matches lib/MerkleProof.circom).
 * Used by tests and scripts to build roots and inclusion proofs.
 */

const { buildPoseidon } = require("circomlibjs");

const TREE_DEPTH = 8;

let poseidon;
let F;

async function initPoseidon() {
    if (poseidon) return;
    poseidon = await buildPoseidon();
    F = poseidon.F;
}

function toField(x) {
    if (typeof x === "bigint") return x;
    if (typeof x === "string") return BigInt(x);
    return BigInt(x);
}

function poseidonHash(inputs) {
    const arr = inputs.map((x) => F.e(toField(x)));
    const out = poseidon(arr);
    return F.toObject(out);
}

function hashLeaf(secret) {
    return poseidonHash([secret]);
}

function hashClaimLeaf(secret, amount) {
    return poseidonHash([secret, amount]);
}

function hashPair(left, right) {
    return poseidonHash([left, right]);
}

function computeZeroHashes(depth) {
    const zeros = [0n];
    for (let i = 1; i <= depth; i++) {
        zeros.push(hashPair(zeros[i - 1], zeros[i - 1]));
    }
    return zeros;
}

function buildMerkleTree(leaves, depth = TREE_DEPTH) {
    const size = 1 << depth;
    if (leaves.length > size) {
        throw new Error(`Too many leaves: ${leaves.length} > ${size}`);
    }

    const zeros = computeZeroHashes(depth);
    const padded = [...leaves];
    while (padded.length < size) {
        padded.push(zeros[0]);
    }

    let level = padded.map((l) => toField(l));
    const layers = [level];

    for (let d = 0; d < depth; d++) {
        const next = [];
        for (let i = 0; i < level.length; i += 2) {
            next.push(hashPair(level[i], level[i + 1]));
        }
        level = next;
        layers.push(level);
    }

    return { root: level[0], layers, zeros, depth };
}

function getMerkleProof(tree, leafIndex) {
    const { layers, depth } = tree;
    const pathElements = [];
    const pathIndices = [];

    let idx = leafIndex;
    for (let d = 0; d < depth; d++) {
        const level = layers[d];
        const isRight = idx % 2;
        const siblingIdx = isRight ? idx - 1 : idx + 1;
        pathElements.push(level[siblingIdx].toString());
        pathIndices.push(isRight ? 1 : 0);
        idx = Math.floor(idx / 2);
    }

    return {
        pathElements,
        pathIndices,
        root: tree.root.toString(),
    };
}

module.exports = {
    TREE_DEPTH,
    initPoseidon,
    hashLeaf,
    hashClaimLeaf,
    hashPair,
    buildMerkleTree,
    getMerkleProof,
    poseidonHash,
};
