#!/bin/bash

if [ -f "./config.conf" ]; then
    source "config.conf"
fi

# Define default arrays for each severity level if not already defined
declare -a ERROR_KEYWORDS=("${ERROR_KEYWORDS[@]:-"error" "failed" "unable" "fatal" "fail" "unsuccessful" "unsuccessfully"}")
declare -a WARNING_KEYWORDS=("${WARNING_KEYWORDS[@]:-"warning" "caution" "problem"}")
declare -a INFO_KEYWORDS=("${INFO_KEYWORDS[@]:-"info" "successful" "completed" "successfully"}")


# Specify the log file path
LOG_FILES=("${LOG_FILES[@]:-"/var/log/syslog"}")

# Specify the output file path
OUTPUT_FILE="${OUTPUT_FILE:-"./file.log"}"

# Specify the default events to look for
EVENTS=("${EVENTS[@]:-"System Startup Sequence Initiated" "System health check OK"}")

# Description:
#   Function to determine the severity level based on keywords
get_severity_level() {
    local message="$1"
    local check_level="$2"
    shift
    shift
    local keywords=("$@")
    local severity_level="UNKNOWN"
    
    for keyword in "${keywords[@]}"; do
        if echo "$message" | grep -qi "$keyword"; then
            severity_level="$check_level";
        fi
    done
    
    echo "$severity_level"
}

# Description:
#   This function returns the percentage given 2 arguments
get_percentage() {
    local partial="$1";
    local total="$2";
    local percentage;

    percentage=$(bc <<< "scale=4; ($partial / $total) * 100");
    echo "${percentage}";
}

# Description:
#   This function centers a text on the screen 
center_text() {
    local text="$1"
    # shellcheck disable=SC2155
    local terminal_width=$(tput cols)
    local text_length=${#text}
    local left_padding=$(( (terminal_width - text_length) / 2 ))

    printf "%*s%s\n" $left_padding "" "$text"
}
