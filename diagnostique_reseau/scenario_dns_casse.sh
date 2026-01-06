#!/bin/bash

RESOLV_CONF="/etc/resolv.conf"
BACKUP_FILE="/etc/resolv.conf.bak"

if [ "$1" == "start" ]; then
    echo "Simulation : Panne résolution DNS..."
    # Sauvegarder la config actuelle
    if [ ! -f "$BACKUP_FILE" ]; then
        cp "$RESOLV_CONF" "$BACKUP_FILE"
    fi
    # Remplacer par un DNS invalide
    echo "nameserver 0.0.0.0" > "$RESOLV_CONF"
    echo "DNS cassé. Testez avec : dig google.com"
elif [ "$1" == "stop" ]; then
    echo "Arrêt de la simulation..."
    # Restaurer la config
    if [ -f "$BACKUP_FILE" ]; then
        cp "$BACKUP_FILE" "$RESOLV_CONF"
        rm "$BACKUP_FILE"
        echo "DNS restauré."
    else
        echo "Erreur : Pas de backup trouvé. Vérifiez manuellement $RESOLV_CONF"
    fi
else
    echo "Usage: ./scenario_dns_casse.sh [start|stop]"
fi
