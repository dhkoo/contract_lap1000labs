const ConfigYaml = require("config-yaml");
const addrBook = ConfigYaml("../addrBook.yaml");
const Donation = artifacts.require("Donation");
const zero = "0x0000000000000000000000000000000000000000";

module.exports = async function (deployer, network, accounts) {
  const palaAddr = network == "cypress" ? addrBook[network].pala : zero;
  await deployer.deploy(Donation, palaAddr);
};
