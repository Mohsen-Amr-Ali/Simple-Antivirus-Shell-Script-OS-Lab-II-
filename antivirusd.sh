#!/bin/bash
#
# This is a simple antivirus daemon made for Operating Systems Lab II
#
# parameters:
#   dir — the source directory being monitored (files only, no subdirectories)
#   malicious_dir — the destination directory where flagged/quarantined files are copied
#   interval_secs — time to wait between every check
#####====================================================================#####

##===================== SETUP =====================##
if [ $# -ne 3 ]
then
    echo
    echo "$0 needs 3 parameters."
    echo "(dir - malicious_dir - interval_secs)"

    exit 3
fi

dir="$1"
malicious_dir="$2"
interval_secs="$3"

##===================== Fn DEFS =====================##

function quarantine () {
    echo "${1##*/} is malicious and it is DELETED"
    cp "$1" "$malicious_dir"/ && rm -f "$1"
}

function scan_extension () {
    local extension=${1##*.} #parameter expansion

    case "$extension" in #because normal string operator in if doesn't support |
        exe | bat | vbs | scr | ps1)
        # I'm just now realising I didn't need to look into parameter expansions and could've just
        # used *.exe .....
            return 0
        ;;
    esac

    return 1
}

function scan_content () {
    grep -Eiq 'virus|trojan|malware|worm|ransomware' "$1"
    # E -> allow for regex
    # i -> ignore case
    # q -> just a y/n (exit status actually)
}

function scan () {
    for file in "$dir"/*
    do
        if [ -f "$file" ] && { scan_extension "$file" || scan_content "$file" ;}
        # {...;} is for grouping without creating a subshell
        then
            quarantine "$file"
        fi
    done
}

##===================== MAIN =====================##

while true
do
    if [ ! -e directory-info.last ]
    then
        scan 
        ls -l "$dir" > directory-info.last
    else
        ls -l "$dir" > directory-info.new

        if ! cmp -s directory-info.last directory-info.new
        then
            scan
            cp directory-info.new directory-info.last
        fi
    fi

    sleep "$interval_secs"
done
