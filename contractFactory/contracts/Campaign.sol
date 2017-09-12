//contract factory practice

pragma solidity ^0.4.4;

contract Campaign{
    address public owner;
    uint    public deadline;
    uint    public goal;
    uint    public fundsRaised;
    bool    public refundsSent;
    
    struct FunderStruct {
        address funder;
        uint amount;
    }
    
    FunderStruct[] public funderStructs;
    
    event LogContribution(address sender, uint amount);
    event LogRefundSent(address funder, uint amount);
    event LogWithdrawal(address beneficiary, uint amount);
    
    function Campaign(uint campaignDuration, uint campaignGoal){
        owner = msg.sender;
        deadline = block.number + campaignDuration;
        goal = campaignGoal;
    }
    
    function isSuccess()
    public
    constant
    returns(bool inDeed)
    {
        return (fundsRaised == goal);
    }
    
    function hasFailed()
    public
    constant
    returns(bool hasIndeed)
    {
        return (fundsRaised < goal && block.number > deadline);
    }
  
    function contribute() 
        public 
        payable 
        returns 
        (bool success)
    {
        require(!(msg.value==0));
        require(!isSuccess()) ;
        require(!hasFailed()) ;
        
        
        fundsRaised += msg.value;
        
        FunderStruct memory newFunder;
        newFunder.funder = msg.sender;
        newFunder.amount = msg.value;
        funderStructs.push(newFunder);
        LogContribution(msg.sender, msg.value);
        return true;
    }
    
    function 
        withdrawFunds () 
        public 
        returns(bool success)
        {
        require(!(msg.sender != owner));
        
        require(isSuccess());
        uint amount = this.balance;
        require(owner.send(amount));
        LogWithdrawal(owner, this.balance);
        return true;
    }
    
    function sendRefunds() 
        public 
        returns(bool success)
    {
        require(!(msg.sender != owner));
        require(!refundsSent) ;
        require(hasFailed());
        
        uint funderCount = funderStructs.length;
        for(uint i=0; i < funderCount; i++)
        {
            require(funderStructs[i].funder.send(funderStructs[i].amount));
            LogRefundSent(funderStructs[i].funder, funderStructs[i].amount);
        }
        refundsSent = true;
        return true;
    }
    
}