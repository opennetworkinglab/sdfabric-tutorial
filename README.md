# WORK-IN-PROGRESS

This tutorial is not ready to be used yet.

***

# SD-Fabric Tutorial

Welcome to the SD-Fabric tutorial!

SD-Fabric is an open source programmable network fabric tailored for
5G-connected edge clouds, with a focus on enterprise and Industry 4.0 use cases.

This repository contains instructions to learn how to use and develop SD-Fabric.
Before starting, we suggest familiarizing with the SD-Fabric architecture and
features using the official SD-Fabric documentation website at
<https://docs.sd-fabric.org>.

In this tutorial, we provide scripts to easily bring up an SD-Fabric environment
in a laptop (or server), including ONOS, emulated Stratum switches, and other
SD-Fabric components. We also provide hands-on exercises that show how to set up
SD-Fabric, use advanced features like the 5G P4-UPF, In-band Network Telemetry,
and more.

## System requirements

All exercises can be executed by installing the following dependencies:

* Docker v1.13.0+ (with docker-compose)
* make
* Python 3
* Bash-like Unix shell
* Wireshark (optional)

We recommend running the exercises on a machine with at least 4 GB of RAM and 4
core CPU. For a smooth experience, we recommend running on a system that has at
least the double of resources.

**Note for macOS users**: if you are using Docker Desktop for Mac, make sure to
adjust the CPU and memory assignments for your Docker VM.

**Note for Windows users**: all scripts have been tested on macOS and Ubuntu.
Although we think they should work on Windows, we have not tested it.

## Get this repo and download dependencies

To work on the exercises you will need to clone this repo and download dependencies:

    git clone https://github.com/opennetworkinglab/sdfabric-tutorial
    cd sdfabric-tutorial
    make deps

The last command will download all necessary Docker images allowing you to work
off-line. If you are doing this tutorial at an event, we recommend running this
step ahead of the tutorial, with a reliable Internet connection.

## Repo structure

**TODO: update**

This repo is structured as follows:

 * `p4src/` P4 implementation
 * `yang/` Yang model used in exercise 2
 * `app/` custom ONOS app Java implementation
 * `mininet/` Mininet script to emulate a 2x2 leaf-spine fabric topology of
   `stratum_bmv2` devices
 * `util/` Utility scripts
 * `ptf/` P4 data plane unit tests based on Packet Test Framework (PTF)

## Tutorial commands

To facilitate working on the exercises, we provide a set of make-based commands
to control the different aspects of the tutorial. Commands will be introduced in
the exercises, here's a quick reference:

| Make command      | Description                                                                |
|-------------------|----------------------------------------------------------------------------|
| `make deps`       | Pull and build all required dependencies                                   |
| `make start`      | Start SD-Fabric containers                                                 |
| `make stop`       | Stop all containers                                                        |
| `make restart`    | Restart containers clearing any previous state                             |
| `make onos-cli`   | Access the ONOS CLI (password: `rocks`, Ctrl-D to exit)                    |
| `make onos-log1`  | Show the log of ONOS instance 1 (replace with 2 and 3 for other instances) |
| `make mn-cli`     | Access the Mininet CLI (Ctrl-D to exit)                                    |
| `make mn-log`     | Show the Mininet log (i.e., the CLI output)                                |
| `make netcfg`     | Push netcfg.json file (network config) to ONOS                             |

## Exercises

Click on the exercise name to see the instructions:

 1. [Environment basics](./EXERCISE-1.md)
 2. [Bridging and routing](./EXERCISE-2.md)
 3. [P4-UPF](./EXERCISE-3.md)
 4. [In-band Network Telemetry](./EXERCISE-4.md)
 5. [BESS-UPF](./EXERCISE-5.md)
## Solutions

You can find solutions for each exercise in the [solution](solution) directory.
Feel free to compare your solution to the reference one whenever you feel stuck.
