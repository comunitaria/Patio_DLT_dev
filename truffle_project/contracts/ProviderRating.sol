pragma solidity ^0.4.0;

contract ProviderRating {

    function ProviderRating(){

    }
    struct Provider {
        bytes32 name;
        bytes32 providerPostalAddress;
        bytes32 providerIdentificationNumber;
    }

    struct User {
        bytes32 userName;
        bytes32 surveyKey;
    }

    struct Rating {
        User author;
        Provider provider;
        uint score;
        bytes32 comment;
    }

    mapping (bytes32 => Provider) providers; // we map the providers through their identification number
    address[] public providerIdentificationNumbers;

    // the key for the users that voted is the survey key that they used
    mapping(bytes32 => User) users;
    bytes32[] public surveyKeys;

    mapping(bytes32 => Rating) ratings; // we map the ratings through a hash string that gets created out of the
    // provider.providerIdentificationNumber + user.surveyKey
    bytes32[] ratingHashes;

    function rateProvider(bytes32 _userName, bytes32 _surveyKey, bytes32 _providerName, bytes32 _providerPostalAddress, bytes32 _providerIdentificationNumber, uint _score, bytes32 _comment) public {
        // todo assure that the hash from _providerName + _surveyKey does not exist in the ratings mapping yet
        User userToUseForRating;
        bytes32 generatedHashFromProviderIdAndUserName;

        // we check if the user that voted already exists in our storage
        if(users[_surveyKey].isValue){
            userToUseForRating = users[_surveyKey];
        }else{
        // we create a new user
            var newUser = users[_surveyKey];
            newUser.userName = _userName;
            newUser.surveyKey = _surveyKey;
            newUser.push(_surveyKey);
            userToUseForRating = newUser;

        }
        Provider providerToUseForRating;
        // we check if the provider that got a review already exists in our storage
        if(providers[_providerIdentificationNumber].isValue){
            providerToUseForRating = providers[_providerIdentificationNumber];
        }else{
        // we create a new Provider
            var newProvider = providers[_providerIdentificationNumber];
            newProvider.name = _providerName;
            newProvider.providerPostalAddress = _providerPostalAddress;
            newProvider.providerIdentificationNumber = _providerIdentificationNumber;
            providerToUseForRating = newProvider;
        }
        // todo generate hash from _providerIdentificationNumber + _userName and check if this hash already exists
        // todo in the ratings mapping, if so it is a duplicate submission and should not be allowed.
        generatedHashFromProviderIdAndUserName = 4;
        var newRating = ratings[generatedHashFromProviderIdAndUserName];
        newRating.author = userToUseForRating;
        newRating.provider = providerToUseForRating;
        newRating.score = _score;
        newRating.comment = _comment;
        ratingHashes.push(generatedHashFromProviderIdAndUserName);
    }

    function getRatingHashes() view public returns(bytes32[]) {
        return ratingHashes;
    }

}
