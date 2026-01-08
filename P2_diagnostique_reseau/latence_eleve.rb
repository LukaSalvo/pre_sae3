#!/usr/bin/env ruby

# Auto-detect default interface
default_interface = `ip route show default | awk '/default/ {print $5}'`.strip
INTERFACE = default_interface.empty? ? "eth0" : default_interface


def start_latency
  puts "Ajout de 500ms de latence sur #{INTERFACE}..."
  system("tc qdisc add dev #{INTERFACE} root netem delay 500ms")
  puts "Latence active. Testez avec : ping 8.8.8.8"
end

def stop_latency
  puts "Suppression de la latence..."
  system("tc qdisc del dev #{INTERFACE} root")
end

case ARGV[0]
when "start"
  start_latency
when "stop"
  stop_latency
else
  puts "Usage: #{$0} [start|stop]"
end
