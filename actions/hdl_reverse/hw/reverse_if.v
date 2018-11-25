`include "enc_defines.v"
`define XILINX 1

module reverse_if(
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
  // ext
  rden_i            ,
  data_o            ,
  // bs
  bs_val_i          ,
  bs_dat_i          ,
  // capi
  i_action_type     ,
  i_action_version  
  );


//*** PARAMETER DECLARATION ****************************************************
                                                     
  parameter    AXI_DW               = 512             ,
               AXI_AW0              = 64              ,
               AXI_AW1              = 32              ,
               AXI_MIDW             = 4               ;

  parameter    AXI_WID              = 0               ,
               AXI_RID              = 0               ;

  parameter    ADDR_SNAP_STATUS              = 0      ,
               ADDR_SNAP_INT_ENABLE          = 1      ,
               ADDR_SNAP_ACTION_TYPE         = 4      ,
               ADDR_SNAP_ACTION_VERSION      = 5      ,
               ADDR_SNAP_CONTEXT             = 8      ,
		           ADDR_START                    = 13     ,
               ADDR_LEN                      = 14     ,
               ADDR_ORI_BASE_HIGH            = 18     ,
               ADDR_ORI_BASE_LOW             = 19     ,
               ADDR_DONE                     = 23     ,
               ADDR_BS_BASE_HIGH             = 24     ,
               ADDR_BS_BASE_LOW              = 25     ;

  parameter    IDLE                          = 0      ,
               WAIT                          = 1      ,
               FETCH                         = 2      ,
               ACK                           = 3      ,
               RUN                           = 4      ,
               DUMP                          = 5      ;

  parameter    ORI_BASE_ADDR                 = 0      ,
               BS_BASE_ADDR                  = 1024   ;


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

  // ext_if
  input                             rden_i            ;
  output [16*`PIXEL_WIDTH-1 : 0]    data_o            ;

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
  reg    [AXI_AW1-1         : 0]    reg_ori_base_high ;
  reg    [AXI_AW1-1         : 0]    reg_ori_base_low  ;
  wire   [AXI_AW0-1         : 0]    reg_ori_base      ;
  reg    [AXI_AW1-1         : 0]    reg_bs_base_high  ;
  reg    [AXI_AW1-1         : 0]    reg_bs_base_low   ;
  wire   [AXI_AW0-1         : 0]    reg_bs_base       ;
  reg                               reg_done          ;
  reg    [31                : 0]    reg_len           ;

  wire                              fifo_rstn_loadpix ;
  wire   [AXI_DW-1          : 0]    data_in_loadpix   ;        
  wire                              pop_req_loadpix   ;        
  wire                              push_req_loadpix  ;
  wire   [16*`PIXEL_WIDTH-1 : 0]    data_out_loadpix  ;
  wire                              empty_loadpix     ;   

  wire                              fifo_rstn_bs      ;   
  wire                              pop_req_bs        ;        
  wire   [AXI_DW-1          : 0]    data_out_bs       ;
  wire                              empty_bs          ; 

  reg    [2                 : 0]    cur_state_0       ;
  reg    [2                 : 0]    nxt_state_0       ;

  reg    [AXI_AW0-1         : 0]    gen_m0_maddr      ;
  reg                               gen_m0_mread      ;
  reg    [AXI_AW0-1         : 0]    addr_offset_0     ;
  reg    [AXI_AW0-1         : 0]    addr_offset_bs    ;

  reg                               reg_start_r       ;
  reg                               reg_start_enc0    ;
  reg                               reg_start_enc1    ;
  reg                               reg_start_enc2    ;
  reg                               reg_start_ack0    ;
  reg                               reg_start_ack1    ;

  reg                               enc_done_r        ; 
  reg                               reg_done_axi0     ;
  reg                               reg_done_axi1     ;
  reg                               reg_done_axi2     ;
  reg                               reg_done_ack0     ;
  reg                               reg_done_ack1     ; 
  wire                              axi_done          ;

//*** MAIN ****************************************************************

  always @(posedge axi_clk or negedge axi_rstn) begin
    if( !axi_rstn )
      reg_start <= 0 ;
    else if( s_axi_wvalid && s_axi_wready && (s_axi_awaddr[6:2]==ADDR_START) && s_axi_wdata[0] )
      reg_start <= 1'b1 ;
    else 
      reg_start <= 1'b0 ;
  end

  always @(posedge axi_clk or negedge axi_rstn) begin
    if(!axi_rstn) begin
      reg_done <= 0;
    end 
    else begin
      if (reg_start)
        reg_done <= 0;
      else 
        if (cur_state_0 == WAIT && nxt_state_0 == IDLE)
          reg_done <= 1;
    end
  end

  // to other register
  always @(posedge axi_clk or negedge axi_rstn) begin
    if( !axi_rstn ) begin
                          reg_len            <= 1024            ;
                          reg_ori_base_low   <= ORI_BASE_ADDR   ;
                          reg_ori_base_high  <= 0 ;
                          reg_bs_base_low    <= BS_BASE_ADDR    ;
                          reg_bs_base_high   <= 0 ;
    end
    else if(s_axi_awvalid & s_axi_awready) begin
      case(s_axi_awaddr[6:2])
        ADDR_LEN            : reg_len            <= s_axi_wdata ;
        ADDR_ORI_BASE_HIGH  : reg_ori_base_high  <= s_axi_wdata ;
        ADDR_ORI_BASE_LOW   : reg_ori_base_low   <= s_axi_wdata ;
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
    ADDR_ORI_BASE_HIGH        : s_axi_rdata = reg_ori_base_high;
    ADDR_ORI_BASE_LOW         : s_axi_rdata = reg_ori_base_low;
    ADDR_BS_BASE_HIGH         : s_axi_rdata = reg_bs_base_high;
    ADDR_BS_BASE_LOW          : s_axi_rdata = reg_bs_base_low ;
    ADDR_DONE                 : s_axi_rdata = reg_done        ;
    ADDR_LEN                  : s_axi_rdata = reg_len         ;
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
    assign data_in_loadpix = gen_m0_sdata ;
    fifo_loadpix fifo_loadpix( 
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
    assign data_in_loadpix_w =  gen_m0_sdata ;
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

  assign fifo_rstn_loadpix = reg_start || !axi_rstn;
  assign push_req_loadpix  = gen_m0_svalid & (gen_m0_sresp==0) ;
  assign pop_req_loadpix   = rden_i ;
  assign data_o = data_out_loadpix  ;

  // bs
  `ifdef ALTERA
    fifo_bs fifo_bs(
      .aclr             ( fifo_rstn_bs              ),
      .data             ( bs_dat_i                  ),
      .rdclk            ( axi_clk                   ),
      .rdreq            ( pop_req_bs                ),
      .wrclk            ( enc_clk                   ),
      .wrreq            ( bs_val_i                  ),
      .q                ( data_out_bs               ),
      .rdempty          ( empty_bs                  )
      );   
  `endif
  `ifdef XILINX
    wire [AXI_DW-1          : 0] data_out_bs_w;
    assign data_out_bs = {
                          data_out_bs_w[ 63: 56],data_out_bs_w[ 55: 48],data_out_bs_w[ 47: 40],data_out_bs_w[ 39: 32],data_out_bs_w[ 31: 24],data_out_bs_w[ 23: 16],data_out_bs_w[ 15:  8],data_out_bs_w[  7:  0],
                          data_out_bs_w[127:120],data_out_bs_w[119:112],data_out_bs_w[111:104],data_out_bs_w[103: 96],data_out_bs_w[ 95: 88],data_out_bs_w[ 87: 80],data_out_bs_w[ 79: 72],data_out_bs_w[ 71: 64],
                          data_out_bs_w[191:184],data_out_bs_w[183:176],data_out_bs_w[175:168],data_out_bs_w[167:160],data_out_bs_w[159:152],data_out_bs_w[151:144],data_out_bs_w[143:136],data_out_bs_w[135:128],
                          data_out_bs_w[255:248],data_out_bs_w[247:240],data_out_bs_w[239:232],data_out_bs_w[231:224],data_out_bs_w[223:216],data_out_bs_w[215:208],data_out_bs_w[207:200],data_out_bs_w[199:192],
                          data_out_bs_w[319:312],data_out_bs_w[311:304],data_out_bs_w[303:296],data_out_bs_w[295:288],data_out_bs_w[287:280],data_out_bs_w[279:272],data_out_bs_w[271:264],data_out_bs_w[263:256],
                          data_out_bs_w[383:376],data_out_bs_w[375:368],data_out_bs_w[367:360],data_out_bs_w[359:352],data_out_bs_w[351:344],data_out_bs_w[343:336],data_out_bs_w[335:328],data_out_bs_w[327:320],
                          data_out_bs_w[447:440],data_out_bs_w[439:432],data_out_bs_w[431:424],data_out_bs_w[423:416],data_out_bs_w[415:408],data_out_bs_w[407:400],data_out_bs_w[399:392],data_out_bs_w[391:384],
                          data_out_bs_w[511:504],data_out_bs_w[503:496],data_out_bs_w[495:488],data_out_bs_w[487:480],data_out_bs_w[479:472],data_out_bs_w[471:464],data_out_bs_w[463:456],data_out_bs_w[455:448]
                         };
    fifo_8_512 fifo_bs(
      .rst              ( fifo_rstn_bs              ),
      .wr_clk           ( enc_clk                   ),
      .rd_clk           ( axi_clk                   ),
      .din              ( bs_dat_i                  ),
      .wr_en            ( bs_val_i                  ),
      .rd_en            ( pop_req_bs                ),
      .dout             ( data_out_bs_w             ),
      .empty            ( empty_bs                  )
      );
  `endif

  assign fifo_rstn_bs = reg_start || !axi_rstn ;
  assign pop_req_bs   = gen_m0_mwrite & gen_m0_saccept ;

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
      IDLE :  if ( reg_start )
                nxt_state_0 = WAIT ;
              else                    
                nxt_state_0 = IDLE ;
      WAIT :  if ( addr_offset_0 >= reg_len )
                nxt_state_0 = IDLE ;
              else
                nxt_state_0 = FETCH ;
      FETCH:  if( gen_m0_svalid & (gen_m0_sresp==0) )
                nxt_state_0 = ACK ;
              else                  
                nxt_state_0 = FETCH ;
      ACK  :  if( !empty_loadpix )      
                nxt_state_0 = RUN ;
              else                    
                nxt_state_0 = ACK ;
      RUN  :  if( axi_done )      
                nxt_state_0 = DUMP ;
              else                    
                nxt_state_0 = RUN ;
      DUMP :  if( gen_m0_mwrite & gen_m0_saccept )   
                nxt_state_0 = WAIT ;
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
  assign gen_m0_msize    = AXI_DW == 512 ? 6 : (AXI_DW == 256 ? 5 : 4) ;
  assign gen_m0_mlen     = 0                       ;
  assign gen_m0_mwstrb   = 64'hffff_ffff_ffff_ffff ;
  assign gen_m0_mdata    = data_out_bs             ;

  always @(posedge axi_clk or negedge axi_rstn ) begin
    if( !axi_rstn ) begin
      gen_m0_mread <= 0 ;
    end
    else if( cur_state_0 == WAIT && nxt_state_0 == FETCH ) begin
      gen_m0_mread <= 1 ;
    end
    else if( gen_m0_mread & gen_m0_saccept ) begin
          gen_m0_mread <= 0 ;
    end
  end

  always @(*) begin
                          gen_m0_maddr = 0 ;
    if( cur_state_0==FETCH ) begin
        gen_m0_maddr = reg_ori_base + addr_offset_0 ;
    end
    else begin
      if( cur_state_0==DUMP )
        gen_m0_maddr = reg_bs_base + addr_offset_bs ;
    end
  end

  // assign gen_m0_mread = ( cur_state_0 == FETCH ) ;

  assign gen_m0_mwrite = (cur_state_0 == DUMP) && !empty_bs ;

  always @(posedge axi_clk or negedge axi_rstn ) begin
    if( !axi_rstn ) begin
      addr_offset_0 <= 0 ;
    end
    else if( reg_start ) begin
      addr_offset_0 <= 0 ;
    end
    else if( gen_m0_mread & gen_m0_saccept ) begin
          addr_offset_0 <= addr_offset_0 + (AXI_DW/8)*(gen_m0_mlen+1) ;
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
          addr_offset_bs <= addr_offset_bs + (AXI_DW/8)*(gen_m0_mlen+1);
    end
  end

//*** general ****************************************************************

  // axi_lite
  // to enc_start 
  //--- CDC SYN start ---
  always @(posedge axi_clk or negedge axi_rstn) begin
    if( !axi_rstn )
      reg_start_r <= 0 ;
    else if( cur_state_0 == ACK && nxt_state_0 == RUN )
      reg_start_r <= 1'b1 ;
    else 
      if (reg_start_ack1)
        reg_start_r <= 1'b0 ;
  end

  always @(posedge enc_clk or negedge enc_rstn) begin
    if(!enc_rstn) begin
      reg_start_enc0 <= 0;
      reg_start_enc1 <= 0;
      reg_start_enc2 <= 0;
    end 
    else begin
      reg_start_enc0 <= reg_start_r   ;
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

  assign sys_start_o = reg_start_enc1 & (~reg_start_enc2) ;
  //--- CDC SYN end ---

  // to axi_done 
  //--- CDC SYN start ---
  always @(posedge enc_clk or negedge enc_rstn) begin
    if( !enc_rstn )
      enc_done_r <= 0 ;
    else if( sys_done_i )
      enc_done_r <= 1'b1 ;
    else if ( reg_done_ack1 )
      enc_done_r <= 1'b0 ;
  end

  always @(posedge axi_clk or negedge axi_rstn) begin
    if(!axi_rstn) begin
      reg_done_axi0 <= 0;
      reg_done_axi1 <= 0;
      reg_done_axi2 <= 0;
    end 
    else begin
      reg_done_axi0 <= enc_done_r   ;
      reg_done_axi1 <= reg_done_axi0;
      reg_done_axi2 <= reg_done_axi1;
    end
  end

  always @(posedge enc_clk or negedge enc_rstn) begin
    if(!enc_rstn) begin
      reg_done_ack0 <= 0;
      reg_done_ack1 <= 0;
    end 
    else begin
      reg_done_ack0 <= reg_done_axi1;
      reg_done_ack1 <= reg_done_ack0;
    end
  end

  assign axi_done = reg_done_axi1 & (~reg_done_axi2) ;
  //--- CDC SYN end ---
  
endmodule
