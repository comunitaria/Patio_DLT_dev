pragma solidity ^0.4.24;

contract Provider {
    bytes8 public geohash;
    bytes12 public csc;
    bytes32 providerName;
    string providerPostalAddress;
    bytes32 providerIdentificationNumber;

    // geohash of up 10 characters
    function Provider(bytes8 _geohash, bytes32 _providerName, string _providerPostalAddress,
        bytes32 _providerIdentificationNumber){

      geohash = _geohash;
      csc = computeCSC(geohash, address(this));
      providerName = _providerName;
      providerPostalAddress = _providerPostalAddress;
      providerIdentificationNumber = _providerIdentificationNumber;
    }

    function computeCSC(bytes8 geohash_arg, address addr) internal returns(bytes12) {
      return bytes12(sha3(geohash_arg, addr));
    }
}
