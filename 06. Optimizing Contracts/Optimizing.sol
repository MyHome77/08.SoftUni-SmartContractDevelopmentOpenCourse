pragma solidity >=0.4.22 <0.6.0;


//this contract is optimized, don't touch it.
contract Ownable {
    address public owner;
    
    
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    
    //Constructor Changed
    constructor() public {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }
    
    function transferOwnership(address newOwner) public onlyOwner {
        require(newOwner != address(0));
        emit OwnershipTransferred(owner, newOwner);
        owner = newOwner;
    }

}

//The objective is to have a contract that has members. The members are added by the owner and hold information about their address, timestamp of being added to the contract and amount of funds donated. Each member can donate to the contract.
//Many anti-patterns have been used to create them.
//Some logical checks have been missed in the implementation.
//Objective: lower the publish/execution gas costs as much as you can and fix the logical checks.

//Changed contract to library - removed variable Member, constructor became function to createMember, added parameter self, removed getter function.
library MemberLib {
    struct Member {
        address adr;
        uint joinedAt;
        uint fundsDonated;
    }
    
    //Member member;
    //Constructor became function to createMember
    function createMember(address adr) internal view returns (Member memory){
        return Member(adr, now, 0);
        //member.adr = adr;
        //member.joinedAt = now;
        //member.fundsDonated = 0;
    }
    
    //Added parameter self
    function donated(Member storage self, uint value) public {
        self.fundsDonated += value;
    }
    
    //function get() public view returns (address){//, uint, uint) {
    //    return (member.adr);//, member.joinedAt, member.fundsDonated);
    //}
}

contract Membered is Ownable{
    //Added using MemberLibrary
    using MemberLib for MemberLib.Member;
    mapping(address => MemberLib.Member) members;
    
    //Removed unnecessary array memberList and variables tmp1 tmp2 tmp3
    //address[] memberList;
    
    //address tmp1;
    //uint tmp2;
    //uint tmp3;
    
    //Removed unnecessary - (tmp1, tmp2, tmp3) = members[msg.sender].get(); and changed require
    modifier onlyMember {
        require(members[msg.sender].adr == msg.sender);
        _;
    }
    
    function addMember(address adr) public onlyOwner {
        MemberLib.Member memory member = MemberLib.createMember(adr);
        
        members[adr] = member;
        //memberList.push(adr);
    }
    
    function donate() public onlyMember payable {
        require(msg.value > 0);
        
        members[msg.sender].donated(msg.value);
    }
}