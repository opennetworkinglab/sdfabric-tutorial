#!/bin/bash

# SPDX-FileCopyrightText: 2022-present Intel Corporation
# SPDX-License-Identifier: Apache-2.0

mv /usr/sbin/tcpdump /usr/bin/tcpdump

python "${MN_SCRIPT}"
