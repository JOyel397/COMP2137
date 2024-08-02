#!/bin/bash

verbose=false
if [[ "$1" == "-verbose" ]]; then
    verbose=true
fi

transfer_and_execute() {
    local server="$1"
    local options="$2"
    scp ~/COMP2137/configure-host.sh remoteadmin@"$server":/root
    if $verbose; then
        ssh remoteadmin@"$server" -- /root/configure-host.sh -verbose $options
    else
        ssh remoteadmin@"$server" -- /root/configure-host.sh $options
    fi
}

transfer_and_execute "server1-mgmt" "-name loghost -ip 192.168.16.3 -hostentry webhost 192.168.16.4"
transfer_and_execute "server2-mgmt" "-name webhost -ip 192.168.16.4 -hostentry loghost 192.168.16.3"

if $verbose; then
    ~/COMP2137/configure-host.sh -verbose -hostentry loghost 192.168.16.3
    ~/COMP2137/configure-host.sh -verbose -hostentry webhost 192.168.16.4
else
    ~/COMP2137/configure-host.sh -hostentry loghost 192.168.16.3
    ~/COMP2137/configure-host.sh -hostentry webhost 192.168.16.4
fi
