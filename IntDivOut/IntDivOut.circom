pragma circom 2.1.8;
include "../node_modules/circomlib/circuits/comparators.circom";

// Use the same constraints from IntDiv, but this
// time assign the quotient in `out`. You still need
// to apply the same constraints as IntDiv

template IntDivOut(n) {
    signal input numerator;
    signal input denominator;
    signal output out;

    component iz = IsZero();
    iz.in <== denominator;
    iz.out === 0;


    // 为什么 \ 不能配合 <==
    //      R1CS 里合法的约束大致是这种形式：
    //      A * B === C    // 乘法 + 加法，最高二次

    // 但 \ 和 % 是整数除法 / 取模，不是「一次乘法就能表达的等式」。
    // 编译器没法把它们化成 R1CS 里的二次约束，所以会报：
    // error[T3001]: Non quadratic constraints are not allowed

    out <-- numerator \ denominator;
    signal remainder;
    remainder <-- numerator - out * denominator;

    component lt = LessThan(252);
    lt.in[0] <== remainder;
    lt.in[1] <== denominator;
    lt.out === 1;


    numerator === out * denominator + remainder;

}

component main = IntDivOut(252);
