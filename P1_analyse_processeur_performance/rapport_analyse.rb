#!/usr/bin/env ruby
# Script de rapport d'analyse de processus
# Génère un rapport détaillé incluant PID, état, CPU, mémoire, fichiers ouverts

require 'json'
require 'time'

class ProcessAnalyzer
  def initialize(pid = nil)
    @pid = pid
    @timestamp = Time.now
  end

  def analyze_all_processes
    processes = []
    # COMMENTAIRE: On cherche uniquement les dossiers numériques dans /proc.
    # Chaque dossier correspond à un PID actif sur le système Linux.
    Dir.glob('/proc/[0-9]*').each do |proc_dir|
      pid = File.basename(proc_dir).to_i
      begin
        process_info = analyze_process(pid)
        processes << process_info if process_info
      rescue => e
        # Ignore les erreurs si le processus disparaît pendant l'analyse
      end
    end
    processes
  end

  def analyze_process(pid)
    # COMMENTAIRE: Vérification critique. Le processus peut s'arrêter entre le 'glob' et l'analyse.
    return nil unless File.exist?("/proc/#{pid}")

    # Lecture unique du fichier status pour éviter d'ouvrir le fichier plusieurs fois
    # Cela améliore la performance et la cohérence des données (état, mémoire, threads).
    status_content = File.read("/proc/#{pid}/status") rescue nil
    return nil unless status_content

    info = {
      pid: pid,
      name: get_process_name(pid),
      state: get_process_state(status_content),    # Refactorisé avec Regex
      cpu_percent: get_cpu_usage(pid),
      memory_mb: get_memory_usage(status_content), # Refactorisé avec Regex
      open_files: get_open_files(pid),
      syscalls: get_recent_syscalls(pid),
      cmdline: get_cmdline(pid),
      threads: get_thread_count(status_content)    # Refactorisé avec Regex
    }
    info
  rescue
    nil
  end

  def generate_report(target_pid = nil)
    puts "=" * 80
    puts "RAPPORT D'ANALYSE DE PROCESSUS"
    puts "Généré le: #{@timestamp}"
    puts "=" * 80
    puts

    if target_pid
      puts "Analyse du processus PID: #{target_pid}"
      info = analyze_process(target_pid)
      display_process_info(info) if info
    else
      puts "Top 10 des processus consommateurs de ressources:"
      puts
      processes = analyze_all_processes
      
      # COMMENTAIRE: Tri décroissant (-p) pour avoir les plus gros consommateurs en premier
      top_cpu = processes.sort_by { |p| -p[:cpu_percent].to_f }.take(10)
      
      puts "=== Par CPU ==="
      display_process_table(top_cpu)
      
      puts "\n=== Par Mémoire ==="
      top_mem = processes.sort_by { |p| -p[:memory_mb].to_f }.take(10)
      display_process_table(top_mem)
    end

    puts "\n" + "=" * 80
  end

  private

  def get_process_name(pid)
    File.read("/proc/#{pid}/comm").strip
  rescue
    "unknown"
  end

  # REFACTORISÉ: Utilisation de Regex pour capturer l'état
  # Le fichier status contient "State:	S (sleeping)"
  def get_process_state(status_content)
    # Regex: Cherche "State:", suivi d'espaces (\s+), capture un mot (\w)
    if match = status_content.match(/^State:\s+(\w)/)
      match[1] # Retourne la première capture (ex: "S", "R")
    else
      "?"
    end
  end

  def get_cpu_usage(pid)
    # COMMENTAIRE: /proc/[pid]/stat contient les métriques brutes du CPU sur une seule ligne.
    stat = File.read("/proc/#{pid}/stat").split
    
    # Indices spécifiques à la doc du kernel Linux (man 5 proc)
    utime = stat[13].to_i # Temps utilisateur
    stime = stat[14].to_i # Temps noyau (système)
    total_time = utime + stime
    
    uptime = File.read("/proc/uptime").split[0].to_f
    hertz = 100.0 # COMMENTAIRE: Fréquence d'horloge (Clock Ticks). 100Hz est standard mais peut varier.
    starttime = stat[21].to_i / hertz
    
    elapsed = uptime - starttime
    
    # Calcul: (Temps utilisé / Fréquence) / Temps écoulé depuis le lancement * 100
    cpu_percent = elapsed > 0 ? (total_time / hertz / elapsed * 100).round(2) : 0.0
    cpu_percent
  rescue
    0.0
  end

  # REFACTORISÉ: Utilisation de Regex pour la mémoire
  # Le fichier contient "VmRSS:     1234 kB"
  def get_memory_usage(status_content)
    # Regex: Cherche "VmRSS:", espaces, capture des chiffres (\d+), espaces, "kB" (insensible à la casse)
    if match = status_content.match(/^VmRSS:\s+(\d+)\s+kB/i)
      kb = match[1].to_i
      (kb / 1024.0).round(2) # Conversion en MB
    else
      0.0
    end
  end

  def get_open_files(pid)
    files = []
    # COMMENTAIRE: /proc/[pid]/fd/ contient des liens symboliques vers les fichiers ouverts.
    # C'est ainsi que lsof fonctionne.
    Dir.glob("/proc/#{pid}/fd/*").each do |fd|
      begin
        target = File.readlink(fd)
        # Filtre les sockets et pipes pour ne garder que les vrais fichiers
        files << target unless target.start_with?("pipe:", "socket:", "anon_inode:")
      rescue
        # Les descripteurs de fichiers peuvent se fermer très vite
      end
    end
    files.take(5) 
  rescue
    []
  end

  def get_recent_syscalls(pid)
    # Note: Pour avoir les vrais syscalls, il faudrait utiliser 'strace' ou eBPF.
    # Ici c'est une liste statique placeholder.
    ["read", "write", "open", "close", "mmap"]
  rescue
    []
  end

  def get_cmdline(pid)
    # COMMENTAIRE: cmdline sépare les arguments par des caractères nuls (\0).
    # On les remplace par des espaces pour l'affichage.
    cmdline = File.read("/proc/#{pid}/cmdline").gsub("\0", " ").strip
    cmdline.empty? ? "[#{get_process_name(pid)}]" : cmdline
  rescue
    "unknown"
  end

  # REFACTORISÉ: Utilisation de Regex pour le nombre de threads
  def get_thread_count(status_content)
    # Regex: Cherche "Threads:", espaces, capture des chiffres (\d+)
    if match = status_content.match(/^Threads:\s+(\d+)/)
      match[1].to_i
    else
      1
    end
  end

  def display_process_info(info)
    puts "PID: #{info[:pid]}"
    puts "Nom: #{info[:name]}"
    puts "État: #{info[:state]} (#{state_description(info[:state])})"
    puts "CPU: #{info[:cpu_percent]}%"
    puts "Mémoire: #{info[:memory_mb]} MB"
    puts "Threads: #{info[:threads]}"
    puts "Ligne de commande: #{info[:cmdline]}"
    puts "\nFichiers ouverts (#{info[:open_files].length}):"
    info[:open_files].each { |f| puts "  - #{f}" }
    puts "\nAppels système typiques:"
    info[:syscalls].each { |s| puts "  - #{s}" }
  end

  def display_process_table(processes)
    printf("%-8s %-20s %-6s %-8s %-10s %-8s\n", 
           "PID", "NOM", "ÉTAT", "CPU%", "MEM(MB)", "THREADS")
    puts "-" * 80
    processes.each do |p|
      printf("%-8d %-20s %-6s %-8.2f %-10.2f %-8d\n",
             p[:pid], p[:name][0..19], p[:state], 
             p[:cpu_percent], p[:memory_mb], p[:threads])
    end
  end

  def state_description(state)
    case state
    when "R" then "Running"
    when "S" then "Sleeping (interruptible)"
    when "D" then "Disk sleep (uninterruptible)"
    when "Z" then "Zombie"
    when "T" then "Stopped"
    when "t" then "Tracing stop"
    when "X" then "Dead"
    else "Unknown"
    end
  end
end

# Programme principal
if __FILE__ == $0
  if ARGV[0] == "--help" || ARGV[0] == "-h"
    puts "Usage: #{$0} [PID]"
    puts "  Sans argument: affiche les top processus"
    puts "  Avec PID: analyse détaillée d'un processus spécifique"
    exit 0
  end

  analyzer = ProcessAnalyzer.new
  
  if ARGV[0]
    pid = ARGV[0].to_i
    if pid > 0
      analyzer.generate_report(pid)
    else
      puts "PID invalide: #{ARGV[0]}"
      exit 1
    end
  else
    analyzer.generate_report
  end
end