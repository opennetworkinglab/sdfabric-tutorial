# SPDX-FileCopyrightText: 2020 Open Networking Foundation <info@opennetworking.org>
#
# SPDX-License-Identifier: Apache-2.0

MKFILE_PATH := $(abspath $(lastword $(MAKEFILE_LIST)))
CURRENT_DIR := $(patsubst %/,%,$(dir $(MKFILE_PATH)))

DOCKER_COMPOSE_CMD := docker compose --env-file ./tmp/.env.docker

# Set to devel to use in-development versions of components
UP4_ENV ?= stable
# Define the topology, it can be leafspine or singlepair
TOPO ?= leafspine
STC_ENV := .env.stc-${TOPO}
TOPO_NETCFG := ${CURRENT_DIR}/topo/netcfg-${TOPO}.json

onos_url := http://localhost:8181/onos
onos_curl := curl --fail -sSL --user onos:rocks --noproxy localhost

.PHONY: $(SCENARIOS)

start: ./tmp/.env.docker
	${DOCKER_COMPOSE_CMD} up -d

mn-cli: ./tmp/.env.docker
	$(info *** Attaching to Mininet CLI...)
	$(info *** To detach press Ctrl-D (Mininet will keep running))
	-@docker attach --detach-keys "ctrl-d" $(shell ${DOCKER_COMPOSE_CMD} ps -q mininet) || echo "*** Detached from Mininet CLI"

mn-log:
	docker logs -f mininet

onos-cli:
	ssh -o "UserKnownHostsFile=/dev/null" -o "StrictHostKeyChecking=no" -o LogLevel=ERROR -p 8101 onos@localhost

onos-log: ./tmp/.env.docker
	${DOCKER_COMPOSE_CMD} logs -f onos1

onos-ui:
	open http://localhost:8181/onos/ui

netcfg:
	$(info *** Pushing ${NGSDN_NETCFG_JSON} to ONOS...)
	${onos_curl} -X POST -H 'Content-Type:application/json' \
		${onos_url}/v1/network/configuration -d@${TOPO_NETCFG}
	@echo

# Create ./tmp before Docker does so it doesn't have root owner.
./tmp:
	@mkdir -p ./tmp

# Empty files to record the last value of a variable
./tmp/makevar.env.$(UP4_ENV): ./tmp
	@rm -f ./tmp/makevar.env.*
	@touch $@

./tmp/.env.docker: ./tmp/makevar.env.$(UP4_ENV)
	@echo "# Generated with make ./tmp/.env.docker" > ./tmp/.env.docker
	@cat ${CURRENT_DIR}/.env.stable >> ./tmp/.env.docker
ifneq "${UP4_ENV}" "stable"
	@cat ${CURRENT_DIR}/.env.${UP4_ENV} >> ./tmp/.env.docker
endif
	@echo "MN_SCRIPT=/topo/topo-gtp-${TOPO}.py" >> ./tmp/.env.docker
	@echo "STC_ENV_FILE=${STC_ENV}" >> ./tmp/.env.docker

#$(SCENARIOS): onos-test ./tmp /tmp/stc ./tmp/.env.docker
#	$(info *** Running STC scenario: $@)
#	@export $(shell cat "${CURRENT_DIR}"/"${STC_ENV}" | grep -v '#' | xargs) && \
#		export PATH="${CURRENT_DIR}/bin:${ONOS_TEST}/tools/test/bin:${ONOS_TEST}/tools/test/scenarios/bin:${ONOS_TEST}/tools/package/runtime/bin:${PATH}" && \
#		export WORKSPACE=${CURRENT_DIR} && \
#		export ONOS_ROOT=${ONOS_TEST} && \
#		export CURRENT_DIR=${CURRENT_DIR} && \
#		export STC_VERSION=${STC_VERSION} && \
#		export DOCKER_COMPOSE_CMD="${DOCKER_COMPOSE_CMD}" && \
#		export STC_ENV_FILE=${STC_ENV} && \
#		export TOPO_NETCFG=${TOPO_NETCFG} && \
#		stc $@

deps: pull build

pull: ./tmp/.env.docker
	${DOCKER_COMPOSE_CMD} pull

build: ./tmp/.env.docker
	${DOCKER_COMPOSE_CMD} build --pull

reset:
	-${DOCKER_COMPOSE_CMD} down -t0 --remove-orphans
#	-make fix-permissions
# 	TODO: make it work without sudo
	-sudo rm -rf ./tmp

mock-smf: ./tmp/.env.docker
	${DOCKER_COMPOSE_CMD} exec mock-smf /up4/bin/mock-smf.py pfcp-agent \
		--pcap-file /tmp/mock-smf.pcap -vvv

p4rt-sh: ./tmp/.env.docker
	${DOCKER_COMPOSE_CMD} exec p4rt \
		python3 -m p4runtime_sh \
		--grpc-addr onos1:51001 \
		--device-id 1 --election-id 0,1

versions: ./tmp/.env.docker
	@echo "UP4_ENV=${UP4_ENV}"
	@export $(shell cat "${CURRENT_DIR}"/tmp/.env.docker | grep -v '#' | xargs) && \
	echo $${ONOS_IMAGE} && \
	docker inspect $${ONOS_IMAGE} | jq -r '.[0].Config.Labels' && \
	echo $${DBUF_IMAGE} && \
    docker inspect $${DBUF_IMAGE} | jq -r '.[0].Config.Labels' && \
    echo $${PFCP_AGENT_IMAGE} && \
    docker inspect $${PFCP_AGENT_IMAGE} | jq -r '.[0].Config.Labels' && \
    echo $${MN_STRATUM_IMAGE} && \
    docker inspect $${MN_STRATUM_IMAGE} | jq -r '.[0].Config.Labels'
