#!/usr/bin/env ruby

PORT = 80

def start_block
  puts "Simulation : Blocage du port #{PORT} (service web inaccessible)..."
  # IPv4
  system("iptables -I INPUT 1 -p tcp --dport #{PORT} -j DROP")
  # IPv6
  system("ip6tables -I INPUT 1 -p tcp --dport #{PORT} -j DROP")
  
  puts "Port #{PORT} bloqué (IPv4/IPv6). Testez avec : curl localhost:#{PORT} ou nc -zv localhost #{PORT}"
end

def stop_block
  puts "Arrêt de la simulation..."
  # IPv4
  system("iptables -D INPUT -p tcp --dport #{PORT} -j DROP")
  # IPv6
  system("ip6tables -D INPUT -p tcp --dport #{PORT} -j DROP")
  
  puts "Port #{PORT} débloqué."
end


case ARGV[0]
when "start"
  start_block
when "stop"
  stop_block
else
  puts "Usage: #{$0} [start|stop]"
end
