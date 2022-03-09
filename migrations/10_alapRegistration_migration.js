const ConfigYaml = require("config-yaml");
const contracts = ConfigYaml("../lap_config/contracts.yaml");
const Proxy = artifacts.require("Proxy");
const AlapRegistration = artifacts.require("AlapRegistration");

module.exports = async function (deployer, network, accounts) {
  await deployer.deploy(Proxy);
  await deployer.deploy(AlapRegistration);

  const proxy = await Proxy.deployed();
  const logic = await AlapRegistration.deployed();

  await proxy.upgrade(logic.address);

  const alapRegistration = await AlapRegistration.at(proxy.address);
  await alapRegistration.initialize(contracts.cypress.alap);
};
