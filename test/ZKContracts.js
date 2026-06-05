const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("ZK scenario contracts (application logic)", function () {
    let verifier;
    let owner;
    let user;

    beforeEach(async () => {
        [owner, user] = await ethers.getSigners();
        const Mock = await ethers.getContractFactory("MockZKVerifier");
        verifier = await Mock.deploy(true);
        await verifier.deployed();
    });

    it("ZKWhitelist: registers root and accepts mock proof", async () => {
        const root = 12345;
        const WL = await ethers.getContractFactory("ZKWhitelist");
        const wl = await WL.deploy(verifier.address);
        await wl.deployed();
        await wl.registerRoot(root);

        await wl
            .connect(user)
            .proveAccess([0, 0], [[0, 0], [0, 0]], [0, 0], [root]);
    });

    it("ZKVote: rejects double nullifier", async () => {
        const Vote = await ethers.getContractFactory("ZKVote");
        const vote = await Vote.deploy(verifier.address);
        await vote.deployed();
        const pollId = 1;
        const root = 99;
        await vote.createPoll(pollId, root);

        const pub = [root, pollId, 555, 777];
        await vote.castVote([0, 0], [[0, 0], [0, 0]], [0, 0], pub);
        await expect(
            vote.castVote([0, 0], [[0, 0], [0, 0]], [0, 0], pub)
        ).to.be.reverted;
    });

    it("ZKClaim: pays beneficiary on valid mock proof", async () => {
        const Claim = await ethers.getContractFactory("ZKClaim");
        const claim = await Claim.deploy(verifier.address);
        await claim.deployed();

        const distId = 42;
        const root = 1;
        const amount = ethers.utils.parseEther("0.5");
        await claim.createDistribution(distId, root, user.address, ethers.utils.parseEther("10"));
        await owner.sendTransaction({
            to: claim.address,
            value: ethers.utils.parseEther("1"),
        });

        const before = await ethers.provider.getBalance(user.address);
        await claim.claim([0, 0], [[0, 0], [0, 0]], [0, 0], [root, distId, 999, amount]);
        const after = await ethers.provider.getBalance(user.address);
        expect(after.sub(before)).to.equal(amount);
    });
});
