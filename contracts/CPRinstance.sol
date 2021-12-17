//SPDX-License-Identifier: MIT
pragma solidity 0.8.7;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

/*  2do
 [
   -set slash to true if conditions are met
   -invoke slash - we will use chainlink VRF to instead of burning a token give it to 
    a random user in the system. to add insult to injury
   -cleanup/reset params if needbe
 ]
 [
   -remove issues, remove proposals?? 
   -we can have the option atleast
   -manage id's when removing props.
 ]
 */
contract CPRinstance is ERC20, Ownable {  
  //events
  event IssueReported(Issue);
  event ProposalMade();
  event Voted();
  event DistributedShares();
  event PurchasedShares();

  // issues are used to raise awareness of an event of some kind primarily.
  // We can think of these as calling for everyones attention or raising the alarm.
  // a struct defining an issue which people may vote.
  struct Issue {
    address issuer; // address of the user making the report
    uint issueID; // make id = array index?
    uint voteSlash; // talley of votes for **Note still deciding on how votes work here. could be that they play into slashing
    bool slash; // determines if a user gets slashed or not, happens when systems abused..[EXPERIMENTAL]
    bool alarmLow; // low level warning
    bool alarmHigh; // high level warning look at this now!
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
  }

  string private TOKEN_NAME = "Common Pool Resource Token";
  string private TOKEN_SYMBOL = "CPRT";
  uint256 private constant TOTAL_SUPPLY = 1000 * (uint(10) ** uint8(18));
  uint256 private constant PRICE = 1; // testing price
  uint256 RIGHTS_VALUE = 2000; // set in constructor later
  mapping(address=>Issue[]) private ManagingIssues;
  mapping(address=>Proposal[]) private ManagingProposals;
  address[] private address2dist; 
 
  constructor(
    address[] memory _address2dist  // List of addresses to distribute shares too, determined in startup report.
  ) ERC20 (TOKEN_NAME, TOKEN_SYMBOL) {
    address2dist = _address2dist;
  }

  function mint(address to, uint256 amount) public payable onlyOwner {
    _mint(to, (amount * (uint(10) ** uint8(18))));
  }
  
  // a primitive function @start which distributes shares among users
  // determined in the report, passed into the constructor.
  function distributeShares() public payable onlyOwner {
    for(int i = 0; i < int(address2dist.length); i++){
      _mint(address(address2dist[uint(i)]), (TOTAL_SUPPLY / 10000 * RIGHTS_VALUE));
    }
    _mint(address(this), (TOTAL_SUPPLY - (address2dist.length * (TOTAL_SUPPLY / 10000 * RIGHTS_VALUE))));
    emit DistributedShares();
  }

  // a function that allows any remaining shares to be purchased
  // we'll use avax as the currency to purchase shares.
  // User enters number of shares and pays the total price in avax.
  function buyShares(uint quantity) public payable {
    require(msg.value == (quantity * PRICE) * (uint(10) ** uint8(18)), "Not enough funds"); //1000000000000000000 = 1
    require(balanceOf(address(this)) >= 1000000000000000000, "Insufficient resources");
    this.transfer(payable(msg.sender), quantity * (uint(10) ** uint8(18)));
    emit PurchasedShares();
  }

  // need to require the user has not already voted
  // a function for voting on things
  function vote(uint context, address issuer, uint issueID, bool choice) public payable{
      if(context == 1){ // 1 == proposal
        if(choice == true){
            ManagingProposals[issuer][issueID].yay++;
        }
        if(choice == false){
            ManagingProposals[issuer][issueID].nay++;
        }
      }
      if(context == 2) // 2 == slash proposal
        ManagingProposals[issuer][issueID].voteSlash++;
      if(context == 3){ // 3 == issue
        if(choice == true){
            ManagingIssues[issuer][issueID].voteSlash++;
        }
      }
    
    emit Voted();
  }

   // a function to create issues which people may vote/act on the base for the openIssue public function.
  function _createIssue(Issue memory issue) internal {
    issue.issueID = ManagingIssues[issue.issuer].length;
    ManagingIssues[issue.issuer].push(issue); // remember we will need to adjust id's when items are removed. User don't need to be aware of this id.
    emit IssueReported(issue);
  }

     // a function to create issues which people may vote/act on the base for the openIssue public function.
  function _createProposal(Proposal memory proposal) internal {
    proposal.propID = ManagingProposals[proposal.issuer].length;
    ManagingProposals[proposal.issuer].push(proposal); // remember we will need to adjust id's when items are removed. User don't need to be aware of this id.
    emit ProposalMade();
  }

  function openIssue(
    address issuer,
    uint issueID,
    uint voteSlash,
    bool slash,
    bool alarmLow,
    bool alarmHigh
  ) public payable {
    require(issuer == msg.sender, 'Not authorized'); // taking accountability, false flags or abuse will be punished.
    Issue memory report_issue = Issue (
      issuer,
      issueID,
      voteSlash,
      slash,
      alarmLow,
      alarmHigh
    );
    _createIssue(report_issue);
  }

  function makeProposal(
    address issuer,
    uint propID,
    uint yay,
    uint nay,
    uint voteSlash,
    bool slash
  ) public payable {
    require(issuer == msg.sender, 'Not authorized'); // taking accountability, false flags or abuse will be punished.
    Proposal memory new_proposal = Proposal (
      issuer,
      propID,
      yay,
      nay,
      voteSlash,
      slash
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

  //could be used in tandem with slashing
  function burn(address from, uint256 amount) public onlyOwner {
    _burn(from, amount);
  }

  // function for setting roles.
  function appointUserRole(address user) public onlyOwner {
    // set roles if any
  }

  // a testing function to releaase avax stored on contract.
  function releaseAVAX(uint amount) public payable onlyOwner{
    (bool succeed, bytes memory data) = payable(msg.sender).call{value: amount}("");
    require(succeed, "Failed to withdraw AVAX");
  }

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