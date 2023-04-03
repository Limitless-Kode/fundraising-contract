//SPDX-License-Identifier: MIT

pragma solidity ^0.8.11;

import "./ClaverToken.sol";

contract FundRaising{
    address public owner;
    address payable public withdrawalAddress;
    uint fundRaisingId;
    ClaverToken public token;
    FundRaisingState fundraisingState;
    mapping(address => Investor) investors;
    mapping(address => Donation[]) donations;
    uint256 totalRaised;

    constructor(ClaverToken _token, uint _fundRaisingId){
        owner = msg.sender;
        token = _token;
        fundraisingState = FundRaisingState.Active;
        fundRaisingId = _fundRaisingId;
    }

    enum FundRaisingState{
        Active,
        Completed,
        Failed
    }

    struct Donation{
        uint fundRaisingId;
        address payable investor;
        uint256 amount;
    }

    struct Investor{
        address payable investor;
        bool verified;
    }

    modifier isOwner{
        require(msg.sender == owner, "Insufficient permissions");
        _;
    }

    modifier isVerified{
        require(investors[msg.sender].verified == true, "You are not verified");
        _;
    }

    modifier isFundRaisingActive{
        require(fundraisingState == FundRaisingState.Active, "Fund raising is not active");
        _;
    }

    function verify(address _investor) public isOwner returns(bool){
        investors[_investor].verified = true;
        return true;
    }

    function setWithdrawalAddress(address _withdrawalAddress) public isOwner returns(bool){
        withdrawalAddress = payable(_withdrawalAddress);
        return true;
    }

    function donate() public payable isVerified isFundRaisingActive {
        uint256 _amount = msg.value;

        require(_amount > 0.01 ether, "Donation amount is too low");
    
        // Transfer tokens from the sender's account to the fundraising contract
        token.transferFrom(msg.sender, address(this), _amount);
        donations[msg.sender].push(Donation(fundRaisingId ,payable(msg.sender), _amount));

        // Update the total amount raised
        totalRaised += _amount;

        // Emit a fundraising received event
        emit FundraisingReceived(msg.sender, _amount);
    }

    function refund(address _recipient, uint _fundRaisingId) public isOwner returns(bool){
        uint256 totalDonations = 0;
        Donation[] memory _donations;
        uint j = 0;
        for(uint i = 0; i < donations[_recipient].length; i++){
            Donation memory currentDonation = donations[_recipient][i];
            if(_fundRaisingId == currentDonation.fundRaisingId){
                totalDonations += currentDonation.amount;
            }else{
                _donations[j++] = currentDonation;
            }
        }

        token.transfer(_recipient, totalDonations);
        emit Refunded(_recipient, totalDonations);
        return true;
    }

    function withdraw() public isOwner returns(bool){
        withdrawalAddress.transfer(totalRaised);
        return true;
    }

    function getDonationsByAddress(address _investor) public view returns(Donation[] memory){
        return donations[_investor];
    }

    function getTotalDonations() public view returns(uint256){
        return totalRaised;
    }

    event Refunded(address indexed recipient, uint256 amount);
    event FundraisingReceived(address indexed sender, uint256 amount);
}