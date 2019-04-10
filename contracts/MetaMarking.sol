pragma solidity 0.5.7;

contract MCHMetaMarking {

  mapping(uint8 => address[]) public addressesByLandType;
  mapping(address => uint8) public landTypeByAddress;

  constructor() public {
  }

  function addMember(uint8 _landType, address _user) public {
    uint8 currentLandType = landTypeByAddress[_user];
    require(_landType != 0, "_landType != 0");
    require(_landType != currentLandType, "Already added member");

    if (currentLandType != 0) {
      uint256 i;
      for (i = 0; i < addressesByLandType[_landType].length; i++) {
	if (addressesByLandType[_landType][i] != _user) {
	  break;
	}
      }

      delete addressesByLandType[currentLandType][i];
    }

    addressesByLandType[_landType].push(_user);
    landTypeByAddress[_user] = _landType;
  }

  function getAddressesByLandType(uint8 _landType) public view returns (address[] memory){
    if (addressesByLandType[_landType].length == 0) {
      return new address[](0);
    }

    uint256 cnt;
    for (uint256 i = 0; i < addressesByLandType[_landType].length; i++) {
      if (addressesByLandType[_landType][i] == address(0x0)) {
	continue;
      }
      cnt++;
    }

    address[] memory ret = new address[](cnt);
    uint256 idx = 0;
    for (uint256 i = 0; i < addressesByLandType[_landType].length; i++) {
      if (addressesByLandType[_landType][i] == address(0x0)) {
	continue;
      }
      ret[idx] = addressesByLandType[_landType][i];
      idx++;
    }

    return ret;
  }

  function kill() external {
    selfdestruct(msg.sender);
  }

}
