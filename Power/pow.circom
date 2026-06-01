pragma circom 2.1.4;

// Create a circuit which takes an input 'a',(array of length 2 ) , then  implement power modulo 
// and return it using output 'c'.

// HINT: Non Quadratic constraints are not allowed. 

include "../node_modules/circomlib/circuits/comparators.circom";

template Pow() {
   
   // Your Code here..done
   signal input a[2];
   signal output c;
   
   var N = 10;
    signal powers[N + 1];
    powers[0] <== 1;
    for (var i = 0; i < N; i++) {
        powers[i + 1] <== powers[i] * a[0];
    }
    component eq[N + 1];
    signal terms[N + 1];
    for (var i = 0; i <= N; i++) {
        eq[i] = IsEqual();
        eq[i].in[0] <== a[1];
        eq[i].in[1] <== i;
        terms[i] <== eq[i].out * powers[i];
    }
    signal acc[N + 2];
    acc[0] <== 0;
    for (var j = 0; j <= N; j++) {
        acc[j + 1] <== acc[j] + terms[j];
    }
    c <== acc[N + 1];
   
}

component main = Pow();
