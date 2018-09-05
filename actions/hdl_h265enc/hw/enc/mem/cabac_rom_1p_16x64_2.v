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

module cabac_rom_1p_16x64_2(
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
        00 : r_data <= 'hfb40 ;
        01 : r_data <= 'hfb40 ;
        02 : r_data <= 'hfb48 ;
        03 : r_data <= 'hfb50 ;
        04 : r_data <= 'he268 ;
        05 : r_data <= 'hfb50 ;
        06 : r_data <= 'he268 ;
        07 : r_data <= 'hfb20 ;
        08 : r_data <= 'hfb48 ;
        09 : r_data <= 'h0038 ;
        10 : r_data <= 'hfb58 ;
        11 : r_data <= 'hf658 ;
        12 : r_data <= 'hfb58 ;
        13 : r_data <= 'hf658 ;
        14 : r_data <= 'hfb58 ;
        15 : r_data <= 'hf658 ;
        16 : r_data <= 'hf658 ;
        17 : r_data <= 'hf168 ;
        18 : r_data <= 'hf650 ;
        19 : r_data <= 'hf168 ;
        20 : r_data <= 'hf168 ;
        21 : r_data <= 'hfb38 ;
        22 : r_data <= 'hfb40 ;
        23 : r_data <= 'h0018 ;
        24 : r_data <= 'hf640 ;
        25 : r_data <= 'h0520 ;
        26 : r_data <= 'hf640 ;
        27 : r_data <= 'hfb30 ;
        28 : r_data <= 'h0058 ;
        29 : r_data <= 'h0040 ;
        30 : r_data <= 'h0040 ;
        31 : r_data <= 'h0040 ;
        32 : r_data <= 'hec60 ;
        33 : r_data <= 'hf148 ;
        34 : r_data <= 'hfb48 ;
        35 : r_data <= 'hf160 ;
        36 : r_data <= 'hf150 ;
        37 : r_data <= 'hf160 ;
        38 : r_data <= 'hf150 ;
        39 : r_data <= 'he258 ;
        40 : r_data <= 'h0038 ;
        41 : r_data <= 'h0528 ;
        42 : r_data <= 'hfb50 ;
        43 : r_data <= 'h0040 ;
        44 : r_data <= 'hfb50 ;
        45 : r_data <= 'h0040 ;
        46 : r_data <= 'hfb50 ;
        47 : r_data <= 'h0040 ;
        48 : r_data <= 'hfb48 ;
        49 : r_data <= 'h0040 ;
        50 : r_data <= 'h0038 ;
        51 : r_data <= 'hfb50 ;
        52 : r_data <= 'hfb50 ;
        53 : r_data <= 'h0f10 ;
        54 : r_data <= 'h0528 ;
        55 : r_data <= 'h0018 ;
        56 : r_data <= 'hfb30 ;
        57 : r_data <= 'h0520 ;
        58 : r_data <= 'hfb38 ;
        59 : r_data <= 'hec48 ;
        60 : r_data <= 'hf660 ;
        61 : r_data <= 'h0040 ;
        62 : r_data <= 'h0f38 ;
        63 : r_data <= 'h0040 ;
      endcase
    end
    else begin
      r_data <= 'hxxxx ;
    end
  end

endmodule




