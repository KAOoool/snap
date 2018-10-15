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

module h265enc_top_with_axi(
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
  // axi_m1          
  axi_m1_awid        , 
  axi_m1_awaddr      , 
  axi_m1_awlen       , 
  axi_m1_awsize      , 
  axi_m1_awburst     , 
  axi_m1_awcache     , 
  axi_m1_awlock      , 
  axi_m1_awprot      , 
  axi_m1_awvalid     , 
  axi_m1_awready     , 
  axi_m1_wdata       , 
  axi_m1_wstrb       , 
  axi_m1_wlast       , 
  axi_m1_wvalid      , 
  axi_m1_wready      , 
  axi_m1_bready      , 
  axi_m1_bid         , 
  axi_m1_bresp       , 
  axi_m1_bvalid      , 
  axi_m1_arid        , 
  axi_m1_araddr      , 
  axi_m1_arlen       , 
  axi_m1_arsize      , 
  axi_m1_arburst     , 
  axi_m1_arcache     , 
  axi_m1_arlock      , 
  axi_m1_arprot      , 
  axi_m1_arvalid     , 
  axi_m1_arready     , 
  axi_m1_rready      , 
  axi_m1_rid         , 
  axi_m1_rdata       , 
  axi_m1_rresp       , 
  axi_m1_rlast       , 
  axi_m1_rvalid      , 
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

  // axi_m1
  input                              axi_m1_arready ;
  input                              axi_m1_awready ;
  input  [AXI_SIDW-1        : 0]     axi_m1_bid     ;
  input  [1                 : 0]     axi_m1_bresp   ;
  input                              axi_m1_bvalid  ;
  input  [AXI_DW-1          : 0]     axi_m1_rdata   ;
  input  [AXI_SIDW-1        : 0]     axi_m1_rid     ;
  input                              axi_m1_rlast   ;
  input  [1                 : 0]     axi_m1_rresp   ;
  input                              axi_m1_rvalid  ;
  input                              axi_m1_wready  ;
  output [AXI_AW1-1         : 0]     axi_m1_araddr  ;
  output [1                 : 0]     axi_m1_arburst ;
  output [3                 : 0]     axi_m1_arcache ;
  output [AXI_SIDW-1        : 0]     axi_m1_arid    ;
  output [3                 : 0]     axi_m1_arlen   ;
  output [1                 : 0]     axi_m1_arlock  ;
  output [2                 : 0]     axi_m1_arprot  ;
  output [2                 : 0]     axi_m1_arsize  ;
  output                             axi_m1_arvalid ;
  output [AXI_AW1-1         : 0]     axi_m1_awaddr  ;
  output [1                 : 0]     axi_m1_awburst ;
  output [3                 : 0]     axi_m1_awcache ;
  output [AXI_SIDW-1        : 0]     axi_m1_awid    ;
  output [3                 : 0]     axi_m1_awlen   ;
  output [1                 : 0]     axi_m1_awlock  ;
  output [2                 : 0]     axi_m1_awprot  ;
  output [2                 : 0]     axi_m1_awsize  ;
  output                             axi_m1_awvalid ;
  output                             axi_m1_bready  ;
  output                             axi_m1_rready  ;
  output [AXI_DW-1          : 0]     axi_m1_wdata   ;
  output                             axi_m1_wlast   ;
  output [AXI_DW/8-1        : 0]     axi_m1_wstrb   ;
  output                             axi_m1_wvalid  ;


//*** WIRE DECLARATION *********************************************************

  // config
  wire                               sys_start      ;
  wire                               sys_done       ;
  wire   [`PIC_X_WIDTH-1    : 0]     sys_x_total    ;
  wire   [`PIC_Y_WIDTH-1    : 0]     sys_y_total    ;
  wire                               sys_mode       ;
  wire   [5                 : 0]     sys_qp         ;
  wire                               sys_type       ;
  wire                               pre_min_size   ;

  // ext_if
  wire   [1-1               : 0]     extif_start    ;
  wire   [1-1               : 0]     extif_done     ;
  wire   [5-1               : 0]     extif_mode     ;
  wire   [6+`PIC_X_WIDTH-1  : 0]     extif_x        ;
  wire   [6+`PIC_Y_WIDTH-1  : 0]     extif_y        ;
  wire   [8-1               : 0]     extif_width    ;
  wire   [8-1               : 0]     extif_height   ;
  wire                               extif_wr_ena   ;
  wire                               extif_rd_ena   ;
  wire   [16*`PIXEL_WIDTH-1 : 0]     extif_wr_dat   ;
  wire   [16*`PIXEL_WIDTH-1 : 0]     extif_rd_dat   ;

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

  // gen_m1 
  wire   [AXI_AW1-1         : 0]     gen_m1_maddr   ;
  wire   [1                 : 0]     gen_m1_mburst  ;
  wire   [3                 : 0]     gen_m1_mcache  ;
  wire   [AXI_DW-1          : 0]     gen_m1_mdata   ;
  wire   [AXI_MIDW-1        : 0]     gen_m1_mid     ;
  wire   [3                 : 0]     gen_m1_mlen    ;
  wire                               gen_m1_mlock   ;
  wire   [2                 : 0]     gen_m1_mprot   ;
  wire                               gen_m1_mread   ;
  wire                               gen_m1_mready  ;
  wire   [2                 : 0]     gen_m1_msize   ;
  wire                               gen_m1_mwrite  ;
  wire   [AXI_DW/8-1        : 0]     gen_m1_mwstrb  ;
  wire                               gen_m1_saccept ;
  wire   [AXI_DW-1          : 0]     gen_m1_sdata   ;
  wire   [AXI_MIDW-1        : 0]     gen_m1_sid     ;
  wire                               gen_m1_slast   ;
  wire   [2                 : 0]     gen_m1_sresp   ;
  wire                               gen_m1_svalid  ;


//*** MAIN BODY ****************************************************************

//*** H265CORE_IF ********************************

  h265enc_if h265enc_if(
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
    .sys_x_total_o     ( sys_x_total       ),
    .sys_y_total_o     ( sys_y_total       ),
    .sys_mode_o        ( sys_mode          ),
    .sys_qp_o          ( sys_qp            ),
    .sys_type_o        ( sys_type          ),
    .pre_min_size_o    ( pre_min_size      ),
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
    // gen_m1 
    .gen_m1_maddr      ( gen_m1_maddr      ),
    .gen_m1_mburst     ( gen_m1_mburst     ),
    .gen_m1_mcache     ( gen_m1_mcache     ),
    .gen_m1_mdata      ( gen_m1_mdata      ),
    .gen_m1_mid        ( gen_m1_mid        ),
    .gen_m1_mlen       ( gen_m1_mlen       ),
    .gen_m1_mlock      ( gen_m1_mlock      ),
    .gen_m1_mprot      ( gen_m1_mprot      ),
    .gen_m1_mread      ( gen_m1_mread      ),
    .gen_m1_mready     ( gen_m1_mready     ),
    .gen_m1_msize      ( gen_m1_msize      ),
    .gen_m1_mwrite     ( gen_m1_mwrite     ),
    .gen_m1_mwstrb     ( gen_m1_mwstrb     ),
    .gen_m1_saccept    ( gen_m1_saccept    ),
    .gen_m1_sdata      ( gen_m1_sdata      ),
    .gen_m1_sid        ( gen_m1_sid        ),
    .gen_m1_slast      ( gen_m1_slast      ),
    .gen_m1_sresp      ( gen_m1_sresp      ),
    .gen_m1_svalid     ( gen_m1_svalid     ),
    // ext
    .extif_start_i     ( extif_start       ),
    .extif_done_o      ( extif_done        ),
    .extif_mode_i      ( extif_mode        ),
    .extif_x_i         ( extif_x           ),
    .extif_y_i         ( extif_y           ),
    .extif_width_i     ( extif_width       ),
    .extif_height_i    ( extif_height      ),
    .extif_wren_o      ( extif_wr_ena      ),
    .extif_rden_o      ( extif_rd_ena      ),
    .extif_data_o      ( extif_wr_dat      ),
    .extif_data_i      ( extif_rd_dat      ),
	.i_action_type     ( 32'h00000001      ),
	.i_action_version  ( 32'h00000001      ),
    // bs
    .bs_val_i          ( bs_val            ),
    .bs_dat_i          ( bs_dat            )
    );

//*** H265CORE ***********************************

  h265enc_top h265enc_top(
    // global
    .clk               ( enc_clk           ),
    .rst_n             ( enc_rstn          ),
    // config
    .sys_start_i       ( sys_start         ),
    .sys_type_i        ( sys_type          ),
    .pre_min_size_i    ( pre_min_size      ),
    .sys_x_total_i     ( sys_x_total       ),
    .sys_y_total_i     ( sys_y_total       ),
    .sys_qp_i          ( sys_qp            ),
    .sys_done_o        ( sys_done          ),
    // ext
    .extif_start_o     ( extif_start       ),
    .extif_done_i      ( extif_done        ),
    .extif_mode_o      ( extif_mode        ),
    .extif_x_o         ( extif_x           ),
    .extif_y_o         ( extif_y           ),
    .extif_width_o     ( extif_width       ),
    .extif_height_o    ( extif_height      ),
    .extif_wren_i      ( extif_wr_ena      ),
    .extif_rden_i      ( extif_rd_ena      ),
    .extif_data_i      ( extif_wr_dat      ),
    .extif_data_o      ( extif_rd_dat      ),
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

  gm_1_DW_axi_gm gm_1_DW_axi_gm_0(
    // Outputs
    .saccept           ( gen_m1_saccept   ),
    .sid               ( gen_m1_sid       ),
    .svalid            ( gen_m1_svalid    ),
    .slast             ( gen_m1_slast     ),
    .sdata             ( gen_m1_sdata     ),
    .sresp             ( gen_m1_sresp     ),
    .awid              ( axi_m1_awid      ),
    .awvalid           ( axi_m1_awvalid   ),
    .awaddr            ( axi_m1_awaddr    ),
    .awlen             ( axi_m1_awlen     ),
    .awsize            ( axi_m1_awsize    ),
    .awburst           ( axi_m1_awburst   ),
    .awlock            ( axi_m1_awlock    ),
    .awcache           ( axi_m1_awcache   ),
    .awprot            ( axi_m1_awprot    ),
    .wid               (                  ),
    .wvalid            ( axi_m1_wvalid    ),
    .wlast             ( axi_m1_wlast     ),
    .wdata             ( axi_m1_wdata     ),
    .wstrb             ( axi_m1_wstrb     ),
    .bready            ( axi_m1_bready    ),
    .arid              ( axi_m1_arid      ),
    .arvalid           ( axi_m1_arvalid   ),
    .araddr            ( axi_m1_araddr    ),
    .arlen             ( axi_m1_arlen     ),
    .arsize            ( axi_m1_arsize    ),
    .arburst           ( axi_m1_arburst   ),
    .arlock            ( axi_m1_arlock    ),
    .arcache           ( axi_m1_arcache   ),
    .arprot            ( axi_m1_arprot    ),
    .rready            ( axi_m1_rready    ),
    // Inputs
    .aclk              ( axi_clk          ),
    .aresetn           ( axi_rstn         ),
    .gclken            ( 1'b1             ),
    .mid               ( gen_m1_mid       ),
    .maddr             ( gen_m1_maddr     ),
    .mread             ( gen_m1_mread     ),
    .mwrite            ( gen_m1_mwrite    ),
    .mlock             ( gen_m1_mlock     ),
    .mlen              ( gen_m1_mlen      ),
    .msize             ( gen_m1_msize     ),
    .mburst            ( gen_m1_mburst    ),
    .mcache            ( gen_m1_mcache    ),
    .mprot             ( gen_m1_mprot     ),
    .mdata             ( gen_m1_mdata     ),
    .mwstrb            ( gen_m1_mwstrb    ),
    .mready            ( gen_m1_mready    ),
    .awready           ( axi_m1_awready   ),
    .wready            ( axi_m1_wready    ),
    .bid               ( axi_m1_bid       ),
    .bvalid            ( axi_m1_bvalid    ),
    .bresp             ( axi_m1_bresp     ),
    .arready           ( axi_m1_arready   ),
    .rid               ( axi_m1_rid       ),
    .rvalid            ( axi_m1_rvalid    ),
    .rlast             ( axi_m1_rlast     ),
    .rdata             ( axi_m1_rdata     ),
    .rresp             ( axi_m1_rresp     )
    );

endmodule
