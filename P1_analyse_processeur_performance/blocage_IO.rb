#!/usr/bin/env ruby
puts "=== Simulation: Blocage I/O (Disque) ==="
puts "PID: #{Process.pid}"
puts "Écriture dans /tmp/io_test_file..."

File.open("/tmp/io_test_file", "w") do |f|
  loop do

    f.write(Random.new.bytes(1_048_576))
    f.fsync 
    sleep 0.1
  end
end