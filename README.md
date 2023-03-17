# Dapp Sample Implementation using npm package react-solidity-xdc3
## Powered by Plugin(A decentralized Oracle)

This guide will give you a clear direction on how to deploy your smart contract, create react component and wire web3 package to push and pull the data onto/from blockchain.

if any queries / comments, feel free to raise an issue.

# IMPORTANT LINKS:
XDC Mainnet explorer - https://explorer.xinfin.network/
Apothem FAUCET - https://faucet.apothem.network/
Apothem Blockchain explorer - https://explorer.apothem.network/
XDCPay Wallet - https://chrome.google.com/webstore/detail/xdcpay/bocpokimicclpaiekenaeelehdjllofo
NPM package - https://www.npmjs.com/package/react-solidity-web3-v2
XDC Remix - https://remix.xinfin.network/#optimize=true&runs=200&evmVersion=null&version=soljson-v0.4.26+commit.4563c3fc.js
Developer Forum -https://www.xdc.dev/
How to Articles - https://docs.xdc.community/learn/how-to-articles/
XDC Tools - https://xinfin.org/xdc-chain-network-tools-and-documents

# Table of Contents
- Pre-requisites
- How it works
- How to deploy
- How to create a component
- How to steup a function to submit txn to Blockchain
- How to query data from blockchain
- How to query events

## pre-requisites
- nvm version 0.37.2
- npm version 7.24.0
- node version 16.10.0
- do seup XDCPay Chrome Extension in your chrome 
- setup Hardhat (https://www.npmjs.com/package/hardhat)

## How it works?
- This project uses react-solidity-xdc3 npm package
- Copy down your contract in contract folder
- Update deplooyment script under scripts/ folder to refer your contract name
- Pass necessary constructor parameter if any
- If you have more than one contract to deploy, then refer those accordingly
- Pass your PRIVATE_KEY in .env to deploy your contract against specific network ( Apothem or Mainnet)
- After successfull deployment, copy down the output.json into App folder
- Go to App folder, creaet your component and call execute function for write, and queryData function for read

## .env should have following parameters
- PRIVATE_KEY(of your account) to migrate the contract

## How to RUn
- do git clone & npm install

```
 npm install
```
## How to deploy sample contract
```
yarn deploy --network apothem
```
this will deploy the contract in apothem network and contract address will be stored in output.json

copy down this contract address in app folder, under same output.json

## How to run client application
- After copying the contract address run react application using following command
```
yarn install
yarn start
```
this will start the application in http://localhost:3000 
- When you click "Register" it writes the data onto blockchain
- When you click "Fetch", it pulls the data from blockchain

## How to Create a new component and implement this react-solidity-xdc3 / react-solidity-web3 at ease
- Go to app/src/components/
- Clone "Sample" folder and name your components (Let's say - Flights)
- Rename new component Sample.js -> Flights.js
- Rename new component Sample.css -> Flights.css
- Update the app.js to have this Flights component
```
import Flights from './Flights/Flights';
```
- Create an instance for flight contract and abi
```
    const flight = await createInstance(flightaddress, flightabi, provider);
```
flightabi, flightaddress to read from respective path
- Set the flight instance in ethereum context like below
```
    setethereumContext({ provider, sample,flght, account })
```

- Update the app.js to have Flights component added under EthereumContext like below
```
      <section className="App-content">
        <EthereumContext.Provider value={ethereumContext}>
          <Sample />
          <Flights />
        </EthereumContext.Provider>
      </section>
```
- Go to Flights.js file and implement this
- Create functions say - "registerFlights", "fetchFlight"
- Update "sample" reference to flight 
- executeTxn() function expects four params "contractInstance,provider,functionName,[params separated by comma, leave if empty]"
- queryData() function also expects the same four params "contractInstance,provider,functionName,[params separated by comma,leave if empty] "

All Set, now you should be able to write data onto blockchain & read.