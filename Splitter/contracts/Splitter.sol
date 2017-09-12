pragma solidity ^0.4.4;

// consensys academy - smart contract program - module 4
// jeyakumar.sathish@emirates.com


contract Splitter {

  event LogEvent(address bob, address carol, uint amount);

  address public accountOneAlice;
  address public accountTwoBob;
  address public accountThreeCarol;

  modifier validateOwner() {
    require(msg.sender == accountOneAlice);
    _;
  }

  function Splitter(address accountTwo, address accountThree)
  {
    accountOneAlice = msg.sender;
    accountTwoBob = accountTwo;
    accountThreeCarol = accountThree;
  }

  function()
    validateOwner()
    public
    payable
  {
    require(msg.value > 0);
    accountTwoBob.transfer(msg.value/2);               
    accountThreeCarol.transfer(msg.value-(msg.value/2)); 
    
    LogEvent(accountTwoBob, accountThreeCarol, msg.value);
  }

  function kill() 
    validateOwner()
    public 
  {
    selfdestruct(accountOneAlice);
  }
}

