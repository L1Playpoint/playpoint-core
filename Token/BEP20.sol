// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../Helpers/ERC20.sol";

contract BEP20 is ERC20 {
    constructor(uint256 initialSupply, string memory _name, string memory _symbol) ERC20(_name, _symbol) {
        _mint(msg.sender, initialSupply);
    }
}