#!/usr/bin/python3
# SPDX-FileCopyrightText: 2022-present Intel Corporation
# SPDX-License-Identifier: Apache-2.0

# Script used in Exercise 8.
# Send downlink packets to UE address.
import argparse

from scapy.layers.inet import IP, UDP
from scapy.sendrecv import send

RATE = 5  # packets per second
PAYLOAD = ' '.join(['P4 is great!'] * 50)

parser = argparse.ArgumentParser(description='Send UDP packets to the given IPv4 address')
parser.add_argument('ipv4_dst', type=str, help="Destination IPv4 address")
args = parser.parse_args()

print("Sending %d UDP packets per second to %s..." % (RATE, args.ipv4_dst))

pkt = IP(dst=args.ipv4_dst) / UDP(sport=80, dport=400) / PAYLOAD
send(pkt, inter=1.0 / RATE, loop=True, verbose=True)
