// contracts/Bid.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// Import Auth from the access-control subdirectory
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "./AEXToken.sol";
import "./Swap.sol";

contract Bid is Ownable {
    // AEX represents the token smart contract
    Swap public swap;
    AEXToken public token;
    // fire when newAdvertiser is registered
    event newAdvertiser(address addr);

    // fire when new ad is placed
    event newAd(uint256 adId, uint256 value);

    // fire when funds transferred
    event Transfer(address from, address to, uint256 value);
    // event Approval(owner, spender, value);

    mapping(address => bool) isRegistered;

    // initialize bidCount to 0
    uint public bidCount = 0;

    uint256 curBid;
    // sets the bid floor bid passed in param
    // TO USE when swapping tokens
    constructor(uint256 _curBid, Swap _swap) {
        curBid = _curBid;
        swap = _swap;
        token = swap.token();
    }
    
    
    // register advertiser for bidding (onlyOwner + admin[later])
    function register(address _address) public onlyOwner {
        require(token.balanceOf(_address) > 0, "please buy AEX tokens first");
        require(_address != owner(), "The owner of this contract cannot register");
        require(isRegistered[_address] == false, "address is already registered");
        isRegistered[_address] = true;
        emit newAdvertiser(_address);
        // fallback for nonvalid addresses 
    }


    // place bid (ensure address is eligible for registered and owner)
        // ensure bid is higher than current bid
        // creates an ad id
        // fires event
        // mapping of address to ad id


    function placeBid (uint256 _value) public {
        // require(token.balanceOf(msg.sender) > 0, "please buy AEX tokens first");
        require(isRegistered[msg.sender] == true, "please register your address");
        require(token.balanceOf(msg.sender) >= _value, "you do not have enough tokens");
        // can be replaced with msg.value
        require(_value > curBid, "please bid above current bid");
        
        // transfer ad space 
        // call send transaction to contract address wallet (look at swap.sellTokens())
        // requires approval to send tokens to this contract
        token.transferFrom(msg.sender,address(this), _value);
        // swap.sellTokens(_value);
        emit Transfer(msg.sender, address(this), _value);
        // incremement bid count which is the ad ID
        bidCount++;
        curBid = _value;
        emit newAd(bidCount, _value);
    }
    
    function currentBid() public view returns (uint256) {
        return curBid;
    }

    function getToken() public view returns(address) {
        return address(token);
    }

    function getSwap() public view returns(address) {
        return address(swap);
    }

}