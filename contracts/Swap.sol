// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "hardhat/console.sol";
import "./AEXToken.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract Swap is Ownable {
  string public name = "EthSwap Instant Exchange";
  AEXToken public token; // token represents the Token smart contract
  uint public rate = 100; // look at extracting another token price data
  // 1 ETH == 100 tokens
  event TokensPurchased(
    address account,
    address token,
    uint amount,
    uint rate
  );

  event TokensSold(
    address account,
    address token,
    uint amount,
    uint rate
  );

  constructor(AEXToken _token) {
    // need the code and address of the token contract
    token = _token;
    // token.mint(address(this), _initialSupply);
  }


  function buyTokens() public payable {
    // redemption rate = # of token recieved for 1 ether
    // Calculate the number of tokens to buy
    // uint tokenAmount = msg.value * rate;
    uint tokenAmount = msg.value * rate;

    // require token contract to have enough (this refers to the token object) >= tokenAmount
    require(token.balanceOf(address(this)) >= tokenAmount, "contract does not have enough tokens");

    // do we have to transfer eth from msg.sender to the token contract?
    // Transfer tokens to the user
    token.transfer(msg.sender, tokenAmount);
    
    // Emit an event
    emit TokensPurchased(address(this), msg.sender, tokenAmount, rate);

    // tests
    // assert(token.balanceOf(address(this)) == token.)
  }

  function sellTokens(uint _amount) public {
    // User can't sell more tokens than they have
    require(token.balanceOf(msg.sender) >= _amount, "you do not have enough tokens");

    // Calculate the amount of Ether to redeem
    uint etherAmount = _amount / rate;

    // Require that Swap has enough Ether to send
    require(address(this).balance >= etherAmount, "contract of AEXToken doesn't have enough ether");

    // Perform sale
    // *****this reverts (requires approval of THIS contract)
    token.transferFrom(msg.sender, address(this), _amount);
    // sends ether back to msg.sender from this contract
    payable(msg.sender).transfer(etherAmount);

    // Emit an event
    emit TokensSold(msg.sender, address(this), _amount, rate);
  }

  function getRate() public view returns(uint) {
    return rate;
  }

  function getEthBalance(address _addr) public view returns(uint256) {
    return address(_addr).balance;
  }

  function getTokenBalance(address _addr) public view returns(uint256) {
    return token.balanceOf(_addr);
  }


  // function approve(address spender, uint256 amount) public virtual override onlyOwner returns (bool) {
  //       // require(isApproved[spender] != true);
  //       address owner = address(this);
  //       _approve(owner, spender, amount);
  //       // isApproved[spender] = true;
  //       return true;
  //       // 100000000000000000000000
  //       // emit Approval(owner, spender, amount);
  //   }

  // function getSwapBalance() public view returns(uint256) {
  //   return token.balanceOf(address(this));
  // }

  // function transfer(uint256 amount) external payable{
  //   console.log("Minted AEX tokens balance is %s tokens", token.balanceOf(address(token)));
  //   console.log("Sender balance is %s ETH tokens", msg.sender.balance);
  //   console.log("Trying to send %s AEX tokens to %s", amount, msg.sender);
  //   console.log("MSG.value is %s AEX tokens", msg.value);

  //   require(msg.sender.balance >= amount, "Not enough tokens");

  //   // msg.sender.balance -= amount;
  //   // to.balance += amount;
// }

  function getTokenAddress() public view returns(address) {
    return address(token);
  }


}
