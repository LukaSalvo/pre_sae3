#!/bin/bash

if [ "$EUID" -ne 0 ]; then
  echo "ERREUR: Ce script doit être lancé avec sudo pour accéder aux logs système."
  echo "Usage: sudo $0"
  exit 1
fi

echo "Tentatives de connexion échouées (SSH)"
# Utilise journalctl car /var/log/auth.log n'existe pas toujours sur les distros modernes
LOGS=$(journalctl -u ssh -q | grep "Failed password" | tail -n 20)
if [ -z "$LOGS" ]; then
    echo "Aucune tentative trouvée. (Avez-vous lancé scenario_intrusion_ssh.sh ?)"
else
    echo "$LOGS"
fi

echo
echo "Connexions SSH réussies"
journalctl -u ssh -q | grep "Accepted" | tail -n 20

echo
echo "Erreurs critiques systemd"
journalctl -p err -n 20

echo
echo "Activité suspecte récente"
journalctl --since "1 hour ago" | grep -i "error" | tail -n 20

