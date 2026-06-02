pragma circom 2.1.8;

include "../node_modules/circomlib/circuits/comparators.circom";

// Create a circuit that takes an array of signals `in[n]` and
// a signal k. The circuit should return 1 if `k` is in the list
// and 0 otherwise. This circuit should work for an arbitrary
// length of `in`.

template HasAtLeastOne(n) {
    signal input in[n];
    signal input k;
    signal output out;

    component eq[n];   // 声明 n 个 IsEqual 组件
    signal ret <== 1;
    signal terms[n+1];
    terms[0] <== 1;
    for (var i=0; i<n; i++) {
        eq[i] = IsEqual();
        eq[i].in[0] <== in[i];
        eq[i].in[1] <== k;
        terms[i+1] <== terms[i] * (1 - eq[i].out);
    }

    out <== 1 - terms[n];

}

component main = HasAtLeastOne(4);
