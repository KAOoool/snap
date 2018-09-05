//-------------------------------------------------------------------
//
//  COPYRIGHT (C) 2011, VIPcore Group, Fudan University
//
//  THIS FILE MAY NOT BE MODIFIED OR REDISTRIBUTED WITHOUT THE
//  EXPRESSED WRITTEN CONSENT OF VIPcore Group
//
//  VIPcore    : http://soc.fudan.edu.cn/vip
//  IP Owner   : Yibo FAN
//  Contact    : fanyibo@fudan.edu.cn
//
//-------------------------------------------------------------------
//
//  Filename    : cabac_rom_1p_16x64.v
//  Author      : Huang leilei
//  Created     : 2017-04-15
//  Description : single port rom
//
//-------------------------------------------------------------------

`include "enc_defines.v"

module cabac_rom_1p_16x64_0(
  clk    ,
  r_en   ,
  r_addr ,
  r_data
  );


//*** PARAMETER DECLARATION ****************************************************

  localparam Word_Width = 16  ;
  localparam Addr_Width = 6   ;


//*** INPUT/OUTPUT DECLARATION *************************************************

  input                       clk    ;
  input                       r_en   ;
  input  [Addr_Width-1 :0]    r_addr ;
  output [Word_Width-1 :0]    r_data ;


//*** REG/WIRE DECLARATION *****************************************************

  reg    [Word_Width-1 :0]    r_data ;


//*** MAIN BODY ****************************************************************

  always @(posedge clk ) begin
    if( r_en ) begin
      case( r_addr )
        00 : r_data <= 'hf168 ;
        01 : r_data <= 'hf160 ;
        02 : r_data <= 'hf658 ;
        03 : r_data <= 'hf658 ;
        04 : r_data <= 'hf168 ;
        05 : r_data <= 'hf168 ;
        06 : r_data <= 'hf150 ;
        07 : r_data <= 'hf160 ;
        08 : r_data <= 'hf658 ;
        09 : r_data <= 'hf658 ;
        10 : r_data <= 'hf168 ;
        11 : r_data <= 'hf168 ;
        12 : r_data <= 'hf150 ;
        13 : r_data <= 'hec48 ;
        14 : r_data <= 'h0a20 ;
        15 : r_data <= 'h0a20 ;
        16 : r_data <= 'hf148 ;
        17 : r_data <= 'h0a08 ;
        18 : r_data <= 'hf148 ;
        19 : r_data <= 'h0a08 ;
        20 : r_data <= 'hf148 ;
        21 : r_data <= 'h0a08 ;
        22 : r_data <= 'hf168 ;
        23 : r_data <= 'hfb50 ;
        24 : r_data <= 'hfb50 ;
        25 : r_data <= 'h0038 ;
        26 : r_data <= 'hfb48 ;
        27 : r_data <= 'hfb50 ;
        28 : r_data <= 'hfb50 ;
        29 : r_data <= 'hfb40 ;
        30 : r_data <= 'h0a30 ;
        31 : r_data <= 'h0040 ;
        32 : r_data <= 'h0038 ;
        33 : r_data <= 'hf658 ;
        34 : r_data <= 'hf160 ;
        35 : r_data <= 'hf658 ;
        36 : r_data <= 'hf160 ;
        37 : r_data <= 'hec68 ;
        38 : r_data <= 'hf150 ;
        39 : r_data <= 'hf658 ;
        40 : r_data <= 'hf160 ;
        41 : r_data <= 'hf658 ;
        42 : r_data <= 'hf160 ;
        43 : r_data <= 'hec68 ;
        44 : r_data <= 'hf150 ;
        45 : r_data <= 'hf638 ;
        46 : r_data <= 'hf648 ;
        47 : r_data <= 'hf648 ;
        48 : r_data <= 'h0520 ;
        49 : r_data <= 'hfb30 ;
        50 : r_data <= 'h0520 ;
        51 : r_data <= 'hfb30 ;
        52 : r_data <= 'h0520 ;
        53 : r_data <= 'hfb30 ;
        54 : r_data <= 'h0540 ;
        55 : r_data <= 'h0040 ;
        56 : r_data <= 'h0040 ;
        57 : r_data <= 'h0a20 ;
        58 : r_data <= 'h0038 ;
        59 : r_data <= 'h0538 ;
        60 : r_data <= 'h0040 ;
        61 : r_data <= 'hf148 ;
        62 : r_data <= 'h0f18 ;
        63 : r_data <= 'h0530 ;
      endcase
    end
    else begin
      r_data <= 'hxxxx ;
    end
  end

endmodule




