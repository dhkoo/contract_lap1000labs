const { expectRevert, time } = require("@openzeppelin/test-helpers");
const { web3 } = require("@openzeppelin/test-helpers/src/setup");
const Donation = artifacts.require("Donation");
const ERC20 = artifacts.require("ERC20");

contract("Donation Test", (accounts) => {
  beforeEach(async () => {
    token = await ERC20.new(String(100 * 1e18));
    donation = await Donation.new(token.address);

    await token.transfer(accounts[1], String(10 * 1e18));
    await token.transfer(accounts[2], String(10 * 1e18));
    await token.transfer(accounts[3], String(10 * 1e18));
    await token.transfer(accounts[4], String(10 * 1e18));
    await token.transfer(accounts[5], String(10 * 1e18));

    await token.approve(donation.address, String(10 * 1e18), {
      from: accounts[1],
    });
    await token.approve(donation.address, String(10 * 1e18), {
      from: accounts[2],
    });
    await token.approve(donation.address, String(10 * 1e18), {
      from: accounts[3],
    });
    await token.approve(donation.address, String(10 * 1e18), {
      from: accounts[4],
    });
    await token.approve(donation.address, String(10 * 1e18), {
      from: accounts[5],
    });
  });
  it("Token Donation Test", async () => {
    for (let i = 1; i <= 4; ++i) {
      console.log(`account${i}: ${accounts[i]}`);
    }
    await donation.donatePALA(String(1 * 1e18), { from: accounts[1] });
    await donation.donatePALA(String(2 * 1e18), { from: accounts[2] });
    await donation.donatePALA(String(3 * 1e18), { from: accounts[3] });
    await donation.donatePALA(String(1 * 1e18), { from: accounts[1] });

    let length = await donation.palaTopDonatorLength();
    for (let i = 0; i < length; ++i) {
      let userDonation = await donation.palaTopDonator(i);
      console.log(
        `${userDonation.account} donation: ${String(userDonation.amount)}`
      );
    }
  });

  it("Token Donation Test1", async () => {
    for (let i = 1; i <= 5; ++i) {
      console.log(`account${i}: ${accounts[i]}`);
    }
    await donation.donatePALA(String(1 * 1e18), { from: accounts[1] });
    await donation.donatePALA(String(1 * 1e18), { from: accounts[2] });
    await donation.donatePALA(String(1 * 1e18), { from: accounts[3] });
    await donation.donatePALA(String(1 * 1e18), { from: accounts[4] });
    await donation.donatePALA(String(1 * 1e18), { from: accounts[5] });
    await donation.donatePALA(String(1 * 1e18), { from: accounts[1] });
    await donation.donatePALA(String(1 * 1e18), { from: accounts[2] });

    let length = await donation.palaTopDonatorLength();
    for (let i = 0; i < length; ++i) {
      let userDonation = await donation.palaTopDonator(i);
      console.log(
        `${userDonation.account} donation: ${String(userDonation.amount)}`
      );
    }
  });

  it("Token Donation Dup Test", async () => {
    for (let i = 1; i <= 1; ++i) {
      console.log(`account${i}: ${accounts[i]}`);
    }
    await donation.donatePALA(String(1 * 1e18), { from: accounts[1] });
    await donation.donatePALA(String(1 * 1e18), { from: accounts[1] });

    let length = await donation.palaTopDonatorLength();
    for (let i = 0; i < length; ++i) {
      let userDonation = await donation.palaTopDonator(i);
      console.log(
        `${userDonation.account} donation: ${String(userDonation.amount)}`
      );
    }
  });

  it("Token Donation Test", async () => {
    for (let i = 1; i <= 4; ++i) {
      console.log(`account${i}: ${accounts[i]}`);
    }
    let bal = await token.balanceOf(accounts[0]);
    console.log(String(bal / 1e18));
    await donation.donatePALA(String(1 * 1e18), { from: accounts[1] });
    await donation.donatePALA(String(2 * 1e18), { from: accounts[2] });
    await donation.donatePALA(String(3 * 1e18), { from: accounts[3] });
    await donation.donatePALA(String(1 * 1e18), { from: accounts[1] });

    bal = await token.balanceOf(accounts[0]);
    console.log(String(bal / 1e18));

    let length = await donation.palaTopDonatorLength();
    for (let i = 0; i < length; ++i) {
      let userDonation = await donation.palaTopDonator(i);
      console.log(
        `${userDonation.account} donation: ${String(userDonation.amount)}`
      );
    }
  });

  it("Dup Test", async () => {
    for (let i = 1; i <= 1; ++i) {
      console.log(`account${i}: ${accounts[i]}`);
    }
    await donation.donateKLAY({ from: accounts[1], value: String(1 * 1e18) });
    await donation.donateKLAY({ from: accounts[1], value: String(1 * 1e18) });
    await donation.donateKLAY({ from: accounts[1], value: String(5 * 1e17) });

    let length = await donation.klayTopDonatorLength();
    for (let i = 0; i < length; ++i) {
      let userDonation = await donation.klayTopDonator(i);
      console.log(
        `${userDonation.account} donation: ${String(userDonation.amount)}`
      );
    }
  });

  it("Functional Test", async () => {
    for (let i = 1; i <= 3; ++i) {
      console.log(`account${i}: ${accounts[i]}`);
    }
    await donation.donateKLAY({ from: accounts[1], value: String(1 * 1e18) });
    await donation.donateKLAY({ from: accounts[2], value: String(2 * 1e18) });
    await donation.donateKLAY({ from: accounts[3], value: String(3 * 1e18) });

    let length = await donation.klayTopDonatorLength();
    for (let i = 0; i < length; ++i) {
      let userDonation = await donation.klayTopDonator(i);
      console.log(
        `${userDonation.account} donation: ${String(userDonation.amount)}`
      );
    }
    let bal = String(await web3.eth.getBalance(accounts[0]));
    console.log(parseInt(bal / 1e18));
  });

  it("Multiple Removal Candidate", async () => {
    for (let i = 1; i <= 4; ++i) {
      console.log(`account${i}: ${accounts[i]}`);
    }
    await donation.donateKLAY({ from: accounts[1], value: String(1 * 1e18) });
    await donation.donateKLAY({ from: accounts[1], value: String(1 * 1e18) });
    await donation.donateKLAY({ from: accounts[2], value: String(2 * 1e18) });
    await donation.donateKLAY({ from: accounts[3], value: String(3 * 1e18) });
    await donation.donateKLAY({ from: accounts[4], value: String(2 * 1e18) });

    let length = await donation.klayTopDonatorLength();
    for (let i = 0; i < length; ++i) {
      let userDonation = await donation.klayTopDonator(i);
      console.log(
        `${userDonation.account} donation: ${String(userDonation.amount)}`
      );
    }
  });

  it("Total Amount Test", async () => {
    for (let i = 1; i <= 4; ++i) {
      console.log(`account${i}: ${accounts[i]}`);
    }
    await donation.donateKLAY({ from: accounts[1], value: String(1 * 1e18) });
    await donation.donateKLAY({ from: accounts[2], value: String(2 * 1e18) });
    await donation.donateKLAY({ from: accounts[3], value: String(3 * 1e18) });
    await donation.donateKLAY({ from: accounts[4], value: String(4 * 1e18) });

    let length = await donation.klayTopDonatorLength();
    for (let i = 0; i < length; ++i) {
      let userDonation = await donation.klayTopDonator(i);
      console.log(
        `${userDonation.account} donation: ${String(userDonation.amount)}`
      );
    }
    const totalKlayAmount = await donation.totalKlayAmount();
    console.log(`Total Donation Amount: ${totalKlayAmount / 1e18}`);
  });

  it("Update Dev Address Test", async () => {
    let devAddr = await donation.dev();
    console.log(`Current Dev Addr: ${devAddr}`);
    await donation.setDevAccount(accounts[1]);
    console.log(`> Upadate Dev Addr`);

    devAddr = await donation.dev();
    console.log(`Current Dev Addr: ${devAddr}`);
  });

  it("Dev Receive Donation Test", async () => {
    for (let i = 1; i <= 1; ++i) {
      console.log(`account${i}: ${accounts[i]}`);
    }
    let amount = await web3.eth.getBalance(await donation.dev());
    console.log(`Before: ${amount / 1e18}`);
    await donation.donateKLAY({ from: accounts[1], value: String(1 * 1e18) });
    amount = await web3.eth.getBalance(await donation.dev());
    console.log(`After : ${amount / 1e18}`);
  });
});
