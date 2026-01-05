#!/usr/bin/env ruby

puts "Processus boucle infini lancé (PID #{Process.pid})"

loop do
  Math.sin(rand(1..10000))
end
