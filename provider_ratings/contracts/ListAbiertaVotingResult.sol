pragma solidity ^0.4.24;

contract ListAbiertaVotingResult{

    struct Vote{
          uint32 userId;
          uint32 votedCandidateId;
          uint32 points;
          bool isValue;
        }


    struct Voting {
        uint32[] uniqueUserIds;
        bytes32[] uniqueUserHashes;
        uint32[] userIdsUsedForVote;
        uint32[] userIdsUsedForVoteVotedCandidateId;
        uint32[] userIdsUsedForVoteVotedPoints;
        uint32[] uniqueCandidateIds;
        bytes32[] uniqueCandidateNames;
        Vote[] votes;
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

//    function getVotingForVotingName(bytes32 votingName) internal returns (Voting){
//        return votingRegistry[votingName];
//    }

    function getCandidateNameForVotingNameAtIndex(bytes32 votingName, uint32 index) view public returns (bytes32){
        return votingRegistry[votingName].uniqueCandidateNames[1];
    }

    function getVotedCandidateIdsForVoterIdForVoting(uint32 voterId, bytes32 votingName) public returns (uint256[]){
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

    function getVotedCandidatePointsForVoterIdForVoting(uint32 voterId, bytes32 votingName) public returns (uint256[]){
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

    function getCandidateNameForCandidateIdForVoting(uint256 candidateId, bytes32 votingName) public returns(bytes32){
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

        function getVoterIdForVoterHashForVoting(bytes32 voterHash, bytes32 votingName) public returns(uint32){
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
}
