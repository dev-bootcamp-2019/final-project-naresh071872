pragma solidity ^0.5.0;
import "./DataStoreContract.sol";

contract StoreOwnerContract is DataStoreContract
{

    constructor() public
    {
   
    }
    /**An approved store owner logs into the app. 
    The web app recognizes their address and identifies them as a store owner. 
    They are shown the store owner functions.*/

    function approveOwner() public view returns (bool)
    {
        return storeOwners[msg.sender].ownerAddress == msg.sender;
    }
    //They can create a new storefront that will be displayed on the marketplace. 
    function addStore(uint storeId,string memory name) public
    {
        storeOwners[msg.sender].storeCount++;
        stores[storeId] = EStore(name,msg.sender);
       
    }
    
    //They can click on a storefront to manage it.
    //They can add/remove products to the storefront  
    function addProduct(uint storeId,uint productId,string memory name,uint unitPrice,uint totalQuantity) public
    {
        Product memory product = Product(name,unitPrice,totalQuantity);
        stores[storeId].products[productId] = product;
    }
    function removeProduct(uint storeId,uint productId) public
    {
        delete stores[storeId].products[productId];
    }
    //change any of the products’ prices.
    function changePrice(uint storeId,uint productId,uint unitPrice) public
    {
        stores[storeId].products[productId].unitPrice = unitPrice;
    }
    //They can also withdraw any funds that the store has collected from sales.
    function withdrawFunds(uint storeId,uint funds) public payable
    {
        stores[storeId].storeOwnerAddress.transfer(funds);
    }
}