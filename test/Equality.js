const chai = require('chai');
const { wasm } = require('circom_tester');
const path = require("path");
const F1Field = require("ffjavascript").F1Field;
const Scalar = require("ffjavascript").Scalar;
exports.p = Scalar.fromString("21888242871839275222246405745257275088548364400416034343698204186575808495617");
const Fr = new F1Field(exports.p);

const wasm_tester = require("circom_tester").wasm;

const assert = chai.assert;

describe("Equality Test ", function () {
    this.timeout(100000);

    it("Check Equality", async () => {
        const circuit = await wasm_tester(path.join(__dirname, "../Equality", "Equality.circom"));
        await circuit.loadConstraints();
        let witness;
        // 2 == 2 && 2 == 2 
        const expectedOutput = 1;

        // 机制	                                何时起作用
        // calculateWitness(..., true)          算 witness 时检查约束是否满足；不满足会抛错

        // 下标	                      含义	                    你的 Equality 电路里
        // witness[0]                 恒为 1                    R1CS 里的「常数 1」线，不是业务信号
        // witness[1]                 主电路的第一个信号         你的 signal output c
        // witness[2]～witness[4]     后续信号                   a[0], a[1], a[2]
        // witness[5] 及以后          内部信号                   eq1.out、IsZero 中间量等
        witness = await circuit.calculateWitness({ "a": [2, 2, 2] }, true);
        // Fr.e(x) — 转成域元素: 把各种输入规范化成域里的 BigInt（对 p 取模，并处理负数等）
        // Fr.eq(a, b) — 域里是否相等: 就是判断两个已规范化的域元素是否相同（底层 a == b）
        // 为什么不直接 assert.equal(witness[1], 1)？
        //     可以，但在这个项目里习惯用 Fr，原因包括：
        //         1. 和 ZK 栈一致：snarkjs、circom_tester 都用同一套域
        //         2. 类型统一：witness 常常是 BigInt，1 是 number，直接 === 可能失败
        //         3. 大数/模运算：超出安全整数或需要模 p 时，Fr.e 会按域规则处理
        //         对 0、1、2 这种小值，写成 witness[1] == 1 往往也能过；
        //         用 Fr.eq(Fr.e(...), Fr.e(...)) 是模板写法，大域元素时更稳。
        assert(Fr.eq(Fr.e(witness[0]), Fr.e(1)));
        assert(Fr.eq(Fr.e(witness[1]), Fr.e(expectedOutput)));

        witness = await circuit.calculateWitness({ "a": [1, 0, 1] }, true);
        let expectedOutput2 = 0;
        assert(Fr.eq(Fr.e(witness[0]), Fr.e(1)));
        assert(Fr.eq(Fr.e(witness[1]), Fr.e(expectedOutput2)));

        witness = await circuit.calculateWitness({ "a": [1, 1, 0] }, true);
        let expectedOutput3 = 0;
        assert(Fr.eq(Fr.e(witness[0]), Fr.e(1)));
        assert(Fr.eq(Fr.e(witness[1]), Fr.e(expectedOutput3)));

        witness = await circuit.calculateWitness({ "a": [2, 1, 1] }, true);
        let expectedOutput4 = 0;
        assert(Fr.eq(Fr.e(witness[0]), Fr.e(1)));
        assert(Fr.eq(Fr.e(witness[1]), Fr.e(expectedOutput4)));
    })
})