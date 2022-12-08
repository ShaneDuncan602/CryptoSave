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
deployAll:; 	forge script script/DeployAll.s.sol --ffi --fork-url http://localhost:8545  --broadcast -vvvvv --private-key ${PRIVATE_KEY} --slow
# Deploy contracts to goerli 
deployAllG:; 	forge script script/DeployAll.s.sol --ffi --rpc-url https://eth-goerli.g.alchemy.com/v2/RJNCmZZmdeEeZaSTdxlcXfWhapJ1zG7n  --broadcast --verify -vvvv --private-key d217d015137f62ae7330f4660c9e5e19ade9b0ae91387997baec82b072aa491c

deployCtoG:; forge create CryptoSave --rpc-url https://eth-goerli.g.alchemy.com/v2/RJNCmZZmdeEeZaSTdxlcXfWhapJ1zG7n  --private-key d217d015137f62ae7330f4660c9e5e19ade9b0ae91387997baec82b072aa491c
deploy1:; forge create src/CryptoSave.sol:CryptoSave --private-key ${PRIVATE_KEY}
deploy2:; forge create src/SvgModel.sol:SvgModel --private-key ${PRIVATE_KEY}
deploy3:; forge create src/WidgetNFT.sol:WidgetNFT --private-key ${PRIVATE_KEY}

# Run all tests
testAll:; forge test --fork-url https://eth-mainnet.g.alchemy.com/v2/613t3mfjTevdrCwDl28CVvuk6wSIxRPi -v
testC:; forge test --fork-url https://eth-mainnet.g.alchemy.com/v2/613t3mfjTevdrCwDl28CVvuk6wSIxRPi -vv --match-contract CryptoSave
testDemo:; forge test --fork-url https://eth-mainnet.g.alchemy.com/v2/613t3mfjTevdrCwDl28CVvuk6wSIxRPi -vv --match-test testDemo

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

connectSvg:; cast send ${WIDGETNFT_ADDR} "setSvgModelAddress(address)" ${SVGMODEL_ADDR} --from ${ADDRESS} --rpc-url ${RPC_URL}
connectCrypto:; cast send ${WIDGETNFT_ADDR} "setCryptoSaveAddress(address)" ${CRYPTO_SAVE_ADDR} --from ${ADDRESS} --rpc-url ${RPC_URL}
mint:; cast send ${WIDGETNFT_ADDR} "mint()" --from ${ADDRESS} --rpc-url ${RPC_URL}
tokenURI:; cast send ${WIDGETNFT_ADDR} "tokenURI(uint256)" 10 --from ${ADDRESS} --rpc-url ${RPC_URL}

getCryptoAddr:; cast call ${WIDGETNFT_ADDR} "getCryptoSaveAddress()(address)" --from ${ADDRESS} --rpc-url ${RPC_URL}
