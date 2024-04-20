#!/bin/bash

if [ -f "./interface.sh" ]; then
    source "./interface.sh";
else
    echo "./interface.sh isn't found";
    exit 1;
fi

INTERFACE_main_menu;