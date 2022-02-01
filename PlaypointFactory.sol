// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./Helpers/ERC20.sol";
import "./Helpers/SafeMath.sol";

contract PlaypointFactory {
    using SafeMath for uint256;

    /**
     * Event for token purchase logging
     * @param purchaser who paid for the tokens
     * @param beneficiary who got the tokens
     * @param value weis paid for purchase
     * @param amount amount of tokens purchased
     */
    event TokenPurchase(
        address indexed purchaser,
        address indexed beneficiary,
        uint256 value,
        uint256 amount
    );

    /// @dev The token being sold
    ERC20 public token;

    /// @dev Address where funds are collected
    address payable public wallet;

    constructor(address payable _wallet, ERC20 _token) {
        // require(_wallet != address(0));
        // require(_token != address(0));
        wallet = _wallet;
        token = _token;
    }

    /**
     * @dev Experimental Function
     */
    // bytes4 private constant SELECTOR =
    //     bytes4(keccak256(bytes("transfer(address,uint256)")));

    // function _safeTransfer(address to, uint256 value) private {
    //     (bool success, bytes memory data) = address(token).call(
    //         abi.encodeWithSelector(SELECTOR, to, value)
    //     );
    //     require(
    //         success && (data.length == 0 || abi.decode(data, (bool))),
    //         "Playpoint: TRANSFER_FAILED"
    //     );
    // }

    /**
     * @dev Override to extend the way in which ether is converted to tokens.
     * @param _weiAmount Value in wei to be converted into tokens
     * @return Number of tokens that can be purchased with the specified _weiAmount
     */
    function _getTokenAmount(uint256 _weiAmount)
        internal
        view
        returns (uint256)
    {
        // return _weiAmount.mul(rate);
    }

    /**
     * @dev Validation of an incoming purchase. Use require statements to revert state when conditions are not met. Use super to concatenate validations.
     * @param _beneficiary Address performing the token purchase
     * @param _weiAmount Value in wei involved in the purchase
     */
    function _preValidatePurchase(address _beneficiary, uint256 _weiAmount)
        internal
        pure
    {
        require(_beneficiary != address(0));
        require(_weiAmount != 0);
    }

    /**
     * @dev Determines how ETH is stored/forwarded on purchases.
     */
    function _forwardFunds() internal {
        wallet.transfer(msg.value);
    }

    /**
     * @dev low level token purchase ***DO NOT OVERRIDE***
     * @param _beneficiary Address performing the token purchase
     */
    function buyTokens(address _beneficiary) public payable {
        uint256 weiAmount = msg.value;
        _preValidatePurchase(_beneficiary, weiAmount);

        // calculate token amount to be created
        uint256 tokens = _getTokenAmount(weiAmount);

        token.transfer(_beneficiary, tokens);

        emit TokenPurchase(msg.sender, _beneficiary, weiAmount, tokens);

        _forwardFunds();
    }
}
