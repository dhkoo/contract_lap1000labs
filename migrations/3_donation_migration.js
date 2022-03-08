const ConfigYaml = require("config-yaml");
const Contracts = ConfigYaml("../lap_config/contracts.yaml");
const Donation = artifacts.require("Donation");
const zero = "0x0000000000000000000000000000000000000000";

module.exports = async function (deployer, network, accounts) {
  const palaAddr = network == "cypress" ? Contracts[network].pala : zero;
  await deployer.deploy(Donation, palaAddr);
};
