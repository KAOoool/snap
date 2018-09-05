//-------------------------------------------------------------------
//
//  COPYRIGHT (C) 2011, VIPcore Group, Fudan University
//
//  THIS FILE MAY NOT BE MODIFIED OR REDISTRIBUTED WITHOUT THE
//  EXPRESSED WRITTEN CONSENT OF VIPcore Group
//
//  VIPcore     : http://soc.fudan.edu.cn/vip
//  IP Owner    : Yibo FAN
//  Contact     : fanyibo@fudan.edu.cn
//
//-------------------------------------------------------------------
//
//  Filename    : cabac_rf_2p_7x64.v
//  Author      : Yibo FAN
//  Created     : 2012-04-01
//  Description : two port register file
//
//-------------------------------------------------------------------

`include "enc_defines.v"

module cabac_rf_2p_7x64 (
  clk    ,
  r_en   ,
  r_addr ,
  r_data ,
  w_en   ,
  w_addr ,
  w_data
);


//*** PARAMETER DECLARATION ****************************************************

  localparam Word_Width = 7 ;
  localparam Addr_Width = 6 ;


//*** INPUT/OUTPUT DECLARATION *************************************************

  input                       clk    ;
  input                       r_en   ;
  input  [Addr_Width-1 :0]    r_addr ;
  output [Word_Width-1 :0]    r_data ;
  input                       w_en   ;
  input  [Addr_Width-1 :0]    w_addr ;
  input  [Word_Width-1 :0]    w_data ;


//*** MAIN BODY ****************************************************************

  rf_2p #(
    .Addr_Width    ( Addr_Width    ),
    .Word_Width    ( Word_Width    )
  ) ram (
    .clka          ( clk           ),
    .cena_i        (~r_en          ),
    .addra_i       ( r_addr        ),
    .dataa_o       ( r_data        ),
    .clkb          ( clk           ),
    .cenb_i        (~w_en          ),
    .wenb_i        (~w_en          ),
    .addrb_i       ( w_addr        ),
    .datab_i       ( w_data        )
    );


endmodule
