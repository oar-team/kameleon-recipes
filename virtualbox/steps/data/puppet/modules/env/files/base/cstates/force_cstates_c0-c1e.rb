#!/usr/bin/ruby

# This script disables C-states C2 and upper. It forces C-states to C0, C1 and C1E.
# It is part of the custom Grid'5000 service (daemon) named 'cstates'

require 'pathname'

def set_cstates(value)

  Dir.glob("/sys/devices/system/cpu/cpu*/cpuidle/state*").each { |state|
    name = File.read(Pathname.new("#{state}/name"))
    
    next if name =~ /^POLL$/
    next if name =~ /^C1[^0-9]/
    
    File.write(Pathname.new("#{state}/disable"), value)
  }

end

# Trap ^C 
Signal.trap("INT") { 
  set_cstates("0") # 0 = enable
  exit
}

# Trap `Kill `
Signal.trap("TERM") {
  set_cstates("0") # 0 = enable
  exit
}

set_cstates("1") # 1 = disable 

sleep # daemon
