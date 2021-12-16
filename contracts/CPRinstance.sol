//SPDX-License-Identifier: MIT
pragma solidity >=0.6.2;

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
  uint256 private constant TOTAL_SUPPLY = 1200 * (uint(10) ** uint8(18));
  uint256 private constant PRICE = 1; // testing price
  
  // how do we want to resolve the actual report a text base mechanism??
  // a struct defining an issue which people may vote.
  struct IssueReport {
    address issuer; // address of the user making the report
    uint issueID; // make id = array index?
    uint yay; // talley of votes for
    uint nay; // talley of votes against.
    bool slash; // determines if a user gets slashed or not, happens when systems abused..[EXPERIMENTAL]
    bool alarmLow; // low level warning
    bool alarmHigh; // high level warning look at this now!
  }

  mapping(address=>IssueReport[]) ManagingIssueReports;
 
  // we will feed this constructor with report data
  constructor()ERC20(TOKEN_NAME, TOKEN_SYMBOL) {
    _mint(address(this), TOTAL_SUPPLY);
  }

  function mint(address to, uint256 amount) public payable onlyOwner {
    _mint(to, (amount * (uint(10) ** uint8(18))));
  }

  // a primitive function @start which distributes shares among users
  // determined in the report, passed into the constructor.
  function distributeShares(/*address[]*/) public onlyOwner {
    // distribute tokens to a list of addresses. We will
    // start simple but need to make shares dynamic. Not every
    // person will have the same demand.
  }

  // a function that allows any remaining shares to be purchased
  // we'll use avax as the currency to purchase shares.
  // User enters number of shares and pays the total price in avax.
  function buyShares(uint quantity) public payable {
    require(msg.value == (quantity * PRICE) * (uint(10) ** uint8(18))), "Not enough funds");
    require(balanceOf(address(this)) >= quantity, "Insufficient resources");
    transferFrom(address(this), msg.sender, quantity);
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

  // a function to releaase avax stored on a contract.
  function releaseAVAX(address payable recipient, uint256 amount) public payable onlyOwner{
    (bool succeed, bytes memory data) = recipient.call{value: amount}("");
    require(succeed, "Failed to withdraw AVAX");
  }

  receive() external payable {}
}
