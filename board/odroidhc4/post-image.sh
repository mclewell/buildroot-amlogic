#!/bin/bash

BOARD_DIR="$(dirname $0)"

echo "Creating SD-Card image..."
cd ~-
support/scripts/genimage.sh -c ${BOARD_DIR}/genimage.cfg
