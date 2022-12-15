//SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/utils/Counters.sol";
import "@goplugin/contracts/src/v0.8/PluginClient.sol";
import "./interface/IStatus.sol";

contract SampleContract is PluginClient, IStatus {
    using Counters for Counters.Counter;
    Counters.Counter private _flightIds;
    Counters.Counter private _insuranceIds;

    using Plugin for Plugin.Request;

    uint256 private constant ORACLE_PAYMENT = 0.001 * 10**18;

    // address
    address public owner;
    mapping(uint256 => mapping(address => FlightInsurance)) public insurances;
    mapping(uint256 => mapping(address => FlightMaster)) public flights;
    mapping(bytes32 => FlightInsurance) public claims;
    mapping(uint256 => mapping(address => bytes32)) public claimRequest;

    constructor(address _pli) {
        setPluginToken(_pli);
        owner = msg.sender;
        _flightIds.increment();
        _insuranceIds.increment();
    }

    modifier only_owner() {
        require(owner == msg.sender);
        _;
    }

    event FlightEvents(
        uint256 flightId,
        string eventType,
        address flight,
        address performedBy,
        uint256 performedOn
    );

    event InsuranceEvents(
        uint256 insuranceid,
        string eventType,
        address passenger,
        address performedBy,
        uint256 performedOn
    );

    //Initialize event requestCreated
    event requestCreated(
        address indexed requester,
        bytes32 indexed jobId,
        bytes32 indexed requestId
    );

    //Initialize event RequestPermissionFulfilled
    event RequestPermissionFulfilled(
        bytes32 indexed requestId,
        uint256 indexed otp
    );

    // Register Flight
    function registerFlights(
        address _flightAddress,
        string memory _carrierFlightNumber,
        string memory _serviceProviderName
    ) public returns (uint256) {
        uint256 _flightId = _flightIds.current();
        _flightIds.increment();

        flights[_flightId][_flightAddress] = FlightMaster(
            _flightId,
            _carrierFlightNumber,
            _serviceProviderName,
            _flightAddress,
            block.timestamp,
            msg.sender
        );
        emit FlightEvents(
            _flightId,
            "Flight Registered",
            msg.sender,
            msg.sender,
            block.timestamp
        );

        return _flightId;
    }

    // Book Flight Delay Insurance
    function bookInsurance(
        address _passengerAddress,
        string memory _carrierFlightNumber,
        uint256 _departureOn,
        uint256 _arrivalOn,
        uint256 _travelday
    ) public returns (uint256) {
        uint256 _insuranceId = _insuranceIds.current();
        _insuranceIds.increment();

        insurances[_insuranceId][_passengerAddress] = FlightInsurance(
            _insuranceId,
            _passengerAddress,
            _carrierFlightNumber,
            _departureOn,
            _arrivalOn,
            block.timestamp,
            FlightStatus(1),
            _travelday,
            false
        );

        emit InsuranceEvents(
            _insuranceId,
            "Insurance Booked",
            msg.sender,
            msg.sender,
            block.timestamp
        );

        return _insuranceId;
    }

    function submitMyClaim(
        uint256 _insuranceid,
        address _oracleAddress,
        string memory _jobid
    ) public {
        FlightInsurance memory fin = insurances[_insuranceid][msg.sender];
        require(
            fin.passenger != address(0),
            "Policy Holder Address is invalid"
        );
        require(fin.processed == false, "Already claimed");

        Plugin.Request memory req = buildPluginRequest(
            stringToBytes32(_jobid),
            address(this),
            this.fulfillClaimInquiry.selector
        );
        req.addUint("until", fin.arrivalOn);
        bytes32 reqId = sendPluginRequestTo(
            _oracleAddress,
            req,
            ORACLE_PAYMENT
        );
        claims[reqId] = fin;
        claimRequest[_insuranceid][msg.sender] = reqId;
    }

    function fulfillClaimInquiry(bytes32 _requestId, FlightStatus _flightStatus)
        public
        recordPluginFulfillment(_requestId)
    {
        FlightInsurance memory fin = claims[_requestId];
        fin.processed = true;
        fin.flightStatus = FlightStatus(_flightStatus);
    }

    //String to bytes to convert jobid to bytest32
    function stringToBytes32(string memory source)
        private
        pure
        returns (bytes32 result)
    {
        bytes memory tempEmptyStringTest = bytes(source);
        if (tempEmptyStringTest.length == 0) {
            return 0x0;
        }
        assembly {
            result := mload(add(source, 32))
        }
    }
}
