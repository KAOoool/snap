//-------------------------------------------------------------------
//
//  COPYRIGHT (C) 2016, VIPcore Group, Fudan University
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
//  Filename      : enc_core.v
//  Author        : Huang Leilei
//  Created       : 2016-03-20
//  Description   : core of enc
//
//-------------------------------------------------------------------
//
//  Modified      : 2016-03-22 by HLL
//  Description   : pipeline stages modified
//
//-------------------------------------------------------------------

`include "enc_defines.v"

module enc_core(
  // GLOBAL
  clk                  ,
  rst_n                ,

  // SYS_IF
  sys_x_total_i        ,
  sys_y_total_i        ,
  sys_type_i           ,
  pre_min_size_i       ,
  enc_start_i          ,

  // PRE_I_SYS_IF
  pre_i_start_i        ,
  pre_i_x_i            ,
  pre_i_y_i            ,
  pre_i_qp_i           ,
  pre_i_done_o         ,
  // PRE_I_CUR_IF
  pre_i_cur_ren_o      ,
  pre_i_cur_sel_o      ,
  pre_i_cur_size_o     ,
  pre_i_cur_4x4_x_o    ,
  pre_i_cur_4x4_y_o    ,
  pre_i_cur_idx_o      ,
  pre_i_cur_data_i     ,

  // INTRA_SYS_IF
  intra_start_i        ,
  intra_x_i            ,
  intra_y_i            ,
  intra_qp_i           ,
  intra_done_o         ,

  // IME_SYS_IF
  ime_start_i          ,
  ime_x_i              ,
  ime_y_i              ,
  ime_qp_i             ,
  ime_done_o           ,
  // IME_CUR_IF
  ime_cur_4x4_x_o      ,
  ime_cur_4x4_y_o      ,
  ime_cur_idx_o        ,
  ime_cur_sel_o        ,
  ime_cur_size_o       ,
  ime_cur_ren_o        ,
  ime_cur_data_i       ,
  // IME_REF_IF
  ime_ref_x_o          ,
  ime_ref_y_o          ,
  ime_ref_ren_o        ,
  ime_ref_data_i       ,

  // FME_SYS_IF
  fme_start_i          ,
  fme_x_i              ,
  fme_y_i              ,
  fme_qp_i             ,
  fme_done_o           ,
  // FME_CUR_IF
  fme_cur_4x4_x_o      ,
  fme_cur_4x4_y_o      ,
  fme_cur_idx_o        ,
  fme_cur_sel_o        ,
  fme_cur_size_o       ,
  fme_cur_ren_o        ,
  fme_cur_data_i       ,
  // FME_REF_IF
  fme_ref_x_o          ,
  fme_ref_y_o          ,
  fme_ref_ren_o        ,
  fme_ref_data_i       ,

  // MC_SYS_IF
  mc_start_i           ,
  mc_x_i               ,
  mc_y_i               ,
  mc_qp_i              ,
  mc_done_o            ,
  // MC_REF_IF
  mc_ref_x_o           ,
  mc_ref_y_o           ,
  mc_ref_ren_o         ,
  mc_ref_sel_o         ,
  mc_ref_data_i        ,

  // TQ_CUR_IF
  tq_cur_4x4_x_o       ,
  tq_cur_4x4_y_o       ,
  tq_cur_idx_o         ,
  tq_cur_sel_o         ,
  tq_cur_size_o        ,
  tq_cur_ren_o         ,
  tq_cur_data_i        ,

  // DB_SYS_IF
  db_start_i           ,
  db_x_i               ,
  db_y_i               ,
  db_qp_i              ,
  db_done_o            ,
  // DB_REC_IF
  db_wen_o             ,
  db_w4x4_x_o          ,
  db_w4x4_y_o          ,
  db_wprevious_o       ,
  db_wsel_o            ,
  db_wdata_o           ,
  db_ren_o             ,
  db_r4x4_o            ,
  db_ridx_o            ,
  db_rdata_i           ,

  // EC_SYS_IF
  ec_start_i           ,
  ec_x_i               ,
  ec_y_i               ,
  ec_qp_i              ,
  ec_done_o            ,
  // EC_BS_IF
  ec_bs_val_o          ,
  ec_bs_dat_o
  );


//*** PARAMETER ****************************************************************

  localparam                             INTRA = 0            ,
                                         INTER = 1            ;


//*** INPUT/OUTPUT DECLARATION *************************************************

  // GLOBAL
  input                                  clk                  ;
  input                                  rst_n                ;

  // SYS_IF
  input  [`PIC_X_WIDTH-1         : 0]    sys_x_total_i        ;
  input  [`PIC_Y_WIDTH-1         : 0]    sys_y_total_i        ;
  input                                  sys_type_i           ;
  input                                  pre_min_size_i       ;
  input                                  enc_start_i          ;

  // PRE_I_SYS_IF
  input                                  pre_i_start_i        ;
  input  [`PIC_X_WIDTH-1         : 0]    pre_i_x_i            ;
  input  [`PIC_Y_WIDTH-1         : 0]    pre_i_y_i            ;
  input  [5                      : 0]    pre_i_qp_i           ;
  output                                 pre_i_done_o         ;
  // PRE_I_CUR_IF
  output [3                      : 0]    pre_i_cur_4x4_x_o    ;
  output [3                      : 0]    pre_i_cur_4x4_y_o    ;
  output [5-1                    : 0]    pre_i_cur_idx_o      ;
  output                                 pre_i_cur_sel_o      ;
  output [2-1                    : 0]    pre_i_cur_size_o     ;
  output                                 pre_i_cur_ren_o      ;
  input  [`PIXEL_WIDTH*32-1      : 0]    pre_i_cur_data_i     ;

  // INTRA_SYS_IF
  input                                  intra_start_i        ;
  input  [`PIC_X_WIDTH-1         : 0]    intra_x_i            ;
  input  [`PIC_Y_WIDTH-1         : 0]    intra_y_i            ;
  input  [5                      : 0]    intra_qp_i           ;
  output                                 intra_done_o         ;

  // IME_SYS_IF
  input                                  ime_start_i          ;
  input  [`PIC_X_WIDTH-1         : 0]    ime_x_i              ;
  input  [`PIC_Y_WIDTH-1         : 0]    ime_y_i              ;
  input  [5                      : 0]    ime_qp_i             ;
  output                                 ime_done_o           ;
  // IME_CUR_IF
  output [4-1                    : 0]    ime_cur_4x4_x_o      ;
  output [4-1                    : 0]    ime_cur_4x4_y_o      ;
  output [5-1                    : 0]    ime_cur_idx_o        ;
  output                                 ime_cur_sel_o        ;
  output [3-1                    : 0]    ime_cur_size_o       ;
  output                                 ime_cur_ren_o        ;
  input  [64*`PIXEL_WIDTH-1      : 0]    ime_cur_data_i       ;
  // IME_REF_IF
  output [5-1                    : 0]    ime_ref_x_o          ;
  output [7-1                    : 0]    ime_ref_y_o          ;
  output                                 ime_ref_ren_o        ;
  input  [64*`PIXEL_WIDTH-1      : 0]    ime_ref_data_i       ;

  // FME_SYS_IF
  input                                  fme_start_i          ;
  input  [`PIC_X_WIDTH-1         : 0]    fme_x_i              ;
  input  [`PIC_Y_WIDTH-1         : 0]    fme_y_i              ;
  input  [5                      : 0]    fme_qp_i             ;
  output                                 fme_done_o           ;
  // FME_CUR_IF
  output [4-1                    : 0]    fme_cur_4x4_x_o      ;
  output [4-1                    : 0]    fme_cur_4x4_y_o      ;
  output [5-1                    : 0]    fme_cur_idx_o        ;
  output                                 fme_cur_sel_o        ;
  output [2-1                    : 0]    fme_cur_size_o       ;
  output                                 fme_cur_ren_o        ;
  input  [32*`PIXEL_WIDTH-1      : 0]    fme_cur_data_i       ;
  // FME_REF_IF
  output [7-1                    : 0]    fme_ref_x_o          ;
  output [7-1                    : 0]    fme_ref_y_o          ;
  output                                 fme_ref_ren_o        ;
  input  [64*`PIXEL_WIDTH-1      : 0]    fme_ref_data_i       ;

  // MC_SYS_IF
  input                                  mc_start_i           ;
  input  [`PIC_X_WIDTH-1         : 0]    mc_x_i               ;
  input  [`PIC_Y_WIDTH-1         : 0]    mc_y_i               ;
  input  [5                      : 0]    mc_qp_i              ;
  output                                 mc_done_o            ;
  // MC_REF_IF
  output [6-1                    : 0]    mc_ref_x_o           ;
  output [6-1                    : 0]    mc_ref_y_o           ;
  output                                 mc_ref_ren_o         ;
  output                                 mc_ref_sel_o         ;
  input  [8*`PIXEL_WIDTH-1       : 0]    mc_ref_data_i        ;

  // TQ_CUR_IF
  output [3                      : 0]    tq_cur_4x4_x_o       ;
  output [3                      : 0]    tq_cur_4x4_y_o       ;
  output [5-1                    : 0]    tq_cur_idx_o         ;
  output                                 tq_cur_sel_o         ;
  output [2-1                    : 0]    tq_cur_size_o        ;
  output                                 tq_cur_ren_o         ;
  input  [`PIXEL_WIDTH*32-1      : 0]    tq_cur_data_i        ;

  // DB_SYS_IF
  input                                  db_start_i           ;
  input  [`PIC_X_WIDTH-1         : 0]    db_x_i               ;
  input  [`PIC_Y_WIDTH-1         : 0]    db_y_i               ;
  input  [5                      : 0]    db_qp_i              ;
  output                                 db_done_o            ;
  // DB_REC_IF
  output [1-1                    : 0]    db_wen_o             ;
  output [5-1                    : 0]    db_w4x4_x_o          ;
  output [5-1                    : 0]    db_w4x4_y_o          ;
  output [1-1                    : 0]    db_wprevious_o       ;
  output [2-1                    : 0]    db_wsel_o            ;
  output [16*`PIXEL_WIDTH-1      : 0]    db_wdata_o           ;
  output [1-1                    : 0]    db_ren_o             ;
  output [5-1                    : 0]    db_r4x4_o            ;
  output [2-1                    : 0]    db_ridx_o            ;
  input  [16*`PIXEL_WIDTH-1      : 0]    db_rdata_i           ;

  // EC_SYS_IF
  input                                  ec_start_i           ;
  input  [`PIC_X_WIDTH-1         : 0]    ec_x_i               ;
  input  [`PIC_Y_WIDTH-1         : 0]    ec_y_i               ;
  input  [5                      : 0]    ec_qp_i              ;
  output                                 ec_done_o            ;
  // EC_BS_IF
  output                                 ec_bs_val_o          ;
  output [7                      : 0]    ec_bs_dat_o          ;


//*** WIRE & REG DECLARATION ***************************************************

//-------------------- global signals ------------
  reg                                    sel_r                 ;
  reg  [1                        : 0]    sel_mod_3_r           ;
  reg  [9                        : 0]    enc_start_r           ;

//-------------------- u_pre_i -------------------
  wire                                   md_we                 ;
  wire [6                        : 0]    md_waddr              ;
  wire [5                        : 0]    md_wdata              ;

  wire                                   md_we_0               ;
  wire [9                        : 0]    md_addr_i_0           ;
  wire [5                        : 0]    md_data_i_0           ;

  wire                                   md_we_1               ;
  wire [9                        : 0]    md_addr_i_1           ;
  wire [5                        : 0]    md_data_i_1           ;

  wire [5                        : 0]    intra_md_data_0       ;
  wire [5                        : 0]    intra_md_data_1       ;

//-------------------- u_intra -------------------
  wire                                   intra_md_ren          ;
  wire [9                        : 0]    intra_md_addr         ;
  wire [5                        : 0]    intra_md_data         ;

  wire                                   intra_ipre_en         ;
  wire [1                        : 0]    intra_ipre_sel        ;
  wire [1                        : 0]    intra_ipre_size       ;
  wire [3                        : 0]    intra_ipre_4x4_x      ;
  wire [3                        : 0]    intra_ipre_4x4_y      ;
  wire [`PIXEL_WIDTH*16-1        : 0]    intra_ipre_data       ;
  wire [5                        : 0]    intra_ipre_mode       ;

//--------------------- u_fime --------------------
  wire                                   curif_en_w            ;
  wire [5                        : 0]    curif_num_w           ;
  wire [`PIXEL_WIDTH*64-1        : 0]    curif_data_w          ;
  wire [41                       : 0]    fmeif_partition_w     ;
  wire [5                        : 0]    fmeif_cu_num_w        ;
  wire [`FMV_WIDTH*2-1           : 0]    fmeif_mv_w            ;
  wire                                   fmeif_en_w            ;

  wire [`FMV_WIDTH-1             : 0]    fmeif_mv_x_w          ;
  wire [`FMV_WIDTH-1             : 0]    fmeif_mv_y_w          ;

  reg  [41                       : 0]    fmeif_partition_r     ;

//--------------------- u_fme ---------------------
  wire [41                       : 0]    imeif_partition_w    ;
  wire [1-1                      : 0]    imeif_mv_rden_w      ;
  wire [6-1                      : 0]    imeif_mv_rdaddr_w    ;
  wire [2*`FMV_WIDTH-1           : 0]    imeif_mv_data_w      ;

  wire [2*`FMV_WIDTH-1           : 0]    imeif_mv_data_w_0    ;
  wire [2*`FMV_WIDTH-1           : 0]    imeif_mv_data_w_1    ;

  wire [1-1                      : 0]    mcif_mv_rden_w        ;
  wire [6-1                      : 0]    mcif_mv_rdaddr_w      ;
  reg  [2*`FMV_WIDTH-1           : 0]    mcif_mv_rddata_w      ;

  wire                                   mcif_mv_wren_w        ;
  wire [6-1                      : 0]    mcif_mv_wraddr_w      ;
  wire [2*`FMV_WIDTH-1           : 0]    mcif_mv_wrdata_w      ;

  wire [32*`PIXEL_WIDTH-1        : 0]    mcif_pre_pixel_w      ;
  wire [4-1                      : 0]    mcif_pre_wren_w       ;
  wire [7-1                      : 0]    mcif_pre_addr_w       ;

  reg  [1-1                      : 0]    fme_mv_mem_0_rden_w   ;
  reg  [6-1                      : 0]    fme_mv_mem_0_rdaddr_w ;
  wire [2*`FMV_WIDTH-1           : 0]    fme_mv_mem_0_rddata_w ;

  reg                                    fme_mv_mem_0_wren_w   ;
  reg  [6-1                      : 0]    fme_mv_mem_0_wraddr_w ;
  reg  [2*`FMV_WIDTH-1           : 0]    fme_mv_mem_0_wrdata_w ;

  reg  [1-1                      : 0]    fme_mv_mem_1_rden_w   ;
  reg  [6-1                      : 0]    fme_mv_mem_1_rdaddr_w ;
  wire [2*`FMV_WIDTH-1           : 0]    fme_mv_mem_1_rddata_w ;

  reg                                    fme_mv_mem_1_wren_w   ;
  reg  [6-1                      : 0]    fme_mv_mem_1_wraddr_w ;
  reg  [2*`FMV_WIDTH-1           : 0]    fme_mv_mem_1_wrdata_w ;

  reg  [1-1                      : 0]    fme_mv_mem_2_rden_w   ;
  reg  [6-1                      : 0]    fme_mv_mem_2_rdaddr_w ;
  wire [2*`FMV_WIDTH-1           : 0]    fme_mv_mem_2_rddata_w ;

  reg                                    fme_mv_mem_2_wren_w   ;
  reg  [6-1                      : 0]    fme_mv_mem_2_wraddr_w ;
  reg  [2*`FMV_WIDTH-1           : 0]    fme_mv_mem_2_wrdata_w ;

//---------------------- u_mc ---------------------
  wire                                   mc_mv_rden_w          ;
  wire [6-1                      : 0]    mc_mv_rdaddr_w        ;
  reg  [2*`FMV_WIDTH-1           : 0]    mc_mv_w               ;

  reg  [41                       : 0]    mc_partition_r        ;

  wire                                   mc_ppre_en            ;
  wire [1                        : 0]    mc_ppre_sel           ;
  wire [1                        : 0]    mc_ppre_size          ;
  wire [3                        : 0]    mc_ppre_4x4_x         ;
  wire [3                        : 0]    mc_ppre_4x4_y         ;
  wire [`PIXEL_WIDTH*16-1        : 0]    mc_ppre_data          ;
  wire [5                        : 0]    mc_ppre_mode          ;

  wire [4-1                      : 0]    fme_rec_mem_0_wen_i   ;
  wire [8-1                      : 0]    fme_rec_mem_0_addr_i  ;
  wire [32*`PIXEL_WIDTH-1        : 0]    fme_rec_mem_0_wdata_i ;

  wire [4-1                      : 0]    fme_rec_mem_1_wen_i   ;
  wire [8-1                      : 0]    fme_rec_mem_1_addr_i  ;
  wire [32*`PIXEL_WIDTH-1        : 0]    fme_rec_mem_1_wdata_i ;

  wire [4-1                      : 0]    mc_pre_wren_w         ;
  wire [7-1                      : 0]    mc_pre_wraddr_w       ;
  wire [32*`PIXEL_WIDTH-1        : 0]    mc_pre_wrdata_w       ;

  wire                                   mc_mvd_wen_w          ;
  wire [`CU_DEPTH*2-1            : 0]    mc_mvd_waddr_w        ;
  wire [`MVD_WIDTH*2             : 0]    mc_mvd_wdata_w        ;

  wire                                   mc_mvd_mem_0_wren_w   ;
  wire [`CU_DEPTH*2-1            : 0]    mc_mvd_mem_0_wraddr_w ;
  wire [`MVD_WIDTH*2             : 0]    mc_mvd_mem_0_wrdata_w ;

  wire                                   mc_mvd_mem_1_wren_w   ;
  wire [`CU_DEPTH*2-1            : 0]    mc_mvd_mem_1_wraddr_w ;
  wire [`MVD_WIDTH*2             : 0]    mc_mvd_mem_1_wrdata_w ;

  wire                                   mc_mvd_mem_2_wren_w   ;
  wire [`CU_DEPTH*2-1            : 0]    mc_mvd_mem_2_wraddr_w ;
  wire [`MVD_WIDTH*2             : 0]    mc_mvd_mem_2_wrdata_w ;

  wire [1-1                      : 0]    mc_pred_ren_w         ;
  wire [2-1                      : 0]    mc_pred_size_w        ;
  wire [4-1                      : 0]    mc_pred_4x4_x_w       ;
  wire [4-1                      : 0]    mc_pred_4x4_y_w       ;
  wire [5-1                      : 0]    mc_pred_4x4_idx_w     ;
  wire [32*`PIXEL_WIDTH-1        : 0]    mc_pred_rdata_w       ;

  wire [32*`PIXEL_WIDTH-1        : 0]    mc_pred_rdata_0_w     ;
  wire [32*`PIXEL_WIDTH-1        : 0]    mc_pred_rdata_1_w     ;

//------------------- u_mem_buf -------------------
  wire                                   rec_cov               ;
  wire                                   rec_val               ;
  wire [4                        : 0]    rec_idx               ;
  wire [`PIXEL_WIDTH*32-1        : 0]    rec_data              ;

  wire [`LCU_SIZE*`LCU_SIZE/16-1 : 0]    tq_cbf_luma           ;
  wire [`LCU_SIZE*`LCU_SIZE/64-1 : 0]    tq_cbf_cb             ;
  wire [`LCU_SIZE*`LCU_SIZE/64-1 : 0]    tq_cbf_cr             ;

  reg                                    lm_md_renab           ;
  reg                                    lm_md_renab_r         ;
  reg  [5                        : 0]    lm_md_raddr           ;
  reg  [5                        : 0]    lm_md_raddr_r         ;
  wire [23                       : 0]    lm_md_rdata           ;

  wire                                   lm_md_mem_0_wren_w    ;
  wire [5                        : 0]    lm_md_mem_0_wraddr_w  ;
  wire [23                       : 0]    lm_md_mem_0_wrdata_w  ;

  wire                                   lm_md_mem_0_rden_w    ;
  wire [5                        : 0]    lm_md_mem_0_rdaddr_w  ;
  wire [23                       : 0]    lm_md_mem_0_rddata_w  ;

  wire                                   lm_md_mem_1_wren_w    ;
  wire [5                        : 0]    lm_md_mem_1_wraddr_w  ;
  wire [23                       : 0]    lm_md_mem_1_wrdata_w  ;

  wire                                   lm_md_mem_1_rden_w    ;
  wire [5                        : 0]    lm_md_mem_1_rdaddr_w  ;
  wire [23                       : 0]    lm_md_mem_1_rddata_w  ;

  reg                                    ec_mem_ren            ;
  reg                                    ec_mem_ren_r          ;
  reg  [1                        : 0]    ec_mem_sel            ;
  reg  [1                        : 0]    ec_mem_sel_r          ;
  reg  [8                        : 0]    ec_mem_raddr          ;
  reg  [8                        : 0]    ec_mem_raddr_r        ;
  wire [`COEFF_WIDTH*16-1        : 0]    ec_mem_rdata          ;

  wire                                   lm_coe_mem_0_wren_w   ;
  wire [8                        : 0]    lm_coe_mem_0_wraddr_w ;
  wire [`COEFF_WIDTH*16-1        : 0]    lm_coe_mem_0_wrdata_w ;

  wire                                   lm_coe_mem_0_rden_w   ;
  wire [8                        : 0]    lm_coe_mem_0_rdaddr_w ;
  wire [`COEFF_WIDTH*16-1        : 0]    lm_coe_mem_0_rddata_w ;

  wire                                   lm_coe_mem_1_wren_w   ;
  wire [8                        : 0]    lm_coe_mem_1_wraddr_w ;
  wire [`COEFF_WIDTH*16-1        : 0]    lm_coe_mem_1_wrdata_w ;

  wire                                   lm_coe_mem_1_rden_w   ;
  wire [8                        : 0]    lm_coe_mem_1_rdaddr_w ;
  wire [`COEFF_WIDTH*16-1        : 0]    lm_coe_mem_1_rddata_w ;

//-------------------- u_tq --------------------
  // Residual
  wire                                   tq_res_en             ;
  wire [1                        : 0]    tq_res_sel            ;
  wire [1                        : 0]    tq_res_size           ;
  wire [4                        : 0]    tq_res_idx            ;
  wire [(`PIXEL_WIDTH+1)*32-1    : 0]    tq_res_data           ;
  // Reconstructed
  wire                                   tq_rec_val            ;
  wire [4                        : 0]    tq_rec_idx            ;
  wire [(`PIXEL_WIDTH+1)*32-1    : 0]    tq_rec_data           ;
  // Coefficient
  wire                                   tq_cef_en             ;
  wire                                   tq_cef_rw             ;
  wire [4                        : 0]    tq_cef_idx            ;
  wire [`COEFF_WIDTH*32-1        : 0]    tq_cef_wdata          ;
  wire [`COEFF_WIDTH*32-1        : 0]    tq_cef_rdata          ;
  // to be delete
  wire                                   tq_cef_ren            ;
  wire [4                        : 0]    tq_cef_ridx           ;
  wire                                   tq_cef_wen            ;
  wire [4                        : 0]    tq_cef_widx           ;

  wire                                   ipre_en               ;
  wire [1                        : 0]    ipre_sel              ;
  wire [1                        : 0]    ipre_size             ;
  wire [3                        : 0]    ipre_4x4_x            ;
  wire [3                        : 0]    ipre_4x4_y            ;
  wire [`PIXEL_WIDTH*16-1        : 0]    ipre_data             ;
  wire [5                        : 0]    ipre_mode             ;

//---------------------- u_ec ---------------------
  reg  [41                       : 0]    ec_partition_0_r      ;
  reg  [41                       : 0]    ec_partition_1_r      ;

  wire                                   ec_mb_type            ;
  wire [20                       : 0]    ec_mb_partition       ;
  wire [((2^`CU_DEPTH)^2)*6-1    : 0]    ec_i_mode             ;
  wire [169                      : 0]    ec_p_mode             ;

  wire                                   ec_mvd_ren_w          ;
  wire [`CU_DEPTH*2-1            : 0]    ec_mvd_raddr_w        ;
  reg  [`MVD_WIDTH*2             : 0]    ec_mvd_rdata_w        ;

  wire [`CU_DEPTH*2-1            : 0]    mc_mvd_mem_0_rdaddr_w ;
  wire [`MVD_WIDTH*2             : 0]    mc_mvd_mem_0_rddata_w ;

  wire [`CU_DEPTH*2-1            : 0]    mc_mvd_mem_1_rdaddr_w ;
  wire [`MVD_WIDTH*2             : 0]    mc_mvd_mem_1_rddata_w ;

  wire [`CU_DEPTH*2-1            : 0]    mc_mvd_mem_2_rdaddr_w ;
  wire [`MVD_WIDTH*2             : 0]    mc_mvd_mem_2_rddata_w ;

  reg  [`LCU_SIZE*`LCU_SIZE/16-1 : 0]    ec_cbf_luma           ;
  reg  [`LCU_SIZE*`LCU_SIZE/16-1 : 0]    ec_cbf_cb             ;
  reg  [`LCU_SIZE*`LCU_SIZE/16-1 : 0]    ec_cbf_cr             ;

  reg  [20                       : 0]    ec_partition_old      ;

  wire                                   ec_mem_ren_w          ;
  wire [1                        : 0]    ec_mem_sel_w          ;
  wire [8                        : 0]    ec_mem_raddr_w        ;
  wire [`COEFF_WIDTH*16-1        : 0]    ec_mem_rdata_w        ;

//---------------------- u_db ---------------------
  reg  [41                       : 0]    db_inter_partition_r  ;
  wire [20                       : 0]    db_intra_partition_w  ;

  wire                                   db_mv_rden_w          ;
  wire [7-1                      : 0]    db_mv_rdaddr_ori_w    ;
  wire [6-1                      : 0]    db_mv_rdaddr_w        ;
  reg  [2*`FMV_WIDTH-1           : 0]    db_mv_w               ;

  wire                                   db_mem_ren            ;
  wire [8                        : 0]    db_mem_raddr          ;
  wire [`PIXEL_WIDTH*16-1        : 0]    db_mem_rdata          ;

  wire                                   db_mb_en              ;
  wire                                   db_mb_rw              ;
  wire [8                        : 0]    db_mb_addr            ;

  reg  [128-1                    : 0]    db_rdata              ;

  wire [128-1                    : 0]    db_mb_data_o          ;

  wire [20                       : 0]    partition_old         ;
  wire [20                       : 0]    partition_cur         ;

  wire                                   ec_lm_md_renab        ;
  wire [5                        : 0]    ec_lm_md_raddr        ;
  wire [23                       : 0]    ec_lm_md_rdata        ;

  wire [`LCU_SIZE*`LCU_SIZE/16-1 : 0]    db_cbf_luma           ;
  wire [`LCU_SIZE*`LCU_SIZE/16-1 : 0]    db_cbf_cb             ;
  wire [`LCU_SIZE*`LCU_SIZE/16-1 : 0]    db_cbf_cr             ;


//*** MAIN BODY ****************************************************************

//-------------------------------------------------------------------
//
//    Global Signals
//
//-------------------------------------------------------------------

  // sel_r
  always @(posedge clk or negedge rst_n ) begin
    if( !rst_n )
      sel_r <= 0 ;
    else if( enc_start_i ) begin
      sel_r <= !sel_r ;
    end
  end

  // sel_mod_3_r
  always @(posedge clk or negedge rst_n ) begin
    if( !rst_n )
      sel_mod_3_r <= 0 ;
    else if( enc_start_i ) begin
      if( sel_mod_3_r==2 )
        sel_mod_3_r <= 0 ;
      else begin
        sel_mod_3_r <= sel_mod_3_r + 1 ;
      end
    end
  end

  // enc_start_r
  always @(posedge clk or negedge rst_n ) begin
    if( !rst_n )
      enc_start_r <= 0 ;
    else begin
      enc_start_r <= {enc_start_r,enc_start_i} ;
    end
  end


//-------------------------------------------------------------------
//
//    PreIntra block
//
//-------------------------------------------------------------------

  hevc_md_top u_pre_i_top(
    .clk              ( clk                ),
    .rstn             ( rst_n              ),
    // sys_if
    .enable           ( pre_i_start_i      ),
    .finish           ( pre_i_done_o       ),
    // pixel_i
    .md_ren_o         ( pre_i_cur_ren_o    ),
    .md_sel_o         ( pre_i_cur_sel_o    ),
    .md_size_o        ( pre_i_cur_size_o   ),
    .md_4x4_x_o       ( pre_i_cur_4x4_x_o  ),
    .md_4x4_y_o       ( pre_i_cur_4x4_y_o  ),
    .md_idx_o         ( pre_i_cur_idx_o    ),
    .md_data_i        ( pre_i_cur_data_i   ),
    // mode_o
    .md_we            ( md_we              ),
    .md_waddr         ( md_waddr           ),
    .md_wdata         ( md_wdata           )
    );

  assign  md_we_0       = sel_r ? md_we         : 0             ;
  assign  md_addr_i_0   = sel_r ? md_waddr      : intra_md_addr ;
  assign  md_data_i_0   = sel_r ? md_wdata      : 0             ;
  assign  md_we_1       = sel_r ? 0             : md_we         ;
  assign  md_addr_i_1   = sel_r ? intra_md_addr : md_waddr      ;
  assign  md_data_i_1   = sel_r ? 0             : md_wdata      ;

  assign  intra_md_data = sel_r ? intra_md_data_1 : intra_md_data_0 ;

  buf_ram_1p_6x85 imode_buf_0(
    .clk              ( clk                ),
    .ce               ( 1'b1               ),
    .we               ( md_we_0            ),
    .addr             ( md_addr_i_0        ),
    .data_i           ( md_data_i_0        ),
    .data_o           ( intra_md_data_0    )
    );

  buf_ram_1p_6x85 imode_buf_1(
    .clk              ( clk                ),
    .ce               ( 1'b1               ),
    .we               ( md_we_1            ),
    .addr             ( md_addr_i_1        ),
    .data_i           ( md_data_i_1        ),
    .data_o           ( intra_md_data_1    )
    );


//-------------------------------------------------------------------
//
//    Intra Block
//
//-------------------------------------------------------------------

  intra_top u_intra_top(
    .clk              ( clk                ),
    .rst_n            ( rst_n              ),
    // sys_if
    .mb_x_total_i     ( sys_x_total_i      ),
    .pre_min_size_i   ( pre_min_size_i     ),
    .start_i          ( intra_start_i      ),
    .mb_x_i           ( intra_x_i          ),
    .mb_y_i           ( intra_y_i          ),
    .done_o           ( intra_done_o       ),
    // pre_i_if
    .md_rden_o        ( intra_md_ren       ),
    .md_raddr_o       ( intra_md_addr      ),
    .md_rdata_i       ( intra_md_data      ),
    // tq_pre_if
    .pre_en_o         ( intra_ipre_en      ),
    .pre_sel_o        ( intra_ipre_sel     ),
    .pre_size_o       ( intra_ipre_size    ),
    .pre_4x4_x_o      ( intra_ipre_4x4_x   ),
    .pre_4x4_y_o      ( intra_ipre_4x4_y   ),
    .pre_data_o       ( intra_ipre_data    ),
    .pre_mode_o       ( intra_ipre_mode    ),
    // tq_rec_if
    .rec_val_i        ( rec_val & (sys_type_i==INTRA)    ),
    .rec_idx_i        ( rec_idx            ),
    .rec_data_i       ( rec_data           ),
    // tq_pt_if
    .cover_valid_i    ( cover_valid        ),
    .cover_value_i    ( cover_value        ),
    .uv_partition_i   ( partition_cur      )
    );


//-------------------------------------------------------------------
//
//    IME Block
//
//-------------------------------------------------------------------

  assign ime_cur_4x4_x_o = 0                 ;
  assign ime_cur_4x4_y_o = curif_num_w[5]<<3 ;
  assign ime_cur_idx_o   = curif_num_w[4:0]  ;
  assign ime_cur_sel_o   = 0                 ;
  assign ime_cur_size_o  = 3'b011            ;
  assign ime_cur_ren_o   = curif_en_w        ;

  assign curif_data_w    = ime_cur_data_i    ;

  ime_top u_ime_top(
   // global
   .clk               ( clk               ),
   .rstn              ( rst_n             ),
   // sys_if
   .sysif_start_i     ( ime_start_i       ),
   .sysif_cmb_x_i     ( ime_x_i           ),
   .sysif_cmb_y_i     ( ime_y_i           ),
   .sysif_qp_i        ( ime_qp_i          ),
   .sysif_done_o      ( ime_done_o        ),
   // cur_if
   .curif_en_o        ( curif_en_w        ),
   .curif_num_o       ( curif_num_w       ),
   .curif_data_i      ( curif_data_w      ),
   // ref_if
   .fetchif_ref_x_o   ( ime_ref_x_o       ),
   .fetchif_ref_y_o   ( ime_ref_y_o       ),
   .fetchif_load_o    ( ime_ref_ren_o     ),
   .fetchif_data_i    ( ime_ref_data_i    ),
   // fme_if
   .fmeif_partition_o ( fmeif_partition_w ),
   .fmeif_cu_num_o    ( fmeif_cu_num_w    ),
   .fmeif_mv_o        ( fmeif_mv_w        ),
   .fmeif_en_o        ( fmeif_en_w        )
   );

  // mask the donnot-care bit
  always @(posedge clk or negedge rst_n ) begin
    if( !rst_n )
      fmeif_partition_r <= 42'b0 ;
    else if( enc_start_i ) begin
      fmeif_partition_r <= 42'b0 ;
      fmeif_partition_r[1:0] <= fmeif_partition_w[1:0];
      if( fmeif_partition_w[1:0]==2'b11 ) begin
        fmeif_partition_r[9:2] <= fmeif_partition_w[9:2];
        if( fmeif_partition_w[3:2]==2'b11 ) begin
          fmeif_partition_r[17:10] <= fmeif_partition_w[17:10];
        end
        if( fmeif_partition_w[5:4]==2'b11 ) begin
          fmeif_partition_r[25:18] <= fmeif_partition_w[25:18];
        end
        if( fmeif_partition_w[7:6]==2'b11 ) begin
          fmeif_partition_r[33:26] <= fmeif_partition_w[33:26];
        end
        if( fmeif_partition_w[9:8]==2'b11 ) begin
          fmeif_partition_r[41:34] <= fmeif_partition_w[41:34];
        end
      end
    end
  end

  // mv_mem
  assign fmeif_mv_y_w = {(fmeif_mv_w[1*`IMV_WIDTH-1:0*`IMV_WIDTH]-12),2'b0} ;
  assign fmeif_mv_x_w = {(fmeif_mv_w[2*`IMV_WIDTH-1:1*`IMV_WIDTH]-12),2'b0} ;

  top_rf_2p_20x64 fime_mv_mem_0 (
    .clkb             ( clk                      ),
    .cenb_i           ( 1'b0                     ),
    .wenb_i           ( !(fmeif_en_w&( sel_r))   ),
    .addrb_i          ( fmeif_cu_num_w           ),
    .datab_i          ( { fmeif_mv_x_w
                         ,fmeif_mv_y_w
                        }                        ),
    .clka             ( clk                      ),
    .cena_i           ( 1'b0                     ),
    .addra_i          ( { imeif_mv_rdaddr_w[5]
                         ,imeif_mv_rdaddr_w[2]
                         ,imeif_mv_rdaddr_w[4]
                         ,imeif_mv_rdaddr_w[1]
                         ,imeif_mv_rdaddr_w[3]
                         ,imeif_mv_rdaddr_w[0]
                        }                        ),
    .dataa_o          ( imeif_mv_data_w_0        )
    );

  top_rf_2p_20x64 fime_mv_mem_1 (
    .clkb             ( clk                      ),
    .cenb_i           ( 1'b0                     ),
    .wenb_i           ( !(fmeif_en_w&(!sel_r))   ),
    .addrb_i          ( fmeif_cu_num_w           ),
    .datab_i          ( { fmeif_mv_x_w
                         ,fmeif_mv_y_w
                        }                        ),
    .clka             ( clk                      ),
    .cena_i           ( 1'b0                     ),
    .addra_i          ( { imeif_mv_rdaddr_w[5]
                         ,imeif_mv_rdaddr_w[2]
                         ,imeif_mv_rdaddr_w[4]
                         ,imeif_mv_rdaddr_w[1]
                         ,imeif_mv_rdaddr_w[3]
                         ,imeif_mv_rdaddr_w[0]
                        }                        ),
    .dataa_o          ( imeif_mv_data_w_1       )
    );


//-------------------------------------------------------------------
//
//          FME Block
//
//-------------------------------------------------------------------

  assign fme_cur_sel_o  = 1'b0  ;
  assign fme_cur_size_o = 2'b01 ;

  // change the order
  assign imeif_partition_w = { fmeif_partition_r[11:10] ,fmeif_partition_r[11+2:10+2] ,fmeif_partition_r[11+4:10+4] ,fmeif_partition_r[11+6:10+6]
                              ,fmeif_partition_r[19:18] ,fmeif_partition_r[19+2:18+2] ,fmeif_partition_r[19+4:18+4] ,fmeif_partition_r[19+6:18+6]
                              ,fmeif_partition_r[27:26] ,fmeif_partition_r[27+2:26+2] ,fmeif_partition_r[27+4:26+4] ,fmeif_partition_r[27+6:26+6]
                              ,fmeif_partition_r[35:34] ,fmeif_partition_r[35+2:34+2] ,fmeif_partition_r[35+4:34+4] ,fmeif_partition_r[35+6:34+6]
                              ,fmeif_partition_r[03:02] ,fmeif_partition_r[03+2:02+2] ,fmeif_partition_r[03+4:02+4] ,fmeif_partition_r[03+6:02+6]
                              ,fmeif_partition_r[01:00]
                             };

  assign imeif_mv_data_w = sel_r ? imeif_mv_data_w_1 : imeif_mv_data_w_0 ;

  fme_top u_fme_top(
    // global
    .clk                  ( clk                    ),
    .rstn                 ( rst_n                  ),
    // sys_if
    .sysif_start_i        ( fme_start_i            ),
    .sysif_cmb_x_i        ( fme_x_i                ),
    .sysif_cmb_y_i        ( fme_y_i                ),
    .sysif_qp_i           ( fme_qp_i               ),
    .sysif_done_o         ( fme_done_o             ),
    // ime_if
    .fimeif_partition_i   ( imeif_partition_w      ),
    .fimeif_mv_rden_o     ( imeif_mv_rden_w        ),
    .fimeif_mv_rdaddr_o   ( imeif_mv_rdaddr_w      ),
    .fimeif_mv_data_i     ( imeif_mv_data_w        ),
    // cur_if
    .cur_rden_o           ( fme_cur_ren_o          ),
    .cur_4x4_idx_o        ( fme_cur_idx_o          ),
    .cur_4x4_x_o          ( fme_cur_4x4_x_o        ),
    .cur_4x4_y_o          ( fme_cur_4x4_y_o        ),
    .cur_pel_i            ( fme_cur_data_i         ),
    // ref_if
    .ref_rden_o           ( fme_ref_ren_o          ),
    .ref_idx_x_o          ( fme_ref_x_o            ),
    .ref_idx_y_o          ( fme_ref_y_o            ),
    .ref_pel_i            ( fme_ref_data_i         ),
    // mc_if
    .mcif_mv_rden_o       ( mcif_mv_rden_w         ),
    .mcif_mv_rdaddr_o     ( mcif_mv_rdaddr_w       ),
    .mcif_mv_data_i       ( mcif_mv_rddata_w       ),
    .mcif_mv_wren_o       ( mcif_mv_wren_w         ),
    .mcif_mv_wraddr_o     ( mcif_mv_wraddr_w       ),
    .mcif_mv_data_o       ( mcif_mv_wrdata_w       ),
    .mcif_pre_pixel_o     ( mcif_pre_pixel_w       ),
    .mcif_pre_wren_o      ( mcif_pre_wren_w        ),
    .mcif_pre_addr_o      ( mcif_pre_addr_w        )
    );

  // rec_mem
  assign fme_rec_mem_0_wen_i   = ( sel_r) ? mcif_pre_wren_w        : mc_pre_wren_w          ;
  assign fme_rec_mem_0_addr_i  = ( sel_r) ? {1'b0,mcif_pre_addr_w} : {1'b0,mc_pre_wraddr_w} ;
  assign fme_rec_mem_0_wdata_i = ( sel_r) ? mcif_pre_pixel_w       : mc_pre_wrdata_w        ;

  assign fme_rec_mem_1_wen_i   = (!sel_r) ? mcif_pre_wren_w        : mc_pre_wren_w          ;
  assign fme_rec_mem_1_addr_i  = (!sel_r) ? {1'b0,mcif_pre_addr_w} : {1'b0,mc_pre_wraddr_w} ;
  assign fme_rec_mem_1_wdata_i = (!sel_r) ? mcif_pre_pixel_w       : mc_pre_wrdata_w        ;

  mem_lipo_1p_bw fme_rec_mem_0 (
    .clk                  ( clk                    ),
    .rst_n                ( rst_n                  ),

    .a_wen_i              ( fme_rec_mem_0_wen_i    ),
    .a_addr_i             ( fme_rec_mem_0_addr_i   ),
    .a_wdata_i            ( fme_rec_mem_0_wdata_i  ),

    .b_ren_i              ( mc_pred_ren_w          ),
    .b_sel_i              ( 1'b0                   ),
    .b_size_i             ( mc_pred_size_w         ),
    .b_4x4_x_i            ( mc_pred_4x4_x_w        ),
    .b_4x4_y_i            ( mc_pred_4x4_y_w        ),
    .b_idx_i              ( mc_pred_4x4_idx_w      ),
    .b_rdata_o            ( mc_pred_rdata_0_w      )
    );

  mem_lipo_1p_bw fme_rec_mem_1 (
    .clk                  ( clk                    ),
    .rst_n                ( rst_n                  ),

    .a_wen_i              ( fme_rec_mem_1_wen_i    ),
    .a_addr_i             ( fme_rec_mem_1_addr_i   ),
    .a_wdata_i            ( fme_rec_mem_1_wdata_i  ),

    .b_ren_i              ( mc_pred_ren_w          ),
    .b_sel_i              ( 1'b0                   ),
    .b_size_i             ( mc_pred_size_w         ),
    .b_4x4_x_i            ( mc_pred_4x4_x_w        ),
    .b_4x4_y_i            ( mc_pred_4x4_y_w        ),
    .b_idx_i              ( mc_pred_4x4_idx_w      ),
    .b_rdata_o            ( mc_pred_rdata_1_w      )
    );

  // mv_mem
  always @(*) begin
                   fme_mv_mem_0_rdaddr_w = 0 ;
                   fme_mv_mem_0_wren_w   = 0 ;
                   fme_mv_mem_0_wraddr_w = 0 ;
                   fme_mv_mem_0_wrdata_w = 0 ;
    case( sel_mod_3_r )
      0 : begin    fme_mv_mem_0_rdaddr_w = mcif_mv_rdaddr_w ;
                   fme_mv_mem_0_wren_w   = mcif_mv_wren_w   ;
                   fme_mv_mem_0_wraddr_w = mcif_mv_wraddr_w ;
                   fme_mv_mem_0_wrdata_w = mcif_mv_wrdata_w ;
          end
      1 : begin    fme_mv_mem_0_rdaddr_w = mc_mv_rdaddr_w   ;
          end
      2 : begin    fme_mv_mem_0_rdaddr_w = db_mv_rdaddr_w   ;
          end
    endcase
  end

  always @(*) begin
                   fme_mv_mem_1_rdaddr_w = 0 ;
                   fme_mv_mem_1_wren_w   = 0 ;
                   fme_mv_mem_1_wraddr_w = 0 ;
                   fme_mv_mem_1_wrdata_w = 0 ;
    case( sel_mod_3_r )
      1 : begin    fme_mv_mem_1_rdaddr_w = mcif_mv_rdaddr_w ;
                   fme_mv_mem_1_wren_w   = mcif_mv_wren_w   ;
                   fme_mv_mem_1_wraddr_w = mcif_mv_wraddr_w ;
                   fme_mv_mem_1_wrdata_w = mcif_mv_wrdata_w ;
          end
      2 : begin    fme_mv_mem_1_rdaddr_w = mc_mv_rdaddr_w   ;
          end
      0 : begin    fme_mv_mem_1_rdaddr_w = db_mv_rdaddr_w   ;
          end
    endcase
  end

  always @(*) begin
                   fme_mv_mem_2_rdaddr_w = 0 ;
                   fme_mv_mem_2_wren_w   = 0 ;
                   fme_mv_mem_2_wraddr_w = 0 ;
                   fme_mv_mem_2_wrdata_w = 0 ;
    case( sel_mod_3_r )
      2 : begin    fme_mv_mem_2_rdaddr_w = mcif_mv_rdaddr_w ;
                   fme_mv_mem_2_wren_w   = mcif_mv_wren_w   ;
                   fme_mv_mem_2_wraddr_w = mcif_mv_wraddr_w ;
                   fme_mv_mem_2_wrdata_w = mcif_mv_wrdata_w ;
          end
      0 : begin    fme_mv_mem_2_rdaddr_w = mc_mv_rdaddr_w   ;
          end
      1 : begin    fme_mv_mem_2_rdaddr_w = db_mv_rdaddr_w   ;
          end
    endcase
  end

  always @(*) begin
          mcif_mv_rddata_w = 0 ;
    case( sel_mod_3_r )
      0 : mcif_mv_rddata_w = fme_mv_mem_0_rddata_w ;
      1 : mcif_mv_rddata_w = fme_mv_mem_1_rddata_w ;
      2 : mcif_mv_rddata_w = fme_mv_mem_2_rddata_w ;
    endcase
  end

  top_rf_2p_20x64 fme_mv_mem_0 (
    .clka                 ( clk                    ),
    .cena_i               ( 1'b0                   ),
    .addra_i              ( fme_mv_mem_0_rdaddr_w  ),
    .dataa_o              ( fme_mv_mem_0_rddata_w  ),
    .clkb                 ( clk                    ),
    .cenb_i               ( 1'b0                   ),
    .wenb_i               ( !fme_mv_mem_0_wren_w   ),
    .addrb_i              ( fme_mv_mem_0_wraddr_w  ),
    .datab_i              ( fme_mv_mem_0_wrdata_w  )
    );

  top_rf_2p_20x64 fme_mv_mem_1 (
    .clka                 ( clk                    ),
    .cena_i               ( 1'b0                   ),
    .addra_i              ( fme_mv_mem_1_rdaddr_w  ),
    .dataa_o              ( fme_mv_mem_1_rddata_w  ),
    .clkb                 ( clk                    ),
    .cenb_i               ( 1'b0                   ),
    .wenb_i               ( !fme_mv_mem_1_wren_w   ),
    .addrb_i              ( fme_mv_mem_1_wraddr_w  ),
    .datab_i              ( fme_mv_mem_1_wrdata_w  )
    );

  top_rf_2p_20x64 fme_mv_mem_2 (
    .clka                 ( clk                    ),
    .cena_i               ( 1'b0                   ),
    .addra_i              ( fme_mv_mem_2_rdaddr_w  ),
    .dataa_o              ( fme_mv_mem_2_rddata_w  ),
    .clkb                 ( clk                    ),
    .cenb_i               ( 1'b0                   ),
    .wenb_i               ( !fme_mv_mem_2_wren_w   ),
    .addrb_i              ( fme_mv_mem_2_wraddr_w  ),
    .datab_i              ( fme_mv_mem_2_wrdata_w  )
    );


//-------------------------------------------------------------------
//
//          MC Block
//
//-------------------------------------------------------------------

  always @(posedge clk or negedge rst_n ) begin
    if( !rst_n )
      mc_partition_r <= 42'b0 ;
    else if( enc_start_i )  begin
      mc_partition_r <= imeif_partition_w ;
    end
  end

  always @(*) begin
          mc_mv_w = 0 ;
    case( sel_mod_3_r )
      1 : mc_mv_w = fme_mv_mem_0_rddata_w ;
      2 : mc_mv_w = fme_mv_mem_1_rddata_w ;
      0 : mc_mv_w = fme_mv_mem_2_rddata_w ;
    endcase
  end

  assign mc_pred_rdata_w = sel_r ? mc_pred_rdata_1_w : mc_pred_rdata_0_w ;

  mc_top u_mc_top(
    .clk                  ( clk                    ),
    .rstn                 ( rst_n                  ),
    // sys_if
    .mb_x_total_i         ( sys_x_total_i          ),
    .mb_y_total_i         ( sys_y_total_i          ),
    .sysif_start_i        ( mc_start_i             ),
    .sysif_cmb_x_i        ( mc_x_i                 ),
    .sysif_cmb_y_i        ( mc_y_i                 ),
    .sysif_qp_i           ( mc_qp_i                ),
    .sysif_done_o         ( mc_done_o              ),
    // ref_if
    .fetchif_rden_o       ( mc_ref_ren_o           ),
    .fetchif_idx_x_o      ( mc_ref_x_o             ),
    .fetchif_idx_y_o      ( mc_ref_y_o             ),
    .fetchif_sel_o        ( mc_ref_sel_o           ),
    .fetchif_pel_i        ( mc_ref_data_i          ),
    // fme_if
    .fmeif_partition_i    ( mc_partition_r         ),
    .fmeif_mv_i           ( mc_mv_w                ),
    .fmeif_mv_rden_o      ( mc_mv_rden_w           ),
    .fmeif_mv_rdaddr_o    ( mc_mv_rdaddr_w         ),
    // pre_wr_if
    .pred_wrdata_o        ( mc_pre_wrdata_w        ),
    .pred_wren_o          ( mc_pre_wren_w          ),
    .pred_wraddr_o        ( mc_pre_wraddr_w        ),
    // pre_rd_if
    .pred_ren_o           ( mc_pred_ren_w          ),
    .pred_size_o          ( mc_pred_size_w         ),
    .pred_4x4_x_o         ( mc_pred_4x4_x_w        ),
    .pred_4x4_y_o         ( mc_pred_4x4_y_w        ),
    .pred_4x4_idx_o       ( mc_pred_4x4_idx_w      ),
    .pred_rdata_i         ( mc_pred_rdata_w        ),
    // ec_if
    .mvd_wen_o            ( mc_mvd_wen_w           ),
    .mvd_waddr_o          ( mc_mvd_waddr_w         ),
    .mvd_wdata_o          ( mc_mvd_wdata_w         ),
    // tq_pre_if
    .pre_start_o          (                        ),
    .pre_en_o             ( mc_ppre_en             ),
    .pre_sel_o            ( mc_ppre_sel            ),
    .pre_size_o           ( mc_ppre_size           ),
    .pre_4x4_x_o          ( mc_ppre_4x4_x          ),
    .pre_4x4_y_o          ( mc_ppre_4x4_y          ),
    .pre_data_o           ( mc_ppre_data           ),
    // tq_rec_if
    .rec_val_i            ( rec_val & (sys_type_i==INTER)    ),
    .rec_idx_i            ( rec_idx                )
    );

  assign mc_mvd_mem_0_wren_w   = (sel_mod_3_r==0) ? mc_mvd_wen_w   : 0 ;
  assign mc_mvd_mem_0_wraddr_w = (sel_mod_3_r==0) ? mc_mvd_waddr_w : 0 ;
  assign mc_mvd_mem_0_wrdata_w = (sel_mod_3_r==0) ? mc_mvd_wdata_w : 0 ;

  assign mc_mvd_mem_1_wren_w   = (sel_mod_3_r==1) ? mc_mvd_wen_w   : 0 ;
  assign mc_mvd_mem_1_wraddr_w = (sel_mod_3_r==1) ? mc_mvd_waddr_w : 0 ;
  assign mc_mvd_mem_1_wrdata_w = (sel_mod_3_r==1) ? mc_mvd_wdata_w : 0 ;

  assign mc_mvd_mem_2_wren_w   = (sel_mod_3_r==2) ? mc_mvd_wen_w   : 0 ;
  assign mc_mvd_mem_2_wraddr_w = (sel_mod_3_r==2) ? mc_mvd_waddr_w : 0 ;
  assign mc_mvd_mem_2_wrdata_w = (sel_mod_3_r==2) ? mc_mvd_wdata_w : 0 ;

  assign mc_mvd_mem_0_rdaddr_w = ec_mvd_raddr_w ;
  assign mc_mvd_mem_1_rdaddr_w = ec_mvd_raddr_w ;
  assign mc_mvd_mem_2_rdaddr_w = ec_mvd_raddr_w ;

  top_rf_2p_23x64 mc_mvd_mem_0 (
    .clka                 ( clk                    ),
    .cena_i               ( 1'b0                   ),
    .addra_i              ( mc_mvd_mem_0_rdaddr_w  ),
    .dataa_o              ( mc_mvd_mem_0_rddata_w  ),
    .clkb                 ( clk                    ),
    .cenb_i               ( 1'b0                   ),
    .wenb_i               (!mc_mvd_mem_0_wren_w    ),
    .addrb_i              ( mc_mvd_mem_0_wraddr_w  ),
    .datab_i              ( mc_mvd_mem_0_wrdata_w  )
    );

  top_rf_2p_23x64 mc_mvd_mem_1 (
    .clka                 ( clk                    ),
    .cena_i               ( 1'b0                   ),
    .addra_i              ( mc_mvd_mem_1_rdaddr_w  ),
    .dataa_o              ( mc_mvd_mem_1_rddata_w  ),
    .clkb                 ( clk                    ),
    .cenb_i               ( 1'b0                   ),
    .wenb_i               (!mc_mvd_mem_1_wren_w    ),
    .addrb_i              ( mc_mvd_mem_1_wraddr_w  ),
    .datab_i              ( mc_mvd_mem_1_wrdata_w  )
    );

  top_rf_2p_23x64 mc_mvd_mem_2 (
    .clka                 ( clk                    ),
    .cena_i               ( 1'b0                   ),
    .addra_i              ( mc_mvd_mem_2_rdaddr_w  ),
    .dataa_o              ( mc_mvd_mem_2_rddata_w  ),
    .clkb                 ( clk                    ),
    .cenb_i               ( 1'b0                   ),
    .wenb_i               (!mc_mvd_mem_2_wren_w    ),
    .addrb_i              ( mc_mvd_mem_2_wraddr_w  ),
    .datab_i              ( mc_mvd_mem_2_wrdata_w  )
    );


//-------------------------------------------------------------------
//
//          MEM BUF Block
//
//-------------------------------------------------------------------

  assign ipre_en    = ( sys_type_i==INTRA ) ? intra_ipre_en    : mc_ppre_en    ;
  assign ipre_sel   = ( sys_type_i==INTRA ) ? intra_ipre_sel   : mc_ppre_sel   ;
  assign ipre_size  = ( sys_type_i==INTRA ) ? intra_ipre_size  : mc_ppre_size  ;
  assign ipre_4x4_x = ( sys_type_i==INTRA ) ? intra_ipre_4x4_x : mc_ppre_4x4_x ;
  assign ipre_4x4_y = ( sys_type_i==INTRA ) ? intra_ipre_4x4_y : mc_ppre_4x4_y ;
  assign ipre_data  = ( sys_type_i==INTRA ) ? intra_ipre_data  : mc_ppre_data  ;
  assign ipre_mode  = ( sys_type_i==INTRA ) ? intra_ipre_mode  : mc_ppre_mode  ;

  mem_buf u_mem_buf (
    .clk                 ( clk               ),
    .rst_n               ( rst_n             ),
    // sys_if
    .pre_start_i         ( enc_start_i       ),
    .pre_type_i          ( sys_type_i        ),
    // bank_if
    .pre_bank_i          ( 2'b0              ),
    .ec_bank_i           ( 2'b0              ),
    .db_bank_i           ( 2'b0              ),
    .pre_cbank_i         ( 1'b0              ),
    .ec_cbank_i          ( 1'b0              ),
    .db_cbank_i          ( 1'b0              ),
    // cur_if
    .cmb_sel_o           ( tq_cur_sel_o      ),
    .cmb_ren_o           ( tq_cur_ren_o      ),
    .cmb_size_o          ( tq_cur_size_o     ),
    .cmb_4x4_x_o         ( tq_cur_4x4_x_o    ),
    .cmb_4x4_y_o         ( tq_cur_4x4_y_o    ),
    .cmb_idx_o           ( tq_cur_idx_o      ),
    .cmb_data_i          ( tq_cur_data_i     ),
    // pre_if
    .ipre_min_size_i     ( pre_min_size_i    ),
    .ipre_en_i           ( ipre_en           ),
    .ipre_sel_i          ( ipre_sel          ),
    .ipre_size_i         ( ipre_size         ),
    .ipre_4x4_x_i        ( ipre_4x4_x        ),
    .ipre_4x4_y_i        ( ipre_4x4_y        ),
    .ipre_data_i         ( ipre_data         ),
    .ipre_mode_i         ( ipre_mode         ),
    .ipre_qp_i           ( intra_qp_i        ),
    // res_if
    .tq_res_en_o         ( tq_res_en         ),
    .tq_res_sel_o        ( tq_res_sel        ),
    .tq_res_size_o       ( tq_res_size       ),
    .tq_res_idx_o        ( tq_res_idx        ),
    .tq_res_data_o       ( tq_res_data       ),
    // rec_if
    .tq_rec_val_i        ( tq_rec_val        ),
    .tq_rec_idx_i        ( tq_rec_idx        ),
    .tq_rec_data_i       ( tq_rec_data       ),
    // cef_if
    .tq_cef_en_i         ( tq_cef_en         ),
    .tq_cef_rw_i         ( tq_cef_rw         ),
    .tq_cef_idx_i        ( tq_cef_idx        ),
    .tq_cef_data_i       ( tq_cef_wdata      ),
    .tq_cef_data_o       ( tq_cef_rdata      ),
    // rec_if
    .rec_val_o           ( rec_val           ),
    .rec_idx_o           ( rec_idx           ),
    .rec_data_o          ( rec_data          ),
    // mode_if
    .cover_valid_o       ( cover_valid       ),
    .cover_value_o       ( cover_value       ),
    // db_if
    .db_mem_ren_i        ( 1'b1              ), // !!!
    .db_mem_raddr_i      ( db_mem_raddr      ),
    .db_mem_rdata_o      ( db_mem_rdata      ),
    // ec_if
    .ec_mem_ren_i        ( 1'b1              ), // !!!
    .ec_mem_sel_i        ( ec_mem_sel        ),
    .ec_mem_raddr_i      ( ec_mem_raddr      ),
    .ec_mem_rdata_o      ( ec_mem_rdata      ),
    .ec_cbf_luma_o       ( db_cbf_luma       ),
    .ec_cbf_cb_o         ( db_cbf_cb         ),
    .ec_cbf_cr_o         ( db_cbf_cr         ),
    // pt_if
    .partition_old_o     ( partition_old     ),
    .partition_cur_o     ( partition_cur     ),
    // md_if
    .lm_md_renab_i       ( 1'b0              ), // !!!
    .lm_md_raddr_i       ( lm_md_raddr       ),
    .lm_md_rdata_o       ( lm_md_rdata       ),
    .cm_md_renab_i       ( 1'b0              ),
    .cm_md_raddr_i       ( 4'b0              ),
    .cm_md_rdata_o       (                   )
    );

  // mode
  always @(posedge clk or negedge rst_n ) begin
    if( !rst_n )
      lm_md_raddr <= 0 ;
    else if( enc_start_r )
      lm_md_raddr <= 1 ;
    else if( lm_md_raddr!=0 ) begin
      if( lm_md_raddr==63 )
        lm_md_raddr <= 0 ;
      else begin
        lm_md_raddr <= lm_md_raddr + 1 ;
      end
    end
  end

  always @(posedge clk or negedge rst_n ) begin
    if( !rst_n )
      lm_md_renab <= 0 ;
    else if( enc_start_r )
      lm_md_renab <= 1 ;
    else if( lm_md_raddr==63 ) begin
      lm_md_renab <= 0 ;
    end
  end

  always @(posedge clk or negedge rst_n ) begin
    if( !rst_n ) begin
      lm_md_renab_r <= 0 ;
      lm_md_raddr_r <= 0 ;
    end
    else begin
      lm_md_renab_r <= lm_md_renab | enc_start_r ;
      lm_md_raddr_r <= lm_md_raddr ;
    end
  end

  assign lm_md_mem_0_wren_w    = ( sel_r) ? lm_md_renab_r : 0 ;
  assign lm_md_mem_0_wraddr_w  = ( sel_r) ? lm_md_raddr_r : 0 ;
  assign lm_md_mem_0_wrdata_w  = ( sel_r) ? lm_md_rdata   : 0 ;

  assign lm_md_mem_1_wren_w    = (!sel_r) ? lm_md_renab_r : 0 ;
  assign lm_md_mem_1_wraddr_w  = (!sel_r) ? lm_md_raddr_r : 0 ;
  assign lm_md_mem_1_wrdata_w  = (!sel_r) ? lm_md_rdata   : 0 ;

  assign lm_md_mem_0_rden_w    = 1 ;
  assign lm_md_mem_0_rdaddr_w  = ec_lm_md_raddr ;

  assign lm_md_mem_1_rden_w    = 1 ;
  assign lm_md_mem_1_rdaddr_w  = ec_lm_md_raddr ;

  top_rf_2p_24x64 tq_md_ram_0 (
    .clkb       ( clk                     ),
    .cenb_i     ( 1'b0                    ),
    .wenb_i     (!lm_md_mem_0_wren_w      ),
    .addrb_i    ( lm_md_mem_0_wraddr_w    ),
    .datab_i    ( lm_md_mem_0_wrdata_w    ),
    .clka       ( clk                     ),
    .cena_i     (!lm_md_mem_0_rden_w      ),
    .addra_i    ( lm_md_mem_0_rdaddr_w    ),
    .dataa_o    ( lm_md_mem_0_rddata_w    )
    );

  top_rf_2p_24x64 tq_md_ram_1 (
    .clkb       ( clk                     ),
    .cenb_i     ( 1'b0                    ),
    .wenb_i     (!lm_md_mem_1_wren_w      ),
    .addrb_i    ( lm_md_mem_1_wraddr_w    ),
    .datab_i    ( lm_md_mem_1_wrdata_w    ),
    .clka       ( clk                     ),
    .cena_i     (!lm_md_mem_1_rden_w      ),
    .addra_i    ( lm_md_mem_1_rdaddr_w    ),
    .dataa_o    ( lm_md_mem_1_rddata_w    )
    );

  // coe
  always @(posedge clk or negedge rst_n ) begin
    if( !rst_n )
      ec_mem_raddr <= 0 ;
    else if( enc_start_r[9] )
      ec_mem_raddr <= 1 ;
    else if( (ec_mem_raddr!=0)|(ec_mem_sel!=2) ) begin
      case( ec_mem_sel )
        2 : if( ec_mem_raddr==255 ) ec_mem_raddr <= 0 ; else ec_mem_raddr <= ec_mem_raddr + 1 ;
        1 : if( ec_mem_raddr==63  ) ec_mem_raddr <= 0 ; else ec_mem_raddr <= ec_mem_raddr + 1 ;
        0 : if( ec_mem_raddr==63  ) ec_mem_raddr <= 0 ; else ec_mem_raddr <= ec_mem_raddr + 1 ;
      endcase
    end
  end

  always @(posedge clk or negedge rst_n ) begin
    if( !rst_n )
      ec_mem_sel <= 2 ;
    else begin
      case( ec_mem_sel )
        2 : if( ec_mem_raddr==255 ) ec_mem_sel <= 1 ;
        1 : if( ec_mem_raddr==63  ) ec_mem_sel <= 0 ;
        0 : if( ec_mem_raddr==63  ) ec_mem_sel <= 2 ;
      endcase
    end
  end

  always @(posedge clk or negedge rst_n ) begin
    if( !rst_n )
      ec_mem_ren <= 0 ;
    else if( enc_start_r[9] )
      ec_mem_ren <= 1 ;
    else if( (ec_mem_raddr==63)&(ec_mem_sel==0) ) begin
      ec_mem_ren <= 0 ;
    end
  end

  always @(posedge clk or negedge rst_n ) begin
    if( !rst_n ) begin
      ec_mem_ren_r   <= 0 ;
      ec_mem_raddr_r <= 0 ;
      ec_mem_sel_r   <= 0 ;
    end
    else begin
      ec_mem_ren_r   <= ec_mem_ren|enc_start_r[9] ;
      ec_mem_raddr_r <= ec_mem_raddr              ;
      ec_mem_sel_r   <= ec_mem_sel                ;
    end
  end

  assign lm_coe_mem_0_wren_w    = ( sel_r) ? ec_mem_ren_r : 0 ;
  assign lm_coe_mem_0_wraddr_w  = ( sel_r) ? (ec_mem_sel_r==1)*256+(ec_mem_sel_r==0)*320+ec_mem_raddr_r : 0 ;
  assign lm_coe_mem_0_wrdata_w  = ( sel_r) ? ec_mem_rdata : 0 ;

  assign lm_coe_mem_1_wren_w    = (!sel_r) ? ec_mem_ren_r : 0 ;
  assign lm_coe_mem_1_wraddr_w  = (!sel_r) ? (ec_mem_sel_r==1)*256+(ec_mem_sel_r==0)*320+ec_mem_raddr_r : 0 ;
  assign lm_coe_mem_1_wrdata_w  = (!sel_r) ? ec_mem_rdata : 0 ;

  assign lm_coe_mem_0_rden_w    = 1 ;
  assign lm_coe_mem_0_rdaddr_w  = (ec_mem_sel_w==1)*256+(ec_mem_sel_w==0)*320+ec_mem_raddr_w ;

  assign lm_coe_mem_1_rden_w    = 1 ;
  assign lm_coe_mem_1_rdaddr_w  = (ec_mem_sel_w==1)*256+(ec_mem_sel_w==0)*320+ec_mem_raddr_w ;


  top_rf_2p_256x512 tq_coe_ram_0 (
    .clkb       ( clk                      ),
    .cenb_i     ( 1'b0                     ),
    .wenb_i     (!lm_coe_mem_0_wren_w      ),
    .addrb_i    ( lm_coe_mem_0_wraddr_w    ),
    .datab_i    ( lm_coe_mem_0_wrdata_w    ),
    .clka       ( clk                      ),
    .cena_i     (!lm_coe_mem_0_rden_w      ),
    .addra_i    ( lm_coe_mem_0_rdaddr_w    ),
    .dataa_o    ( lm_coe_mem_0_rddata_w    )
    );


  top_rf_2p_256x512 tq_coe_ram_1 (
    .clkb       ( clk                      ),
    .cenb_i     ( 1'b0                     ),
    .wenb_i     (!lm_coe_mem_1_wren_w      ),
    .addrb_i    ( lm_coe_mem_1_wraddr_w    ),
    .datab_i    ( lm_coe_mem_1_wrdata_w    ),
    .clka       ( clk                      ),
    .cena_i     (!lm_coe_mem_1_rden_w      ),
    .addra_i    ( lm_coe_mem_1_rdaddr_w    ),
    .dataa_o    ( lm_coe_mem_1_rddata_w    )
    );




//-------------------------------------------------------------------
//
//          TQ Block
//
//-------------------------------------------------------------------

  // tq_qp
  wire [5  : 0]    tq_qp   ;
  reg  [5  : 0]    tq_qp_c ;
  wire [5  : 0]    tq_qp_w ;

  assign tq_qp      = ( sys_type_i==INTRA ) ? intra_qp_i : mc_qp_i ;
  assign tq_cef_en  = tq_cef_ren | tq_cef_wen ;
  assign tq_cef_rw  = tq_cef_wen ? 1'b1: 1'b0 ;
  assign tq_cef_idx = tq_cef_wen ? tq_cef_widx : tq_cef_ridx ;

  always @(*) begin
    tq_qp_c = tq_qp ;
    if( tq_qp>43 )
      tq_qp_c = tq_qp-6 ;
    else if( tq_qp<30 )
      tq_qp_c = tq_qp ;
    else begin
      case( tq_qp )
        30      : tq_qp_c = 6'd29 ;
        31      : tq_qp_c = 6'd30 ;
        32      : tq_qp_c = 6'd31 ;
        33      : tq_qp_c = 6'd32 ;
        34      : tq_qp_c = 6'd33 ;
        35      : tq_qp_c = 6'd33 ;
        36      : tq_qp_c = 6'd34 ;
        37      : tq_qp_c = 6'd34 ;
        38      : tq_qp_c = 6'd35 ;
        39      : tq_qp_c = 6'd35 ;
        40      : tq_qp_c = 6'd36 ;
        41      : tq_qp_c = 6'd36 ;
        42      : tq_qp_c = 6'd37 ;
        43      : tq_qp_c = 6'd37 ;
        default : tq_qp_c = 6'hxx ;
      endcase
    end
  end

  assign tq_qp_w = ( tq_res_sel==2'b00 ) ? tq_qp : tq_qp_c ;  // still missing inter one

  tq_top u_tq_top(
    .clk                 ( clk             ),
    .rst                 ( rst_n           ),
    .type_i              ( sys_type_i      ),
    .qp_i                ( tq_qp_w         ),

    .tq_en_i             ( tq_res_en       ),
    .tq_sel_i            ( tq_res_sel      ),
    .tq_size_i           ( tq_res_size     ),
    .tq_idx_i            ( tq_res_idx      ),
    .tq_res_i            ( tq_res_data     ),

    .rec_val_o           ( tq_rec_val      ),
    .rec_idx_o           ( tq_rec_idx      ),
    .rec_data_o          ( tq_rec_data     ),

    .cef_ren_o           ( tq_cef_ren      ),
    .cef_ridx_o          ( tq_cef_ridx     ),
    .cef_data_i          ( tq_cef_rdata    ),

    .cef_wen_o           ( tq_cef_wen      ),
    .cef_widx_o          ( tq_cef_widx     ),
    .cef_data_o          ( tq_cef_wdata    )
    );

//-------------------------------------------------------------------
//
//    deblocking module
//
//-------------------------------------------------------------------

  reg  [2*`FMV_WIDTH-1 : 0]    mb_mv_rdata ;
  reg  [128-1          : 0]    tq_ori_data ;

  always @(posedge clk or negedge rst_n ) begin
    if( !rst_n )
      db_inter_partition_r <= 42'b0 ;
    else if( enc_start_i ) begin
      db_inter_partition_r <= mc_partition_r ;
    end
  end

  assign db_intra_partition_w = (sys_type_i==INTRA) ? partition_old
                                                    : { db_inter_partition_r[41]&db_inter_partition_r[40]
                                                       ,db_inter_partition_r[39]&db_inter_partition_r[38]
                                                       ,db_inter_partition_r[37]&db_inter_partition_r[36]
                                                       ,db_inter_partition_r[35]&db_inter_partition_r[34]
                                                       ,db_inter_partition_r[33]&db_inter_partition_r[32]
                                                       ,db_inter_partition_r[31]&db_inter_partition_r[30]
                                                       ,db_inter_partition_r[29]&db_inter_partition_r[28]
                                                       ,db_inter_partition_r[27]&db_inter_partition_r[26]
                                                       ,db_inter_partition_r[25]&db_inter_partition_r[24]
                                                       ,db_inter_partition_r[23]&db_inter_partition_r[22]
                                                       ,db_inter_partition_r[21]&db_inter_partition_r[20]
                                                       ,db_inter_partition_r[19]&db_inter_partition_r[18]
                                                       ,db_inter_partition_r[17]&db_inter_partition_r[16]
                                                       ,db_inter_partition_r[15]&db_inter_partition_r[14]
                                                       ,db_inter_partition_r[13]&db_inter_partition_r[12]
                                                       ,db_inter_partition_r[11]&db_inter_partition_r[10]
                                                       ,db_inter_partition_r[09]&db_inter_partition_r[08]
                                                       ,db_inter_partition_r[07]&db_inter_partition_r[06]
                                                       ,db_inter_partition_r[05]&db_inter_partition_r[04]
                                                       ,db_inter_partition_r[03]&db_inter_partition_r[02]
                                                       ,db_inter_partition_r[01]&db_inter_partition_r[00]
                                                      };

  always @(*) begin
          db_mv_w = 0 ;
    case( sel_mod_3_r )
      2 : db_mv_w = { fme_mv_mem_0_rddata_w[9:0] ,fme_mv_mem_0_rddata_w[19:10] };
      0 : db_mv_w = { fme_mv_mem_1_rddata_w[9:0] ,fme_mv_mem_1_rddata_w[19:10] };
      1 : db_mv_w = { fme_mv_mem_2_rddata_w[9:0] ,fme_mv_mem_2_rddata_w[19:10] };
    endcase
  end

  assign db_mv_rdaddr_w = { db_mv_rdaddr_ori_w[5]
                           ,db_mv_rdaddr_ori_w[3]
                           ,db_mv_rdaddr_ori_w[1]
                           ,db_mv_rdaddr_ori_w[4]
                           ,db_mv_rdaddr_ori_w[2]
                           ,db_mv_rdaddr_ori_w[0]
                          };

  db_top u_db_top(
    .clk                 ( clk                  ),
    .rst_n               ( rst_n                ),
    // sys_if
    .mb_x_total_i        ( sys_x_total_i        ),
    .mb_y_total_i        ( sys_y_total_i        ),
    .mb_type_i           ( sys_type_i==INTRA    ),
    .start_i             ( db_start_i           ),
    .mb_x_i              ( db_x_i               ),
    .mb_y_i              ( db_y_i               ),
    .qp_i                ( db_qp_i              ),
    .done_o              ( db_done_o            ),
    // mc_if
    .mb_partition_i      ( db_intra_partition_w ),
    .mb_p_pu_mode_i      ( db_inter_partition_r ),
    // fme_if
    .mb_mv_ren_o         ( db_mv_rden_w         ),
    .mb_mv_raddr_o       ( db_mv_rdaddr_ori_w   ),
    .mb_mv_rdata_i       ( db_mv_w              ),
    // tq_if
    .mb_cbf_i            ( db_cbf_luma          ),
    .mb_cbf_u_i          ( (sys_type_i==INTRA) ? db_cbf_cb : db_cbf_cr ),
    .mb_cbf_v_i          ( (sys_type_i==INTRA) ? db_cbf_cr : db_cbf_cb ),
    .tq_ren_o            ( db_mem_ren           ),
    .tq_raddr_o          ( db_mem_raddr         ),
    .tq_rdata_i          ( db_mem_rdata         ),
    .tq_ori_data_i       ( tq_ori_data          ),    // fake (for sao)
    // rec_if
    .db_wen_o            ( db_wen_o             ),
    .db_w4x4_x_o         ( db_w4x4_x_o          ),
    .db_w4x4_y_o         ( db_w4x4_y_o          ),
    .db_wprevious_o      ( db_wprevious_o       ),
    .db_wdone_o          ( db_wdone_o           ),
    .db_wsel_o           ( db_wsel_o            ),
    .db_wdata_o          ( db_wdata_o           ),
    .mb_db_ren_o         ( db_ren_o             ),
    .mb_db_r4x4_o        ( db_r4x4_o            ),
    .mb_db_ridx_o        ( db_ridx_o            ),
    .mb_db_data_i        ( db_rdata_i           ),
    .mb_db_en_o          (                      ),
    .mb_db_rw_o          (                      ),
    .mb_db_addr_o        (                      ),
    .mb_db_data_o        (                      )
    );


//-------------------------------------------------------------------
//
//          EC Block
//
//-------------------------------------------------------------------

  // partition
  always @(posedge clk or negedge rst_n ) begin
    if( !rst_n ) begin
      ec_partition_0_r <= 42'b0 ;
      ec_partition_1_r <= 42'b0 ;
    end
    else if( enc_start_i )  begin
      ec_partition_0_r <= mc_partition_r ;
      ec_partition_1_r <= ec_partition_0_r ;
    end
  end

  // mvd
  always @(*) begin
          ec_mvd_rdata_w = mc_mvd_mem_1_rddata_w ;
    case( sel_mod_3_r )
      0 : ec_mvd_rdata_w = mc_mvd_mem_1_rddata_w ;
      1 : ec_mvd_rdata_w = mc_mvd_mem_2_rddata_w ;
      2 : ec_mvd_rdata_w = mc_mvd_mem_0_rddata_w ;
    endcase
  end

  // cbf
  always @(posedge clk or negedge rst_n ) begin
    if( !rst_n ) begin
      ec_cbf_luma      <= 0 ;
      ec_cbf_cb        <= 0 ;
      ec_cbf_cr        <= 0 ;
      ec_partition_old <= 0 ;
    end
    else if( enc_start_i ) begin
      ec_cbf_luma      <= db_cbf_luma   ;
      ec_cbf_cb        <= db_cbf_cb     ;
      ec_cbf_cr        <= db_cbf_cr     ;
      ec_partition_old <= partition_old ;
    end
  end

  // mode
  assign ec_lm_md_rdata = sel_r ? lm_md_mem_1_rddata_w : lm_md_mem_0_rddata_w ;

  // coe
  assign ec_mem_rdata_w = sel_r ? lm_coe_mem_1_rddata_w : lm_coe_mem_0_rddata_w ;

  cabac_top u_cabac_top(
    .clk                     ( clk               ),
    .rst_n                   ( rst_n             ),
    // sys_if
    .mb_x_total_i            ( sys_x_total_i     ),
    .mb_y_total_i            ( sys_y_total_i     ),
    .mb_type_i               ( (sys_type_i==INTRA)    ),
    .sao_i                   ( 62'b0             ),
    .start_i                 ( ec_start_i        ),
    .mb_x_i                  ( ec_x_i            ),
    .mb_y_i                  ( ec_y_i            ),
    .param_qp_i              ( (sys_type_i==INTRA) ? (ec_qp_i)  : (ec_qp_i+6'd3)    ),
    .qp_i                    ( ec_qp_i           ),
    .done_o                  ( ec_done_o         ),
    .slice_done_o            (                   ),
    // tq_coe_if
    .tq_ren_o                ( ec_mem_ren_w      ),
    .coeff_type_o            ( ec_mem_sel_w      ),
    .tq_raddr_o              ( ec_mem_raddr_w    ),
    .tq_rdata_i              ( ec_mem_rdata_w    ),
    // tq_cbf_if
    .tq_cbf_luma_i           ( ec_cbf_luma       ),
    .tq_cbf_cb_i             ( ec_cbf_cb         ),
    .tq_cbf_cr_i             ( ec_cbf_cr         ),
    .mb_partition_i          ( {64'b0 ,ec_partition_old }    ),
    // tq_md_if
    .cu_luma_mode_ren_o      ( ec_lm_md_renab    ),
    .cu_luma_mode_raddr_o    ( ec_lm_md_raddr    ),
    .luma_mode_i             ( ec_lm_md_rdata    ),
    .cu_chroma_mode_ren_o    (                   ),
    .cu_chroma_mode_raddr_o  (                   ),
    .chroma_mode_i           ( 24'h924924        ),
    .merge_flag_i            ( 85'd0             ),
    .merge_idx_i             ( 256'd0            ),
    .cu_skip_flag_i          ( 85'd0             ),
    // tq_pt_if
    .mb_p_pu_mode_i          ({{(`INTER_CU_INFO_LEN-42){1'b0}},ec_partition_1_r}    ),
    // fme_if
    .mb_mvd_ren_o            ( ec_mvd_ren_w      ),
    .mb_mvd_raddr_o          ( ec_mvd_raddr_w    ),
    .mb_mvd_rdata_i          ( ec_mvd_rdata_w    ),
    // bs_if
    .bs_val_o                ( ec_bs_val_o       ),
    .bs_data_o               ( ec_bs_dat_o       ),
    .bs_wait_i               ( 1'd1              )
    );

endmodule
