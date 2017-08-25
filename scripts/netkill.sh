#!/bin/bash
# kills all network interfaces
# USAGE: netkill to kill; netkill -r to revive

while getopts ":r" opt; do
  case $opt in
    "r")
      mode="revive"
      ;;
    "?")
      echo "Invalid option: -$OPTARG" >&2
      exit 1
      ;;
  esac
done

ifconfig -a | grep '[<,]UP[,>]' | grep -v '[<,]LOOPBACK[,>]' > /tmp/upifs
echo "Current state: "
cat /tmp/upifs
echo

if [[ $mode == "revive" ]]
then
  echo "Reviving network"
  devices=$(cat /tmp/netifs | grep -o '.*:' | cut -f1 -d:)
  for dev in $devices
  do
    echo "Reviving $dev"
    sudo ifconfig $dev up
  done
  # remove so that netkill can be run again
  rm /tmp/netifs
else
  #if /tmp/netifs exists, network has already been killed
  [[ -f /tmp/netifs ]] && echo "/tmp/netifs already exists - exiting" && exit
  ifconfig -a | grep '[<,]UP[,>]' | grep -v '[<,]LOOPBACK[,>]' > /tmp/netifs
  echo "Killing network"
  devices=$(cat /tmp/netifs | grep -o '.*:' | cut -f1 -d:)
  for dev in $devices
  do
    echo "Killing $dev"
    sudo ifconfig $dev down
  done
fi

ifconfig -a | grep '[<,]UP[,>]' | grep -v '[<,]LOOPBACK[,>]' > /tmp/upifs
echo
echo "Current state: "
cat /tmp/upifs
