pragma solidity 0.5.7;

contract MCHMetaMarking {

  struct Mark {
    bool isExist;
    uint markAt;
    // uint32 uid;
    uint8 landType;
    // bool isPrime;
  }


  mapping(uint8 => address[]) public addressesByLandType;
  mapping(address => Mark) public latestMarkByAddress;


  constructor() public {
  }

  function mark(uint8 _landType, address _user) public {

    if (!latestMarkByAddress[_user].isExist) {
      latestMarkByAddress[_user] = Mark(
                                        true,
                                        block.number,
                                        _landType
                                        );
      addressesByLandType[_landType].push(_user);
      return;
    }

    uint8 currentLandType = latestMarkByAddress[_user].landType;
    if (currentLandType != _landType) {
      uint256 i;
      for (i = 0; i < addressesByLandType[_landType].length; i++) {
	if (addressesByLandType[_landType][i] != _user) {
	  break;
	}
      }

      delete addressesByLandType[currentLandType][i];
      addressesByLandType[_landType].push(_user);
    }

    latestMarkByAddress[_user].markAt = block.number;
    latestMarkByAddress[_user].landType = _landType;
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
