pragma solidity ^0.4.24;
import "./Provider.sol";
import "./ProviderRating.sol";

contract ProviderRatingFactory {

  address public providers;
  address public providerRatings;
  // is the central communication point to create and query Providers and ProviderRatings
  constructor() {
  }

  function newProviderRating(bytes8 _geohashOfProvider, bytes32 _surveyKey, bytes32 hashOfProviderNameAndSurveyKey,
    bytes32 _providerName, string _providerPostalAddress, bytes32 _providerIdentificationNumber, uint _score, string _comment){
    // we check if we created a new Provider or not if we did we create the new Provider Smart Contract
    // as well
    ProviderRating providerRating = new ProviderRating();

    Provider provider = new Provider(_geohashOfProvider, _providerName, _providerPostalAddress,
      _providerIdentificationNumber);


  }
}
