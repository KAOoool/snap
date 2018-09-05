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
//  Filename      : fetch_wrapper.v
//  Author        : Huang Leilei
//  Created       : 2016-03-22
//  Description   : analyze requests from sys_ctrl and enc_core
//                  and send them to the 5 inner module and ext_if
//
//-------------------------------------------------------------------

`include "enc_defines.v"

module fetch_wrapper (
  // global
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
  // cur_luma_if
  cur_luma_done_o       ,
  cur_luma_data_o       ,
  cur_luma_valid_o      ,
  cur_luma_addr_o       ,
  // cur_chroma_if
  cur_chroma_done_o     ,
  cur_chroma_data_o     ,
  cur_chroma_valid_o    ,
  cur_chroma_addr_o     ,
  // ref_luma_if
  ref_luma_done_o       ,
  ref_luma_data_o       ,
  ref_luma_valid_o      ,
  ref_luma_addr_o       ,
  // ref_chroma_if
  ref_chroma_done_o     ,
  ref_chroma_data_o     ,
  ref_chroma_valid_o    ,
  ref_chroma_addr_o     ,
  // db_if
  db_store_addr_o       ,
  db_store_en_o         ,
  db_store_data_i       ,
  db_store_done_o       ,
  db_ref_addr_o         ,
  db_ref_en_o           ,
  db_ref_data_o         ,
  // ext_if
  extif_start_o         ,
  extif_done_i          ,
  extif_mode_o          ,
  extif_x_o             ,
  extif_y_o             ,
  extif_width_o         ,
  extif_height_o        ,
  extif_wren_i          ,
  extif_rden_i          ,
  extif_data_i          ,
  extif_data_o
  );


//*** PARAMETER ****************************************************************

  parameter INTRA = 0 ,
            INTER = 1 ;

  parameter AXI_WIDTH = 128 ;

  parameter AXI_WIDTH_PIXEL = (AXI_WIDTH/`PIXEL_WIDTH) ;

  parameter IDLE = 0  ;
  parameter P1   = 1  ;
  parameter P2   = 2  ;
  parameter P3   = 3  ;
  parameter P4   = 4  ;
  parameter P5   = 5  ;
  parameter P6   = 6  ;
  parameter P7   = 7  ;
  parameter P8   = 8  ;
  parameter P9   = 9  ;
  parameter P10  = 10 ;

  parameter LOAD_CUR_LUMA     = 03 ,
            LOAD_REF_LUMA     = 04 ,
            LOAD_CUR_CHROMA   = 05 ,
            LOAD_REF_CHROMA   = 06 ,
            LOAD_DB_LUMA      = 07 ,
            LOAD_DB_CHROMA    = 08 ,
            STORE_DB_LUMA     = 09 ,
            STORE_DB_CHROMA   = 10 ;

  parameter DB_STORE_IDLE     = 0 ,
            DB_STORE_LUMA_PRE = 1 ,
            DB_STORE_LUMA_CUR = 2 ,
            DB_STORE_CHRO_PRE = 3 ,
            DB_STORE_CHRO_CUR = 4 ;


//*** INPUT/OUTPUT DECLARATION *************************************************

  input      [1-1                : 0]    clk                    ;
  input      [1-1                : 0]    rstn                   ;
  // sys_if
  input                                  sysif_type_i           ;
  input      [`PIC_X_WIDTH-1     : 0]    sysif_total_x_i        ;
  input      [`PIC_Y_WIDTH-1     : 0]    sysif_total_y_i        ;
  // ctrl_if
  input      [1-1                : 0]    sysif_start_i          ;
  output     [1-1                : 0]    sysif_done_o           ;
  input                                  load_cur_luma_ena_i    ;
  input                                  load_ref_luma_ena_i    ;
  input                                  load_cur_chroma_ena_i  ;
  input                                  load_ref_chroma_ena_i  ;
  input                                  load_db_luma_ena_i     ;
  input                                  load_db_chroma_ena_i   ;
  input                                  store_db_luma_ena_i    ;
  input                                  store_db_chroma_ena_i  ;
  input      [`PIC_X_WIDTH-1     : 0]    load_cur_luma_x_i      ;
  input      [`PIC_Y_WIDTH-1     : 0]    load_cur_luma_y_i      ;
  input      [`PIC_X_WIDTH-1     : 0]    load_ref_luma_x_i      ;
  input      [`PIC_Y_WIDTH-1     : 0]    load_ref_luma_y_i      ;
  input      [`PIC_X_WIDTH-1     : 0]    load_cur_chroma_x_i    ;
  input      [`PIC_Y_WIDTH-1     : 0]    load_cur_chroma_y_i    ;
  input      [`PIC_X_WIDTH-1     : 0]    load_ref_chroma_x_i    ;
  input      [`PIC_Y_WIDTH-1     : 0]    load_ref_chroma_y_i    ;
  input      [`PIC_X_WIDTH-1     : 0]    load_db_luma_x_i       ;
  input      [`PIC_Y_WIDTH-1     : 0]    load_db_luma_y_i       ;
  input      [`PIC_X_WIDTH-1     : 0]    load_db_chroma_x_i     ;
  input      [`PIC_Y_WIDTH-1     : 0]    load_db_chroma_y_i     ;
  input      [`PIC_X_WIDTH-1     : 0]    store_db_luma_x_i      ;
  input      [`PIC_Y_WIDTH-1     : 0]    store_db_luma_y_i      ;
  input      [`PIC_X_WIDTH-1     : 0]    store_db_chroma_x_i    ;
  input      [`PIC_Y_WIDTH-1     : 0]    store_db_chroma_y_i    ;
  // cur_luma_if
  output     [1-1                : 0]    cur_luma_done_o        ;
  output     [32*`PIXEL_WIDTH-1  : 0]    cur_luma_data_o        ;
  output     [1-1                : 0]    cur_luma_valid_o       ;
  output     [7-1                : 0]    cur_luma_addr_o        ;
  // cur_chroma_if
  output     [1-1                : 0]    cur_chroma_done_o      ;
  output     [32*`PIXEL_WIDTH-1  : 0]    cur_chroma_data_o      ;
  output     [1-1                : 0]    cur_chroma_valid_o     ;
  output     [6-1                : 0]    cur_chroma_addr_o      ;
  // ref_luma_if
  output     [1-1                : 0]    ref_luma_done_o        ;
  output     [96*`PIXEL_WIDTH-1  : 0]    ref_luma_data_o        ;
  output     [1-1                : 0]    ref_luma_valid_o       ;
  output     [7-1                : 0]    ref_luma_addr_o        ;
  // ref_chroma_if
  output     [1-1                : 0]    ref_chroma_done_o      ;
  output     [96*`PIXEL_WIDTH-1  : 0]    ref_chroma_data_o      ;
  output                                 ref_chroma_valid_o     ;
  output     [6-1                : 0]    ref_chroma_addr_o      ;
  // db_if
  output reg [8-1                : 0]    db_store_addr_o        ;
  output     [1-1                : 0]    db_store_en_o          ;
  input      [32*`PIXEL_WIDTH-1  : 0]    db_store_data_i        ;
  output                                 db_store_done_o        ;
  output     [5-1                : 0]    db_ref_addr_o          ;
  output     [1-1                : 0]    db_ref_en_o            ;
  output     [16*`PIXEL_WIDTH-1  : 0]    db_ref_data_o          ;
  // ext_if
  output     [1-1                : 0]    extif_start_o          ;
  input      [1-1                : 0]    extif_done_i           ;
  output     [5-1                : 0]    extif_mode_o           ;
  output     [6+`PIC_X_WIDTH-1   : 0]    extif_x_o              ;
  output     [6+`PIC_Y_WIDTH-1   : 0]    extif_y_o              ;
  output     [8-1                : 0]    extif_width_o          ;
  output     [8-1                : 0]    extif_height_o         ;
  input                                  extif_wren_i           ;
  input                                  extif_rden_i           ;
  input      [16*`PIXEL_WIDTH-1  : 0]    extif_data_i           ;
  output     [16*`PIXEL_WIDTH-1  : 0]    extif_data_o           ;


//*** WIRE/REG DECLARATION *****************************************************
/*
  reg                                    sysif_start_r          ;

  reg                                    pre_l                  ;
  reg                                    pre_i                  ;
  reg                                    intra                  ;
  reg                                    db                     ;
  reg                                    ime                    ;
  reg                                    fme                    ;
  reg                                    mc                     ;

  reg        [3                  : 0]    current_state          ;
  reg        [3                  : 0]    next_state             ;

  reg        [7                  : 0]    first_x                , first_y                ;
  reg        [7                  : 0]    pre_x                  , pre_y                  ;
  reg        [7                  : 0]    ime_x                  , ime_y                  ;
  reg        [7                  : 0]    fme_x                  , fme_y                  ;
  reg        [7                  : 0]    mc_x                   , mc_y                   ;
  reg        [7                  : 0]    db_0_x                 , db_0_y                 ;
  reg        [7                  : 0]    db_1_x                 , db_1_y                 ;
  reg        [7                  : 0]    db_2_x                 , db_2_y                 ;
  reg        [7                  : 0]    pre_i_x                , pre_i_y                ;
  reg        [7                  : 0]    intra_x                , intra_y                ;
*/

  reg        [4                  : 0]    cur_fetch              ;
  reg        [4                  : 0]    nxt_fetch              ;

  reg                                    store_db_done          ;
  wire                                   store_db               ;

  reg        [7                  : 0]    store_db_chroma_x_r    ;

  reg        [11                 : 0]    luma_ref_x_s           , luma_ref_y_s           ,
                                         luma_ref_x_s_r1        , luma_ref_x_s_r2        ,
                                         luma_ref_y_s_r1        , luma_ref_y_s_r2        ;

  reg        [7                  : 0]    luma_ref_height        ,
                                         luma_ref_height_r1     ,
                                         luma_ref_height_r2     ;

  reg        [AXI_WIDTH-1        : 0]    extif_data_0           ;
  reg        [AXI_WIDTH-1        : 0]    extif_data_1           ;
  reg        [AXI_WIDTH-1        : 0]    extif_data_2           ;
  reg        [AXI_WIDTH-1        : 0]    extif_data_3           ;
  reg        [AXI_WIDTH-1        : 0]    extif_data_4           ;

  reg        [1                  : 0]    cur_luma_cnt           ;
  reg        [2                  : 0]    ref_luma_cnt           ;
  reg        [1                  : 0]    cur_chroma_cnt         ;
  reg        [2                  : 0]    ref_chroma_cnt         ;


  reg        [6                  : 0]    cur_luma_addr          ;
  reg        [5                  : 0]    cur_chroma_addr        ;
  reg        [6                  : 0]    ref_luma_addr_o        ;
  reg        [5                  : 0]    ref_chroma_addr        ;
  reg        [8                  : 0]    db_store_addr_r        ;
  reg        [8                  : 0]    db_store_addr_w        ;
  reg        [5-1                : 0]    db_ref_addr_o          ;


  reg        [5-1                : 0]    extif_mode_o           ;
  reg        [6+`PIC_X_WIDTH-1   : 0]    extif_x_o              ;
  reg        [6+`PIC_Y_WIDTH-1   : 0]    extif_y_o              ;
  reg        [8-1                : 0]    extif_width_o          ;
  reg        [8-1                : 0]    extif_height_o         ;

  reg        [96*`PIXEL_WIDTH-1  : 0]    ref_luma_data_o        ;
  wire       [96*`PIXEL_WIDTH-1  : 0]    ref_luma_data          ;
  wire       [128*`PIXEL_WIDTH-1 : 0]    ref_luma_lshift        ;
  wire       [128*`PIXEL_WIDTH-1 : 0]    ref_luma_rshift        ;

  reg        [1-1                : 0]    extif_start_o          ;
  reg        [1-1                : 0]    sysif_done_o           ;
  reg        [1-1                : 0]    cur_luma_valid_o       ;
  reg        [1-1                : 0]    cur_chroma_valid_o     ;

  reg                                    chroma_ref_lshift_r1   , chroma_ref_lshift_r2   ;
  reg                                    chroma_ref_rshift_r1   , chroma_ref_rshift_r2   ;

  wire       [48*`PIXEL_WIDTH-1  : 0]    ref_chroma_u_lshift    ;
  wire       [48*`PIXEL_WIDTH-1  : 0]    ref_chroma_u_rshift    ;
  wire       [48*`PIXEL_WIDTH-1  : 0]    ref_chroma_v_lshift    ;
  wire       [48*`PIXEL_WIDTH-1  : 0]    ref_chroma_v_rshift    ;
  wire       [48*`PIXEL_WIDTH-1  : 0]    ref_chroma_u_data      ;
  wire       [48*`PIXEL_WIDTH-1  : 0]    ref_chroma_v_data      ;
  wire       [96*`PIXEL_WIDTH-1  : 0]    ref_chroma_data        ;
  reg        [96*`PIXEL_WIDTH-1  : 0]    ref_chroma_data_o      ;

  reg                                    db_store_done_w        ;
  reg        [2                  : 0]    cur_state_db_store     ;
  reg        [2                  : 0]    cur_state_db_store_d   ;
  reg        [2                  : 0]    nxt_state_db_store     ;


//*** MAIN BODY ****************************************************************

//--- ARBITER ------------------------------------
  // cur_fetch
  always @(posedge clk or negedge rstn ) begin
    if( !rstn )
      cur_fetch <= IDLE ;
    else begin
      cur_fetch <= nxt_fetch ;
    end
  end

  // nxt_fetch
  always @(*) begin
                                                                         nxt_fetch = IDLE            ;
    case( cur_fetch )
      IDLE          :   if( sysif_start_i )                              nxt_fetch = LOAD_CUR_LUMA   ;
                        else                                             nxt_fetch = IDLE            ;
      LOAD_CUR_LUMA :   if( (!load_cur_luma_ena_i)
                          | ( load_cur_luma_ena_i & extif_done_i ) )
                                                                         nxt_fetch = LOAD_REF_LUMA   ;
                        else                                             nxt_fetch = LOAD_CUR_LUMA   ;
      LOAD_REF_LUMA :   if( (!load_ref_luma_ena_i)
                          | ( load_ref_luma_ena_i & extif_done_i ) )
                                                                         nxt_fetch = LOAD_CUR_CHROMA ;
                        else                                             nxt_fetch = LOAD_REF_LUMA   ;
      LOAD_CUR_CHROMA : if( (!load_cur_chroma_ena_i)
                          | ( load_cur_chroma_ena_i & extif_done_i ) )
                                                                         nxt_fetch = LOAD_REF_CHROMA ;
                        else                                             nxt_fetch = LOAD_CUR_CHROMA ;
      LOAD_REF_CHROMA : if( (!load_ref_chroma_ena_i)
                          | ( load_ref_chroma_ena_i & extif_done_i ) )
                                                                         nxt_fetch = LOAD_DB_LUMA    ;
                        else                                             nxt_fetch = LOAD_REF_CHROMA ;
      LOAD_DB_LUMA    : if( (!load_db_luma_ena_i)
                          | ( load_db_luma_ena_i & extif_done_i ) )
                                                                         nxt_fetch = LOAD_DB_CHROMA  ;
                        else                                             nxt_fetch = LOAD_DB_LUMA    ;
      LOAD_DB_CHROMA  : if( (!load_db_chroma_ena_i)
                          | ( load_db_chroma_ena_i & extif_done_i ) )
                                                                         nxt_fetch = STORE_DB_LUMA   ;
                        else                                             nxt_fetch = LOAD_DB_CHROMA  ;
      STORE_DB_LUMA   : if( (!store_db_luma_ena_i)
                          | ( store_db_luma_ena_i & extif_done_i ) )     nxt_fetch = STORE_DB_CHROMA ;
                        else                                             nxt_fetch = STORE_DB_LUMA   ;
      STORE_DB_CHROMA : if( (!store_db_chroma_ena_i)
                          | ( store_db_chroma_ena_i & extif_done_i ) )
                          if( store_db_done )                            nxt_fetch = IDLE            ;
                          else                                           nxt_fetch = STORE_DB_LUMA   ;
                        else                                             nxt_fetch = STORE_DB_CHROMA ;
    endcase
  end

  // store_db twice, when x == total_x
  assign store_db = store_db_chroma_ena_i ;

  always @(posedge clk or negedge rstn ) begin
    if( !rstn )
      store_db_done <= 0 ;
    else if( cur_fetch == LOAD_DB_CHROMA ) begin
      if( store_db_chroma_x_i == sysif_total_x_i )
        store_db_done <= 0 ;
      else begin
        store_db_done <= 1 ;
      end
    end
    else if( (cur_fetch==STORE_DB_CHROMA) & extif_done_i ) begin
      store_db_done <= 1 ;
    end
  end

//--- EXT_IF ---------------------------
  // x, y, width, height & mode
  always @(*) begin
                              extif_x_o       = 0                   ;
                              extif_y_o       = 0                   ;
                              extif_width_o   = 0                   ;
                              extif_height_o  = 0                   ;
                              extif_mode_o    = IDLE                ;
    case( cur_fetch )
      LOAD_CUR_LUMA   : begin extif_x_o       = load_cur_luma_x_i   ;
                              extif_y_o       = load_cur_luma_y_i   ;
                              extif_width_o   = 64                  ;
                              extif_height_o  = 64                  ;
                              extif_mode_o    = LOAD_CUR_LUMA       ;
                        end
      LOAD_REF_LUMA   : begin extif_x_o       = luma_ref_x_s        ;
                              extif_y_o       = luma_ref_y_s        ;
                              extif_width_o   = 96                  ;
                              extif_height_o  = luma_ref_height     ;
                              extif_mode_o    = LOAD_REF_LUMA       ;
                        end
      LOAD_CUR_CHROMA : begin extif_x_o       = load_cur_chroma_x_i ;
                              extif_y_o       = load_cur_chroma_y_i ;
                              extif_width_o   = 64                  ;
                              extif_height_o  = 64                  ;
                              extif_mode_o    = LOAD_CUR_CHROMA     ;
                        end
      LOAD_REF_CHROMA : begin extif_x_o       = luma_ref_x_s_r2     ;
                              extif_y_o       = luma_ref_y_s_r2     ;
                              extif_width_o   = 96                  ;
                              extif_height_o  = luma_ref_height_r2  ;
                              extif_mode_o    = LOAD_REF_CHROMA     ;
                        end
      LOAD_DB_LUMA    : begin extif_x_o       = load_db_luma_x_i * 64     ;
                              extif_y_o       = load_db_luma_y_i * 64 - 4 ;
                              extif_width_o   = 64                  ;
                              extif_height_o  = 4                   ;
                              extif_mode_o    = LOAD_DB_LUMA        ;
                        end
      LOAD_DB_CHROMA  : begin extif_x_o       = load_db_chroma_x_i * 64     ;
                              extif_y_o       = load_db_chroma_y_i * 64 - 8 ;
                              extif_width_o   = 64                  ;
                              extif_height_o  = 8                   ;
                              extif_mode_o    = LOAD_DB_CHROMA      ;
                        end
      STORE_DB_LUMA   : begin extif_x_o       = ( store_db_done & (store_db_chroma_x_i==sysif_total_x_i) ) ? (store_db_chroma_x_i * 64) : (store_db_chroma_x_r * 64    ) ;
                              extif_y_o       = (                  store_db_chroma_y_i==0                ) ? (store_db_chroma_y_i * 64) : (store_db_chroma_y_i * 64 - 4) ;
                              extif_width_o   = 64                  ;
                              extif_height_o  = (                  store_db_chroma_y_i==0                ) ? 64 : 68 ;
                              extif_mode_o    = STORE_DB_LUMA       ;
                        end
      STORE_DB_CHROMA : begin extif_x_o       = ( store_db_done & (store_db_chroma_x_i==sysif_total_x_i) ) ? (store_db_chroma_x_i * 64) : (store_db_chroma_x_r * 64    ) ;
                              extif_y_o       = (                  store_db_chroma_y_i==0                ) ? (store_db_chroma_y_i * 64) : (store_db_chroma_y_i * 64 - 8) ;
                              extif_width_o   = 64                  ;
                              extif_height_o  = (                  store_db_chroma_y_i==0                ) ? 64 : 72 ;
                              extif_mode_o    = STORE_DB_CHROMA     ;
                        end
    endcase
  end

  // store_db_chroma_x_r
  always @(posedge clk or negedge rstn ) begin
    if( !rstn )
      store_db_chroma_x_r <= 0 ;
    else if( sysif_done_o ) begin
      store_db_chroma_x_r <= store_db_chroma_x_i ;
    end
  end

  // start
  always @ (posedge clk or negedge rstn) begin
    if (~rstn) begin
      extif_start_o <= 0 ;
    end
    else if( sysif_type_i==INTER ) begin
      if ( ( (cur_fetch==IDLE           ) && (nxt_fetch==LOAD_CUR_LUMA  ) && load_cur_luma_ena_i   )
         | ( (cur_fetch==LOAD_CUR_LUMA  ) && (nxt_fetch==LOAD_REF_LUMA  ) && load_ref_luma_ena_i   )
         | ( (cur_fetch==LOAD_REF_LUMA  ) && (nxt_fetch==LOAD_CUR_CHROMA) && load_cur_chroma_ena_i )
         | ( (cur_fetch==LOAD_CUR_CHROMA) && (nxt_fetch==LOAD_REF_CHROMA) && load_ref_chroma_ena_i )
         | ( (cur_fetch==LOAD_REF_CHROMA) && (nxt_fetch==LOAD_DB_LUMA   ) && load_db_luma_ena_i    )
         | ( (cur_fetch==LOAD_DB_LUMA   ) && (nxt_fetch==LOAD_DB_CHROMA ) && load_db_chroma_ena_i  )
         | ( (cur_fetch==LOAD_DB_CHROMA ) && (nxt_fetch==STORE_DB_LUMA  ) && store_db_luma_ena_i   )
         | ( (cur_fetch==STORE_DB_LUMA  ) && (nxt_fetch==STORE_DB_CHROMA) && store_db_chroma_ena_i )
         | ( (cur_fetch==STORE_DB_CHROMA) && (store_db_done==0)           && extif_done_i          ) )
        extif_start_o <= 1 ;
      else begin
        extif_start_o <= 0 ;
      end
    end
    else begin
      if( ( (cur_fetch==IDLE           ) && (nxt_fetch==LOAD_CUR_LUMA  ) && load_cur_luma_ena_i   )
        | ( (cur_fetch==LOAD_REF_LUMA  ) && (nxt_fetch==LOAD_CUR_CHROMA) && load_cur_chroma_ena_i )
        | ( (cur_fetch==LOAD_REF_CHROMA) && (nxt_fetch==LOAD_DB_LUMA   ) && load_db_luma_ena_i    )
        | ( (cur_fetch==LOAD_DB_LUMA   ) && (nxt_fetch==LOAD_DB_CHROMA ) && load_db_chroma_ena_i  )
        | ( (cur_fetch==LOAD_DB_CHROMA ) && (nxt_fetch==STORE_DB_LUMA  ) && store_db_luma_ena_i   )
        | ( (cur_fetch==STORE_DB_LUMA  ) && (nxt_fetch==STORE_DB_CHROMA) && store_db_chroma_ena_i )
        | ( (cur_fetch==STORE_DB_CHROMA) && (store_db_done==0          ) && extif_done_i          ) )
        extif_start_o <= 1 ;
      else begin
        extif_start_o <= 0 ;
      end
    end
  end

  // data_o
  assign extif_data_o = ((cur_state_db_store_d==DB_STORE_CHRO_PRE)|(cur_state_db_store_d==DB_STORE_CHRO_CUR))
                         ? ( db_store_addr_r[0] ? { db_store_data_i[127:120],db_store_data_i[095:088],db_store_data_i[119:112],db_store_data_i[087:080],db_store_data_i[111:104],db_store_data_i[079:072],db_store_data_i[103:096],db_store_data_i[071:064]
                                                   ,db_store_data_i[063:056],db_store_data_i[031:024],db_store_data_i[055:048],db_store_data_i[023:016],db_store_data_i[047:040],db_store_data_i[015:008],db_store_data_i[039:032],db_store_data_i[007:000]
                                                  }
                                                : { db_store_data_i[255:248],db_store_data_i[223:216],db_store_data_i[247:240],db_store_data_i[215:208],db_store_data_i[239:232],db_store_data_i[207:200],db_store_data_i[231:224],db_store_data_i[199:192]
                                                   ,db_store_data_i[191:184],db_store_data_i[159:152],db_store_data_i[183:176],db_store_data_i[151:144],db_store_data_i[175:168],db_store_data_i[143:136],db_store_data_i[167:160],db_store_data_i[135:128]
                                                  }
                           )
                         : ( db_store_addr_r[0] ? db_store_data_i[16*`PIXEL_WIDTH-1:0] : db_store_data_i[32*`PIXEL_WIDTH-1:16*`PIXEL_WIDTH] );

//--- X & Y (recalculated) -------------
  // ref x & y coordinate
  wire signed [13:0] pre_x_minus16 = load_cur_luma_x_i * 64 - 'd16;
  wire signed [13:0] pre_x_plus80  = load_cur_luma_x_i * 64 + 'd80;
  wire signed [13:0] pre_y_minus16 = load_cur_luma_y_i * 64 - 'd16;

  always @(*) begin
    if( pre_x_minus16 < 0 )
      luma_ref_x_s = 0 ;
    else begin
      luma_ref_x_s = load_cur_luma_x_i * 64 - 16 ;
    end
  end

  always @(*) begin
    if ( pre_y_minus16 < 0 )
      luma_ref_y_s = 0 ;
    else begin
      luma_ref_y_s = load_cur_luma_y_i * 64 - 16 ;
    end
  end

  // ref width & height
  always @(*) begin
    if( pre_y_minus16 < 0 )
      luma_ref_height = 96 + load_cur_luma_y_i * 64 - 16 ;
    else if ( (load_cur_luma_y_i * 64 + 80) > (sysif_total_y_i*64 + 64) )
      luma_ref_height = (sysif_total_y_i+1)*64 - 2*load_cur_luma_y_i*64 ; // ???????? by gch
    else begin
      luma_ref_height = 96 ;
    end
  end

  // chroma
  always @(posedge clk or negedge rstn ) begin
    if( !rstn ) begin
      luma_ref_height_r1   <= 0 ;
      luma_ref_height_r2   <= 0 ;
      luma_ref_x_s_r1      <= 0 ;
      luma_ref_x_s_r2      <= 0 ;
      luma_ref_y_s_r1      <= 0 ;
      luma_ref_y_s_r2      <= 0 ;
      chroma_ref_lshift_r1 <= 0 ;
      chroma_ref_lshift_r2 <= 0 ;
      chroma_ref_rshift_r1 <= 0 ;
      chroma_ref_rshift_r2 <= 0 ;
    end
    else if (sysif_done_o) begin
      luma_ref_height_r1   <= luma_ref_height      ;
      luma_ref_height_r2   <= luma_ref_height_r1   ;
      luma_ref_x_s_r1      <= luma_ref_x_s         ;
      luma_ref_x_s_r2      <= luma_ref_x_s_r1      ;
      luma_ref_y_s_r1      <= luma_ref_y_s         ;
      luma_ref_y_s_r2      <= luma_ref_y_s_r1      ;
      chroma_ref_lshift_r1 <= (pre_x_minus16 < 0)  ;
      chroma_ref_lshift_r2 <= chroma_ref_lshift_r1 ;
      chroma_ref_rshift_r1 <= (pre_x_plus80 > (sysif_total_x_i+1)*64) ;
      chroma_ref_rshift_r2 <= chroma_ref_rshift_r1 ;
    end
  end

//--- DONE -----------------------------
  always @(posedge clk or negedge rstn ) begin
    if( !rstn ) begin
      sysif_done_o <= 0 ;
    end
    else begin
      sysif_done_o <=( ( cur_fetch==STORE_DB_CHROMA )
                     & ( (!store_db_chroma_ena_i)
                       | ( store_db_chroma_ena_i & extif_done_i & store_db_done )
                       )
                     ) ;
    end
  end

  assign cur_luma_done_o    = (cur_fetch == LOAD_CUR_LUMA  ) & load_cur_luma_ena_i   & extif_done_i ;
  assign cur_chroma_done_o  = (cur_fetch == LOAD_CUR_CHROMA) & load_ref_luma_ena_i   & extif_done_i ;
  assign ref_luma_done_o    = (cur_fetch == LOAD_REF_LUMA  ) & load_cur_chroma_ena_i & extif_done_i ;
  assign ref_chroma_done_o  = (cur_fetch == LOAD_REF_CHROMA) & load_ref_chroma_ena_i & extif_done_i ;
  assign db_store_done_o    = (cur_fetch == STORE_DB_CHROMA) & store_db_chroma_ena_i & extif_done_i ;
  assign db_store_en_o    = 1 ;

//--- WRAPPER --------------------------
  // ext buffer
  always @(posedge clk or negedge rstn ) begin
    if( !rstn ) begin
      extif_data_0 <= 0 ;
      extif_data_1 <= 0 ;
      extif_data_2 <= 0 ;
      extif_data_3 <= 0 ;
      extif_data_4 <= 0 ;
    end
    else if( extif_wren_i ) begin
      extif_data_0 <= extif_data_i ;
      extif_data_1 <= extif_data_0 ;
      extif_data_2 <= extif_data_1 ;
      extif_data_3 <= extif_data_2 ;
      extif_data_4 <= extif_data_3 ;
    end
  end

  // cur luma
  always @(posedge clk or negedge rstn ) begin
    if( !rstn ) begin
      cur_luma_addr <= 0 ;
    end
    else if( cur_luma_valid_o ) begin
      cur_luma_addr <= cur_luma_addr + 1 ;
    end
  end

  always @(posedge clk or negedge rstn ) begin
    if( !rstn ) begin
      cur_luma_cnt     <= 0 ;
      cur_luma_valid_o <= 0 ;
    end
    else if( cur_fetch!=nxt_fetch ) begin
      cur_luma_cnt     <= 0 ;
      cur_luma_valid_o <= 0 ;
    end
    else if( (cur_fetch==LOAD_CUR_LUMA) && extif_wren_i ) begin
      if( cur_luma_cnt==(32/AXI_WIDTH_PIXEL-1) ) begin
        cur_luma_cnt     <= 0 ;
        cur_luma_valid_o <= 1 ;
      end
      else begin
        cur_luma_cnt     <= cur_luma_cnt + 1 ;
        cur_luma_valid_o <= 0 ;
      end
    end
    else begin
      cur_luma_valid_o <= 0 ;
    end
  end

  assign cur_luma_data_o = { extif_data_1 ,extif_data_0 };

  assign cur_luma_addr_o = {  cur_luma_addr[6],
                              cur_luma_addr[0],
                              cur_luma_addr[5:1]
                           };

  // ref_luma
  always @(posedge clk or negedge rstn ) begin
    if( !rstn ) begin
      ref_luma_addr_o <= 0 ;
      ref_luma_cnt    <= 0 ;
    end
    else if( cur_fetch!=nxt_fetch ) begin
        ref_luma_addr_o <= 0 ;
        ref_luma_cnt    <= 0 ;
    end
    else if( (cur_fetch==LOAD_REF_LUMA) && extif_wren_i ) begin
      if( ref_luma_cnt==(96/AXI_WIDTH_PIXEL-1) ) begin
        ref_luma_addr_o <= ref_luma_addr_o+1 ;
        ref_luma_cnt    <= 0 ;
      end
      else begin
        ref_luma_addr_o <= ref_luma_addr_o ;
        ref_luma_cnt    <= ref_luma_cnt+1  ;
      end
    end
  end

  assign ref_luma_data   = {extif_data_4,extif_data_3, extif_data_2,
                            extif_data_1,extif_data_0, extif_data_i};
  assign ref_luma_valid_o= (cur_fetch==LOAD_REF_LUMA) && extif_wren_i && (ref_luma_cnt==(96/AXI_WIDTH_PIXEL-1)) ;
  assign ref_luma_lshift = {{32{extif_data_4[16*`PIXEL_WIDTH-1:15*`PIXEL_WIDTH]}},ref_luma_data} >> ('d16 * `PIXEL_WIDTH);
  assign ref_luma_rshift = {extif_data_4,extif_data_3,extif_data_2,
                          extif_data_1,extif_data_0,{32{extif_data_0[`PIXEL_WIDTH-1:0]}}};

  always @ (*) begin
    if( pre_x_minus16<0 )
      ref_luma_data_o = ref_luma_lshift[96*`PIXEL_WIDTH-1:0] ;
    else if( pre_x_plus80 > (sysif_total_x_i+1)*64 )
      ref_luma_data_o = {extif_data_4,extif_data_3,extif_data_2,extif_data_1,extif_data_0,{16{extif_data_0[`PIXEL_WIDTH-1:0]}}} ;
    else begin
      ref_luma_data_o = ref_luma_data ;
    end
  end

  // cur_chroma
  always @(posedge clk or negedge rstn ) begin
    if( !rstn ) begin
      cur_chroma_addr <= 0 ;
    end
    else if( cur_chroma_valid_o ) begin
      cur_chroma_addr <= cur_chroma_addr + 1 ;
    end
  end

  always @(posedge clk or negedge rstn ) begin
    if( !rstn ) begin
      cur_chroma_cnt     <= 0 ;
      cur_chroma_valid_o <= 0 ;
    end
    else if( cur_fetch!=nxt_fetch ) begin
      cur_chroma_cnt     <= 0 ;
      cur_chroma_valid_o <= 0 ;
    end
    else if( (cur_fetch==LOAD_CUR_CHROMA) && extif_wren_i ) begin
      if( cur_chroma_cnt==(32/AXI_WIDTH_PIXEL-1) ) begin
        cur_chroma_cnt     <= 0 ;
        cur_chroma_valid_o <= 1 ;
      end
      else begin
        cur_chroma_cnt     <= cur_chroma_cnt + 1 ;
        cur_chroma_valid_o <= 0;
      end
    end
    else begin
      cur_chroma_valid_o <= 0 ;
    end
  end

  assign cur_chroma_data_o  = { extif_data_1[127:120],extif_data_1[111:104],extif_data_1[095:088],extif_data_1[079:072],extif_data_1[063:056],extif_data_1[047:040],extif_data_1[031:024],extif_data_1[015:008]
                               ,extif_data_0[127:120],extif_data_0[111:104],extif_data_0[095:088],extif_data_0[079:072],extif_data_0[063:056],extif_data_0[047:040],extif_data_0[031:024],extif_data_0[015:008]
                               ,extif_data_1[119:112],extif_data_1[103:096],extif_data_1[087:080],extif_data_1[071:064],extif_data_1[055:048],extif_data_1[039:032],extif_data_1[023:016],extif_data_1[007:000]
                               ,extif_data_0[119:112],extif_data_0[103:096],extif_data_0[087:080],extif_data_0[071:064],extif_data_0[055:048],extif_data_0[039:032],extif_data_0[023:016],extif_data_0[007:000]
                              };

  assign cur_chroma_addr_o  = { cur_chroma_addr[5],
                                cur_chroma_addr[0],
                                cur_chroma_addr[4:1]
                              };

  // ref_chroma
  always @(posedge clk or negedge rstn ) begin
    if( !rstn ) begin
      ref_chroma_addr    <= 0 ;
      ref_chroma_cnt     <= 0 ;
    end
    else if( cur_fetch!=nxt_fetch ) begin
      ref_chroma_addr    <= 0 ;
      ref_chroma_cnt     <= 0 ;
    end
    else if( (cur_fetch==LOAD_REF_CHROMA) && extif_wren_i ) begin
      if( ref_chroma_cnt==(48/AXI_WIDTH_PIXEL*2-1) ) begin
        ref_chroma_cnt     <= 0 ;
        ref_chroma_addr    <= ref_chroma_addr+1 ;
      end
      else begin
        ref_chroma_addr    <= ref_chroma_addr   ;
        ref_chroma_cnt     <= ref_chroma_cnt+1  ;
      end
    end
  end

  assign ref_chroma_valid_o = (cur_fetch==LOAD_REF_CHROMA) && extif_wren_i && ref_chroma_cnt==(48/AXI_WIDTH_PIXEL*2-1) ;
  assign ref_chroma_addr_o  = ref_chroma_addr ;
  assign ref_chroma_u_data  = { extif_data_4[127:120],extif_data_4[111:104],extif_data_4[095:088],extif_data_4[079:072],extif_data_4[063:056],extif_data_4[047:040],extif_data_4[031:024],extif_data_4[015:008]
                               ,extif_data_3[127:120],extif_data_3[111:104],extif_data_3[095:088],extif_data_3[079:072],extif_data_3[063:056],extif_data_3[047:040],extif_data_3[031:024],extif_data_3[015:008]
                               ,extif_data_2[127:120],extif_data_2[111:104],extif_data_2[095:088],extif_data_2[079:072],extif_data_2[063:056],extif_data_2[047:040],extif_data_2[031:024],extif_data_2[015:008]
                               ,extif_data_1[127:120],extif_data_1[111:104],extif_data_1[095:088],extif_data_1[079:072],extif_data_1[063:056],extif_data_1[047:040],extif_data_1[031:024],extif_data_1[015:008]
                               ,extif_data_0[127:120],extif_data_0[111:104],extif_data_0[095:088],extif_data_0[079:072],extif_data_0[063:056],extif_data_0[047:040],extif_data_0[031:024],extif_data_0[015:008]
                               ,extif_data_i[127:120],extif_data_i[111:104],extif_data_i[095:088],extif_data_i[079:072],extif_data_i[063:056],extif_data_i[047:040],extif_data_i[031:024],extif_data_i[015:008]
                               };
  assign ref_chroma_v_data  = { extif_data_4[119:112],extif_data_4[103:096],extif_data_4[087:080],extif_data_4[071:064],extif_data_4[055:048],extif_data_4[039:032],extif_data_4[023:016],extif_data_4[007:000]
                               ,extif_data_3[119:112],extif_data_3[103:096],extif_data_3[087:080],extif_data_3[071:064],extif_data_3[055:048],extif_data_3[039:032],extif_data_3[023:016],extif_data_3[007:000]
                               ,extif_data_2[119:112],extif_data_2[103:096],extif_data_2[087:080],extif_data_2[071:064],extif_data_2[055:048],extif_data_2[039:032],extif_data_2[023:016],extif_data_2[007:000]
                               ,extif_data_1[119:112],extif_data_1[103:096],extif_data_1[087:080],extif_data_1[071:064],extif_data_1[055:048],extif_data_1[039:032],extif_data_1[023:016],extif_data_1[007:000]
                               ,extif_data_0[119:112],extif_data_0[103:096],extif_data_0[087:080],extif_data_0[071:064],extif_data_0[055:048],extif_data_0[039:032],extif_data_0[023:016],extif_data_0[007:000]
                               ,extif_data_i[119:112],extif_data_i[103:096],extif_data_i[087:080],extif_data_i[071:064],extif_data_i[055:048],extif_data_i[039:032],extif_data_i[023:016],extif_data_i[007:000]
                               };
  assign ref_chroma_u_lshift = {{8{ref_chroma_u_data[48*`PIXEL_WIDTH-1:47*`PIXEL_WIDTH]}},ref_chroma_u_data}>>(8*`PIXEL_WIDTH) ;
  assign ref_chroma_v_lshift = {{8{ref_chroma_v_data[48*`PIXEL_WIDTH-1:47*`PIXEL_WIDTH]}},ref_chroma_v_data}>>(8*`PIXEL_WIDTH) ;
  assign ref_chroma_u_rshift = {ref_chroma_u_data>>(8*`PIXEL_WIDTH),{8{ref_chroma_u_data[09*`PIXEL_WIDTH-1:08*`PIXEL_WIDTH]}}} ;
  assign ref_chroma_v_rshift = {ref_chroma_v_data>>(8*`PIXEL_WIDTH),{8{ref_chroma_v_data[09*`PIXEL_WIDTH-1:08*`PIXEL_WIDTH]}}} ;

  always @ (*) begin
    if ( chroma_ref_lshift_r2 )
      ref_chroma_data_o = { ref_chroma_u_lshift ,ref_chroma_v_lshift };
    else if ( chroma_ref_rshift_r2 )
      ref_chroma_data_o = { ref_chroma_u_rshift ,ref_chroma_v_rshift };
    else begin
      ref_chroma_data_o = { ref_chroma_u_data   ,ref_chroma_v_data   };
    end
  end

  // db_ref_addr_o
  always @(posedge clk or negedge rstn ) begin
    if( !rstn ) begin
      db_ref_addr_o <= 0 ;
    end
    else if( (cur_fetch==LOAD_DB_LUMA) & extif_start_o ) begin
      db_ref_addr_o <= 0 ;
    end
    else if( ((cur_fetch==LOAD_DB_LUMA)|(cur_fetch==LOAD_DB_CHROMA)) & extif_wren_i ) begin
      db_ref_addr_o <= db_ref_addr_o + 1;
    end
  end

  // cur_state_db_store
  always @(posedge clk or negedge rstn ) begin
    if( !rstn )
      cur_state_db_store   <= DB_STORE_IDLE ;
    else begin
      cur_state_db_store   <= nxt_state_db_store ;
    end
  end

  // nxt_state_db_store
  always @(*) begin
                                                            nxt_state_db_store = DB_STORE_IDLE     ;
    case( cur_state_db_store )
      DB_STORE_IDLE     : if( (cur_fetch==STORE_DB_LUMA)&(extif_start_o) )
                            if( store_db_chroma_y_i==0 )    nxt_state_db_store = DB_STORE_LUMA_CUR ;
                            else                            nxt_state_db_store = DB_STORE_LUMA_PRE ;
                          else                              nxt_state_db_store = DB_STORE_IDLE     ;
      DB_STORE_LUMA_PRE : if( db_store_done_w )             nxt_state_db_store = DB_STORE_LUMA_CUR ;
                          else                              nxt_state_db_store = DB_STORE_LUMA_PRE ;
      DB_STORE_LUMA_CUR : if( db_store_done_w )
                            if( store_db_chroma_y_i==0 )    nxt_state_db_store = DB_STORE_CHRO_CUR ;
                            else                            nxt_state_db_store = DB_STORE_CHRO_PRE ;
                          else                              nxt_state_db_store = DB_STORE_LUMA_CUR ;
      DB_STORE_CHRO_PRE : if( db_store_done_w )             nxt_state_db_store = DB_STORE_CHRO_CUR ;
                          else                              nxt_state_db_store = DB_STORE_CHRO_PRE ;
      DB_STORE_CHRO_CUR : if( db_store_done_w )             nxt_state_db_store = DB_STORE_IDLE     ;
                          else                              nxt_state_db_store = DB_STORE_CHRO_CUR ;
    endcase
  end

  // db_store_done_w
  always @(*) begin
                          db_store_done_w = ( db_store_addr_r == (  1-1) ) & extif_rden_i ;
    case( cur_state_db_store )
      DB_STORE_IDLE     : db_store_done_w = ( db_store_addr_r == (  1-1) ) & extif_rden_i ;
      DB_STORE_LUMA_PRE : db_store_done_w = ( db_store_addr_r == ( 16-1) ) & extif_rden_i ;
      DB_STORE_LUMA_CUR : db_store_done_w = ( db_store_addr_r == (256-1) ) & extif_rden_i ;
      DB_STORE_CHRO_PRE : db_store_done_w = ( db_store_addr_r == ( 16-1) ) & extif_rden_i ;
      DB_STORE_CHRO_CUR : db_store_done_w = ( db_store_addr_r == (128-1) ) & extif_rden_i ;
    endcase
  end

  // db_store_addr_r
  always @(posedge clk or negedge rstn ) begin
    if( !rstn ) begin
      db_store_addr_r <= 0 ;
    end
    else if( (cur_fetch==STORE_DB_LUMA) & extif_start_o ) begin
      db_store_addr_r <= 0 ;
    end
    else if( ((cur_fetch==STORE_DB_LUMA)|(cur_fetch==STORE_DB_CHROMA)) & extif_rden_i ) begin
      if( db_store_done_w )
        db_store_addr_r <= 0 ;
      else begin
        db_store_addr_r <= db_store_addr_r + 1 ;
      end
    end
  end

  // db_store_addr_w
  always @(*) begin
    db_store_addr_w = db_store_addr_r ;
    if( (cur_fetch==STORE_DB_LUMA) & extif_start_o )
      db_store_addr_w = 0 ;
    else if( (cur_fetch==STORE_DB_LUMA)|(cur_fetch==STORE_DB_CHROMA) ) begin
      if( extif_rden_i ) begin
        if( db_store_done_w )
          db_store_addr_w = 0 ;
        else begin
          db_store_addr_w = db_store_addr_r + 1 ;
        end
      end
      else begin
        db_store_addr_w = db_store_addr_r ;
      end
    end
  end

  // cur_state_db_store_d
  always @(posedge clk or negedge rstn ) begin
    if( !rstn )
      cur_state_db_store_d <= 0 ;
    else if( (cur_fetch==STORE_DB_LUMA) | (cur_fetch==STORE_DB_CHROMA) & extif_rden_i )begin
      cur_state_db_store_d <= nxt_state_db_store ;
    end
  end

  // db_store_addr_o
  always @(*) begin
                          db_store_addr_o =   0 ;
    case( nxt_state_db_store )
      DB_STORE_IDLE     : db_store_addr_o =   0 ;
      DB_STORE_LUMA_PRE : db_store_addr_o = 192 + { db_store_addr_w[8:4] ,db_store_addr_w[1] ,db_store_addr_w[3:2] };
      DB_STORE_LUMA_CUR : db_store_addr_o =   0 + { db_store_addr_w[8:7] ,db_store_addr_w[1] ,db_store_addr_w[6:2] };
      DB_STORE_CHRO_PRE : db_store_addr_o = 200 + { db_store_addr_w[8:4] ,db_store_addr_w[1] ,db_store_addr_w[3:2] };
      DB_STORE_CHRO_CUR : db_store_addr_o = 128 + { db_store_addr_w[8:4] ,db_store_addr_w[1] ,db_store_addr_w[3:2] };
    endcase
  end

  // load db
  assign db_ref_en_o    = ( (cur_fetch==LOAD_DB_LUMA)|(cur_fetch==LOAD_DB_CHROMA) ) && extif_wren_i ;
  assign db_ref_data_o  = ( db_ref_addr_o<16 ) ? extif_data_i :
                          { extif_data_i[127:120],extif_data_i[111:104],extif_data_i[095:088],extif_data_i[079:072],extif_data_i[063:056],extif_data_i[047:040],extif_data_i[031:024],extif_data_i[015:008]
                           ,extif_data_i[119:112],extif_data_i[103:096],extif_data_i[087:080],extif_data_i[071:064],extif_data_i[055:048],extif_data_i[039:032],extif_data_i[023:016],extif_data_i[007:000]
                          } ;

endmodule

