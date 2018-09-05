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

module cabac_rom_1p_16x64_1(
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
        01 : r_data <= 'hfb58 ;
        02 : r_data <= 'h0040 ;
        03 : r_data <= 'hf160 ;
        04 : r_data <= 'hfb50 ;
        05 : r_data <= 'hf668 ;
        06 : r_data <= 'hfb68 ;
        07 : r_data <= 'he768 ;
        08 : r_data <= 'hf648 ;
        09 : r_data <= 'hf160 ;
        10 : r_data <= 'hfb50 ;
        11 : r_data <= 'hf668 ;
        12 : r_data <= 'hfb68 ;
        13 : r_data <= 'he768 ;
        14 : r_data <= 'hf648 ;
        15 : r_data <= 'h0548 ;
        16 : r_data <= 'h0030 ;
        17 : r_data <= 'hf160 ;
        18 : r_data <= 'hf150 ;
        19 : r_data <= 'hfb48 ;
        20 : r_data <= 'hfb48 ;
        21 : r_data <= 'hec50 ;
        22 : r_data <= 'h0030 ;
        23 : r_data <= 'he740 ;
        24 : r_data <= 'hf148 ;
        25 : r_data <= 'h0a08 ;
        26 : r_data <= 'h1908 ;
        27 : r_data <= 'h0038 ;
        28 : r_data <= 'h0030 ;
        29 : r_data <= 'h0040 ;
        30 : r_data <= 'he268 ;
        31 : r_data <= 'h0040 ;
        32 : r_data <= 'hfb40 ;
        33 : r_data <= 'hf168 ;
        34 : r_data <= 'h0040 ;
        35 : r_data <= 'hf160 ;
        36 : r_data <= 'hec68 ;
        37 : r_data <= 'hf168 ;
        38 : r_data <= 'hf168 ;
        39 : r_data <= 'hec60 ;
        40 : r_data <= 'hf648 ;
        41 : r_data <= 'hf160 ;
        42 : r_data <= 'hec68 ;
        43 : r_data <= 'hf168 ;
        44 : r_data <= 'hf168 ;
        45 : r_data <= 'hec60 ;
        46 : r_data <= 'hf648 ;
        47 : r_data <= 'hfb50 ;
        48 : r_data <= 'hf148 ;
        49 : r_data <= 'hfb48 ;
        50 : r_data <= 'he268 ;
        51 : r_data <= 'h0a28 ;
        52 : r_data <= 'h0a28 ;
        53 : r_data <= 'h0f10 ;
        54 : r_data <= 'h0030 ;
        55 : r_data <= 'hfb20 ;
        56 : r_data <= 'hf638 ;
        57 : r_data <= 'h0f00 ;
        58 : r_data <= 'h0528 ;
        59 : r_data <= 'h0528 ;
        60 : r_data <= 'h0528 ;
        61 : r_data <= 'h0018 ;
        62 : r_data <= 'hfb48 ;
        63 : r_data <= 'hfb50 ;
      endcase
    end
    else begin
      r_data <= 'hxxxx ;
    end
  end

endmodule




