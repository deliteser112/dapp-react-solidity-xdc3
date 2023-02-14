//SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

interface IInvokeOracle {
    function requestData(address _caller) external returns (bytes32 requestId);

    function showPrice() external view returns (uint256);
}

contract CustomerContract {
    address CONTRACTADDR = 0x4C50a698F8148b2560eAdb50a8397b614DcfF6A0;
    bytes32 public requestId;

    uint256 public _counter;

    struct Temp{
        uint256 id;
        string bookName;
    }

    mapping(uint256 => Temp) public books;

    constructor(){
        _counter =1;
    }

    function addBooks(string memory _bookName) public {
        books[_counter] = Temp(
            _counter,
            _bookName
        );
        _counter+=1;
    }

    //Fund this contract with sufficient PLI, before you trigger below function.
    //Note, below function will not trigger if you do not put PLI in above contract address
    function getPriceInfo() external returns (bytes32) {
        (requestId) = IInvokeOracle(CONTRACTADDR).requestData({
            _caller: msg.sender
        });
        return requestId;
    }

    //TODO - you can customize below function as you want, but below function will give you the pricing value
    //This function will give you last stored value in the contract
    function show() external view returns (uint256) {
        return IInvokeOracle(CONTRACTADDR).showPrice();
    }
}
