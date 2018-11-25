`include "enc_defines.v"

module reverse_top(
  // global
  clk               ,
  rstn              ,
  // config
  sys_start_i       ,
  sys_done_o        ,
  // ext
  rden_o            ,
  data_i            ,
  // bs
  bs_val_o          ,
  bs_dat_o
  );


  parameter    IDLE                  = 0            ,  
               WAIT                  = 1            ,  
               FETCH                 = 2            ,  
               RUN                   = 3            ;  

  parameter    AXI_DW                = 512          ,
               AXI_AW0               = 64           ,
               AXI_AW1               = 32           ,
               AXI_MIDW              = 1            ,
               AXI_SIDW              = 1            ;


//*** WIRE/REG DECLARATION *****************************************************

  // GLOBAL
  input                                 clk                   ;
  input                                 rstn                  ;

  // CONFIG
  input                                 sys_start_i           ;
  output                                sys_done_o            ;

  // EXT_IF
  output                                rden_o                ;
  input      [16*`PIXEL_WIDTH-1 : 0]    data_i                ;

  // BS
  output                                bs_val_o              ;
  output     [7                 : 0]    bs_dat_o              ;


//*** WIRE/REG DECLARATION *****************************************************

  reg        [1                 : 0]    cur_state_0           ;
  reg        [1                 : 0]    nxt_state_0           ;

  reg        [16*`PIXEL_WIDTH-1 : 0]    cur_data              ; 

  reg        [3                 : 0]    cnt_bs                ; 
  reg        [6                 : 0]    cnt_proc              ;
  wire       [7                 : 0]    bs_dat_w              ; 

  always @(posedge clk or negedge rstn ) begin
    if( !rstn )
      cur_state_0 <= 0 ;
    else begin
      cur_state_0 <= nxt_state_0 ;
    end
  end

  always @(*) begin
    nxt_state_0 = IDLE;
    case( cur_state_0 )
      IDLE :  if ( sys_start_i )
                nxt_state_0 = WAIT ;
              else                    
                nxt_state_0 = IDLE ;
      WAIT :  if ( cnt_proc >= AXI_DW/8 )
                nxt_state_0 = IDLE ;
              else
                nxt_state_0 = FETCH ;
      FETCH:    nxt_state_0 = RUN ;
      RUN  :  if( cnt_bs == 4'd15 )      
                nxt_state_0 = WAIT ;
              else                    
                nxt_state_0 = RUN ;
    endcase
  end

  assign rden_o = (cur_state_0 == FETCH) ;

  always @(posedge clk or negedge rstn ) begin
    if( !rstn ) begin
      cur_data <= 0 ;
    end
    else begin
      if (rden_o)
        cur_data <= data_i ;
      else
        if (bs_val_o)
          cur_data <= (cur_data >> `PIXEL_WIDTH) ;
    end
  end

  assign bs_val_o = cur_state_0 == RUN ;
  assign bs_dat_w = cur_data[`PIXEL_WIDTH-1:0] ;
  assign bs_dat_o = ~bs_dat_w ;

  always @(posedge clk or negedge rstn ) begin
    if( !rstn ) begin
      cnt_bs <= 0 ;
    end
    else begin
      if (bs_val_o)
        cnt_bs <= cnt_bs + 1 ;
    end
  end

  always @(posedge clk or negedge rstn ) begin
    if( !rstn ) begin
      cnt_proc <= 0 ;
    end
    else begin
      if ( sys_start_i )
        cnt_proc <= 0;
      else
        if ( bs_val_o )
          cnt_proc <= cnt_proc + 1 ;
    end
  end

  assign sys_done_o = (cur_state_0 == WAIT) && (nxt_state_0 == IDLE) ;

endmodule
