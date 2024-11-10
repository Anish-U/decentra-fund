// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

/**
 * @title Campaign
 * @dev A contract that represents a single crowdfunding campaign, allowing contributors to fund the campaign,
 *      create funding requests, and approve/disapprove requests for fund withdrawals.
 */
contract Campaign {
  /**
   * @notice A structure to represent a funding request.
   * @dev Each request includes a description, value, recipient, completion status, approval count, and approvals.
   *      Approvals are used to determine if the request has been approved by a majority of contributors.
   */
  struct Request {
    string description;
    uint value;
    address recipient;
    bool complete;
    uint approvalCount;
    mapping(address => bool) approvals;
  }

  address public manager;
  uint public minimumContribution;
  string public campaignName;
  string public campaignDescription;
  string public imageUrl;
  uint public targetAmount;

  address[] public contributors;
  mapping(address => bool) public approvers;
  uint public approversCount;

  Request[] public requests;

  modifier restricted() {
    require(msg.sender == manager, 'Only the manager can perform this action');
    _;
  }

  /**
   * @dev Constructor to initialize a new campaign.
   * @param minimum The minimum contribution required to participate in the campaign.
   * @param creator The address of the campaign manager (creator).
   * @param name The name of the campaign.
   * @param description The description of the campaign.
   * @param image The image URL related to the campaign.
   * @param target The target amount the campaign aims to raise.
   */
  constructor(
    uint minimum,
    address creator,
    string memory name,
    string memory description,
    string memory image,
    uint target
  ) {
    manager = creator;
    minimumContribution = minimum;
    campaignName = name;
    campaignDescription = description;
    imageUrl = image;
    targetAmount = target;
  }

  /**
   * @dev Allows users to contribute funds to the campaign.
   * @notice The contribution must be above the minimum contribution amount.
   */
  function contribute() public payable {
    require(msg.value >= minimumContribution, 'Contribution is below minimum');

    contributors.push(msg.sender);
    approvers[msg.sender] = true;
    approversCount++;
  }

  /**
   * @dev Allows the manager to create a new request for funds from the campaign balance.
   * @param description A description of the request.
   * @param value The amount of funds requested.
   * @param recipient The address of the recipient of the funds.
   */
  function createRequest(
    string memory description,
    uint value,
    address recipient
  ) public restricted {
    require(
      value <= address(this).balance,
      'Request exceeds the campaign balance'
    );

    Request storage newRequest = requests.push();

    newRequest.description = description;
    newRequest.value = value;
    newRequest.recipient = recipient;

    newRequest.complete = false;
    newRequest.approvalCount = 0;
  }

  /**
   * @dev Allows contributors to approve a funding request.
   * @param index The index of the request to approve.
   * @notice Only contributors can approve a request, and they can only approve once.
   */
  function approveRequest(uint index) public {
    Request storage request = requests[index];

    require(approvers[msg.sender], 'You must be a contributor to approve');
    require(
      !request.approvals[msg.sender],
      'You have already approved this request'
    );

    request.approvals[msg.sender] = true;
    request.approvalCount++;
  }

  /**
   * @dev Finalizes a request and transfers the requested funds to the recipient.
   * @param index The index of the request to finalize.
   * @notice Only the manager can finalize the request, and the request must have a majority of approvals.
   */
  function finalizeRequest(uint index) public restricted {
    Request storage request = requests[index];

    require(
      request.approvalCount > (approversCount / 2),
      'Not enough approvals'
    );
    require(!request.complete, 'Request has already been completed');

    payable(request.recipient).transfer(request.value);
    request.complete = true;
  }

  /**
   * @dev Returns a summary of the campaign's details.
   * @return minimum The minimum contribution required.
   * @return balance The current balance of the campaign.
   * @return requestCount The total number of requests made.
   * @return approverCount The number of contributors/approvers.
   * @return campaignManager The address of the campaign manager.
   * @return name The name of the campaign.
   * @return description The description of the campaign.
   * @return image The image URL of the campaign.
   * @return campaignTargetAmount The target amount to be raised by the campaign.
   */
  function getSummary()
    public
    view
    returns (
      uint minimum,
      uint balance,
      uint requestCount,
      uint approverCount,
      address campaignManager,
      string memory name,
      string memory description,
      string memory image,
      uint campaignTargetAmount
    )
  {
    return (
      minimumContribution,
      address(this).balance,
      requests.length,
      approversCount,
      manager,
      campaignName,
      campaignDescription,
      imageUrl,
      targetAmount
    );
  }

  /**
   * @dev Returns the total number of requests made for the campaign.
   * @return The number of requests.
   */
  function getRequestsCount() public view returns (uint) {
    return requests.length;
  }
}
