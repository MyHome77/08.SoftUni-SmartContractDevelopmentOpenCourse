pragma solidity >=0.4.22 <0.6.0;

contract Owned {
    address owner;
    
    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }
    
    constructor() public {
        owner = msg.sender;
    }
}


contract Destructable is Owned {
    
    function() external payable  { }
    
    constructor() public { }
    
    function destroy() public onlyOwner {
        selfdestruct(msg.sender);
    }
    
    function destroyAndSend (address payable recipient) public onlyOwner {
        selfdestruct(recipient);
    }
}

library MemberLib {
    
    using SafeMath for uint;

    struct Member {
        address adr;
        uint256 totalDonation;
        uint256 latestDonationTimestamp;
        uint256 latestDonationValue;
    }
    function initializeMember(Member storage self, address _adr) public {
        self.adr = _adr;
        self.latestDonationTimestamp = now;
    }
    function removeMember(Member storage self) public {
        self.adr = address(0);
    }
    function hasDonated(Member storage self) public view returns (bool) {
            return now - self.latestDonationTimestamp < 1 hours;
    }
    function updateDonation(Member storage self, uint value) public {
            self.latestDonationTimestamp = now;
            self.latestDonationValue = value;
            self.totalDonation.add(value);
    }

}

library Voting {
    
    using SafeMath for uint;
    
    struct Vote {
        address proposedMember;
        uint voteFor;
        uint voteAgainst;
        mapping(address => bool) voted;
    }
    
    function initializeVote(Vote storage self, address _adr) public {
        self.proposedMember = _adr;
        self.voteFor = 0;
        self.voteAgainst = 0;
    }
    
    function vote(Vote storage self, address _voter, bool _voteFor) public {
        require(!self.voted[_voter]);
        
        self.voted[_voter] = true;
        if (_voteFor) {
            self.voteFor.add(1);
        } else {
            self.voteAgainst.add(1);
        }
    }
    
    function clearVote(Vote storage self) public {
        self.proposedMember = address(0);
    }
}

contract MemberVoter is Owned, Destructable {
    
    using SafeMath for uint;
    using MemberLib for MemberLib.Member;
    using Voting for Voting.Vote;

    mapping (address => MemberLib.Member) public members;
    mapping (bytes32 => Voting.Vote) public votings;
    
    uint membersCount;
    uint activeVotings;
    
    event LogNewMemberProposal(address indexed _adr);
    event LogMemberApproved(address indexed _adr);
    event LogMemberRejected(address indexed _adr);
    event LogMemberRemoval(address indexed _adr);
    event LogNewDonation(address indexed _adr, uint _value);

    modifier onlyMember(address _adr) {
        require(members[_adr].adr != address(0));
        if (!_canRemoveMember(members[_adr])) {
            _;
        }
    }
    
    modifier isNotMember(address _adr) {
        require(members[_adr].adr == address(0));
        _;
    }
    
    constructor() public {
        _addMember(msg.sender);
    }
    
    function _canRemoveMember(MemberLib.Member storage member) internal returns (bool) {
        if (activeVotings == 0 && member.adr != owner && !member.hasDonated()) {
            _removeMember(member);
            return true;
        }
        return false;
    }
    
    function _addMember (address _adr) internal {
        members[_adr].initializeMember(_adr);
        membersCount.add(1);
        emit LogMemberApproved(_adr);
    }
    
    function _removeMember (MemberLib.Member storage member) internal {
        member.removeMember();
        membersCount.sub(1);
        emit LogMemberRemoval(member.adr);
    }
    
    function _clearVoting (Voting.Vote storage vote) internal {
        vote.clearVote();
        activeVotings.sub(1);
    }
    
    function proposeMember(address _adr) public onlyMember(msg.sender) isNotMember(_adr) returns (bytes32) {
        require(members[msg.sender].hasDonated());
        
        bytes32 voteID = keccak256(abi.encodePacked(_adr, now));
        votings[voteID].initializeVote(_adr);
        activeVotings.add(1);
        
        emit LogNewMemberProposal(_adr);
        return voteID;
    }
    
    function removeMember(address _adr) public onlyOwner {
        require(msg.sender != owner);
        _removeMember(members[_adr]);    
    }
    
    function vote (bytes32 votingID, bool _voteFor) public onlyMember(msg.sender) {
        Voting.Vote storage voting = votings[votingID];
        require(voting.proposedMember != address(0));
        
        voting.vote(msg.sender, _voteFor);
        if (_voteFor && voting.voteFor.mul(2) >= membersCount) {
            _addMember(voting.proposedMember);
            _clearVoting(voting);
        } else if (!_voteFor && voting.voteAgainst.mul(2) >= membersCount) {
            emit LogMemberRejected(voting.proposedMember);
            _clearVoting(voting);
        }
    }
    
    function donate () public payable onlyMember(msg.sender) {
        require(msg.value != 0);
        members[msg.sender].updateDonation(msg.value);
        emit LogNewDonation(msg.sender, msg.value);
    }
}

library SafeMath {

    /**

     * @dev Multiplies two unsigned integers, reverts on overflow.

     */

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {

        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the

        // benefit is lost if 'b' is also tested.

        // See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522

        if (a == 0) {

            return 0;

        }



        uint256 c = a * b;

        require(c / a == b);



        return c;

    }



    /**

     * @dev Integer division of two unsigned integers truncating the quotient, reverts on division by zero.

     */

    function div(uint256 a, uint256 b) internal pure returns (uint256) {

        // Solidity only automatically asserts when dividing by 0

        require(b > 0);

        uint256 c = a / b;

        // assert(a == b * c + a % b); // There is no case in which this doesn't hold



        return c;

    }



    /**

     * @dev Subtracts two unsigned integers, reverts on overflow (i.e. if subtrahend is greater than minuend).

     */

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b <= a);

        uint256 c = a - b;



        return c;

    }



    /**

     * @dev Adds two unsigned integers, reverts on overflow.

     */

    function add(uint256 a, uint256 b) internal pure returns (uint256) {

        uint256 c = a + b;

        require(c >= a);



        return c;

    }



    /**

     * @dev Divides two unsigned integers and returns the remainder (unsigned integer modulo),

     * reverts when dividing by zero.

     */

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b != 0);

        return a % b;

    }

}