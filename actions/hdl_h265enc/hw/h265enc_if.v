//-------------------------------------------------------------------
//
//  COPYRIGHT (C) 2011, VIPcore Group, Fudan University
//
//  THIS FILE MAY NOT BE MODIFIED OR REDISTRIBUTED WITHOUT THE
//  EXPRESSED WRITTEN CONSENT OF VIPcore Group
//
//  VIPcore       : http://soc.fudan.edu.cn/vip
//  IP Owner      : Yibo FAN
//  Contact       : fanyibo@fudan.edu.cn
//
//-------------------------------------------------------------------
//
//  Filename      : h265core_if.v
//  Author        : Huang Lei Lei
//  Created       : 2015-09-12
//  Description   : interface for h265core
//
//-------------------------------------------------------------------
//
//  Modified      : 2015-09-17 by HLL
//  Description   : ref_luma & ref_chroma supported
//  Modified      : 2015-09-19 by HLL
//  Description   : load_db_luma, load_db_chroma, store_db_luma & store_db_chroma supported
//  Modified      : 2015-10-09 by HLL
//  Description   : burst transfer supported
//  Modified      : 2015-10-10 by HLL
//  Description   : apb if added
//  Modified      : 2015-11-11 by HLL
//  Description   : several control and status registers added
//  Modified      : 2018-04-19 by GCH
//  Description   : AXI_DW changed to 512
//  Modified      : 2018-05-14 by LYH
//  Description   : Change apb to axi_lite
//
//-------------------------------------------------------------------

`include "enc_defines.v"
`define XILINX

module h265enc_if(
  // global
  axi_clk           , //250MHz
  axi_rstn          ,
  enc_clk           , //125MHz
  enc_rstn          ,
  // axi_lite
  s_axi_awready     ,
  s_axi_awaddr      ,
  s_axi_awvalid     ,
  s_axi_wready      ,
  s_axi_wdata       ,
  s_axi_wstrb       ,
  s_axi_wvalid      ,
  s_axi_bresp       ,
  s_axi_bvalid      ,
  s_axi_bready      ,
  s_axi_arready     ,
  s_axi_arvalid     ,
  s_axi_araddr      ,
  s_axi_rdata       ,
  s_axi_rresp       ,
  s_axi_rready      ,
  s_axi_rvalid      ,
  // config
  sys_start_o       ,
  sys_done_i        ,
  sys_x_total_o     ,
  sys_y_total_o     ,
  sys_mode_o        ,
  sys_qp_o          ,
  sys_type_o        ,
  pre_min_size_o    ,
  // gen_m0
  gen_m0_maddr      ,
  gen_m0_mburst     ,
  gen_m0_mcache     ,
  gen_m0_mdata      ,
  gen_m0_mid        ,
  gen_m0_mlen       ,
  gen_m0_mlock      ,
  gen_m0_mprot      ,
  gen_m0_mread      ,
  gen_m0_mready     ,
  gen_m0_msize      ,
  gen_m0_mwrite     ,
  gen_m0_mwstrb     ,
  gen_m0_saccept    ,
  gen_m0_sdata      ,
  gen_m0_sid        ,
  gen_m0_slast      ,
  gen_m0_sresp      ,
  gen_m0_svalid     ,
  // gen_m1
  gen_m1_maddr      ,
  gen_m1_mburst     ,
  gen_m1_mcache     ,
  gen_m1_mdata      ,
  gen_m1_mid        ,
  gen_m1_mlen       ,
  gen_m1_mlock      ,
  gen_m1_mprot      ,
  gen_m1_mread      ,
  gen_m1_mready     ,
  gen_m1_msize      ,
  gen_m1_mwrite     ,
  gen_m1_mwstrb     ,
  gen_m1_saccept    ,
  gen_m1_sdata      ,
  gen_m1_sid        ,
  gen_m1_slast      ,
  gen_m1_sresp      ,
  gen_m1_svalid     ,
  // ext
  extif_start_i     ,
  extif_done_o      ,
  extif_mode_i      ,
  extif_x_i         ,
  extif_y_i         ,
  extif_width_i     ,
  extif_height_i    ,
  extif_wren_o      ,
  extif_rden_o      ,
  extif_data_o      ,
  extif_data_i      ,
  i_action_type     ,
  i_action_version  ,
  // bs
  bs_val_i          ,
  bs_dat_i
  );


//*** PARAMETER DECLARATION ****************************************************

  parameter    INTRA                = 0               ,
               INTER                = 1               ;
                                                     
  parameter    AXI_DW               = 512             ,
               AXI_AW0              = 64              ,
               AXI_AW1              = 32              ,
               AXI_MIDW             = 0               ;

  parameter    AXI_WID              = 0               ,
               AXI_RID              = 0               ;

  parameter    ADDR_SNAP_STATUS              = 0      ,
               ADDR_SNAP_INT_ENABLE          = 1      ,
               ADDR_SNAP_ACTION_TYPE         = 4      ,
               ADDR_SNAP_ACTION_VERSION      = 5      ,
               ADDR_SNAP_CONTEXT             = 8      ,
		       ADDR_START           = 13              ,
               ADDR_X_TOTAL         = 14              ,
               ADDR_Y_TOTAL         = 15              ,
               //ADDR_MODE            = 16              ,
               ADDR_QP              = 16              ,
               ADDR_TYPE            = 17              ,
               //ADDR_MIN_SIZE        = 18              ,
               ADDR_ORI_BASE_HIGH   = 18              ,
               ADDR_ORI_BASE_LOW    = 19              ,
               ADDR_REC_0_BASE      = 20              ,
               ADDR_REC_1_BASE      = 21              ,
               ADDR_COUNTER         = 22              ,
               ADDR_DONE            = 23              ,
               ADDR_BS_BASE_HIGH    = 24              ,
               ADDR_BS_BASE_LOW     = 25              ;

  parameter    LOAD_CUR_SUB         = 01              ,
               LOAD_REF_SUB         = 02              ,
               LOAD_CUR_LUMA        = 03              ,
               LOAD_REF_LUMA        = 04              , // width = 96
               LOAD_CUR_CHROMA      = 05              ,
               LOAD_REF_CHROMA      = 06              , // width = 96
               LOAD_DB_LUMA         = 07              ,
               LOAD_DB_CHROMA       = 08              ,
               STORE_DB_LUMA        = 09              ,
               STORE_DB_CHROMA      = 10              ;

  parameter    IDLE                 = 0               ,
               REQ                  = 1               ,
               WAIT                 = 2               ,
               DUMP                 = 3               ;

  parameter    ORI_BASE_ADDR        = (448*256*3/2)*0 ,
               REC_0_BASE_ADDR      = (448*256*3/2)*1 ,
               REC_1_BASE_ADDR      = (448*256*3/2)*2 ,
               BS_BASE_ADDR         = (448*256*3/2)*3 ;


//*** INPUT/OUTPUT DECLARATION *************************************************

  // global
  input                             axi_clk           ;
  input                             axi_rstn          ;
  input                             enc_clk           ;
  input                             enc_rstn          ;

  // axi_lite
  output                            s_axi_awready     ;
  input  [31                : 0]    s_axi_awaddr      ;
  input                             s_axi_awvalid     ;
  output                            s_axi_wready      ;
  input  [31                : 0]    s_axi_wdata       ;
  input  [3                 : 0]    s_axi_wstrb       ;
  input                             s_axi_wvalid      ;
  output [1                 : 0]    s_axi_bresp       ;
  output                            s_axi_bvalid      ;
  input                             s_axi_bready      ;
  output                            s_axi_arready     ;
  input  [31                : 0]    s_axi_araddr      ;
  input                             s_axi_arvalid     ;
  output [31                : 0]    s_axi_rdata       ;
  output [1                 : 0]    s_axi_rresp       ;
  output                            s_axi_rvalid      ;
  input                             s_axi_rready      ;

  // config
  output                            sys_start_o       ;
  input                             sys_done_i        ;
  output [`PIC_X_WIDTH-1    : 0]    sys_x_total_o     ;
  output [`PIC_Y_WIDTH-1    : 0]    sys_y_total_o     ;
  output                            sys_mode_o        ;
  output [5                 : 0]    sys_qp_o          ;
  output                            sys_type_o        ;
  output                            pre_min_size_o    ;

  // gen_m0 (cur pix & bs)
  output [AXI_AW0-1         : 0]    gen_m0_maddr      ;
  output [1                 : 0]    gen_m0_mburst     ;
  output [3                 : 0]    gen_m0_mcache     ;
  output [AXI_DW-1          : 0]    gen_m0_mdata      ;
  output [AXI_MIDW-1        : 0]    gen_m0_mid        ;
  output [3                 : 0]    gen_m0_mlen       ;
  output                            gen_m0_mlock      ;
  output [2                 : 0]    gen_m0_mprot      ;
  output                            gen_m0_mread      ;
  output                            gen_m0_mready     ;
  output [2                 : 0]    gen_m0_msize      ;
  output                            gen_m0_mwrite     ;
  output [AXI_DW/8-1        : 0]    gen_m0_mwstrb     ;
  input                             gen_m0_saccept    ;
  input  [AXI_DW-1          : 0]    gen_m0_sdata      ;
  input  [AXI_MIDW-1        : 0]    gen_m0_sid        ;
  input                             gen_m0_slast      ;
  input  [2                 : 0]    gen_m0_sresp      ;
  input                             gen_m0_svalid     ;

  // gen_m1 (ref pix)
  output [AXI_AW1-1         : 0]    gen_m1_maddr      ;
  output [1                 : 0]    gen_m1_mburst     ;
  output [3                 : 0]    gen_m1_mcache     ;
  output [AXI_DW-1          : 0]    gen_m1_mdata      ;
  output [AXI_MIDW-1        : 0]    gen_m1_mid        ;
  output [3                 : 0]    gen_m1_mlen       ;
  output                            gen_m1_mlock      ;
  output [2                 : 0]    gen_m1_mprot      ;
  output                            gen_m1_mread      ;
  output                            gen_m1_mready     ;
  output [2                 : 0]    gen_m1_msize      ;
  output                            gen_m1_mwrite     ;
  output [AXI_DW/8-1        : 0]    gen_m1_mwstrb     ;
  input                             gen_m1_saccept    ;
  input  [AXI_DW-1          : 0]    gen_m1_sdata      ;
  input  [AXI_MIDW-1        : 0]    gen_m1_sid        ;
  input                             gen_m1_slast      ;
  input  [2                 : 0]    gen_m1_sresp      ;
  input                             gen_m1_svalid     ;

  // ext_if
  input                             extif_start_i     ;
  output                            extif_done_o      ;
  input  [5-1               : 0]    extif_mode_i      ;
  input  [6+`PIC_X_WIDTH-1  : 0]    extif_x_i         ;
  input  [6+`PIC_Y_WIDTH-1  : 0]    extif_y_i         ;
  input  [8-1               : 0]    extif_width_i     ;
  input  [8-1               : 0]    extif_height_i    ;
  output                            extif_wren_o      ;
  output                            extif_rden_o      ;
  output [16*`PIXEL_WIDTH-1 : 0]    extif_data_o      ;
  input  [16*`PIXEL_WIDTH-1 : 0]    extif_data_i      ;

  // BS
  input                             bs_val_i          ;
  input  [7                 : 0]    bs_dat_i          ;

  input  [31                : 0]    i_action_type     ;
  input  [31                : 0]    i_action_version  ;


//*** WIRE/REG DECLARATION *****************************************************

  reg    [31                : 0]    s_axi_rdata       ;
  reg                               s_axi_rvalid      ;
  wire   [1                 : 0]    s_axi_rresp       ;
  wire   [1                 : 0]    s_axi_bresp       ;
  reg                               s_axi_bvalid      ;
  reg                               s_axi_arready     ;
  reg                               s_axi_awready     ;
  reg                               s_axi_wready      ;

  reg                               reg_start         ;
  reg    [`PIC_X_WIDTH-1    : 0]    reg_x_total       ;
  reg    [`PIC_Y_WIDTH-1    : 0]    reg_y_total       ;
  reg                               reg_mode          ;
  reg    [5                 : 0]    reg_qp            ;
  reg                               reg_type          ;
  reg                               reg_min_size      ;
  reg    [AXI_AW1-1         : 0]    reg_ori_base_high ;
  reg    [AXI_AW1-1         : 0]    reg_ori_base_low  ;
  wire   [AXI_AW0-1         : 0]    reg_ori_base      ;
  reg    [AXI_AW1-1         : 0]    reg_rec_0_base    ;
  reg    [AXI_AW1-1         : 0]    reg_rec_1_base    ;
  reg    [AXI_AW1-1         : 0]    reg_bs_base_high  ;
  reg    [AXI_AW1-1         : 0]    reg_bs_base_low   ;
  wire   [AXI_AW0-1         : 0]    reg_bs_base       ;
  reg                               reg_done          ;
  reg    [31                : 0]    reg_counter       ;

  reg                               reg_start_enc0    ;
  reg                               reg_start_enc1    ;
  reg                               reg_start_enc2    ; 
  reg                               reg_start_ack0    ;
  reg                               reg_start_ack1    ;
  wire                              sys_start_enc     ;

  wire                              fifo_rstn_loadpix ;
  wire   [AXI_DW-1          : 0]    data_in_loadpix   ;        
  wire                              pop_req_loadpix   ;        
  wire                              push_req_loadpix  ;
  wire   [16*`PIXEL_WIDTH-1 : 0]    data_out_loadpix  ;
  wire                              empty_loadpix     ;   
  reg    [2                 : 0]    pop_cnter         ;

  wire                              fifo_rstn_storepix;
  wire   [16*`PIXEL_WIDTH-1 : 0]    data_in_storepix  ;        
  wire                              pop_req_storepix  ;        
  wire                              push_req_storepix ;
  wire   [AXI_DW-1          : 0]    data_out_storepix ;
  wire                              empty_storepix    ;   

  wire                              fifo_rstn_bs      ;   
  wire                              pop_req_bs        ;        
  wire   [AXI_DW-1          : 0]    data_out_bs       ;
  wire                              empty_bs          ; 

  reg    [1                 : 0]    cur_state_0       ;
  reg    [1                 : 0]    nxt_state_0       ;
  reg    [AXI_AW0-1         : 0]    gen_m0_maddr      ;        
  reg                               gen_m0_mread      ;  
  reg    [6                 : 0]    addr_offset_x_0   ;
  reg    [6                 : 0]    addr_offset_y_0   ;
  reg    [AXI_AW0-1         : 0]    addr_offset_bs    ;
  wire                              bs_dump_done_w    ;

  reg    [1                 : 0]    cur_state_1       ;
  reg    [1                 : 0]    nxt_state_1       ;
  reg    [AXI_AW1-1         : 0]    gen_m1_maddr      ;        
  reg                               gen_m1_mread      ;  
  reg                               gen_m1_mwrite     ;  
  reg    [3                 : 0]    gen_m1_mlen       ;
  reg    [6                 : 0]    addr_offset_x_1   ;
  reg    [6                 : 0]    addr_offset_y_1   ;

  reg                               req_done_w        ;
  reg    [15                : 0]    rden_cnter_thre   ;
  reg    [15                : 0]    rden_cnter        ;
  reg    [15                : 0]    wren_cnter        ;
  reg    [15                : 0]    store_cnter       ;
  reg                               store_done_w      ;
  reg                               store_done_axi    ;
  reg                               store_done_enc0   ;
  reg                               store_done_enc1   ;
  reg                               store_done_enc2   ;
  reg                               store_done_ack0   ;
  reg                               store_done_ack1   ;
  wire                              store_done_enc    ;
  reg                               extif_done_w      ;
  reg                               extif_done_axi0   ;
  reg                               extif_done_axi1   ;
  reg                               extif_done_axi2   ; 
  wire                              extif_done_axi    ;

  reg                               extif_done_o      ;
  wire                              extif_mode_cur    ;
  reg                               extif_start_axi0  ;
  reg                               extif_start_axi1  ;
  reg                               extif_start_axi2  ;
  wire                              extif_start_axi   ;

  reg                               sys_done_r        ;
  reg                               bs_valid_extra    ;
  reg    [5                 : 0]    bs_valid_cnter    ;
  reg                               sys_done_0        ;
  reg                               sys_done_1        ;

//*** MAIN ****************************************************************

  // config
  assign sys_x_total_o  = reg_x_total  ;
  assign sys_y_total_o  = reg_y_total  ;
  assign sys_mode_o     = reg_mode     ;
  assign sys_qp_o       = reg_qp       ;
  assign sys_type_o     = reg_type     ;
  assign pre_min_size_o = reg_min_size ;

  // axi_lite
  // to reg_start 
  //--- CDC SYN start ---
  always @(posedge axi_clk or negedge axi_rstn) begin
    if( !axi_rstn )
      reg_start <= 0 ;
    else if( s_axi_wvalid && s_axi_wready && (s_axi_awaddr[6:2]==ADDR_START) && s_axi_wdata[0] )
      reg_start <= 1'b1 ;
    else if (reg_start_ack1)
      reg_start <= 1'b0 ;
  end

  always @(posedge enc_clk or negedge enc_rstn) begin
    if(!enc_rstn) begin
      reg_start_enc0 <= 0;
      reg_start_enc1 <= 0;
      reg_start_enc2 <= 0;
    end 
    else begin
      reg_start_enc0 <= reg_start     ;
      reg_start_enc1 <= reg_start_enc0;
      reg_start_enc2 <= reg_start_enc1;
    end
  end

  always @(posedge axi_clk or negedge axi_rstn) begin
    if(!axi_rstn) begin
      reg_start_ack0 <= 0;
      reg_start_ack1 <= 0;
    end 
    else begin
      reg_start_ack0 <= reg_start_enc1;
      reg_start_ack1 <= reg_start_ack0;
    end
  end

  assign sys_start_enc = reg_start_enc1 & (~reg_start_enc2) ;
  assign sys_start_o   = sys_start_enc                      ;
  //--- CDC SYN end ---

  // to other register
  always @(posedge axi_clk or negedge axi_rstn) begin
    if( !axi_rstn ) begin
                          reg_x_total        <= 6 ;
                          reg_y_total        <= 3 ;
                          reg_mode           <= 0 ;
                          reg_qp             <= 0 ;
                          reg_type           <= 0 ;
                          reg_min_size       <= 1 ;
                          reg_ori_base_low   <= ORI_BASE_ADDR   ;
                          reg_ori_base_high  <= 0 ;
                          reg_rec_0_base     <= REC_0_BASE_ADDR ;
                          reg_rec_1_base     <= REC_1_BASE_ADDR ;
                          reg_bs_base_low    <= BS_BASE_ADDR    ;
                          reg_bs_base_high   <= 0 ;
    end
    else if(s_axi_awvalid & s_axi_awready) begin
      case(s_axi_awaddr[6:2])
        ADDR_X_TOTAL        : reg_x_total        <= s_axi_wdata ;
        ADDR_Y_TOTAL        : reg_y_total        <= s_axi_wdata ;
        //ADDR_MODE       : reg_mode       <= s_axi_wdata ;
        ADDR_QP             : reg_qp             <= s_axi_wdata ;
        ADDR_TYPE           : reg_type           <= s_axi_wdata ;
        //ADDR_MIN_SIZE   : reg_min_size   <= s_axi_wdata ;
        ADDR_ORI_BASE_HIGH  : reg_ori_base_high  <= s_axi_wdata ;
        ADDR_ORI_BASE_LOW   : reg_ori_base_low   <= s_axi_wdata ;
        ADDR_REC_0_BASE     : reg_rec_0_base     <= s_axi_wdata ;
        ADDR_REC_1_BASE     : reg_rec_1_base     <= s_axi_wdata ;
        ADDR_BS_BASE_HIGH   : reg_bs_base_high   <= s_axi_wdata ;
        ADDR_BS_BASE_LOW    : reg_bs_base_low    <= s_axi_wdata ;
      endcase
    end
  end

  assign reg_ori_base = {reg_ori_base_high,reg_ori_base_low};
  assign reg_bs_base  = {reg_bs_base_high,reg_bs_base_low};

  always @(*) begin
                        s_axi_rdata = 0              ;
    case( s_axi_araddr[6:2] )
	  ADDR_SNAP_STATUS          : s_axi_rdata = 32'd0           ;
	  ADDR_SNAP_INT_ENABLE      : s_axi_rdata = 32'd0           ;
	  ADDR_SNAP_ACTION_TYPE     : s_axi_rdata = i_action_type   ;
	  ADDR_SNAP_ACTION_VERSION  : s_axi_rdata = i_action_version;
	  ADDR_SNAP_CONTEXT         : s_axi_rdata = 32'd0           ;
      ADDR_X_TOTAL              : s_axi_rdata = reg_x_total     ;
      ADDR_Y_TOTAL              : s_axi_rdata = reg_y_total     ;
      //ADDR_MODE       : s_axi_rdata = reg_mode       ;
      ADDR_QP                   : s_axi_rdata = reg_qp          ;
      ADDR_TYPE                 : s_axi_rdata = reg_type        ;
      //ADDR_MIN_SIZE   : s_axi_rdata = reg_min_size   ;
      ADDR_ORI_BASE_HIGH        : s_axi_rdata = reg_ori_base_high;
      ADDR_ORI_BASE_LOW         : s_axi_rdata = reg_ori_base_low;
      ADDR_REC_0_BASE           : s_axi_rdata = reg_rec_0_base  ;
      ADDR_REC_1_BASE           : s_axi_rdata = reg_rec_1_base  ;
      ADDR_BS_BASE_HIGH         : s_axi_rdata = reg_bs_base_high;
      ADDR_BS_BASE_LOW          : s_axi_rdata = reg_bs_base_low ;
      ADDR_DONE                 : s_axi_rdata = reg_done        ;
      ADDR_COUNTER              : s_axi_rdata = reg_counter     ;
    endcase
  end

  assign s_axi_bresp = 2'b00;
  assign s_axi_rresp = 2'b00;

  always @(posedge axi_clk or negedge axi_rstn)
    if( !axi_rstn )
	  s_axi_bvalid <= 1'b0;
	else if(s_axi_wvalid & s_axi_wready)
	  s_axi_bvalid <= 1'b1;
	else if(s_axi_bready)
	  s_axi_bvalid <= 1'b0;

  always @(posedge axi_clk or negedge axi_rstn)
    if( !axi_rstn )
	  s_axi_rvalid <= 1'b0;
	else if(s_axi_arvalid & s_axi_arready)
	  s_axi_rvalid <= 1'b1;
	else if(s_axi_rready)
	  s_axi_rvalid <= 1'b0;

  always @(posedge axi_clk or negedge axi_rstn)
    if( !axi_rstn )
	  s_axi_arready <= 1'b1;
	else if(s_axi_arvalid)
	  s_axi_arready <= 1'b0;
	else if(s_axi_rvalid & s_axi_rready)
	  s_axi_arready <= 1'b1;

  always @(posedge axi_clk or negedge axi_rstn)
    if( !axi_rstn )
	  s_axi_awready <= 1'b0;
	else if(s_axi_awvalid)
	  s_axi_awready <= 1'b1;
	else if(s_axi_wvalid & s_axi_wready)
	  s_axi_awready <= 1'b0;

  always @(posedge axi_clk or negedge axi_rstn)
    if( !axi_rstn )
	  s_axi_wready <= 1'b0;
	else if(s_axi_awvalid & s_axi_awready)
	  s_axi_wready <= 1'b1;
	else if(s_axi_wvalid)
	  s_axi_wready <= 1'b0;

//*** FIFOs ****************************************************************

  // pixel load
  `ifdef ALTERA
    assign data_in_loadpix = extif_mode_cur ? gen_m0_sdata : gen_m1_sdata ;
    fifo_loadpix fifo_loadpix  
      .aclr             ( fifo_rstn_loadpix  ),
      .data             ( data_in_loadpix    ),
      .rdclk            ( enc_clk            ),
      .rdreq            ( pop_req_loadpix    ),
      .wrclk            ( axi_clk            ),
      .wrreq            ( push_req_loadpix   ),
      .q                ( data_out_loadpix   ),
      .rdempty          ( empty_loadpix      )
      );   
  `endif
  `ifdef XILINX
    wire [AXI_DW-1          : 0] data_in_loadpix_w;
    assign data_in_loadpix_w = extif_mode_cur ? gen_m0_sdata : gen_m1_sdata ;
    assign data_in_loadpix   = {data_in_loadpix_w[127:  0],data_in_loadpix_w[255:128],data_in_loadpix_w[383:256],data_in_loadpix_w[511:384]} ; 
    fifo_512_128 fifo_loadpix(
      .rst              ( fifo_rstn_loadpix  ),
      .wr_clk           ( axi_clk            ),
      .rd_clk           ( enc_clk            ),
      .din              ( data_in_loadpix    ),
      .wr_en            ( push_req_loadpix   ),
      .rd_en            ( pop_req_loadpix    ),
      .dout             ( data_out_loadpix   ),
      .empty            ( empty_loadpix      )
      );
  `endif

    assign fifo_rstn_loadpix = extif_done_w || !axi_rstn;
    assign push_req_loadpix  = extif_mode_cur ? (gen_m0_svalid & (gen_m0_sresp==0)) : (gen_m1_svalid & (gen_m1_sresp==0)) ;
    assign pop_req_loadpix   = !empty_loadpix ;


    always @(posedge enc_clk or negedge enc_rstn)
      if(!enc_rstn) begin
        pop_cnter <= 0;
      end 
      else begin
        if (extif_start_i) begin
          pop_cnter <= 3'd0;
        end
        else begin
          if ((extif_mode_i == LOAD_REF_LUMA || extif_mode_i == LOAD_REF_CHROMA) && pop_req_loadpix) begin
            if (pop_cnter == 3'd5)
              pop_cnter <= 3'd0;
            else
              pop_cnter <= pop_cnter + 3'd1;
          end
        end
      end

  // pixel store
  `ifdef ALTERA
    fifo_storepix fifo_storepix  
      .aclr             ( fifo_rstn_storepix  ),
      .data             ( data_in_storepix    ),
      .rdclk            ( enc_clk             ),
      .rdreq            ( pop_req_storepix    ),
      .wrclk            ( axi_clk             ),
      .wrreq            ( push_req_storepix   ),
      .q                ( data_out_storepix   ),
      .rdempty          ( empty_storepix      )
      );   
  `endif
  `ifdef XILINX
    wire [AXI_DW-1          : 0] data_out_storepix_w;
    assign data_out_storepix = {
                                data_out_storepix_w[127:  0],
                                data_out_storepix_w[255:128],
                                data_out_storepix_w[383:256],
                                data_out_storepix_w[511:384]
                               };
    fifo_128_512 fifo_storepix(
      .rst              ( fifo_rstn_storepix  ),
      .wr_clk           ( axi_clk             ),
      .rd_clk           ( enc_clk             ),
      .din              ( data_in_storepix    ),
      .wr_en            ( push_req_storepix   ),
      .rd_en            ( pop_req_storepix    ),
      .dout             ( data_out_storepix_w ),
      .empty            ( empty_storepix      )
      );
  `endif

  assign fifo_rstn_storepix = extif_done_w || !axi_rstn;
  assign push_req_storepix = (cur_state_1 == REQ) && (rden_cnter <= rden_cnter_thre) && ((extif_mode_i==STORE_DB_LUMA)||(extif_mode_i==STORE_DB_CHROMA));
  assign pop_req_storepix  = gen_m1_mwrite & gen_m1_saccept ;
  assign data_in_storepix  = { extif_data_i[007:000]
                              ,extif_data_i[015:008]
                              ,extif_data_i[023:016]
                              ,extif_data_i[031:024]
                              ,extif_data_i[039:032]
                              ,extif_data_i[047:040]
                              ,extif_data_i[055:048]
                              ,extif_data_i[063:056]
                              ,extif_data_i[071:064]
                              ,extif_data_i[079:072]
                              ,extif_data_i[087:080]
                              ,extif_data_i[095:088]
                              ,extif_data_i[103:096]
                              ,extif_data_i[111:104]
                              ,extif_data_i[119:112]
                              ,extif_data_i[127:120]
                             };
  
  // bs
  `ifdef ALTERA
    fifo_bs fifo_bs(  
      .aclr             ( fifo_rstn_bs              ),
      .data             ( bs_dat_i                  ),
      .rdclk            ( enc_clk                   ),
      .rdreq            ( pop_req_bs                ),
      .wrclk            ( axi_clk                   ),
      .wrreq            ( bs_val_i | bs_valid_extra ),
      .q                ( data_out_bs               ),
      .rdempty          ( empty_bs                  )
      );   
  `endif
  `ifdef XILINX
    wire [AXI_DW-1          : 0] data_out_bs_w;
    assign data_out_bs = {
                          data_out_bs_w[  7:  0],data_out_bs_w[ 15:  8],data_out_bs_w[ 23: 16],data_out_bs_w[ 31: 24],data_out_bs_w[ 39: 32],data_out_bs_w[ 47: 40],data_out_bs_w[ 55: 48],data_out_bs_w[ 63: 56],
                          data_out_bs_w[ 71: 64],data_out_bs_w[ 79: 72],data_out_bs_w[ 87: 80],data_out_bs_w[ 95: 88],data_out_bs_w[103: 96],data_out_bs_w[111:104],data_out_bs_w[119:112],data_out_bs_w[127:120],
                          data_out_bs_w[135:128],data_out_bs_w[143:136],data_out_bs_w[151:144],data_out_bs_w[159:152],data_out_bs_w[167:160],data_out_bs_w[175:168],data_out_bs_w[183:176],data_out_bs_w[191:184],
                          data_out_bs_w[199:192],data_out_bs_w[207:200],data_out_bs_w[215:208],data_out_bs_w[223:216],data_out_bs_w[231:224],data_out_bs_w[239:232],data_out_bs_w[247:240],data_out_bs_w[255:248],
                          data_out_bs_w[263:256],data_out_bs_w[271:264],data_out_bs_w[279:272],data_out_bs_w[287:280],data_out_bs_w[295:288],data_out_bs_w[303:296],data_out_bs_w[311:304],data_out_bs_w[319:312],
                          data_out_bs_w[327:320],data_out_bs_w[335:328],data_out_bs_w[343:336],data_out_bs_w[351:344],data_out_bs_w[359:352],data_out_bs_w[367:360],data_out_bs_w[375:368],data_out_bs_w[383:376],
                          data_out_bs_w[391:384],data_out_bs_w[399:392],data_out_bs_w[407:400],data_out_bs_w[415:408],data_out_bs_w[423:416],data_out_bs_w[431:424],data_out_bs_w[439:432],data_out_bs_w[447:440],
                          data_out_bs_w[455:448],data_out_bs_w[463:456],data_out_bs_w[471:464],data_out_bs_w[479:472],data_out_bs_w[487:480],data_out_bs_w[495:488],data_out_bs_w[503:496],data_out_bs_w[511:504]
                         };
    fifo_8_512 fifo_bs(
      .rst              ( fifo_rstn_bs              ),
      .wr_clk           ( axi_clk                   ),
      .rd_clk           ( enc_clk                   ),
      .din              ( bs_dat_i                  ),
      .wr_en            ( bs_val_i | bs_valid_extra ),
      .rd_en            ( pop_req_bs                ),
      .dout             ( data_out_bs_w             ),
      .empty            ( empty_bs                  )
      );
  `endif

  assign fifo_rstn_bs = reg_done && !axi_rstn ;

//*** gm0 ****************************************************************

  always @(posedge axi_clk or negedge axi_rstn ) begin
    if( !axi_rstn )
      cur_state_0 <= 0 ;
    else begin
      cur_state_0 <= nxt_state_0 ;
    end
  end

  always @(*) begin
    nxt_state_0 = IDLE;
    case( cur_state_0 )
      IDLE :  if( !empty_bs ) begin 
                nxt_state_0 = DUMP; 
              end
              else begin 
                if ( extif_start_axi && extif_mode_cur )
                  nxt_state_0 = REQ  ;
                else                    
                  nxt_state_0 = IDLE ;
              end
      REQ  :  if( req_done_w )
                if( extif_done_axi )    
                  nxt_state_0 = IDLE ;
                else                  
                  nxt_state_0 = WAIT ;
              else                    
                nxt_state_0 = REQ  ;
      WAIT :  if( extif_done_axi )      
                nxt_state_0 = IDLE ;
              else                    
                nxt_state_0 = WAIT ;
      DUMP :  if ( bs_dump_done_w )
                nxt_state_0 = IDLE ;
              else
                nxt_state_0 = DUMP ;
    endcase
  end

  assign gen_m0_mburst   = 2'b01                   ;
  assign gen_m0_mcache   = 4'b0000                 ;
  assign gen_m0_mid      = AXI_RID                 ;
  assign gen_m0_mlock    = 0                       ;
  assign gen_m0_mprot    = 3'b000                  ;
  assign gen_m0_mready   = 1                       ;
  assign gen_m0_msize    = 3'b110                  ;
  assign gen_m0_mlen     = 0                       ;
  assign gen_m0_mwstrb   = 64'hffff_ffff_ffff_ffff ;
  assign gen_m0_mdata    = data_out_bs             ;

  always @(*) begin
                          gen_m0_maddr = 0 ;
    if( cur_state_0==REQ ) begin
      case( extif_mode_i )
        LOAD_CUR_LUMA   : gen_m0_maddr = reg_ori_base + (extif_y_i*64  +addr_offset_y_0)*(sys_x_total_o+1)*64+extif_x_i*64+addr_offset_x_0 ;
        LOAD_CUR_CHROMA : gen_m0_maddr = reg_ori_base + (extif_y_i*64/2+addr_offset_y_0)*(sys_x_total_o+1)*64+extif_x_i*64+addr_offset_x_0 + (sys_x_total_o+1)*64*(sys_y_total_o+1)*64 ;
      endcase
    end
    else begin
      if( cur_state_0==DUMP )
        gen_m0_maddr = reg_bs_base + addr_offset_bs ;
    end
  end

  always @(*) begin
                          gen_m0_mread = 0 ;
    if( cur_state_0==REQ ) begin
      case( extif_mode_i )
        LOAD_CUR_LUMA   : gen_m0_mread = 1 && (extif_height_i!=0) ;
        LOAD_CUR_CHROMA : gen_m0_mread = 1 && (extif_height_i!=0) ;
      endcase
    end
  end

  assign gen_m0_mwrite = (cur_state_0==DUMP) && !empty_bs ;

  always @(posedge axi_clk or negedge axi_rstn ) begin
    if( !axi_rstn ) begin
      addr_offset_x_0 <= 0 ;
      addr_offset_y_0 <= 0 ;
    end
    else if( extif_start_axi ) begin
      addr_offset_x_0 <= 0 ;
      addr_offset_y_0 <= 0 ;
    end
    else if( gen_m0_mread & gen_m0_saccept ) begin
      case ( extif_mode_i )
        LOAD_CUR_LUMA   : if( addr_offset_x_0==extif_width_i-64*(gen_m0_mlen+1) ) begin
                            addr_offset_x_0 <= 0 ;
                            addr_offset_y_0 <= addr_offset_y_0 + 1 ;
                          end
                          else begin
                            addr_offset_x_0 <= addr_offset_x_0+64*(gen_m0_mlen+1) ;
                          end
        LOAD_CUR_CHROMA : if( addr_offset_x_0==extif_width_i-64*(gen_m0_mlen+1) ) begin
                            addr_offset_x_0 <= 0 ;
                            addr_offset_y_0 <= addr_offset_y_0 + 1 ;
                          end
                          else begin
                            addr_offset_x_0 <= addr_offset_x_0+64*(gen_m0_mlen+1) ;
                          end
      endcase
    end
  end

  always @(posedge axi_clk or negedge axi_rstn) begin
    if( !axi_rstn ) begin
      addr_offset_bs <= 0;
    end 
    else begin
      if ( reg_start )
        addr_offset_bs <= 0;
      else 
        if ( pop_req_bs )
          addr_offset_bs <= addr_offset_bs + 64*(gen_m0_mlen+1);
    end
  end

  assign pop_req_bs     = gen_m0_mwrite & gen_m0_saccept ;

  assign bs_dump_done_w = pop_req_bs;

//*** gm1 ****************************************************************

  always @(posedge axi_clk or negedge axi_rstn ) begin
    if( !axi_rstn )
      cur_state_1 <= 0 ;
    else begin
      cur_state_1 <= nxt_state_1 ;
    end
  end

  always @(*) begin
                nxt_state_1 = IDLE;
    case( cur_state_1 )
      IDLE :  if( extif_start_axi && !extif_mode_cur )     
                nxt_state_1 = REQ  ;
              else                    
                nxt_state_1 = IDLE ;
      REQ  :  if( req_done_w )
                if( extif_done_axi )    
                  nxt_state_1 = IDLE ;
                else                  
                  nxt_state_1 = WAIT ;
              else                    
                nxt_state_1 = REQ  ;
      WAIT :  if( extif_done_axi )      
                nxt_state_1 = IDLE ;
              else                    
                nxt_state_1 = WAIT ;
    endcase
  end

  assign gen_m1_mburst   = 2'b01                   ;
  assign gen_m1_mcache   = 4'b0000                 ;
  assign gen_m1_mid      = AXI_RID                 ;
  assign gen_m1_mlock    = 0                       ;
  assign gen_m1_mprot    = 3'b000                  ;
  assign gen_m1_mready   = 1                       ;
  assign gen_m1_msize    = 3'b110                  ;
  assign gen_m1_mwstrb   = 64'hffff_ffff_ffff_ffff ;

  assign gen_m1_mdata    = data_out_storepix       ;

  always @(*) begin
                          gen_m1_maddr = 0 ;
    if( cur_state_0==REQ ) begin
      case( extif_mode_i )
        LOAD_REF_LUMA   : gen_m1_maddr = reg_rec_0_base + (extif_y_i*01  +addr_offset_y_1)*(sys_x_total_o+1)*64+extif_x_i*01+addr_offset_x_1 ;
        LOAD_REF_CHROMA : gen_m1_maddr = reg_rec_0_base + (extif_y_i*01/2+addr_offset_y_1)*(sys_x_total_o+1)*64+extif_x_i*01+addr_offset_x_1 + (sys_x_total_o+1)*64*(sys_y_total_o+1)*64 ;
        LOAD_DB_LUMA    : gen_m1_maddr = reg_rec_1_base + (extif_y_i*01  +addr_offset_y_1)*(sys_x_total_o+1)*64+extif_x_i*01+addr_offset_x_1 ;
        LOAD_DB_CHROMA  : gen_m1_maddr = reg_rec_1_base + (extif_y_i*01/2+addr_offset_y_1)*(sys_x_total_o+1)*64+extif_x_i*01+addr_offset_x_1 + (sys_x_total_o+1)*64*(sys_y_total_o+1)*64 ;
        STORE_DB_LUMA   : gen_m1_maddr = reg_rec_1_base + (extif_y_i*01  +addr_offset_y_1)*(sys_x_total_o+1)*64+extif_x_i*01+addr_offset_x_1 ;
        STORE_DB_CHROMA : gen_m1_maddr = reg_rec_1_base + (extif_y_i*01/2+addr_offset_y_1)*(sys_x_total_o+1)*64+extif_x_i*01+addr_offset_x_1 + (sys_x_total_o+1)*64*(sys_y_total_o+1)*64 ;
      endcase
    end
  end

  always @(*) begin
                          gen_m1_mread  = 0 ;
                          gen_m1_mwrite = 0 ;
    if( cur_state_1==REQ ) begin
      case( extif_mode_i )
        LOAD_REF_LUMA   : gen_m1_mread  = 1 & (extif_height_i!=0)                   ;
        LOAD_REF_CHROMA : gen_m1_mread  = 1 & (extif_height_i!=0)                   ;
        LOAD_DB_LUMA    : gen_m1_mread  = 1 & (extif_height_i!=0)                   ;
        LOAD_DB_CHROMA  : gen_m1_mread  = 1 & (extif_height_i!=0)                   ;
        STORE_DB_LUMA   : gen_m1_mwrite = 1 & (extif_height_i!=0) & !empty_storepix ;
        STORE_DB_CHROMA : gen_m1_mwrite = 1 & (extif_height_i!=0) & !empty_storepix ;
      endcase
    end
  end


  always @(*) begin
                            gen_m1_mlen = 0 ;
    if (cur_state_1==REQ) begin                       
      case( extif_mode_i )  
        LOAD_REF_SUB    :   gen_m1_mlen = 0 ;
        LOAD_REF_LUMA   :   gen_m1_mlen = 1 ;    // 128 - 32(discard) = 96 pixels 
        LOAD_REF_CHROMA :   gen_m1_mlen = 1 ;    // 128 - 32(discard) = 96 pixels 
        LOAD_DB_LUMA    :   gen_m1_mlen = 0 ;    // 64 pixels
        LOAD_DB_CHROMA  :   gen_m1_mlen = 0 ;    // 64 pixels
        STORE_DB_LUMA   :   gen_m1_mlen = 0 ;    // 64 pixels
        STORE_DB_CHROMA :   gen_m1_mlen = 0 ;    // 64 pixels
      endcase
    end
  end  

  always @(posedge axi_clk or negedge axi_rstn ) begin
    if( !axi_rstn ) begin
      addr_offset_x_1 <= 0 ;
      addr_offset_y_1 <= 0 ;
    end
    else if( extif_start_axi ) begin
      addr_offset_x_1 <= 0 ;
      addr_offset_y_1 <= 0 ;
    end
    else if( (gen_m1_mread|gen_m1_mwrite ) & gen_m1_saccept ) begin
      case ( extif_mode_i )
        LOAD_REF_LUMA   : if( addr_offset_x_1==extif_width_i-64*(gen_m1_mlen+1)+32 ) begin //+32 -> discard 32 pixels
                            addr_offset_x_1 <= 0 ;
                            addr_offset_y_1 <= addr_offset_y_1 + 1 ;
                          end
                          else begin
                            addr_offset_x_1 <= addr_offset_x_1+64*(gen_m1_mlen+1) ;
                          end
        LOAD_REF_CHROMA : if( addr_offset_x_1==extif_width_i-64*(gen_m1_mlen+1)+32 ) begin //+32 -> discard 32 pixels
                            addr_offset_x_1 <= 0 ;
                            addr_offset_y_1 <= addr_offset_y_1 + 1 ;
                          end
                          else begin
                            addr_offset_x_1 <= addr_offset_x_1+64*(gen_m1_mlen+1) ;
                          end
        LOAD_DB_LUMA    : if( addr_offset_x_1==extif_width_i-64*(gen_m1_mlen+1) ) begin
                            addr_offset_x_1 <= 0 ;
                            addr_offset_y_1 <= addr_offset_y_1 + 1 ;
                          end
                          else begin
                            addr_offset_x_1 <= addr_offset_x_1+64*(gen_m1_mlen+1) ;
                          end
        LOAD_DB_CHROMA  : if( addr_offset_x_1==extif_width_i-64*(gen_m1_mlen+1) ) begin
                            addr_offset_x_1 <= 0 ;
                            addr_offset_y_1 <= addr_offset_y_1 + 1 ;
                          end
                          else begin
                            addr_offset_x_1 <= addr_offset_x_1+64*(gen_m1_mlen+1) ;
                          end
        STORE_DB_LUMA   : if( addr_offset_x_1==extif_width_i-64 ) begin
                            addr_offset_x_1 <= 0 ;
                            addr_offset_y_1 <= addr_offset_y_1 + 1 ;
                          end
                          else begin
                            addr_offset_x_1 <= addr_offset_x_1+64 ;
                          end
        STORE_DB_CHROMA : if( addr_offset_x_1==extif_width_i-64 ) begin
                            addr_offset_x_1 <= 0 ;
                            addr_offset_y_1 <= addr_offset_y_1 + 1 ;
                          end
                          else begin
                            addr_offset_x_1 <= addr_offset_x_1+64 ;
                          end
      endcase
    end
  end

//*** general ****************************************************************

  always @(*) begin
                        req_done_w = 0 ;
    case( extif_mode_i )
      LOAD_CUR_SUB    : req_done_w = 1 ;
      LOAD_REF_SUB    : req_done_w = 1 ;
      LOAD_CUR_LUMA   : req_done_w = ( gen_m0_saccept & (addr_offset_x_0==extif_width_i-64*(gen_m0_mlen+1)   ) & (addr_offset_y_0==extif_height_i-1)   ) | (extif_height_i==0) ;
      LOAD_REF_LUMA   : req_done_w = ( gen_m1_saccept & (addr_offset_x_1==extif_width_i-64*(gen_m1_mlen+1)+32) & (addr_offset_y_1==extif_height_i-1)   ) | (extif_height_i==0) ;
      LOAD_CUR_CHROMA : req_done_w = ( gen_m0_saccept & (addr_offset_x_0==extif_width_i-64*(gen_m0_mlen+1)   ) & (addr_offset_y_0==extif_height_i/2-1) ) | (extif_height_i==0) ;
      LOAD_REF_CHROMA : req_done_w = ( gen_m1_saccept & (addr_offset_x_1==extif_width_i-64*(gen_m1_mlen+1)+32) & (addr_offset_y_1==extif_height_i/2-1) ) | (extif_height_i==0) ;
      LOAD_DB_LUMA    : req_done_w = ( gen_m1_saccept & (addr_offset_x_1==extif_width_i-64*(gen_m1_mlen+1)   ) & (addr_offset_y_1==extif_height_i-1)   ) | (extif_height_i==0) ;
      LOAD_DB_CHROMA  : req_done_w = ( gen_m1_saccept & (addr_offset_x_1==extif_width_i-64*(gen_m1_mlen+1)   ) & (addr_offset_y_1==extif_height_i/2-1) ) | (extif_height_i==0) ;
      STORE_DB_LUMA   : req_done_w = ( gen_m1_saccept & (store_cnter==extif_width_i*extif_height_i  -64)                                               ) | (extif_height_i==0) ;
      STORE_DB_CHROMA : req_done_w = ( gen_m1_saccept & (store_cnter==extif_width_i*extif_height_i/2-64)                                               ) | (extif_height_i==0) ;
    endcase
  end

  always @(*) begin
    rden_cnter_thre = 0;
    case( extif_mode_i )
      STORE_DB_LUMA   : rden_cnter_thre = extif_width_i*extif_height_i  -16;
      STORE_DB_CHROMA : rden_cnter_thre = extif_width_i*extif_height_i/2-16;
    endcase    
  end

  always @(posedge enc_clk or negedge enc_rstn) begin
    if( !enc_rstn ) begin
      rden_cnter <= 0;
    end 
    else begin
      if ( extif_start_i )
        rden_cnter <= 0;
      else 
        if ( push_req_storepix ) 
          rden_cnter <= rden_cnter + 16;
    end
  end

  always @(posedge enc_clk or negedge enc_rstn ) begin
    if( !enc_rstn )
      wren_cnter <= 0 ;
    else if( extif_start_i )
      wren_cnter <= 0 ;
    else begin
      case ( extif_mode_i )
        LOAD_CUR_LUMA   : if( extif_wren_o ) begin
                            wren_cnter <= wren_cnter+16 ;
                          end
        LOAD_REF_LUMA   : if( extif_wren_o ) begin
                            wren_cnter <= wren_cnter+16 ;
                          end
        LOAD_CUR_CHROMA : if( extif_wren_o ) begin
                            wren_cnter <= wren_cnter+16 ;
                          end
        LOAD_REF_CHROMA : if( extif_wren_o ) begin
                            wren_cnter <= wren_cnter+16 ;
                          end
        LOAD_DB_LUMA    : if( extif_wren_o ) begin
                            wren_cnter <= wren_cnter+16 ;
                          end
        LOAD_DB_CHROMA  : if( extif_wren_o ) begin
                            wren_cnter <= wren_cnter+16 ;
                          end
      endcase
    end
  end

  always @(posedge axi_clk or negedge axi_rstn)
    if(!axi_rstn) begin
      store_cnter <= 0;
    end 
    else begin
      if (extif_start_axi)
        store_cnter <= 0;
      else 
        if( gen_m1_mwrite & gen_m1_saccept )
          store_cnter <= store_cnter + 64;
    end

  always @(*) begin
                        store_done_w = 0;
    case (extif_mode_i)
      STORE_DB_LUMA   : store_done_w = ( gen_m1_saccept & (store_cnter==extif_width_i*extif_height_i  -64) );
      STORE_DB_CHROMA : store_done_w = ( gen_m1_saccept & (store_cnter==extif_width_i*extif_height_i/2-64) );
    endcase
  end

  //--- CDC SYN start ---
  always @(posedge axi_clk or negedge axi_rstn) begin
    if( !axi_rstn )
      store_done_axi <= 0 ;
    else if( store_done_w )
      store_done_axi <= 1'b1 ;
    else if (store_done_ack1)
      store_done_axi <= 1'b0 ;
  end

  always @(posedge enc_clk or negedge enc_rstn) begin
    if(!enc_rstn) begin
      store_done_enc0 <= 0;
      store_done_enc1 <= 0;
      store_done_enc2 <= 0;
    end 
    else begin
      store_done_enc0 <= store_done_axi ;
      store_done_enc1 <= store_done_enc0;
      store_done_enc2 <= store_done_enc1;
    end
  end

  always @(posedge axi_clk or negedge axi_rstn) begin
    if(!axi_rstn) begin
      store_done_ack0 <= 0;
      store_done_ack1 <= 0;
    end 
    else begin
      store_done_ack0 <= store_done_enc1;
      store_done_ack1 <= store_done_ack0;
    end
  end

  assign store_done_enc = store_done_enc1 & (~store_done_enc2) ;
  //--- CDC SYN end ---

  always @(*) begin
                          extif_done_w = 0 ;
    if( cur_state_0!=IDLE ) begin
      case( extif_mode_i )
        LOAD_CUR_SUB    : extif_done_w = 1 ;
        LOAD_CUR_LUMA   : extif_done_w = ( extif_wren_o & (wren_cnter==extif_width_i*extif_height_i  -16) ) | (extif_height_i==0) ;
        LOAD_CUR_CHROMA : extif_done_w = ( extif_wren_o & (wren_cnter==extif_width_i*extif_height_i/2-16) ) | (extif_height_i==0) ;
      endcase
    end
    else begin
      if( cur_state_1!=IDLE ) begin
        case( extif_mode_i )
          LOAD_REF_SUB    : extif_done_w = 1 ;
          LOAD_REF_LUMA   : extif_done_w = ( extif_wren_o & (wren_cnter==extif_width_i*extif_height_i  -16) ) | (extif_height_i==0) ;
          LOAD_REF_CHROMA : extif_done_w = ( extif_wren_o & (wren_cnter==extif_width_i*extif_height_i/2-16) ) | (extif_height_i==0) ;
          LOAD_DB_LUMA    : extif_done_w = ( extif_wren_o & (wren_cnter==extif_width_i*extif_height_i  -16) ) | (extif_height_i==0) ;
          LOAD_DB_CHROMA  : extif_done_w = ( extif_wren_o & (wren_cnter==extif_width_i*extif_height_i/2-16) ) | (extif_height_i==0) ;
          STORE_DB_LUMA   : extif_done_w =   store_done_enc                                                   | (extif_height_i==0) ;
          STORE_DB_CHROMA : extif_done_w =   store_done_enc                                                   | (extif_height_i==0) ;
        endcase
      end
    end
  end

  //--- CDC SYN start ---
  always @(posedge axi_clk or negedge axi_rstn) begin
    if(!axi_rstn) begin
      extif_done_axi0 <= 0;
      extif_done_axi1 <= 0;
      extif_done_axi2 <= 0;
    end 
    else begin
      extif_done_axi0 <= extif_done_w   ;
      extif_done_axi1 <= extif_done_axi0;
      extif_done_axi2 <= extif_done_axi1;
    end
  end

  assign extif_done_axi = extif_done_axi1 & (~extif_done_axi2) ;
  //--- CDC SYN end ---

//*** extif ****************************************************************

  assign extif_wren_o = pop_req_loadpix && (pop_cnter!=4) && (pop_cnter!=5);

  assign extif_rden_o = push_req_storepix;

  assign extif_data_o = { data_out_loadpix[007:000]
                         ,data_out_loadpix[015:008]
                         ,data_out_loadpix[023:016]
                         ,data_out_loadpix[031:024]
                         ,data_out_loadpix[039:032]
                         ,data_out_loadpix[047:040]
                         ,data_out_loadpix[055:048]
                         ,data_out_loadpix[063:056]
                         ,data_out_loadpix[071:064]
                         ,data_out_loadpix[079:072]
                         ,data_out_loadpix[087:080]
                         ,data_out_loadpix[095:088]
                         ,data_out_loadpix[103:096]
                         ,data_out_loadpix[111:104]
                         ,data_out_loadpix[119:112]
                         ,data_out_loadpix[127:120]
                        };

  always @(posedge enc_clk or negedge enc_rstn ) begin
    if( !enc_rstn )
      extif_done_o <= 0 ;
    else begin
      extif_done_o <= extif_done_w ;
    end
  end

  assign extif_mode_cur = (extif_mode_i==LOAD_CUR_LUMA)||(extif_mode_i==LOAD_CUR_CHROMA) ;

  //--- CDC SYN start ---
  always @(posedge axi_clk or negedge axi_rstn) begin
    if(!axi_rstn) begin
      extif_start_axi0 <= 0;
      extif_start_axi1 <= 0;
      extif_start_axi2 <= 0;
    end 
    else begin
      extif_start_axi0 <= extif_start_i ;
      extif_start_axi1 <= extif_start_axi0;
      extif_start_axi2 <= extif_start_axi1;
    end
  end

  assign extif_start_axi = extif_start_axi1 & (~extif_start_axi2) ;
  //--- CDC SYN end ---

//*** bs counter *****************************************************

  always @(posedge enc_clk or negedge enc_rstn) begin
    if( !enc_rstn ) begin
      reg_counter <= 0;
    end 
    else begin
      if ( sys_start_enc )
        reg_counter <= 0;
      else
        if ( bs_val_i )
          reg_counter <= reg_counter + 1;
    end
  end

//*** bs final dump *****************************************************

  always @(posedge enc_clk or negedge enc_rstn) begin
    if( !enc_rstn ) begin
      sys_done_r <= 0;
    end 
    else begin
      sys_done_r <= sys_done_i;
    end
  end

  always @(posedge enc_clk or negedge enc_rstn) begin
    if( !enc_rstn ) begin
      bs_valid_extra <= 0;
    end 
    else begin
      if ( bs_valid_cnter == 6'd63 )
        bs_valid_extra <= 1'b0;
      else 
        if ( sys_done_i & !sys_done_r )
          bs_valid_extra <= 1'b1;
    end
  end

  always @(posedge enc_clk or negedge enc_rstn)
    if( !enc_rstn ) begin
      bs_valid_cnter <= 0;
    end 
    else begin
      if ( bs_valid_cnter == 6'd63 )
        bs_valid_cnter <= 6'd0;
      else
        if ( bs_valid_extra )
          bs_valid_cnter <= bs_valid_cnter + 6'd1;
    end

  always @(posedge enc_clk or negedge enc_rstn) begin
    if( !enc_rstn ) begin
      sys_done_0 <= 0;
    end 
    else begin
      if ( sys_start_enc )
        sys_done_0 <= 0;
      else
        if ( sys_done_i )
          sys_done_0 <= 1;
    end
  end

  always @(posedge enc_clk or negedge enc_rstn) begin
    if( !enc_rstn ) begin
      sys_done_1 <= 0;
    end 
    else begin
      if ( sys_start_enc )
        sys_done_1 <= 0;
      else
        if ( sys_done_0 && bs_valid_cnter == 6'd63 )
          sys_done_1 <= 1;
    end
  end

  always @(posedge enc_clk or negedge enc_rstn) begin
    if( !enc_rstn ) begin
      reg_done <= 0;
    end 
    else begin
      if ( sys_start_enc )
        reg_done <= 0;
      else
        if ( sys_done_1 & !empty_bs )
          reg_done <= 1;
    end
  end

endmodule
