const path = require("path");
const chai = require("chai");
const chaiAsPromised = require("chai-as-promised");
const wasm_tester = require("circom_tester").wasm;
const { buildVoteWitness } = require("../lib/proofInputs");

chai.use(chaiAsPromised);
const expect = chai.expect;

describe("Vote (eligible set + nullifier + commitment)", function () {
    this.timeout(300000);

    const voters = ["11", "22", "33", "44"];
    const pollId = "9001";

    it("accepts yes vote with valid nullifier and commitment", async () => {
        const circuit = await wasm_tester(path.join(__dirname, "../Vote/Vote.circom"));
        await circuit.loadConstraints();

        const input = await buildVoteWitness({
            secret: voters[1],
            vote: 1,
            pollId,
            allSecrets: voters,
            leafIndex: 1,
        });
        await expect(circuit.calculateWitness(input, true)).to.eventually.be.ok;
    });

    it("rejects invalid vote value", async () => {
        const circuit = await wasm_tester(path.join(__dirname, "../Vote/Vote.circom"));
        const input = await buildVoteWitness({
            secret: voters[0],
            vote: 2,
            pollId,
            allSecrets: voters,
            leafIndex: 0,
        });
        await expect(circuit.calculateWitness(input, true)).to.be.eventually.rejected;
    });

    it("rejects reused wrong nullifier", async () => {
        const circuit = await wasm_tester(path.join(__dirname, "../Vote/Vote.circom"));
        const input = await buildVoteWitness({
            secret: voters[0],
            vote: 0,
            pollId,
            allSecrets: voters,
            leafIndex: 0,
        });
        input.nullifier = "1";
        await expect(circuit.calculateWitness(input, true)).to.be.eventually.rejected;
    });
});
