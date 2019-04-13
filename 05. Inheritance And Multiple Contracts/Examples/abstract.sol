pragma solidity >=0.4.22 <0.6.0;

//define abstract contract
contract Feline {
    function utterance() public returns (bytes32);
}

//implement the abstract method from parent
contract Cat is Feline {
    function utterance() public returns (bytes32) { return "miaow"; }
}
