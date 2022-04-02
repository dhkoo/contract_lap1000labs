const Proxy = artifacts.require("Proxy");
const Membership = artifacts.require("Membership");

module.exports = async function (deployer, network, accounts) {
  await deployer.deploy(Proxy);
  await deployer.deploy(Membership);

  const proxy = await Proxy.deployed();
  const logic = await Membership.deployed();

  await proxy.upgrade(logic.address);

  const membership = await Membership.at(proxy.address);
  await membership.initialize(0);
};
