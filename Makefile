#### VARIABLES ####
SHELL=/usr/bin/env bash
ifndef DIR
DIR = ~/node_data/
endif
DATA_PATH = $(shell readlink -f ${DIR})
GITHUB_TOKEN = $(shell cat ${DIR}github_token.txt)
# requires 'rq' and 'jq' command line utils, install with `cargo install record-query`
# The permanent IP address of your validator.
# IP = $(shell rq -t < ~/node_data/miner.toml | jq -r '.profile.ip')
# The 0L account, which will be your namespace for all data
# Also is last 16 digits of auth_key hex.
ACC = alice

NAMESPACE = $(ACC)
REPO_ORG = OLSF
REPO_NAME = dev-genesis
# Don't put the MNEM here for production, add that by command line only.


ifndef NODE_ENV
# Default to prod settings for genesis and mining. Pass with NODE_ENV=stage for staging values.
NODE_ENV=prod
endif

echo:
	@echo NAMESPACE: ${NAMESPACE}
	@echo test: ${TEST}
	@echo env: ${NODE_ENV}
	@echo path: ${DATA_PATH}
	@echo ip: ${IP}
	@echo account: ${ACC}
	@echo github_token: ${GITHUB_TOKEN}
	@echo github_org: ${REPO_ORG}
	@echo github_repo: ${REPO_NAME}

######################################
## THIS IS TEST DATA -- NOT FOR GENESIS##

ifeq ($(NAMESPACE), alice)
NAMESPACE = alice
ACC = f094dfc3d134331d5410a23f795117b8
AUTH = f0dc83910c2263e5301431114c5c6d12f094dfc3d134331d5410a23f795117b8
IP = 142.93.191.147
MNEM = average list time circle item couch resemble tool diamond spot winter pulse cloth laundry slice youth payment cage neutral bike armor balance way ice
endif

ifeq ($(NAMESPACE), bob)
ACC = 5831d5f6cb6c0c5c576c186f9c4efb63
AUTH = b28f75b8cdd27913ac785d38161501665831d5f6cb6c0c5c576c186f9c4efb63
IP = 167.71.84.248
MNEM = owner city siege lamp code utility humor inherit plug tuna orchard lion various hill arrow hold venture biology aisle talent desert expand nose city
endif

ifeq ($(NAMESPACE), carol)
ACC = 07dcd9c8d1dbaaa1611880cbe4ee9691
AUTH = 89d1026ea2e6dd5a0366f96e773dec0b07dcd9c8d1dbaaa1611880cbe4ee9691
IP = 104.131.56.224
MNEM = motor employ crumble add original wealth spray lobster eyebrow title arrive hazard machine snake east dish alley drip mail erupt source dinner hobby day
endif

ifeq ($(NAMESPACE), dave)
ACC = 4a6dcca79b3828fc665fca5c6218d793
AUTH = 4a62540137e5f3b05c6ea608e37b3ab74a6dcca79b3828fc665fca5c6218d793
IP = 104.131.32.62
MNEM = advice organ wage sick travel brief leave renew utility host roast barely can noble cheap cancel rotate series method inside damage beach tomorrow power
endif

ifeq ($(NAMESPACE), eve)
ACC = e9fbaf07795acc2e675961eb7649acdf
AUTH = a34b9c1580fe7f7c518dac7ed9ddba0be9fbaf07795acc2e675961eb7649acdf
IP = 134.122.115.12
MNEM = veteran category typical plastic service mimic photo sort face taste puppy slogan nature youth member lake symptom edit pepper stairs actual hub miss train
endif

##########################

REMOTE = 'backend=github;repository_owner=${REPO_ORG};repository=${REPO_NAME};token=${DATA_PATH}/github_token.txt;namespace=${NAMESPACE}'
LOCAL = 'backend=disk;path=${DATA_PATH}/key_store.json;namespace=${NAMESPACE}'

##### PIPELINES #####
compile: stop stdlib bins
# pipelines for genesis ceremony
register: stop clear fixtures init add-proofs keys register
# do genesis
genesis: stop build-genesis waypoint toml peers

#### ENVIRONMENT #####
install:
	sudo apt-get update
	sudo apt-get -y install build-essential cmake clang llvm libgmp-dev zip secure-delete jq
# TODO: Cargo is not getting set to path. This next line doesn't run.
#install rq, a tool for manipulateing TOML
	curl -LSfs https://japaric.github.io/trust/install.sh | sh -s -- --git dflemstr/rq
# install rust
	sudo curl https://sh.rustup.rs -sSf | sh -s -- --default-toolchain nightly -y
	
stdlib:
	cd ~/libra/language/stdlib && cargo run --release

bins:
	cd ~/libra && cargo build -p libra-node --release & sudo cp -f ~/libra/target/release/libra-node /usr/local/bin/libra-node
	# cd ~/libra && cargo build -p libra-management --release && sudo cp -f ~/libra/target/release/libra-management /usr/local/bin/libra-management
	cd ~/libra && cargo build -p miner --release && sudo cp -f ~/libra/target/release/miner /usr/local/bin/miner

all-bins:
	cd ~/libra && cargo build --all --bins --release --exclude cluster-test

#### GENESIS BACKEND SETUP ####
init-backend: 
	curl -X POST -H "Authorization: token ${GITHUB_TOKEN}" https://api.github.com/orgs/${REPO_ORG}/repos -d '{"name":"${REPO_NAME}", "private": "true", "auto_init": "true"}'

init-layout:
	cargo run -p libra-management -- set-layout \
	--backend 'backend=github;owner=${REPO_ORG};repository=${REPO_NAME};token=${DATA_PATH}/github_token.txt;namespace=common' \
	--path=set_layout_${NODE_ENV}.toml


#### GENESIS REGISTRATION ####
init-old:
ifdef TEST
	#for debug-net fill in mnemonic from fixtures
	echo ${MNEM} | head -c -1 | cargo run -p libra-management -- initialize --path=${DATA_PATH} --namespace=${NAMESPACE}
else
	cargo run -p libra-management -- initialize \
	--path=${DATA_PATH} \
	--namespace=${NAMESPACE}
endif

init:
	cargo run -p libra-genesis-tool -- init --path=${DATA_PATH} --namespace=${NAMESPACE}

add-proofs:
	cargo run -p libra-management -- mining \
	--path-to-genesis-pow ${DATA_PATH}/blocks/block_0.json \
	--backend ${REMOTE}

keys-old:
	cargo run -p libra-management -- operator-key \
	--local ${LOCAL} \
	--remote ${REMOTE}

keys:
	cargo run -p libra-genesis-tool -- operator-key \
	--validator-backend ${LOCAL} \
	--shared-backend ${REMOTE}

reg:
	cargo run -p libra-genesis-tool -- validator-config \
	--owner-name ${ACC} \
	--chain-id "1" \
	--validator-address "/ip4/${IP}/tcp/6180" \
	--fullnode-address "/ip4/${IP}/tcp/6179" \
	--validator-backend ${LOCAL} \
	--shared-backend ${REMOTE}

# libra-genesis-tool
# validator-config
# --owner-name {owner_name}
# --validator-address {validator_address}
# --fullnode-address {fullnode_address}
# --chain-id {chain_id}
# --validator-backend backend={backend};\
#     path={path};\
#     namespace={validator_ns}
# --shared-backend backend={backend};\
#     path={path};\
#     namespace={shared_ns}


#### GENESIS  ####
build-genesis:
	NODE_ENV='${NODE_ENV}' cargo run -p libra-management -- genesis \
	--backend ${REMOTE} \
	--path ${DATA_PATH}/genesis.blob

waypoint:
	NODE_ENV='${NODE_ENV}' cargo run -p libra-management -- create-waypoint \
	--remote ${REMOTE} \
	--local ${LOCAL} \
	--path ${DATA_PATH}

	$(eval WAY = $(shell cat ${DATA_PATH}/genesis_waypoint.txt))

# modify miner.toml to inlcude waypoint
	rq -t < ${DATA_PATH}/miner.toml | \
	jq '.["chain_info"]."base_waypoint" = "${WAY}"' | \
	rq -jT > tmp
	mv tmp ${DATA_PATH}/miner.toml
	cat ${DATA_PATH}/miner.toml

toml:
	cargo run -p libra-management -- config \
	--validator-address "/ip4/${IP}/tcp/6180" \
	--validator-listen-address "/ip4/0.0.0.0/tcp/6180" \
	--backend ${LOCAL} \
	--fullnode-address "/ip4/${IP}/tcp/6179" \
	--fullnode-listen-address "/ip4/0.0.0.0/tcp/6179" \
	--path ${DATA_PATH}/

peers:
# cp -f seed_peers.toml backup.seed_peers.toml
	cargo run -p libra-management -- seeds --genesis-path ${DATA_PATH}/genesis.blob
# TODO: Seed peers gets places in working path, deep in libra code.
	mv network_peers.toml  ${DATA_PATH}/network_peers.toml
	mv seed_peers.toml  ${DATA_PATH}/seed_peers.toml

remove-keys:
	jq 'del(.["${NAMESPACE}/owner", "${NAMESPACE}/operator", "${NAMESPACE}/operator_previous", "${NAMESPACE}/owner_previous"])' ${DATA_PATH}/key_store.json > ${DATA_PATH}/tmp
	mv ${DATA_PATH}/tmp ${DATA_PATH}/key_store.json

#### NODE MANAGEMENT ####
start:
# run in foreground. Only for testing, use a daemon for net.
	libra-node --config ${DATA_PATH}/node.configs.toml

daemon:
# your node's custom libra-node.service lives in node_data. Take the template from libra/utils and edit for your needs.
	sudo cp -f ~/node_data/libra-node.service /lib/systemd/system/
# cp -f miner.service /lib/systemd/system/
	if test -d ~/logs; then \
		echo "WIPING SYSTEMD LOGS"; \
		sudo rm -rf ~/logs*; \
	fi 

	sudo mkdir ~/logs
	sudo touch ~/logs/node.log
	sudo chmod 660 ~/logs
	sudo chmod 660 ~/logs/node.log

	sudo systemctl daemon-reload
	sudo systemctl stop libra-node.service
	sudo systemctl start libra-node.service
	sudo sleep 2
	sudo systemctl status libra-node.service &
	sudo tail -f ~/logs/node.log

miner:
ifdef TEST
#for debug-net fill in mnemonic from fixtures
	@echo ${MNEM}
	NODE_ENV='${NODE_ENV}' cd ${DATA_PATH} && miner start
else
	if test -d ~/logs; then \
		echo "WIPING MINER LOGS"; \
		sudo rm -rf ~/logs/miner.log; \
		sudo touch ~/logs/miner.log
		sudo chmod 660 ~/logs/miner.log
	fi 

# submit any backlog transactions
	NODE_ENV='${NODE_ENV}' cd ${DATA_PATH} && miner start --resubmit
# pipe logs to screen and tee to miner logs
	NODE_ENV='${NODE_ENV}' cd ${DATA_PATH} && miner start 2> >(tee ~/logs/miner.log)

endif



#### HELPERS ####
get_waypoint:
	$(eval export WAY = $(shell jq -r '. | with_entries(select(.key|match("waypoint";"i")))[].value.value' ~/node_data/key_store.json))
	echo $$WAY

client: get_waypoint
	cargo run --bin cli -- -u http://localhost:8080 --waypoint $$WAY

compress: 
	tar -C ~/libra/target/release/ -czvf test_net_bins.tar.gz libra-node miner
  
keygen:
	cd ${DATA_PATH} && miner keygen

miner-genesis:
	cd ${DATA_PATH} && NODE_ENV=${NODE_ENV} miner genesis

reset: stop clear fixtures init keys genesis daemon

wipe: 
	history -c
	shred ~/.bash_history
	srm ~/.bash_history

stop:
	sudo service libra-node stop

#### TEST SETUP ####

clear:
ifdef TEST
	service libra-node stop
	if test -f ~/node_data/key_store.json; then \
		cd ${DATA_PATH} && rm -rf libradb *.toml *.blob *.json; \
		rm ${DATA_PATH}/blocks/*; \
	fi 

endif

fixtures:
ifdef TEST
	echo ${NAMESPACE}

	mkdir -p ${DATA_PATH}/blocks/

	if test -f ${DATA_PATH}/blocks/block_0.json; then \
		rm ${DATA_PATH}/blocks/block_0.json; \
	fi 

	cp ~/libra/fixtures/miner.toml.${NAMESPACE} ${DATA_PATH}/miner.toml

	cp ~/libra/fixtures/block_0.json.${NODE_ENV}.${NAMESPACE} ${DATA_PATH}/blocks/block_0.json

endif