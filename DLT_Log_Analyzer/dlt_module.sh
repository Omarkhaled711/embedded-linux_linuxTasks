#!/bin/bash

if [ -f "./utils.sh" ]; then
    source "utils.sh"
else
    echo "utils.sh isn't found"
    exit 1
fi


# Description:
#    This function takes the system log files defined inside the LOG_FILES array
#    It filters them based on severity levels (ERROR, WARNING, INFO, DEBUG) based
#    on the keywards defined for each of them in the crossponding arrays
#    Then it writes it to the ouput log file defined inside the OUTPUT_FILE
DLT_write_log_file() {
    for log_file in "${LOG_FILES[@]}"; do
        while IFS= read -r log_message; do
            # Determine the severity level
            severity_level=$(get_severity_level "$log_message" "INFO" "${INFO_KEYWORDS[@]}")
            if [ "$severity_level" == "UNKNOWN" ]; then
                severity_level=$(get_severity_level "$log_message" "WARNING" "${WARNING_KEYWORDS[@]}")
            fi
            if [ "$severity_level" == "UNKNOWN" ]; then
                severity_level=$(get_severity_level "$log_message" "ERROR" "${ERROR_KEYWORDS[@]}")
            fi
            if [ "$severity_level" == "UNKNOWN" ]; then
                severity_level="DEBUG";
            fi   
            # Append the log message to the output file with the detected severity level
            echo "[$(date +"%Y-%m-%d %H:%M:%S")] $severity_level $log_message" >> "$OUTPUT_FILE"
            
        done < "$log_file"
    done
}

# Description:
#   This function deletes the output log file if present
DLT_delete_log_file() {
    if [ -f "$OUTPUT_FILE" ]; then
        rm -rf "$OUTPUT_FILE";
    fi
}

# Description:
#   This function displays the output log file on scree if present.
DLT_read_log_file() {
    if [ ! -f "$OUTPUT_FILE" ]; then
        printf "'%s' log file doesn't exist \n" "$OUTPUT_FILE";
        return
    fi
    while IFS= read -r line; do
        printf "%s\n" "${line}";
    done < "$OUTPUT_FILE"

}
# Description:
#   This function filters the log messages by log level
DLT_filter_level() {
    if [ ! -f "$OUTPUT_FILE" ]; then
        printf "'%s' log file doesn't exist \n" "$OUTPUT_FILE";
        return
    fi   
    local severity_level="$1";
    while IFS= read -r line; do
        if [[ "${line}" == *"${severity_level}"* ]]; then
            printf "%s\n" "${line}";
        fi
        
    done < "$OUTPUT_FILE"
    
}
# Description:
#   This function returns the total number of logs in the log file
DLT_count_all() {
    if [ ! -f "$OUTPUT_FILE" ]; then
        printf "'%s' log file doesn't exist \n" "$OUTPUT_FILE";
        return
    fi 
    local line_count;
    line_count="$(wc -l < "$OUTPUT_FILE")";
    echo "$line_count";
}

# Description:
#   This function returns the number of logs of a specified type (level)
DLT_count_log_level() {
    if [ ! -f "$OUTPUT_FILE" ]; then
        printf "'%s' log file doesn't exist \n" "$OUTPUT_FILE";
        return
    fi 
    local severity_level="$1"
    local -i count=0
    while IFS= read -r line; do
        if [[ "${line}" == *"${severity_level}"* ]]; then
            ((count++));
        fi
    done < "$OUTPUT_FILE"
    echo "$count";
}
# Description:
#   This function prints the error log summary (the number of error log messages and its percentage)
DLT_error_summary() {
    if [ ! -f "$OUTPUT_FILE" ]; then
        printf "'%s' log file doesn't exist \n" "$OUTPUT_FILE";
        return
    fi 
    local all_count;
    local error_count;
    local percentage;

    all_count=$(DLT_count_all);
    error_count=$(DLT_count_log_level "ERROR");
    percentage=$(get_percentage "${error_count}" "${all_count}");

    printf "Error Count: %d\nAll Logs Count: %d\nError precentage: %.2f%%\n" "$error_count" "$all_count" "$percentage"
}
# Description:
#   This function prints the warning log summary (the number of warning log messages and its percentage)
DLT_warning_summary() {
    if [ ! -f "$OUTPUT_FILE" ]; then
        printf "'%s' log file doesn't exist \n" "$OUTPUT_FILE";
        return
    fi 
    local all_count;
    local warning_count;
    local percentage;

    all_count=$(DLT_count_all);
    warning_count=$(DLT_count_log_level "WARNING");
    percentage=$(get_percentage "${warning_count}" "${all_count}");

    printf "Warning Count: %d\nAll Logs Count: %d\nWarning precentage: %.2f%%\n" "$warning_count" "$all_count" "$percentage"
}
# Description:
#   This function searches for some specific messages, logs, data, ..etc in logs
#   and returns the matching results
DLT_event_tracking() {
    if [ ! -f "$OUTPUT_FILE" ]; then
        printf "'%s' log file doesn't exist \n" "$OUTPUT_FILE";
        return
    fi 
    local -i flag;
    for event in "${EVENTS[@]}"; do
        flag=1;
        while IFS= read -r line; do
            if [[ "${line}" == *"${event}"* ]]; then
                printf "%s\n" "${line}";
                flag=0;
            fi
        done < "$OUTPUT_FILE"
        if (( flag == 1 )); then
            printf "The event: '%s' was not found\n" "$event"
        fi
    done   
}
# Description:
#   This function generates a report after analyizing the log messages
DLT_generate_report() {
    if [ ! -f "$OUTPUT_FILE" ]; then
        printf "'%s' log file doesn't exist \n" "$OUTPUT_FILE";
        return
    fi 
    local all_count;
    local level_string=();
    local level_count=();
    local percentage;

    # print a centered message
    center_text "REPORT"

    level_string=("ERROR" "WARNING" "INFO" "DEBUG");
    all_count=$(DLT_count_all);
    level_count+=("$(DLT_count_log_level 'ERROR')");
    level_count+=("$(DLT_count_log_level 'WARNING')");
    level_count+=("$(DLT_count_log_level 'INFO')");
    # Debug Level calculation in a faster way than calling the above function
    level_count+=( $(( all_count - level_count[0] - level_count[1] - level_count[2] ))) 

    printf "All Logs Count: %d\n" "${all_count}";
    for ((i = 0; i < ${#level_count[@]}; i++)); do
        percentage=$(get_percentage "${level_count[i]}" "${all_count}");
        printf "%s Count:%d %10s Percentage:%.2f%% \n" "${level_string[i]}" "${level_count[i]}" "${level_string[i]}" "${percentage}"
    done

    printf "\nChecking Important Events\n";
    DLT_event_tracking;
}