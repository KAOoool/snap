//-------------------------------------------------------------------
//
//  Filename      : h265enc_top_with_gm.v
//  Author        : Gu Chenhao
//  Created       : 2018-06-04
//  Description   : h265enc_top_with_gm
//
//-------------------------------------------------------------------

`include "enc_defines.v"

module reverse_top_with_gm(
  // global
  axi_clk            , 
  axi_rstn           ,
  enc_clk            , 
  enc_rstn           ,
  // apb_s
  apb_s_pready       ,
  apb_s_pslverr      ,
  apb_s_prdata       ,
  apb_s_paddr        ,
  apb_s_penable      ,
  apb_s_psel         ,
  apb_s_pwdata       ,
  apb_s_pwrite       ,
  // axi_m0
  gen_m0_maddr       ,
  gen_m0_mburst      ,
  gen_m0_mcache      ,
  gen_m0_mdata       ,
  gen_m0_mid         ,
  gen_m0_mlen        ,
  gen_m0_mlock       ,
  gen_m0_mprot       ,
  gen_m0_mread       ,
  gen_m0_mready      ,
  gen_m0_msize       ,
  gen_m0_mwrite      ,
  gen_m0_mwstrb      ,
  gen_m0_saccept     ,
  gen_m0_sdata       ,
  gen_m0_sid         ,
  gen_m0_slast       ,
  gen_m0_sresp       ,
  gen_m0_svalid      
  );


//*** PARAMETER DECLARATION ****************************************************

  parameter    AXI_DW                = 512          ,
               AXI_AW                = 64           ,
               AXI_MIDW              = 4            ,
               AXI_SIDW              = 8            ;

  parameter    AXI_WID               = 0            ,
               AXI_RID               = 0            ;

//*** INPUT/OUTPUT DECLARATION *************************************************

  // global
  input                              axi_clk        ;
  input                              axi_rstn       ;
  input                              enc_clk        ;
  input                              enc_rstn       ;
  // apb_s
  output                             apb_s_pready   ;
  output                             apb_s_pslverr  ;
  output [31                : 0]     apb_s_prdata   ;
  input  [31                : 0]     apb_s_paddr    ;
  input                              apb_s_penable  ;
  input                              apb_s_psel     ;
  input  [31                : 0]     apb_s_pwdata   ;
  input                              apb_s_pwrite   ;

  // gen_m0       
  output [AXI_AW-1          : 0]     gen_m0_maddr   ;
  output [1                 : 0]     gen_m0_mburst  ;
  output [3                 : 0]     gen_m0_mcache  ;
  output [AXI_DW-1          : 0]     gen_m0_mdata   ;
  output [AXI_MIDW-1        : 0]     gen_m0_mid     ;
  output [3                 : 0]     gen_m0_mlen    ;
  output                             gen_m0_mlock   ;
  output [2                 : 0]     gen_m0_mprot   ;
  output                             gen_m0_mread   ;
  output                             gen_m0_mready  ;
  output [2                 : 0]     gen_m0_msize   ;
  output                             gen_m0_mwrite  ;
  output [AXI_DW/8-1        : 0]     gen_m0_mwstrb  ;
  input                              gen_m0_saccept ;
  input  [AXI_DW-1          : 0]     gen_m0_sdata   ;
  input  [AXI_MIDW-1        : 0]     gen_m0_sid     ;
  input                              gen_m0_slast   ;
  input  [2                 : 0]     gen_m0_sresp   ;
  input                              gen_m0_svalid  ;


//*** WIRE DECLARATION *********************************************************

  // config
  wire                               sys_start      ;
  wire                               sys_done       ;

  // ext_if
  wire                               rd_ena         ;
  wire   [16*`PIXEL_WIDTH-1 : 0]     wr_dat         ;

  // bs
  wire                               bs_val         ;
  wire   [7                 : 0]     bs_dat         ;

  // axi_lite
  wire                               s_axi_awready  ;
  wire   [31                : 0]     s_axi_awaddr   ;
  wire                               s_axi_awvalid  ;
  wire                               s_axi_wready   ;
  wire   [31                : 0]     s_axi_wdata    ;
  wire   [3                 : 0]     s_axi_wstrb    ;
  wire                               s_axi_wvalid   ;
  wire   [1                 : 0]     s_axi_bresp    ;
  wire                               s_axi_bvalid   ;
  wire                               s_axi_bready   ;
  wire                               s_axi_arready  ;
  wire   [31                : 0]     s_axi_araddr   ;
  wire                               s_axi_arvalid  ;
  wire   [31                : 0]     s_axi_rdata    ;
  wire   [1                 : 0]     s_axi_rresp    ;
  wire                               s_axi_rvalid   ;
  wire                               s_axi_rready   ;


//*** MAIN BODY ****************************************************************

  reverse_if reverse_if(
    // global
    .axi_clk           ( axi_clk           ), //250MHz
    .axi_rstn          ( axi_rstn          ),
    .enc_clk           ( enc_clk           ), //125MHz
    .enc_rstn          ( enc_rstn          ),
    // axi_lite
    .s_axi_awready     ( s_axi_awready     ),
    .s_axi_awaddr      ( s_axi_awaddr      ),
    .s_axi_awvalid     ( s_axi_awvalid     ),
    .s_axi_wready      ( s_axi_wready      ),
    .s_axi_wdata       ( s_axi_wdata       ),
    .s_axi_wstrb       ( s_axi_wstrb       ),
    .s_axi_wvalid      ( s_axi_wvalid      ),
    .s_axi_bresp       ( s_axi_bresp       ),
    .s_axi_bvalid      ( s_axi_bvalid      ),
    .s_axi_bready      ( s_axi_bready      ),
    .s_axi_arready     ( s_axi_arready     ),
    .s_axi_arvalid     ( s_axi_arvalid     ),
    .s_axi_araddr      ( s_axi_araddr      ),
    .s_axi_rdata       ( s_axi_rdata       ),
    .s_axi_rresp       ( s_axi_rresp       ),
    .s_axi_rready      ( s_axi_rready      ),
    .s_axi_rvalid      ( s_axi_rvalid      ),
    // config
    .sys_start_o       ( sys_start         ),
    .sys_done_i        ( sys_done          ),
    // gen_m0
    .gen_m0_maddr      ( gen_m0_maddr      ),
    .gen_m0_mburst     ( gen_m0_mburst     ),
    .gen_m0_mcache     ( gen_m0_mcache     ),
    .gen_m0_mdata      ( gen_m0_mdata      ),
    .gen_m0_mid        ( gen_m0_mid        ),
    .gen_m0_mlen       ( gen_m0_mlen       ),
    .gen_m0_mlock      ( gen_m0_mlock      ),
    .gen_m0_mprot      ( gen_m0_mprot      ),
    .gen_m0_mread      ( gen_m0_mread      ),
    .gen_m0_mready     ( gen_m0_mready     ),
    .gen_m0_msize      ( gen_m0_msize      ),
    .gen_m0_mwrite     ( gen_m0_mwrite     ),
    .gen_m0_mwstrb     ( gen_m0_mwstrb     ),
    .gen_m0_saccept    ( gen_m0_saccept    ),
    .gen_m0_sdata      ( gen_m0_sdata      ),
    .gen_m0_sid        ( gen_m0_sid        ),
    .gen_m0_slast      ( gen_m0_slast      ),
    .gen_m0_sresp      ( gen_m0_sresp      ),
    .gen_m0_svalid     ( gen_m0_svalid     ),
    // ext
    .rden_i            ( rd_ena            ),
    .data_o            ( wr_dat            ),
    .i_action_type     ( 32'h00000000      ),
    .i_action_version  ( 32'h00000000      ),
    // bs
    .bs_val_i          ( bs_val            ),
    .bs_dat_i          ( bs_dat            )
    );

//*** H265CORE ***********************************

  reverse_top reverse_top(
    // global
    .clk               ( enc_clk           ),
    .rstn              ( enc_rstn          ),
    // config
    .sys_start_i       ( sys_start         ),
    .sys_done_o        ( sys_done          ),
    // ext
    .rden_o            ( rd_ena            ),
    .data_i            ( wr_dat            ),
    // bs
    .bs_val_o          ( bs_val            ),
    .bs_dat_o          ( bs_dat            )
    );


endmodule
