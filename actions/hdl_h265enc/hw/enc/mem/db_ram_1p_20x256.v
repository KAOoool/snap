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
//  Filename    : db_ram_1p_20x256.v
//  Author      : Huang Leilei
//  Created     : 2017-04-15
//  Description : single port sram
//
//-------------------------------------------------------------------

`include "enc_defines.v"

module db_ram_1p_20x256 (
  clk    ,
  cen_i  ,
  oen_i  ,
  wen_i  ,
  addr_i ,
  data_i ,
  data_o
);

//*** PARAMETER DECLARATION ****************************************************

  parameter Word_Width = 20 ;
  parameter Addr_Width = 8  ;

//*** INPUT/OUTPUT DECLARATION *************************************************

  input                     clk    ;
  input                     cen_i  ;
  input                     oen_i  ;
  input                     wen_i  ;
  input   [Addr_Width-1:0]  addr_i ;
  input   [Word_Width-1:0]  data_i ;
  output  [Word_Width-1:0]  data_o ;


//*** MAIN BODY ****************************************************************

  ram_1p #(
    .Addr_Width    ( Addr_Width    ),
    .Word_Width    ( Word_Width    )
  ) ram (                          
    .clk           ( clk           ),
    .cen_i         ( cen_i         ),
    .oen_i         ( oen_i         ),
    .wen_i         ( wen_i         ),
    .addr_i        ( addr_i        ),
    .data_i        ( data_i        ),
    .data_o        ( data_o        )
    );


endmodule
