#!/bin/bash

FG_RED='\033[31m'
FG_GREEN='\033[32m'
FG_YELLOW='\033[33m'
FG_NC='\033[0m'

SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)

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
    echo -ne "${FG_GREEN}$3${FG_NC}: $1 ${FG_GREEN}->${FG_NC} $2 : "

    if ! command -v "$3" > /dev/null; then
        echo -e "${FG_YELLOW} Ignored${FG_NC}"
        return
    fi

    if [[ "$(check_link "$1" "$2")" -eq 0 ]]; then
        echo -e "${FG_YELLOW} Linked${FG_NC}"
        return
    fi

    if ln -s "$1" "$2"; then
        echo -e "${FG_GREEN} OK${FG_NC}"
    else
        echo -e "${FG_RED} ERROR${FG_NC}"
    fi
}

#######################################
# Main.
#######################################
main() {
    while read -r line; do
        file=$(echo "$line" | awk -F '|' '{print $1}' | xargs)
        exec=$(echo "$line" | awk -F '|' '{print $2}' | xargs)
        link=${HOME}/.config/${file}
        link_config "${SCRIPT_DIR}/$file" "$link" "$exec"
    done <"${SCRIPT_DIR}/list-xdg_config"

    while read -r line; do
        file=$(echo "$line" | awk -F '|' '{print $1}' | xargs)
        exec=$(echo "$line" | awk -F '|' '{print $2}' | xargs)

        link_file=$(basename "${file}")
        link="${HOME}/.${link_file}"

        link_config "${SCRIPT_DIR}/$file" "$link" "$exec"
    done <"${SCRIPT_DIR}/list-home"
}

main "$@"
