pragma solidity ^0.5.0;
contract DataStoreContract 
{
    struct EStore  {
        string name;
        mapping(uint => Product) products;
        address payable storeOwnerAddress;
    }
    struct Product{
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
    mapping(address => StoreOwner) public storeOwners;
}