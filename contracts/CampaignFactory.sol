// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

import './Campaign.sol';

/**
 * @title CampaignFactory
 * @dev A contract that deploys and manages multiple crowdfunding campaigns.
 */
contract CampaignFactory {
  address[] public deployedCampaigns;

  /**
   * @dev Creates a new crowdfunding campaign and deploys the Campaign contract.
   * @param minimum Minimum contribution required to participate in the campaign.
   * @param name Name of the campaign.
   * @param description Description of the campaign.
   * @param image Image URL representing the campaign.
   * @param target Target amount the campaign aims to raise.
   */
  function createCampaign(
    uint minimum,
    string memory name,
    string memory description,
    string memory image,
    uint target
  ) public {
    Campaign newCampaign = new Campaign(
      minimum,
      msg.sender,
      name,
      description,
      image,
      target
    );
    deployedCampaigns.push(address(newCampaign));
  }

  /**
   * @dev Returns the list of deployed campaign addresses.
   * @return A list of addresses of all deployed campaigns.
   */
  function getDeployedCampaigns() public view returns (address[] memory) {
    return deployedCampaigns;
  }
}
