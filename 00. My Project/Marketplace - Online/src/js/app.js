App = {
  web3Provider: null,
  contracts: {},

  initWeb3: async function () {
    // Modern dapp browsers...
    if (window.ethereum) {
      App.web3Provider = window.ethereum;
      try {
        // Request account access
        await window.ethereum.enable();
      } catch (error) {
        // User denied account access...
        console.error("User denied account access")
      }
    }
    // Legacy dapp browsers...
    else if (window.web3) {
      App.web3Provider = window.web3.currentProvider;
    }
    // If no injected web3 instance is detected, fall back to Ganache
    else {
      App.web3Provider = new Web3.providers.HttpProvider('http://localhost:7545');
    }
    web3 = new Web3(App.web3Provider);
    return App.initContract();
  },

  initContract: function () {
    $.getJSON('Marketplace.json', function (data) {
      // Get the necessary contract artifact file and instantiate it with truffle-contract
      var MarketplaceArtifact = data;
      App.contracts.Marketplace = TruffleContract(data);

      // Set the provider for our contract
      App.contracts.Marketplace.setProvider(App.web3Provider);

      return App.registerUser();
    });
    return App.bindEvents();
  },

  bindEvents: function () {
    $(document).on('click', '.registerbtn', App.registerUser);
    $(document).on('click', '.loginbtn', App.loginUser);
    $(document).on('click', '.createStorebtn', App.createStore);
    $(document).on('click', '.getStoresbtn', App.getStores);
    $(document).on('click', '.addProductbtn', App.addProduct);
  },
  registerUser: function (event){
    event.preventDefault();
    let username = $("#username").val();
    let role = $("[name='role']:checked").val();
    var marketplaceInstance;
    App.contracts.Marketplace.deployed().then(function (instance) {
      marketplaceInstance = instance;
      return marketplaceInstance.addUser(username, role);
    }).then(function(transaction){
      if(transaction.receipt.logs.length == 1) {
        $(".registerResult").text("You registered succesfully");
      } else {
        $(".registerResult").text("Registration failed");
      }
    }).catch(function (err) {
      console.log(err.message);
    });
  },

  loginUser: function (event){
    event.preventDefault();
    var marketplaceInstance;
    App.contracts.Marketplace.deployed().then(function (instance) {
      marketplaceInstance = instance;
      return marketplaceInstance.checkUser();
    }).then(function(role) {
      if (role.c[0] === 0) {
        $("#loginResult").text("Success - you are Administrator");
      } else if (role.c[0] === 1) {
        $("#loginResult").text("Success - you are Store Owner");
      } else if (role.c[0] === 2) {
        $("#loginResult").text("Success - you are Buyer");
      } else {
        $("#loginResult").text("Failed - you are not registered");
      }
    }).catch(function (err) {
      console.log(err.message);
    });
  },

  createStore: function (event){
    event.preventDefault();
    let storeName = $("#createStore #storeName").val();
    var marketplaceInstance;
    App.contracts.Marketplace.deployed().then(function (instance) {
      marketplaceInstance = instance;
      return marketplaceInstance.addStore(storeName);
    }).then(function(result) {
      $("#createStoreResult").text(`Success - You created a store called ${storeName}`);
    }).catch(function (err) {
      $("#createStoreResult").text('Failed - You cannot create a store');
      console.log(err.message);
    });
  },

  getStores: function (event){
    event.preventDefault();
    $("#getStoresResult").text("");
    var marketplaceInstance;
    App.contracts.Marketplace.deployed().then(function (instance) {
      marketplaceInstance = instance;
      return marketplaceInstance.getStoreOwnerStoreNames.call();
    }).then(function(stores) {
      console.log(stores)
      let table = $("<table><th>Store Name</th><th></th><th></th>");
      for (let i = 0; i < stores.length; i++) {
        let button = $("<button>").text("Show Products");
        button.on("click", function(event) {
          event.preventDefault();
          return App.getProducts(stores[i]);
        });
        let row = $(`<tr><td>${stores[i]}</td>`).append("<td>").append(button);
        table.append(row);
      }
      $("#getStoresResult").append(table);
    }).catch(function (err) {
      console.log(err.message);
    });
  },

  getProducts: function (storeName){
    var marketplaceInstance;
    App.contracts.Marketplace.deployed().then( function (instance) {
      marketplaceInstance = instance;
      return marketplaceInstance.getProducts(storeName);
    }).then(function(data) {
      console.log(data);
        let table = $("#allProducts");
        //[ids, titles, prices, quantities]
        for (let i = 0; i < data[0].length; i++) {
          let row = $("<tr>");
          let productId = $("<td>").text(data[0][i]);
          let productName = $("<td>").text(data[1][i]);
          let productPrice = $("<td>").text(data[2][i]);
          let productQuantity = $("<td>").text(data[3][i]);
          let priceButton = $(".savePricebtn").text("Save Price");
          priceButton.on("click", function(event) {
            event.preventDefault();
            return App.changePrice(data[0][i],data[2][i]);
          })
          let quantityButton = $(".saveQuantitybtn").text("Save Quantity");
          quantityButton.on("click", function(event) {
            event.preventDefault();
            return App.changeQuantity(data[0][i],data[3][i]);
          });
          let deleteButton = $(".deleteProductbtn").text("Delete Product");
          deleteButton.on("click", function(event) {
            event.preventDefault();
            return App.deleteProduct(data[0]);
          });
          row.append(productId).append(productName).append(productPrice).append(productQuantity);
          table.append(row);
        }
    }).catch(function (err) {
      console.log(err.message);
    });
  },

  addProduct: function (event){
      event.preventDefault();
      let storeName = $("#addProduct #storeName").val();
      let productTitle = $("#addProduct #productTitle").val();
      let productPrice = $("#addProduct #productPrice").val();
      let productQuantity = $("#addProduct #productQuantity").val();
      console.log([storeName,productTitle,productPrice,productQuantity]);
      App.contracts.Marketplace.deployed().then(function (instance) {
        marketplaceInstance = instance;
        return marketplaceInstance.addProduct(storeName,productTitle,parseInt(productPrice),parseInt(productQuantity));
      }).then(function(isAdded) {
        if(isAdded){
          $("#addProductResult").text("Successfully added the product");
        } else {
          $("#addProductResult").text("Failed adding the product");
        }
      }).catch(function (err) {
        console.log(err.message);
      });
  }
}

$(function () {
  $(window).load(function () {
    App.initWeb3();
  });
})