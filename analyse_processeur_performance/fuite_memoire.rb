#!/usr/bin/env ruby

puts "Processus #{Process.pid} commence à fuiter de la mémoire..."
data = []
loop do
  data << "a" * 10_000_000
  sleep 0.5
  puts "Taille actuelle : #{data.length * 10} Mo"
end