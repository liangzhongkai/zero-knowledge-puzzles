pragma circom 2.1.8;
include "../node_modules/circomlib/circuits/comparators.circom";

// Write a circuit that returns true when at least one
// element is 1. It should return false if all elements
// are 0. It should be unsatisfiable if any of the inputs
// are not 0 or not 1.

template MultiOR(n) {
    signal input in[n];
    signal output out;

    for (var i=0; i<n; i++)
        in[i] * (in[i] - 1) === 0;

    signal tmp[n+1];
    tmp[0] <== 0;
    for (var i=0; i<n; i++)
        tmp[i+1] <== tmp[i] + in[i] - tmp[i] * in[i];

    out <== tmp[n];
}

component main = MultiOR(4);
