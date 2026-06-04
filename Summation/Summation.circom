pragma circom 2.1.8;

template Summation(n) {
    signal input in[n];
    signal input sum;

    // constrain sum === in[0] + in[1] + in[2] + ... + in[n-1]
    // this should work for any n
    signal tmp[n + 1];
    tmp[0] <== 0;
    for( var i = 0; i<n; i++) {
        tmp[i+1] <== tmp[i] + in[i];
    }
    sum === tmp[n];
}

component main = Summation(8);