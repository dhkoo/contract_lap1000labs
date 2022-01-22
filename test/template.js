const { expectRevert, time } = require("@openzeppelin/test-helpers");
const { web3 } = require("@openzeppelin/test-helpers/src/setup");
const Test = artifacts.require("Test");

contract("Test Script Template", (accounts) => {

    beforeEach(async () => {
        test = await Test.new();
    });

    it("Test1", async () => {
    });
});
