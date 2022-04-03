const Proxy = artifacts.require("Proxy");
const Store = artifacts.require("Store");

module.exports = async function (deployer, network, accounts) {
  await deployer.deploy(Proxy);
  await deployer.deploy(Store);

  const proxy = await Proxy.deployed();
  const logic = await Store.deployed();

  await proxy.upgrade(logic.address);

  const store = await Store.at(proxy.address);
  await store.initialize(accounts[0], 250, 100, 2, 10);
};
