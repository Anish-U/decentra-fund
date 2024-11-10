import { buildModule } from '@nomicfoundation/hardhat-ignition/modules';

/**
 * @module CampaignFactoryModule
 * @description A module for interacting with the CampaignFactory contract in a Hardhat project. This module
 *              provides access to the CampaignFactory contract instance for deploying and managing campaigns.
 */
const CampaignFactoryModule = buildModule('CampaignFactory', (m) => {
  const campaignFactory = m.contract('CampaignFactory');

  return { campaignFactory };
});

export default CampaignFactoryModule;
