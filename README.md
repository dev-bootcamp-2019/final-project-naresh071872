﻿This project is for Online Market Place built using following technologies.

Smart Contracts written using Solidity Language
OnlineMarketPlace.sol

Run following commands to compile , migrate and test using Truffle

    truffle compile
    npm install --save truffle-hdwallet-provider
    truffle migrate
    truffle test

Front-end built using React Framework and ether.js to interact with contracts

Navigate to client directory and install all dependencies listed below command
npm install

Update contract address in react container App.js
const SMART_CONTRACT_ADDRESS = new_contract_address

Start the React app.

    npm run start

Alternatively you can use test network deployed contracts addresses:
Ropsten: 0xCD66dF3a352ec9e7ceB6Cc9E7948c9cdAB8C65BB
Rinkeby: 0x9D3f97b3C8E016a184770f60b99632a3d1F407F9

Project Description: Online Market Place Application was built as dapp with front-end on React JS.
It includes following functionality as belows
Ability to add new administrators
Ability to remove existing administrators
Ability to add new store owners by administrators
Ability to remove existing store owners by administrators
Ability to add new stores by storeowners
Ability to remove stores by storeowners
Ability to add new products by storeowners
Ability to remove a product from a store by storeowners
Ability to update price for a given product by storeowners
Ability to buy a product by shopper
Ability to withdraw funds for storeowners
