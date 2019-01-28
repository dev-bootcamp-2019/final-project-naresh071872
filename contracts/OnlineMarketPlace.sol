pragma solidity ^0.5.0;

import "./AccessRestriction.sol";
import "./SafeMath.sol";
/* @title OnlineMarketPlace
* @author Naresh Saladi
* @notice Final Project - Consensys Training
*/
contract OnlineMarketPlace is AccessRestriction {
 
    bool public stopped = false;
     address[] public administrators;
     address[] public storeOwners;
     mapping(address => bool) public adminAddressMap;  
     mapping(address => bool) public storeOwnerAddressMap;  
     struct Product{
        uint productId;
        bytes32 name;
        uint unitPrice;
        uint totalQuantity;
        uint productSales;
    }
     struct Store  {
        bytes32 name;
        uint productsCount;
        uint storeSales;
        address payable owner;
        mapping(uint => Product) products;
    }
    
    mapping(uint => Store) public stores;
    
    uint storeCount;
    uint adminCount;
    uint storeOwnerCount;
    
     //Events
     event LogAdminAdded(address _owner);
     event LogAdminDeleted(address _owner);
      event LogStoreOwnerAdded(address _owner);
     event LogStoreOwnerDeleted(address _owner);
     
     event LogAddStore(uint _storeId,bytes32 _name);
     event LogDeleteStore(uint _storeId);
   
     event LogProductAdded(uint _storeId,bytes32 _name,uint _unitPrice,uint _totalQuantity);
     event LogProductRemoved(uint _storeId,uint _productId);
     event LogUpdatePrice(uint _storeId,uint _productid,uint _unitPrice);
     event LogWithdrawFunds(uint _storeId,uint _funds);
     
     event LogProductBought(uint _storeId,uint _productId,uint _quantity);
     event LogInventoryAdjustment(uint _storeId,uint _productId,uint _quantity);
     event LogProductQtyUpdated(uint _productId,uint _newQuantity,uint oldQty);
     /* @dev modifier checks owner is contract owner
    * @param _owner address of next administrator
    */
    modifier restrictContractOwner() 
    {
       
        require(owner == msg.sender,"Provided user is not contract owner");
        _;
    }
    /* @dev adds given ethereum address as administrator
    * @param _owner address of next administrator
    */
     function addAdmin(address _owner) public restrictContractOwner()
    {
        adminAddressMap[_owner]=true;
        administrators.push(_owner);
        emit LogAdminAdded(_owner);
    }
    /* @dev removes given ethereum address as administrator
    * @param _owner address of next administrator
    */
     function deleteAdmin(address _owner) public restrictContractOwner()
    {
        delete adminAddressMap[_owner];
        uint _adminCount = administrators.length;
        for(uint i = 0; i < _adminCount; i++) {
            if (administrators[i] == _owner) {
                administrators[i] = administrators[_adminCount-1];
                delete administrators[_adminCount-1];
                administrators.length --;
                break;
            }
        }
        emit LogAdminDeleted(_owner);
    }
    /* @dev modifier checks owner is contract owner
    * @param _owner address of next administrator
    */
    modifier restrictAdmin() 
    {
        require(adminAddressMap[msg.sender],"Provided user is not administrator");
        _;
    }
     /* @dev adds given ethereum address as storeowner
    * @param _owner address of storeowner
    */
     function addStoreOwner(address _owner) public restrictAdmin()
    {
        storeOwnerAddressMap[_owner]=true;
        storeOwners.push(_owner);
        emit LogStoreOwnerAdded(_owner);
    }
    /* @dev removes given ethereum address as storeOwner
    * @param _owner address of store owner
    */
     function deleteStoreOwner(address _owner) public restrictAdmin()
    {
        delete storeOwnerAddressMap[_owner];
         uint ownerCount = storeOwners.length;
        for(uint i = 0; i < ownerCount; i++) {
            if (storeOwners[i] == _owner) {
                storeOwners[i] = storeOwners[ownerCount-1];
                delete storeOwners[ownerCount-1];
                storeOwners.length --;
                break;
            }
        }
        emit LogStoreOwnerDeleted(_owner);
    }
    /* @dev modifier checks owner is storeowner
    */
    modifier restrictStoreOwner() 
    {
        require(storeOwnerAddressMap[msg.sender],"Provided user is not storeOwner");
        _;
    }
    

    modifier stopInEmergency { require(!stopped); _; }
    modifier onlyInEmergency { require(stopped); _; }

   
    constructor() public{
      
        adminAddressMap[msg.sender] = true;
        administrators.push(msg.sender);
    }
    
    /* @dev create a new storefront that will be displayed on the marketplace
     * @param name store name 
     * @returns storeId id of store
    */
    
    function addStore(bytes32 _name) public restrictStoreOwner() returns (uint)
    {
        storeCount =SafeMath.add(storeCount,1);
        stores[storeCount] = Store(_name,0,0,msg.sender);
        emit LogAddStore(storeCount,_name);
        return storeCount;
       
    }
    /* @dev delete a store that will be removed from the marketplace
    * @param _storeId identifier of a store
    */
     function deleteStore(uint _storeId) public restrictStoreOwner() returns (uint)
    {
        storeCount--;
        delete stores[_storeId];
        emit LogDeleteStore(_storeId);
        return _storeId;
       
    }
 
    /* @dev add a product to a specific store 
    * @param _storeId identifier of a store
      * @param _name name of product
       * @param _unitPrice price of product
        * @param _totalQuantity total inventory of product available
         
    */
    function addProduct(uint _storeId,bytes32 _name,uint _unitPrice,uint _totalQuantity) public restrictStoreOwner() returns (uint)
    {
        stores[_storeId].productsCount= SafeMath.add(stores[_storeId].productsCount,1);
        uint productId = stores[_storeId].productsCount;
        Product memory product = Product(productId,_name,_unitPrice,_totalQuantity,0);
        stores[_storeId].products[productId] = product;
        emit LogProductAdded(_storeId,_name,_unitPrice,_totalQuantity);
        return  productId;
    }
      /* @dev remove a product from  a specific store 
    * @param _storeId identifier of a store
      * @param _productId identifier of a product
    
    */
    function removeProduct(uint _storeId,uint _productId) public restrictStoreOwner() 
    {
        stores[_storeId].productsCount--;
        delete stores[_storeId].products[_productId];
        emit LogProductRemoved(_storeId,_productId);
    }
    
       /* @dev change any of the products’ prices.
    * @param _storeId identifier of a store
      * @param _productId identifier of a product
    * @param _newUnitPrice new unit price of a product
    */
    function updatePrice(uint _storeId,uint _productId,uint _newUnitPrice) public restrictStoreOwner() 
    {
        stores[_storeId].products[_productId].unitPrice = _newUnitPrice;
        emit LogUpdatePrice(_storeId,_productId,stores[_storeId].products[_productId].unitPrice);
    }
  
    /* @dev withdraw any funds that the store has collected from sales
    * @param _storeId identifier of a store
      * @param _funds  funds need to be withdraw from store balance
    */
    function withdrawFunds(uint _storeId,uint _funds) public payable onlyInEmergency() //checkAvailFunds(_storeId,_funds)
    {
        
        stores[_storeId].storeSales = SafeMath.sub(stores[_storeId].storeSales,_funds);
        emit LogWithdrawFunds(_storeId,_funds);
    }
    /* @dev check availability funds
    * @param _storeId identifier of a store
      * @param _funds  funds need to be withdraw from store balance
    */
    modifier checkAvailFunds(uint _storeId,uint _funds) {
        require(stores[_storeId].storeSales>=_funds,"Funds plan to withdraw is more than Store Balance");
        _;
    }


       /* @dev check whether buyer has enough funds 
    * @param _storeId identifier of a store
      * @param _productId identifier of a product
    * @param quantity product quantity
    */
    modifier buyerEnoughFunds(uint storeId,uint productId,uint quantity) 
    { 
        
        uint totalCost = stores[storeId].products[productId].unitPrice * (quantity);
        require(msg.sender.balance >= totalCost,"Buyer doesn't have enought balance"); 
        _;
    }
      /* @dev check product inventory .
    * @param _storeId identifier of a store
      * @param _productId identifier of a product
    * @param quantity product quantity
    */
    modifier checkStock(uint storeId,uint productId,uint quantity)
    {
        require (stores[storeId].products[productId].totalQuantity>=quantity,"Out-of-Stock"); 
        _;
    }

   /* @dev buy product .
    * @param _storeId identifier of a store
      * @param _productId identifier of a product
    * @param quantity product quantity
    */
    function purchaseProduct(uint _storeId,uint _productId,uint _quantity) public
    checkStock(_storeId,_productId,_quantity) buyerEnoughFunds(_storeId,_productId,_quantity) stopInEmergency()
     payable
    {
        
        uint totalAmount = stores[_storeId].products[_productId].unitPrice * _quantity;
       
        adjustInventory(_storeId,_productId,_quantity);
        stores[_storeId].products[_productId].productSales =SafeMath.add(stores[_storeId].products[_productId].productSales,totalAmount);
        stores[_storeId].storeSales = SafeMath.add(stores[_storeId].storeSales,totalAmount);
        emit LogProductBought(_storeId,_productId,_quantity);
    }
    /* @dev inventory will be reduced .
    * @param _storeId identifier of a store
      * @param _productId identifier of a product
    * @param quantity product quantity
    */
    function adjustInventory(uint _storeId,uint _productId,uint _quantity) private
    {
        stores[_storeId].products[_productId].totalQuantity -= _quantity;
        emit LogInventoryAdjustment(_storeId,_productId,_quantity);

    }
    function getStoreCount() external view returns(uint)
    {
        return storeCount;
    }
    function getProductCount(uint storeId) external view returns(uint)
    {
        return stores[storeId].productsCount;
    }
    function getProductPrice(uint storeId,uint productId)  public view returns (uint)
{
    return stores[storeId].products[productId].unitPrice;
}   
 function getAdministrators()
    public
    view
    returns(address[] memory) {
        uint _adminCount = administrators.length;
        address[] memory admins = new address[](_adminCount);
        for (uint i = 0; i < _adminCount; i++) {
            admins[i] = administrators[i];
        }
        return admins;
    }

  /** @dev Get a list of all the store owners.
    * @return owners The array of all the store owners address.
    */
    function getStoreOwners()
    public
    view
    returns(address[] memory) {
        uint _storeOwnerCount = storeOwners.length;
        address[] memory owners = new address[](_storeOwnerCount);
        for (uint i = 0; i < _storeOwnerCount; i++) {
            owners[i] = storeOwners[i];
        }
        return owners;
    }
    
    function getStores(address storeOwner)
    public
    view
    returns(uint[]  memory ,bytes32[] memory, uint[] memory) {
        
        uint[] memory storeIds = new uint[](storeCount);
        bytes32[] memory names = new bytes32[](storeCount);
        uint[] memory storeSales = new uint[](storeCount);
       
        for(uint i = 0; i < storeCount; i++) {
            if (stores[i].owner != storeOwner)
            continue;
            storeIds[i] = i;
            names[i] = stores[i].name;
            storeSales[i] = stores[i].storeSales;
            
        }
        return (storeIds, names, storeSales);
    }
    function getStores()
    public
    view
    returns(uint[]  memory ,bytes32[] memory, address[] memory) {
        
        uint[] memory storeIds = new uint[](storeCount);
        bytes32[] memory names = new bytes32[](storeCount);
        address[] memory owners = new address[](storeCount);
       
       
        for(uint i = 0; i < storeCount; i++) {
            storeIds[i] = i;
            names[i] = stores[i].name;
            owners[i] = stores[i].owner;
            
        }
        return (storeIds, names, owners);
    }
    /** @dev Get the inventory for a specific store.
    * @param _storeId The storefront ID.
    * @return (itemIds, itemNames, itemQuantities, itemPrices) The Id, name, quantity and price for each Item.
    */
    function getProductCatalog(uint _storeId)
    public
    view
    returns(uint[] memory, bytes32[] memory, uint[] memory, uint[] memory)
    {
        uint _productCount= stores[_storeId].productsCount;
        
        uint[] memory itemIds = new uint[](_productCount);
        bytes32[] memory itemNames = new bytes32[](_productCount);
        uint[] memory itemQuantities = new uint[](_productCount);
        uint[] memory itemPrices = new uint[](_productCount);
        for(uint i = 0; i < _productCount; i++) {
            itemIds[i] = stores[_storeId].products[i].productId;
            itemNames[i] = stores[_storeId].products[i].name;
            itemQuantities[i] = stores[_storeId].products[i].totalQuantity;
            itemPrices[i] = stores[_storeId].products[i].unitPrice;
        }
        return (itemIds, itemNames, itemQuantities, itemPrices);
    }
        /** @dev Updates the quantity of an Item from a specicic Storefront.
    * @param _productId The item ID we want to update.
    * @param _storeId The storefront ID we want to update the inventory from.
    * @param _newQuantity The new quantity value we want to set the Item to.
    * @return _productId The updated item ID.
    */
    function updateItemQuantity(uint _productId, uint _storeId, uint _newQuantity)
    public
    restrictStoreOwner()
    
    returns(uint) {
        uint oldQty = stores[_storeId].products[_productId].totalQuantity;
       stores[_storeId].products[_productId].totalQuantity = _newQuantity;
        emit LogProductQtyUpdated(_productId, _newQuantity, oldQty);
        return _productId;
    }
}