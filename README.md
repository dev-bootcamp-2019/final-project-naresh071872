This project is for Online Market Place built using following technologies
Smart Contracts written using Solidity Language
OnlineMarketPlace.sol
Run following commands to compile , migrate and test using Truffle
truffle compile
npm install --save truffle-hdwallet-provider
truffle migrate
truffle test

    Front-end built using React Framework and ether.js to interact with contracts

    Navigate to client directory and install all dependencies listed below
    command
        npm install

Update contract address in react container App.js
const SMART_CONTRACT_ADDRESS = new_contract_address

Start the React app.

npm run start

    Alternatively you can use test network deployed contracts addresses:

    Ropsten: 0xa39A9fA7e4624b60C4b11e7B83EE5851Cf497B3C
    Rinkeby: 0xaD3591637553bFd0a93AB9D086c536A188e15Cb0
