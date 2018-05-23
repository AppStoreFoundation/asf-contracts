pragma solidity ^0.4.19;

import  { CampaignLibrary } from "./lib/CampaignLibrary";

/**
 * The Advertisement contract collects campaigns registered by developers
 * and executes payments to users using campaign registered applications
 * after proof of Attention.
 */
contract AdvertisementStorage {

	mapping (bytes32 => CampaignLibrary.Campaign) campaigns;

	function getCampaign (byte32 campaignId) constant returns (CampaignLibrary.Campaign) {
		return campaigns[campaignId];
	}


	function setCampaign (byte32 campaignId, CampaignLibrary.Campaign campaign) constant returns (CampaignLibrary.Campaign) {
		return campaigns[campaignId] campaign;
	}
}
