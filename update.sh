#!/bin/bash

# Colors.
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

BALET_DIR="$HOME/.balet"

printf "${CYAN}Updating Balet...\n${NC}"
cd "$BALET_DIR"
if git pull --rebase --stat origin master
then
  printf "${GREEN}Balet is updated successfully! \xE2\x9C\x94\n\n${NC}"
else
  printf "${RED}There was an error while updating Balet, try again later.\n${NC}"
fi
