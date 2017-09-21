 solidity ^0.4.0;
//consensus - developer program
//jeyakumar.sathish@emirates.com
contract Remittance {
   
    address public escrowOwner;
    uint public escrowFee;
   
    struct FirstParty{
        uint amount;
        bytes32 passwordHash;
        uint deadline;
    }

    function Remittance(){
        escrowOwner = msg.sender;
        escrowFee = tx.gasprice -1;
    }
    
    mapping(address=>uint) public balances;
    mapping(address=>FirstParty) public firstParty;
    
    modifier validateOwner() {
      require(escrowOwner == msg.sender);
    _;
   }
  

    function startTransaction(bytes32 secretCode, uint duration)
    public
    payable
    returns(bool success){
        require(msg.value>escrowFee);
        require(firstParty[msg.sender].deadline<block.number); 
        firstParty[msg.sender].amount = msg.value-escrowFee;
        firstParty[msg.sender].passwordHash = secretCode;
        firstParty[msg.sender].deadline = block.number+duration;
        escrowOwner.transfer(escrowFee);
        return true;
    }
    

    function requestFundsfromParty1(bytes32 secretCode, address firstPartyAddress) 
    public 
    returns(bool success){
        require( firstPartyAddress !=0);
        require(firstParty[firstPartyAddress].deadline>block.number);
        require(firstParty[firstPartyAddress].passwordHash == secretCode); 
        firstParty[firstPartyAddress].deadline = 0; 
        
        uint amount =firstParty[firstPartyAddress].amount;
        firstParty[firstPartyAddress].amount = 0;
        
        msg.sender.transfer(amount);
        return true;
    }

    function revertTransaction()
    public
      returns(bool success){
        require(firstParty[msg.sender].deadline<=block.number);
        require(firstParty[msg.sender].amount>0);
        
        uint amount = firstParty[msg.sender].amount;
        firstParty[msg.sender].amount = 0;
        firstParty[msg.sender].deadline = 0;
        msg.sender.transfer(amount);
        return true;
    }
     
   function kill() 
    validateOwner()
    public 
  {
    selfdestruct(escrowOwner);
   }

  }





