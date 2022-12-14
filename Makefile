# include .env file and export its env vars
# (-include to ignore error if it does not exist)
-include .env

all: clean remove install update solc build deploy

# Install proper solc version.
solc:; nix-env -f https://github.com/dapphub/dapptools/archive/master.tar.gz -iA solc-static-versions.solc_0_8_17

# Clean the repo
clean  :;	forge clean

# Remove modules
remove :; rm -rf .gitmodules && rm -rf .git/modules/* && rm -rf lib && touch .gitmodules && git add . && git commit -m "modules"

# Install the Modules
install :; 
	forge install dapphub/ds-test 
	forge install OpenZeppelin/openzeppelin-contracts

# Update Dependencies
update:; forge update

# Builds
build  :; forge clean && forge build --optimize

# Deploy contracts to anvil
deployAll:; 	forge script script/DeployAll.s.sol --ffi --fork-url http://localhost:8545  --broadcast --verify -vvvv --private-key ${PRIVATE_KEY}
# Deploy contracts to goerli 
deployAllG:; 	forge script script/DeployAll.s.sol --ffi --rpc-url https://eth-goerli.g.alchemy.com/v2/RJNCmZZmdeEeZaSTdxlcXfWhapJ1zG7n  --broadcast --verify -vvvv --private-key ${ADDRESS}

deployCtoG:; forge create CryptoSave --rpc-url https://eth-goerli.g.alchemy.com/v2/RJNCmZZmdeEeZaSTdxlcXfWhapJ1zG7n  --private-key ${PRIVATE_KEY}

# Run all tests
testAll:; forge test --fork-url https://eth-mainnet.g.alchemy.com/v2/613t3mfjTevdrCwDl28CVvuk6wSIxRPi -vv

# Interact with locally deployed contract
testFund:; cast send ${CRYPTO_SAVE_ADDR} "fundContract(uint256)" 1200 --value 10ether --private-key ${PRIVATE_KEY} --rpc-url ${RPC_URL}
testPoke0:; cast send ${CRYPTO_SAVE_ADDR} "poke(uint8,uint256,uint256)" 0 1100 1 --from ${ADDRESS} --rpc-url ${RPC_URL}
testPoke1:; cast send ${CRYPTO_SAVE_ADDR} "poke(uint8,uint256,uint256)" 1 900 1 --from ${ADDRESS} --rpc-url ${RPC_URL}
getCrypto:; cast call ${CRYPTO_SAVE_ADDR} "getCryptoAmount()(uint256)" --from ${ADDRESS} --rpc-url ${RPC_URL}
getStable:; cast call ${CRYPTO_SAVE_ADDR} "getStableAmount()(uint256)" --from ${ADDRESS} --rpc-url ${RPC_URL}
getStrPos:; cast call ${CRYPTO_SAVE_ADDR} "getOriginalPositionValue()(uint256)" --from ${ADDRESS} --rpc-url ${RPC_URL}
getEndPos:; cast call ${CRYPTO_SAVE_ADDR} "getCurrentPositionValue()(uint256)" --from ${ADDRESS} --rpc-url ${RPC_URL}
getInMoney:; cast call ${CRYPTO_SAVE_ADDR} "getIsInMoney()(bool)" --from ${ADDRESS} --rpc-url ${RPC_URL}
getLifePct:; cast call ${CRYPTO_SAVE_ADDR} "getStrLifeTimePercentage()(string)" --from ${ADDRESS} --rpc-url ${RPC_URL}