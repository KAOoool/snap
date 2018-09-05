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
//  Filename    : ime_rf_1p_64x32.v
//  Author      : Huang Leilei
//  Created     : 2017-04-15
//  Description : register file
//
//-------------------------------------------------------------------

`include "enc_defines.v"

module ime_rf_1p_64x32 (
  clk    ,
  cen_i  ,
  wen_i  ,
  addr_i ,
  data_i ,
  data_o
);

//*** PARAMETER DECLARATION ****************************************************

  localparam Word_Width = 64 ;
  localparam Addr_Width = 5  ;


//*** INPUT/OUTPUT DECLARATION *************************************************

  input                     clk    ;
  input                     cen_i  ;
  input                     wen_i  ;
  input   [Addr_Width-1:0]  addr_i ;
  input   [Word_Width-1:0]  data_i ;
  output  [Word_Width-1:0]  data_o ;


//*** MAIN BODY ****************************************************************

  rf_1p #(
    .Addr_Width    ( Addr_Width    ),
    .Word_Width    ( Word_Width    )
  ) rf_1p (
    .clk           ( clk           ),
    .cen_i         ( cen_i         ),
    .wen_i         ( wen_i         ),
    .addr_i        ( addr_i        ),
    .data_i        ( data_i        ),
    .data_o        ( data_o        )
    );


endmodule
