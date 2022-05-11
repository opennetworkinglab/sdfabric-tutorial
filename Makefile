# SPDX-FileCopyrightText: 2020 Open Networking Foundation <info@opennetworking.org>
#
# SPDX-License-Identifier: Apache-2.0

MKFILE_PATH := $(abspath $(lastword $(MAKEFILE_LIST)))
CURRENT_DIR := $(patsubst %/,%,$(dir $(MKFILE_PATH)))

# TODO: add other topos
# oneswitch, leafpair, leafspine
export TOPO ?= leafspine


ONOS_URL := http://localhost:8181/onos
ONOS_CURL := curl --fail -sSL --user onos:rocks --noproxy localhost

.PHONY: $(SCENARIOS)

start: ./tmp
	$(info *** Starting all containers...)
	docker compose up -d

stop:
	$(info *** Stopping all containers...)
	docker compose down -t0 --remove-orphans

restart: reset start

mn-cli:
	$(info *** Attaching to Mininet CLI...)
	$(info *** To detach press Ctrl-D (Mininet will keep running))
	-@docker attach --detach-keys "ctrl-d" mininet || echo "*** Detached from Mininet CLI"

mn-log:
	docker logs -f mininet

onos-cli:
	ssh -o "UserKnownHostsFile=/dev/null" -o "StrictHostKeyChecking=no" -o LogLevel=ERROR -p 8101 onos@localhost

onos-log:
	docker compose logs -f onos1

onos-ui:
	open http://localhost:8181/onos/ui

pfcp-log:
	docker compose logs -f pfcp-agent

netcfg: NETCFG_JSON := ./config/netcfg-${TOPO}.json
netcfg: _netcfg

netcfg-up4: NETCFG_JSON := ./config/netcfg-up4.json
netcfg-up4: _netcfg

_netcfg:
	$(info *** Pushing ${NETCFG_JSON} to ONOS...)
	${ONOS_CURL} -X POST -H 'Content-Type:application/json' \
		${ONOS_URL}/v1/network/configuration -d@${NETCFG_JSON}
	@echo

# Create ./tmp before Docker does so it doesn't have root owner.
./tmp:
	@mkdir -p ./tmp

deps: pull build

pull:
	docker compose pull

build:
	docker compose build --pull

reset:
	-docker compose down -t0 --remove-orphans
#	-make fix-permissions
# 	TODO: make it work without sudo
	-sudo rm -rf ./tmp

smf-sim:
	docker compose exec smf-sim /up4/bin/smf-sim.py pfcp-agent \
		--pcap-file /tmp/smf-sim.pcap -vvv

up4-p4rt-sh:
	docker compose exec p4rt \
		python3 -m p4runtime_sh \
		--grpc-addr onos1:51001 \
		--device-id 1 --election-id 0,1
