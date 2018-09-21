pragma solidity ^0.4.24;
pragma experimental ABIEncoderV2;

contract ProviderRating {

    function ProviderRating(){

    }
    struct Provider {
        bytes32 name;
        string providerPostalAddress; // we use a string data type here because bytes32 can only fit 32 characters (addresses might be longer)
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
        string comment; // we use a string data type here because bytes32 can onl fit 32 characters (comments might be longer)
        bool isValue;
    }

    mapping (bytes32 => Provider) providers; // we map the providers through their identification number
    mapping(bytes32 => User) users;
    mapping(bytes32 => Rating) ratings; // we map the ratings through a hash string that gets created out of the



    // the key for the users that voted is the survey key that they used
    bytes32[] public surveyKeys;
    bytes32[] ratingHashes;
    address[] public providerIdentificationNumbers;


    function validRatingHash(bytes32 ratingHash) view public returns (bool) {
        // we assure that a rating hash does not exist yet
        for (uint i = 0; i < ratingHashes.length; i++) {
            if (ratingHashes[i] == ratingHash) {
                return false;
            }
        }
        return false;
    }

    function rateProvider(bytes32 _surveyKey, bytes32 hashOfProviderNameAndSurveyKey, bytes32 _providerName, string _providerPostalAddress, bytes32 _providerIdentificationNumber, uint _score, string _comment) public {
        // it is faster and costs less gas to compute the hash of of the providerName and the SurveyKey on the client and pass it to this function rather than to securely compute it here


        User userToUseForRating;
        // we check if the user that voted already exists in our storage
        if(users[_surveyKey].isValue){
            userToUseForRating = users[_surveyKey];
        }else{
        // we create a new user
            var newUser = users[_surveyKey];
            newUser.surveyKey = _surveyKey;
            newUser.isValue = true;
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
            newProvider.isValue = true;
            providerToUseForRating = newProvider;
        }
        if(ratings[hashOfProviderNameAndSurveyKey].isValue){
            revert(); // duplicate submission this should not be allowed
        }else{
            var newRating = ratings[hashOfProviderNameAndSurveyKey];
            newRating.author = userToUseForRating;
            newRating.provider = providerToUseForRating;
            newRating.score = _score;
            newRating.comment = _comment;
            newRating.isValue = true;
            ratingHashes.push(hashOfProviderNameAndSurveyKey);
        }

    }
    function getRatingAuthorKeyForRatingHash(bytes32 ratingHash)  public constant returns(bytes32){
        return ratings[ratingHash].author.surveyKey;

    }
    function getRatingProviderNameForRatingHash(bytes32 ratingHash) view public returns(bytes32){
        return ratings[ratingHash].provider.name;

    }
    function getRatingCommentForRatingHash(bytes32 ratingHash) view public returns (string){
        return ratings[ratingHash].comment;

    }

    function getRatingScoreForRatingHash(bytes32 ratingHash) view public returns(uint) {
        return ratings[ratingHash].score;
    }

    function getNumberOfRatingsSaved() view public returns(uint){
        return ratingHashes.length;
    }

    function getRatingHashAtIndex(uint index) view public returns(bytes32){
        return ratingHashes[index];
    }


}
