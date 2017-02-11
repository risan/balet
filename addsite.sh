#!/bin/bash

# Colors.
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Command arguments.
WEBSITE_TYPE="$1"       # Website type: html, html-ssl, php, php-ssl.
WEBSITE_NAME="$2"       # The website domain.
RELATIVE_ROOT_DIR="$3"  # The relative path to the root directory.

CURRENT_DIR="$PWD"
BALET_DIR="`dirname $0`"
TEMPLATES_DIR="$BALET_DIR/templates"
SERVERS_DIR="$BALET_DIR/servers"
HOSTS_FILE="/etc/hosts"

# Make sure that the website type is set.
if [ -z $WEBSITE_TYPE ]; then
  echo "${RED}The website-type argument is required!${NC}"
  echo "${YELLOW}sh addsite.sh website-type website-name [website-root-dir]${NC}"
  exit 1
fi

WEBSITE_TEMPLATE_FILE="$TEMPLATES_DIR/$WEBSITE_TYPE.dev"

# Make sure that the template for the website type is exists.
if [ ! -f $WEBSITE_TEMPLATE_FILE ]; then
  echo "${RED}The website configuration template for type $WEBSITE_TYPE is not exists: $WEBSITE_TEMPLATE_FILE${NC}"
  exit 1
fi

# Make sure that the website name is set.
if [ -z $WEBSITE_NAME ]; then
  echo "${RED}The website-name argument is required!${NC}"
  echo "${YELLOW}sh addsite.sh website-type website-name [website-root-dir]${NC}"
  exit 1
fi

WEBSITE_CONFIG_FILE="$SERVERS_DIR/$WEBSITE_NAME"

# Check if the webiste configuration file is already exist.
if [ -f $WEBSITE_CONFIG_FILE ]; then
  echo "${RED}The configuration file for $WEBSITE_NAME is already exists: $WEBSITE_CONFIG_FILE${NC}"
  exit 1
fi

# Get root directory.
if [ -z $RELATIVE_ROOT_DIR ]; then
  if [ -d "$CURRENT_DIR/public" ]; then
    ROOT_DIR="$CURRENT_DIR/public"
  elif [ -d "$CURRENT_DIR/html" ]; then
    ROOT_DIR="$CURRENT_DIR/html"
  else
    ROOT_DIR="$CURRENT_DIR"
  fi
else
  ROOT_DIR="$CURRENT_DIR/$RELATIVE_ROOT_DIR"
fi

# Copy and configure the website template configuration file.
cp "$WEBSITE_TEMPLATE_FILE" "$WEBSITE_CONFIG_FILE"                # Copy the configuration file.
sed -i '' "s~ROOT_DIR~$ROOT_DIR~g" $WEBSITE_CONFIG_FILE           # Replace the root directory.
sed -i '' "s/WEBSITE_NAME/$WEBSITE_NAME/g" $WEBSITE_CONFIG_FILE   # Replace the website name.

echo $ROOT_DIR
exit 1
