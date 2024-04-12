#!/usr/bin/env bash


# Description:
#   This functino takes a pid as an argument, and calculates the cpu usage of
#   The associated process by retrieving data from (/proc) directory

function get_process_cpu_usage() {
    
    # Defining Variables
    local PID
    local PROCESS_UTIME
    local PROCESS_STIME
    local PROCESS_STARTTIME
    local SYSTEM_UPTIME_SEC
    local CLK_TCK

    local PROCESS_UTIME_SEC
    local PROCESS_STIME_SEC
    local PROCESS_STARTTIME_SEC

    local PROCESS_ELAPSED_SEC
    local PROCESS_USAGE_SEC
    local PROCESS_USAGE

    # Implementing the function
    PID=$1

    PROCESS_UTIME=$(awk '{print $14}' "/proc/$PID/stat")
    PROCESS_STIME=$(awk '{print $15}' "/proc/$PID/stat")
    PROCESS_STARTTIME=$(awk '{print $22}' "/proc/$PID/stat")
    SYSTEM_UPTIME_SEC=$(awk '{print int($1)}' /proc/uptime)
    CLK_TCK=$(getconf CLK_TCK)

    PROCESS_UTIME_SEC=$(echo "$PROCESS_UTIME / $CLK_TCK" | bc)
    PROCESS_STIME_SEC=$(echo "$PROCESS_STIME / $CLK_TCK" | bc)
    PROCESS_STARTTIME_SEC=$(echo "$PROCESS_STARTTIME / $CLK_TCK" | bc)

    PROCESS_ELAPSED_SEC=$(echo "$SYSTEM_UPTIME_SEC - $PROCESS_STARTTIME_SEC" | bc)
    PROCESS_USAGE_SEC=$(echo "$PROCESS_UTIME_SEC + $PROCESS_STIME_SEC" | bc)
    PROCESS_USAGE=$(echo "scale=2; $PROCESS_USAGE_SEC * 100 / $PROCESS_ELAPSED_SEC" | bc)

   printf "%.2f\n" "$PROCESS_USAGE"  
}

# Description:
#   This function takes a pid as an argument and returns 
#   the memory percentage used by it by retreiving data
#   from /proc/$pid/status directory
function get_process_memory_percentage() {
    # Defining Vars
    local pid
    local process_StatusFile
    local process_Vmrss
    local system_TotalMemory
    local process_MemoryPercentage

    # implemeing the function logic
    pid="$1"
    process_StatusFile="/proc/$pid/status"

    process_Vmrss=$(grep VmRSS "$process_StatusFile" | awk '{print $2}')
    system_TotalMemory=$(grep MemTotal /proc/meminfo | awk '{print $2}')

    if [[ -n "${process_Vmrss}" ]] && [[ -n "${system_TotalMemory}" ]]; then
        process_MemoryPercentage=$(echo "scale=2; $process_Vmrss * 100 / $system_TotalMemory" | bc)
        printf "%.2f\n" "$process_MemoryPercentage"
    else
        echo "0"
    fi
}

# Description:
#   This function takes pid as an argument and returns the ppid
#   by retrieving info from /proc/$pid directory

function get_ppid() {
    # Defining Vars
    local pid
    local ppid


    # Impleming The function logic
    pid="$1"
    if [ ! -d "/proc/$pid" ]; then
        echo "Error: There is no process with this $pid pid"
        exit 1
    fi
    ppid=$(awk '{print $4}' "/proc/$pid/stat")
    echo "$ppid"
}

# Description:
#   This function takes a pid as an argument, and returns
#   the user controlling this process

function get_user_for_pid() {
    # Defining Vars
    local pid
    local user

    # Implementing the function logic
    pid=$1
    if [ ! -d "/proc/$pid" ]; then
        echo "Error: There is no process with this $pid pid"
        exit 1
    fi
    # Read the UID from the /proc/<pid>/status file
    user=$(awk '/Uid/ {print $2}' "/proc/$pid/status")
    # Convert UID to username
    user=$(getent passwd "$user" | awk -F: '{print $1}')
    echo "$user"
}

# Description:
#   This function takes a pid as an argument, and returns
#   the command responsiple for this process

function get_command_for_pid() {

    # Defining Vars
    local pid
    local process_command

    # Implementing function logic
    pid="$1"
    if [ ! -f "/proc/$pid/comm" ]; then
        echo "Error: There is no process with this $pid pid"
        exit 1
    fi
    process_command="$(cat /proc/"$pid"/comm)"
    echo "$process_command"
}