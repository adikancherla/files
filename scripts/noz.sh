#!/bin/bash
#***************************************************************************
#*** noz - prevent laptop from sleeping when lid is closed
#***************************************************************************

#***** set some defaults *****
BATTERY_SLEEP=10 # in minutes
DEF_WAKE_LEN=10 # in minutes

#***** determine timeout value *****
timeout_len_min=${1:-$DEF_WAKE_LEN}
timeout_len=$(( timeout_len_min * 60 )) # in seconds

function prevent_sleep() {
    echo
    echo "Preventing sleep for $timeout_len_min minutes"

    sudo pmset -b disablesleep 1
    sudo pmset -b sleep 0
}

function enable_sleep() {
    # $1: <enter> = 0, timeout = 1, Ctrl-C = undef

    #----- insert a newline for timeout or Ctrl-C -----
    if [[ ${1:-1} -eq 1 ]]; then    echo; fi
    echo "Restoring previous battery sleep setting: $BATTERY_SLEEP minutes"

    sudo pmset -b disablesleep 0
    sudo pmset -b sleep $BATTERY_SLEEP

    #----- sleep on timeout only -----
    if [[ ${1:--1} -eq 1 ]]; then   sudo pmset sleepnow; fi
    exit
}

#***** prevent it from sleeping *****
prevent_sleep

#***** trap Ctrl-C *****
trap enable_sleep INT

#***** wait for an enter *****
read -t $timeout_len
rc=$?

#***** re-enable normal sleep *****
enable_sleep $rc
