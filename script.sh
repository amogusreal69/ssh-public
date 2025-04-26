#!/bin/bash

# amogus's SSH key manager
#
# This script is used as a way to help users as fast as possible by instead of sharing their server's password, they add my SSH key, and I have access to their server.
# Idea inspired by Virtfusion, GPT-4o helped with this lol
# This is the new version of the script, accessible via:
#   $ wget -qO- https://${DOWNLOAD_URL}/script.sh | bash
#
# We also have a legacy version of the script, which is no longer maintained, accessible via:
#   $ wget -qO- https://${DOWNLOAD_URL}/old.sh | bash
# 
# Have fun! Made with ❤️ by amogus

SSH_KEY=''
TMP_DOWNLOAD_LOCATION=$(mktemp -d)
DOWNLOAD_URL="https://ssh.amogus.works"
OPTION=$1

help() {
    echo -e "\033[92m● Usage:\e[0m"
    echo -e "  script.sh [add|remove|check|help]"
    echo ""
    echo -e "\033[92m● Options:\e[0m"
    echo -e "  \e[33m○ add\e[0m     - Installs the SSH key."
    echo -e "  \e[33m○ remove\e[0m  - Removes the SSH key."
    echo -e "  \e[33m○ check\e[0m   - Checks if the SSH key is installed."
    echo -e "  \e[33m○ help\e[0m    - Displays this help message."
    echo ""
    echo -e "\033[92m● GitHub Repository:\e[0m"
    echo -e "  \e[33m○ https://github.com/amogusreal69/ssh\e[0m"
    exit 0
}

add() {
    mkdir -p ~/.ssh
    chmod 700 ~/.ssh
    touch ~/.ssh/authorized_keys

    grep -F -e "amogusreal69420@proton.me" -e "amogus's support key, check next_steps.txt in root directory for more" ~/.ssh/authorized_keys >/dev/null 2>&1

    if [ $? -eq 0 ]; then
        echo -e "\033[93m● Support SSH key is already installed!\e[0m"
    else
        echo -e "\e[36m○ Downloading support SSH key...\e[0m"
        wget https://${DOWNLOAD_URL}/keys/ssh_key.pub -O "${TMP_DOWNLOAD_LOCATION}/__tmp___amogus___key" >/dev/null 2>&1

        echo -e "\e[36m○ Downloading support SSH key checksum...\e[0m"
        wget https://${DOWNLOAD_URL}/keys/checksum/ssh_key.checksum -O "${TMP_DOWNLOAD_LOCATION}/__tmp___amogus__key___check" >/dev/null 2>&1

        echo -e "\e[36m○ Verifying SSH key with SHA1...\e[0m"
        CHECKSUM=$(awk '{ print $1 }' "${TMP_DOWNLOAD_LOCATION}/__tmp___amogus__key___check")
        KEYSUM=$(sha1sum "${TMP_DOWNLOAD_LOCATION}/__tmp___amogus___key" | awk '{ print $1 }')

        if [ "${CHECKSUM}" == "${KEYSUM}" ]; then
            echo -e "\033[92m● SSH key verification successful!\e[0m"
            echo -e "\e[36m○ Installing SSH key...\e[0m"
            SSH_KEY=$(cat "${TMP_DOWNLOAD_LOCATION}/__tmp___amogus___key")
            echo "${SSH_KEY}" >> ~/.ssh/authorized_keys
            rm -f "${TMP_DOWNLOAD_LOCATION}/__tmp___amogus___key"
            rm -f "${TMP_DOWNLOAD_LOCATION}/__tmp___amogus__key___check"
            echo -e "\033[92m● Support SSH key installed successfully!\e[0m"
        else
            echo -e "\e[1;31m● Support SSH key verification failed! SSH Key didn't match checksum!\e[0m"
        fi
    fi

    echo -e "\e[36m○ Setting permissions...\e[0m"
    chmod 600 ~/.ssh/authorized_keys
}

remove_ssh_key() {
    grep -F -e "amogusreal69420@proton.me" -e "amogus's support key, check next_steps.txt in root directory for more" ~/.ssh/authorized_keys >/dev/null 2>&1

    if [ $? -ne 0 ]; then
        echo -e "\e[1;31m● Support SSH key not found!\e[0m"
    else
        sed -i '/amogusreal69420@proton.me/d' ~/.ssh/authorized_keys
        sed -i "/amogus's support key, check next_steps.txt in root directory for more/d" ~/.ssh/authorized_keys
        echo -e "\033[92m● Support SSH key removed successfully!\e[0m"
    fi
}

check_ssh_key() {
    grep -F -e "amogusreal69420@proton.me" -e "amogus's support key, check next_steps.txt in root directory for more" ~/.ssh/authorized_keys >/dev/null 2>&1

    if [ $? -eq 0 ]; then
        echo -e "\033[92m● Support SSH key IS installed.\e[0m"
        echo -e "\033[92m○ To remove my support SSH key, run the following command:\e[0m"
        echo -e "  \e[33mwget -qO- https://${DOWNLOAD_URL}/script.sh | bash -s -- remove\e[0m"
    else
        echo -e "\033[93m● Support SSH key is NOT installed.\e[0m"
        echo -e "\033[92m○ To add my support SSH key, run the following command:\e[0m"
        echo -e "  \e[33mwget -qO- https://${DOWNLOAD_URL}/script.sh | bash -s -- add\e[0m"
    fi
}

case "$OPTION" in
    add)
        add
        ;;
    remove)
        remove_ssh_key
        ;;
    check)
        check_ssh_key
        ;;
    --help|help|-h)
        help
        ;;
    *)
        echo -e "\e[1;31m● Invalid command or argument! Run the same script with the --help argument for the command list.\e[0m"
        ;;
esac
