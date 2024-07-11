-include .env

deploy-sepolia:
	forge script script/DeployFaceNft.s.sol --rpc-url $(ETHEREUM_SEPOLIA_RPC_URL) --account key --verify --etherscan-api-key $(ETHERSCAN_API_KEY) --broadcast -vvvv

test-sepolia:
	forge test --rpc-url $(ETHEREUM_SEPOLIA_RPC_URL)

	