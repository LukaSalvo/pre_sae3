#!/usr/bin/env bash
set -u

TARGET_USER="${1:-$USER}"
TARGET_HOST="${2:-127.0.0.1}"
PORT="${3:-22}"

echo "Simulation de tentatives SSH échouées sur ${TARGET_USER}@${TARGET_HOST}:${PORT}"
echo "Objectif: générer des logs 'Failed password' dans journalctl"

# Création du "faux" askpass
ASKPASS_SCRIPT=$(mktemp)
chmod +x "$ASKPASS_SCRIPT"
echo '#!/bin/bash' > "$ASKPASS_SCRIPT"
echo 'echo "mauvais_mdp_pour_fail_$(date +%s)"' >> "$ASKPASS_SCRIPT"

export SSH_ASKPASS="$ASKPASS_SCRIPT"
export DISPLAY=":0"
export SSH_ASKPASS_REQUIRE="force" # Interdit le prompt TTY, force l'usage de ASKPASS

# 10 tentatives rapides
for i in $(seq 1 10); do
  # setsid détache le processus du TTY
  setsid ssh -o PreferredAuthentications=password \
             -o PubkeyAuthentication=no \
             -o StrictHostKeyChecking=no \
             -o UserKnownHostsFile=/dev/null \
             -p "$PORT" \
             "${TARGET_USER}@${TARGET_HOST}" "exit" >/dev/null 2>&1 || true
             
  echo "  - Tentative $i envoyée (via SSH_ASKPASS)"
done

# Nettoyage
rm -f "$ASKPASS_SCRIPT"

echo "Terminé. Vérification des logs :"
echo "    sudo journalctl -u ssh -q | grep 'Failed password' | tail -n 20"
