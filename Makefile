-include .env

deploy-sepolia:
	forge script script/DeployDynamicPfp.s.sol --rpc-url $(ETHEREUM_SEPOLIA_RPC_URL) --account key --verify --etherscan-api-key $(ETHERSCAN_API_KEY) --broadcast -vvvv

