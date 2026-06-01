pragma circom 2.1.4;

include "../node_modules/circomlib/circuits/mimcsponge.circom";

// In this exercise, we will learn an important concept related to hashing . There are 2 values a and b. You want to 
// perform computation on these and verify it , but secretly without discovering the values. 
// One way is to hash the 2 values and then store the hash as a reference. 
// There is one problem in this concept, attacker can brute force the 2 variables by comparing the public hash with the resulting hash.
// To overcome this , we use a secret value in the input privately. We hash it with a and b. 

// This way brute force becomes illogical as the cost will increase multifolds for the attacker.


// Input 3 values, a, b and salt. 
// Hash all 3 using mimcsponge as a hashing mechanism. 
// Output the res using 'out'.

template Salt() {
    // Your code here..done
    signal input a;
    signal input b;
    signal input salt;
    signal output out;

    //             Poseidon	                                   MiMCSponge
    // 设计目标    现代 ZK 协议里的通用哈希 / Merkle 标准件       更早、更简单的 ZK 哈希，带 key 参数
    // 典型用法    Poseidon(n) 把 n 个 field 元素 hash 成一个    MiMCSponge(nInputs, 220, nOutputs) 吸收输入 + 可选 key
    // 生态地位    当前 ZK 主流（Semaphore、Tornado、很多 L2）    circomlib 老代码、Dark Forest、EdDSA-MiMC 等

    component ms = MiMCSponge(2, 220, 1);
    ms.ins[0] <== a;
    ms.ins[1] <== b;
    ms.k <== salt;
    out <== ms.outs[0];
}

component main  = Salt();
// By default all inputs are private in circom. We will not define any input as public 
// because we want them to be a secret , at least in this case. 

// There will be cases where some values will be declared explicitly public .




