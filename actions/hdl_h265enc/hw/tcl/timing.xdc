#Timing constrains
#create_clock -period 4.444444444 -name clkA [get_nets c0/U0/pll0/clk_out1]
#create_clock -period 10.000 -name clkB [get_nets a0/action_w/pll_h265/clk_out1]

#set_clock_groups -logically_exclusive -group {clkA} -group {clkB}

set_false_path -from [get_clocks -of_objects [get_nets c0/U0/pll0/clk_out1]] -to [get_clocks -of_objects [get_nets a0/action_w/pll_h265/clk_out1]]
set_false_path -from [get_clocks -of_objects [get_nets a0/action_w/pll_h265/clk_out1]] -to [get_clocks -of_objects [get_nets c0/U0/pll0/clk_out1]]
