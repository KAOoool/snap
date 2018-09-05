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
//  Filename      : fetch_top.v
//  Author        : Huang Leilei
//  Created       : 2016-03-22
//  Description   : top of fetch
//
//-------------------------------------------------------------------

`include "enc_defines.v"

module fetch_top (
  clk                   ,
  rstn                  ,
  // sys_if
  sysif_type_i          ,
  sysif_total_x_i       ,
  sysif_total_y_i       ,
  // ctrl_if
  sysif_start_i         ,
  sysif_done_o          ,
  load_cur_luma_ena_i   ,
  load_ref_luma_ena_i   ,
  load_cur_chroma_ena_i ,
  load_ref_chroma_ena_i ,
  load_db_luma_ena_i    ,
  load_db_chroma_ena_i  ,
  store_db_luma_ena_i   ,
  store_db_chroma_ena_i ,
  load_cur_luma_x_i     ,
  load_cur_luma_y_i     ,
  load_ref_luma_x_i     ,
  load_ref_luma_y_i     ,
  load_cur_chroma_x_i   ,
  load_cur_chroma_y_i   ,
  load_ref_chroma_x_i   ,
  load_ref_chroma_y_i   ,
  load_db_luma_x_i      ,
  load_db_luma_y_i      ,
  load_db_chroma_x_i    ,
  load_db_chroma_y_i    ,
  store_db_luma_x_i     ,
  store_db_luma_y_i     ,
  store_db_chroma_x_i   ,
  store_db_chroma_y_i   ,
  // pre_i_cur_if
  pre_i_4x4_x_i         ,
  pre_i_4x4_y_i         ,
  pre_i_4x4_idx_i       ,
  pre_i_sel_i           ,
  pre_i_size_i          ,
  pre_i_rden_i          ,
  pre_i_pel_o           ,
  // ime_cur_if
  fime_cur_4x4_x_i      ,
  fime_cur_4x4_y_i      ,
  fime_cur_4x4_idx_i    ,
  fime_cur_sel_i        ,
  fime_cur_size_i       ,
  fime_cur_rden_i       ,
  fime_cur_pel_o        ,
  // ime_ref_if
  fime_ref_cur_y_i      ,
  fime_ref_x_i          ,
  fime_ref_y_i          ,
  fime_ref_rden_i       ,
  fime_ref_pel_o        ,
  // fme_cur_if
  fme_cur_4x4_x_i       ,
  fme_cur_4x4_y_i       ,
  fme_cur_4x4_idx_i     ,
  fme_cur_sel_i         ,
  fme_cur_size_i        ,
  fme_cur_rden_i        ,
  fme_cur_pel_o         ,
  // fme_ref_if
  fme_ref_cur_y_i       ,
  fme_ref_x_i           ,
  fme_ref_y_i           ,
  fme_ref_rden_i        ,
  fme_ref_pel_o         ,
  // mc_ref_if
  mc_ref_cur_y_i        ,
  mc_ref_x_i            ,
  mc_ref_y_i            ,
  mc_ref_rden_i         ,
  mc_ref_sel_i          ,
  mc_ref_pel_o          ,
  // tq_cur_if
  mc_cur_4x4_x_i        ,
  mc_cur_4x4_y_i        ,
  mc_cur_4x4_idx_i      ,
  mc_cur_sel_i          ,
  mc_cur_size_i         ,
  mc_cur_rden_i         ,
  mc_cur_pel_o          ,
  // db_cur_if
  db_cur_4x4_x_i        ,
  db_cur_4x4_y_i        ,
  db_cur_4x4_idx_i      ,
  db_cur_sel_i          ,
  db_cur_size_i         ,
  db_cur_rden_i         ,
  db_cur_pel_o          ,
  // db_rec_if
  db_wen_i              ,
  db_w4x4_x_i           ,
  db_w4x4_y_i           ,
  db_wprevious_i        ,
  db_done_i             ,
  db_wsel_i             ,
  db_wdata_i            ,
  db_ren_i              ,
  db_r4x4_i             ,
  db_ridx_i             ,
  db_rdata_o            ,
  // ext_if
  extif_start_o         ,
  extif_done_i          ,
  extif_mode_o          ,
  extif_x_o             ,
  extif_y_o             ,
  extif_rden_i          ,
  extif_wren_i          ,
  extif_width_o         ,
  extif_height_o        ,
  extif_data_i          ,
  extif_data_o
  );


//*** INPUT/OUTPUT DECLARATION *************************************************

  input  [1-1               : 0]    clk                   ;
  input  [1-1               : 0]    rstn                  ;
  // sys_if
  input                             sysif_type_i          ;
  input  [`PIC_X_WIDTH-1    : 0]    sysif_total_x_i       ;
  input  [`PIC_Y_WIDTH-1    : 0]    sysif_total_y_i       ;
  // ctrl_if
  input  [1-1               : 0]    sysif_start_i         ;
  output [1-1               : 0]    sysif_done_o          ;
  input                             load_cur_luma_ena_i   ;
  input                             load_ref_luma_ena_i   ;
  input                             load_cur_chroma_ena_i ;
  input                             load_ref_chroma_ena_i ;
  input                             load_db_luma_ena_i    ;
  input                             load_db_chroma_ena_i  ;
  input                             store_db_luma_ena_i   ;
  input                             store_db_chroma_ena_i ;
  input [`PIC_X_WIDTH-1     : 0]    load_cur_luma_x_i     ;
  input [`PIC_Y_WIDTH-1     : 0]    load_cur_luma_y_i     ;
  input [`PIC_X_WIDTH-1     : 0]    load_ref_luma_x_i     ;
  input [`PIC_Y_WIDTH-1     : 0]    load_ref_luma_y_i     ;
  input [`PIC_X_WIDTH-1     : 0]    load_cur_chroma_x_i   ;
  input [`PIC_Y_WIDTH-1     : 0]    load_cur_chroma_y_i   ;
  input [`PIC_X_WIDTH-1     : 0]    load_ref_chroma_x_i   ;
  input [`PIC_Y_WIDTH-1     : 0]    load_ref_chroma_y_i   ;
  input [`PIC_X_WIDTH-1     : 0]    load_db_luma_x_i      ;
  input [`PIC_Y_WIDTH-1     : 0]    load_db_luma_y_i      ;
  input [`PIC_X_WIDTH-1     : 0]    load_db_chroma_x_i    ;
  input [`PIC_Y_WIDTH-1     : 0]    load_db_chroma_y_i    ;
  input [`PIC_X_WIDTH-1     : 0]    store_db_luma_x_i     ;
  input [`PIC_Y_WIDTH-1     : 0]    store_db_luma_y_i     ;
  input [`PIC_X_WIDTH-1     : 0]    store_db_chroma_x_i   ;
  input [`PIC_Y_WIDTH-1     : 0]    store_db_chroma_y_i   ;

  // pre_i_cur_if
  input  [4-1               : 0]    pre_i_4x4_x_i         ;
  input  [4-1               : 0]    pre_i_4x4_y_i         ;
  input  [5-1               : 0]    pre_i_4x4_idx_i       ;
  input  [1-1               : 0]    pre_i_sel_i           ;
  input  [2-1               : 0]    pre_i_size_i          ;
  input  [1-1               : 0]    pre_i_rden_i          ;
  output [32*`PIXEL_WIDTH-1 : 0]    pre_i_pel_o           ;
  // ime_cur_if
  input  [4-1               : 0]    fime_cur_4x4_x_i      ;
  input  [4-1               : 0]    fime_cur_4x4_y_i      ;
  input  [5-1               : 0]    fime_cur_4x4_idx_i    ;
  input  [1-1               : 0]    fime_cur_sel_i        ;
  input  [3-1               : 0]    fime_cur_size_i       ;
  input  [1-1               : 0]    fime_cur_rden_i       ;
  output [64*`PIXEL_WIDTH-1 : 0]    fime_cur_pel_o        ;
  // ime_ref_if
  input  [8-1               : 0]    fime_ref_cur_y_i      ;
  input  [8-1               : 0]    fime_ref_x_i          ;
  input  [8-1               : 0]    fime_ref_y_i          ;
  input  [1-1               : 0]    fime_ref_rden_i       ;
  output [64*`PIXEL_WIDTH-1 : 0]    fime_ref_pel_o        ;
  // fme_cur_if
  input  [4-1               : 0]    fme_cur_4x4_x_i       ;
  input  [4-1               : 0]    fme_cur_4x4_y_i       ;
  input  [5-1               : 0]    fme_cur_4x4_idx_i     ;
  input  [1-1               : 0]    fme_cur_sel_i         ;
  input  [2-1               : 0]    fme_cur_size_i        ;
  input  [1-1               : 0]    fme_cur_rden_i        ;
  output [32*`PIXEL_WIDTH-1 : 0]    fme_cur_pel_o         ;
  // fme_ref_if
  input  [8-1               : 0]    fme_ref_cur_y_i       ;
  input  [7-1               : 0]    fme_ref_x_i           ;
  input  [7-1               : 0]    fme_ref_y_i           ;
  input  [1-1               : 0]    fme_ref_rden_i        ;
  output [64*`PIXEL_WIDTH-1 : 0]    fme_ref_pel_o         ;
  // mc_cur_if
  input  [4-1               : 0]    mc_cur_4x4_x_i        ;
  input  [4-1               : 0]    mc_cur_4x4_y_i        ;
  input  [5-1               : 0]    mc_cur_4x4_idx_i      ;
  input  [1-1               : 0]    mc_cur_sel_i          ;
  input  [2-1               : 0]    mc_cur_size_i         ;
  input  [1-1               : 0]    mc_cur_rden_i         ;
  output [32*`PIXEL_WIDTH-1 : 0]    mc_cur_pel_o          ;
  // mc_ref_if
  input  [8-1               : 0]    mc_ref_cur_y_i        ;
  input  [6-1               : 0]    mc_ref_x_i            ;
  input  [6-1               : 0]    mc_ref_y_i            ;
  input                             mc_ref_rden_i         ;
  input                             mc_ref_sel_i          ;
  output [8*`PIXEL_WIDTH-1  : 0]    mc_ref_pel_o          ;
  // db_cur_if
  input  [4-1               : 0]    db_cur_4x4_x_i        ;
  input  [4-1               : 0]    db_cur_4x4_y_i        ;
  input  [5-1               : 0]    db_cur_4x4_idx_i      ;
  input  [1-1               : 0]    db_cur_sel_i          ;
  input  [2-1               : 0]    db_cur_size_i         ;
  input  [1-1               : 0]    db_cur_rden_i         ;
  output [32*`PIXEL_WIDTH-1 : 0]    db_cur_pel_o          ;
  // db_rec_if
  input  [1-1               : 0]    db_wen_i              ;
  input  [5-1               : 0]    db_w4x4_x_i           ;
  input  [5-1               : 0]    db_w4x4_y_i           ;
  input  [1-1               : 0]    db_wprevious_i        ;
  input  [1-1               : 0]    db_done_i             ;
  input  [2-1               : 0]    db_wsel_i             ;
  input  [16*`PIXEL_WIDTH-1 : 0]    db_wdata_i            ;
  input  [1-1               : 0]    db_ren_i              ;
  input  [5-1               : 0]    db_r4x4_i             ;
  input  [2-1               : 0]    db_ridx_i             ;
  output [4*`PIXEL_WIDTH-1  : 0]    db_rdata_o            ;
  // ext_if
  output [1-1               : 0]    extif_start_o         ;
  input  [1-1               : 0]    extif_done_i          ;
  output [5-1               : 0]    extif_mode_o          ;
  output [6+`PIC_X_WIDTH-1  : 0]    extif_x_o             ;
  output [6+`PIC_Y_WIDTH-1  : 0]    extif_y_o             ;
  output [8-1               : 0]    extif_width_o         ;
  output [8-1               : 0]    extif_height_o        ;
  input                             extif_rden_i          ;
  input                             extif_wren_i          ;
  input  [16*`PIXEL_WIDTH-1 : 0]    extif_data_i          ;
  output [16*`PIXEL_WIDTH-1 : 0]    extif_data_o          ;


//*** WIRE/REG DECLARATION *****************************************************

  wire                              cur_luma_done         ;
  wire   [32*`PIXEL_WIDTH-1 :0]     cur_luma_data         ;
  wire                              cur_luma_valid        ;
  wire   [7-1               :0]     cur_luma_addr         ;

  wire                              cur_chroma_done       ;
  wire   [32*`PIXEL_WIDTH-1 :0]     cur_chroma_data       ;
  wire                              cur_chroma_valid      ;
  wire   [6-1               :0]     cur_chroma_addr       ;

  wire                              ref_luma_done         ;
  wire   [96*`PIXEL_WIDTH-1 :0]     ref_luma_data         ;
  wire                              ref_luma_valid        ;
  wire   [7-1               :0]     ref_luma_addr         ;

  wire                              ref_chroma_done       ;
  wire   [96*`PIXEL_WIDTH-1 :0]     ref_chroma_data       ;
  wire                              ref_chroma_valid      ;
  wire   [6-1               :0]     ref_chroma_addr       ;

  wire   [8-1               :0]     db_store_addr         ;
  wire                              db_store_en           ;
  wire                              db_store_ready        ;
  wire   [32*`PIXEL_WIDTH-1 :0]     db_store_data         ;
  wire   [5-1               :0]     db_ref_addr           ;
  wire                              db_ref_en             ;
  wire   [16*`PIXEL_WIDTH-1 :0]     db_ref_data           ;


  wire   [8-1               :0]     sysif_fime_y          ;
  wire   [8-1               :0]     sysif_fme_y           ;
  wire   [8-1               :0]     sysif_mc_y            ;

  wire   [32*`PIXEL_WIDTH-1 :0]     mc_cur_luma_pel_o     ;
  wire   [32*`PIXEL_WIDTH-1 :0]     mc_cur_chroma_pel_o   ;

  wire   [32*`PIXEL_WIDTH-1 :0]     db_cur_luma_pel_o     ;
  wire   [32*`PIXEL_WIDTH-1 :0]     db_cur_chroma_pel_o   ;


//*** MAIN BODY ****************************************************************

  // fetch_ctrl
  fetch_wrapper u_wrapper (
    // global
    .clk                   ( clk                   ),
    .rstn                  ( rstn                  ),
    // sys_if
    .sysif_type_i          ( sysif_type_i          ),
    .sysif_total_x_i       ( sysif_total_x_i       ),
    .sysif_total_y_i       ( sysif_total_y_i       ),
    // ctrl_if
    .sysif_start_i         ( sysif_start_i         ),
    .sysif_done_o          ( sysif_done_o          ),
    .load_cur_luma_ena_i   ( load_cur_luma_ena_i   ),
    .load_ref_luma_ena_i   ( load_ref_luma_ena_i   ),
    .load_cur_chroma_ena_i ( load_cur_chroma_ena_i ),
    .load_ref_chroma_ena_i ( load_ref_chroma_ena_i ),
    .load_db_luma_ena_i    ( load_db_luma_ena_i    ),
    .load_db_chroma_ena_i  ( load_db_chroma_ena_i  ),
    .store_db_luma_ena_i   ( store_db_luma_ena_i   ),
    .store_db_chroma_ena_i ( store_db_chroma_ena_i ),
    .load_cur_luma_x_i     ( load_cur_luma_x_i     ),
    .load_cur_luma_y_i     ( load_cur_luma_y_i     ),
    .load_ref_luma_x_i     ( load_ref_luma_x_i     ),
    .load_ref_luma_y_i     ( load_ref_luma_y_i     ),
    .load_cur_chroma_x_i   ( load_cur_chroma_x_i   ),
    .load_cur_chroma_y_i   ( load_cur_chroma_y_i   ),
    .load_ref_chroma_x_i   ( load_ref_chroma_x_i   ),
    .load_ref_chroma_y_i   ( load_ref_chroma_y_i   ),
    .load_db_luma_x_i      ( load_db_luma_x_i      ),
    .load_db_luma_y_i      ( load_db_luma_y_i      ),
    .load_db_chroma_x_i    ( load_db_chroma_x_i    ),
    .load_db_chroma_y_i    ( load_db_chroma_y_i    ),
    .store_db_luma_x_i     ( store_db_luma_x_i     ),
    .store_db_luma_y_i     ( store_db_luma_y_i     ),
    .store_db_chroma_x_i   ( store_db_chroma_x_i   ),
    .store_db_chroma_y_i   ( store_db_chroma_y_i   ),
    // cur_luma_if
    .cur_luma_done_o       ( cur_luma_done         ),
    .cur_luma_data_o       ( cur_luma_data         ),
    .cur_luma_valid_o      ( cur_luma_valid        ),
    .cur_luma_addr_o       ( cur_luma_addr         ),
    // cur_chroma_if
    .cur_chroma_done_o     ( cur_chroma_done       ),
    .cur_chroma_data_o     ( cur_chroma_data       ),
    .cur_chroma_valid_o    ( cur_chroma_valid      ),
    .cur_chroma_addr_o     ( cur_chroma_addr       ),
    // ref_luma_if
    .ref_luma_done_o       ( ref_luma_done         ),
    .ref_luma_data_o       ( ref_luma_data         ),
    .ref_luma_valid_o      ( ref_luma_valid        ),
    .ref_luma_addr_o       ( ref_luma_addr         ),
    // ref_chroma_if
    .ref_chroma_done_o     ( ref_chroma_done       ),
    .ref_chroma_data_o     ( ref_chroma_data       ),
    .ref_chroma_valid_o    ( ref_chroma_valid      ),
    .ref_chroma_addr_o     ( ref_chroma_addr       ),
    // db_if
    .db_store_addr_o       ( db_store_addr         ),
    .db_store_en_o         ( db_store_en           ),
    .db_store_data_i       ( db_store_data         ),
    .db_store_done_o       ( db_store_done         ),
    .db_ref_addr_o         ( db_ref_addr           ),
    .db_ref_en_o           ( db_ref_en             ),
    .db_ref_data_o         ( db_ref_data           ),
    // ext_if
    .extif_start_o         ( extif_start_o         ),
    .extif_done_i          ( extif_done_i          ),
    .extif_mode_o          ( extif_mode_o          ),
    .extif_x_o             ( extif_x_o             ),
    .extif_y_o             ( extif_y_o             ),
    .extif_width_o         ( extif_width_o         ),
    .extif_height_o        ( extif_height_o        ),
    .extif_wren_i          ( extif_wren_i          ),
    .extif_rden_i          ( extif_rden_i          ),
    .extif_data_i          ( extif_data_i          ),
    .extif_data_o          ( extif_data_o          )
    );

  // fetch_cur_luma
  fetch_cur_luma u_cur_luma (
    .clk                   ( clk                   ),
    .rstn                  ( rstn                  ),
    .sysif_start_i         ( sysif_start_i         ),
    .sysif_type_i          ( sysif_type_i          ),
    .pre_i_4x4_x_i         ( pre_i_4x4_x_i         ),
    .pre_i_4x4_y_i         ( pre_i_4x4_y_i         ),
    .pre_i_4x4_idx_i       ( pre_i_4x4_idx_i       ),
    .pre_i_sel_i           ( pre_i_sel_i           ),
    .pre_i_size_i          ( pre_i_size_i          ),
    .pre_i_rden_i          ( pre_i_rden_i          ),
    .pre_i_pel_o           ( pre_i_pel_o           ),
    .fime_cur_4x4_x_i      ( fime_cur_4x4_x_i      ),
    .fime_cur_4x4_y_i      ( fime_cur_4x4_y_i      ),
    .fime_cur_4x4_idx_i    ( fime_cur_4x4_idx_i    ),
    .fime_cur_sel_i        ( fime_cur_sel_i        ),
    .fime_cur_size_i       ( fime_cur_size_i       ),
    .fime_cur_rden_i       ( fime_cur_rden_i       ),
    .fime_cur_pel_o        ( fime_cur_pel_o        ),
    .fme_cur_4x4_x_i       ( fme_cur_4x4_x_i       ),
    .fme_cur_4x4_y_i       ( fme_cur_4x4_y_i       ),
    .fme_cur_4x4_idx_i     ( fme_cur_4x4_idx_i     ),
    .fme_cur_sel_i         ( fme_cur_sel_i         ),
    .fme_cur_size_i        ( fme_cur_size_i        ),
    .fme_cur_rden_i        ( fme_cur_rden_i        ),
    .fme_cur_pel_o         ( fme_cur_pel_o         ),
    .mc_cur_4x4_x_i        ( mc_cur_4x4_x_i        ),
    .mc_cur_4x4_y_i        ( mc_cur_4x4_y_i        ),
    .mc_cur_4x4_idx_i      ( mc_cur_4x4_idx_i      ),
    .mc_cur_sel_i          ( mc_cur_sel_i          ),
    .mc_cur_size_i         ( mc_cur_size_i         ),
    .mc_cur_rden_i         ( mc_cur_rden_i         ),
    .mc_cur_pel_o          ( mc_cur_luma_pel_o     ),
    .db_cur_4x4_x_i        ( db_cur_4x4_x_i        ),
    .db_cur_4x4_y_i        ( db_cur_4x4_y_i        ),
    .db_cur_4x4_idx_i      ( db_cur_4x4_idx_i      ),
    .db_cur_sel_i          ( db_cur_sel_i          ),
    .db_cur_size_i         ( db_cur_size_i         ),
    .db_cur_rden_i         ( db_cur_rden_i         ),
    .db_cur_pel_o          ( db_cur_luma_pel_o     ),
    .ext_load_done_i       ( sysif_done_o          ),
    .ext_load_addr_i       ( cur_luma_addr         ),
    .ext_load_data_i       ( cur_luma_data         ),
    .ext_load_valid_i      ( cur_luma_valid        )
    );

  // fetch_ref_luma
  fetch_ref_luma u_ref_luma (
    .clk                   ( clk                   ),
    .rstn                  ( rstn                  ),
    .sysif_start_i         ( sysif_start_i         ),
    .sysif_total_y_i       ( sysif_total_y_i       ),

    .fime_cur_y_i          ( fime_ref_cur_y_i      ),
    .fime_ref_x_i          ( fime_ref_x_i          ),
    .fime_ref_y_i          ( fime_ref_y_i          ),
    .fime_ref_rden_i       ( fime_ref_rden_i       ),
    .fime_ref_pel_o        ( fime_ref_pel_o        ),

    .fme_cur_y_i           ( fme_ref_cur_y_i       ),
    .fme_ref_x_i           ( fme_ref_x_i           ),
    .fme_ref_y_i           ( fme_ref_y_i           ),
    .fme_ref_rden_i        ( fme_ref_rden_i        ),
    .fme_ref_pel_o         ( fme_ref_pel_o         ),
    .ext_load_done_i       ( sysif_done_o          ),
    .ext_load_addr_i       ( ref_luma_addr         ),
    .ext_load_data_i       ( ref_luma_data         ),
    .ext_load_valid_i      ( ref_luma_valid        )
  );

  // fetch_cur_chroma
  fetch_cur_chroma u_cur_chroma (
    .clk                   ( clk                   ),
    .rstn                  ( rstn                  ),
    .sysif_start_i         ( sysif_start_i         ),
    .mc_cur_4x4_x_i        ( mc_cur_4x4_x_i        ),
    .mc_cur_4x4_y_i        ( mc_cur_4x4_y_i        ),
    .mc_cur_4x4_idx_i      ( mc_cur_4x4_idx_i      ),
    .mc_cur_sel_i          ( mc_cur_sel_i          ),
    .mc_cur_size_i         ( mc_cur_size_i         ),
    .mc_cur_rden_i         ( mc_cur_rden_i         ),
    .mc_cur_pel_o          ( mc_cur_chroma_pel_o   ),
    .db_cur_4x4_x_i        ( db_cur_4x4_x_i        ),
    .db_cur_4x4_y_i        ( db_cur_4x4_y_i        ),
    .db_cur_4x4_idx_i      ( db_cur_4x4_idx_i      ),
    .db_cur_sel_i          ( db_cur_sel_i          ),
    .db_cur_size_i         ( db_cur_size_i         ),
    .db_cur_rden_i         ( db_cur_rden_i         ),
    .db_cur_pel_o          ( db_cur_chroma_pel_o   ),
    .ext_load_done_i       ( sysif_done_o          ),
    .ext_load_data_i       ( cur_chroma_data       ),
    .ext_load_addr_i       ( cur_chroma_addr       ),
    .ext_load_valid_i      ( cur_chroma_valid      )
    );

  assign  mc_cur_pel_o = mc_cur_sel_i ? mc_cur_chroma_pel_o : mc_cur_luma_pel_o;
  assign  db_cur_pel_o = db_cur_sel_i ? db_cur_chroma_pel_o : db_cur_luma_pel_o;

  // fetch_ref_chroma
  fetch_ref_chroma  u_ref_chroma(
    .clk                   ( clk                   ),
    .rstn                  ( rstn                  ),
    .sysif_start_i         ( sysif_start_i         ),
    .sysif_total_y_i       ( sysif_total_y_i       ),

    .mc_cur_y_i            ( mc_ref_cur_y_i        ),
    .mc_ref_x_i            ( mc_ref_x_i            ),
    .mc_ref_y_i            ( mc_ref_y_i            ),
    .mc_ref_rden_i         ( mc_ref_rden_i         ),
    .mc_ref_sel_i          ( mc_ref_sel_i          ),
    .mc_ref_pel_o          ( mc_ref_pel_o          ),

    .ext_load_done_i       ( sysif_done_o          ),
    .ext_load_data_i       ( ref_chroma_data       ),
    .ext_load_addr_i       ( ref_chroma_addr       ),
    .ext_load_valid_i      ( ref_chroma_valid      )
    );

  // fetch_db
  fetch_db u_db (
    .clk                   ( clk                   ),
    .rstn                  ( rstn                  ),
    .sysif_start_i         ( sysif_start_i         ),
    .db_wen_i              ( db_wen_i              ),
    .db_w4x4_x_i           ( db_w4x4_x_i           ),
    .db_w4x4_y_i           ( db_w4x4_y_i           ),
    .db_wprevious_i        ( db_wprevious_i        ),
    .db_done_i             ( db_done_i             ),
    .db_wsel_i             ( db_wsel_i             ),
    .db_wdata_i            ( db_wdata_i            ),
    .db_ren_i              ( db_ren_i              ),
    .db_r4x4_i             ( db_r4x4_i             ),
    .db_ridx_i             ( db_ridx_i             ),
    .db_rdata_o            ( db_rdata_o            ),
    .ext_store_addr_i      ( db_store_addr         ),
    .ext_store_en_i        ( db_store_en           ),
    .ext_store_ready_o     ( db_store_ready        ),
    .ext_store_data_o      ( db_store_data         ),
    .ext_store_done_i      ( db_store_done         ),
    .ext_ref_en_i          ( db_ref_en             ),
    .ext_ref_addr_i        ( db_ref_addr           ),
    .ext_ref_data_i        ( db_ref_data           )
    );


endmodule

