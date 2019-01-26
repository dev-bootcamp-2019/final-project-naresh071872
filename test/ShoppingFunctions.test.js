/*

This test file created to test functionality related to browsing
stores , products and buying products
by shopper 

*/

var OnlineMarketPlace = artifacts.require('OnlineMarketPlace')

contract('OnlineMarketPlace', function(accounts) {

    
    const adminAddress = accounts[1]
    const storeOwnerAddress = accounts[2]
    const withdrawAccount = accounts[3]

    var store="AMAZON"
    
    var name

    it("should browse stores to buy products", async() => {
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
    it("should browse products with provided store", async() => {
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
    it("should buy product with the provided storeId,productId,quantity", async() => {
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
   
});
