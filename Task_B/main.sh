#!/usr/bin/env bash


# Set default values for configuration, so that if the config file
# was messed up, the script still works
declare UPDATE_INTERVAL_DEFAULT=5
declare CPU_ALERT_THRESHOLD_DEFAULT=90
declare MEMORY_ALERT_THRESHOLD_DEFAULT=80

# Source the process module file
if [ -f "./process_module.sh" ]; then
    source ./process_module.sh
fi

# Source the conf file
if [ -f "./process_monitor.conf" ]; then
    source process_monitor.conf
fi

# Use the variables with default values if not defined in the config file
UPDATE_INTERVAL=${UPDATE_INTERVAL:-$UPDATE_INTERVAL_DEFAULT}
CPU_ALERT_THRESHOLD=${CPU_ALERT_THRESHOLD:-$CPU_ALERT_THRESHOLD_DEFAULT}
MEMORY_ALERT_THRESHOLD=${MEMORY_ALERT_THRESHOLD:-$MEMORY_ALERT_THRESHOLD_DEFAULT}


function main() {
# Display the menu
menuTitle="Select an option (1-7): "
options=("Real-time Monitoring All Processes" "Process Information"
         "Kill A Process" "Process Statistics" "Search and Filter"
         "Resource User Alert" "Quit")


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
        5) process_searchWrapper;;
        6) 
            echo "Processes that consume high cpu:"
                process_alertCpu "$CPU_ALERT_THRESHOLD"
                printf "\n"
            echo "Processes that consume high memory:"
                process_alertCpu "$MEMORY_ALERT_THRESHOLD"
                printf "\n"
            ;;
        7) echo "Goodbye!"; break;;
    esac
done
}

main
