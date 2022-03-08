const ConfigYaml = require("config-yaml");
const Contracts = ConfigYaml("../lap_config/contracts.yaml");
const NameBookViewer = artifacts.require("NameBookViewer");

module.exports = async function (deployer, network, accounts) {
  if (network == "cypress") {
    await deployer.deploy(NameBookViewer, Contracts[network].ProxyNameBook);
  }
};
