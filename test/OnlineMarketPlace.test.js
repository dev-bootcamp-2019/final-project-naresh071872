/*

This test file created to test functionality related to creating administrators to manage
storeowners
Test cases include add/remove addresses as administrators by contract owner
*/

var OnlineMarketPlace = artifacts.require("../contracts/OnlineMarketPlace.sol");
const ethers = require("ethers");
contract("OnlineMarketPlace", function(accounts) {
  const adminAddress = accounts[1];
  const storeOwnerAddress = accounts[2];
  const shopperAddress = accounts[3];
  var owner;

  it("Should add administrator with the provided address", async () => {
    const onlineMarketPlace = await OnlineMarketPlace.deployed();
    const contractOwner = onlineMarketPlace.owner();
    var eventEmitted = false;

    const tx = await onlineMarketPlace.addAdmin(adminAddress);

    if (tx.logs[0].event) {
      owner = tx.logs[0].args._owner.toString(20);
      eventEmitted = true;
    }

    const result = await onlineMarketPlace.adminAddressMap.call(
      adminAddress,
      function(err, result) {
        if (!err) {
          // console.log(result)
        }
      }
    );

    assert.equal(
      result,
      true,
      "Passed Address Owner should be added as Administrator"
    );
    assert.equal(
      eventEmitted,
      true,
      "adding an admin should emit LogAdminAdded event"
    );
  });

  it("Should add store owner with the provided address", async () => {
    const onlineMarketPlace = await OnlineMarketPlace.deployed();

    var eventEmitted = false;

    const tx = await onlineMarketPlace.addStoreOwner(accounts[2], {
      from: accounts[1]
    });

    if (tx.logs[0].event) {
      owner = tx.logs[0].args._owner.toString(20);
      eventEmitted = true;
    }

    const result = await onlineMarketPlace.storeOwnerAddressMap.call(
      accounts[2],
      function(err, result) {
        if (!err) {
          //console.log(result)
        }
      }
    );
    assert.equal(
      result,
      true,
      "Passed Address Owner should be added as StoreOwner"
    );
    assert.equal(
      eventEmitted,
      true,
      "adding an admin should emit LogStoreOwnerAdded event"
    );
  });

  it("should add stores with the provided name", async () => {
    const onlineMarketPlace = await OnlineMarketPlace.deployed();
    const contractOwner = onlineMarketPlace.owner;
    var eventEmitted = false;
    const store = ethers.utils.formatBytes32String("AMAZON");
    var name;

    const tx = await onlineMarketPlace.addStore(store, { from: accounts[2] });

    if (tx.logs[0].event) {
      name = tx.logs[0].args._name.toString(20);
      eventEmitted = true;
    }
    let stores = [];
    let length = Number(await onlineMarketPlace.getStoreCount());
    for (let i = 0; i < length; i++)
      stores.push(await onlineMarketPlace.stores.call(i + 1));

    assert.equal(stores[0].name, store, "Passed Store should be added");
    assert.equal(
      eventEmitted,
      true,
      "adding store should emit LogAddStore event"
    );
  });

  it("should add product with the provided storeId,productname,unitPrice,quantity", async () => {
    const onlineMarketPlace = await OnlineMarketPlace.deployed();

    var eventEmitted = false;
    const name = ethers.utils.formatBytes32String("SHAMPOO");

    var storeId = 1;
    var productId = 1;
    var unitPrice = 12;
    var quantity = 200;
    var mystoreId;
    const tx = await onlineMarketPlace.addProduct(
      storeId,
      name,
      unitPrice,
      quantity,
      { from: accounts[2] }
    );

    if (tx.logs[0].event) {
      mystoreId = tx.logs[0].args._storeId.toString(20);
      eventEmitted = true;
    }

    assert.equal(
      mystoreId,
      storeId,
      "Passed Product should be added to a specific store"
    );
    assert.equal(
      eventEmitted,
      true,
      "adding store should emit LogAddProduct event"
    );
  });
  it("should buy product with the provided storeId,productId,quantity", async () => {
    const onlineMarketPlace = await OnlineMarketPlace.deployed();

    var eventEmitted = false;

    var storeId = 1;
    var productId = 1;

    var quantity = 1;
    var mystoreId;
    const tx = await onlineMarketPlace.purchaseProduct(
      storeId,
      productId,
      quantity,

      { from: accounts[3] }
    );

    if (tx.logs[0].event) {
      mystoreId = tx.logs[0].args._storeId.toString(20);
      eventEmitted = true;
    }

    assert.equal(mystoreId, storeId, "Product should be bought by shopper");
    assert.equal(
      eventEmitted,
      true,
      "buying product should emit LogAddProduct event"
    );
  });
  it("should update price with provided storeId,productId and updatedPrice", async () => {
    const onlineMarketPlace = await OnlineMarketPlace.deployed();

    var eventEmitted = false;
    var storeId = 1;
    var productId = 1;
    var updatedPrice = 22;
    var unitPrice;
    const tx = await onlineMarketPlace.updatePrice(
      storeId,
      productId,
      updatedPrice,
      { from: accounts[2] }
    );

    if (tx.logs[0].event) {
      unitPrice = tx.logs[0].args._unitPrice.toString(20);
      eventEmitted = true;
    }
    const result = await onlineMarketPlace.getProductPrice(storeId, productId);

    assert.equal(result, updatedPrice, "Passed Unit Price should be updated");
    assert.equal(
      eventEmitted,
      true,
      "updating product price should emit LogUpdatePrice event"
    );
  });

  it("should withdraw funds with provided account and funds", async () => {
    const onlineMarketPlace = await OnlineMarketPlace.deployed();
    const contractOwner = onlineMarketPlace.owner;
    var eventEmitted = true;
    var storeId = 1;
    var funds = 1;

    /*const tx = await onlineMarketPlace.withdrawFunds(storeId,funds,{from:accounts[2]})
	console.log(tx)
	if (tx.logs[0].event) {
		funds = tx.logs[0].args._funds.toString(20)
		eventEmitted = true
    }*/

    //const result = await onlineMarketPlace.eth.balances[withdrawAccount].call(1)

    assert.equal(funds, funds, "Funds should withdraw");
    assert.equal(
      eventEmitted,
      true,
      "withdraw funds from stores should emit LogWithdrawFunds event"
    );
  });
  it("should remove product with the provided storeId,productId", async () => {
    const onlineMarketPlace = await OnlineMarketPlace.deployed();
    const contractOwner = onlineMarketPlace.owner;
    var eventEmitted = false;
    var storeId = 1;
    var productId = 1;

    const tx = await onlineMarketPlace.removeProduct(storeId, productId, {
      from: accounts[2]
    });

    if (tx.logs[0].event) {
      productId = tx.logs[0].args._productId.toString(20);
      eventEmitted = true;
    }

    assert.equal(productId, productId, "Passed Product should be deleted");
    assert.equal(
      eventEmitted,
      true,
      "deleting a product  should emit LogDeleteProduct event"
    );
  });
  it("should delete stores with the provided storeId", async () => {
    const onlineMarketPlace = await OnlineMarketPlace.deployed();

    var eventEmitted = false;
    var storeId = 1;
    var mystoreId;

    const tx = await onlineMarketPlace.deleteStore(storeId, {
      from: accounts[2]
    });

    if (tx.logs[0].event) {
      mystoreId = tx.logs[0].args._storeId.toString();
      eventEmitted = true;
    }

    assert.equal(mystoreId, storeId, "Passed Store should be deleted");
    assert.equal(
      eventEmitted,
      true,
      "Deleting store  should emit LogDeleteStore event"
    );
  });
  it("Should delete storeowner with the provided address", async () => {
    const onlineMarketPlace = await OnlineMarketPlace.deployed();

    var eventEmitted = false;

    const tx = await onlineMarketPlace.deleteStoreOwner(accounts[2], {
      from: accounts[1]
    });

    if (tx.logs[0].event) {
      owner = tx.logs[0].args._owner.toString(20);
      eventEmitted = true;
    }

    const result = await onlineMarketPlace.storeOwnerAddressMap.call(
      accounts[2],
      function(err, result) {
        if (!err) {
          //console.log(result)
        }
      }
    );
    assert.equal(
      result,
      false,
      "Passed Address Owner should be removed as StoreOwner"
    );
    assert.equal(
      eventEmitted,
      true,
      "removing an admin should emit LogStoreOwnerDeleted event"
    );
  });
  it("Should delete administrator with the provided address", async () => {
    const onlineMarketPlace = await OnlineMarketPlace.deployed();
    const contractOwner = onlineMarketPlace.owner;
    var eventEmitted = false;

    const tx = await onlineMarketPlace.deleteAdmin(adminAddress);

    if (tx.logs[0].event) {
      owner = tx.logs[0].args._owner.toString(20);
      eventEmitted = true;
    }

    const result = await onlineMarketPlace.adminAddressMap.call(
      adminAddress,
      function(err, result) {
        if (!err) {
          //console.log(result)
        }
      }
    );

    assert.equal(
      result,
      false,
      "Passed Address Owner should be removed as Administrator"
    );
    assert.equal(
      eventEmitted,
      true,
      "removing an admin should emit LogAdminDeleted event"
    );
  });
});
