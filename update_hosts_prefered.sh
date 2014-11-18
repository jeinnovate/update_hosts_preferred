#!/bin/bash
#
# I use a "host's resolver as a DNS proxy in NAT mode" as per (http://www.virtualbox.org/manual/ch09.html#nat_host_resolver_proxy).
# What this means is when I change IPs I don't want to change anything in the hosts file on my arsenal of Internet Explorer VMs which are pointed to my host.
# These functions update the hosts file of the host machine to allow this "magic."
#
# Author: Jonathan A. Epstein

# Update the IP (key) in your hosts file containing the "PLACEHOLDER_HOST_NAME".
# @Params: $1 the IP to set
set_hosts_variable_ip() {
    local PLACEHOLDER_HOST_NAME='variable.ip'
    sudo sed -i ".bak" "s/^\(.*\) ${PLACEHOLDER_HOST_NAME}/${1}/" /etc/hosts
}

# Enable you to grab the "prefered" (the interface with an IP which resolves first) interface
# so you can use your top network interface (i.e. ethernet tends to work better than wifi).
# This only works on MAC OS X for now.
# TODO: Add debian based Linux support
get_prefered_interface_ip() {
    local NETWORK_SEARCH_STRING='Wi-Fi|Thunderbolt Ethernet'
    local networks=$(networksetup -listnetworkserviceorder)
    local interfaces_info=$(echo "${networks}" | awk "/${NETWORK_SEARCH_STRING}/{getline; print;}")
    local possible_interfaces=()

    while read -r interface_info; do
        possible_interfaces+=($(echo ${interface_info} | sed "s/.*Device: \(en[[:digit:]]\)).*/\1/"))
    done <<< "${interfaces_info}"

    for possible_interface in "${possible_interfaces[@]}"; do
        if possible_config=$(ifconfig ${possible_interface} 2> /dev/null); then
            echo "${possible_config}" | grep 'inet ' | awk '{print $2}'
        fi
    done
}

# Updates the hosts file with the prefered interface ip
update_hosts_prefered() {
    set_hosts_variable_ip $(get_prefered_interface_ip)
}

update_hosts_prefered
