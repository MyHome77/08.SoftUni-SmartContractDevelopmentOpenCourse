pragma solidity >=0.4.22 <0.6.0;


contract Enumerations {
    
    enum Colors { Blue, Red, Green }
    
    Colors choice;
    Colors constant defaultChoice = Colors.Green;
    
    function chooseRed() public {
        choice = Colors.Red;
    }
    
    function choose(uint _color) public {
        choice = Colors(_color);
    }
    
    // Return type will be converted to (uint8), 
    // since enums are not part of ABI.
    // If uint8 doesn't fit all options, uint16 will be used and so on.
    function getChoice() public view returns(Colors) {
        return choice;
    }
    
    function getDefaultChoice() public pure returns (uint) {
        return uint(defaultChoice);
    }
    
}