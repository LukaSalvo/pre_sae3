#!/usr/bin/env ruby
# orchestrateur.rb
# Script principal d'automatisation pour le projet SAE 3
# Orchestre les outils d'analyse processeur, réseau et système.

require 'fileutils'
require 'open3'

class Orchestrator
  # Définition des chemins relatifs vers les outils
  TOOLS = {
    process: {
      path: File.join(__dir__, '../P1_analyse_processeur_performance/rapport_analyse.rb'),
      desc: "Analyse processus (CPU/Mem en Ruby)",
      type: :ruby
    },
    network: {
      path: File.join(__dir__, '../P2_diagnostique_reseau/audit_reseau.rb'),
      desc: "Audit réseau automatisé (Ruby)",
      type: :ruby
    },
    system: {
      path: File.join(__dir__, '../P4_diagnostic_système_avancés/tableau_de_bord.sh'),
      desc: "Tableau de bord système (Bash)",
      type: :bash
    }
  }

  def initialize
    check_root
    @report_dir = File.join(__dir__, 'rapports_automatises')
    FileUtils.mkdir_p(@report_dir)
  end

  def start
    loop do
      display_menu
      choice = gets.chomp
      case choice
      when '1' then run_tool(:process)
      when '2' then run_tool(:network)
      when '3' then run_tool(:system)
      when '4' then run_all
      when '0', 'q', 'exit'
        puts "Au revoir."
        break
      else
        puts "Choix invalide."
      end
      puts "\nAppuyez sur Entrée pour continuer..."
      gets
    end
  end

  private

  def check_root
    if Process.uid != 0
      puts "ATTENTION : Ce script doit idéalement être lancé en root (sudo) pour accéder à toutes les métriques."
      puts "Certains outils (comem iotop, audit réseau complet) peuvent échouer sans privilèges."
      print "Voulez-vous continuer quand même ? (o/N) "
      resp = gets.chomp.downcase
      exit unless resp == 'o'
    end
  end

  def display_menu
    system("clear") || system("cls")
    puts "Orchestrateur SAE 3 - Diagnostic système"
    puts "1. Lancer l'Analyse Processus/Performance"
    puts "2. Lancer l'Audit Réseau"
    puts "3. Générer le Tableau de Bord Système"
    puts "4. TOUT LANCER (Rapport complet)"
    puts "0. Quitter"
    puts "0. Quitter"
    print "Votre choix : "
  end

  def run_tool(key)
    tool = TOOLS[key]
    puts "\n>>> Lancement de : #{tool[:desc]}..."
    
    unless File.exist?(tool[:path])
      puts "ERREUR : Fichier introuvable (#{tool[:path]})"
      return
    end

    cmd = case tool[:type]
          when :ruby
            "ruby \"#{tool[:path]}\""
          when :bash
            "bash \"#{tool[:path]}\""
          end

    puts "Exécution : #{cmd}"
    
    # Exécution de la commande
    # On laisse la sortie s'afficher dans le terminal pour le mode interactif
    success = system(cmd)
    
    if success
      puts "\n[OK] Module terminé avec succès."
    else
      puts "\n[ERREUR] Le module a retourné une erreur."
    end
  end

  def run_all
    timestamp = Time.now.strftime('%Y-%m-%d_%Hh%M')
    full_report_path = File.join(@report_dir, "audit_complet_#{timestamp}.txt")
    
    puts "\nLancement de l'audit complet"
    puts "Les sorties seront concaténées dans : #{full_report_path}"

    File.open(full_report_path, 'w') do |f|
      f.puts "RAPPORT D'AUDIT GLOBAL SAE 3"
      f.puts "Date : #{Time.now}"
      f.puts "Date : #{Time.now}\n\n"
      
      TOOLS.each do |key, tool|
        f.puts ">>> MODULE : #{tool[:desc]}"

        
        # Capture de la sortie standard et d'erreur
        cmd = case tool[:type]
              when :ruby
                "ruby \"#{tool[:path]}\""
              when :bash
                "bash \"#{tool[:path]}\""
              end
        
        stdout_str, stderr_str, status = Open3.capture3(cmd)
        
        f.puts stdout_str
        if !stderr_str.empty?
          f.puts "\n[STDERR] :"
          f.puts stderr_str
        end
        f.puts "\n\n"
        puts "- #{tool[:desc]} : #{status.success? ? 'OK' : 'ERREUR'}"
      end
    end
    puts "\nAudit complet terminé. Rapport disponible : #{full_report_path}"
  end
end

# Lancement direct si exécuté en tant que script
if __FILE__ == $0
  Orchestrator.new.start
end
