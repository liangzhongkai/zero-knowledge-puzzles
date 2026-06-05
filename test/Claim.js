const path = require("path");
const chai = require("chai");
const chaiAsPromised = require("chai-as-promised");
const wasm_tester = require("circom_tester").wasm;
const { buildClaimWitness } = require("../lib/proofInputs");

chai.use(chaiAsPromised);
const expect = chai.expect;

describe("Claim (amount-bound leaf + nullifier)", function () {
    this.timeout(300000);

    const distributionId = "42";
    const entries = [
        { secret: "1001", amount: "1000000000000000000" },
        { secret: "1002", amount: "2000000000000000000" },
        { secret: "1003", amount: "500000000000000000" },
    ];

    it("accepts valid claim proof", async () => {
        const circuit = await wasm_tester(path.join(__dirname, "../Claim/Claim.circom"));
        await circuit.loadConstraints();

        const input = await buildClaimWitness({
            secret: entries[1].secret,
            amount: entries[1].amount,
            distributionId,
            entries,
            leafIndex: 1,
        });
        await expect(circuit.calculateWitness(input, true)).to.eventually.be.ok;
    });

    it("rejects tampered claim amount", async () => {
        const circuit = await wasm_tester(path.join(__dirname, "../Claim/Claim.circom"));
        const input = await buildClaimWitness({
            secret: entries[0].secret,
            amount: entries[0].amount,
            distributionId,
            entries,
            leafIndex: 0,
        });
        input.amount = "999";
        await expect(circuit.calculateWitness(input, true)).to.be.eventually.rejected;
    });

    it("rejects wrong nullifier", async () => {
        const circuit = await wasm_tester(path.join(__dirname, "../Claim/Claim.circom"));
        const input = await buildClaimWitness({
            secret: entries[2].secret,
            amount: entries[2].amount,
            distributionId,
            entries,
            leafIndex: 2,
        });
        input.nullifier = "0";
        await expect(circuit.calculateWitness(input, true)).to.be.eventually.rejected;
    });
});
