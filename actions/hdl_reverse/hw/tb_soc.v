//*** INCLUDE   ***************************************************************
`include "enc_defines.v"

//*** DIFINE    ***************************************************************

  // waveform
  `define DUMP_FSDB
          `define DUMP_TIME    0 
          `define DUMP_FILE    "tb_soc.fsdb"
  
   //`define DUMP_SHM
           `define DUMP_SHM_FILE     "./dump/wave_form.shm"
           `define DUMP_SHM_TIME     0
           `define DUMP_SHM_LEVEL    "AS"    // all signal

  `define BYTES_NUM 2048 

//*** MAIN BODY ***************************************************************

module tb_soc;


  integer               ext_ori_fp        ;
  integer               ext_ori_tp        ;
  integer               ext_ori_i         ;
  reg       [7 : 0]     ext_temp_yuv      ;

  integer               ext_bs_save_fp    ;
  integer               ext_bs_save_i     ;
  reg       [7 : 0]     ext_bs_save       ;

  reg axi_clk  ;
  reg axi_rstn ;
  reg enc_clk  ;
  reg enc_rstn ; 

  parameter FETCH_CUR_FILE = "./tv/BlowingBubbles_nv12.yuv"    ;
  parameter FETCH_REV_FILE = "./tv/BlowingBubbles_reverse.yuv"    ;

  reverse_sdram reverse_sdram(
    .axi_clk      ( axi_clk     ),
    .axi_rstn     ( axi_rstn    ),
    .enc_clk      ( enc_clk     ),
    .enc_rstn     ( enc_rstn    )
    );

  // clk
  initial begin
    enc_clk = 1'b1;
    forever #10 enc_clk = ~enc_clk;
  end

  initial begin
    axi_clk = 1'b1;
    forever #6 axi_clk = ~axi_clk;
  end

 initial begin
    axi_rstn      = 0 ;
    enc_rstn      = 0 ;
    #100 ;
    axi_rstn      = 1 ;
    enc_rstn      = 1 ;

    $display( "\n\n*** CHECK REVERSE_SDRAM ! ***\n" );

    ext_ori_fp     = $fopen( FETCH_CUR_FILE , "rb" );
    ext_bs_save_fp = $fopen( FETCH_REV_FILE , "w" );

    reverse_sdram.reverse_top_with_gm.reverse_if.reg_ori_base_low  = 0 ;
    reverse_sdram.reverse_top_with_gm.reverse_if.reg_ori_base_high = 0 ;

    reverse_sdram.reverse_top_with_gm.reverse_if.reg_bs_base_low   = `BYTES_NUM ;
    reverse_sdram.reverse_top_with_gm.reverse_if.reg_bs_base_high  = 0    ;

    reverse_sdram.reverse_top_with_gm.reverse_if.reg_len           = `BYTES_NUM ;

    // init mem with 0
    for( ext_ori_i=0 ;ext_ori_i<reverse_sdram.reverse_top_with_gm.reverse_if.reg_len ;ext_ori_i=ext_ori_i+1 ) begin
      ext_ori_tp = $fread( ext_temp_yuv ,ext_ori_fp );
      case(ext_ori_i[1:0])
        0: reverse_sdram.u_mt48lc4m16a2a.Bank0[ext_ori_i/4][07:00] = ext_temp_yuv ;
        1: reverse_sdram.u_mt48lc4m16a2a.Bank0[ext_ori_i/4][15:08] = ext_temp_yuv ;
        2: reverse_sdram.u_mt48lc4m16a2b.Bank0[ext_ori_i/4][07:00] = ext_temp_yuv ;
        3: reverse_sdram.u_mt48lc4m16a2b.Bank0[ext_ori_i/4][15:08] = ext_temp_yuv ;
      endcase
    end

    #1000 ;

    @(negedge axi_clk);
    reverse_sdram.reverse_top_with_gm.reverse_if.reg_start = 1 ;
    #1 ;
    @(negedge axi_clk);
    reverse_sdram.reverse_top_with_gm.reverse_if.reg_start = 0 ;

    wait(reverse_sdram.reverse_top_with_gm.reverse_if.reg_done == 0) ;
    wait(reverse_sdram.reverse_top_with_gm.reverse_if.reg_done == 1) ;

    // dump
    for( ext_bs_save_i = reverse_sdram.reverse_top_with_gm.reverse_if.reg_bs_base ; 
         ext_bs_save_i < reverse_sdram.reverse_top_with_gm.reverse_if.reg_bs_base + `BYTES_NUM ; 
         ext_bs_save_i = ext_bs_save_i + 1 ) begin
          case( ext_bs_save_i[1:0] )
            0: ext_bs_save = reverse_sdram.u_mt48lc4m16a2a.Bank0[ext_bs_save_i/4][07:00] ;
            1: ext_bs_save = reverse_sdram.u_mt48lc4m16a2a.Bank0[ext_bs_save_i/4][15:08] ;
            2: ext_bs_save = reverse_sdram.u_mt48lc4m16a2b.Bank0[ext_bs_save_i/4][07:00] ;
            3: ext_bs_save = reverse_sdram.u_mt48lc4m16a2b.Bank0[ext_bs_save_i/4][15:08] ;
          endcase
          $fwrite(ext_bs_save_fp,"%h\n",ext_bs_save);
    end

    #1000 ;
    $display( "\n\n*** at %08d, CHECK FNISHED ! ***\n" ,$time );
    #1000 ;
    $finish ;
  end


//*** DUMP FSDB ***************************************************************

  `ifdef DUMP_FSDB

    initial begin
      #`DUMP_TIME ;
      $fsdbDumpfile( `DUMP_FILE );
      $fsdbDumpvars( tb_soc );
      #100 ;
      $display( "\t\t dump (fsdb) to this test is on !\n" );
    end

  `endif

  `ifdef DUMP_SHM

    initial begin
      #`DUMP_SHM_TIME ;
      $shm_open( `DUMP_SHM_FILE );
      $shm_probe( tb_soc ,`DUMP_SHM_LEVEL );
      #100 ;
      $display( "\t\t dump (shm) to this test is on !\n" );
    end

  `endif

endmodule
