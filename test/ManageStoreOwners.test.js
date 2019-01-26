/*

This test file created to test functionality related to creating and deleting
store owners by administrators


*/

var OnlineMarketPlace = artifacts.require('OnlineMarketPlace')

contract('OnlineMarketPlace', function(accounts) {

    
    const adminAddress = accounts[1]
    const storeOwnerAddress = accounts[2]
  

    var owner
    


    it("should add store owner with the provided address", async() => {
        const onlineMarketPlace = await OnlineMarketPlace.deployed()
        const contractOwner =  onlineMarketPlace.owner;
        var eventEmitted = false
        
	
    const tx = await onlineMarketPlace.addStoreOwner(storeOwnerAddress)
	
	if (tx.logs[0].event) {
		owner = tx.logs[0].args._owner.toString(20)
		eventEmitted = true
	}
        
        const result = await onlineMarketPlace.storeOwnerAddressMap.call(storeOwnerAddress)

        assert.equal(result[0], true , 'Passed Address Owner should be added as StoreOwner')
        assert.equal(eventEmitted, true, 'adding an admin should emit LogStoreOwnerAdded event')
    })
    it("should delete storeowner with the provided address", async() => {
        const onlineMarketPlace = await OnlineMarketPlace.deployed()
        
        var eventEmitted = false
        
	
	const tx = await onlineMarketPlace.deleteStoreOwner(storeOwnerAddress)
	
	if (tx.logs[0].event) {
		owner = tx.logs[0].args._owner.toString(20)
		eventEmitted = true
	}
        
        const result = await onlineMarketPlace.storeOwnerAddressMap.call(storeOwnerAddress)

        assert.equal(result[0], false , 'Passed Address Owner should be removed as StoreOwner')
        assert.equal(eventEmitted, true, 'removing an admin should emit LogStoreOwnerDeleted event')
    })
    

});

