const { expectRevert, time } = require("@openzeppelin/test-helpers");
const { web3 } = require("@openzeppelin/test-helpers/src/setup");
const Donation = artifacts.require("Donation");
const palaAddr = "0x7a1cdca99fe5995ab8e317ede8495c07cbf488ad";

contract("Donation Test", (accounts) => {

    beforeEach(async () => {
        donation = await Donation.new(palaAddr);
    });

    it("Functional Test", async () => {
        for (let i = 1; i <= 3; ++i) {
            console.log(`account${i}: ${accounts[i]}`);
        }
        await donation.donateKLAY({from: accounts[1], value: String(1*1e18)});
        await donation.donateKLAY({from: accounts[2], value: String(2*1e18)});
        await donation.donateKLAY({from: accounts[3], value: String(3*1e18)});

        let length = await donation.klayTopDonatorLength();
        for (let i = 0; i < length; ++i) {
            let userDonation = await donation.klayTopDonator(i);
            console.log(`${userDonation.account} donation: ${String(userDonation.amount)}`);
        }
        let bal = String(await web3.eth.getBalance(accounts[0]));
        console.log(parseInt(bal / 1e18));
    });

    it("multiple removal candidate", async () => {
        for (let i = 1; i <= 3; ++i) {
            console.log(`account${i}: ${accounts[i]}`);
        }
        await donation.donateKLAY({from: accounts[1], value: String(1*1e18)});
        await donation.donateKLAY({from: accounts[2], value: String(2*1e18)});
        await donation.donateKLAY({from: accounts[1], value: String(1*1e18)});
        await donation.donateKLAY({from: accounts[3], value: String(3*1e18)});

        let length = await donation.klayTopDonatorLength();
        for (let i = 0; i < length; ++i) {
            let userDonation = await donation.klayTopDonator(i);
            console.log(`${userDonation.account} donation: ${String(userDonation.amount)}`);
        }
    });
});
