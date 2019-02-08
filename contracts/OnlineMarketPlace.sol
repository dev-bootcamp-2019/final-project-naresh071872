pragma solidity ^0.5.0;

import "./AccessRestriction.sol";
import "./SafeMath.sol";
/* @title OnlineMarketPlace
* @author Naresh Saladi
* @notice Final Project - Consensys Training
*/
contract OnlineMarketPlace is AccessRestriction {

    //state variable to maintain data in blockchain

    // data for administrators and storeowners
    bool public stopped = false;
     address[] public administrators;
     address[] public storeOwners;
     mapping(address => bool) public adminAddressMap;  
     mapping(address => bool) public storeOwnerAddressMap;  

    //data for store
      struct Store  {
        bytes32 id;
        bytes32 name;
        address owner;
        uint storeSales;
    }
    //data for product
     struct Product{
        bytes32 id;
        bytes32 name;
        uint unitPrice;
        uint totalQuantity;
        uint productSales;
    }
    
    bytes32[] ids;
    //data for id key and list of ids array as values
    mapping(bytes32 => bytes32[]) public productsByStore;
    // data for id key and stores
    mapping(bytes32 => Store) public stores;
    //data for id key and products
    mapping(bytes32 => Product) products;
    //data for list of ids by owner
    mapping (address => bytes32[]) public storesByOwner;

    //data to maintain counts
    uint storeCounterer;
    uint adminCount;
    uint storeOwnerCount;
    
     //Events
     event LogAdminAdded(address _owner);
     event LogAdminDeleted(address _owner);
      event LogStoreOwnerAdded(address _owner);
     event LogStoreOwnerDeleted(address _owner);
     
     event LogAddStore(bytes32 _id,bytes32 _name);
     event LogDeleteStore(bytes32 _id);
   
     event LogProductAdded(bytes32 _id,bytes32 _name,uint _unitPrice,uint _totalQuantity);
     event LogProductRemoved(bytes32 _id);
     event LogUpdatePrice(bytes32 _id,uint _unitPrice,uint _oldUnitPrice);
     
     event LogWithdrawFunds(bytes32 _id,uint _funds);
     
     event LogProductBought(bytes32 _id,bytes32 _productId,uint _quantity);
     event LogInventoryAdjustment(bytes32 _id,uint _quantity);
     event LogProductQtyUpdated(bytes32 _id,uint _newQuantity,uint oldQty);

    //contract instantiation - send contract owner as admin
     constructor() public{
        adminAddressMap[msg.sender] = true;
        administrators.push(msg.sender);
       
    }
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
        adminAddressMap[_owner]=false;
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
        /** @dev Get a list of all the administrators.
    * @return admins The array of all the administrators address.
    */  
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
         storeOwnerAddressMap[_owner]=false;
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

    modifier stopInEmergency { require(!stopped); _; }
    modifier onlyInEmergency { require(stopped); _; }

    
    /* @dev create a new storefront that will be displayed on the marketplace
     * @param name store name 
     * @returns id id of store
    */
    
    function addStore(bytes32 _name) public restrictStoreOwner() returns (bytes32)
    {
        bytes32 _id = keccak256(abi.encodePacked(msg.sender, _name, now));
        Store memory _store =Store(_id,_name,msg.sender,0);
        ids.push(_id);
        storesByOwner[msg.sender].push(_id);
        stores[_id] = _store;
        emit LogAddStore(_id,_name);
        return _id;  
    }
    /* @dev delete a store that will be removed from the marketplace
    * @param _id identifier of a store
    */
     function deleteStore(bytes32 _id) public restrictStoreOwner() returns (bytes32)
    {
        
         // Delete all the items from the store inventory.
        for (uint i = 0; i < productsByStore[_id].length; i++) {
            bytes32 id = productsByStore[_id][i];
            delete products[id];
        }

        // Delete the store inventory.
        delete productsByStore[_id];

        // Remove from storefrontsByOwner mapping.
        uint storeCount = storesByOwner[msg.sender].length;
        for(uint i = 0; i < storeCount; i++) {
            if (storesByOwner[msg.sender][i] == _id) {
                storesByOwner[msg.sender][i] = storesByOwner[msg.sender][storeCount-1];
                delete storesByOwner[msg.sender][storeCount-1];
                storesByOwner[msg.sender].length --;
                break;
            }
        }

        // Remove from ids array.
        storeCount = ids.length;
        for(uint i = 0; i < storeCount; i++) {
            if (ids[i] == _id) {
                ids[i] = ids[storeCount - 1];
                delete ids[storeCount - 1];
                ids.length --;
                break;
            }
        }

        // Withdraw Balance if needed.
        uint storeBalance = stores[_id].storeSales;
        if (storeBalance > 0) {
            //stores[_id].storeBalance = 0;
            msg.sender.transfer(storeBalance);
            emit LogWithdrawFunds(_id, storeBalance);
        }
        
        delete stores[_id]; 
        emit LogDeleteStore(_id);
        return _id;
       
    }
 
 function findStoresByOwner(address storeOwner)
    public
    view
    returns(bytes32[]  memory ,bytes32[] memory, uint[] memory) {
        uint storeCount = storesByOwner[storeOwner].length;
        bytes32[] memory _ids = new bytes32[](storeCount);
        bytes32[] memory names = new bytes32[](storeCount);
        uint[] memory storeSales = new uint[](storeCount);
       
        for(uint i = 0; i < storeCount; i++) {
            bytes32 id = storesByOwner[storeOwner][i];
            _ids[i] = stores[id].id;
            names[i] = stores[id].name;
            storeSales[i] = stores[id].storeSales;
        }
        return (_ids, names, storeSales);
    }

    /* @dev withdraw any funds that the store has collected from sales
    * @param _id identifier of a store
      * @param _funds  funds need to be withdraw from store balance
    */
    function withdrawFunds(bytes32 _id,uint _funds) public payable onlyInEmergency() //checkAvailFunds(_id,_funds)
    {
        stores[_id].storeSales = 0;
        msg.sender.transfer(_funds);
        emit LogWithdrawFunds(_id,_funds);
    
    }

    /** @dev Get all the created Storefronts.
    * @return (ids, names, owners) The Id, name and owner for each Storefront.
    */
    function findStores()
    public
    view
    returns(bytes32[] memory, bytes32[] memory, address[] memory) {
        uint storeCount = ids.length;
        bytes32[] memory _ids = new bytes32[](storeCount);
        bytes32[] memory names = new bytes32[](storeCount);
        address[] memory owners = new address[](storeCount);
        for(uint i = 0; i < storeCount; i ++) {
            _ids[i] = stores[ids[i]].id;
            names[i] = stores[ids[i]].name;
            owners[i] = stores[ids[i]].owner;
        }
        return(_ids, names, owners);
    }
    /* @dev add a product to a specific store 
    * @param _id identifier of a store
      * @param _name name of product
       * @param _unitPrice price of product
        * @param _totalQuantity total inventory of product available
         
    */
    function addProduct(bytes32 _id,bytes32 _name,uint _unitPrice,uint _totalQuantity) public restrictStoreOwner() returns (bytes32)
    {
        
        bytes32 _productId = keccak256(abi.encodePacked(msg.sender, _name, now));
        Product memory product = Product(_productId,_name,_unitPrice,_totalQuantity,0);
        products[_productId] = product;
        productsByStore[_id].push(_productId);
        emit LogProductAdded(_productId,_name,_unitPrice,_totalQuantity);
        return  _id;
    }
      /* @dev remove a product from  a specific store 
    * @param _id identifier of a store
      * @param _id identifier of a product
    
    */
    function removeProduct(bytes32 _storeId,bytes32 _productId) public restrictStoreOwner() 
    {
          // Remove the item from inventory mapping
        uint productCount = productsByStore[_storeId].length;
        for(uint i = 0; i < productCount; i++) {
            if (productsByStore[_storeId][i] == _productId) {
                productsByStore[_storeId][i] = productsByStore[_storeId][productCount-1];
                delete productsByStore[_storeId][productCount-1];
                productsByStore[_storeId].length --;
                break;
            }
        }
        //Remove item from items mapping
        delete products[_productId];
        emit LogProductRemoved(_productId);
    }
    
       /* @dev change any of the products’ prices.
    * @param _id identifier of a store
      * @param _id identifier of a product
    * @param _newUnitPrice new unit price of a product
    */
    function updatePrice(bytes32 _id,uint _newUnitPrice) public restrictStoreOwner() 
    returns (bytes32)
    {
        uint oldPrice = products[_id].unitPrice;
        products[_id].unitPrice = _newUnitPrice;
        emit LogUpdatePrice(_id,_newUnitPrice,oldPrice);
        return _id;
    }
  
 /** @dev Updates the quantity of an Item from a specicic Storefront.
    * @param _id The item ID we want to update.
    * @param _newQuantity The new quantity value we want to set the Item to.
    * @return _id The updated item ID.
    */
    function updateItemQuantity(bytes32 _id, uint _newQuantity)
    public
    restrictStoreOwner()
    returns(bytes32) {
        uint oldQty = products[_id].totalQuantity;
        products[_id].totalQuantity = _newQuantity;
        emit LogProductQtyUpdated(_id, _newQuantity, oldQty);
        return _id;
    }   
    /* @dev check availability funds
    * @param _id identifier of a store
      * @param _funds  funds need to be withdraw from store balance
    */
    modifier checkAvailFunds(bytes32 _id,uint _funds) {
        require(stores[_id].storeSales>=_funds,"Funds plan to withdraw is more than Store Balance");
        _;
    }


       /* @dev check whether buyer has enough funds 
    * @param _id identifier of a store
      * @param _id identifier of a product
    * @param quantity product quantity
    */
    modifier buyerEnoughFunds(bytes32 _productId,uint quantity) 
    { 
        
        uint totalCost = products[_productId].unitPrice * (quantity);
        require(msg.value >= totalCost,"Buyer doesn't have enought balance"); 
        _;
    }
      /* @dev check product inventory .
    * @param _id identifier of a store
      * @param _id identifier of a product
    * @param quantity product quantity
    */
    modifier checkStock(bytes32 _productId,uint quantity)
    {
        require (products[_productId].totalQuantity>=quantity,"Out-of-Stock"); 
        _;
    }

   /* @dev buy product .
    * @param _id identifier of a store
      * @param _id identifier of a product
    * @param quantity product quantity
    */
    function purchaseProduct(bytes32 _id,bytes32 _productId,uint _quantity) public
    //buyerEnoughFunds(_productId,_quantity) 
    checkStock(_productId,_quantity)  stopInEmergency()
     payable returns (bool)
    {
        
        uint totalPrice = products[_productId].unitPrice * _quantity;
        
   
        if (msg.value > totalPrice) {
            msg.sender.transfer(SafeMath.sub(msg.value,totalPrice));
        }
        adjustInventory(_productId,_quantity);
        products[_productId].productSales =SafeMath.add(products[_productId].productSales,totalPrice);
        stores[_id].storeSales = SafeMath.add(stores[_id].storeSales,totalPrice);
        emit LogProductBought(_id,_productId,_quantity);
        return true;
    }
    /* @dev inventory will be reduced .
    * @param _id identifier of a store
      * @param _id identifier of a product
    * @param quantity product quantity
    */
    function adjustInventory(bytes32 _productId,uint _quantity) private
    {
        products[_productId].totalQuantity = SafeMath.sub(products[_productId].totalQuantity,_quantity);
        emit LogInventoryAdjustment(_productId,_quantity);

    }
    
   /** @dev Get the inventory for a specific Storefront.
    * @param _id The storefront ID.
    * @return (itemIds, itemNames, itemQuantities, itemPrices) The Id, name, quantity and price for each Item.
    */
    function productCatalog(bytes32 _id)
    public
    view
    returns(bytes32[] memory, bytes32[] memory, uint[] memory, uint[] memory)
    {
        bytes32[] memory inventory = productsByStore[_id];
        uint inventorySize = inventory.length;
        bytes32[] memory itemIds = new bytes32[](inventorySize);
        bytes32[] memory itemNames = new bytes32[](inventorySize);
        uint[] memory itemQuantities = new uint[](inventorySize);
        uint[] memory itemPrices = new uint[](inventorySize);
        for(uint i = 0; i < inventorySize; i++) {
            itemIds[i] = products[inventory[i]].id;
            itemNames[i] = products[inventory[i]].name;
            itemQuantities[i] = products[inventory[i]].totalQuantity;
            itemPrices[i] = products[inventory[i]].unitPrice;
        }
        return (itemIds, itemNames, itemQuantities, itemPrices);
    }

    function getStoreCount() external view returns(uint)
    {
        return ids.length;
    }
    function getProductCount(bytes32 _id) external view returns(uint)
    {
        return productsByStore[_id].length;
    }
    function getProductPrice(bytes32 _id)  public view returns (uint)
{
    return products[_id].unitPrice;
} 
 
    
}