pragma solidity ^0.5.0;
pragma experimental ABIEncoderV2;

import "./ProductLib.sol";
import "./StoreLib.sol";

/** @title Marketplace. */

contract Marketplace {

    using StoreLib for StoreLib.Store;

	bool private isStopped = false;
	address payable public owner;
	mapping (address => User) public users;
	mapping (address => StoreLib.Store[]) public stores;
	mapping (bytes32 => StoreLib.Store) public storesById;
	mapping (address => string[]) public storeNames;
	mapping (address => mapping (bytes32 => ProductLib.Product[])) public productsByStoreId;
	mapping (bytes32 => ProductLib.Product) public productsById;
	modifier onlyAdministrator {
		require(users[msg.sender].role == UserEnum.Administrator);
		_;
	}
	modifier onlyNotAdministrator {
		require(users[msg.sender].role != UserEnum.Administrator);
		_;
	}
	modifier onlyStoreOwner {
		require(users[msg.sender].role == UserEnum.StoreOwner);
		_;
	}
	modifier onlyNotStoreOwner {
		require(users[msg.sender].role != UserEnum.StoreOwner);
		_;
	}
	modifier onlyBuyer {
		require(users[msg.sender].role == UserEnum.Buyer);
		_;
	}
	modifier onlyNotBuyer {
		require(users[msg.sender].role != UserEnum.Buyer);
		_;
	}
	modifier onlyExistingStores {
		require(stores[msg.sender].length > 0);
		_;
	}
	modifier onlyWhenStopped {
        require(isStopped);
        _;
    }
	modifier onlyAuthorized {
        require(isStopped);
        _;
    }

	event LogAddedUser(address administrator, string username, UserEnum role);
	event LogAddedStore(bytes32 storeId, address storeOwner, string storeName);
	event LogAddedProduct(bytes32 storeId, address storeOwner, string productTitle);
	event LogRemovedProduct(bytes32 storeId, address storeOwner, bytes32 productId);
	event LogChangedPrice(bytes32 productId, uint256 productPrice);
	event LogChangedQuantity(bytes32 productId, uint256 productQuantity);
	event LogBoughtProduct(address buyer, bytes32 productId, uint256 productQuantity);

	struct User {
		address addr;
		string username;
		UserEnum role;
	}

	/**
        * Constructor that sets the owner.
		*
        */

	constructor() public {
		owner = msg.sender;
	}

	enum UserEnum {
		Administrator,
		StoreOwner,
		Buyer,
		Unknown
	}
	//////ADMIN//////
	
    /** @dev Adds administrator and creates user with properties address, username and role.
      * @param _username Username of the administrator.
      */

	function addUser(string memory _username, string memory _role) public returns (bool) {
		if (keccak256(abi.encode(users[msg.sender].username)) == keccak256(abi.encode(_username))){
			return false;
		}
		UserEnum role = UserEnum.Administrator;
		bytes32 currentRole = keccak256(abi.encode(_role));
		if(currentRole == keccak256(abi.encode("Store Owner"))){
			role = UserEnum.StoreOwner;
		} else if (currentRole == keccak256(abi.encode("Buyer"))) {
			role = UserEnum.Buyer;
		}
		User memory currentUser = User({addr: msg.sender, username: _username, role: role});
		users[msg.sender] = currentUser;
		emit LogAddedUser(msg.sender, _username, role);
		return true;
    }

	/** @dev Checks for existing user and returns his role.
		* @return string Role of user.
		*/

	function checkUser() public view returns (UserEnum){
		if(users[msg.sender].addr != msg.sender){
			return UserEnum.Unknown;
		}
		return users[msg.sender].role;
	}

	/** @dev Creates a store with 3 properties id, owner and name of the store.
		* @param _storeName Name of the store.
		* @return bool Is added successfully.
		*/

	function addStore(string memory _storeName) public onlyStoreOwner returns (bool) {
		for (uint256 i = 0; i < storeNames[msg.sender].length; i++) {
			if (keccak256(abi.encode(storeNames[msg.sender][i])) == keccak256(abi.encode(_storeName))){
				return false;
			}
		}
		StoreLib.Store memory currentStore = StoreLib.createStore(msg.sender, _storeName);
		stores[msg.sender].push(currentStore);
		storeNames[msg.sender].push(_storeName);
		
		emit LogAddedStore(currentStore.id, msg.sender, _storeName);
		return true;
	}

	/** @dev Gets names of all stores of the store owner.
		* @return string[] Array of store names.
		*/

	function getStoreOwnerStoreNames() public view returns (string[] memory){
		return storeNames[msg.sender];
	}

	function getStoreOwnerStores() public view returns (bytes32[] memory, string[] memory){
		bytes32[] memory ids;
		string[] memory currentStoreNames;
		for (uint8 i = 0; i < stores[msg.sender].length; i++) {
			ids[i] = stores[msg.sender][i].id;
			currentStoreNames[i] = stores[msg.sender][i].storeName;
		}
		return (ids, currentStoreNames);
	}
		/** @dev Adds a product with 4 properties id, title, price and quantity.
		* @param _storeId Id of the store.
		* @param _title Title of the product.
		* @param _price Price of the product.
		* @param _quantity Quantity of the product.
		* @return bool Is successfully added.
		*/

	function addProduct(bytes32 _storeId, string memory _title, uint256 _price, uint256 _quantity) public onlyStoreOwner returns (bool) {
		if(storesById[_storeId].id != _storeId && storesById[_storeId].owner != msg.sender){
			return false;
		}
		if(_price <= 0 || _quantity < 0){
			return false;
		}
		ProductLib.Product memory currentProduct = ProductLib.createProduct(_title, _price, _quantity);
		productsByStoreId[msg.sender][_storeId].push(currentProduct);
		productsById[currentProduct.id] = currentProduct;
		
		emit LogAddedProduct(_storeId, msg.sender, _title);
		return true;
	}

	/** @dev Gets all product from a store with specified ID and returns 4 arrays (product ID, product title, product price and product quantity).
		* @param _storeId Id of the store.
		* @return ids Array with product IDs.
		* @return titles Array with product titles.
		* @return prices Array with product prices.
		* @return quantities Array with product quantities.
		*/

	function getProducts(bytes32 _storeId) public view returns (bytes32[] memory, string[] memory, uint256[] memory, uint256[] memory) {
		ProductLib.Product[] memory currentProducts = productsByStoreId[msg.sender][_storeId];
		bytes32[] memory ids;
		string[] memory titles;
		uint256[] memory prices;
		uint256[] memory quantities;
		for (uint8 i = 0; i < currentProducts.length; i++) {
			ids[i] = currentProducts[i].id;
			titles[i] = currentProducts[i].title;
			prices[i] = currentProducts[i].price;
			quantities[i] = currentProducts[i].quantity;
		}

		return (ids, titles, prices, quantities);
	}

	/** @dev Removes a product with specified store Id and product Id and returns true if successfull.
		* @param _storeId Id of the store.
		* @param _productId Id of the product.
		* @return bool Is successfully removed.
		*/

	function removeProduct(bytes32 _storeId, bytes32 _productId) public onlyStoreOwner returns (bool) {
		if(storesById[_storeId].id != _storeId && storesById[_storeId].owner != msg.sender && productsById[_productId].id != _productId){
			return false;
		}
		ProductLib.Product[] memory currentProducts = productsByStoreId[msg.sender][_storeId];
		for (uint8 i = 0; i < currentProducts.length; i++) {
			if(currentProducts[i].id == _productId){
				delete currentProducts[i];
			}
		}
		emit LogRemovedProduct(_storeId, msg.sender, _productId);
		return true;
	}

	/** @dev Changes the price of a product with a specific price and returns true if successfull.
		* @param _productId Id of the product.
		* @param _price Price of the product.
		* @return bool Is the price changed successfully.
		*/

	function changePrice(bytes32 _productId, uint256 _price) public onlyStoreOwner returns (bool) {
		if(productsById[_productId].id != _productId || _price <= 0){
			return false;
		}
		productsById[_productId].price = _price;
		
		emit LogChangedPrice(_productId, _price);
		return true;
	}

	/** @dev Changes the quantity of a product with a specific quantity and returns true if successfull.
		* @param _productId Id of the product.
		* @param _quantity Quantity of the product.
		* @return bool Is the quantity changed successfully.
		*/

	function changeQuantity(bytes32 _productId, uint256 _quantity) public onlyStoreOwner returns (bool) {
		if(productsById[_productId].id != _productId || _quantity < 0){
			return false;
		}
		productsById[_productId].quantity = _quantity;
		
		emit LogChangedQuantity(_productId, _quantity);
		return true;
	}

	/** @dev Buys a product with the specificied product Id and specificied quantity.
		* @param _productId Id of the product.
		* @param _quantity Quantity of the product to be bought.
		* @return bool Is bought successfully.
		*/

	function buyProduct(bytes32 _productId, uint256 _quantity) public onlyBuyer returns (bool) {
		if(productsById[_productId].id != _productId || _quantity <= 0){
			return false;
		}
		ProductLib.Product storage currentProduct = productsById[_productId];
		msg.sender.transfer(currentProduct.price * _quantity);
		
		emit LogBoughtProduct(msg.sender, _productId, _quantity);
		return true;
	}

	/** @dev Withdraw the money.
		* @param value Amount of the money.
		*/

	function withdraw(uint256 value) public {
		owner.transfer(value);
	}

	/** @dev Circuit breaker (emergency stop) pattern
			* 
			*/
	function stopContract() public onlyAuthorized {
        isStopped = true;
    }

    function resumeContract() public onlyAuthorized {
        isStopped = false;
    }
	function emergencyWithdraw() public onlyWhenStopped {
        owner.transfer(address(this).balance);
    }
}