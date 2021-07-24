pragma solidity ^0.4.25;

contract CrowdfundingCampaign {
    struct Withdrawal {
        string description;
        uint value;
        address recipient;
        bool complete;
        uint approvalCount;
        mapping(address => bool) approvals;
    }
    
    Withdrawal[] public withdrawals;
    
    address public owner;
    mapping(address => bool) contributors;
    uint public contributorsCount;
    uint public minimumContribution;
    
    constructor(uint minimum, address creater) public {
        owner = creater;
        minimumContribution = minimum;
    }
    
    function contribute() public payable {
        require(msg.value >= minimumContribution);
        contributors[msg.sender] = true;
        contributorsCount++;
    }
    
    modifier onlyOwner(){
        require(msg.sender == owner);
        _;
    }
    
    modifier onlyContributor() {
        require(contributors[msg.sender]);
        _;
    }
    
    function createWithdrawal(string description, uint value, address recipient) public onlyOwner {
        Withdrawal memory newWithdrawal = Withdrawal({
            description: description,
            value: value,
            recipient: recipient,
            complete: false,
            approvalCount: 0
        });
        withdrawals.push(newWithdrawal);
    }
    
    function approveWithdrawal(uint index) public onlyContributor {
        Withdrawal storage withdrawal = withdrawals[index];
        
        require(!withdrawal.approvals[msg.sender]);
        
        withdrawal.approvals[msg.sender] = true;
        withdrawal.approvalCount++;
    }
    
    function finalizeWithdrawal(uint index) public onlyOwner {
        Withdrawal storage withdrawal = withdrawals[index];
        
        require(withdrawal.approvalCount >= (contributorsCount / 2));
        require(!withdrawal.complete);
        
        withdrawal.recipient.transfer(withdrawal.value);
        
        withdrawal.complete = true;
    }
}
