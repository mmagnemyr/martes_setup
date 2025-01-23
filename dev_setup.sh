#!/bin/bash

# Define the alias name and dynamically set the target directory
ALIAS_NAME="gom"
TARGET_DIR="$HOME"
BASHRC_FILE="$HOME/.bashrc"

# Check if the alias already exists in .bashrc
if ! grep -q "alias $ALIAS_NAME=" "$BASHRC_FILE"; then
    # Add the alias to .bashrc
    echo "alias $ALIAS_NAME='cd $TARGET_DIR'" >> "$BASHRC_FILE"
    echo "Alias '$ALIAS_NAME' added to $BASHRC_FILE"
else
    echo "Alias '$ALIAS_NAME' already exists in $BASHRC_FILE"
fi

# Reload .bashrc to apply the alias immediately
source "$BASHRC_FILE"