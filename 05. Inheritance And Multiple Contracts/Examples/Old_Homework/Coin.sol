pragma solidity >=0.4.22 <0.6.0;


contract MetaCoin {
	string public name = "TEST";
	string public symbol = "TST";
	uint256 public decimals = 18;
	uint256 public totalSupply;
	
	
	mapping (address => uint) balances;

	constructor (uint256 _totalSupply) public {
		balances[msg.sender] = _totalSupply * 10**decimals;
	}
	
	function() external {
		assert(false);
	}

	function sendCoin(address receiver, uint amount) public returns(bool sufficient) {
		if (balances[msg.sender] < amount) return false;
		balances[msg.sender] -= amount;
		balances[receiver] += amount;
		return true;
	}
}