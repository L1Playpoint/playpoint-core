// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./Helpers/ERC20.sol";
import "./Helpers/SafeMath.sol";

/**
 * @title PlaypointFactory
 * @dev PlaypointFactory is a base contract for managing a token crowdsale,
 * allowing investors to purchase tokens with bnb. This contract implements
 * such functionality in its most fundamental form and can be extended to provide additional
 * functionality and/or custom behavior.
 * The external interface represents the basic interface for purchasing tokens, and conform
 * the base architecture for crowdsales. They are *not* intended to be modified / overriden.
 * The internal interface conforms the extensible and modifiable surface of crowdsales. Override
 * the methods to add functionality. Consider using 'super' where appropiate to concatenate
 * behavior.
 */
contract PlaypointFactory {
    using SafeMath for uint256;
    ERC20 public token;
    address payable public wallet;
    uint256 public rate;

    /**
     * Event for token purchase logging
     * @param purchaser who paid for the tokens
     * @param value weis paid for purchase
     * @param amount amount of tokens purchased
     */
    event TokenPurchase(
        address indexed purchaser,
        uint256 value,
        uint256 amount
    );

    /**
     * @param _rate Number of token units a buyer gets per wei
     * @param _token Address of the token being sold
     */
    constructor(uint256 _rate, ERC20 _token) {
        require(_rate > 0);

        rate = _rate;
        wallet = payable(msg.sender);
        token = _token;
    }

    /**
     * @dev Validation of an incoming purchase. Use require statements to revert state when conditions are not met. Use super to concatenate validations.
     * @param _weiAmount Value in wei involved in the purchase
     */
    function _preValidatePurchase(uint256 _weiAmount) internal view {
        require(msg.sender != address(0));
        require(
            _weiAmount >= 5 * 10**16,
            "Minimum purchase amount is 0.05 BNB!"
        );
    }

    /**
     * @dev Source of tokens. Override this method to modify the way in which the crowdsale ultimately gets and sends its tokens.
     * @param _tokenAmount Number of tokens to be emitted
     */
    function _deliverTokens(uint256 _tokenAmount) internal {
        token.transfer(payable(msg.sender), _tokenAmount);
    }

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
        return _weiAmount.mul(rate);
    }

    /**
     * @dev Determines how BNB is stored/forwarded on purchases.
     */
    function _forwardFunds() internal {
        wallet.transfer(msg.value);
    }

    /**
     * @dev low level token purchase ***DO NOT OVERRIDE***
     */
    function buyTokens() public payable {
        uint256 weiAmount = msg.value;

        _preValidatePurchase(weiAmount);

        uint256 tokens = _getTokenAmount(weiAmount);

        _deliverTokens(tokens);

        emit TokenPurchase(msg.sender, weiAmount, tokens);

        _forwardFunds();
    }

    function withdrawTokenToWallet(uint256 _amount) public {
        require(msg.sender == wallet, "Only the wallet can withdraw tokens!");
        token.transfer(wallet, _amount);
    }
}
