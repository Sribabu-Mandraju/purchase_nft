# Foundry Project Management
.PHONY: install test build deploy clean

include .env

install:
	forge install

update:
	forge update

build:
	forge build

test:
	forge test -vvv

test-gas:
	forge test --gas-report

clean:
	forge clean

snapshot:
	forge snapshot

fmt:
	forge fmt

lint: fmt

# Deployment examples (adjust for your needs)

deploy-mint:
	@forge script script/interactions.s.sol:MintTokens  --rpc-url $(RPC_URL) --private-key $(PRIVATE_KEY) --broadcast -vvvvv

deploy-base:
	@forge script script/BaseDeploy.s.sol:BaseDeploy  --rpc-url $(RPC_URL) --private-key $(PRIVATE_KEY) --broadcast -vvvvv

deploy-nftPurchase:
	@forge script script/interactions.s.sol:PurchaseNFT  --rpc-url $(RPC_URL) --private-key $(PRIVATE_KEY) --broadcast -vvvvv

deploy-withDraw:
	@forge script script/interactions.s.sol:WithDrwaTokens  --rpc-url $(RPC_URL) --private-key $(PRIVATE_KEY) --broadcast -vvvvv

t-nft:
	@forge test --match-path test/TestDenverNFT.t.sol -vvvvv

