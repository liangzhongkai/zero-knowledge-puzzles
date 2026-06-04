# 1. 生成 wasm / r1cs / zkey / verifier（在 Compile/ 下，或跑 script.sh）
cd Compile && circom Mul.circom --r1cs --wasm -o .
# ... snarkjs 仪式（见 script.sh）...

# 2. 编译 Solidity
cd .. && npx hardhat compile

# 3. 跑测试
yarn mocha test/Compile.js
