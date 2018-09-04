-- Copyright 1986-2017 Xilinx, Inc. All Rights Reserved.
-- --------------------------------------------------------------------------------
-- Tool Version: Vivado v.2017.4 (lin64) Build 2086221 Fri Dec 15 20:54:30 MST 2017
-- Date        : Mon Sep  3 03:53:20 2018
-- Host        : hdclf136.boeblingen.de.ibm.com running 64-bit Red Hat Enterprise Linux Workstation release 6.9 (Santiago)
-- Command     : write_vhdl -force -mode synth_stub
--               /afs/vlsilab.boeblingen.ibm.com/u/lyhlu/vol2/HEVC/snap/actions/hdl_h265enc/ip/fifo_128_512/fifo_128_512_stub.vhdl
-- Design      : fifo_128_512
-- Purpose     : Stub declaration of top-level module interface
-- Device      : xcvu9p-flgb2104-2L-e
-- --------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity fifo_128_512 is
  Port ( 
    rst : in STD_LOGIC;
    wr_clk : in STD_LOGIC;
    rd_clk : in STD_LOGIC;
    din : in STD_LOGIC_VECTOR ( 127 downto 0 );
    wr_en : in STD_LOGIC;
    rd_en : in STD_LOGIC;
    dout : out STD_LOGIC_VECTOR ( 511 downto 0 );
    full : out STD_LOGIC;
    empty : out STD_LOGIC
  );

end fifo_128_512;

architecture stub of fifo_128_512 is
attribute syn_black_box : boolean;
attribute black_box_pad_pin : string;
attribute syn_black_box of stub : architecture is true;
attribute black_box_pad_pin of stub : architecture is "rst,wr_clk,rd_clk,din[127:0],wr_en,rd_en,dout[511:0],full,empty";
attribute x_core_info : string;
attribute x_core_info of stub : architecture is "fifo_generator_v13_2_1,Vivado 2017.4";
begin
end;
