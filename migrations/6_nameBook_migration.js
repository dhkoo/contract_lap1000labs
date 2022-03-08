const ConfigYaml = require("config-yaml");
const Contracts = ConfigYaml("../lap_config/contracts.yaml");
const NameBook = artifacts.require("NameBook");

module.exports = async function (deployer, network, accounts) {
  if (network == "cypress") {
    await deployer.deploy(
      NameBook,
      Contracts[network].pala,
      Contracts[network].DonationViewer
    );
  }
};
