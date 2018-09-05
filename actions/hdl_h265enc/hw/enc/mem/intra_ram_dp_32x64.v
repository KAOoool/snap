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
//  Filename    : intra_ram_dp_32x64.v
//  Author      : Huang Leilei
//  Created     : 2012-04-01
//  Description : dual port sram
//
//-------------------------------------------------------------------

`include "enc_defines.v"

module intra_ram_dp_32x64 (
  clka    ,
  cena_i  ,
  oena_i  ,
  wena_i  ,
  addra_i ,
  dataa_o ,
  dataa_i ,
  clkb    ,
  cenb_i  ,
  oenb_i  ,
  wenb_i  ,
  addrb_i ,
  datab_o ,
  datab_i
);


//*** PARAMETER DECLARATION ****************************************************

  localparam Word_Width = 32 ;
  localparam Addr_Width = 6  ;


//*** INPUT/OUTPUT DECLARATION *************************************************
  // A port
  input                       clka    ;
  input                       cena_i  ;
  input                       oena_i  ;
  input                       wena_i  ;
  input  [Addr_Width-1 :0]    addra_i ;
  input  [Word_Width-1 :0]    dataa_i ;
  output [Word_Width-1 :0]    dataa_o ;

  // B Port
  input                       clkb    ;
  input                       cenb_i  ;
  input                       oenb_i  ;
  input                       wenb_i  ;
  input  [Addr_Width-1 :0]    addrb_i ;
  input  [Word_Width-1 :0]    datab_i ;
  output [Word_Width-1 :0]    datab_o ;


//*** MAIN BODY ****************************************************************

  ram_dp #(
    .Addr_Width    ( Addr_Width    ),
    .Word_Width    ( Word_Width    )
  ) ram_dp (
    .clka          ( clka          ),
    .cena_i        ( cena_i        ),
    .oena_i        ( oena_i        ),
    .wena_i        ( wena_i        ),
    .addra_i       ( addra_i       ),
    .dataa_o       ( dataa_o       ),
    .dataa_i       ( dataa_i       ),
    .clkb          ( clkb          ),
    .cenb_i        ( cenb_i        ),
    .oenb_i        ( oenb_i        ),
    .wenb_i        ( wenb_i        ),
    .addrb_i       ( addrb_i       ),
    .datab_o       ( datab_o       ),
    .datab_i       ( datab_i       )
    );

endmodule