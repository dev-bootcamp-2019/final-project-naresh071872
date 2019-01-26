pragma solidity ^0.5.0;
import "./AccessRestriction.sol";
import "./SafeMath.sol";
/* @title OnlineMarketPlace
* @author Naresh Saladi
* @notice Final Project - Consensys Training
*/
contract OnlineMarketPlace is AccessRestriction {
 
    bool public stopped = false;

     mapping(address => bool) public adminAddressMap;  
     mapping(address => bool) public storeOwnerAddressMap;  
     struct Product{
        uint productId;
        string name;
        uint unitPrice;
        uint totalQuantity;
        uint productSales;
    }
     struct Store  {
        string name;
        uint productsCount;
        uint storeSales;
        address payable storeOwnerAddress;
        mapping(uint => Product) products;
    }
    
    mapping(uint => Store) stores;
    uint storeCount;
   
    
     //Events
     event LogAdminAdded(address _owner);
     event LogAdminDeleted(address _owner);
      event LogStoreOwnerAdded(address _owner);
     event LogStoreOwnerDeleted(address _owner);
     
     event LogAddStore(uint _storeId,string _name);
     event LogDeleteStore(uint _storeId);
   
     event LogProductAdded(uint _storeId,string _name,uint _unitPrice,uint _totalQuantity);
     event LogProductRemoved(uint _storeId,uint _productId);
     event LogUpdatePrice(uint _storeId,uint _productid,uint _unitPrice);
     event LogWithdrawFunds(uint _storeId,uint _funds);
     
     event LogProductBought(uint _storeId,uint _productId,uint _quantity);
     event LogInventoryAdjustment(uint _storeId,uint _productId,uint _quantity);
     
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
     function addAdmin(address _owner) public restrictContractOwner() returns (bool)
    {
        adminAddressMap[_owner]=true;
        emit LogAdminAdded(_owner);
        return adminAddressMap[_owner];
    }
    /* @dev removes given ethereum address as administrator
    * @param _owner address of next administrator
    */
     function deleteAdmin(address _owner) public restrictContractOwner() returns (bool)
    {
        delete adminAddressMap[_owner];
        emit LogAdminDeleted(_owner);
        return true;
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
        emit LogStoreOwnerAdded(_owner);
    }
    /* @dev removes given ethereum address as storeOwner
    * @param _owner address of store owner
    */
     function deleteStoreOwner(address _owner) public restrictAdmin()
    {
        delete storeOwnerAddressMap[_owner];
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
    }
    
    /* @dev create a new storefront that will be displayed on the marketplace
     * @param name store name 
     * @returns storeId id of store
    */
    
    function addStore(string memory _name) public restrictStoreOwner() returns (uint)
    {
        storeCount = SafeMath.add(storeCount,1);
        stores[storeCount] = Store(_name,0,0,msg.sender);
        emit LogAddStore(storeCount,_name);
        return storeCount;
       
    }
    /* @dev delete a store that will be removed from the marketplace
    * @param _storeId identifier of a store
    */
     function deleteStore(uint _storeId) public restrictStoreOwner() returns (uint)
    {
        storeCount= SafeMath.sub(storeCount,1);
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
    function addProduct(uint _storeId,string memory _name,uint _unitPrice,uint _totalQuantity) public restrictStoreOwner() returns (uint)
    {
        stores[_storeId].productsCount= SafeMath.add(stores[_storeId].productsCount,1);
        uint productId = stores[_storeId].productsCount;
        stores[_storeId].products[productId] = Product(productId,_name,_unitPrice,_totalQuantity,0);
        emit LogProductAdded(_storeId,_name,_unitPrice,_totalQuantity);
        return productId;
    }
      /* @dev remove a product from  a specific store 
    * @param _storeId identifier of a store
      * @param _productId identifier of a product
    
    */
    function removeProduct(uint _storeId,uint _productId) public restrictStoreOwner() 
    {
        stores[_storeId].productsCount= SafeMath.sub(stores[_storeId].productsCount,1);
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
        emit LogUpdatePrice(_storeId,_productId,_newUnitPrice);
    }
  
    /* @dev withdraw any funds that the store has collected from sales
    * @param _storeId identifier of a store
      * @param _funds  funds need to be withdraw from store balance
    */
    function withdrawFunds(uint _storeId,address payable _targetAddress, uint _funds) public payable onlyInEmergency() checkAvailFunds(_storeId,_funds)
    {
        _targetAddress.transfer(_funds);
        stores[_storeId].storeSales -=_funds;
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
        uint totalCost = stores[storeId].products[productId].unitPrice * quantity;
        require(msg.value >= totalCost,""); 
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
        stores[_storeId].storeOwnerAddress.transfer(totalAmount);
        adjustInventory(_storeId,_productId,_quantity);
        stores[_storeId].products[_productId].productSales +=totalAmount;
        stores[_storeId].storeSales +=totalAmount;
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
}
