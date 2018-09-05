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

module cabac_rom_1p_16x64_4(
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
        00 : r_data <= 'hfb30 ;
        01 : r_data <= 'hf658 ;
        02 : r_data <= 'h0038 ;
        03 : r_data <= 'hf658 ;
        04 : r_data <= 'h0038 ;
        05 : r_data <= 'hf658 ;
        06 : r_data <= 'h0038 ;
        07 : r_data <= 'hec60 ;
        08 : r_data <= 'hf160 ;
        09 : r_data <= 'hf650 ;
        10 : r_data <= 'hfb30 ;
        11 : r_data <= 'hfb30 ;
        12 : r_data <= 'hfb40 ;
        13 : r_data <= 'h0038 ;
        14 : r_data <= 'hfb30 ;
        15 : r_data <= 'h0528 ;
        16 : r_data <= 'h0030 ;
        17 : r_data <= 'h0030 ;
        18 : r_data <= 'h0040 ;
        19 : r_data <= 'h0038 ;
        20 : r_data <= 'h0f30 ;
        21 : r_data <= 'h0040 ;
        22 : r_data <= 'h0040 ;
        23 : r_data <= 'h0040 ;
        24 : r_data <= 'h0040 ;
        25 : r_data <= 'h0040 ;
        26 : r_data <= 'h0040 ;
        27 : r_data <= 'h0040 ;
        28 : r_data <= 'h0040 ;
        29 : r_data <= 'h0040 ;
        30 : r_data <= 'h0040 ;
        31 : r_data <= 'h0040 ;
        32 : r_data <= 'hf638 ;
        33 : r_data <= 'h0a28 ;
        34 : r_data <= 'h0038 ;
        35 : r_data <= 'h0a28 ;
        36 : r_data <= 'h0038 ;
        37 : r_data <= 'h0a28 ;
        38 : r_data <= 'h0038 ;
        39 : r_data <= 'h0040 ;
        40 : r_data <= 'h0038 ;
        41 : r_data <= 'hf648 ;
        42 : r_data <= 'h0028 ;
        43 : r_data <= 'h0028 ;
        44 : r_data <= 'hf148 ;
        45 : r_data <= 'h0528 ;
        46 : r_data <= 'hec48 ;
        47 : r_data <= 'hf640 ;
        48 : r_data <= 'hf148 ;
        49 : r_data <= 'h0528 ;
        50 : r_data <= 'h0040 ;
        51 : r_data <= 'h0038 ;
        52 : r_data <= 'h0a38 ;
        53 : r_data <= 'h0040 ;
        54 : r_data <= 'h0040 ;
        55 : r_data <= 'h0040 ;
        56 : r_data <= 'h0040 ;
        57 : r_data <= 'h0040 ;
        58 : r_data <= 'h0040 ;
        59 : r_data <= 'h0040 ;
        60 : r_data <= 'h0040 ;
        61 : r_data <= 'h0040 ;
        62 : r_data <= 'h0f20 ;
        63 : r_data <= 'h0040 ;
      endcase
    end
    else begin
      r_data <= 'hxxxx ;
    end
  end

endmodule




