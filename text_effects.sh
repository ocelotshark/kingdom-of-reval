#!/usr/bin/env bash

RESET="\e[0m"

# Core effects
BOLD="\e[1m"
DIM="\e[2m"
ITALIC="\e[3m"
UNDERLINE="\e[4m"
BLINK="\e[5m"
REVERSE="\e[7m"
HIDDEN="\e[8m"
STRIKE="\e[9m"

# Foreground colors
BLACK="\e[30m"
RED="\e[31m"
GREEN="\e[32m"
YELLOW="\e[33m"
BLUE="\e[34m"
MAGENTA="\e[35m"
CYAN="\e[36m"
WHITE="\e[37m"

# Bright foreground colors
BRIGHT_BLACK="\e[90m"
BRIGHT_RED="\e[91m"
BRIGHT_GREEN="\e[92m"
BRIGHT_YELLOW="\e[93m"
BRIGHT_BLUE="\e[94m"
BRIGHT_MAGENTA="\e[95m"
BRIGHT_CYAN="\e[96m"
BRIGHT_WHITE="\e[97m"

# Background colors
BG_BLACK="\e[40m"
BG_RED="\e[41m"
BG_GREEN="\e[42m"
BG_YELLOW="\e[43m"
BG_BLUE="\e[44m"
BG_MAGENTA="\e[45m"
BG_CYAN="\e[46m"
BG_WHITE="\e[47m"

# Bright background colors
BG_BRIGHT_BLACK="\e[100m"
BG_BRIGHT_RED="\e[101m"
BG_BRIGHT_GREEN="\e[102m"
BG_BRIGHT_YELLOW="\e[103m"
BG_BRIGHT_BLUE="\e[104m"
BG_BRIGHT_MAGENTA="\e[105m"
BG_BRIGHT_CYAN="\e[106m"
BG_BRIGHT_WHITE="\e[107m"

# Pre-made combos
TITLE="${BOLD}${BRIGHT_CYAN}"
ERROR="${BOLD}${RED}"
SUCCESS="${BOLD}${GREEN}"
WARNING="${BOLD}${YELLOW}"
INFO="${CYAN}"

HP_BAR="${BOLD}${RED}"
MANA_BAR="${BOLD}${BLUE}"
GOLD="${BOLD}${YELLOW}"

NPC="${BOLD}${MAGENTA}"
ENEMY="${BOLD}${BRIGHT_RED}"
LOOT="${BOLD}${BRIGHT_YELLOW}"