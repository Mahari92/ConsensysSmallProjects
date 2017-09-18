pragma solidity ^0.4.4;

// consensys academy - smart contract program - module 4
// jeyakumar.sathish@emirates.com


contract Splitter {

  event LogEvent(address accountB, address accountC, uint amount);
  event LogEvent(address withdrawAccount, uint amount);
  
  address public accountB;
  address public accountC;
  address public owner;
 
  mapping(address => uint) balances;
   

  modifier validateOwner() {
    require(owner == msg.sender);
    _;
  }
  
  modifier validAddress(address addr) {
      require (addr!=0);
      _;
  }

  function Splitter(address b, address c) validAddress(b) validAddress(c)
  {
    owner = msg.sender;   
    accountB = b;
    accountC = c;
  }

  function split()
    validateOwner()
    public
    payable returns (bool successStatus)
  {
    require(msg.value > 1);
    
    if(msg.value %2 ==1){
        balances[owner] +=1;
    }
    var amount = msg.value/2;
    balances[accountB] += amount;
    balances[accountC] += amount;
    
    LogEvent(accountB, accountC, msg.value);
    
    return true;
  }

  function kill() 
    validateOwner()
    public 
  {
    selfdestruct(owner);
  }
  
   function withdraw() {
        
        require(balances[msg.sender]>0);
        var amount = balances[msg.sender];
        balances[msg.sender] =0;
        msg.sender.transfer(amount);
        
        LogEvent(msg.sender,amount);
    
    }
}

