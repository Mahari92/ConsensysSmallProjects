pragma solidity ^0.4.0;
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
        escrowFee = 10000 ;
    }
    
    mapping(address=>uint) public balances;
    mapping(address=>FirstParty) public firstParty;

    function startTransaction(bytes32 password1, bytes32 password2, uint duration)
    public
    payable
    returns(bool success){
        require(msg.value>escrowFee);
        require(firstParty[msg.sender].deadline<block.number); 
        firstParty[msg.sender].amount = msg.value-escrowFee;
        firstParty[msg.sender].passwordHash = keccak256(password1,password2);
        firstParty[msg.sender].deadline = block.number+duration;
        escrowOwner.transfer(escrowFee);
        return true;
    }
    

    function requestFundsfromParty1(bytes32 password1, bytes32 password2, address firstPartyAddress)
    public 
    returns(bool success){
        require(firstParty[firstPartyAddress].deadline>block.number);
        require(firstParty[firstPartyAddress].passwordHash == keccak256(password1,password2)); 
        firstParty[firstPartyAddress].deadline = 0; 
        firstParty[firstPartyAddress].amount = 0; 
        msg.sender.transfer(firstParty[firstPartyAddress].amount);
        return true;
    }

    function revertTransaction()
    public
      returns(bool success){
        require(firstParty[msg.sender].deadline<=block.number);
        require(firstParty[msg.sender].amount>0);
        firstParty[msg.sender].amount = 0;
        firstParty[msg.sender].deadline = 0;
        msg.sender.transfer(firstParty[msg.sender].amount);
        return true;
    }
}




