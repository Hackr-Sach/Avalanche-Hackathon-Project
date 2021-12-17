//SPDX-License-Identifier: MIT
pragma solidity 0.8.7;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract CPRinstance is ERC20, Ownable {  
  //events
  event IssueReported(IssueReport);
  event Voted();
  event DistributeddShares();
  event PurchasedShares();

  // instance vars
  string private TOKEN_NAME = "Common Pool Resource Token";
  string private TOKEN_SYMBOL = "CPRT";
  uint256 private constant TOTAL_SUPPLY = 1000 * (uint(10) ** uint8(18));
  uint256 private constant PRICE = 1; // testing price
  
  // issues are used to raise awareness of an event of some kind primarily.
  // We can think of these as calling for everyones attention or raising the alarm.
  // a struct defining an issue which people may vote.
  struct IssueReport {
    address issuer; // address of the user making the report
    uint issueID; // make id = array index?
    uint yay; // talley of votes for **Note still deciding on how votes work here. could be that they play into slashing
    uint nay; // talley of votes against.
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
    uint issueID; // make id = array index?
    uint yay; // talley of votes for **Note still deciding on how votes work here. could be that they play into slashing
    uint nay; // talley of votes against.
    bool slash; // determines if a user gets slashed or not [EXPERIMENTAL]
  }
  mapping(address=>IssueReport[]) ManagingIssueReports;
  address[] public address2dist; //to be removed, will be provided in constructor. this is for testing
  // we will feed this constructor with report data
  constructor(
    address[] memory _address2dist
  )ERC20(TOKEN_NAME, TOKEN_SYMBOL) {
    address2dist = _address2dist;
  }

  function mint(address to, uint256 amount) public payable onlyOwner {
    _mint(to, (amount * (uint(10) ** uint8(18))));
  }
  
  // a primitive function @start which distributes shares among users
  // determined in the report, passed into the constructor.
  function distributeShares(/*address[]*/) public payable onlyOwner {
    // in this test we will mint a total of 1000 lumber share determined via report
    // in this simple scenario four apropiators will each recieve 20%
    // with the remaining 20% going to the store 
    // each address will recieve 200 CPRT
    // the store will have 200 CPRT
    uint rightsVal = 2000;
    _mint(address(address2dist[uint(0)]), (TOTAL_SUPPLY / 10000 * rightsVal));
    _mint(address(address2dist[uint(1)]), (TOTAL_SUPPLY / 10000 * rightsVal));
    _mint(address(address2dist[uint(2)]), (TOTAL_SUPPLY / 10000 * rightsVal));
    _mint(address(address2dist[uint(3)]), (TOTAL_SUPPLY / 10000 * rightsVal));
    _mint(address(this), (TOTAL_SUPPLY - (address2dist.length * (TOTAL_SUPPLY / 10000 * rightsVal))));
  }

  // a function that allows any remaining shares to be purchased
  // we'll use avax as the currency to purchase shares.
  // User enters number of shares and pays the total price in avax.
  function buyShares(uint quantity) public payable {
    require(msg.value == (quantity * PRICE) * (uint(10) ** uint8(18)), "Not enough funds"); //1000000000000000000 = 1
    require(balanceOf(address(this)) >= 1000000000000000000, "Insufficient resources");
    this.transfer(payable(msg.sender), quantity * (uint(10) ** uint8(18)));
  }

  // a function to create issues which people may vote/act on the base for the openIssue public function.
  function _createIssue(IssueReport memory issue) internal {
    issue.issueID = ManagingIssueReports[issue.issuer].length;
    ManagingIssueReports[issue.issuer].push(issue); // remember we will need to adjust id's when items are removed. User don't need to be aware of this id.
    emit IssueReported(issue);
  }

  function openIssue(
    address issuer,
    uint issueID,
    uint yay,
    uint nay,
    bool slash,
    bool alarmLow,
    bool alarmHigh
  ) public payable {
    require(issuer == msg.sender, 'Not authorized'); // taking accountability, false flags or abuse will be punished.
    IssueReport memory issueReport = IssueReport(
      issuer,
      issueID,
      yay,
      nay,
      slash,
      alarmLow,
      alarmHigh
    );
    _createIssue(issueReport);
  }
 
  // function gets get an issue given an issuer address and issueID
  function getIssue(address issuer, uint issueID) public view returns(IssueReport memory){
    IssueReport[] memory issues = ManagingIssueReports[issuer];
    return(issues[issueID]);
  }

  // I think I will add id's to issue or use the tracking array method to track multiple issues form a user.
  // need to require the user has not already voted
  // a function for voting on things
  function vote(address issuer, uint issueID, bool choice) public payable{
    if(choice == true){
      ManagingIssueReports[issuer][issueID].yay++;
    }
    if(choice == false){
      ManagingIssueReports[issuer][issueID].nay++;
    }
  }
  //could be used in tandem with slashing
  function burn(address from, uint256 amount) public onlyOwner {
    _burn(from, amount);
  }

  // function for setting roles. could be another reason to use 1155? 
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