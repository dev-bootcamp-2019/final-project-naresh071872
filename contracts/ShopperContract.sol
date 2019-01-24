pragma solidity ^0.5.0;

import "./DataStoreContract.sol";
/** 
A shopper logs into the app. 
The web app does not recognize their address so they are shown the generic shopper application. 
*/

contract ShopperContract is DataStoreContract{
  

    constructor() public
    {

    }
    /**
//From the main page they can browse all of the storefronts that have been created in the marketplace. 
    function browseStores() public returns ( mapping(uint => EStore) memory) 
    {
        return stores;
    }
/**     Clicking on a storefront will take them to a product page. 
They can see a list of products offered by the store, including their price and quantity. 

    function browseProducts(uint storeId) public returns ( mapping(uint => Product) memory)
    {
        return stores[storeId].products;
    }*/
    
    modifier paidEnough(uint storeId,uint productId,uint quantity) 
    { 
        uint totalCost = stores[storeId].products[productId].unitPrice * quantity;
        require(msg.value >= totalCost,""); 
        _;
    }
    modifier checkStock(uint storeId,uint productId,uint quantity)
    {
        require (stores[storeId].products[productId].totalQuantity>=quantity,"Out-of-Stock"); 
        _;
    }
/**Shoppers can purchase a product, which will debit their account and send it to the store. 
The quantity of the item in the store’s inventory will be reduced by the appropriate amount.*/
    function purchaseProduct(uint storeId,uint productId,uint quantity) public
    checkStock(storeId,productId,quantity) paidEnough(storeId,productId,quantity)
     payable
    {
        
        uint totalPrice = stores[storeId].products[productId].unitPrice * quantity;
        stores[storeId].storeOwnerAddress.transfer(totalPrice);
        adjustInventory(storeId,productId,quantity);
    }
    
    function adjustInventory(uint storeId,uint productId,uint quantity) private
    {
        stores[storeId].products[productId].totalQuantity = stores[storeId].products[productId].totalQuantity - quantity;

    }
}