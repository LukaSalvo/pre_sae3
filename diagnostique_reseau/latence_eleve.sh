#!/bin/bash

INTERFACE="eth0" # À adapter selon l'interface de la VM (souvent eth0 ou ens33)

if [ "$1" == "start" ]; then
    echo "Ajout de 500ms de latence sur $INTERFACE..."
    tc qdisc add dev $INTERFACE root netem delay 500ms
    echo "Latence active. Testez avec : ping 8.8.8.8"
elif [ "$1" == "stop" ]; then
    echo "Suppression de la latence..."
    tc qdisc del dev $INTERFACE root
else
    echo "Usage: ./latence_eleve.sh [start|stop]"
fi#!/bin/bash

INTERFACE="eth0" # À adapter selon l'interface de la VM (souvent eth0 ou ens33)

if [ "$1" == "start" ]; then
    echo "Ajout de 500ms de latence sur $INTERFACE..."
    tc qdisc add dev $INTERFACE root netem delay 500ms
    echo "Latence active. Testez avec : ping 8.8.8.8"
elif [ "$1" == "stop" ]; then
    echo "Suppression de la latence..."
    tc qdisc del dev $INTERFACE root
else
    echo "Usage: ./latence_eleve.sh [start|stop]"
fi