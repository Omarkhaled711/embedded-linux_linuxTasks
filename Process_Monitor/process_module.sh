#!/usr/bin/env bash

# Sourcing utils file
if [ -f "./utils.sh" ]; then
    source ./utils.sh
fi


# Description:
#   This function lists all the processes on the system

function process_list(){
    # Defining Vars
    local process_command
    local process_cpuPercentage
    local process_MemoryPercentage
    local process_User

    #Implementing the function logic
    printf "%-7s | %-20s | %-5s | %-5s | %s\n" "PID" "USER" "%CPU" "%Mem" "Command"
    echo "-------------------------------------------------------"

    for pid in /proc/[0-9]*; do
        if [ -d "$pid" ]; then
            pid=$(basename "$pid")
            process_command=$(get_command_for_pid "$pid")
            process_cpuPercentage=$(get_process_cpu_usage "$pid")
            process_MemoryPercentage=$(get_process_memory_percentage "$pid")
            process_User=$(get_user_for_pid "$pid")
            printf "%-7s | %-20s | %-5s | %-5s | %s\n" "$pid" "$process_User" "$process_cpuPercentage" "$process_MemoryPercentage" "$process_command"
        fi
    done       
}

# Description:
#   This function takes a pid as an argument and 
#   Provide detailed information about it including
#   its PID, PPID, user, CPU and memory usage, etc.
function process_info() {
    # Defining Vars
    local pid
    local ppid
    local cpuPercentage
    local memPercentage
    local user
    local command

    # Implementing the function logic
    pid="$1"
    if [ ! -d "/proc/$pid" ]; then
        echo "Error: There is no process with this $pid pid"
        exit 1
    fi
    ppid=$(get_ppid "$pid")
    cpuPercentage=$(get_process_cpu_usage "$pid")
    memPercentage=$(get_process_memory_percentage "$pid")
    user=$(get_user_for_pid "$pid")
    command=$(get_command_for_pid "$pid")

    printf "%-7s | %-7s | %-20s | %-5s | %-5s | %s\n" "PID" "PPID" "USER" "%CPU" "%Mem" "Command"
    echo "-------------------------------------------------------"
     printf "%-7s | %-7s |%-20s | %-5s | %-5s | %s\n" "$pid" "$ppid" "$user" "$cpuPercentage" "$memPercentage" "$command"
}
# Description:
#   This function takes a pid as an input and
#   kills the process associated with this pid

function process_kill() {
    # Defining Vars
    local pid

    #Implementing the function logic
    pid=$1
    echo "Info has been logged to ./logs/log.txt"

    if [ ! -d "./logs" ]; then
        mkdir ./logs
    fi
    echo "Trying to kill process with pid: $pid" >> ./logs/log.txt

    if [ ! -d "/proc/$pid" ]; then
        printf "Error: There is no process with this %s pid \n\n" "$pid">> ./logs/log.txt
        return
    fi
    printf "Info about the process: \n" >> ./logs/log.txt
    process_info "$pid" >> ./logs/log.txt
    
    if kill "$pid"; then
        printf "\nThe process has been killed Successfully \n\n " >> ./logs/log.txt
    else
        print "\nFailed to kill the process\n\n" >> ./logs/log.txt
    fi
}

# Description:
#   This function prints process statistics (such as the total
#   number of processes, memory usage, and CPU load.)

function process_statistics() {
    # Defining Vars
    local processNumber
    local process_singleCpu
    local process_singleMem
    local process_totalCpuLoad
    local process_totalMemLoad

    # Implementing the function logic
    processNumber=0
    process_totalCpuLoad=0
    process_totalMemLoad=0

    echo "Please wait for a few seconds, The results are being calculated ^^"
    for pid in /proc/[0-9]*; do
        if [ -d "$pid" ]; then
            processNumber=$(( processNumber+1 ))
            pid=$(basename "$pid")
            process_singleCpu=$(get_process_cpu_usage "$pid")
            process_singleMem=$(get_process_memory_percentage "$pid")
            
            process_totalCpuLoad=$(echo "$process_totalCpuLoad + $process_singleCpu" | bc)
            process_totalMemLoad=$(echo "$process_totalMemLoad + $process_singleMem" | bc)
        fi
    done
    printf "Total Process Number: %s\n Total Cpu Load: %s\n Total Memory Load: %s\n" "$processNumber" "$process_totalCpuLoad" "$process_totalMemLoad"
}

# Description:
#   This function search about processes with the given command name
function process_searchName() {
    #Defining Vars
    local givenName
    local processCommand

    # Implementing the function
        givenName=$1
        for pid in /proc/[0-9]*; do
        if [ -d "$pid" ]; then
            pid=$(basename "$pid")
            processCommand=$(get_command_for_pid "$pid")
            if echo "$processCommand" | grep "$givenName" > /dev/null; then
                process_info "$pid"
                printf "\n"
            fi
   
        fi
    done  
}

# Description:
#   This function search about processes associated with a certain user
function process_searchUser() {
    #Defining Vars
    local givenUser
    local processUser

    # Implementing the function
        givenUser=$1
        for pid in /proc/[0-9]*; do
        if [ -d "$pid" ]; then
            pid=$(basename "$pid")
            processUser=$(get_user_for_pid "$pid")
            if echo "$processUser" | grep "$givenUser" > /dev/null; then
                process_info "$pid"
                printf "\n"
            fi   
        fi
    done  
}

# Description:
#   This function search about processes >= certain memory percentage
function process_searchMemory() {
    #Defining Vars
    local givenPercentage
    local processPercentage

    # Implementing the function
        givenPercentage=$1
        for pid in /proc/[0-9]*; do
        if [ -d "$pid" ]; then
            pid=$(basename "$pid")
            processPercentage=$(get_process_memory_percentage "$pid")
            if (( $(echo "${processPercentage} >= ${givenPercentage}" | bc -l) )); then
                process_info "$pid"
                printf "\n"
            fi   
        fi
    done  
}

# Description:
#   This function search about processes >= certain cpu percentage
function process_searchCpu() {
    #Defining Vars
    local givenPercentage
    local processPercentage

    # Implementing the function
        givenPercentage=$1
        for pid in /proc/[0-9]*; do
        if [ -d "$pid" ]; then
            pid=$(basename "$pid")
            processPercentage=$(get_process_cpu_usage "$pid")
            if (( $(echo "${processPercentage} >= ${givenPercentage}" | bc -l) )); then
                process_info "$pid"
                printf "\n"
            fi   
        fi
    done  
}

# Description:
#   This function detects dangerous processes on the cpu
#   It takes a cpu% as an argument, and returns all process >= this value

function process_alertCpu() {
    # Defining Vars
    local processRisky

    # Implementing the function
    processRisky="$1"
    process_searchCpu "$processRisky"    
}

# Description:
#   This function detects dangerous processes on the memory
#   It takes a mem% as an argument, and returns all process >= this value

function process_alertMemory() {
    # Defining Vars
    local processRisky

    # Implementing the function
    processRisky="$1"
    process_searchMemory "$processRisky"    
}
