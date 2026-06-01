pragma circom 2.1.4;

include "../node_modules/circomlib/circuits/poseidon.circom";

// Go through the circomlib library and import the poseidon hashing template using node_modules
// Input 4 variables,namely,'a','b','c','d' , and output variable 'out' .
// Now , hash all the 4 inputs using poseidon and output it . 
template poseidon() {

   // Your Code here..done
   signal input a;
   signal input b;
   signal input c;
   signal input d;
   signal output out;

   //  Poseidon 是为 零知识证明 设计的哈希（见 Poseidon 论文），在电路里比 SHA-256 便宜很多。

   //  对 Poseidon(4) 来说，关键参数是：
   //  参数	             值	                  含义
   //  nInputs            4                    你传入的 4 个输入
   //  t                  5                    内部状态宽度 = nInputs + 1
   //  initialState       0                    第 0 个状态槽的初始值
   //  输出               1 个 field 元素       哈希结果
  
   //  内部状态可以看成 5 个槽位：
   //  [state₀, input₀, input₁, input₂, input₃]
   //     ↑        ↑       ↑       ↑       ↑
   //     0        a       b       c       d
   //  然后经过多轮运算，主要包括：
   //     1. Add Round Constants (Ark) — 加常数
   //     2. S-box (Sigma) —    x   ↦   x^5x↦x5（ZK 友好）
   //     3. Mix / MixS — 线性混合（MDS 矩阵）
   //  circomlib 对 t = 5 用的是论文推荐参数：8 轮 full rounds + 57 轮 partial rounds（见 N_ROUNDS_P 表）。

   // 和常见哈希的对比
   //     Keccak/SHA-256：比特操作为主，在 R1CS 电路里约束数量巨大。
   //     Poseidon：直接在有限域上运算，约束少，适合 Merkle 树、commitment、nullifier 等 ZK 场景。
   // 注意：Poseidon 的输入/输出都是 有限域元素（通常 BN254 的 scalar field），不是任意字节串。
   //      输入必须在域范围内，否则证明会失败。
   component psd = Poseidon(4);
   psd.inputs[0] <== a;
   psd.inputs[1] <== b;
   psd.inputs[2] <== c;
   psd.inputs[3] <== d;
   out <== psd.out;
}

component main = poseidon();