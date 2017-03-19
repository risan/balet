#!/bin/bash

# Colors.
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

# Command arguments.
WEBSITE_NAME="$1"

BALET_DIR="`dirname $0`"
LOGS_DIR="$BALET_DIR/logs"
SERVERS_DIR="$BALET_DIR/servers"
SSL_DIR="$BALET_DIR/ssl"
HOSTS_FILE="/etc/hosts"
SYSTEM_KEYCHAIN_PATH="/Library/Keychains/System.keychain"

# Make sure that the website name is set.
if [ -z $WEBSITE_NAME ]; then
  printf "${RED}The domain argument is required!\n\n${NC}"
  printf "${YELLOW}balet remove domain\n${NC}"
  exit 1
fi

WEBSITE_CONFIG_FILE="$SERVERS_DIR/$WEBSITE_NAME"
WEBSITE_ERROR_LOG_FILE="$LOGS_DIR/$WEBSITE_NAME-error.log"
WEBSITE_SSL_DIR="$BALET_DIR/ssl/$WEBSITE_NAME"
WEBSITE_SSL_CERTIFICATE_FILE="$WEBSITE_SSL_DIR/certificate.crt"

# Check if the webiste configuration file is not exist.
if [ ! -f $WEBSITE_CONFIG_FILE ]; then
  printf "${RED}The configuration file for $WEBSITE_NAME is not exists: $WEBSITE_CONFIG_FILE\n${NC}"
  exit 1
fi

# Welcome message.
printf "${CYAN}Removing $WEBSITE_NAME website...\n${NC}"

# Delete the configuration file.
printf "${CYAN}Removing website configuration...\n${NC}"
rm "$WEBSITE_CONFIG_FILE"

# Delete the error log file.
printf "${CYAN}Removing website error log file...\n${NC}"
rm "$WEBSITE_ERROR_LOG_FILE"

# Remove from the trusted list.
printf "${CYAN}Try removing the SSL certificate from the trusted list...\n${NC}"
sudo security remove-trusted-cert -d "$WEBSITE_SSL_CERTIFICATE_FILE"

# Remove certificate from keychain.
printf "${CYAN}Try removing the SSL certificate from the keychain...\n${NC}"
sudo security delete-certificate -c "$WEBSITE_NAME" "$SYSTEM_KEYCHAIN_PATH"

# Remove certificate directory.
printf "${CYAN}Removing website SSL directory...\n${NC}"
rm -Rf "$WEBSITE_SSL_DIR"

# Reload nginx.
printf "${CYAN}Restarting the Nginx server...\n${NC}"
sudo nginx -s reload

# Goodbye message.
printf "${GREEN}The $WEBSITE_NAME website is removed \xE2\x9C\x94\n${NC}"
