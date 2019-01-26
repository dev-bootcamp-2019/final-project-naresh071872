/*

This test file created to test functionality related to creating stores,products
and update product price by store owner for good shopping experience
for buyers

*/

var OnlineMarketPlace = artifacts.require('OnlineMarketPlace')

contract('OnlineMarketPlace', function(accounts) {

    
    const adminAddress = accounts[1]
    const storeOwnerAddress = accounts[2]
    const withdrawAccount = accounts[3]

    var store="AMAZON"
    
    var name

    it("should add stores with the provided name", async() => {
        const onlineMarketPlace = await OnlineMarketPlace.deployed()
        const contractOwner =  onlineMarketPlace.owner;
        var eventEmitted = false
        
	
    const tx = await onlineMarketPlace.addStore(store)
	
	if (tx.logs[0].event) {
		name = tx.logs[0].args._name.toString(20)
		eventEmitted = true
	}
        
        const result = await onlineMarketPlace.stores.call(1)

        assert.equal(result[0].name, name , 'Passed Store should be added')
        assert.equal(eventEmitted, true, 'adding store should emit LogAddStore event')
    })
    it("should delete stores with the provided storeId", async() => {
        const onlineMarketPlace = await OnlineMarketPlace.deployed()
        const contractOwner =  onlineMarketPlace.owner;
        var eventEmitted = false
        
	
    const tx = await onlineMarketPlace.deleteStore(store)
	
	if (tx.logs[0].event) {
		name = tx.logs[0].args._name.toString(20)
		eventEmitted = true
	}
        
        const result = await onlineMarketPlace.stores.call(1)

        assert.equal(result[0].name, name , 'Passed Store should be added')
        assert.equal(eventEmitted, true, 'adding an admin should emit LogDeleteStore event')
    })
    it("should add product with the provided storeId,productname,unitPrice,quantity", async() => {
        const onlineMarketPlace = await OnlineMarketPlace.deployed()
        
        var eventEmitted = false
        var name="SHAMPOO";
        var storeId=1;
        var unitPrice=12;
        var quantity=200;
        
    const tx = await onlineMarketPlace.addProduct(storeId,name,unitPrice,quantity)
	
	if (tx.logs[0].event) {
		storeId = tx.logs[0].args._storeId.toString(20)
		eventEmitted = true
	}
        
        const result = await onlineMarketPlace.store[1].product[2].call(1)

        assert.equal(result[0].name, name , 'Passed Product should be added to a specific store')
        assert.equal(eventEmitted, true, 'adding store should emit LogAddProduct event')
    })
    it("should delete product with the provided storeId,productId", async() => {
        const onlineMarketPlace = await OnlineMarketPlace.deployed()
        const contractOwner =  onlineMarketPlace.owner
        var eventEmitted = false
        var storeId=1
        var productId=1
	
    const tx = await onlineMarketPlace.deleteProduct(storeId,productId)
	
	if (tx.logs[0].event) {
		productId = tx.logs[0].args._productId.toString(20)
		eventEmitted = true
	}
        
        const result = await onlineMarketPlace.stores[1].product[1].call(1)

        assert.equal(result[0].name, name , 'Passed Product should be deleted')
        assert.equal(eventEmitted, true, 'deleting a product  should emit LogDeleteProduct event')
    })
    it("should update price with provided storeId,productId and updatedPricetr", async() => {
        const onlineMarketPlace = await OnlineMarketPlace.deployed()
        const contractOwner =  onlineMarketPlace.owner
        var eventEmitted = false
        var storeId=1
        var productId=1
        var updatedPrice=22
	
    const tx = await onlineMarketPlace.updatePrice(storeId,productId,updatedPrice)
	
	if (tx.logs[0].event) {
		productId = tx.logs[0].args._productId.toString(20)
		eventEmitted = true
	}
        
        const result = await onlineMarketPlace.stores[1].product[1].call(1)

        assert.equal(result[0].unitPrice, updatedPrice , 'Passed Unit Price should be updated')
        assert.equal(eventEmitted, true, 'updating product price should emit LogUpdatePrice event')
    })
    it("should withdraw funds with provided account and funds", async() => {
        const onlineMarketPlace = await OnlineMarketPlace.deployed()
        const contractOwner =  onlineMarketPlace.owner
        var eventEmitted = false
   
        var funds=10
      
	
    const tx = await onlineMarketPlace.withdrawFund(withdrawAccount,funds)
	
	if (tx.logs[0].event) {
		funds = tx.logs[0].args._funds.toString(20)
		eventEmitted = true
	}
        
        const result = await onlineMarketPlace.eth.balances[withdrawAccount][1].call(1)

        assert.equal(result[0].unitPrice, updatedPrice , 'Funds should withdraw')
        assert.equal(eventEmitted, true, 'withdraw funds from stores should emit LogWithdrawFunds event')
    })
});
