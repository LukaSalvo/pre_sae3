# Guide de Diagnostic Réseau

Ce document présente la méthodologie de diagnostic pour différents problèmes réseau.

## 1. Latence Réseau (`latence_eleve.sh`)

**Symptôme :** Lenteur d'accès, ping élevé.

**Méthodologie :**
1.  **Vérifier la connectivité de base :**
    ```bash
    ping -c 4 8.8.8.8
    ```
    *Interprétation :* Regarder le temps `time=... ms`. Si > 100ms, latence anormale.
2.  **Tracer la route :**
    ```bash
    mtr -r -c 10 8.8.8.8
    ```
    *Interprétation :* Identifier le saut (hop) où la latence augmente brusquement.

## 2. Service Bloqué (`scenario_service_bloque.sh`)

**Symptôme :** Impossible d'accéder à un service web (port 80).

**Méthodologie :**
1.  **Tester le port :**
    ```bash
    curl -v http://localhost
    # ou
    nc -zv localhost 80
    ```
    *Interprétation :* "Connection refused" = service éteint. "Connection timed out" = pare-feu.
2.  **Vérifier le pare-feu :**
    ```bash
    sudo iptables -L INPUT -n --line-numbers
    ```
    *Interprétation :* Chercher des règles `DROP` ou `REJECT` sur le port concerné.

## 3. Problème DNS (`scenario_dns_casse.sh`)

**Symptôme :** Impossible de joindre des sites par leur nom (ex: google.com), mais ping IP fonctionne.

**Méthodologie :**
1.  **Tester la résolution :**
    ```bash
    dig google.com
    # ou
    nslookup google.com
    ```
    *Interprétation :* Si "SERVFAIL" ou timeout, problème DNS.
2.  **Vérifier la configuration :**
    ```bash
    cat /etc/resolv.conf
    ```
    *Interprétation :* Vérifier les IP des `nameserver`.

## Outils Référence

- `ss -tulnp` : Lister les ports en écoute.
- `ip a` : Voir les adresses IP.
- `ip r` : Voir les routes.
- `tcpdump -i any port 80` : Sniffer le trafic HTTP.
