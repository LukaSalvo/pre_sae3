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

## 2. Pare-Feu Bloquant (`scenario_parefeu.rb`)

**Symptôme :** Impossible d'accéder à un service (ex: port 80), le navigateur charge indéfiniment ou `curl` timeout.

**Méthodologie :**
1.  **Tester le port :**
    ```bash
    curl -v http://localhost
    # ou
    nc -zv localhost 80
    ```
    *Interprétation :* 
    - "Connection timed out" : **Pare-feu** (le paquet est jeté/DROP).
    - "Connection refused" : **Service éteint** (le serveur envoie un RST).
2.  **Scanner avec Nmap :**
    ```bash
    nmap -p 80 localhost
    ```
    *Interprétation :* État `filtered` confirme le pare-feu. État `closed` indique que le service est éteint.
3.  **Vérifier le pare-feu (IPv4 et IPv6) :**
    ```bash
    sudo iptables -L INPUT -n --line-numbers
    sudo ip6tables -L INPUT -n --line-numbers
    ```
    *Interprétation :* Chercher des règles `DROP` ou `REJECT` sur le port concerné.

## 3. Problème DNS (`scenario_dns_casse.rb`)

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

Voici les outils à maîtriser pour le projet :

- **ss / netstat** : Lister les ports.
  - `ss -tulnp` : Ports TCP/UDP en écoute et processus associés.
- **ip** : Configuration réseau.
  - `ip a` : Adresses IP.
  - `ip r` : Routes.
- **tcpdump** : Capture de paquets.
  - `sudo tcpdump -i any port 80` : Voir le trafic HTTP.
  - `sudo tcpdump -i eth0 icmp` : Voir les pings.
- **nmap** : Scan de ports.
  - `nmap -sV localhost` : Lister services et versions.
- **mtr / traceroute** : Diagnostic chemin.
  - `mtr 8.8.8.8` : Ping continu sur chaque saut.
- **dig / host** : DNS.
  - `dig A google.com` : Demander l'enregistrement A (IPv4).
