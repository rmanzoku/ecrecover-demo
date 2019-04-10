OPENZEPPELIN_VERSION=2.2.0
CONTRACT_LIBRARY=0.0.4

exec: contracts/lib/github.com/OpenZeppelin/openzeppelin-solidity-$(OPENZEPPELIN_VERSION) contracts/lib/github.com/doublejumptokyo/contract-library-$(CONTRACT_LIBRARY)


contracts/lib/github.com/OpenZeppelin/openzeppelin-solidity-$(OPENZEPPELIN_VERSION):
	mkdir -p contracts/lib/github.com/OpenZeppelin/
	curl https://codeload.github.com/OpenZeppelin/openzeppelin-solidity/tar.gz/v$(OPENZEPPELIN_VERSION) | tar zx -C contracts/lib/github.com/OpenZeppelin/

contracts/lib/github.com/doublejumptokyo/contract-library-$(CONTRACT_LIBRARY):
	mkdir -p contracts/lib/github.com/doublejumptokyo/
	curl https://codeload.github.com/doublejumptokyo/contract-library/tar.gz/v$(CONTRACT_LIBRARY) | tar zx -C contracts/lib/github.com/doublejumptokyo/
