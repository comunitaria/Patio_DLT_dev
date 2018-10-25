pragma solidity ^0.4.21;
import "zos-lib/contracts/migrations/Migratable.sol";

contract MyContract is Migratable {
  uint256 public x;

  //
  function initialize(uint256 _x) isInitializer("MyContract", "0") public {
    x = _x;
  }
}
