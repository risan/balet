#!/bin/bash

# Colors.
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

BALET_DIR="$HOME/.balet"
ZSHRC_FILE="$HOME/.zshrc"

# Make sure that the Git is installed.
git --version 2>&1 > /dev/null || {
  print "${RED}Git is not installed on your computer.\n${NC}"
  exit 1
}

# Make sure that the Nginx is installed.
nginx -v 2>&1 > /dev/null || {
  print "${RED}Nginx is not installed on your computer.\n${NC}"
  exit 1
}

# Make sure that the Balet is not installed.
if [ -d "$BALET_DIR" ]; then
  print "${RED}You already have Balet installed: $BALET_DIR${NC}"
  exit 1
fi

# Welcome message.
print "${CYAN}Installing Balet...\n${NC}"

# Clone the Balet repository.
print "${CYAN}Cloning Balet into: $BALET_DIR\n${NC}"
git clone --depth=1 https://github.com/risan/balet.git $BALET_DIR

# Add balet to system path permanently within the .zshrc.
print "${CYAN}Adding Balet to system path...\n${NC}"
sed -i '' '/export PATH="$HOME\/.balet\/bin:$PATH"/d' $ZSHRC_FILE
print 'export PATH="$HOME/.balet/bin:$PATH"' >> $ZSHRC_FILE

# Goodbye message.
print "${GREEN}Balet is successfully installed! \xE2\x9C\x94\n\n${NC}"
print "${YELLOW}1. Reload your .zshrc file:\n${NC}"
print "${YELLOW}source ~/.zshrc\n\n${NC}"
print "${YELLOW}2. Update your nginx.conf file to include Balet servers directory within http block:\n${NC}"
print "${YELLOW}include $HOME/.balet/servers/*;\n${NC}"
