pragma solidity ^0.4.0;

contract ProviderRating {

    function ProviderRating(){

    }
    struct Provider {
        bytes32 name;
        bytes32 providerPostalAddress;
        bytes32 providerIdentificationNumber;
        bool isValue;
    }

    struct User {
        bytes32 surveyKey;
        bool isValue; //https://ethereum.stackexchange.com/questions/13021/how-can-you-figure-out-if-a-certain-key-exists-in-a-mapping-struct-defined-insi
    }

    struct Rating {
        User author;
        Provider provider;
        uint score;
        bytes32 comment;
    }

    mapping (bytes32 => Provider) providers; // we map the providers through their identification number
    mapping(bytes32 => User) users;
    mapping(bytes32 => Rating) ratings; // we map the ratings through a hash string that gets created out of the



    // the key for the users that voted is the survey key that they used
    bytes32[] public surveyKeys;
    bytes32[] ratingHashes;
    address[] public providerIdentificationNumbers;


    // provider.providerIdentificationNumber + user.surveyKey

    function rateProvider(bytes32 _surveyKey, bytes32 hashOfProviderNameAndSurveyKey, bytes32 _providerName, bytes32 _providerPostalAddress, bytes32 _providerIdentificationNumber, uint _score, bytes32 _comment) public {
        // it is faster and costs less gas to compute the hash of of the providerName and the SurveyKey on the client and pass it to this function rather than to securely compute it here
        User userToUseForRating;

        // we check if the user that voted already exists in our storage
        if(users[_surveyKey].isValue){
            userToUseForRating = users[_surveyKey];
        }else{
        // we create a new user
            var newUser = users[_surveyKey];
            newUser.surveyKey = _surveyKey;
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
        var newRating = ratings[hashOfProviderNameAndSurveyKey];
        newRating.author = userToUseForRating;
        newRating.provider = providerToUseForRating;
        newRating.score = _score;
        newRating.comment = _comment;
        ratingHashes.push(hashOfProviderNameAndSurveyKey);
    }

    function getRatingForProviderNameAndSurveyKeyHash(bytes32 ratingHash) view public returns(uint) {
        return ratings[ratingHash].score;
    }

}
