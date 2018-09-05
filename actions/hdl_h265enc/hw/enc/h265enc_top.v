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
//  Filename      : h265enc_top.v
//  Author        : Huang Leilei
//  Created       : 2016-03-20
//  Description   : top of h265enc, including sys_ctrl, enc_core and fetch
//
//-------------------------------------------------------------------
//
//  Modified      : 2016-03-22
//  Description   : fetch replaced with fetch_top
//
//-------------------------------------------------------------------

`include "enc_defines.v"

module h265enc_top(
  // global
  clk               ,
  rst_n             ,
  // config
  sys_start_i       ,
  sys_type_i        ,
  pre_min_size_i    ,
  sys_x_total_i     ,
  sys_y_total_i     ,
  sys_qp_i          ,
  sys_done_o        ,
  // ext
  extif_start_o     ,
  extif_done_i      ,
  extif_mode_o      ,
  extif_x_o         ,
  extif_y_o         ,
  extif_width_o     ,
  extif_height_o    ,
  extif_wren_i      ,
  extif_rden_i      ,
  extif_data_i      ,
  extif_data_o      ,
  // bs
  bs_val_o          ,
  bs_dat_o
  );


//*** PARAMETER ****************************************************************

  parameter                             INTRA = 0             ,
                                        INTER = 1             ;


//*** WIRE/REG DECLARATION *****************************************************

  // GLOBAL
  input                                 clk                   ;
  input                                 rst_n                 ;

  // CONFIG
  input                                 sys_start_i           ;
  output                                sys_done_o            ;
  input      [`PIC_X_WIDTH-1    : 0]    sys_x_total_i         ;
  input      [`PIC_Y_WIDTH-1    : 0]    sys_y_total_i         ;
  input      [5                 : 0]    sys_qp_i              ;
  input                                 sys_type_i            ;
  input                                 pre_min_size_i        ;

  // EXT_IF
  output     [1-1               : 0]    extif_start_o         ;
  input      [1-1               : 0]    extif_done_i          ;
  output     [5-1               : 0]    extif_mode_o          ;
  output     [6+`PIC_X_WIDTH-1  : 0]    extif_x_o             ;
  output     [6+`PIC_Y_WIDTH-1  : 0]    extif_y_o             ;
  output     [8-1               : 0]    extif_width_o         ;
  output     [8-1               : 0]    extif_height_o        ;
  input                                 extif_wren_i          ;
  input                                 extif_rden_i          ;
  input      [16*`PIXEL_WIDTH-1 : 0]    extif_data_i          ;
  output     [16*`PIXEL_WIDTH-1 : 0]    extif_data_o          ;

  // BS
  output                                bs_val_o              ;
  output     [7                 : 0]    bs_dat_o              ;


//*** WIRE/REG DECLARATION *****************************************************

  // FETCH_SYS_IF
  wire                                  pre_l_start           ;
  wire       [`PIC_X_WIDTH-1    : 0]    pre_l_x               ;
  wire       [`PIC_Y_WIDTH-1    : 0]    pre_l_y               ;
  wire       [5                 : 0]    pre_l_qp              ;

  // PRE_I_SYS_IF
  wire                                  pre_i_start           ;
  wire       [`PIC_X_WIDTH-1    : 0]    pre_i_x               ;
  wire       [`PIC_Y_WIDTH-1    : 0]    pre_i_y               ;
  wire       [5                 : 0]    pre_i_qp              ;
  wire                                  pre_i_done            ;
  // PRE_I_CUR_IF
  wire       [3                 : 0]    pre_i_cur_4x4_x       ;
  wire       [3                 : 0]    pre_i_cur_4x4_y       ;
  wire       [5-1               : 0]    pre_i_cur_idx         ;
  wire                                  pre_i_cur_sel         ;
  wire       [2-1               : 0]    pre_i_cur_size        ;
  wire                                  pre_i_cur_ren         ;
  wire       [32*`PIXEL_WIDTH-1 : 0]    pre_i_cur_data        ;

  // INTRA_SYS_IF
  wire                                  intra_start           ;
  wire       [`PIC_X_WIDTH-1    : 0]    intra_x               ;
  wire       [`PIC_Y_WIDTH-1    : 0]    intra_y               ;
  wire       [5                 : 0]    intra_qp              ;
  wire                                  intra_done            ;

  // IME_SYS_IF
  wire                                  ime_start             ;
  wire       [`PIC_X_WIDTH-1    : 0]    ime_x                 ;
  wire       [`PIC_Y_WIDTH-1    : 0]    ime_y                 ;
  wire       [5                 : 0]    ime_qp                ;
  wire                                  ime_done              ;
  // IME_CUR_IF
  wire       [4-1               : 0]    ime_cur_4x4_x         ;
  wire       [4-1               : 0]    ime_cur_4x4_y         ;
  wire       [5-1               : 0]    ime_cur_idx           ;
  wire                                  ime_cur_sel           ;
  wire       [3-1               : 0]    ime_cur_size          ;
  wire                                  ime_cur_ren           ;
  wire       [64*`PIXEL_WIDTH-1 : 0]    ime_cur_data          ;
  // IME_REF_IF
  wire       [5-1               : 0]    ime_ref_x             ;
  wire       [7-1               : 0]    ime_ref_y             ;
  wire                                  ime_ref_ren           ;
  wire       [64*`PIXEL_WIDTH-1 : 0]    ime_ref_data          ;

  // FME_CUR_IF
  wire       [4-1               : 0]    fme_cur_4x4_x         ;
  wire       [4-1               : 0]    fme_cur_4x4_y         ;
  wire       [5-1               : 0]    fme_cur_idx           ;
  wire                                  fme_cur_sel           ;
  wire       [2-1               : 0]    fme_cur_size          ;
  wire                                  fme_cur_ren           ;
  wire       [32*`PIXEL_WIDTH-1 : 0]    fme_cur_data          ;

  // FME_SYS_IF
  wire                                  fme_start             ;
  wire       [`PIC_X_WIDTH-1    : 0]    fme_x                 ;
  wire       [`PIC_Y_WIDTH-1    : 0]    fme_y                 ;
  wire       [5                 : 0]    fme_qp                ;
  wire                                  fme_done              ;
  // FME_REF_IF
  wire       [7-1               : 0]    fme_ref_x             ;
  wire       [7-1               : 0]    fme_ref_y             ;
  wire                                  fme_ref_ren           ;
  wire       [64*`PIXEL_WIDTH-1 : 0]    fme_ref_data          ;

  // MC_SYS_IF
  wire                                  mc_start              ;
  wire       [`PIC_X_WIDTH-1    : 0]    mc_x                  ;
  wire       [`PIC_Y_WIDTH-1    : 0]    mc_y                  ;
  wire       [5                 : 0]    mc_qp                 ;
  wire                                  mc_done               ;
  // MC_REF_IF
  wire       [6-1               : 0]    mc_ref_x              ;
  wire       [6-1               : 0]    mc_ref_y              ;
  wire                                  mc_ref_ren            ;
  wire                                  mc_ref_sel            ;
  wire       [8*`PIXEL_WIDTH-1  : 0]    mc_ref_data           ;

  // TQ_CUR_IF
  wire       [3                 : 0]    tq_cur_4x4_x          ;
  wire       [3                 : 0]    tq_cur_4x4_y          ;
  wire       [5-1               : 0]    tq_cur_idx            ;
  wire                                  tq_cur_sel            ;
  wire       [2-1               : 0]    tq_cur_size           ;
  wire                                  tq_cur_ren            ;
  wire       [`PIXEL_WIDTH*32-1 : 0]    tq_cur_data           ;

  // DB_SYS_IF
  wire                                  db_start              ;
  wire       [`PIC_X_WIDTH-1    : 0]    db_x                  ;
  wire       [`PIC_Y_WIDTH-1    : 0]    db_y                  ;
  wire       [5                 : 0]    db_qp                 ;
  wire                                  db_done               ;
  // DB_FETCH_IF
  wire       [1-1               : 0]    db_wen                ;
  wire       [5-1               : 0]    db_w4x4_x             ;
  wire       [5-1               : 0]    db_w4x4_y             ;
  wire       [1-1               : 0]    db_wprevious          ;
  wire       [2-1               : 0]    db_wsel               ;
  wire       [16*`PIXEL_WIDTH-1 : 0]    db_wdata              ;
  wire       [1-1               : 0]    db_ren                ;
  wire       [5-1               : 0]    db_r4x4               ;
  wire       [2-1               : 0]    db_ridx               ;
  wire       [4*`PIXEL_WIDTH-1  : 0]    db_rdata              ;

  // EC_SYS_IF
  wire                                  ec_start              ;
  wire       [`PIC_X_WIDTH-1    : 0]    ec_x                  ;
  wire       [`PIC_Y_WIDTH-1    : 0]    ec_y                  ;
  wire       [5                 : 0]    ec_qp                 ;
  wire                                  ec_done               ;

  // STORE_DB_SYS_IF
  wire                                  store_db_start        ;
  wire       [`PIC_X_WIDTH-1    : 0]    store_db_x            ;
  wire       [`PIC_Y_WIDTH-1    : 0]    store_db_y            ;
  wire       [5                 : 0]    store_db_qp           ;
  wire                                  store_db_done         ;

  // FETCH
  wire                                  fetch_done            ;
  wire                                  load_cur_luma_ena     ;
  wire                                  load_ref_luma_ena     ;
  wire                                  load_cur_chroma_ena   ;
  wire                                  load_ref_chroma_ena   ;
  wire                                  load_db_luma_ena      ;
  wire                                  load_db_chroma_ena    ;
  wire                                  store_db_luma_ena     ;
  wire                                  store_db_chroma_ena   ;
  wire       [`PIC_X_WIDTH-1    : 0]    load_cur_luma_x       ;
  wire       [`PIC_Y_WIDTH-1    : 0]    load_cur_luma_y       ;
  wire       [`PIC_X_WIDTH-1    : 0]    load_ref_luma_x       ;
  wire       [`PIC_Y_WIDTH-1    : 0]    load_ref_luma_y       ;
  wire       [`PIC_X_WIDTH-1    : 0]    load_cur_chroma_x     ;
  wire       [`PIC_Y_WIDTH-1    : 0]    load_cur_chroma_y     ;
  wire       [`PIC_X_WIDTH-1    : 0]    load_ref_chroma_x     ;
  wire       [`PIC_Y_WIDTH-1    : 0]    load_ref_chroma_y     ;
  wire       [`PIC_X_WIDTH-1    : 0]    load_db_luma_x        ;
  wire       [`PIC_Y_WIDTH-1    : 0]    load_db_luma_y        ;
  wire       [`PIC_X_WIDTH-1    : 0]    load_db_chroma_x      ;
  wire       [`PIC_Y_WIDTH-1    : 0]    load_db_chroma_y      ;
  wire       [`PIC_X_WIDTH-1    : 0]    store_db_luma_x       ;
  wire       [`PIC_Y_WIDTH-1    : 0]    store_db_luma_y       ;
  wire       [`PIC_X_WIDTH-1    : 0]    store_db_chroma_x     ;
  wire       [`PIC_Y_WIDTH-1    : 0]    store_db_chroma_y     ;


//*** DUT DECLARATION **********************************************************


//--- SYS_CTRL -----------------------------------

  sys_ctrl u_sys_ctrl(
    // global
    .clk                   ( clk                  ),
    .rst_n                 ( rst_n                ),
    // sys_if
    .sys_start_i           ( sys_start_i          ),
    .sys_type_i            ( sys_type_i           ),
    .sys_x_total_i         ( sys_x_total_i        ),
    .sys_y_total_i         ( sys_y_total_i        ),
    .sys_qp_i              ( sys_qp_i             ),
    .sys_done_o            ( sys_done_o           ),
    // start_if
    .enc_start_o           ( enc_start            ),
    // done_if
    .fetch_done_i          ( fetch_done           ),
    .pre_i_done_i          ( pre_i_done           ),
    .intra_done_i          ( intra_done           ),
    .ime_done_i            ( ime_done             ),
    .fme_done_i            ( fme_done             ),
    .mc_done_i             ( mc_done              ),
    .db_done_i             ( db_done              ),
    .ec_done_i             ( ec_done              ),
    // start for enc_core
    .pre_l_start_o         ( pre_l_start          ),
    .pre_i_start_o         ( pre_i_start          ),
    .intra_start_o         ( intra_start          ),
    .ime_start_o           ( ime_start            ),
    .fme_start_o           ( fme_start            ),
    .mc_start_o            ( mc_start             ),
    .db_start_o            ( db_start             ),
    .ec_start_o            ( ec_start             ),
    .store_db_start_o      ( store_db_start       ),
    // x & y for enc_core
    .pre_l_x_o             ( pre_l_x              ),
    .pre_l_y_o             ( pre_l_y              ),
    .pre_i_x_o             ( pre_i_x              ),
    .pre_i_y_o             ( pre_i_y              ),
    .intra_x_o             ( intra_x              ),
    .intra_y_o             ( intra_y              ),
    .ime_x_o               ( ime_x                ),
    .ime_y_o               ( ime_y                ),
    .fme_x_o               ( fme_x                ),
    .fme_y_o               ( fme_y                ),
    .mc_x_o                ( mc_x                 ),
    .mc_y_o                ( mc_y                 ),
    .db_x_o                ( db_x                 ),
    .db_y_o                ( db_y                 ),
    .ec_x_o                ( ec_x                 ),
    .ec_y_o                ( ec_y                 ),
    .store_db_x_o          ( store_db_x           ),
    .store_db_y_o          ( store_db_y           ),
    // qp for enc_core
    .pre_l_qp_o            ( pre_l_qp             ),
    .pre_i_qp_o            ( pre_i_qp             ),
    .intra_qp_o            ( intra_qp             ),
    .ime_qp_o              ( ime_qp               ),
    .fme_qp_o              ( fme_qp               ),
    .mc_qp_o               ( mc_qp                ),
    .db_qp_o               ( db_qp                ),
    .ec_qp_o               ( ec_qp                ),
    .store_db_qp_o         ( store_db_qp          ),
    // enc for fetch
    .load_cur_luma_ena_o   ( load_cur_luma_ena    ),
    .load_ref_luma_ena_o   ( load_ref_luma_ena    ),
    .load_cur_chroma_ena_o ( load_cur_chroma_ena  ),
    .load_ref_chroma_ena_o ( load_ref_chroma_ena  ),
    .load_db_luma_ena_o    ( load_db_luma_ena     ),
    .load_db_chroma_ena_o  ( load_db_chroma_ena   ),
    .store_db_luma_ena_o   ( store_db_luma_ena    ),
    .store_db_chroma_ena_o ( store_db_chroma_ena  ),
    // x & y for fetch
    .load_cur_luma_x_o     ( load_cur_luma_x      ),
    .load_cur_luma_y_o     ( load_cur_luma_y      ),
    .load_ref_luma_x_o     ( load_ref_luma_x      ),
    .load_ref_luma_y_o     ( load_ref_luma_y      ),
    .load_cur_chroma_x_o   ( load_cur_chroma_x    ),
    .load_cur_chroma_y_o   ( load_cur_chroma_y    ),
    .load_ref_chroma_x_o   ( load_ref_chroma_x    ),
    .load_ref_chroma_y_o   ( load_ref_chroma_y    ),
    .load_db_luma_x_o      ( load_db_luma_x       ),
    .load_db_luma_y_o      ( load_db_luma_y       ),
    .load_db_chroma_x_o    ( load_db_chroma_x     ),
    .load_db_chroma_y_o    ( load_db_chroma_y     ),
    .store_db_luma_x_o     ( store_db_luma_x      ),
    .store_db_luma_y_o     ( store_db_luma_y      ),
    .store_db_chroma_x_o   ( store_db_chroma_x    ),
    .store_db_chroma_y_o   ( store_db_chroma_y    )
    );


//--- FETCH --------------------------------------

  fetch_top u_fetch_top (
    .clk                   ( clk                  ),
    .rstn                  ( rst_n                ),
    // sys_if
    .sysif_type_i          ( sys_type_i           ),
    .sysif_total_x_i       ( sys_x_total_i        ),
    .sysif_total_y_i       ( sys_y_total_i        ),
    // ctrl_if
    .sysif_start_i         ( enc_start            ),
    .sysif_done_o          ( fetch_done           ),
    .load_cur_luma_ena_i   ( load_cur_luma_ena    ),
    .load_ref_luma_ena_i   ( load_ref_luma_ena    ),
    .load_cur_chroma_ena_i ( load_cur_chroma_ena  ),
    .load_ref_chroma_ena_i ( load_ref_chroma_ena  ),
    .load_db_luma_ena_i    ( load_db_luma_ena     ),
    .load_db_chroma_ena_i  ( load_db_chroma_ena   ),
    .store_db_luma_ena_i   ( store_db_luma_ena    ),
    .store_db_chroma_ena_i ( store_db_chroma_ena  ),
    .load_cur_luma_x_i     ( load_cur_luma_x      ),
    .load_cur_luma_y_i     ( load_cur_luma_y      ),
    .load_ref_luma_x_i     ( load_ref_luma_x      ),
    .load_ref_luma_y_i     ( load_ref_luma_y      ),
    .load_cur_chroma_x_i   ( load_cur_chroma_x    ),
    .load_cur_chroma_y_i   ( load_cur_chroma_y    ),
    .load_ref_chroma_x_i   ( load_ref_chroma_x    ),
    .load_ref_chroma_y_i   ( load_ref_chroma_y    ),
    .load_db_luma_x_i      ( load_db_luma_x       ),
    .load_db_luma_y_i      ( load_db_luma_y       ),
    .load_db_chroma_x_i    ( load_db_chroma_x     ),
    .load_db_chroma_y_i    ( load_db_chroma_y     ),
    .store_db_luma_x_i     ( store_db_luma_x      ),
    .store_db_luma_y_i     ( store_db_luma_y      ),
    .store_db_chroma_x_i   ( store_db_chroma_x    ),
    .store_db_chroma_y_i   ( store_db_chroma_y    ),
    // pre_i_cur_if
    .pre_i_4x4_x_i         ( pre_i_cur_4x4_x      ),
    .pre_i_4x4_y_i         ( pre_i_cur_4x4_y      ),
    .pre_i_4x4_idx_i       ( pre_i_cur_idx        ),
    .pre_i_sel_i           ( pre_i_cur_sel        ),
    .pre_i_size_i          ( pre_i_cur_size       ),
    .pre_i_rden_i          ( pre_i_cur_ren        ),
    .pre_i_pel_o           ( pre_i_cur_data       ),
    // fime_cur_if
    .fime_cur_4x4_x_i      ( ime_cur_4x4_x        ),
    .fime_cur_4x4_y_i      ( ime_cur_4x4_y        ),
    .fime_cur_4x4_idx_i    ( ime_cur_idx          ),
    .fime_cur_sel_i        ( ime_cur_sel          ),
    .fime_cur_size_i       ( ime_cur_size         ),
    .fime_cur_rden_i       ( ime_cur_ren          ),
    .fime_cur_pel_o        ( ime_cur_data         ),
    // fime_ref_if
    .fime_ref_cur_y_i      ( ime_y                ),
    .fime_ref_x_i          ( {3'b0,ime_ref_x}     ),
    .fime_ref_y_i          ( {1'b0,ime_ref_y}     ),
    .fime_ref_rden_i       ( ime_ref_ren          ),
    .fime_ref_pel_o        ( ime_ref_data         ),
    // fme_cur_if
    .fme_cur_4x4_x_i       ( fme_cur_4x4_x        ),
    .fme_cur_4x4_y_i       ( fme_cur_4x4_y        ),
    .fme_cur_4x4_idx_i     ( fme_cur_idx          ),
    .fme_cur_sel_i         ( fme_cur_sel          ),
    .fme_cur_size_i        ( fme_cur_size         ),
    .fme_cur_rden_i        ( fme_cur_ren          ),
    .fme_cur_pel_o         ( fme_cur_data         ),
    // fme_ref_if
    .fme_ref_cur_y_i       ( fme_y                ),
    .fme_ref_x_i           ( fme_ref_x            ),
    .fme_ref_y_i           ( fme_ref_y            ),
    .fme_ref_rden_i        ( fme_ref_ren          ),
    .fme_ref_pel_o         ( fme_ref_data         ),
    // mc_ref_if
    .mc_ref_cur_y_i        ( mc_y                 ),
    .mc_ref_x_i            ( mc_ref_x             ),
    .mc_ref_y_i            ( mc_ref_y             ),
    .mc_ref_rden_i         ( mc_ref_ren           ),
    .mc_ref_sel_i          ( mc_ref_sel           ),
    .mc_ref_pel_o          ( mc_ref_data          ),
    // tq_cur_if
    .mc_cur_4x4_x_i        ( tq_cur_4x4_x         ),
    .mc_cur_4x4_y_i        ( tq_cur_4x4_y         ),
    .mc_cur_4x4_idx_i      ( tq_cur_idx           ),
    .mc_cur_sel_i          ( tq_cur_sel           ),
    .mc_cur_size_i         ( tq_cur_size          ),
    .mc_cur_rden_i         ( tq_cur_ren           ),
    .mc_cur_pel_o          ( tq_cur_data          ),
    // db_cur_if
    .db_cur_4x4_x_i        ( 4'b0                 ),
    .db_cur_4x4_y_i        ( 4'b0                 ),
    .db_cur_4x4_idx_i      ( 5'b0                 ),
    .db_cur_sel_i          ( 1'b0                 ),
    .db_cur_size_i         ( 2'b0                 ),
    .db_cur_rden_i         ( 1'b0                 ),
    .db_cur_pel_o          (                      ),
    // db_rec_if
    .db_wen_i              (!db_wen               ),
    .db_w4x4_x_i           ( db_w4x4_x            ),
    .db_w4x4_y_i           ( db_w4x4_y            ),
    .db_wprevious_i        ( db_wprevious         ),
    .db_done_i             ( db_done              ),
    .db_wsel_i             ( db_wsel              ),
    .db_wdata_i            ( db_wdata             ),
    .db_ren_i              (!db_ren               ),
    .db_r4x4_i             ( db_r4x4              ),
    .db_ridx_i             ( db_ridx              ),
    .db_rdata_o            ( db_rdata             ),
    // ext_if
    .extif_start_o         ( extif_start_o        ),
    .extif_done_i          ( extif_done_i         ),
    .extif_mode_o          ( extif_mode_o         ),
    .extif_x_o             ( extif_x_o            ),
    .extif_y_o             ( extif_y_o            ),
    .extif_width_o         ( extif_width_o        ),
    .extif_height_o        ( extif_height_o       ),
    .extif_wren_i          ( extif_wren_i         ),
    .extif_rden_i          ( extif_rden_i         ),
    .extif_data_i          ( extif_data_i         ),
    .extif_data_o          ( extif_data_o         )
    );


//--- ENC_TOP ------------------------------------

  reg [16*`PIXEL_WIDTH-1 : 0]    db_rdata_w ;

  always @(*) begin
    case( db_ridx )
      1 : begin db_rdata_w = 128'b0 ; db_rdata_w[16*`PIXEL_WIDTH-1:12*`PIXEL_WIDTH] = db_rdata ; end
      2 : begin db_rdata_w = 128'b0 ; db_rdata_w[12*`PIXEL_WIDTH-1:08*`PIXEL_WIDTH] = db_rdata ; end
      3 : begin db_rdata_w = 128'b0 ; db_rdata_w[08*`PIXEL_WIDTH-1:04*`PIXEL_WIDTH] = db_rdata ; end
      0 : begin db_rdata_w = 128'b0 ; db_rdata_w[04*`PIXEL_WIDTH-1:00*`PIXEL_WIDTH] = db_rdata ; end
    endcase
  end

  enc_core u_enc_core (
    // global
    .clk                   ( clk                  ),
    .rst_n                 ( rst_n                ),
    // sys_if
    .sys_x_total_i         ( sys_x_total_i        ),
    .sys_y_total_i         ( sys_y_total_i        ),
    .sys_type_i            ( sys_type_i           ),
    .pre_min_size_i        ( pre_min_size_i       ),
    .enc_start_i           ( enc_start            ),
    // pre_i_sys_if
    .pre_i_start_i         ( pre_i_start          ),
    .pre_i_x_i             ( pre_i_x              ),
    .pre_i_y_i             ( pre_i_y              ),
    .pre_i_qp_i            ( pre_i_qp             ),
    .pre_i_done_o          ( pre_i_done           ),
    // pre_i_cur_if
    .pre_i_cur_ren_o       ( pre_i_cur_ren        ),
    .pre_i_cur_sel_o       ( pre_i_cur_sel        ),
    .pre_i_cur_size_o      ( pre_i_cur_size       ),
    .pre_i_cur_4x4_x_o     ( pre_i_cur_4x4_x      ),
    .pre_i_cur_4x4_y_o     ( pre_i_cur_4x4_y      ),
    .pre_i_cur_idx_o       ( pre_i_cur_idx        ),
    .pre_i_cur_data_i      ( pre_i_cur_data       ),
    // intra_sys_if
    .intra_start_i         ( intra_start          ),
    .intra_x_i             ( intra_x              ),
    .intra_y_i             ( intra_y              ),
    .intra_qp_i            ( intra_qp             ),
    .intra_done_o          ( intra_done           ),
    // ime_sys_if
    .ime_start_i           ( ime_start            ),
    .ime_x_i               ( ime_x                ),
    .ime_y_i               ( ime_y                ),
    .ime_qp_i              ( ime_qp               ),
    .ime_done_o            ( ime_done             ),
    // ime_cur_if
    .ime_cur_4x4_x_o       ( ime_cur_4x4_x        ),
    .ime_cur_4x4_y_o       ( ime_cur_4x4_y        ),
    .ime_cur_idx_o         ( ime_cur_idx          ),
    .ime_cur_sel_o         ( ime_cur_sel          ),
    .ime_cur_size_o        ( ime_cur_size         ),
    .ime_cur_ren_o         ( ime_cur_ren          ),
    .ime_cur_data_i        ( ime_cur_data         ),
    // ime_ref_if
    .ime_ref_x_o           ( ime_ref_x            ),
    .ime_ref_y_o           ( ime_ref_y            ),
    .ime_ref_ren_o         ( ime_ref_ren          ),
    .ime_ref_data_i        ( ime_ref_data         ),
    // fme_sys_if
    .fme_start_i           ( fme_start            ),
    .fme_x_i               ( fme_x                ),
    .fme_y_i               ( fme_y                ),
    .fme_qp_i              ( fme_qp               ),
    .fme_done_o            ( fme_done             ),
    // fme_cur_if
    .fme_cur_4x4_x_o       ( fme_cur_4x4_x        ),
    .fme_cur_4x4_y_o       ( fme_cur_4x4_y        ),
    .fme_cur_idx_o         ( fme_cur_idx          ),
    .fme_cur_sel_o         ( fme_cur_sel          ),
    .fme_cur_size_o        ( fme_cur_size         ),
    .fme_cur_ren_o         ( fme_cur_ren          ),
    .fme_cur_data_i        ( fme_cur_data         ),
    // fme_ref_if
    .fme_ref_x_o           ( fme_ref_x            ),
    .fme_ref_y_o           ( fme_ref_y            ),
    .fme_ref_ren_o         ( fme_ref_ren          ),
    .fme_ref_data_i        ( fme_ref_data         ),
    // mc_sys_if
    .mc_start_i            ( mc_start             ),
    .mc_x_i                ( mc_x                 ),
    .mc_y_i                ( mc_y                 ),
    .mc_qp_i               ( mc_qp                ),
    .mc_done_o             ( mc_done              ),
    // mc_ref_if
    .mc_ref_x_o            ( mc_ref_x             ),
    .mc_ref_y_o            ( mc_ref_y             ),
    .mc_ref_ren_o          ( mc_ref_ren           ),
    .mc_ref_sel_o          ( mc_ref_sel           ),
    .mc_ref_data_i         ( mc_ref_data          ),
    // tq_cur_if
    .tq_cur_4x4_x_o        ( tq_cur_4x4_x         ),
    .tq_cur_4x4_y_o        ( tq_cur_4x4_y         ),
    .tq_cur_idx_o          ( tq_cur_idx           ),
    .tq_cur_sel_o          ( tq_cur_sel           ),
    .tq_cur_size_o         ( tq_cur_size          ),
    .tq_cur_ren_o          ( tq_cur_ren           ),
    .tq_cur_data_i         ( tq_cur_data          ),
    // db_sys_if
    .db_start_i            ( db_start             ),
    .db_x_i                ( db_x                 ),
    .db_y_i                ( db_y                 ),
    .db_qp_i               ( db_qp                ),
    .db_done_o             ( db_done              ),
    // db_rec_if
    .db_wen_o              ( db_wen               ),
    .db_w4x4_x_o           ( db_w4x4_x            ),
    .db_w4x4_y_o           ( db_w4x4_y            ),
    .db_wprevious_o        ( db_wprevious         ),
    .db_wsel_o             ( db_wsel              ),
    .db_wdata_o            ( db_wdata             ),
    .db_ren_o              ( db_ren               ),
    .db_r4x4_o             ( db_r4x4              ),
    .db_ridx_o             ( db_ridx              ),
    .db_rdata_i            ( db_rdata_w           ),
    // ec_sys_if
    .ec_start_i            ( ec_start             ),
    .ec_x_i                ( ec_x                 ),
    .ec_y_i                ( ec_y                 ),
    .ec_qp_i               ( ec_qp                ),
    .ec_done_o             ( ec_done              ),
    // ec_bs_if
    .ec_bs_val_o           ( bs_val_o             ),
    .ec_bs_dat_o           ( bs_dat_o             )
    );

endmodule