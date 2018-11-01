## Env Variables

set action_root [lindex $argv 0]
set fpga_part  	[lindex $argv 1]
puts "FPGACHIP = $fpga_part"
puts "ACTION_ROOT = $action_root"

set aip_dir 	$action_root/ip
set log_dir     $action_root/../../hardware/logs
set log_file    $log_dir/create_action_ip.log
set src_path 	$aip_dir/action_ip_prj/action_ip_prj.srcs

## Create a new Vivado IP Project
puts "\[CREATE_ACTION_IPs..........\] start [clock format [clock seconds] -format {%T %a %b %d %Y}]"
create_project action_ip_prj $aip_dir/action_ip_prj -force -part $fpga_part -ip

# Project IP Settings
# General
set_property target_language Verilog [current_project] >> $log_file


##################################################################################
##################################################################################
##################################################################################
puts "\[Generate User IP 1 (AFU_DMA)\]"
##################################################################################
#   Add afu_dma IPs
##################################################################################

puts "Generating fifo_128_512 ......"
create_ip -name fifo_generator -vendor xilinx.com -library ip -version 13.2 -module_name fifo_128_512 >> $log_file
set_property -dict [list CONFIG.Component_Name {fifo_128_512} CONFIG.Fifo_Implementation {Independent_Clocks_Block_RAM} CONFIG.Performance_Options {First_Word_Fall_Through} CONFIG.asymmetric_port_width {true} CONFIG.Input_Data_Width {128} CONFIG.Output_Data_Width {512} CONFIG.Output_Depth {256} CONFIG.Reset_Type {Asynchronous_Reset} CONFIG.Full_Flags_Reset_Value {1} CONFIG.Read_Data_Count_Width {8} CONFIG.Full_Threshold_Assert_Value {1023} CONFIG.Full_Threshold_Negate_Value {1022} CONFIG.Empty_Threshold_Assert_Value {4} CONFIG.Empty_Threshold_Negate_Value {5} CONFIG.Enable_Safety_Circuit {false}] [get_ips fifo_128_512] >> $log_file
generate_target all [get_files $src_path/sources_1/ip/fifo_128_512/fifo_128_512.xci] >> $log_file

puts "Generating fifo_512_128 ......"
create_ip -name fifo_generator -vendor xilinx.com -library ip -version 13.2 -module_name fifo_512_128 >> $log_file
set_property -dict [list CONFIG.Component_Name {fifo_512_128} CONFIG.Fifo_Implementation {Independent_Clocks_Block_RAM} CONFIG.Performance_Options {First_Word_Fall_Through} CONFIG.asymmetric_port_width {true} CONFIG.Input_Data_Width {512} CONFIG.Input_Depth {512} CONFIG.Output_Data_Width {128} CONFIG.Output_Depth {2048} CONFIG.Reset_Type {Asynchronous_Reset} CONFIG.Full_Flags_Reset_Value {1} CONFIG.Data_Count_Width {9} CONFIG.Write_Data_Count_Width {9} CONFIG.Read_Data_Count_Width {11} CONFIG.Full_Threshold_Assert_Value {509} CONFIG.Full_Threshold_Negate_Value {508} CONFIG.Empty_Threshold_Assert_Value {4} CONFIG.Empty_Threshold_Negate_Value {5} CONFIG.Enable_Safety_Circuit {false}] [get_ips fifo_512_128] >> $log_file
generate_target all [get_files $src_path/sources_1/ip/fifo_512_128/fifo_512_128.xci] >> $log_file

puts "Generating fifo_64_512 ......"
create_ip -name fifo_generator -vendor xilinx.com -library ip -version 13.2 -module_name fifo_64_512 >> $log_file
set_property -dict [list CONFIG.Component_Name {fifo_64_512} CONFIG.Fifo_Implementation {Independent_Clocks_Block_RAM} CONFIG.Performance_Options {First_Word_Fall_Through} CONFIG.asymmetric_port_width {true} CONFIG.Input_Data_Width {64} CONFIG.Output_Data_Width {512} CONFIG.Output_Depth {128} CONFIG.Reset_Type {Asynchronous_Reset} CONFIG.Full_Flags_Reset_Value {1} CONFIG.Read_Data_Count_Width {7} CONFIG.Full_Threshold_Assert_Value {1023} CONFIG.Full_Threshold_Negate_Value {1022} CONFIG.Empty_Threshold_Assert_Value {4} CONFIG.Empty_Threshold_Negate_Value {5} CONFIG.Enable_Safety_Circuit {false}] [get_ips fifo_64_512] >> $log_file
generate_target all [get_files $src_path/sources_1/ip/fifo_64_512/fifo_64_512.xci] >> $log_file

puts "Generating clk_wiz_h265"
create_ip -name clk_wiz -vendor xilinx.com -library ip -version 5.4 -module_name clk_wiz_h265 >> $log_file
set_property -dict [list CONFIG.PRIM_IN_FREQ {125.000} CONFIG.CLKOUT1_DRIVES {BUFG} CONFIG.CLKIN1_JITTER_PS {80.0} CONFIG.FEEDBACK_SOURCE {FDBK_AUTO} CONFIG.MMCM_DIVCLK_DIVIDE {5} CONFIG.MMCM_CLKFBOUT_MULT_F {48.000} CONFIG.MMCM_CLKIN1_PERIOD {8.000} CONFIG.CLKOUT1_JITTER {177.983} CONFIG.CLKOUT1_PHASE_ERROR {222.305}] [get_ips clk_wiz_h265] >> $log_file
generate_target all [get_files $src_path/sources_1/ip/clk_wiz_h265/clk_wiz_h265.xci] >> $log_file

puts "\[CREATE_ACTION_IPs..........\] done  [clock format [clock seconds] -format {%T %a %b %d %Y}]"
close_project
