pragma solidity ^0.5.0;
library ProductLib {
	struct Product {
		bytes32 id;
		string title;
		uint256 price;
		uint256 quantity;
	}
	
	/** @dev Creates a product with 4 properties id, title, price and quantity.
		* @param _title Title of the product.
		* @param _price Price of the product.
		* @param _quantity Quantity of the product.
		* @return Product Copy of the product.
		*/

	function createProduct(string memory _title, uint256 _price, uint256 _quantity) internal view returns (Product memory){
		return Product({id: keccak256(abi.encodePacked(_title, now)), title: _title, price: _price, quantity: _quantity});
	}
}