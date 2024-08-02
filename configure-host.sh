#!/bin/bash

verbose=false

while [[ "$#" -gt 0 ]]; do
    case $1 in
        -verbose) verbose=true ;;
        -name) hostname="$2"; shift ;;
        -ip) ip_address="$2"; shift ;;
        -hostentry) hostentry_name="$2"; hostentry_ip="$3"; shift; shift ;;
        *) echo "Unknown parameter: $1"; exit 1 ;;
    esac
    shift
done

log_message() {
    local message="$1"
    if $verbose; then
        echo "$message"
    fi
    logger "$message"
}

if [[ -n "$hostname" ]]; then
    current_hostname=$(hostname)
    if [[ "$current_hostname" != "$hostname" ]]; then
        echo "$hostname" > /etc/hostname
        sed -i "s/$current_hostname/$hostname/g" /etc/hosts
        hostnamectl set-hostname "$hostname"
        log_message "Hostname updated from $current_hostname to $hostname"
    else
        log_message "Hostname already set to $hostname"
    fi
fi

if [[ -n "$ip_address" ]]; then
    current_ip=$(hostname -I | awk '{print $1}')
    if [[ "$current_ip" != "$ip_address" ]]; then
        sed -i "s/$current_ip/$ip_address/g" /etc/hosts
        sed -i "s/dhcp4: true/dhcp4: false/g" /etc/netplan/50-cloud-init.yaml
        echo "    addresses: [$ip_address/24]" >> /etc/netplan/50-cloud-init.yaml
        netplan apply
        log_message "IP address updated from $current_ip to $ip_address"
    else
        log_message "IP address already set to $ip_address"
    fi
fi

if [[ -n "$hostentry_name" && -n "$hostentry_ip" ]]; then
    if ! grep -q "$hostentry_ip $hostentry_name" /etc/hosts; then
        echo "$hostentry_ip $hostentry_name" >> /etc/hosts
        log_message "Host entry added: $hostentry_name with IP $hostentry_ip"
    else
        log_message "Host entry for $hostentry_name with IP $hostentry_ip already exists"
    fi
fi
