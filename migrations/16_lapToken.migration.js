const Proxy = artifacts.require("Proxy");
const LapToken = artifacts.require("LapToken");

module.exports = async function (deployer, network, accounts) {
  await deployer.deploy(Proxy);
  await deployer.deploy(LapToken);

  const proxy = await Proxy.deployed();
  const logic = await LapToken.deployed();

  await proxy.upgrade(logic.address);

  const lapToken = await LapToken.at(proxy.address);
  await lapToken.initialize();
};
