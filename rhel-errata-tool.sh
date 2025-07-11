#!/bin/bash -e
# File:        rhel-errata-tool.sh
# Author:      Christo Deale 
# Date:        2025-07-11
# Version:     1.0.0
# Description: Utility to Inspect & Mitigate Red Hat Errata Advisories (RHSA, RHBA, CVE)

LOGFILE="/var/log/errata_script.log"
GREEN=$(tput setaf 2)
RED=$(tput setaf 1)
RESET=$(tput sgr0)

# Check if running as root
if [ "$EUID" -ne 0 ]; then
    echo "${RED}Hierdie script moet as root uitgevoer word.${RESET}"
    exit 1
fi

# Check for package manager
if command -v dnf >/dev/null 2>&1; then
    PKG_MANAGER="dnf"
elif command -v yum >/dev/null 2>&1; then
    PKG_MANAGER="yum"
else
    echo "${RED}Geen ondersteunde pakketbestuurder (yum/dnf) gevind nie.${RESET}"
    exit 1
fi

# Help option
if [ "$1" = "--help" ] || [ "$1" = "-h" ]; then
    echo "Gebruik: $0"
    echo "Hierdie script help om Red Hat errata (RHSA, RHBA, CVE) te inspekteer en toe te pas."
    exit 0
fi

function process_advisory () {
    local advisory_type=$1
    local grep_pattern=$2
    local update_flag=$3

    clear
    echo "${GREEN}:: Inspecting $advisory_type Advisories ::${RESET}"
    $PKG_MANAGER updateinfo list | grep "$grep_pattern"
    echo "Enter $advisory_type-NUM to Inspect Advisory"
    read -r NUM
    if ! $PKG_MANAGER updateinfo info $update_flag$NUM >/dev/null 2>&1; then
        echo "${RED}Ongeldige $advisory_type-$NUM. Probeer weer.${RESET}"
        process_advisory "$advisory_type" "$grep_pattern" "$update_flag"
    fi
    $PKG_MANAGER updateinfo info $update_flag$NUM
    echo "${GREEN}>>> Mitigate $advisory_type >>>${RESET}
         1. YES
         2. NO"
    select option in "YES" "NO"; do
        if [ "$option" = "YES" ]; then
            echo "$(date): Running $advisory_type-$NUM update" >> "$LOGFILE"
            $PKG_MANAGER update $update_flag$NUM >> "$LOGFILE" 2>&1
        else
            menuprincipal
        fi
    done
}

function menuprincipal () {
    clear
    echo "${GREEN} :: RHEL Errata Inspect & Mitigate :: ${RESET}"
    echo "Choose an option to get started
        1 - (RHSA) RedHat Security Advisory
        2 - (RHBA) RedHat Bug Advisory 
        3 - (CVE) RedHat Security CVE"
    read -r option
    case $option in
        1) process_advisory "RHSA" "RHSA-*" "--advisory=RHSA-" ;;
        2) process_advisory "RHBA" "RHBA-*" "--advisory=RHBA-" ;;
        3) process_advisory "CVE" "CVE-*" "--cve CVE-" ;;
        *) echo "${RED}Ongeldige keuse. Kies 1, 2, of 3.${RESET}"; menuprincipal ;;
    esac
}

menuprincipal
