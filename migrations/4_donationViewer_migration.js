const ConfigYaml = require("config-yaml");
const addrBook = ConfigYaml("../addrBook.yaml");
const DonationViewer = artifacts.require("DonationViewer");

module.exports = async function(deployer, network, accounts) {
  if (network == "cypress" || network == "baobab") {
    await deployer.deploy(DonationViewer, addrBook[network].Donation, addrBook[network].AlapViewer);
  }
};
