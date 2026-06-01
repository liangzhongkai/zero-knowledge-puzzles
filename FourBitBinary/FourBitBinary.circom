pragma circom 2.1.8;

// Create a circuit that takes an array of four signals
// `in`and a signal s and returns is satisfied if `in`
// is the binary representation of `n`. For example:
// 
// Accept:
// 0,  [0,0,0,0]
// 1,  [1,0,0,0]
// 15, [1,1,1,1]
// 
// Reject:
// 0, [3,0,0,0]
// 
// The circuit is unsatisfiable if n > 15

template FourBitBinary() {
    signal input in[4];
    signal input n;

    for (var i = 0; i < 4; i++) {
        in[i] * (in[i] - 1) === 0;
    }

    signal tmp[5];
    tmp[0] <== 0;
    for (var i = 0; i < 4; i++) {
        tmp[i + 1] <== tmp[i] + in[i] * (2 ** i);
    }

    tmp[4] === n;
}

component main{public [n]} = FourBitBinary();
