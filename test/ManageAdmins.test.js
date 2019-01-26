/*

This test file created to test functionality related to creating administrators to manage
storeowners
Test cases include add/remove addresses as administrators by contract owner
*/

var OnlineMarketPlace = artifacts.require('OnlineMarketPlace')

contract('OnlineMarketPlace', function(accounts) {

    
    const adminAddress = accounts[1]
    const storeOwnerAddress = accounts[2]
  

    var owner
    

    it("should add administrator with the provided address", async() => {
        const onlineMarketPlace = await OnlineMarketPlace.deployed()
        const contractOwner =  onlineMarketPlace.owner;
        var eventEmitted = false
        
	
	const tx = await onlineMarketPlace.addAdmin(adminAddress)
	
	if (tx.logs[0].event) {
		owner = tx.logs[0].args._owner.toString(20)
		eventEmitted = true
	}
        
        const result = await onlineMarketPlace.adminAddressMap.call(adminAddress)

        assert.equal(result[0], true , 'Passed Address Owner should be added as Administrator')
        assert.equal(eventEmitted, true, 'adding an admin should emit LogAdminAdded event')
    })
    it("should delete administrator with the provided address", async() => {
        const onlineMarketPlace = await OnlineMarketPlace.deployed()
        const contractOwner =  onlineMarketPlace.owner;
        var eventEmitted = false
        
	
	const tx = await onlineMarketPlace.deleteAdmin(adminAddress)
	
	if (tx.logs[0].event) {
		owner = tx.logs[0].args._owner.toString(20)
		eventEmitted = true
	}
        
        const result = await onlineMarketPlace.adminAddressMap.call(adminAddress)

        assert.equal(result[0], false , 'Passed Address Owner should be removed as Administrator')
        assert.equal(eventEmitted, true, 'removing an admin should emit LogAdminDeleted event')
    })
    

});
