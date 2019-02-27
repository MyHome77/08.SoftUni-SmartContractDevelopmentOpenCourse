pragma solidity >=0.4.22 <0.6.0;

contract CrowdsaleContract {
     enum State { CROWDSALE, OPEN }

    

    struct UserData {

        uint balance;

        bool hasTokens;

        bool isValue;

    }

    

    event withdrawEvent (string msg, uint _amount);

    event tokenPurchaseEvent (address indexed adr, uint _amount);

    event exchangeTokensEvent (address indexed sender, address indexed receiver, uint _amount);

    

    address owner;

    uint creationTimestamp;

    State currentState;

    mapping(address => UserData) public balances;

    address[] public allTokenHolders;



    modifier onlyOwner {

        require(msg.sender == owner);

        _;

    }

    

    modifier isCrowdsale {

        require(currentState == State.CROWDSALE);

        _;

    }

    

    modifier isOpenState {

        require(currentState == State.OPEN);

        _;

    }

    

    modifier canTransfer (uint _amount) {

        require(balances[msg.sender].balance >= _amount && _amount > 0);

        _;

    }

    

    function TokenHomework () public {

        owner = msg.sender;

        currentState = State.CROWDSALE;

        creationTimestamp = now;

    }

    

    function withdrawFunds(uint amount) public onlyOwner {
        
        assert(now - creationTimestamp > 1 year);

        assert(amount <= this.balance);

        msg.sender.transfer(amount);

        withdrawEvent("Withdrawal of funds has been initiated!", amount);

    }

    

    function buyToken() public payable isCrowdsale {

        //Switches State from CROWDSALE to OPEN

        if (now - creationTimestamp > 5 minutes) {

            currentState = State.OPEN;

            assert(false);

        } else {

            uint tokensBought = msg.value / 1 ether * 5;

            

            //User already bought tokens

            if (balances[msg.sender].isValue) {

                balances[msg.sender].balance+=tokensBought;    

            } else {

                //First time buying tokens

                balances[msg.sender] = UserData({balance : tokensBought, hasTokens : tokensBought != 0, isValue : tokensBought != 0});

                allTokenHolders.push(msg.sender);

            }

            tokenPurchaseEvent(msg.sender, tokensBought);

        }

    }

    

    function exchangeTokens (uint _amount, address receiveAdr) public isOpenState canTransfer(_amount) {

        balances[msg.sender].balance -= _amount;

        if (balances[receiveAdr].isValue) {

            balances[receiveAdr].balance += _amount;

        } else {

            balances[receiveAdr] = UserData({balance : _amount, hasTokens : true, isValue : true});

            allTokenHolders.push(receiveAdr);

        }

        

        exchangeTokensEvent(msg.sender, receiveAdr, _amount);

        

        if (balances[msg.sender].balance == 0) {

            balances[msg.sender].hasTokens = false;

        }

    }
}