#!/bin/zsh

# Get the directory where this script is located
SCRIPT_DIR="${${(%):-%x}:A:h}"

source "$SCRIPT_DIR/homebrew.sh"
source "$SCRIPT_DIR/macos.sh"
source "$SCRIPT_DIR/dev.sh"
source "$SCRIPT_DIR/zsh.sh"
