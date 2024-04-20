#!/usr/bin/env bash

if [ -f "./process_module.sh" ]; then
    source ./process_module.sh
else
    echo "process_module.sh isn't found";
    exit 1;
fi

# Description:
#   This is a search wrapper function
function INTERFACE_searchWrapper() {
    options=("Search by command name" "Search by user"
    "filter by minimum cpu amount" "filter by minimum memory amount" "Back")
while true; do
    echo "Search and Filter menu:"
    select _ in "${options[@]}"; do
        case $REPLY in
            1) echo "Please enter a command name:"
                    read -r command_name
                        process_searchName "$command_name";;
            2) 
                echo "Please enter a user name:"
                    read -r user_name
                        process_searchUser "$user_name";;
            3) 
                echo "Please enter a cpu percentage:"
                    read -r cpu_percentage
                        process_searchCpu "$cpu_percentage";;
            
            4)  
                echo "Please enter a memory percentage:"
                    read -r memory_percentage
                        process_searchMemory "$memory_percentage";;
            5) INTERFACE_main_menu;;
            *) echo "Invalid option";;
        esac
        break;
    done
done
}

function INTERFACE_main_menu() {
# Display the menu
menuTitle="Select an option (1-7): "
options=("Real-time Monitoring All Processes" "Process Information"
         "Kill A Process" "Process Statistics" "Search and Filter"
         "Resource User Alert" "Quit")


while true; do
    echo "$menuTitle"
    select _ in "${options[@]}"; do
        case $REPLY in
            1) 
                while true; do
                    process_list
                    echo "The data will be updated after $UPDATE_INTERVAL seconds"
                    sleep "$UPDATE_INTERVAL"
                    clear
                done
                ;;
            2) 
                echo "Please enter a PID:"
                    read -r pid
                    if [[ $pid =~ ^[0-9]+$ ]]; then
                        process_info "$pid"
                    else
                        echo "Invalid PID. Please enter a numeric PID."
                    fi
            ;;
            
            3) 
                echo "Please enter a PID:"
                    read -r pid
                    if [[ $pid =~ ^[0-9]+$ ]]; then
                        process_kill "$pid"
                    else
                        echo "Invalid PID. Please enter a numeric PID."
                    fi
            ;;
            
            4) process_statistics;;
            5) INTERFACE_searchWrapper;;
            6) 
                echo "Processes that consume high cpu:"
                    process_alertCpu "$CPU_ALERT_THRESHOLD"
                    printf "\n"
                echo "Processes that consume high memory:"
                    process_alertCpu "$MEMORY_ALERT_THRESHOLD"
                    printf "\n"
                ;;
            7) echo "Goodbye!"; exit 0;;
        esac
        break;
    done
done
}