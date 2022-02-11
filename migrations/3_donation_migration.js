const Donation = artifacts.require("Donation");
const palaAddr= "0x7a1cdca99fe5995ab8e317ede8495c07cbf488ad";
const zero = "0x0000000000000000000000000000000000000000";

module.exports = async function(deployer, network, accounts) {
  const pala = network == "cypress" ? palaAddr : zero;
  await deployer.deploy(Donation, palaAddr);
};
