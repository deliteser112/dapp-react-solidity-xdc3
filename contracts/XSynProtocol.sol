// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./interfaces/IExchangeRate.sol";
import "./interfaces/IXDUSDCore.sol";
import "./AddressResolver.sol";
import "./utils/Constants.sol";
import "./utils/SafeDecimalMath.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract XSynProtocol is Constants, AddressResolver {

    using SafeMath for uint256;
    using SafeDecimalMath for uint256;

    string public constant CONTRACTNAME = "XSynProtocol";
    string internal constant CONTRACT_XDUSDCORE = "XDUSD";
    string internal constant CONTRACT_EXCHANGERATE = "EXCHANGERATE";

    mapping(address => uint256) public mintr;
    address public contractOwner;

    uint256 public minimumXDCDepositAmount = 2000 * SafeDecimalMath.unit();
    uint256 public minimumPLIDepositAmount = 700 * SafeDecimalMath.unit();

    /* Stores deposits from users. */
    struct DepositEntry {
        // The user that made the deposit
        address payable user;
        // The amount (in xdc / pli) that they deposited
        uint256 xdcDeposit;
        uint256 pliDeposit;
        // type of (coin/token) that they deposited
        TokenType tok;
    }

    mapping(address => DepositEntry) public deposits;

    constructor() public {
        contractOwner = msg.sender;
    }

    /**
     * @notice Fallback function
     */
    receive() external payable {}

    function setMinDepositForXDC(uint256 _minDeposit) external {
        minimumXDCDepositAmount = _minDeposit;
        emit MinimumDepositAmountUpdated(minimumXDCDepositAmount);
    }

    function setMinDepositForPLI(uint256 _minDeposit) external {
        minimumPLIDepositAmount = _minDeposit;
        emit MinimumDepositAmountUpdated(minimumPLIDepositAmount);
    }

    /**
     * @notice Exchange XDC to xdUSD.
     */
    /* solhint-disable multiple-sends, reentrancy */
    function mintxdUSDForXDC()
        external
        payable
        returns (
            uint256 // Returns the number of Synths (sUSD) Minted
        )
    {
        require(
            msg.value >= minimumXDCDepositAmount,
            "XDC amount Should be minimumXDCDepositAmount limit"
        );
        // How much is the XDC they sent us worth in XDUSD (ignoring the transfer fee)?
        // The multiplication works here because  ExchangeRate().retrieve(XDC_PRICE_FROM_PLUGIN) is specified in
        // 18 decimal places, just like our currency base.
        bytes32 requestId = ExchangeRate().requestData("XDC", "USDT");
        uint256 xdUSDToMint = msg.value.multiplyDecimal(
            ExchangeRate().showPrice(requestId)
        );
        return _exchangeXdcForXDUSD(xdUSDToMint);
    }

    function _exchangeXdcForXDUSD(uint256 _xdUSDToMintforXDC)
        internal
        returns (uint256)
    {
        require(
            msg.value >= minimumXDCDepositAmount,
            "XDC amount Should be minimumXDCDepositAmount limit"
        );

        DepositEntry memory deposit = deposits[msg.sender];
        uint256 newAmount = deposit.xdcDeposit.add(msg.value);

        // add a row in deposit entry and sum up the total value deposited so far
        deposits[msg.sender] = DepositEntry(
            deposit.user,
            newAmount,
            deposit.pliDeposit,
            TokenType(0)
        );
        //mint XDUSD for the amount of XDC they staked
        xdusdCore().mint(msg.sender, _xdUSDToMintforXDC);
        return 1;
    }

    /**
     * @notice Exchange XDC to xdUSD.
     */
    /* solhint-disable multiple-sends, reentrancy */
    function mintxdUSDForPLI(uint256 _pliVal, address _tokenAddress)
        external
        returns (
            uint256 // Returns the number of Synths (sUSD) Minted
        )
    {
        require(
            _pliVal >= minimumPLIDepositAmount,
            "PLI amount Should be minimumPLIDepositAmount limit"
        );
        // How much is the XDC they sent us worth in XDUSD (ignoring the transfer fee)?
        // The multiplication works here because  ExchangeRate().retrieve(XDC_PRICE_FROM_PLUGIN) is specified in
        // 18 decimal places, just like our currency base.
        bytes32 requestId = ExchangeRate().requestData("PLI", "USDT");
        uint256 xdUSDToMint = _pliVal.multiplyDecimal(
            ExchangeRate().showPrice(requestId)
        );
        XRC20Balance(msg.sender, _tokenAddress, _pliVal);
        XRC20Allowance(msg.sender, _tokenAddress, _pliVal);
        transferFundsToContract(_pliVal, _tokenAddress);
        return _exchangePliForXDUSD(xdUSDToMint, _pliVal);
    }

    function _exchangePliForXDUSD(uint256 _xdUSDToMintforPli, uint256 _pli)
        internal
        returns (uint256)
    {
        require(
            _pli >= minimumPLIDepositAmount,
            "PLI amount Should be minimumPLIDepositAmount limit"
        );

        DepositEntry memory deposit = deposits[msg.sender];
        uint256 newAmount = deposit.pliDeposit.add(_pli);

        // add a row in deposit entry and sum up the total value deposited so far
        deposits[msg.sender] = DepositEntry(
            deposit.user,
            deposit.xdcDeposit,
            newAmount,
            TokenType(1)
        );
        //mint XDUSD for the amount of XDC they staked
        xdusdCore().mint(msg.sender, _xdUSDToMintforPli);
        return 1;
    }

    function xdusdCore() internal view returns (IXDUSDCore) {
        return IXDUSDCore(requireAndGetAddress(CONTRACT_XDUSDCORE));
    }

    function ExchangeRate() internal view returns (IExchangeRate) {
        return IExchangeRate(requireAndGetAddress(CONTRACT_EXCHANGERATE));
    }

    function XRC20Balance(
        address _addrToCheck,
        address _currency,
        uint256 _AmountToCheckAgainst
    ) internal view {
        require(
            IERC20(_currency).balanceOf(_addrToCheck) >= _AmountToCheckAgainst,
            "XRC20Gateway: insufficient currency balance"
        );
    }

    function XRC20Allowance(
        address _addrToCheck,
        address _currency,
        uint256 _AmountToCheckAgainst
    ) internal view {
        require(
            IERC20(_currency).allowance(_addrToCheck, address(this)) >=
                _AmountToCheckAgainst,
            "XRC20Gateway: insufficient allowance."
        );
    }

    //internal function for transferpayment
    function transferFundsToContract(uint256 _amount, address _tokenaddress)
        internal
    {
        IERC20(_tokenaddress).transferFrom(msg.sender, address(this), _amount);
    }

    /* ========== EVENTS ========== */
    event MinimumDepositAmountUpdated(uint256 amount);
}
