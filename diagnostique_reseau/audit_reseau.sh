#!/bin/bash

echo "=== Audit Réseau Automatisé ==="
echo "Date: $(date)"
echo ""

echo "--- 1. Services exposés (Ports en écoute) ---"
# -t: TCP, -u: UDP, -l: listening, -n: numeric ports, -p: process name
ss -tulnp | head -n 20
echo "..."
echo ""

echo "--- 2. Connexions suspectes (établies) ---"
# Identifier les connexions établies vers des ports non standards (hors 80, 443, 22)
# Ceci est une heuristique simple.
ss -tun state established | grep -vE ":80 |:443 |:22 " | head -n 20
if [ $? -ne 0 ]; then
    echo "Aucune connexion atypique détectée (hors web/ssh standard)."
fi
echo ""

echo "--- 3. Configuration Réseau ---"
echo "Interfaces :"
ip -br addr
echo ""
echo "Table de routage :"
ip route
echo ""
echo "Serveurs DNS :"
cat /etc/resolv.conf | grep nameserver

echo ""
echo "=== Fin de l'audit ==="
