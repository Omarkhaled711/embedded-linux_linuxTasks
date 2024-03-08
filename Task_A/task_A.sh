#!/usr/bin/env bash



# Description:
#   A function that takes a directory path, ensures that it exists
#   and removes any trailing '/' from the directory path (formating it for next functions)
#   then cd to the directory, and returns the directory path after formating
# Usage:
#   Formatted_DIR_PATH=$(driectoryHandler $Given_PATH)
# Example:
#   DIR_PATH=$(driectoryHandler "$1")

function driectoryHandler() {
    declare DIR_PATH=$1
    if [ ! -d "$DIR_PATH" ]; then
        echo "directory $DIR_PATH does not exist"
        exit 1
    fi

    # remove trailing '/' if exists
    # I want the directory path to be in the form of (path/directory)
    # and not (path/directory/)
    if [[ $DIR_PATH == */ ]]; then
    DIR_PATH="${DIR_PATH%/}"
    fi
    cd "$DIR_PATH" || exit
    echo "$DIR_PATH"
}

# Description:
#   create an extension subdirectory that gathers all files of the same extennsion
# Usage:
#   gatherExtension <Directory_Path> <extension(sub-directory) name>
# Example:
#   gatherExtension "$DIR_PATH" "txt"

function gatherExtension() {
    declare DIR_PATH=$1
    declare extension=$2

    shopt -s dotglob # to enable bash processing hidden files in the next for loop
    for file in "$DIR_PATH"/*."$extension"; do
        if [ -f "$file" ]; then
            if [ ! -d "$DIR_PATH/$extension" ]; then
                mkdir "$DIR_PATH/$extension"
            fi
            mv "$file" "$DIR_PATH/$extension"
        fi
    done
    shopt -u dotglob # returning to the default behaviour of not processing hidden files as we are done
}

# Descrition:
#    The rest of the files that don't fall under the specified extensions will be
#    placed inside a misc directory
# Usage:
#   gatherMisc <Directory_path>
# Example:
#   gatherMisc "$DIR_PATH"

function gatherMisc() {
    declare DIR_PATH=$1
    shopt -s dotglob # to enable bash processing hidden files in the next for loop
    for file in "$DIR_PATH"/*; do
        if [ -f "$file" ]; then
            if [ ! -d "$DIR_PATH/misc" ]; then
                mkdir "$DIR_PATH/misc"
            fi
            mv "$file" "$DIR_PATH/misc"
        fi
    done
    shopt -u dotglob # returning to the default behaviour of not processing hidden files as we are done
}
function main() {
    declare DIR_PATH
    DIR_PATH=$(driectoryHandler "$1")
    declare arrayExtensions=("txt" "pdf" "jpg"); # add extesnions you want here

    for item in "${arrayExtensions[@]}"; do
        gatherExtension "$DIR_PATH" "${item}"
    done
    
    gatherMisc "$DIR_PATH"
    tree -a "$(basename -- "$DIR_PATH")" #Show the contents of the directory as a tree
}

main "$1"
