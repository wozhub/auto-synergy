#!/bin/bash 

script_dir=$(dirname $(realpath $0))
source $script_dir/synergy-tools

#me fijo si no esta abierto el synergy (gui) ya
if [ "$(pidof synergy)" != "" ] || [ "$(pidof synergyc)" != "" ]; then
    echo "Ya esta corriendo el Synergy"
    ps aux | grep '[s]ynergy'
    exit 1
fi

if findCurrentNetwork; then
  echo "Conozco la red: $network_name"
  if testSynergy $server_ip; then
    echo "El ip conocido esta activo: $server_ip"
    /usr/bin/synergyc --daemon --debug INFO --log /tmp/synergy $server_ip
    exit $?
  else
    echo "No pude conectarme a la IP que esperaba ($server_ip)"
    
    echo "Intentando encontrarla mediante nmap/arp..."
    ip=$(findIPfromMAC $network $server_mac)
    
    echo "Encontre: $ip"
    if updateConfig $ip; then
      /usr/bin/synergyc --daemon --debug INFO --log /tmp/synergy $ip
      exit $?
    fi
  fi
fi
