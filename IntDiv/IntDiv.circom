pragma circom 2.1.8;
include "../node_modules/circomlib/circuits/comparators.circom";

// Create a circuit that is satisfied if `numerator`,
// `denominator`, `quotient`, and `remainder` represent
// a valid integer division. You will need a comparison check, so
// we've already imported the library and set n to be 252 bits.
//
// Hint: integer division in Circom is `\`.
// `/` is modular division
// `%` is integer modulus

template IntDiv(n) {
    signal input numerator;
    signal input denominator;
    signal input quotient;
    signal input remainder;


    component iz = IsZero();
    iz.in <== denominator;
    iz.out === 0;


    component lt = LessThan(252);
    lt.in[0] <== remainder;
    lt.in[1] <== denominator;
    lt.out === 1;


    numerator === quotient * denominator + remainder;
}

component main = IntDiv(252);
