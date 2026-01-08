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
    Dir.glob('/proc/[0-9]*').each do |proc_dir|
      pid = File.basename(proc_dir).to_i
      begin
        process_info = analyze_process(pid)
        processes << process_info if process_info
      rescue => e

      end
    end
    processes
  end

  def analyze_process(pid)
    return nil unless File.exist?("/proc/#{pid}")

    info = {
      pid: pid,
      name: get_process_name(pid),
      state: get_process_state(pid),
      cpu_percent: get_cpu_usage(pid),
      memory_mb: get_memory_usage(pid),
      open_files: get_open_files(pid),
      syscalls: get_recent_syscalls(pid),
      cmdline: get_cmdline(pid),
      threads: get_thread_count(pid)
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

  def get_process_state(pid)
    status = File.read("/proc/#{pid}/status")
    state_line = status.lines.find { |l| l.start_with?("State:") }
    state_line ? state_line.split[1] : "?"
  rescue
    "?"
  end

  def get_cpu_usage(pid)
    stat = File.read("/proc/#{pid}/stat").split
    utime = stat[13].to_i
    stime = stat[14].to_i
    total_time = utime + stime
    
    uptime = File.read("/proc/uptime").split[0].to_f
    hertz = 100.0 # CLK_TCK généralement 100
    starttime = stat[21].to_i / hertz
    
    elapsed = uptime - starttime
    cpu_percent = elapsed > 0 ? (total_time / hertz / elapsed * 100).round(2) : 0.0
    cpu_percent
  rescue
    0.0
  end

  def get_memory_usage(pid)
    status = File.read("/proc/#{pid}/status")
    vmrss_line = status.lines.find { |l| l.start_with?("VmRSS:") }
    if vmrss_line
      kb = vmrss_line.split[1].to_i
      (kb / 1024.0).round(2)
    else
      0.0
    end
  rescue
    0.0
  end

  def get_open_files(pid)
    files = []
    Dir.glob("/proc/#{pid}/fd/*").each do |fd|
      begin
        target = File.readlink(fd)
        files << target unless target.start_with?("pipe:", "socket:", "anon_inode:")
      rescue
      end
    end
    files.take(5) 
  rescue
    []
  end

  def get_recent_syscalls(pid)
    ["read", "write", "open", "close", "mmap"]
  rescue
    []
  end

  def get_cmdline(pid)
    cmdline = File.read("/proc/#{pid}/cmdline").gsub("\0", " ").strip
    cmdline.empty? ? "[#{get_process_name(pid)}]" : cmdline
  rescue
    "unknown"
  end

  def get_thread_count(pid)
    status = File.read("/proc/#{pid}/status")
    threads_line = status.lines.find { |l| l.start_with?("Threads:") }
    threads_line ? threads_line.split[1].to_i : 1
  rescue
    1
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