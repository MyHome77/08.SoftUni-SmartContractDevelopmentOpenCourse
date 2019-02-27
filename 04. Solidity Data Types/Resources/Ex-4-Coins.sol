pragma solidity >=0.4.22 <0.6.0;


contract RainbowCoinContract {

	mapping(address => mapping(uint256 => uint256))	public balances;
	
	constructor() public {
	
		balances[msg.sender][0] = 10000;	// red
		balances[msg.sender][1] = 10000;	// green
		balances[msg.sender][2] = 10000;	// blue
		
	}
	
	function sendCoins(uint256 _coinIndex, address _to, uint256 _amount) public
	{
		require(balances[msg.sender][_coinIndex] >= _amount);
		
		balances[msg.sender][_coinIndex] -= _amount;
		
		balances[_to][_coinIndex] += _amount;
	}
}


