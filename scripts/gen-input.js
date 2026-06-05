#!/usr/bin/env node
/**
 * Generate input.json for a scenario directory.
 * Usage: node scripts/gen-input.js whitelist|vote|claim
 */
const fs = require("fs");
const path = require("path");
const {
    buildWhitelistWitness,
    buildVoteWitness,
    buildClaimWitness,
} = require("../lib/proofInputs");

async function main() {
    const scenario = process.argv[2];
    const root = path.join(__dirname, "..");

    let outPath;
    let input;

    if (scenario === "whitelist") {
        const secrets = ["101", "202", "303", "404"];
        input = await buildWhitelistWitness(secrets[1], secrets, 1);
        outPath = path.join(root, "Whitelist/input.json");
    } else if (scenario === "vote") {
        input = await buildVoteWitness({
            secret: "22",
            vote: 1,
            pollId: "9001",
            allSecrets: ["11", "22", "33", "44"],
            leafIndex: 1,
        });
        outPath = path.join(root, "Vote/input.json");
    } else if (scenario === "claim") {
        const entries = [
            { secret: "1001", amount: "1000000000000000000" },
            { secret: "1002", amount: "2000000000000000000" },
        ];
        input = await buildClaimWitness({
            secret: entries[0].secret,
            amount: entries[0].amount,
            distributionId: "42",
            entries,
            leafIndex: 0,
        });
        outPath = path.join(root, "Claim/input.json");
    } else {
        console.error("Usage: node 2 whitelist|vote|claim");
        process.exit(1);
    }

    fs.writeFileSync(outPath, JSON.stringify(input, null, 2));
    console.log("Wrote", outPath);
}

main().catch((e) => {
    console.error(e);
    process.exit(1);
});
