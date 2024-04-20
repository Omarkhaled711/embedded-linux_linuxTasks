#!/usr/bin/env bash


# Set default values for configuration, so that if the config file
# was messed up, the script still works
declare UPDATE_INTERVAL_DEFAULT=5
declare CPU_ALERT_THRESHOLD_DEFAULT=90
declare MEMORY_ALERT_THRESHOLD_DEFAULT=80

# Source the process module file
if [ -f "./interface.sh" ]; then
    source ./interface.sh
else
    echo "interface.sh ins't found"
    exit 1;
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
    INTERFACE_main_menu;
}

main
