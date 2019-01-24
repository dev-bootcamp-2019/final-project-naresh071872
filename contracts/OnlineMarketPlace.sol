/*
    This exercise has been updated to use Solidity version 0.5
    Breaking changes from 0.4 to 0.5 can be found here: 
    https://solidity.readthedocs.io/en/v0.5.0/050-breaking-changes.html
*/

pragma solidity ^0.5.0;

contract OnlineMarketPlace {
    
     struct EStore  {
        string name;
       
        address payable storeOwnerAddress;
    }
    struct Product{
        uint productId;
        string name;
        uint unitPrice;
        uint totalQuantity;
    }
    struct StoreOwner{
        string name;
        uint storeCount;
        address payable ownerAddress;
        mapping(uint => EStore) _stores;
    }
    mapping(uint => EStore) public stores;
    mapping(uint => Product[]) public products;
    mapping(address => StoreOwner) public storeOwners;
    mapping (address => bool) public admins;
    
    constructor() public{
       
      
    }
    function addAdmin(address admin) public
    {
        admins[admin]=true;
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
        EStore memory estore =EStore(name,msg.sender);
        stores[storeId] = estore;
       
    }
    
    //They can click on a storefront to manage it.
    //They can add/remove products to the storefront  
    function addProduct(uint storeId,uint productId,string memory name,uint unitPrice,uint totalQuantity) public
    {
        Product memory product = Product(productId,name,unitPrice,totalQuantity);
        products[storeId].push(product);
    }
    function removeProduct(uint storeId,uint productId) public
    {
        delete products[productId];
    }
    //change any of the products’ prices.
    function changePrice(uint storeId,uint productId,uint unitPrice) public
    {
        products[productId].unitPrice = unitPrice;
    }
    //They can also withdraw any funds that the store has collected from sales.
    function withdrawFunds(uint storeId,uint funds) public payable
    {
        stores[storeId].storeOwnerAddress.transfer(funds);
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
        uint totalCost = products[productId].unitPrice * quantity;
        require(msg.value >= totalCost,""); 
        _;
    }
    modifier checkStock(uint storeId,uint productId,uint quantity)
    {
        require (products[productId].totalQuantity>=quantity,"Out-of-Stock"); 
        _;
    }
/**Shoppers can purchase a product, which will debit their account and send it to the store. 
The quantity of the item in the store’s inventory will be reduced by the appropriate amount.*/
    function purchaseProduct(uint storeId,uint productId,uint quantity) public
    checkStock(storeId,productId,quantity) paidEnough(storeId,productId,quantity)
     payable
    {
        
        uint totalPrice = products[productId].unitPrice * quantity;
        stores[storeId].storeOwnerAddress.transfer(totalPrice);
        adjustInventory(storeId,productId,quantity);
    }
    
    function adjustInventory(uint storeId,uint productId,uint quantity) private
    {
        products[productId].totalQuantity = products[productId].totalQuantity - quantity;

    }
}
