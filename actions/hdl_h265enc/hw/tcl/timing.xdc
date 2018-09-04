#Timing constrains
create_clock -period 4.444 -name clkA [get_nets a0/ha_pclock]
create_clock -period 8.000 -name clkB [get_nets a0/pci_clock_125MHz]

set_clock_groups -exclusivr -group {clkA} -group {clkB}

set_false_path -from {get_clocks clkA} -to {get_clocks clkB}
set_false_path -from {get_clocks clkB} -to {get_clocks clkA}
