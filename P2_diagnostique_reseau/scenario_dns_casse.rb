#!/usr/bin/env ruby
require 'fileutils'

RESOLV_CONF = "/etc/resolv.conf"
BACKUP_FILE = "/etc/resolv.conf.bak"

def start_dns_break
  puts "Simulation : Panne résolution DNS..."
  if !File.exist?(BACKUP_FILE)
    FileUtils.cp(RESOLV_CONF, BACKUP_FILE)
  end
  File.write(RESOLV_CONF, "nameserver 0.0.0.0\n")
  puts "DNS cassé. Testez avec : dig google.com"
end

def stop_dns_break
  puts "Arrêt de la simulation..."
  if File.exist?(BACKUP_FILE)
    FileUtils.cp(BACKUP_FILE, RESOLV_CONF)
    File.delete(BACKUP_FILE)
    puts "DNS restauré."
  else
    puts "Erreur : Pas de backup trouvé. Vérifiez manuellement #{RESOLV_CONF}"
  end
end

case ARGV[0]
when "start"
  start_dns_break
when "stop"
  stop_dns_break
else
  puts "Usage: #{$0} [start|stop]"
end
