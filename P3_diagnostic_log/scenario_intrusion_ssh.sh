#!/usr/bin/env bash
set -euo pipefail

TARGET_USER="${1:-$USER}"
TARGET_HOST="${2:-127.0.0.1}"
PORT="${3:-22}"

echo "Simulation de tentatives SSH échouées sur ${TARGET_USER}@${TARGET_HOST}:${PORT}"
echo "Objectif: générer des logs 'Failed password' dans /var/log/auth.log et journalctl"

# 10 tentatives échouées (mauvais mot de passe)
for i in $(seq 1 10); do
  ssh -o PreferredAuthentications=password \
      -o PubkeyAuthentication=no \
      -o StrictHostKeyChecking=no \
      -o UserKnownHostsFile=/dev/null \
      -p "$PORT" \
      "${TARGET_USER}@${TARGET_HOST}" "exit" >/dev/null 2>&1 || true
  echo "  - tentative $i envoyée"
done

echo "Terminé. Consulte:"
echo "    sudo grep 'Failed password' /var/log/auth.log | tail -n 20"
echo "    sudo journalctl -u ssh --since '10 min ago' | tail -n 50"

