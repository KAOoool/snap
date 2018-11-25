//-------------------------------------------------------------------
//
//  Filename      : h265core_top.v
//  Author        : Huang Lei Lei
//  Created       : 2015-09-12
//  Description   : top for h265core
//
//-------------------------------------------------------------------
//
//  Modified      : 2015-09-19 by HLL
//  Description   : more modes connected out
//  Modified      : 2015-10-10 by HLL
//  Description   : apb if added
//  Modified      : 2015-11-15 by HLL
//  Description   : sys_done_o connected out
//  Modified      : 2018-05-14 by GCH
//  Description   : output bus changed to axi
//  Modified      : 2018-05-14 by LYH
//  Description   : change apb to axi_lite
//
//-------------------------------------------------------------------

`include "enc_defines.v"

module reverse_top_with_axi(
  // global
  axi_clk            , //250MHz
  axi_rstn           ,
  enc_clk            , //125MHz
  enc_rstn           ,
  // axi_m0
  axi_m0_awid        , 
  axi_m0_awaddr      , 
  axi_m0_awlen       , 
  axi_m0_awsize      , 
  axi_m0_awburst     , 
  axi_m0_awcache     , 
  axi_m0_awlock      , 
  axi_m0_awprot      , 
  axi_m0_awvalid     , 
  axi_m0_awready     , 
  axi_m0_wdata       , 
  axi_m0_wstrb       , 
  axi_m0_wlast       , 
  axi_m0_wvalid      , 
  axi_m0_wready      , 
  axi_m0_bready      , 
  axi_m0_bid         , 
  axi_m0_bresp       , 
  axi_m0_bvalid      , 
  axi_m0_arid        , 
  axi_m0_araddr      , 
  axi_m0_arlen       , 
  axi_m0_arsize      , 
  axi_m0_arburst     , 
  axi_m0_arcache     , 
  axi_m0_arlock      , 
  axi_m0_arprot      , 
  axi_m0_arvalid     , 
  axi_m0_arready     , 
  axi_m0_rready      , 
  axi_m0_rid         , 
  axi_m0_rdata       , 
  axi_m0_rresp       , 
  axi_m0_rlast       , 
  axi_m0_rvalid      , 
  // axi_lite
  s_axi_awready      ,
  s_axi_awaddr       ,
  s_axi_awvalid      ,
  s_axi_wready       ,
  s_axi_wdata        ,
  s_axi_wstrb        ,
  s_axi_wvalid       ,
  s_axi_bresp        ,
  s_axi_bvalid       ,
  s_axi_bready       ,
  s_axi_arready      ,
  s_axi_arvalid      ,
  s_axi_araddr       ,
  s_axi_rdata        ,
  s_axi_rresp        ,
  s_axi_rready       ,
  s_axi_rvalid
  );


//*** PARAMETER DECLARATION ****************************************************

  parameter    AXI_DW                = 512          ,
               AXI_AW0               = 64           ,
               AXI_AW1               = 32           ,
               AXI_MIDW              = 1            ,
               AXI_SIDW              = 1            ;

  parameter    AXI_WID               = 0            ,
               AXI_RID               = 0            ;


//*** INPUT/OUTPUT DECLARATION *************************************************

  // global
  input                              axi_clk        ;
  input                              axi_rstn       ;
  input                              enc_clk        ;
  input                              enc_rstn       ;

  // axi_lite
  output                             s_axi_awready     ;
  input  [31                : 0]     s_axi_awaddr      ;
  input                              s_axi_awvalid     ;
  output                             s_axi_wready      ;
  input  [31                : 0]     s_axi_wdata       ;
  input  [3                 : 0]     s_axi_wstrb       ;
  input                              s_axi_wvalid      ;
  output [1                 : 0]     s_axi_bresp       ;
  output                             s_axi_bvalid      ;
  input                              s_axi_bready      ;
  output                             s_axi_arready     ;
  input  [31                : 0]     s_axi_araddr      ;
  input                              s_axi_arvalid     ;
  output [31                : 0]     s_axi_rdata       ;
  output [1                 : 0]     s_axi_rresp       ;
  output                             s_axi_rvalid      ;
  input                              s_axi_rready      ;

  // axi_m0
  input                              axi_m0_arready ;
  input                              axi_m0_awready ;
  input  [AXI_SIDW-1        : 0]     axi_m0_bid     ;
  input  [1                 : 0]     axi_m0_bresp   ;
  input                              axi_m0_bvalid  ;
  input  [AXI_DW-1          : 0]     axi_m0_rdata   ;
  input  [AXI_SIDW-1        : 0]     axi_m0_rid     ;
  input                              axi_m0_rlast   ;
  input  [1                 : 0]     axi_m0_rresp   ;
  input                              axi_m0_rvalid  ;
  input                              axi_m0_wready  ;
  output [AXI_AW0-1         : 0]     axi_m0_araddr  ;
  output [1                 : 0]     axi_m0_arburst ;
  output [3                 : 0]     axi_m0_arcache ;
  output [AXI_SIDW-1        : 0]     axi_m0_arid    ;
  output [3                 : 0]     axi_m0_arlen   ;
  output [1                 : 0]     axi_m0_arlock  ;
  output [2                 : 0]     axi_m0_arprot  ;
  output [2                 : 0]     axi_m0_arsize  ;
  output                             axi_m0_arvalid ;
  output [AXI_AW0-1         : 0]     axi_m0_awaddr  ;
  output [1                 : 0]     axi_m0_awburst ;
  output [3                 : 0]     axi_m0_awcache ;
  output [AXI_SIDW-1        : 0]     axi_m0_awid    ;
  output [3                 : 0]     axi_m0_awlen   ;
  output [1                 : 0]     axi_m0_awlock  ;
  output [2                 : 0]     axi_m0_awprot  ;
  output [2                 : 0]     axi_m0_awsize  ;
  output                             axi_m0_awvalid ;
  output                             axi_m0_bready  ;
  output                             axi_m0_rready  ;
  output [AXI_DW-1          : 0]     axi_m0_wdata   ;
  output                             axi_m0_wlast   ;
  output [AXI_DW/8-1        : 0]     axi_m0_wstrb   ;
  output                             axi_m0_wvalid  ;


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

  // gen_m0
  wire   [AXI_AW0-1         : 0]     gen_m0_maddr   ;
  wire   [1                 : 0]     gen_m0_mburst  ;
  wire   [3                 : 0]     gen_m0_mcache  ;
  wire   [AXI_DW-1          : 0]     gen_m0_mdata   ;
  wire   [AXI_MIDW-1        : 0]     gen_m0_mid     ;
  wire   [3                 : 0]     gen_m0_mlen    ;
  wire                               gen_m0_mlock   ;
  wire   [2                 : 0]     gen_m0_mprot   ;
  wire                               gen_m0_mread   ;
  wire                               gen_m0_mready  ;
  wire   [2                 : 0]     gen_m0_msize   ;
  wire                               gen_m0_mwrite  ;
  wire   [AXI_DW/8-1        : 0]     gen_m0_mwstrb  ;
  wire                               gen_m0_saccept ;
  wire   [AXI_DW-1          : 0]     gen_m0_sdata   ;
  wire   [AXI_MIDW-1        : 0]     gen_m0_sid     ;
  wire                               gen_m0_slast   ;
  wire   [2                 : 0]     gen_m0_sresp   ;
  wire                               gen_m0_svalid  ;


//*** MAIN BODY ****************************************************************

//*** H265CORE_IF ********************************

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
    .i_action_type     ( 32'h00000001      ),
    .i_action_version  ( 32'h00000001      ),
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

//*** GM2AXI ***********************************

  gm_0_DW_axi_gm gm_0_DW_axi_gm_0(
    // Outputs
    .saccept           ( gen_m0_saccept   ),
    .sid               ( gen_m0_sid       ),
    .svalid            ( gen_m0_svalid    ),
    .slast             ( gen_m0_slast     ),
    .sdata             ( gen_m0_sdata     ),
    .sresp             ( gen_m0_sresp     ),
    .awid              ( axi_m0_awid      ),
    .awvalid           ( axi_m0_awvalid   ),
    .awaddr            ( axi_m0_awaddr    ),
    .awlen             ( axi_m0_awlen     ),
    .awsize            ( axi_m0_awsize    ),
    .awburst           ( axi_m0_awburst   ),
    .awlock            ( axi_m0_awlock    ),
    .awcache           ( axi_m0_awcache   ),
    .awprot            ( axi_m0_awprot    ),
    .wid               (                  ), //temp
    .wvalid            ( axi_m0_wvalid    ),
    .wlast             ( axi_m0_wlast     ),
    .wdata             ( axi_m0_wdata     ),
    .wstrb             ( axi_m0_wstrb     ),
    .bready            ( axi_m0_bready    ),
    .arid              ( axi_m0_arid      ),
    .arvalid           ( axi_m0_arvalid   ),
    .araddr            ( axi_m0_araddr    ),
    .arlen             ( axi_m0_arlen     ),
    .arsize            ( axi_m0_arsize    ),
    .arburst           ( axi_m0_arburst   ),
    .arlock            ( axi_m0_arlock    ),
    .arcache           ( axi_m0_arcache   ),
    .arprot            ( axi_m0_arprot    ),
    .rready            ( axi_m0_rready    ),
    // Inputs
    .aclk              ( axi_clk          ),
    .aresetn           ( axi_rstn         ),
    .gclken            ( 1'b1             ),
    .mid               ( gen_m0_mid       ),
    .maddr             ( gen_m0_maddr     ),
    .mread             ( gen_m0_mread     ),
    .mwrite            ( gen_m0_mwrite    ),
    .mlock             ( gen_m0_mlock     ),
    .mlen              ( gen_m0_mlen      ),
    .msize             ( gen_m0_msize     ),
    .mburst            ( gen_m0_mburst    ),
    .mcache            ( gen_m0_mcache    ),
    .mprot             ( gen_m0_mprot     ),
    .mdata             ( gen_m0_mdata     ),
    .mwstrb            ( gen_m0_mwstrb    ),
    .mready            ( gen_m0_mready    ),
    .awready           ( axi_m0_awready   ),
    .wready            ( axi_m0_wready    ),
    .bid               ( axi_m0_bid       ),
    .bvalid            ( axi_m0_bvalid    ),
    .bresp             ( axi_m0_bresp     ),
    .arready           ( axi_m0_arready   ),
    .rid               ( axi_m0_rid       ),
    .rvalid            ( axi_m0_rvalid    ),
    .rlast             ( axi_m0_rlast     ),
    .rdata             ( axi_m0_rdata     ),
    .rresp             ( axi_m0_rresp     )
    );

endmodule
