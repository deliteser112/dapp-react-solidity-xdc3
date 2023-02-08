import { useState, useContext } from 'react';
import './Sample.css';
const { executeTransaction, EthereumContext, log, queryData } = require('react-solidity-web3');

function Sample() {
  const [submitting, setSubmitting] = useState(false);
  const { provider, sample } = useContext(EthereumContext);
  console.log("sample", sample)

  const registerFlights = async (event) => {
    event.preventDefault();
    setSubmitting(true);
    let _flightAddress = "0xA9e6835929f32DD440290b4c81466ff554b82667";
    let _careerFlightNo = "ING695";
    let _serviceProviderName = "Indigo Airlines";
    let response1 = await executeTransaction(sample, provider, 'registerFlights', [_flightAddress, _careerFlightNo, _serviceProviderName]);
    log("registerFlights", "hash", response1.txHash)
    setSubmitting(false);
  }

  const fetchFlight = async (event) => {
    event.preventDefault();
    setSubmitting(true);
    let _flightId = "1";
    let _flightAddress = "0xA9e6835929f32DD440290b4c81466ff554b82667";
    let response1 = await queryData(sample, provider, 'flights', [_flightId, _flightAddress]);
    log("submitClaim", "hash", response1)
    setSubmitting(false);
  }

  return <div className="Container">
    <div>
      <h1>Register</h1><br></br>
      <form onSubmit={registerFlights}>
        <button type="submit" disabled={submitting}>{submitting ? 'Registering..' : 'Register Flights'}</button>
      </form>
    </div>
    <div>
      <h1>Fetch</h1><br></br>
      <form onSubmit={fetchFlight}>
        <button type="submit" disabled={submitting}>{submitting ? 'Fetching..' : 'Fetch Flights '}</button>
      </form>
    </div>
  </div>
}



export default Sample;
