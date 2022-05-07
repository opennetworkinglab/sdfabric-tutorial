#!/bin/bash

# SPDX-FileCopyrightText: 2020-present Open Networking Foundation <info@opennetworking.org>
#
# SPDX-License-Identifier: Apache-2.0

mv /usr/sbin/tcpdump /usr/bin/tcpdump

python ${MN_SCRIPT}
