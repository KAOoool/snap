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
//  Filename       : top_rf_2p_256x512.v
//  Author         : Huang Leilei
//  Created        : 2017-04-15
//  Description    : two port register file
//
//-------------------------------------------------------------------

`include "enc_defines.v"

module top_rf_2p_256x512 (
  clka    ,
  cena_i  ,
  addra_i ,
  dataa_o ,
  clkb    ,
  cenb_i  ,
  wenb_i  ,
  addrb_i ,
  datab_i
);


//*** PARAMETER DECLARATION ****************************************************

  localparam Word_Width = 256 ;
  localparam Addr_Width = 9   ;


//*** INPUT/OUTPUT DECLARATION *************************************************

  // A port
  input                       clka    ;
  input                       cena_i  ;
  input  [Addr_Width-1 :0]    addra_i ;
  output [Word_Width-1 :0]    dataa_o ;
                                      
  // B Port                           
  input                       clkb    ;
  input                       cenb_i  ;
  input                       wenb_i  ;
  input  [Addr_Width-1 :0]    addrb_i ;
  input  [Word_Width-1 :0]    datab_i ;


//*** MAIN BODY ****************************************************************

  rf_2p #(
    .Addr_Width    ( Addr_Width    ),
    .Word_Width    ( Word_Width    )
  ) rf_2p (
    .clka          ( clka          ),
    .cena_i        ( cena_i        ),
    .addra_i       ( addra_i       ),
    .dataa_o       ( dataa_o       ),
    .clkb          ( clkb          ),
    .cenb_i        ( cenb_i        ),
    .wenb_i        ( wenb_i        ),
    .addrb_i       ( addrb_i       ),
    .datab_i       ( datab_i       )
    );


endmodule