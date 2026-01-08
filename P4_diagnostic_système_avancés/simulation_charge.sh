#!/bin/bash
set -u

# Configuration
DURATION=60  # Durée en secondes
TEMP_DIR="/tmp/stress_test_$(date +%s)"
mkdir -p "$TEMP_DIR"

cleanup() {
    echo -e "\nNettoyage..."
    rm -rf "$TEMP_DIR"
    pkill -P $$ 
}
trap cleanup EXIT INT TERM

echo "Simulation de charge système (${DURATION}s)"
echo "Démarrage des workers..."

# 1. Simulation CPU (Calculs mathématiques en boucle)
# Lance X processus qui font du sha256sum sur /dev/zero
CPUS=$(nproc)
echo "Lancement de $CPUS workers CPU (sha256sum)..."
for i in $(seq 1 "$CPUS"); do
    (sha256sum /dev/zero > /dev/null 2>&1) &
done

# 2. Simulation I/O Disque (Écritures aléatoires)
echo "Lancement worker I/O (dd write)..."
(
    while true; do
        dd if=/dev/urandom of="$TEMP_DIR/io_test_$$.bin" bs=1M count=100 conv=fsync >/dev/null 2>&1
    done
) &

# 3. Simulation Mémoire (Allocation via python si dispo, sinon ignoré)
if command -v python3 &> /dev/null; then
    echo "Allocation RAM (500MB via Python)..."
    (python3 -c "a = 'a' * 500 * 1024 * 1024; import time; time.sleep($DURATION)" >/dev/null 2>&1) &
fi

echo "--- Charge en cours ---"
echo "Vous pouvez maintenant lancer le tableau de bord dans un autre terminal :"
echo "   sudo ./tableau_de_bord.sh"
echo "-----------------------"

for i in $(seq 1 "$DURATION"); do
    printf "\rTemps restant : %02d s" "$((DURATION - i))"
    sleep 1
done

echo -e "\nFin de la simulation."
