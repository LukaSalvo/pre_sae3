#!/usr/bin/env bash
set -euo pipefail

DIR="${1:-/tmp/diskfill_demo}"
SIZE_MB="${2:-200}"   # ajuste selon ta VM (ex: 2000 si tu veux vraiment remplir)

mkdir -p "$DIR"
echo "Remplissage de disque dans $DIR (~${SIZE_MB}MB)"
echo "Objectif: provoquer des erreurs d'écriture et observer les logs"

# Remplit progressivement un fichier
dd if=/dev/zero of="$DIR/fill.bin" bs=1M count="$SIZE_MB" status=progress || true

# Génère un log applicatif qui essaie d'écrire
echo "Tentative d'écriture dans un fichier log (peut échouer si disque plein)"
for i in $(seq 1 50); do
  echo "$(date -Is) test log line $i" >> "$DIR/app.log" || true
done

echo "Terminé. Consulte:"
echo "    df -h"
echo "    dmesg | tail -n 50"
echo "    sudo journalctl --since '10 min ago' | grep -i -E 'no space|disk|ext4|i/o' | tail -n 50"
echo
echo "Nettoyage (quand tu as fini l'analyse): rm -rf '$DIR'"

