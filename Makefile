-include .env

deploy-sepolia:
	forge script script/DeployFaceNft.s.sol --rpc-url $(ETHEREUM_SEPOLIA_RPC_URL) --account key --verify --etherscan-api-key $(ETHERSCAN_API_KEY) --broadcast -vvvv

deploy-optimism:
	forge script script/DeployFaceNft.s.sol --rpc-url $(OPTIMISM_SEPOLIA_RPC_URL) --account key --verify --etherscan-api-key $(OPTIMISM_ETHERSCAN_API_KEY) --broadcast -vvvv

deploy-arbitrum:
	forge script script/DeployFaceNft.s.sol --rpc-url $(ARBITRUM_SEPOLIA_RPC_URL) --account key --verify --etherscan-api-key $(ARBISCAN_API_KEY) --broadcast -vvvv


test-sepolia:
	forge test --rpc-url $(ETHEREUM_SEPOLIA_RPC_URL)

test-optimism:
	forge test --rpc-url $(OPTIMISM_SEPOLIA_RPC_URL)

test-arbitrum:
	forge test --rpc-url $(ARBITRUM_SEPOLIA_RPC_URL)


coverage-sepolia:
	forge coverage --rpc-url $(ETHEREUM_SEPOLIA_RPC_URL)

coverage-optimism:
	forge coverage --rpc-url $(OPTIMISM_SEPOLIA_RPC_URL)

coverage-arbitrum:
	forge coverage --rpc-url $(ARBITRUM_SEPOLIA_RPC_URL)


mint-sepolia:
	forge script script/Interactions.s.sol --rpc-url $(ETHEREUM_SEPOLIA_RPC_URL) --account key --verify --etherscan-api-key $(ETHERSCAN_API_KEY) --broadcast -vvvv

mint-optimism:
	forge script script/Interactions.s.sol --rpc-url $(OPTIMISM_SEPOLIA_RPC_URL) --account key --verify --etherscan-api-key $(OPTIMISM_ETHERSCAN_API_KEY) --broadcast -vvvv

mint-arbitrum:
	forge script script/Interactions.s.sol --rpc-url $(ARBITRUM_SEPOLIA_RPC_URL) --account key --verify --etherscan-api-key $(ARBISCAN_API_KEY) --broadcast -vvvv


