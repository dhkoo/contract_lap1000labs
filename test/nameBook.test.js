const { expectRevert, time } = require("@openzeppelin/test-helpers");
const { web3 } = require("@openzeppelin/test-helpers/src/setup");
const NameBook = artifacts.require("NameBook");
const ERC20 = artifacts.require("ERC20");

contract("NameBook Contract Test", (accounts) => {
  beforeEach(async () => {
    token = await ERC20.new(String(100 * 1e18));
    nameBook = await NameBook.new(token.address);

    await token.transfer(accounts[1], String(10 * 1e18));
    await token.transfer(accounts[2], String(10 * 1e18));
    await token.transfer(accounts[3], String(10 * 1e18));
    await token.transfer(accounts[4], String(10 * 1e18));

    await token.approve(nameBook.address, String(10 * 1e18), {
      from: accounts[1],
    });
    await token.approve(nameBook.address, String(10 * 1e18), {
      from: accounts[2],
    });
    await token.approve(nameBook.address, String(10 * 1e18), {
      from: accounts[3],
    });
    await token.approve(nameBook.address, String(10 * 1e18), {
      from: accounts[4],
    });
  });

  it("setName Test", async () => {
    let name = await nameBook.names(accounts[1]);
    console.log(`name: ${name}`);

    await nameBook.setName("alice", { from: accounts[1] });

    name = await nameBook.names(accounts[1]);
    console.log(`name: ${name}`);
  });

  it("removeName Test", async () => {
    await nameBook.setName("alice", { from: accounts[1] });
    let name = await nameBook.names(accounts[1]);
    console.log(`name: ${name}`);

    await nameBook.removeName({ from: accounts[1] });
    name = await nameBook.names(accounts[1]);
    console.log(`name: ${name}`);
  });

  it("require Test", async () => {
    try {
      await nameBook.setName("bob", { from: accounts[5] });
    } catch (err) {
      console.log(`work require well`);
    }
  });

  it("fee Transfer Test", async () => {
    let fee = await nameBook.fee();
    console.log(`fee: ${fee / 1e18}`);
    let bal = await token.balanceOf(accounts[0]);
    console.log(`balance: ${bal / 1e18}`);

    await nameBook.setName("alice", { from: accounts[1] });
    console.log(`> setName`);

    bal = await token.balanceOf(accounts[0]);
    console.log(`balance: ${bal / 1e18}`);

    await nameBook.setFee(0);
    console.log(`fee update`);
    fee = await nameBook.fee();
    console.log(`fee: ${fee}`);

    await nameBook.setName("bob", { from: accounts[5] });
    console.log(`> setName`);

    bal = await token.balanceOf(accounts[0]);
    console.log(`balance: ${bal / 1e18}`);
  });
});
