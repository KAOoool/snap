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
//  Filename      : sys_ctrl.v
//  Author        : Huang Leilei
//  Created       : 2016-03-20
//  Description   : system controller of enc_core and fetch
//
//-------------------------------------------------------------------
//
//  Modified      : 2016-03-22 by HLL
//  Description   : ena, x & y for fetch added
//  Modified      : 2016-03-22 by HLL
//  Description   : pipeline stages modified
//
//-------------------------------------------------------------------

`include "enc_defines.v"

module sys_ctrl(
  // global
  clk                      ,
  rst_n                    ,
  // sys_if
  sys_start_i              ,
  sys_type_i               ,
  sys_x_total_i            ,
  sys_y_total_i            ,
  sys_qp_i                 ,
  sys_done_o               ,
  // start_if
  enc_start_o              ,
  // done_if
  fetch_done_i             ,
  pre_i_done_i             ,
  intra_done_i             ,
  ime_done_i               ,
  fme_done_i               ,
  mc_done_i                ,
  db_done_i                ,
  ec_done_i                ,
  // start for enc_core
  pre_l_start_o            ,
  pre_i_start_o            ,
  intra_start_o            ,
  ime_start_o              ,
  fme_start_o              ,
  mc_start_o               ,
  db_start_o               ,
  ec_start_o               ,
  store_db_start_o         ,
  // x & y for enc_core
  pre_l_x_o                ,
  pre_l_y_o                ,
  pre_i_x_o                ,
  pre_i_y_o                ,
  intra_x_o                ,
  intra_y_o                ,
  ime_x_o                  ,
  ime_y_o                  ,
  fme_x_o                  ,
  fme_y_o                  ,
  mc_x_o                   ,
  mc_y_o                   ,
  db_x_o                   ,
  db_y_o                   ,
  ec_x_o                   ,
  ec_y_o                   ,
  store_db_x_o             ,
  store_db_y_o             ,
  // qp for enc_core
  pre_l_qp_o               ,
  pre_i_qp_o               ,
  intra_qp_o               ,
  ime_qp_o                 ,
  fme_qp_o                 ,
  mc_qp_o                  ,
  db_qp_o                  ,
  ec_qp_o                  ,
  store_db_qp_o            ,
  // ena for fetch
  load_cur_luma_ena_o      ,
  load_ref_luma_ena_o      ,
  load_cur_chroma_ena_o    ,
  load_ref_chroma_ena_o    ,
  load_db_luma_ena_o       ,
  load_db_chroma_ena_o     ,
  store_db_luma_ena_o      ,
  store_db_chroma_ena_o    ,
  // x & y for fetch
  load_cur_luma_x_o        ,
  load_cur_luma_y_o        ,
  load_ref_luma_x_o        ,
  load_ref_luma_y_o        ,
  load_cur_chroma_x_o      ,
  load_cur_chroma_y_o      ,
  load_ref_chroma_x_o      ,
  load_ref_chroma_y_o      ,
  load_db_luma_x_o         ,
  load_db_luma_y_o         ,
  load_db_chroma_x_o       ,
  load_db_chroma_y_o       ,
  store_db_luma_x_o        ,
  store_db_luma_y_o        ,
  store_db_chroma_x_o      ,
  store_db_chroma_y_o
  );


//*** PARAMETER ****************************************************************

  localparam                         IDLE  = 0+00          ,
                                     S0    = 1+00          ,
                                     S1    = 1+01          ,
                                     S2    = 1+02          ,
                                     S3    = 1+03          ,
                                     S4    = 1+04          ,
                                     S5    = 1+05          ,
                                     S6    = 1+06          ,
                                     S7    = 1+07          ,
                                     S8    = 1+08          ,
                                     S9    = 1+09          ,
                                     SA    = 1+10          ;

  localparam                         INTRA = 0             ,
                                     INTER = 1             ;


//*** INPUT/OUTPUT DECLARATION *************************************************

  // global
  input                              clk                   ;
  input                              rst_n                 ;
  // sys_if
  input                              sys_start_i           ;
  input                              sys_type_i            ;
  input      [`PIC_X_WIDTH-1 : 0]    sys_x_total_i         ;
  input      [`PIC_Y_WIDTH-1 : 0]    sys_y_total_i         ;
  input      [5              : 0]    sys_qp_i              ;
  output                             sys_done_o            ;
  // start_if
  output reg                         enc_start_o           ;
  // done_if
  input                              fetch_done_i          ;
  input                              pre_i_done_i          ;
  input                              intra_done_i          ;
  input                              ime_done_i            ;
  input                              fme_done_i            ;
  input                              mc_done_i             ;
  input                              db_done_i             ;
  input                              ec_done_i             ;
  // start for enc_core
  output reg                         pre_l_start_o         ;
  output reg                         pre_i_start_o         ;
  output reg                         intra_start_o         ;
  output reg                         ime_start_o           ;
  output reg                         fme_start_o           ;
  output reg                         mc_start_o            ;
  output reg                         db_start_o            ;
  output reg                         ec_start_o            ;
  output reg                         store_db_start_o      ;
  // x & y for enc_core
  output reg [`PIC_X_WIDTH-1 : 0]    pre_l_x_o             ;
  output reg [`PIC_Y_WIDTH-1 : 0]    pre_l_y_o             ;
  output reg [`PIC_X_WIDTH-1 : 0]    pre_i_x_o             ;
  output reg [`PIC_Y_WIDTH-1 : 0]    pre_i_y_o             ;
  output reg [`PIC_X_WIDTH-1 : 0]    intra_x_o             ;
  output reg [`PIC_Y_WIDTH-1 : 0]    intra_y_o             ;
  output reg [`PIC_X_WIDTH-1 : 0]    ime_x_o               ;
  output reg [`PIC_Y_WIDTH-1 : 0]    ime_y_o               ;
  output reg [`PIC_X_WIDTH-1 : 0]    fme_x_o               ;
  output reg [`PIC_Y_WIDTH-1 : 0]    fme_y_o               ;
  output reg [`PIC_X_WIDTH-1 : 0]    mc_x_o                ;
  output reg [`PIC_Y_WIDTH-1 : 0]    mc_y_o                ;
  output reg [`PIC_X_WIDTH-1 : 0]    db_x_o                ;
  output reg [`PIC_Y_WIDTH-1 : 0]    db_y_o                ;
  output reg [`PIC_X_WIDTH-1 : 0]    ec_x_o                ;
  output reg [`PIC_Y_WIDTH-1 : 0]    ec_y_o                ;
  output reg [`PIC_X_WIDTH-1 : 0]    store_db_x_o          ;
  output reg [`PIC_Y_WIDTH-1 : 0]    store_db_y_o          ;
  // qp for enc_core
  output reg [5              : 0]    pre_l_qp_o            ;
  output reg [5              : 0]    pre_i_qp_o            ;
  output reg [5              : 0]    intra_qp_o            ;
  output reg [5              : 0]    ime_qp_o              ;
  output reg [5              : 0]    fme_qp_o              ;
  output reg [5              : 0]    mc_qp_o               ;
  output reg [5              : 0]    db_qp_o               ;
  output reg [5              : 0]    ec_qp_o               ;
  output reg [5              : 0]    store_db_qp_o         ;
  // ena for fetch
  output reg                         load_cur_luma_ena_o   ;
  output reg                         load_ref_luma_ena_o   ;
  output reg                         load_cur_chroma_ena_o ;
  output reg                         load_ref_chroma_ena_o ;
  output reg                         load_db_luma_ena_o    ;
  output reg                         load_db_chroma_ena_o  ;
  output reg                         store_db_luma_ena_o   ;
  output reg                         store_db_chroma_ena_o ;
  // x & y for fetch
  output reg [`PIC_X_WIDTH-1 : 0]    load_cur_luma_x_o     ;
  output reg [`PIC_Y_WIDTH-1 : 0]    load_cur_luma_y_o     ;
  output reg [`PIC_X_WIDTH-1 : 0]    load_ref_luma_x_o     ;
  output reg [`PIC_Y_WIDTH-1 : 0]    load_ref_luma_y_o     ;
  output reg [`PIC_X_WIDTH-1 : 0]    load_cur_chroma_x_o   ;
  output reg [`PIC_Y_WIDTH-1 : 0]    load_cur_chroma_y_o   ;
  output reg [`PIC_X_WIDTH-1 : 0]    load_ref_chroma_x_o   ;
  output reg [`PIC_Y_WIDTH-1 : 0]    load_ref_chroma_y_o   ;
  output reg [`PIC_X_WIDTH-1 : 0]    load_db_luma_x_o      ;
  output reg [`PIC_Y_WIDTH-1 : 0]    load_db_luma_y_o      ;
  output reg [`PIC_X_WIDTH-1 : 0]    load_db_chroma_x_o    ;
  output reg [`PIC_Y_WIDTH-1 : 0]    load_db_chroma_y_o    ;
  output reg [`PIC_X_WIDTH-1 : 0]    store_db_luma_x_o     ;
  output reg [`PIC_Y_WIDTH-1 : 0]    store_db_luma_y_o     ;
  output reg [`PIC_X_WIDTH-1 : 0]    store_db_chroma_x_o   ;
  output reg [`PIC_Y_WIDTH-1 : 0]    store_db_chroma_y_o   ;


//*** WIRE/REG DECLARATION *****************************************************

  // fsm
  reg        [3              : 0]    nxt_state             ;
  reg        [3              : 0]    cur_state             ;
  // ena
  reg                                pre_l_ena             ;
  reg                                pre_i_ena             ;
  reg                                intra_ena             ;
  reg                                ime_ena               ;
  reg                                fme_ena               ;
  reg                                mc_ena                ;
  reg                                db_ena                ;
  reg                                ec_ena                ;
  reg                                store_db_ena          ;
  // flg
  reg                                fetch_flg             ;
  reg                                pre_i_flg             ;
  reg                                intra_flg             ;
  reg                                ime_flg               ;
  reg                                fme_flg               ;
  reg                                mc_flg                ;
  reg                                db_flg                ;
  reg                                ec_flg                ;
  // enc
  reg                                enc_start_w           ;
  reg                                enc_done_r            ;


//*** MAIN BODY ****************************************************************

//--- GLOBAL ---------------------------

  assign sys_done_o = cur_state==IDLE ;

  always @(*) begin
    if( cur_state==IDLE )
      enc_start_w = sys_start_i ;
    else if( ((sys_type_i==INTRA)&&(cur_state==S8)) || ((sys_type_i==INTER)&&(cur_state==SA)) )
      enc_start_w = 0 ;
    else begin
      enc_start_w = enc_done_r ;
    end
  end

  always @(posedge clk or negedge rst_n ) begin
    if( !rst_n )
      enc_start_o <= 0 ;
    else begin
      enc_start_o <= enc_start_w ;
    end
  end

//--- FSM ------------------------------
  // cur state
  always @(posedge clk or negedge rst_n ) begin
    if( !rst_n )
      cur_state <= IDLE ;
    else begin
      cur_state <= nxt_state ;
    end
  end

  // nxt state
  always @(*) begin
                                 nxt_state = IDLE ;
    if( sys_type_i==INTRA )
      case( cur_state )
        IDLE : if( sys_start_i ) nxt_state = S0   ; else nxt_state = IDLE ;
        S0   : if( enc_start_w ) nxt_state = S1   ; else nxt_state = S0   ;
        S1   : if( enc_start_w ) nxt_state = S2   ; else nxt_state = S1   ;
        S2   : if( enc_start_w ) nxt_state = S3   ; else nxt_state = S2   ;
        S3   : if( enc_start_w ) nxt_state = S4   ; else nxt_state = S3   ;
        S4   : if( enc_start_w && (pre_l_x_o==sys_x_total_i) && (pre_l_y_o==sys_y_total_i) )
                                 nxt_state = S5   ; else nxt_state = S4   ;
        S5   : if( enc_start_w ) nxt_state = S6   ; else nxt_state = S5   ;
        S6   : if( enc_start_w ) nxt_state = S7   ; else nxt_state = S6   ;
        S7   : if( enc_start_w ) nxt_state = S8   ; else nxt_state = S7   ;
        S8   : if( enc_done_r  ) nxt_state = IDLE ; else nxt_state = S8   ;
      endcase
    else begin
      case( cur_state )
        IDLE : if( sys_start_i ) nxt_state = S0   ; else nxt_state = IDLE ;
        S0   : if( enc_start_w ) nxt_state = S1   ; else nxt_state = S0   ;
        S1   : if( enc_start_w ) nxt_state = S2   ; else nxt_state = S1   ;
        S2   : if( enc_start_w ) nxt_state = S3   ; else nxt_state = S2   ;
        S3   : if( enc_start_w ) nxt_state = S4   ; else nxt_state = S3   ;
        S4   : if( enc_start_w ) nxt_state = S5   ; else nxt_state = S4   ;
        S5   : if( enc_start_w && (pre_l_x_o==sys_x_total_i) && (pre_l_y_o==sys_y_total_i) )
                                 nxt_state = S6   ; else nxt_state = S5   ;
        S6   : if( enc_start_w ) nxt_state = S7   ; else nxt_state = S6   ;
        S7   : if( enc_start_w ) nxt_state = S8   ; else nxt_state = S7   ;
        S8   : if( enc_start_w ) nxt_state = S9   ; else nxt_state = S8   ;
        S9   : if( enc_start_w ) nxt_state = SA   ; else nxt_state = S9   ;
        SA   : if( enc_done_r  ) nxt_state = IDLE ; else nxt_state = SA   ;
      endcase
    end
  end

//--- ENA ------------------------------
  // ena_for_enc_core
  always @(*) begin
             {pre_l_ena ,pre_i_ena,intra_ena, ime_ena,fme_ena,mc_ena ,db_ena,ec_ena,store_db_ena} = 9'b0_00_000_000 ;
    if( sys_type_i == INTRA )
      case( cur_state )
        S0 : {pre_l_ena ,pre_i_ena,intra_ena, db_ena,ec_ena,store_db_ena} = 6'b1_00_000 ;
        S1 : {pre_l_ena ,pre_i_ena,intra_ena, db_ena,ec_ena,store_db_ena} = 6'b1_10_000 ;
        S2 : {pre_l_ena ,pre_i_ena,intra_ena, db_ena,ec_ena,store_db_ena} = 6'b1_11_000 ;
        S3 : {pre_l_ena ,pre_i_ena,intra_ena, db_ena,ec_ena,store_db_ena} = 6'b1_11_100 ;
        S4 : {pre_l_ena ,pre_i_ena,intra_ena, db_ena,ec_ena,store_db_ena} = 6'b1_11_111 ;
        S5 : {pre_l_ena ,pre_i_ena,intra_ena, db_ena,ec_ena,store_db_ena} = 6'b0_11_111 ;
        S6 : {pre_l_ena ,pre_i_ena,intra_ena, db_ena,ec_ena,store_db_ena} = 6'b0_01_111 ;
        S7 : {pre_l_ena ,pre_i_ena,intra_ena, db_ena,ec_ena,store_db_ena} = 6'b0_00_111 ;
        S8 : {pre_l_ena ,pre_i_ena,intra_ena, db_ena,ec_ena,store_db_ena} = 6'b0_00_011 ;
      endcase
    else begin
      case( cur_state )
        S0 : {pre_l_ena ,ime_ena,fme_ena,mc_ena ,db_ena,ec_ena,store_db_ena} = 7'b1_000_000 ;
        S1 : {pre_l_ena ,ime_ena,fme_ena,mc_ena ,db_ena,ec_ena,store_db_ena} = 7'b1_100_000 ;
        S2 : {pre_l_ena ,ime_ena,fme_ena,mc_ena ,db_ena,ec_ena,store_db_ena} = 7'b1_110_000 ;
        S3 : {pre_l_ena ,ime_ena,fme_ena,mc_ena ,db_ena,ec_ena,store_db_ena} = 7'b1_111_000 ;
        S4 : {pre_l_ena ,ime_ena,fme_ena,mc_ena ,db_ena,ec_ena,store_db_ena} = 7'b1_111_100 ;
        S5 : {pre_l_ena ,ime_ena,fme_ena,mc_ena ,db_ena,ec_ena,store_db_ena} = 7'b1_111_111 ;
        S6 : {pre_l_ena ,ime_ena,fme_ena,mc_ena ,db_ena,ec_ena,store_db_ena} = 7'b0_111_111 ;
        S7 : {pre_l_ena ,ime_ena,fme_ena,mc_ena ,db_ena,ec_ena,store_db_ena} = 7'b0_011_111 ;
        S8 : {pre_l_ena ,ime_ena,fme_ena,mc_ena ,db_ena,ec_ena,store_db_ena} = 7'b0_001_111 ;
        S9 : {pre_l_ena ,ime_ena,fme_ena,mc_ena ,db_ena,ec_ena,store_db_ena} = 7'b0_000_111 ;
        SA : {pre_l_ena ,ime_ena,fme_ena,mc_ena ,db_ena,ec_ena,store_db_ena} = 7'b0_000_011 ;
      endcase
    end
  end

  // ena for fetch
  always @(*) begin
    if( sys_type_i == INTRA ) begin
      load_cur_luma_ena_o   = pre_l_ena    ;
      load_ref_luma_ena_o   = 0            ;
      load_cur_chroma_ena_o = pre_i_ena    ;
      load_ref_chroma_ena_o = 0            ;
      load_db_luma_ena_o    = intra_ena    & (intra_y_o !=0)   ;
      load_db_chroma_ena_o  = intra_ena    & (intra_y_o !=0)   ;
      store_db_luma_ena_o   = store_db_ena & (store_db_x_o!=0) ;
      store_db_chroma_ena_o = store_db_ena & (store_db_x_o!=0) ;
    end
    else begin
      load_cur_luma_ena_o   = pre_l_ena    ;
      load_ref_luma_ena_o   = pre_l_ena    ;
      load_cur_chroma_ena_o = fme_ena      ;
      load_ref_chroma_ena_o = fme_ena      ;
      load_db_luma_ena_o    = mc_ena       & (mc_y_o!=0)       ;
      load_db_chroma_ena_o  = mc_ena       & (mc_y_o!=0)       ;
      store_db_luma_ena_o   = store_db_ena & (store_db_x_o!=0) ;
      store_db_chroma_ena_o = store_db_ena & (store_db_x_o!=0) ;
    end
  end

//--- START ----------------------------
  // start_o
  always @(posedge clk or negedge rst_n ) begin
    if( !rst_n ) begin
      pre_l_start_o    <= 0 ;
      pre_i_start_o    <= 0 ;
      intra_start_o    <= 0 ;
      ime_start_o      <= 0 ;
      fme_start_o      <= 0 ;
      mc_start_o       <= 0 ;
      db_start_o       <= 0 ;
      ec_start_o       <= 0 ;
      store_db_start_o <= 0 ;
    end
    else if( enc_start_o ) begin
      pre_l_start_o    <= pre_l_ena    ;
      pre_i_start_o    <= pre_i_ena    ;
      intra_start_o    <= intra_ena    ;
      ime_start_o      <= ime_ena      ;
      fme_start_o      <= fme_ena      ;
      mc_start_o       <= mc_ena       ;
      db_start_o       <= db_ena       ;
      ec_start_o       <= ec_ena       ;
      store_db_start_o <= store_db_ena ;
    end
    else begin
      pre_l_start_o    <= 0 ;
      pre_i_start_o    <= 0 ;
      intra_start_o    <= 0 ;
      ime_start_o      <= 0 ;
      fme_start_o      <= 0 ;
      mc_start_o       <= 0 ;
      db_start_o       <= 0 ;
      ec_start_o       <= 0 ;
      store_db_start_o <= 0 ;
    end
  end

//--- DONE -----------------------------
  // x_flg (done_flag)
  always @(posedge clk or negedge rst_n ) begin
    if( !rst_n ) begin
      fetch_flg <= 0 ;
      pre_i_flg <= 0 ;
      intra_flg <= 0 ;
      ime_flg   <= 0 ;
      fme_flg   <= 0 ;
      mc_flg    <= 0 ;
      db_flg    <= 0 ;
      ec_flg    <= 0 ;
    end
    else if ( cur_state==IDLE ) begin
      fetch_flg <= 0 ;
      pre_i_flg <= 0 ;
      intra_flg <= 0 ;
      ime_flg   <= 0 ;
      fme_flg   <= 0 ;
      mc_flg    <= 0 ;
      db_flg    <= 0 ;
      ec_flg    <= 0 ;
    end
    else if ( enc_done_r ) begin
      fetch_flg <= 0 ;
      pre_i_flg <= 0 ;
      intra_flg <= 0 ;
      ime_flg   <= 0 ;
      fme_flg   <= 0 ;
      mc_flg    <= 0 ;
      db_flg    <= 0 ;
      ec_flg    <= 0 ;
    end
    else begin
      fetch_flg <= fetch_done_i | fetch_flg ;
      pre_i_flg <= pre_i_done_i | pre_i_flg ;
      intra_flg <= intra_done_i | intra_flg ;
      ime_flg   <= ime_done_i   | ime_flg   ;
      fme_flg   <= fme_done_i   | fme_flg   ;
      mc_flg    <= mc_done_i    | mc_flg    ;
      db_flg    <= db_done_i    | db_flg    ;
      ec_flg    <= ec_done_i    | ec_flg    ;
    end
  end

  // enc_done_r
  always @(posedge clk or negedge rst_n ) begin
    if( !rst_n )
                                                                                            enc_done_r <= 0 ;
    else if( enc_done_r )
                                                                                            enc_done_r <= 0 ;
    else begin
                                                                                            enc_done_r <= 0 ;
      if( sys_type_i == INTRA )
        case( cur_state )
          S0   : if( {fetch_flg ,pre_i_flg,intra_flg ,db_flg,ec_flg} == 5'b1_00_00 )        enc_done_r <= 1 ;
          S1   : if( {fetch_flg ,pre_i_flg,intra_flg ,db_flg,ec_flg} == 5'b1_10_00 )        enc_done_r <= 1 ;
          S2   : if( {fetch_flg ,pre_i_flg,intra_flg ,db_flg,ec_flg} == 5'b1_11_00 )        enc_done_r <= 1 ;
          S3   : if( {fetch_flg ,pre_i_flg,intra_flg ,db_flg,ec_flg} == 5'b1_11_10 )        enc_done_r <= 1 ;
          S4   : if( {fetch_flg ,pre_i_flg,intra_flg ,db_flg,ec_flg} == 5'b1_11_11 )        enc_done_r <= 1 ;
          S5   : if( {fetch_flg ,pre_i_flg,intra_flg ,db_flg,ec_flg} == 5'b1_11_11 )        enc_done_r <= 1 ;
          S6   : if( {fetch_flg ,pre_i_flg,intra_flg ,db_flg,ec_flg} == 5'b1_01_11 )        enc_done_r <= 1 ;
          S7   : if( {fetch_flg ,pre_i_flg,intra_flg ,db_flg,ec_flg} == 5'b1_00_11 )        enc_done_r <= 1 ;
          S8   : if( {fetch_flg ,pre_i_flg,intra_flg ,db_flg,ec_flg} == 5'b1_00_01 )        enc_done_r <= 1 ;
        endcase
      else begin
        case( cur_state )
          S0   : if( {fetch_flg ,ime_flg,fme_flg,mc_flg ,db_flg,ec_flg} == 6'b1_000_00 )    enc_done_r <= 1 ;
          S1   : if( {fetch_flg ,ime_flg,fme_flg,mc_flg ,db_flg,ec_flg} == 6'b1_100_00 )    enc_done_r <= 1 ;
          S2   : if( {fetch_flg ,ime_flg,fme_flg,mc_flg ,db_flg,ec_flg} == 6'b1_110_00 )    enc_done_r <= 1 ;
          S3   : if( {fetch_flg ,ime_flg,fme_flg,mc_flg ,db_flg,ec_flg} == 6'b1_111_00 )    enc_done_r <= 1 ;
          S4   : if( {fetch_flg ,ime_flg,fme_flg,mc_flg ,db_flg,ec_flg} == 6'b1_111_10 )    enc_done_r <= 1 ;
          S5   : if( {fetch_flg ,ime_flg,fme_flg,mc_flg ,db_flg,ec_flg} == 6'b1_111_11 )    enc_done_r <= 1 ;
          S6   : if( {fetch_flg ,ime_flg,fme_flg,mc_flg ,db_flg,ec_flg} == 6'b1_111_11 )    enc_done_r <= 1 ;
          S7   : if( {fetch_flg ,ime_flg,fme_flg,mc_flg ,db_flg,ec_flg} == 6'b1_011_11 )    enc_done_r <= 1 ;
          S8   : if( {fetch_flg ,ime_flg,fme_flg,mc_flg ,db_flg,ec_flg} == 6'b1_001_11 )    enc_done_r <= 1 ;
          S9   : if( {fetch_flg ,ime_flg,fme_flg,mc_flg ,db_flg,ec_flg} == 6'b1_000_11 )    enc_done_r <= 1 ;
          SA   : if( {fetch_flg ,ime_flg,fme_flg,mc_flg ,db_flg,ec_flg} == 6'b1_000_01 )    enc_done_r <= 1 ;
        endcase
      end
    end
  end

//--- X & Y ----------------------------
  // pre_l x y
  always @(posedge clk or negedge rst_n ) begin
    if( !rst_n )begin
      pre_l_x_o <= 0;
      pre_l_y_o <= 0;
    end
    else if( cur_state==IDLE )begin
      pre_l_x_o <= 0 ;
      pre_l_y_o <= 0 ;
    end
    else if( enc_done_r )begin
      if( pre_l_x_o == sys_x_total_i )begin
        pre_l_x_o <= 0 ;
        if ( pre_l_y_o == sys_y_total_i )
          pre_l_y_o <= 0 ;
        else begin
          pre_l_y_o <= pre_l_y_o + 1 ;
        end
      end
      else begin
        pre_l_x_o <= pre_l_x_o + 1 ;
        pre_l_y_o <= pre_l_y_o ;
      end
    end
  end

  // x & y for enc_core
  always @(posedge clk or negedge rst_n ) begin
    if( !rst_n ) begin
      pre_i_x_o    <= 0 ;
      pre_i_y_o    <= 0 ;
      intra_x_o    <= 0 ;
      intra_y_o    <= 0 ;
      ime_x_o      <= 0 ;
      ime_y_o      <= 0 ;
      fme_x_o      <= 0 ;
      fme_y_o      <= 0 ;
      mc_x_o       <= 0 ;
      mc_y_o       <= 0 ;
      db_x_o       <= 0 ;
      db_y_o       <= 0 ;
      ec_x_o       <= 0 ;
      ec_y_o       <= 0 ;
      store_db_x_o <= 0 ;
      store_db_y_o <= 0 ;
    end
    else if( cur_state==IDLE ) begin
      pre_i_x_o    <= 0 ;
      pre_i_y_o    <= 0 ;
      intra_x_o    <= 0 ;
      intra_y_o    <= 0 ;
      ime_x_o      <= 0 ;
      ime_y_o      <= 0 ;
      fme_x_o      <= 0 ;
      fme_y_o      <= 0 ;
      mc_x_o       <= 0 ;
      mc_y_o       <= 0 ;
      db_x_o       <= 0 ;
      db_y_o       <= 0 ;
      ec_x_o       <= 0 ;
      ec_y_o       <= 0 ;
      store_db_x_o <= 0 ;
      store_db_y_o <= 0 ;
    end
    else if( enc_done_r ) begin
      if( sys_type_i==INTRA ) begin
        pre_i_x_o    <= pre_l_x_o ;
        pre_i_y_o    <= pre_l_y_o ;
        intra_x_o    <= pre_i_x_o ;
        intra_y_o    <= pre_i_y_o ;
        ime_x_o      <= 0         ;
        ime_y_o      <= 0         ;
        fme_x_o      <= 0         ;
        fme_y_o      <= 0         ;
        mc_x_o       <= 0         ;
        mc_y_o       <= 0         ;
        db_x_o       <= intra_x_o ;
        db_y_o       <= intra_y_o ;
        ec_x_o       <= db_x_o    ;
        ec_y_o       <= db_y_o    ;
        store_db_x_o <= db_x_o    ;
        store_db_y_o <= db_y_o    ;
      end
      else begin
        pre_i_x_o    <= 0         ;
        pre_i_y_o    <= 0         ;
        intra_x_o    <= 0         ;
        intra_y_o    <= 0         ;
        ime_x_o      <= pre_l_x_o ;
        ime_y_o      <= pre_l_y_o ;
        fme_x_o      <= ime_x_o   ;
        fme_y_o      <= ime_y_o   ;
        mc_x_o       <= fme_x_o   ;
        mc_y_o       <= fme_y_o   ;
        db_x_o       <= mc_x_o    ;
        db_y_o       <= mc_y_o    ;
        ec_x_o       <= db_x_o    ;
        ec_y_o       <= db_y_o    ;
        store_db_x_o <= db_x_o    ;
        store_db_y_o <= db_y_o    ;
      end
    end
  end

  // x & y for fetch
  always @(*) begin
    if( sys_type_i == INTRA ) begin
      load_cur_luma_x_o   = pre_l_x_o    ;
      load_cur_luma_y_o   = pre_l_y_o    ;
      load_ref_luma_x_o   = 0            ;
      load_ref_luma_y_o   = 0            ;
      load_cur_chroma_x_o = pre_i_x_o    ;
      load_cur_chroma_y_o = pre_i_y_o    ;
      load_ref_chroma_x_o = 0            ;
      load_ref_chroma_y_o = 0            ;
      load_db_luma_x_o    = intra_x_o    ;
      load_db_luma_y_o    = intra_y_o    ;
      load_db_chroma_x_o  = intra_x_o    ;
      load_db_chroma_y_o  = intra_y_o    ;
      store_db_luma_x_o   = store_db_x_o ;
      store_db_luma_y_o   = store_db_y_o ;
      store_db_chroma_x_o = store_db_x_o ;
      store_db_chroma_y_o = store_db_y_o ;
    end
    else begin
      load_cur_luma_x_o   = pre_l_x_o    ;
      load_cur_luma_y_o   = pre_l_y_o    ;
      load_ref_luma_x_o   = pre_l_x_o    ;
      load_ref_luma_y_o   = pre_l_y_o    ;
      load_cur_chroma_x_o = fme_x_o      ;
      load_cur_chroma_y_o = fme_y_o      ;
      load_ref_chroma_x_o = fme_x_o      ;
      load_ref_chroma_y_o = fme_y_o      ;
      load_db_luma_x_o    = mc_x_o       ;
      load_db_luma_y_o    = mc_y_o       ;
      load_db_chroma_x_o  = mc_x_o       ;
      load_db_chroma_y_o  = mc_y_o       ;
      store_db_luma_x_o   = store_db_x_o ;
      store_db_luma_y_o   = store_db_y_o ;
      store_db_chroma_x_o = store_db_x_o ;
      store_db_chroma_y_o = store_db_y_o ;
    end
  end

//--- QP -------------------------------
  // qp for enc_core
  always @(posedge clk or negedge rst_n )begin
    if( !rst_n ) begin
      pre_l_qp_o    <= 0 ;
      pre_i_qp_o    <= 0 ;
      intra_qp_o    <= 0 ;
      ime_qp_o      <= 0 ;
      fme_qp_o      <= 0 ;
      mc_qp_o       <= 0 ;
      db_qp_o       <= 0 ;
      ec_qp_o       <= 0 ;
      store_db_qp_o <= 0 ;
    end
    else if( cur_state==IDLE ) begin
      pre_l_qp_o    <= 0 ;
      pre_i_qp_o    <= 0 ;
      intra_qp_o    <= 0 ;
      ime_qp_o      <= 0 ;
      fme_qp_o      <= 0 ;
      mc_qp_o       <= 0 ;
      db_qp_o       <= 0 ;
      ec_qp_o       <= 0 ;
      store_db_qp_o <= 0 ;
    end
    else if( enc_start_o ) begin
      if( sys_type_i==INTRA ) begin
        pre_l_qp_o    <= sys_qp_i   ;
        pre_i_qp_o    <= pre_l_qp_o ;
        intra_qp_o    <= pre_i_qp_o ;
        ime_qp_o      <= 0          ;
        fme_qp_o      <= 0          ;
        mc_qp_o       <= 0          ;
        db_qp_o       <= intra_qp_o ;
        ec_qp_o       <= db_qp_o    ;
        store_db_qp_o <= db_qp_o    ;
      end
      else begin
        pre_l_qp_o    <= sys_qp_i   ;
        pre_i_qp_o    <= 0          ;
        intra_qp_o    <= 0          ;
        ime_qp_o      <= pre_l_qp_o ;
        fme_qp_o      <= ime_qp_o   ;
        mc_qp_o       <= fme_qp_o   ;
        db_qp_o       <= mc_qp_o    ;
        ec_qp_o       <= db_qp_o    ;
        store_db_qp_o <= db_qp_o    ;
      end
    end
  end

endmodule
