const path = require("path");
const chai = require("chai");
const chaiAsPromised = require("chai-as-promised");
const wasm_tester = require("circom_tester").wasm;
const { buildWhitelistWitness } = require("../lib/proofInputs");

chai.use(chaiAsPromised);
const expect = chai.expect;

describe("Whitelist (Merkle membership)", function () {
    this.timeout(300000);

    const secrets = ["101", "202", "303", "404"];

    it("accepts a valid Merkle membership proof", async () => {
        const circuit = await wasm_tester(
            path.join(__dirname, "../Whitelist/Whitelist.circom")
        );
        await circuit.loadConstraints();

        const input = await buildWhitelistWitness(secrets[2], secrets, 2);
        await expect(circuit.calculateWitness(input, true)).to.eventually.be.ok;
    });

    it("rejects wrong Merkle root", async () => {
        const circuit = await wasm_tester(
            path.join(__dirname, "../Whitelist/Whitelist.circom")
        );
        const input = await buildWhitelistWitness(secrets[0], secrets, 0);
        input.root = "1";
        await expect(circuit.calculateWitness(input, true)).to.be.eventually.rejected;
    });

    it("rejects non-member secret", async () => {
        const circuit = await wasm_tester(
            path.join(__dirname, "../Whitelist/Whitelist.circom")
        );
        const input = await buildWhitelistWitness("99999", secrets, 0);
        await expect(circuit.calculateWitness(input, true)).to.be.eventually.rejected;
    });
});
