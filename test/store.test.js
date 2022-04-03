const { expectRevert, time } = require("@openzeppelin/test-helpers");
const { web3 } = require("@openzeppelin/test-helpers/src/setup");
const Proxy = artifacts.require("Proxy");
const Store = artifacts.require("Store");
const StoreViewer = artifacts.require("StoreViewer");
const TestNFT = artifacts.require("TestNFT");
const BN = web3.utils.BN;

contract("Store Test", ([dev, seller1, seller2, buyer]) => {
  beforeEach(async () => {
    storeLogic = await Store.new();
    storeProxy = await Proxy.new();
    await storeProxy.upgrade(storeLogic.address);

    store = await Store.at(storeProxy.address);
    await store.initialize(
      dev,
      300, // defaultFeeRatio
      100, // premiumFeeRatio
      2, // GCCount
      10 // GCMaxIter
    );

    viewer = await StoreViewer.new(storeProxy.address);
    testNFT = await TestNFT.new();

    await testNFT.mint(seller1, "");
    await testNFT.mint(seller1, "");
    await testNFT.mint(seller1, "");

    await testNFT.mint(seller2, "");
    await testNFT.mint(seller2, "");
    await testNFT.mint(seller2, "");

    await testNFT.setApprovalForAll(store.address, true, {
      from: seller1,
    });
    await testNFT.setApprovalForAll(store.address, true, {
      from: seller2,
    });
  });

  it("list()", async () => {
    const price = String(1e18);
    const expiredBlockNumber = 100000;
    await store.list(testNFT.address, 1, price, expiredBlockNumber, {
      from: seller1,
    });
    assert.equal(
      seller1,
      await store.itemSeller(testNFT.address, 1),
      "NOT_SELLER"
    );
    const item = await store.userListItems(seller1, 0);
    assert.equal(item.token, testNFT.address, "MISMATCH_TOKEN");
    assert.equal(item.tokenId, 1, "MISMATCH_TOKEN_ID");
    assert.equal(item.price, price, "MISMATCH_PRICE");
  });

  it("cancelList()", async () => {
    const price = String(1e18);
    const expiredBlockNumber = (await web3.eth.getBlockNumber()) + 3600;
    await store.list(testNFT.address, 1, price, expiredBlockNumber, {
      from: seller1,
    });

    await store.cancelList(testNFT.address, 1, { from: seller1 });
    assert.equal(0, await store.userListItemsCount(seller1), "EXIST_LIST");
  });

  it("buy()", async () => {
    const price = String(1e18);
    const expiredBlockNumber = (await web3.eth.getBlockNumber()) + 3600;
    await store.list(testNFT.address, 1, price, expiredBlockNumber, {
      from: seller1,
    });

    await store.buy(testNFT.address, 1, price, {
      from: buyer,
      value: price,
    });

    assert.equal(0, await store.userListItemsCount(seller1), "EXIST_LIST");

    assert.equal(buyer, await testNFT.ownerOf(1), "NOT_ONWER");
    assert.notEqual(seller1, await testNFT.ownerOf(1), "NOT_TRANSFERED");
  });

  it("fee", async () => {
    const price = String(1e18);
    const expiredBlockNumber = (await web3.eth.getBlockNumber()) + 3600;
    await store.list(testNFT.address, 1, price, expiredBlockNumber, {
      from: seller1,
    });

    const sellerBalBefore = await web3.eth.getBalance(seller1);
    const devBalBefore = await web3.eth.getBalance(dev);

    await store.buy(testNFT.address, 1, price, {
      from: buyer,
      value: price,
    });

    const sellerBalAfter = await web3.eth.getBalance(seller1);
    const devBalAfter = await web3.eth.getBalance(dev);

    const feeRatio = await store.defaultFeeRatio();
    const fee = new BN(price).mul(feeRatio).div(new BN(1e4));
    assert.equal(
      String(new BN(sellerBalAfter).sub(new BN(sellerBalBefore))),
      String(new BN(price).sub(fee))
    );
    assert.equal(
      String(new BN(devBalAfter).sub(new BN(devBalBefore))),
      String(new BN(fee))
    );
  });
});
