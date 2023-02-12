import { ethers } from 'ethers';
import './App.css';
import Sample from './Sample/Sample';
import Header from './Header/Header';
import { abi } from '../artifacts/contracts/SampleContract.sol/SampleContract.json';
import { SampleContract as address } from '../output.json';

import { useState } from 'react';
import { ToastContainer } from 'react-toastify';
import 'react-toastify/dist/ReactToastify.css';

const { getWeb3Modal, createWeb3Provider, connectWallet, EthereumContext, createContractInstance, log } = require('react-solidity-xdc3');

var connectOptions = {
  rpcObj: {
    50: "https://rpc.xinfin.network",
    51: "https://rpc.apothem.network"
  },
  network: "mainnet",
  toDisableInjectedProvider: true
}

function App() {
  const [connecting, setconnecting] = useState(false);
  const [ethereumContext, setethereumContext] = useState({});
  const web3Modal = getWeb3Modal(connectOptions);

  const connect = async (event) => {
    event.preventDefault();
    const instance = await web3Modal.connect();
    const { provider, signer } = await createWeb3Provider(instance);
    const sample = await createContractInstance(address, abi, provider);
    const account = signer.getAddress();
    setethereumContext({ provider, sample, account })
    log("Connect", "Get Address", await signer.getAddress());
    setconnecting(true);
  }
  return (
    <div className="App">
      <Header />
      <header className="App-header">
        <h1>Sample Decentralized Application </h1>
        <p>Powered by react-solidity-xdc3 Package</p>
        <p>Contributed by GoPlugin(www.goplugin.co)</p>
        <form onSubmit={connect}>
          <button type="submit" disabled={connecting}>{connecting ? 'Connecting...' : 'Connect'}</button>
        </form>
      </header>
      <section className="App-content">
        <EthereumContext.Provider value={ethereumContext}>
          <Sample />
        </EthereumContext.Provider>
      </section>
      <ToastContainer hideProgressBar={true} />
    </div>
  );
}

export default App;
