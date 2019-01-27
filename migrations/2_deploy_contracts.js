
var OnlineMarketPlace = artifacts.require('./OnlineMarketPlace.sol')
var AccessRestriction = artifacts.require('./AccessRestriction.sol')
module.exports = function(deployer) {
  deployer.deploy(OnlineMarketPlace);
  deployer.deploy(AccessRestriction);

  
};
