pragma solidity 0.5.7;

import "./lib/github.com/OpenZeppelin/openzeppelin-solidity-2.2.0/contracts/cryptography/ECDSA.sol";
import "./lib/github.com/doublejumptokyo/contract-library-0.0.4/contracts/access/roles/OperatorRole.sol";

contract MCHMetaMarking is OperatorRole {

  mapping(address => uint256) public nonces;
  mapping(address => bool) public relayers;
  struct Mark {
    bool isExist;
    uint markAt;
    uint32 uid;
    bool isPrime;
    uint8 landType;
  }

  mapping(uint8 => address[]) public addressesByLandType;
  mapping(address => Mark) public latestMarkByAddress;

  constructor() public {
    addOperator(address(0xd868711BD9a2C6F1548F5f4737f71DA67d821090));
    relayers[address(0xd868711BD9a2C6F1548F5f4737f71DA67d821090)] = true;
  }

  function setRelayer(address _relayer, bool _new) external onlyOwner() {
    relayers[_relayer] = _new;
  }

  function encodeData(address _from, uint256 _markAt, uint8 _landType, uint256 _nonce, address _relayer) public view returns (bytes32) {
    return keccak256(abi.encodePacked(
                                      address(this),
                                      _from,
                                      _markAt,
                                      _landType,
                                      _nonce,
                                      _relayer
                                      )
                     );
  }

  function recover(bytes32 _data, bytes memory _sig) public pure returns (address) {
    bytes32 data = ECDSA.toEthSignedMessageHash(_data);
    return ECDSA.recover(data, _sig);
  }

  function executeMarkMetaTx(address _from, uint256 _markAt, uint32 _uid, bool _isPrime, uint8 _landType, uint256 _nonce, bytes calldata _sig) external {
    require(relayers[msg.sender] == true, "msg.sender is not relayer");
    require(nonces[_from]+1 == _nonce, "nonces[_from]+1 != _nonce");
    bytes32 encodedData = encodeData(_from, _markAt, _landType, _nonce, msg.sender);
    address signer = recover(encodedData, _sig);
    require(_from == signer, "signer != _from");

    _mark(_from, _markAt, _uid, _isPrime, _landType);
    nonces[_from]++;
  }

  function forceMark(address _user, uint256 _markAt, uint32 _uid, bool _isPrime, uint8 _landType) external onlyOperator() {
    _mark(_user, _markAt, _uid, _isPrime, _landType);
  }

  function _mark(address _user, uint256 _markAt, uint32 _uid, bool _isPrime, uint8 _landType) private {

    if (!latestMarkByAddress[_user].isExist) {
      latestMarkByAddress[_user] = Mark(
                                        true,
                                        _markAt,
                                        _uid,
                                        _isPrime,
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

    latestMarkByAddress[_user].markAt = _markAt;
    latestMarkByAddress[_user].uid = _uid;
    latestMarkByAddress[_user].isPrime = _isPrime;
    latestMarkByAddress[_user].landType = _landType;
  }

  function getAddressesByLandType(uint8 _landType, uint256 _validBlockFrom) public view returns (address[] memory){
    if (addressesByLandType[_landType].length == 0) {
      return new address[](0);
    }

    uint256 cnt;
    for (uint256 i = 0; i < addressesByLandType[_landType].length; i++) {
      address addr = addressesByLandType[_landType][i];
      if (addr == address(0x0)) {
        continue;
      }

      if (latestMarkByAddress[addr].markAt >= _validBlockFrom) {
        cnt++;
      }
    }

    address[] memory ret = new address[](cnt);
    uint256 idx = 0;
    for (uint256 i = 0; i < addressesByLandType[_landType].length; i++) {
      address addr = addressesByLandType[_landType][i];
      if (addr == address(0x0)) {
        if (latestMarkByAddress[addr].markAt < _validBlockFrom) {
          continue;
        }

        if (latestMarkByAddress[addr].markAt >= _validBlockFrom) {
          ret[idx] = addressesByLandType[_landType][i];
          idx++;
        }
      }
    }

    return ret;
  }

  function meta_nonce(address _from) external view returns (uint256 nonce) {
    return nonces[_from];
  }

  function kill() external onlyOperator() {
    selfdestruct(msg.sender);
  }
}
