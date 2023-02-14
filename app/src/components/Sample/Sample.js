import { useState, useContext } from 'react';
import './Sample.css';
const { executeTransaction, EthereumContext, log, queryData } = require('react-solidity-xdc3');

function Sample() {
  const [submitting, setSubmitting] = useState(false);
  const { provider, sample, consumer } = useContext(EthereumContext);
  console.log("sample", sample)
  console.log("consumer", consumer)

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

  const getPriceInfo = async (event) => {
    event.preventDefault();
    setSubmitting(true);
    let response1 = await executeTransaction(consumer, provider, 'getPriceInfo', [], 0);
    log("getPriceInfo", "hash", response1.txHash)
    setSubmitting(false);
  }

  const showPrice = async (event) => {
    event.preventDefault();
    setSubmitting(true);
    let response = await queryData(consumer, provider, 'show', []);
    log("showPrice", "hash", response)
    setSubmitting(false);
  }

  const addBook = async (event) => {
    event.preventDefault();
    setSubmitting(true);
    let bookname = "My First Book";
    let response = await executeTransaction(consumer, provider, 'addBooks', [bookname], 0);
    log("addBook", "hash", response)
    setSubmitting(false);
  }
  const retriveBook = async (event) => {
    event.preventDefault();
    setSubmitting(true);
    let bookid = 1;
    let response = await queryData(consumer, provider, 'books', [bookid]);
    log("retriveBook", "hash", response)
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
    <div>
      <h1>Get Price Info</h1><br></br>
      <form onSubmit={getPriceInfo}>
        <button type="submit" disabled={submitting}>{submitting ? 'Fetching..' : 'Get Price '}</button>
      </form>
    </div>
    <div>
      <h1>Show Price</h1><br></br>
      <form onSubmit={showPrice}>
        <button type="submit" disabled={submitting}>{submitting ? 'Fetching..' : 'Show Price '}</button>
      </form>
    </div>
    <div>
      <h1>Add Book </h1><br></br>
      <form onSubmit={addBook}>
        <button type="submit" disabled={submitting}>{submitting ? 'Adding Books..' : 'Add Book '}</button>
      </form>
    </div>
    <div>
      <h1>Retrieve Book </h1><br></br>
      <form onSubmit={retriveBook}>
        <button type="submit" disabled={submitting}>{submitting ? 'Retrieving Books..' : 'Show My Book '}</button>
      </form>
    </div>
  </div>
}



export default Sample;
