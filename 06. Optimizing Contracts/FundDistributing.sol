pragma solidity ^0.5.1;

contract Ownable {
    address public owner;
    
    modifier onlyOwner {
        require(owner == msg.sender);
        _;
    }
    
    constructor() public {
        owner = msg.sender;
    }
}

library VotingLib {
    
    struct Voting {
        address targetAddress;
        uint256 value;
        mapping(address => bool) voted;
        uint256 votedFor;
        uint256 votedAgainst;
        uint256 targetVotes;
        bool exists;
        bool successful;
        bool finished;
    }
    
    function createVoting (address targetAddress, uint256 value, uint256 targetVotes) internal pure returns (Voting memory) {
        return Voting({
            targetAddress: targetAddress, 
            value: value, 
            votedFor: 0, 
            votedAgainst: 0, 
            targetVotes: targetVotes, 
            exists: true,
            successful: false,
            finished: false
        });
    }
    
    function vote (Voting storage self, bool voteFor, uint256 importance) internal returns (bool) {
        require(!self.finished);
        require(self.exists);
        require(!self.voted[msg.sender]);
        
        self.voted[msg.sender] = true;
        
        if(voteFor) {
            self.votedFor += importance;
            
            if(self.votedFor >= self.targetVotes) {
                self.finished = true;
                self.successful = true;
            }
        } else {
            self.votedAgainst += importance;
            
            if(self.votedAgainst >= self.targetVotes) {
                self.finished = true;
                self.successful = false;
            }
        }
        
        return self.finished;
    }
}

contract MemberVoter is Ownable {
    using VotingLib for VotingLib.Voting;
    
    mapping(bytes32 => VotingLib.Voting) votings;
    
    struct Member {
        address adr;
        uint256 importance;
    }
    
    mapping(address => Member) members;
    
    mapping(address => uint256) withdrawals;
    
    modifier onlyMember {
        require(members[msg.sender].importance > 0);
        _;
    }
    
    uint256 totalImportance;
    bool initialized;
    
    function init(address[] memory membersAddresses, uint256[] memory importance) public onlyOwner {
        require(membersAddresses.length >= 3);
        require(membersAddresses.length == importance.length);
        require(!initialized);
        initialized = true;
        
        uint256 totalImp = 0;
        
        for(uint256 i = 0; i < membersAddresses.length; i++) {
            members[membersAddresses[i]].adr = membersAddresses[i];
            members[membersAddresses[i]].importance = importance[i];
            
            require(importance[i] > 0);
            totalImp += importance[i];
        }
        
        totalImportance = totalImp;
    }
    
    function startVoting(address targetAddress, uint256 value) public onlyOwner returns (bytes32 ID) {
        require(targetAddress != address(0));
        require(value > 0);
        ID = keccak256(abi.encodePacked(targetAddress, value, now));
        
        require(!votings[ID].exists);
        
        VotingLib.Voting memory voting = VotingLib.createVoting(targetAddress, value, totalImportance / 2);
        
        votings[ID] = voting;
    }
    
    function castVote(bytes32 ID, bool voteFor) public onlyMember {
        VotingLib.Voting storage voting = votings[ID];
        
        if(VotingLib.vote(voting, voteFor, members[msg.sender].importance)) {
            if(voting.successful) {
                withdrawals[voting.targetAddress] += voting.value;
            }
        }
    }
    
    function withdraw() public {
        uint256 value = withdrawals[msg.sender];
        withdrawals[msg.sender] = 0;
        
        msg.sender.transfer(value);
    }
}