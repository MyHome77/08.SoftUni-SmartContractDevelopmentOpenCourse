pragma solidity >=0.4.22 <0.6.0;

contract Agent{
    address master;
    uint lastOrder;
    
    modifier OnlyMaster{
        require(msg.sender == master);
        _;
    }
    
    modifier CanReceiveOrder{
        require(isReady());
        _;
    }
    
   constructor(address _master) public {
        master = _master;
    }
    
    function receiveOrder() public OnlyMaster CanReceiveOrder {
        lastOrder = now;
    }
    
    function isReady() public view returns(bool) {
        return now > lastOrder + 15 seconds;
    }
}

contract Master{
    address owner;
    
    mapping(address => bool) approvedAgents;
    
    modifier OnlyOwner{
        require(owner == msg.sender);
        _;
    }
    
    modifier AgentExists(Agent agent){
        require(approvedAgents[address(agent)]);
        _;
    }
    
    constructor() public {
        owner = msg.sender;
    }
    
    function newAgent() public OnlyOwner returns(Agent) {
        Agent agent = new Agent(address(this));
        
        approvedAgents[address(agent)] = true;
        
        return agent;
    }
    
    function addAgent(Agent agent) public OnlyOwner {
        approvedAgents[address(agent)] = true;
    }
    
    function giveOrder(Agent agent) public OnlyOwner AgentExists(agent) {
        agent.receiveOrder();
    }
    
    function queryOrder(Agent agent) public view AgentExists(agent) returns(bool) {
        return agent.isReady();
    }
}
