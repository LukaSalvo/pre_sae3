#!/bin/bash

echo "Tentatives de connexion échouées"
grep "Failed password" /var/log/auth.log | awk '{print $1, $2, $3, $11}'

echo
echo "Connexions SSH réussies"
grep "Accepted password" /var/log/auth.log | awk '{print $1, $2, $3, $9, $11}'

echo
echo "Erreurs critiques systemd"
journalctl -p err -n 20

echo
echo "Activité suspecte récente"
journalctl --since "1 hour ago" | grep -i "error"

