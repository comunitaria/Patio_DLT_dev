pragma solidity ^0.4.24;

contract ListAbiertaVotingResult{

    struct Voting {
        uint32[] uniqueUserIds;
        bytes32[] uniqueUserHashes;
        uint32[] userIdsUsedForVote;
        uint32[] userIdsUsedForVoteVotedCandidateId;
        uint32[] userIdsUsedForVoteVotedPoints;
        uint32[] uniqueCandidateIds;
        bytes32[] uniqueCandidateNames;
        bool isValue;
    }
    mapping (bytes32 => Voting) votingRegistry; // this is the registry where the results of all the votes are saved
    // mapped by the name of the voting
    bytes32[] votingNames;

    constructor() public {
    }

    function saveVotingResultDetails(
        uint32[] _uniqueUserIds,
        bytes32[] _uniqueUserHashes,
        uint32[] _userIdsUsedForVote,
        uint32[] _userIdsUsedForVoteVotedCandidateId,
        uint32[] _userIdsUsedForVoteVotedPoints,
        bytes32 _votingName) internal {


        for(uint i=0; i<_uniqueUserIds.length; i++) {
            votingRegistry[_votingName].uniqueUserIds.push(_uniqueUserIds[i]);
        }
        for (uint j=0; j<_uniqueUserHashes.length; j++) {
            votingRegistry[_votingName].uniqueUserHashes.push(_uniqueUserHashes[j]);
        }
        for (uint k=0; k<_userIdsUsedForVote.length; k++) {
            votingRegistry[_votingName].userIdsUsedForVote.push(_userIdsUsedForVote[k]);
        }
        for (uint l=0; l<_userIdsUsedForVoteVotedCandidateId.length; l++) {
            votingRegistry[_votingName].userIdsUsedForVoteVotedCandidateId.push(_userIdsUsedForVoteVotedCandidateId[l]);
        }
        for (uint m=0; m<_userIdsUsedForVoteVotedPoints.length; m++) {
            votingRegistry[_votingName].userIdsUsedForVoteVotedPoints.push(_userIdsUsedForVoteVotedPoints[m]);
        }

    }

    function saveCandidateDetails(uint32[] uniqueCandidateIds, bytes32[] uniqueCandidateNames, bytes32 _votingName) internal{
        for (uint n=0; n<uniqueCandidateIds.length; n++) {
            votingRegistry[_votingName].uniqueCandidateIds.push(uniqueCandidateIds[n]);
        }
        for (uint o=0; o<uniqueCandidateNames.length; o++) {
            votingRegistry[_votingName].uniqueCandidateNames.push(uniqueCandidateNames[o]);
        }

    }

    function submitNewVoting(
        uint32[] _uniqueUserIds, bytes32[] _uniqueUserHashes,
        uint32[] _userIdsUsedForVote,
        uint32[] _userIdsUsedForVoteVotedCandidateId,
        uint32[] _userIdsUsedForVoteVotedPoints,
        uint32[] _uniqueCandidateIds, bytes32[] _uniqueCandidateNames,
        bytes32 _votingName) public {


        votingNames.push(_votingName);
        votingRegistry[_votingName].isValue = true;

        saveVotingResultDetails(_uniqueUserIds, _uniqueUserHashes, _userIdsUsedForVote,
            _userIdsUsedForVoteVotedCandidateId, _userIdsUsedForVoteVotedPoints, _votingName);
        saveCandidateDetails(_uniqueCandidateIds, _uniqueCandidateNames, _votingName);

    }

    function getNumberOfSubmittedVotings() view public returns (uint256){
        return votingNames.length;
    }

    function getVotingNameAtIndex(uint32 index) view public returns (bytes32){
        return votingNames[index];
    }

    function getCandidateNameForVotingNameAtIndex(bytes32 votingName, uint32 index) view public returns (bytes32){
        return votingRegistry[votingName].uniqueCandidateNames[1];
    }

    function getVotedCandidateIdsForVoterIdForVoting(uint32 voterId, bytes32 votingName) view public returns (uint256[]){
        uint256 numberOfVoterIdIndices = 0;

        for(uint i=0;i<votingRegistry[votingName].userIdsUsedForVote.length;i++){
            if(votingRegistry[votingName].userIdsUsedForVote[i] == voterId){
                numberOfVoterIdIndices = numberOfVoterIdIndices +1;
            }
        }
        uint256[] memory voterIdIndices = new uint256[](numberOfVoterIdIndices);
        uint256 lastVoterIdIndexUsed = 0;
        for(uint j=0;j<votingRegistry[votingName].userIdsUsedForVote.length;j++){
            if(votingRegistry[votingName].userIdsUsedForVote[j] == voterId){
                voterIdIndices[lastVoterIdIndexUsed]=j;
                lastVoterIdIndexUsed = lastVoterIdIndexUsed+1;
            }
        }

        uint256[] memory votingResultsForVoterId = new uint256[](numberOfVoterIdIndices);
        uint256 lastVotingResultIndexUsed = 0;
        for(uint k=0;k<voterIdIndices.length;k++){
                votingResultsForVoterId[lastVotingResultIndexUsed]= votingRegistry[votingName].userIdsUsedForVoteVotedCandidateId[voterIdIndices[k]];
                lastVotingResultIndexUsed = lastVotingResultIndexUsed+1;
        }

        return votingResultsForVoterId;
    }

    function getVotedCandidatePointsForVoterIdForVoting(uint32 voterId, bytes32 votingName) view public returns (uint256[]){
        uint256 numberOfVoterIdIndices = 0;

        for(uint i=0;i<votingRegistry[votingName].userIdsUsedForVote.length;i++){
            if(votingRegistry[votingName].userIdsUsedForVote[i] == voterId){
                numberOfVoterIdIndices = numberOfVoterIdIndices +1;
            }
        }
        uint256[] memory voterIdIndices = new uint256[](numberOfVoterIdIndices);
        uint256 lastVoterIdIndexUsed = 0;
        for(uint j=0;j<votingRegistry[votingName].userIdsUsedForVote.length;j++){
            if(votingRegistry[votingName].userIdsUsedForVote[j] == voterId){
                voterIdIndices[lastVoterIdIndexUsed]=j;
                lastVoterIdIndexUsed = lastVoterIdIndexUsed+1;
            }
        }

        uint256[] memory votingResultsForVoterId = new uint256[](numberOfVoterIdIndices);
        uint256 lastVotingResultIndexUsed = 0;
        for(uint k=0;k<voterIdIndices.length;k++){
                votingResultsForVoterId[lastVotingResultIndexUsed]= votingRegistry[votingName].userIdsUsedForVoteVotedPoints[voterIdIndices[k]];
                lastVotingResultIndexUsed = lastVotingResultIndexUsed+1;
        }

        return votingResultsForVoterId;
    }

    function getCandidateNameForCandidateIdForVoting(uint256 candidateId, bytes32 votingName) view public returns(bytes32){
        bool foundCandidateId = false;
        uint256 candidateIndex = 0;
        for(uint i=0;i<votingRegistry[votingName].uniqueCandidateIds.length;i++){
            if(votingRegistry[votingName].uniqueCandidateIds[i] == candidateId){
                candidateIndex = i;
                foundCandidateId = true;
            }
        }
        require(foundCandidateId);
        return votingRegistry[votingName].uniqueCandidateNames[candidateIndex];
    }

        function getVoterIdForVoterHashForVoting(bytes32 voterHash, bytes32 votingName) view public returns(uint32){
        bool foundVoterId = false;
        uint256 voterIndex = 0;
        for(uint i=0;i<votingRegistry[votingName].uniqueUserHashes.length;i++){
            if(votingRegistry[votingName].uniqueUserHashes[i] == voterHash){
                voterIndex = i;
                foundVoterId = true;
            }
        }
        require(foundVoterId);
        return votingRegistry[votingName].uniqueUserIds[voterIndex];
    }

    function getNumberOfTimesVotedForPositionsFromOneToFive(
        uint256[] candidateIdIndices, bytes32 votingName) internal returns (uint256[]){

        uint32 numberOfTimesVotedFirst = 0;
        uint32 numberOfTimesVotedSecond = 0;
        uint32 numberOfTimesVotedThird = 0;
        uint32 numberOfTimesVotedFourth = 0;
        uint32 numberOfTimesVotedFifth = 0;

        // there is a maximum of 10 positions to vote for
        uint256[] memory numberOfTimesVotedFromOneToFive = new uint256[](5);
        for(uint l=0;l<candidateIdIndices.length;l++){
            if(votingRegistry[votingName].userIdsUsedForVoteVotedPoints[candidateIdIndices[l]] == 1){
                numberOfTimesVotedFirst = numberOfTimesVotedFirst + 1;
            }
            if(votingRegistry[votingName].userIdsUsedForVoteVotedPoints[candidateIdIndices[l]] == 2){
                numberOfTimesVotedSecond = numberOfTimesVotedSecond + 1;
            }
            if(votingRegistry[votingName].userIdsUsedForVoteVotedPoints[candidateIdIndices[l]] == 3){
                numberOfTimesVotedThird = numberOfTimesVotedThird + 1;
            }
            if(votingRegistry[votingName].userIdsUsedForVoteVotedPoints[candidateIdIndices[l]] == 4){
                numberOfTimesVotedFourth = numberOfTimesVotedFourth + 1;
            }
            if(votingRegistry[votingName].userIdsUsedForVoteVotedPoints[candidateIdIndices[l]] == 5){
                numberOfTimesVotedFifth = numberOfTimesVotedFifth + 1;
            }
        }
        numberOfTimesVotedFromOneToFive[0]=numberOfTimesVotedFirst;
        numberOfTimesVotedFromOneToFive[1]=numberOfTimesVotedSecond;
        numberOfTimesVotedFromOneToFive[2]=numberOfTimesVotedThird;
        numberOfTimesVotedFromOneToFive[3]=numberOfTimesVotedFourth;
        numberOfTimesVotedFromOneToFive[4]=numberOfTimesVotedFifth;


        return numberOfTimesVotedFromOneToFive;
    }
    function getNumberOfTimesVotedForPositionsSixToTen(
        uint256[] candidateIdIndices, bytes32 votingName) internal returns (uint256[]){

        uint32 numberOfTimesVotedSixth = 0;
        uint32 numberOfTimesVotedSeventh = 0;
        uint32 numberOfTimesVotedEight = 0;
        uint32 numberOfTimesVotedNinth = 0;
        uint32 numberOfTimesVotedTenth = 0;

        // there is a maximum of 10 positions to vote for
        uint256[] memory numberOfTimesVotedFromSixToTen = new uint256[](5);
        for(uint l=0;l<candidateIdIndices.length;l++){
            if(votingRegistry[votingName].userIdsUsedForVoteVotedPoints[candidateIdIndices[l]] == 6){
                numberOfTimesVotedSixth = numberOfTimesVotedSixth + 1;
            }
            if(votingRegistry[votingName].userIdsUsedForVoteVotedPoints[candidateIdIndices[l]] == 7){
                numberOfTimesVotedSeventh = numberOfTimesVotedSeventh + 1;
            }
            if(votingRegistry[votingName].userIdsUsedForVoteVotedPoints[candidateIdIndices[l]] == 8){
                numberOfTimesVotedEight = numberOfTimesVotedEight + 1;
            }
            if(votingRegistry[votingName].userIdsUsedForVoteVotedPoints[candidateIdIndices[l]] == 9){
                numberOfTimesVotedNinth = numberOfTimesVotedNinth + 1;
            }
            if(votingRegistry[votingName].userIdsUsedForVoteVotedPoints[candidateIdIndices[l]] == 10){
                numberOfTimesVotedTenth = numberOfTimesVotedTenth + 1;
            }
        }
        numberOfTimesVotedFromSixToTen[0]=numberOfTimesVotedSixth;
        numberOfTimesVotedFromSixToTen[1]=numberOfTimesVotedSeventh;
        numberOfTimesVotedFromSixToTen[2]=numberOfTimesVotedEight;
        numberOfTimesVotedFromSixToTen[3]=numberOfTimesVotedNinth;
        numberOfTimesVotedFromSixToTen[4]=numberOfTimesVotedTenth;


        return numberOfTimesVotedFromSixToTen;
    }


    function getNumberOfTimesVotedForOnAllPositions(
        uint256[] candidateIdIndices, bytes32 votingName) internal returns (uint256[]){

        uint256[] memory numberOfTimesVotedFromOneToFive = new uint256[](5);
        uint256[] memory numberOfTimesVotedFromSixToTen = new uint256[](5);

        uint256[] memory numberOfTimesVotedOnAllPositions = new uint256[](10);

        // we split the calculation into two functions here because otherwise the function would be too long
        // and would cause a stack too deep exception
        numberOfTimesVotedFromOneToFive = getNumberOfTimesVotedForPositionsFromOneToFive(candidateIdIndices, votingName);
        numberOfTimesVotedFromSixToTen = getNumberOfTimesVotedForPositionsSixToTen(candidateIdIndices, votingName);


        numberOfTimesVotedOnAllPositions[0] = numberOfTimesVotedFromOneToFive[0];
        numberOfTimesVotedOnAllPositions[1] = numberOfTimesVotedFromOneToFive[1];
        numberOfTimesVotedOnAllPositions[2] = numberOfTimesVotedFromOneToFive[2];
        numberOfTimesVotedOnAllPositions[3] = numberOfTimesVotedFromOneToFive[3];
        numberOfTimesVotedOnAllPositions[4] = numberOfTimesVotedFromOneToFive[4];

        numberOfTimesVotedOnAllPositions[5] = numberOfTimesVotedFromSixToTen[0];
        numberOfTimesVotedOnAllPositions[6] = numberOfTimesVotedFromSixToTen[1];
        numberOfTimesVotedOnAllPositions[7] = numberOfTimesVotedFromSixToTen[2];
        numberOfTimesVotedOnAllPositions[8] = numberOfTimesVotedFromSixToTen[3];
        numberOfTimesVotedOnAllPositions[9] = numberOfTimesVotedFromSixToTen[4];

        return numberOfTimesVotedOnAllPositions;
    }



    function getNumberOfTimesVotedForOnAllPositionsForCandidateNameForVoting(bytes32 votingName, bytes32 candidateName)view public returns (uint256[]){

        // first we find the candidate id for the candidate name
        uint32 candidateId;
        for(uint i=0;i<votingRegistry[votingName].uniqueCandidateNames.length;i++){
            if(votingRegistry[votingName].uniqueCandidateNames[i] == candidateName){
                candidateId = votingRegistry[votingName].uniqueCandidateIds[i];
            }
        }
        // then we calculate the length of the indices array (how many times this candidate vas voted)
        // (solidity does not support dynamic array lengths in in-memory arrays
        uint256 numberOfCandidateIdIndices = 0;

        for(uint j=0;j<votingRegistry[votingName].userIdsUsedForVoteVotedCandidateId.length;j++){
            if(votingRegistry[votingName].userIdsUsedForVoteVotedCandidateId[j] == candidateId){
                numberOfCandidateIdIndices = numberOfCandidateIdIndices +1;
            }
        }
        // then we create the array with the indices of the array where the voted points are stored
        uint256[] memory candidateIdIndices = new uint256[](numberOfCandidateIdIndices);
        uint256 lastCandidateIdIndexUsed = 0;
        for(uint k=0;k<votingRegistry[votingName].userIdsUsedForVoteVotedCandidateId.length;k++){
            if(votingRegistry[votingName].userIdsUsedForVoteVotedCandidateId[k] == candidateId){
                candidateIdIndices[lastCandidateIdIndexUsed]=k;
                lastCandidateIdIndexUsed = lastCandidateIdIndexUsed+1;
            }
        }
        uint256[] memory numberOfTimesVotedForOnAllPositions = new uint256[](numberOfCandidateIdIndices);
        numberOfTimesVotedForOnAllPositions = getNumberOfTimesVotedForOnAllPositions(candidateIdIndices, votingName);

        return numberOfTimesVotedForOnAllPositions;

    }
}
