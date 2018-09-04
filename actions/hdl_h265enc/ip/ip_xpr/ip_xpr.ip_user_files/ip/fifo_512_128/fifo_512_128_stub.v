// Copyright 1986-2017 Xilinx, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2017.4 (lin64) Build 2086221 Fri Dec 15 20:54:30 MST 2017
// Date        : Mon Sep  3 03:55:28 2018
// Host        : hdclf136.boeblingen.de.ibm.com running 64-bit Red Hat Enterprise Linux Workstation release 6.9 (Santiago)
// Command     : write_verilog -force -mode synth_stub
//               /afs/vlsilab.boeblingen.ibm.com/u/lyhlu/vol2/HEVC/snap/actions/hdl_h265enc/ip/fifo_512_128/fifo_512_128_stub.v
// Design      : fifo_512_128
// Purpose     : Stub declaration of top-level module interface
// Device      : xcvu9p-flgb2104-2L-e
// --------------------------------------------------------------------------------

// This empty module with port declaration file causes synthesis tools to infer a black box for IP.
// The synthesis directives are for Synopsys Synplify support to prevent IO buffer insertion.
// Please paste the declaration into a Verilog source file or add the file as an additional source.
(* x_core_info = "fifo_generator_v13_2_1,Vivado 2017.4" *)
module fifo_512_128(rst, wr_clk, rd_clk, din, wr_en, rd_en, dout, full, 
  empty)
/* synthesis syn_black_box black_box_pad_pin="rst,wr_clk,rd_clk,din[511:0],wr_en,rd_en,dout[127:0],full,empty" */;
  input rst;
  input wr_clk;
  input rd_clk;
  input [511:0]din;
  input wr_en;
  input rd_en;
  output [127:0]dout;
  output full;
  output empty;
endmodule
