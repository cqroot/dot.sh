#!/bin/bash

FG_RED='\033[31m'
FG_GREEN='\033[32m'
FG_YELLOW='\033[33m'
FG_NC='\033[0m'

#######################################
# Check if the file is linked correctly.
# Arguments:
#   Linked file
#   The file linked to
# Returns:
#   0 if true, non-zero on error.
#######################################
check_link() {
    if [[ $(readlink "$2") -ef $1 ]]; then
        echo 0
    else
        echo 1
    fi

}

#######################################
# Link config to target.
# Arguments:
#   config to link
#   the target linked to
#   exec to check
#######################################
link_config() {
    file="${PWD}/$1"
    echo -ne "${FG_GREEN}$1${FG_NC}: $file ${FG_GREEN}->${FG_NC} $2 : "

    if [[ $3 != "" ]]; then
        if ! command -v "$3" >/dev/null; then
            echo -e "${FG_YELLOW} Ignored${FG_NC}"
            return
        fi
    fi

    if [[ "$(check_link "$file" "$2")" -eq 0 ]]; then
        echo -e "${FG_YELLOW} Linked${FG_NC}"
        return
    fi

    if ln -s "$file" "$2"; then
        echo -e "${FG_GREEN} OK${FG_NC}"
    else
        echo -e "${FG_RED} ERROR${FG_NC}"
    fi
}

#######################################
# Main.
#######################################
main() {
    current_mode=none

    while read -r line; do
        pureline=$(echo "$line" | xargs)
        if [[ $pureline == "" ]]; then
            continue
        elif [[ $pureline == "[xdg]" ]]; then
            current_mode=xdg
            continue
        elif [[ $pureline == "[home]" ]]; then
            current_mode=home
            continue
        fi

        file=$(echo "$pureline" | awk -F 'exec:' '{print $1}' | xargs)
        exec=$(echo "$pureline" | awk -F 'exec:' '{print $2}' | xargs)

        link=""
        if [[ $current_mode == "xdg" ]]; then
            link=${HOME}/.config/$(basename "${file}")
        elif [[ $current_mode == "home" ]]; then
            link_file=$(basename "${file}")
            link="${HOME}/.${link_file}"
        fi
        link_config "$file" "$link" "$exec"
    done <"${PWD}/dot.conf"
}

main "$@"
