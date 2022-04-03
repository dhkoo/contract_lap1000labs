const ConfigYaml = require("config-yaml");
const Contracts = ConfigYaml("../lap_config/contracts.yaml");
const StoreViewer = artifacts.require("StoreViewer");

module.exports = async function (deployer, network, accounts) {
  if (network == "cypress" || network == "baobab") {
    await deployer.deploy(StoreViewer, Contracts[network].Store);
  }
};
