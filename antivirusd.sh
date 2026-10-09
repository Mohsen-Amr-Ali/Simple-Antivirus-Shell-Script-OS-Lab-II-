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
fi

dir="$1"
malicious_dir="$2"
interval_secs="$3"

ls -l "$dir" > directory-info.last
> directory-info.new

##===================== ------ =====================##

function quarantine () {
    echo "'$1' is malicious and it is DELETED"
    cp "$1" "$malicious_dir" && rm -f "$1"
}

function scan_extension () {
    local extension=${1##*.} #parameter expansion
    if [ "$extension" = ".exe\|.bat\|.vbs\|.scr\|.ps1" ]
    then
        return 1
    fi
    return 0
}

function scan_content () {
    return grep -Eliq 'virus|trojan|malware|worm|ransomware' "$1"
}

function scan () {
    for file in "$dir"/*
    do
        if scan_extension "$file" || ! scan_content "$file" 
        then
            quarantine "$file"
        fi
    done
}

