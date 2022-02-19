const ConfigYaml = require("config-yaml");
const addrBook = ConfigYaml("../addrBook.yaml");
const NameBook = artifacts.require("NameBook");

module.exports = async function (deployer, network, accounts) {
  await deployer.deploy(
    NameBook,
    addrBook[network].pala,
    addrBook[network].DonationViewer
  );
};
