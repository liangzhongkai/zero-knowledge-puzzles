pragma circom 2.1.8;
include "../node_modules/circomlib/circuits/comparators.circom";

// Write a circuit that constrains the 4 input signals to be
// sorted. Sorted means the values are non decreasing starting
// at index 0. The circuit should not have an output.

template IsSorted() {
    signal input in[4];

    component let1 = LessEqThan(32);
    let1.in[0] <== in[0];
    let1.in[1] <== in[1];
    let1.out === 1;
    
    component let2 = LessEqThan(32);
    let2.in[0] <== in[1];
    let2.in[1] <== in[2];
    let2.out === 1;
    
    component let3 = LessEqThan(32);
    let3.in[0] <== in[2];
    let3.in[1] <== in[3];
    let3.out === 1;
    
}

component main = IsSorted();
