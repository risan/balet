#!/bin/bash

# Colors.
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

BALET_DIR="$HOME/.balet"
SERVERS_DIR="$BALET_DIR/servers"

printf "${GREEN}Your Balet registered websites:\n\n${NC}"
for file in $( find ${SERVERS_DIR}/*.dev -maxdepth 1 -type f ); do
  filename=`basename "$file"`
  printf "${YELLOW} - $filename\n"
done
