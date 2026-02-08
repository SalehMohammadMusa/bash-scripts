#!/bin/bash
#load all the hosts in the file host.txt
combined_list=()
ip_list=()
mapfile -t host_list < host.txt
#check if you can login or not 
for host in "${host_list[@]}"; do 
    ip=$(dig +short "$host" | tail -n1)
    
    if [ -z "$ip" ]; then
        ip="/NA"
    fi
    combined_list+=("$host|$ip")
done
#for logged in system:
#list down their ip address hostname and domain if given domain name find their ip  address
#check their timezone
#check their server configuration and list down it also 
#find their os details ad version of os they are using