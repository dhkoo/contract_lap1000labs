const Donation = artifacts.require("Donation");
const palaAddr = "0x7a1cdca99fe5995ab8e317ede8495c07cbf488ad";

module.exports = async function(deployer, network, accounts) {
  await deployer.deploy(Donation, palaAddr);
};
