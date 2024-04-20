#!/bin/bash
if [ -f "./dlt_module.sh" ]; then
    source "dlt_module.sh"
else
    echo "dlt_module.sh isn't found"
    exit 1
fi

# Description:
#   This function represents the main menu interface for the program
INTERFACE_main_menu() {
    local options=("Create New (overwrite existing) log file"
                  "Update Log File (without overwriting)"
                  "Display logs"
                  "Filter logs by severity level"
                  "Error Logs Summary"
                  "Warning Logs Summary"
                  "Generate Report"
                  "Delete Log File"
                  "Exit")

    while true; do
        echo "Menu Options:"
        select _ in "${options[@]}"; do
            case $REPLY in
                1)
                    echo "Creating Log file at ${OUTPUT_FILE}..."
                    DLT_delete_log_file
                    DLT_write_log_file;;
                2)
                    echo "Updating Log file at ${OUTPUT_FILE}..."
                    DLT_write_log_file;;
                3) DLT_read_log_file;;
                4) INTERFACE_filter_menu;;
                5) DLT_error_summary;;
                6) DLT_warning_summary;;
                7) DLT_generate_report;;
                8) 
                    echo "Deleting Log file at ${OUTPUT_FILE}..."
                    DLT_delete_log_file;;
                9) echo "Exiting..."; exit 0;;
                *) echo "Invalid option";;
            esac
            break
        done
    done
}

# Description:
#   This function represents the filter menu interface for the program
INTERFACE_filter_menu() {
    local options=("ERROR" "WARNING" "INFO" "DEBUG" "Back")

    while true; do
        echo "Filter Menu:"
        select _ in "${options[@]}"; do
            case $REPLY in
                1) DLT_filter_level "ERROR";;
                2) DLT_filter_level "WARNING";;
                3) DLT_filter_level "INFO";;
                4) DLT_filter_level "DEBUG";;
                5)
                    clear;
                    INTERFACE_main_menu;;
                *) echo "Invalid option";;
            esac
            break
        done
    done
}