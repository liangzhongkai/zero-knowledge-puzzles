pragma circom 2.1.8;
include "../node_modules/circomlib/circuits/comparators.circom";

// Be sure to solve IntSqrt before solving this 
// puzzle. Your goal is to compute the square root
// in the provided function, then constrain the answer
// to be true using your work from the previous puzzle.
// You can use the Bablyonian/Heron's or Newton's
// method to compute the integer square root. Remember,
// this is not the modular square root.


function intSqrtFloor(x) {
    // compute the floor of the
    // integer square root
    if (x == 0) return 0;
    var lo = 0;
    var hi = x;
    while (lo < hi) {
        var mid = (lo + hi + 1) \ 2;
        if (mid * mid <= x) {
            lo = mid;
        } else {
            hi = mid - 1;
        }
    }
    return lo;
}

template IntSqrtOut(n) {
    signal input in;
    signal output out;

    out <-- intSqrtFloor(in);
    // constrain out using your
    // work from IntSqrt

    signal bSq;
    bSq <== out * out;

    component lower  = LessThan(n);
    lower.in[0] <== bSq;
    lower.in[1] <== in + 1;

    component upper = LessThan(n);
    upper.in[0] <== in;
    upper.in[1] <== bSq + 2 * out + 1; // (x + 1)^2 => x^2 + 2x + 1

    lower.out * upper.out === 1;
}

component main = IntSqrtOut(252);
