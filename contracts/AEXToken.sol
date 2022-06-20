// contracts/GLDToken.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract AEXToken is ERC20, Ownable {

    constructor(uint256 _initialSupply) ERC20("AdExchange", "AEX") {
        _mint(address(this), _initialSupply);
    }
    /*
    @ dev new minting for external swap contract
    */

    function mint(address account, uint amount) external onlyOwner {
        _mint(account, amount);
    }
    
}