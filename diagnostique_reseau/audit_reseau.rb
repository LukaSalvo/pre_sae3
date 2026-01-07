#!/usr/bin/env ruby
require 'socket'

puts "=== Audit Réseau Automatisé (Ruby) ==="
puts "Date: #{Time.now}"
puts ""

puts "--- 1. Services exposés (Ports en écoute) ---"
# Using system call and reading output
puts `ss -tulnp | head -n 20`
puts "..."
puts ""

puts "--- 2. Connexions suspectes (établies) ---"
connections = `ss -tun state established`
suspicious = connections.lines.select do |line|
  !line.match(/:80 |:443 |:22 /) && !line.start_with?("Netid")
end

if suspicious.empty?
  puts "Aucune connexion atypique détectée (hors web/ssh standard)."
else
  puts suspicious.take(20)
end
puts ""

puts "--- 3. Configuration Réseau ---"
puts "Interfaces :"
puts `ip -br addr`
puts ""
puts "Table de routage :"
puts `ip route`
puts ""
puts "Serveurs DNS :"
if File.exist?('/etc/resolv.conf')
  puts File.readlines('/etc/resolv.conf').grep(/nameserver/)
end


puts ""
puts "=== Fin de l'audit ==="
