const { expectRevert, time } = require("@openzeppelin/test-helpers");
const { assertion } = require("@openzeppelin/test-helpers/src/expectRevert");
const { web3 } = require("@openzeppelin/test-helpers/src/setup");
const TestNFT = artifacts.require("TestNFT");
const Proxy = artifacts.require("Proxy");
const AlapRegistration = artifacts.require("AlapRegistration");

contract("AlapRegistration Test", (accounts) => {
  beforeEach(async () => {
    testNFT = await TestNFT.new();
    proxy = await Proxy.new();
    logic = await AlapRegistration.new();
    await proxy.upgrade(logic.address);

    alapRegistration = await AlapRegistration.at(proxy.address);
    await alapRegistration.initialize(testNFT.address);

    await testNFT.mint(accounts[0], "");
  });

  it("register test", async () => {
    await alapRegistration.registerAlapId(1);
    let id = await alapRegistration.getUserAlapId(accounts[0]);
    assert.equal(id, 1);

    id = await alapRegistration.getUserAlapId(accounts[1]);
    assert.equal(id, 0);
  });

  it("owner changed test", async () => {
    await alapRegistration.registerAlapId(1);
    let id = await alapRegistration.getUserAlapId(accounts[0]);
    assert.equal(id, 1);

    await testNFT.transferFrom(accounts[0], accounts[1], 1);
    id = await alapRegistration.getUserAlapId(accounts[0]);
    assert.equal(id, 0);
  });
});
