pragma solidity ^0.5.0;
import "./DataStoreContract.sol";
//An administrator opens the web app. 
/**, 
 such as managing store owners. , so if the owner of that address logs into the app, they have access to the store owner functions.
*/

/** @title Admin Contract */
contract AdminContract is DataStoreContract{
    mapping (address => bool) admins;
    
    constructor() public{
        admins[0xc2bFa544Ba80BD4Be5E09B87B7f68880196D1bD5]=true;
        admins[0x9bd8Ae4E329561918Cfc650d13736BB120265C46]=true;
    }
    //The web app reads the address and identifies that the user is an admin
    //showing them admin only functions,
    function identityAsAdmin() public view 
    {
        require(admins[msg.sender]==true,"Provided user is not administrator");
    }
    //An admin adds an address to the list of approved store owners
    function addStoreOwner(address payable _owner) public 
    {
        storeOwners[_owner] = StoreOwner("",0,_owner);
    }
}