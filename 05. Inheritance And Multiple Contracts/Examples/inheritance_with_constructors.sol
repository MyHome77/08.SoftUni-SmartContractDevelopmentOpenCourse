pragma solidity >=0.4.22 <0.6.0;

contract Parent{
    constructor(uint meaningOfLife) public {
        //...
    }
}

//constructor arguments can be passed in the child contract declaration
contract ChildOne is Parent(42) {
    //...
}

contract ChildTwo is Parent {
    //constructor arguments can be passed in the child's constructor declaration
    constructor(uint num) Parent(num*3) public {
        //...
    }
}

