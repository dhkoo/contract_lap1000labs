const { expectRevert, time } = require("@openzeppelin/test-helpers");
const { web3 } = require("@openzeppelin/test-helpers/src/setup");
const Proxy = artifacts.require("Proxy");
const Membership = artifacts.require("Membership");
const MembershipV2 = artifacts.require("MembershipV2");

contract("Membership Test", ([minter, black]) => {
  beforeEach(async () => {
    membershipLogic = await Membership.new();
    membershipProxy = await Proxy.new();
    await membershipProxy.upgrade(membershipLogic.address);

    membership = await Membership.at(membershipProxy.address);
    await membership.initialize(1);
  });

  it("mint()", async () => {
    await membership.mint(minter, "");
    const owner = await membership.ownerOf(1);
    const count = await membership.totalSupply();
    assert.equal(owner, minter);
    assert.equal(count, 1);
  });

  it("bulkMint()", async () => {
    await membership.bulkMint(minter, 50);
    const count = await membership.totalSupply();
    console.log(String(count));
  });

  it("upgrade", async () => {
    membershipLogicV2 = await MembershipV2.new();
    await membershipProxy.upgrade(membershipLogicV2.address);
    membershipV2 = await MembershipV2.at(membershipProxy.address);
    await membership.mint(minter, "");
    await membership.transferFrom(minter, black, 1);
    const owner = await membership.ownerOf(1);
    assert.equal(owner, black);

    await membershipV2.setTarget(black);
    try {
      await membership.transferFrom(black, minter, 1);
      assert.equal(0, 1, "Something wrong");
    } catch (e) {
      console.log(e);
    }
  });
});
