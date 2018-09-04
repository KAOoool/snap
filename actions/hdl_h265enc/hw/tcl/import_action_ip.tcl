set action_ipdir $::env(ACTION_ROOT)/ip
#add_files -scan_for_includes -norecurse $action_hw

#User IPs
foreach usr_ip [list \
                $action_ipdir/fifo_128_512  \
                $action_ipdir/fifo_64_512  \
                $action_ipdir/fifo_512_128  \
               ] {
  foreach usr_ip_xci [exec find $usr_ip -name *.xci] {
    puts "                        importing user IP $usr_ip_xci (in PIE core)"
    add_files -norecurse $usr_ip_xci >> $log_file
    export_ip_user_files -of_objects  [get_files "$usr_ip_xci"] -force >> $log_file
  }
}

##temp:xdc
add_files $::env(ACTION_ROOT)/hw/tcl/timing.xdc >> $log_file
