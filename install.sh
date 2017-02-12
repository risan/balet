#!/bin/bash

# Colors.
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

BALET_DIR="$HOME/.balet"
ZSHRC_FILE="$HOME/.zshrc"

# Make sure that the Balet is not installed.
if [ -d "$BALET_DIR" ]; then
  echo "${RED}You already have Balet installed: $BALET_DIR${NC}"
  exit 1
fi

# Welcome message.
echo "${CYAN}Installing Balet...${NC}"

# Clone the Balet repository.
echo "${CYAN}Cloning Balet into: $BALET_DIR${NC}"
git clone --depth=1 https://github.com/risan/balet.git $BALET_DIR

# Add balet to system path permanently within the .zshrc.
echo "${CYAN}Adding Balet to system path...${NC}"
sed -i '' '/export PATH="$HOME\/.balet\/bin:$PATH"/d' $ZSHRC_FILE
echo 'export PATH="$HOME/.balet/bin:$PATH"' >> $ZSHRC_FILE

# Goodbye message.
echo "${GREEN}Balet is successfully installed! \xE2\x9C\x94\n${NC}"
echo "${YELLOW}1. Reload your .zshrc file:${NC}"
echo "${YELLOW}source ~/.zshrc\n${NC}"
echo "${YELLOW}2. Update your nginx.conf file to include Balet servers directory within http block:${NC}"
echo "${YELLOW}include $HOME/.balet/servers/*;${NC}"
