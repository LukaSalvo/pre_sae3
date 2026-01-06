#!/bin/bash

# Port à bloquer (HTTP)
PORT=80

if [ "$1" == "start" ]; then
    echo "Simulation : Blocage du port $PORT (service web inaccessible)..."
    # Bloquer le trafic entrant sur le port 80
    iptables -A INPUT -p tcp --dport $PORT -j DROP
    echo "Port $PORT bloqué. Testez avec : curl localhost:$PORT ou nc -zv localhost $PORT"
elif [ "$1" == "stop" ]; then
    echo "Arrêt de la simulation..."
    # Supprimer la règle de blocage
    iptables -D INPUT -p tcp --dport $PORT -j DROP
    echo "Port $PORT débloqué."
else
    echo "Usage: ./scenario_service_bloque.sh [start|stop]"
fi
