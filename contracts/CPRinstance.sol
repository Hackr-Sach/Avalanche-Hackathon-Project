//SPDX-License-Identifier: BSD 3-Clause
pragma solidity 0.8.7;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
import "@chainlink/contracts/src/v0.8/VRFConsumerBase.sol";

// note* We will track users of a cpr using the benefactor array.
/*  2do
 [
   chainlink VRF
   -random distriution function
   -random appointments
   -set slash to true if conditions are met
   -invoke slash  will use chainlink VRF to instead of burning a token give it to 
    a random user in the system. to add salt to the wound >:D
    we could maybe invoke slash right from the vote2slash condition. if vote + current slashes breaks a threshold.
    slash the person who made the prop
 ]
 */
contract CPRinstance is ERC20, VRFConsumerBase, Ownable {  
  //events
  event IssueReported();
  event ProposalMade();
  event ProposalPassed();
  event ProposalRejected();
  event Voted();
  event DistributedShares();
  event PurchasedShares();


  // issues are used to raise awareness of an event of some kind primarily.
  // We can think of these as calling for everyones attention or raising the alarm.
  // a struct defining an issue which people may vote.
  struct Issue {
    address issuer; // address of the user making the report
    uint issueID; // make id = array index?
    bool alarmLow; // low level warning
    bool alarmHigh; // high level warning look at this now!
    uint voteSlash; // talley of votes for **Note still deciding on how votes work here. could be that they play into slashing
    bool slash; // determines if a user gets slashed or not, happens when systems abused..[EXPERIMENTAL]
    address[] voted2slash;
  }
  // ** Figure out how we want to handle proposals. Most likely ipfs but do we need to tokenize them?
  // Proposals are changes to governance metrics. Such as changing
  // distribution, value, new comitees, tbd/etc
  // a struct defining a propposal
  struct Proposal {
    address issuer; // address of the user making the report
    uint propID; // make id = array index?
    uint yay;
    uint nay; // talley of votes against.
    uint voteSlash; // talley of votes for **Note still deciding on how votes work here. could be that they play into slashing
    bool slash; // determines if a user gets slashed or not [EXPERIMENTAL]
    address[] voted; // initiate with issuer address. People can't vote on their own proposals.
    address[] voted2slash;  
  }

  string private TOKEN_NAME = "Common Pool Resource Token";
  string private TOKEN_SYMBOL = "CPRT";
  uint256 private constant TOTAL_SUPPLY = 1000 * (uint(10) ** uint8(18));
  uint256 private constant PRICE = 1; // testing price
  uint256 RIGHTS_VALUE = 2000; // set in constructor later
  address[] public benefactor; 
  mapping(address=>Issue[]) private ManagingIssues;
  mapping(address=>Proposal[]) private ManagingProposals;
  enum c {PROPOSAL, SLASH_PROP, ISSUE}
  AggregatorV3Interface internal priceFeed; // avax/usd
  // move chainlink stuff into constructor
  bytes32 internal keyHash;
  uint256 internal fee;
  uint256 public randomResult;

  constructor(
    address[] memory _address2dist  // List of addresses to distribute shares too, determined in report.
  ) ERC20(TOKEN_NAME, TOKEN_SYMBOL) VRFConsumerBase(
        0xdD3782915140c8f3b190B5D67eAc6dc5760C46E9, // VRF Coordinator
        0xa36085F69e2889c224210F603D836748e7dC0088  // LINK Token
  ) 
  {
    priceFeed = AggregatorV3Interface(0x5498BB86BC934c8D34FDA08E81D444153d0D06aD);
    benefactor = _address2dist;
    keyHash = 0x6c3699283bda56ad74f6b855546325b68d482e983852a7a82979cc4807b641f4;
    fee = 0.1 * 10 ** 18; // 0.1 LINK (Varies by network)
  } 

  /** 
  * Requests randomness 
  */
  function getRandomNumber() public returns (bytes32 requestId) {
    require(LINK.balanceOf(address(this)) >= fee, "Not enough LINK - fill contract with faucet");
    return requestRandomness(keyHash, fee);
  }

  /**
  * Callback function used by VRF Coordinator
  */
  function fulfillRandomness(bytes32 requestId, uint256 randomness) internal override {
    randomResult = randomness;
  }

  function mint(address to, uint256 amount) public payable onlyOwner {
    _mint(to, (amount * (uint(10) ** uint8(18))));
  }
  
  // a primitive function @start which distributes shares among users
  // determined in the report, passed into the constructor.
  function distributeShares() public payable onlyOwner {
    for(int i = 0; i < int(benefactor.length); i++){
      _mint(address(benefactor[uint(i)]), (TOTAL_SUPPLY / 10000 * RIGHTS_VALUE));
    }
    _mint(address(this), (TOTAL_SUPPLY - (benefactor.length * (TOTAL_SUPPLY / 10000 * RIGHTS_VALUE))));
    emit DistributedShares();
  }
  // ** need to explore and add rate limits **
  // a function that allows any remaining shares to be purchased
  // we'll use avax as the currency to purchase shares.
  // User enters number of shares and pays the total price in avax.
  function buyShares(uint quantity) public payable {
    require(msg.value == (quantity * PRICE) * (uint(10) ** uint8(18)), "Not enough funds"); //1000000000000000000 = 1
    require(balanceOf(address(this)) >= 1000000000000000000, "Insufficient resources");
    this.transfer(payable(msg.sender), quantity * (uint(10) ** uint8(18)));
    emit PurchasedShares();
  }
 
  // I want to use a map but introduces some complexity.
  // loops may scale fine as most cpr comunity are relatively small with larger ones being maybe a few thousand. Not eveyone will
  // vote on all issues/proposals so wed expect the loops to be reasonable. considering they should be good to 50,000 reads/500writes
  // a function for voting on things
  function vote(uint context, address issuer, uint _ID, bool choice) public payable{
      if(uint(c.PROPOSAL) == context){ 
      bool check = false;
        for(int i = 0; i < int(ManagingProposals[issuer][_ID].voted.length); i++)
            if(address(ManagingProposals[issuer][_ID].voted[uint(i)]) == address(msg.sender))
              check = true;
        
        require(check == false, "already voted");
        if(choice == true){
            ManagingProposals[issuer][_ID].yay++;
            ManagingProposals[issuer][_ID].voted.push(msg.sender);
          }
        if(choice == false){
            ManagingProposals[issuer][_ID].nay++;
            ManagingProposals[issuer][_ID].voted.push(msg.sender);
          }
      }

      if(uint(c.SLASH_PROP) == context){
      bool check = false;
        for(int i = 0; i < int(ManagingProposals[issuer][_ID].voted2slash.length); i++) 
          if(ManagingProposals[issuer][_ID].voted2slash[uint(i)] == msg.sender)
            check = true;
        
        require(check == false, "already voted");
        ManagingProposals[issuer][_ID].voteSlash++;
        ManagingProposals[issuer][_ID].voted2slash.push(msg.sender);
      } 
      
      if(uint(c.ISSUE) == context){ 
        bool check = false;
        for(int i = 0; i < int(ManagingIssues[issuer][_ID].voted2slash.length); i++) 
          if(ManagingIssues[issuer][_ID].voted2slash[uint(i)] == msg.sender)
            check = true;
        
        require(check == false, "already voted");
        ManagingIssues[issuer][_ID].voteSlash++;
        ManagingIssues[issuer][_ID].voted2slash.push(msg.sender);
      }
    
    emit Voted();
  }

  function _createIssue(Issue memory issue) internal {
    issue.issueID = ManagingIssues[issue.issuer].length;
    issue.voted2slash[0] = issue.issuer;
    ManagingIssues[issue.issuer].push(issue); // remember we will need to adjust id's when items are removed. User don't need to be aware of this id.
    emit IssueReported();
  }

  function _createProposal(Proposal memory proposal) internal {
    proposal.propID = ManagingProposals[proposal.issuer].length;
    proposal.voted[0] = proposal.issuer;
    ManagingProposals[proposal.issuer].push(proposal); // remember we will need to adjust id's when items are removed. User don't need to be aware of this id.
    emit ProposalMade();
  }

  function openIssue(
    address issuer,
    uint issueID,
    bool alarmLow,
    bool alarmHigh,
    uint voteSlash,
    bool slash,
    address[] memory voted2slash
   
  ) public payable {
    require(issuer == msg.sender, 'Not authorized'); // taking accountability, false flags or abuse will be punished.
    Issue memory report_issue = Issue (
      issuer,
      issueID,
      alarmLow,
      alarmHigh,
      voteSlash,
      slash,
      voted2slash
    );
    _createIssue(report_issue);
  }

  function makeProposal(
    address issuer,
    uint propID,
    uint yay,
    uint nay,
    uint voteSlash,
    bool slash,
    address[] memory voted,
    address[] memory voted2slash
  ) public payable {
    require(issuer == msg.sender, 'Not authorized'); // taking accountability, false flags or abuse will be punished.
    Proposal memory new_proposal = Proposal (
      issuer,
      propID,
      yay,
      nay,
      voteSlash,
      slash,
      voted,
      voted2slash
    );
    _createProposal(new_proposal);
  }
 
  // function gets get an issue given an issuer address and issueID
  function getIssue(address issuer, uint issueID) public view returns(Issue memory){
    Issue[] memory issues = ManagingIssues[issuer];
    return(issues[issueID]);
  }

    // function gets a proposal given an issuer address and propID
  function getProposal(address issuer, uint propID) public view returns(Proposal memory){
    Proposal[] memory proposals = ManagingProposals[issuer];
    return(proposals[propID]);
  }

 //function to remove an issue or proposal
  function removeIssueOrProp(uint context, address issuer, uint _ID) public payable {
    require(msg.sender == issuer, "Not authorized");
    if(uint(c.PROPOSAL) == context){
      uint idx = ManagingProposals[issuer].length - 1;
      ManagingProposals[issuer][_ID] = ManagingProposals[issuer][idx];
      ManagingProposals[issuer][_ID].propID = _ID;
      ManagingProposals[issuer].pop();
    }
    if(uint(c.ISSUE) == context){
      uint idx = ManagingIssues[issuer].length - 1;
      ManagingIssues[issuer][_ID] = ManagingIssues[issuer][idx];
      ManagingIssues[issuer][_ID].issueID = _ID;
      ManagingIssues[issuer].pop();
    }
  }

  function addBenefactor(address _benefactor) public payable onlyOwner returns(bool){
    for(int i = 0; i < int(benefactor.length); i++){
      if(benefactor[uint(i)] == _benefactor){
        return false;
      }
    }
    benefactor.push(_benefactor);
    return true;
  } 

  function removeBenefactor(address _benefactor) public payable onlyOwner returns(bool){
    for(int i = 0; i < int(benefactor.length); i++){
      if(benefactor[uint(i)] == _benefactor){
        benefactor[uint(i)] = benefactor[benefactor.length-1];
        benefactor.pop();
        return true;
      }
    }
    return false;
  }

  // EXPERIMENTAL
  function _slash(address user) internal {

  }

  function burn(address from, uint256 amount) public onlyOwner {
    _burn(from, amount);
  }

  // function for setting roles.
  function appointUserRole(address user) public onlyOwner {
    // set roles if any
  }

  function getLatestPrice() public view returns (int) {
    (,int price,,,) = priceFeed.latestRoundData();
    return price;
  }

  // a testing function to releaase avax stored on contract.
  function releaseAVAX(uint amount) public payable onlyOwner{
    (bool succeed, bytes memory data) = payable(msg.sender).call{value: amount}("");
    require(succeed, "Failed to withdraw AVAX");
  }

  function releaseLink() external {} //todo

  function setMyAllowance(address spender, uint addedValue) public {
    increaseAllowance(spender, addedValue);
  }
  receive() external payable {}

}
// [
//   "0x814dDd96FA03f46352c4A2C5787b4836408477fC",
//   "0x72D1CbA159e87c017C9e9f672efBab3C2DfBfadA", 
//   "0xFb65A9e3B18abcF21F926e1C213887369EbF75Fd",
//   "0x816fe97D604744c793656893e9ade34e92B8f13c"
//  ]
