const ConfigYaml = require("config-yaml");
const Contracts = ConfigYaml("../lap_config/contracts.yaml");
const DonationViewer = artifacts.require("DonationViewer");

module.exports = async function(deployer, network, accounts) {
  if (network == "cypress" || network == "baobab") {
    await deployer.deploy(DonationViewer, Contracts[network].Donation, Contracts[network].AlapViewer);
  }
};
