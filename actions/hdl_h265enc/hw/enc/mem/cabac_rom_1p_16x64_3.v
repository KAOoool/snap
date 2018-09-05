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

module cabac_rom_1p_16x64_3(
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
        00 : r_data <= 'h0040 ;
        01 : r_data <= 'h0038 ;
        02 : r_data <= 'hec60 ;
        03 : r_data <= 'h0040 ;
        04 : r_data <= 'hfb48 ;
        05 : r_data <= 'hf650 ;
        06 : r_data <= 'h0038 ;
        07 : r_data <= 'hf158 ;
        08 : r_data <= 'hf668 ;
        09 : r_data <= 'h0040 ;
        10 : r_data <= 'hf650 ;
        11 : r_data <= 'h0038 ;
        12 : r_data <= 'hf158 ;
        13 : r_data <= 'hf668 ;
        14 : r_data <= 'h0040 ;
        15 : r_data <= 'hfb58 ;
        16 : r_data <= 'hfb50 ;
        17 : r_data <= 'hfb40 ;
        18 : r_data <= 'hfb48 ;
        19 : r_data <= 'hec50 ;
        20 : r_data <= 'h0030 ;
        21 : r_data <= 'h0a20 ;
        22 : r_data <= 'h0f18 ;
        23 : r_data <= 'h0528 ;
        24 : r_data <= 'h0030 ;
        25 : r_data <= 'hfb48 ;
        26 : r_data <= 'h0a30 ;
        27 : r_data <= 'h0040 ;
        28 : r_data <= 'hfb58 ;
        29 : r_data <= 'h0040 ;
        30 : r_data <= 'h0a20 ;
        31 : r_data <= 'hf168 ;
        32 : r_data <= 'he768 ;
        33 : r_data <= 'hf650 ;
        34 : r_data <= 'h0018 ;
        35 : r_data <= 'h0040 ;
        36 : r_data <= 'hfb48 ;
        37 : r_data <= 'hec60 ;
        38 : r_data <= 'he768 ;
        39 : r_data <= 'he760 ;
        40 : r_data <= 'hf168 ;
        41 : r_data <= 'h0040 ;
        42 : r_data <= 'hec60 ;
        43 : r_data <= 'he768 ;
        44 : r_data <= 'he760 ;
        45 : r_data <= 'hf168 ;
        46 : r_data <= 'h0040 ;
        47 : r_data <= 'h0040 ;
        48 : r_data <= 'h0540 ;
        49 : r_data <= 'h0528 ;
        50 : r_data <= 'h0a20 ;
        51 : r_data <= 'hfb30 ;
        52 : r_data <= 'hfb38 ;
        53 : r_data <= 'h0528 ;
        54 : r_data <= 'h0a20 ;
        55 : r_data <= 'hf640 ;
        56 : r_data <= 'hf148 ;
        57 : r_data <= 'hf148 ;
        58 : r_data <= 'h0040 ;
        59 : r_data <= 'h0a38 ;
        60 : r_data <= 'hfb48 ;
        61 : r_data <= 'hf160 ;
        62 : r_data <= 'hf648 ;
        63 : r_data <= 'h0048 ;
      endcase
    end
    else begin
      r_data <= 'hxxxx ;
    end
  end

endmodule




