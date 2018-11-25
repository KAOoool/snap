`include "enc_defines.v"

module reverse_sdram(
  // axi_clk & rst
  axi_clk   ,
  axi_rstn  ,
  enc_clk   ,
  enc_rstn                         
  );

  parameter    AXI_DW               = 512       ,
               AXI_AW               = 64        ,
               AXI_MIDW             = 4         ,
               AXI_SIDW             = 8         ;

  parameter    AXI_WID              = 0         ,
               AXI_RID              = 0         ;

  // axi_clk & rst
  input                     axi_clk             ;
  input                     axi_rstn            ;
  input                     enc_clk             ;
  input                     enc_rstn            ;

  // apb_s
  wire   [31        : 0]    apb_s_prdata        ; 
  wire   [31        : 0]    apb_s_paddr         ; 
  wire                      apb_s_penable       ; 
  wire                      apb_s_psel          ; 
  wire   [31        : 0]    apb_s_pwdata        ; 
  wire                      apb_s_pwrite        ; 

  // gen_m
  wire  [AXI_AW-1   : 0]    gen_m0_maddr        ; 
  wire  [1          : 0]    gen_m0_mburst       ; 
  wire  [3          : 0]    gen_m0_mcache       ; 
  wire  [AXI_DW-1   : 0]    gen_m0_mdata        ; 
  wire  [AXI_MIDW-1 : 0]    gen_m0_mid          ; 
  wire  [3          : 0]    gen_m0_mlen         ; 
  wire                      gen_m0_mlock        ; 
  wire  [2          : 0]    gen_m0_mprot        ; 
  wire                      gen_m0_mread        ; 
  wire                      gen_m0_mready       ; 
  wire  [2          : 0]    gen_m0_msize        ; 
  wire                      gen_m0_mwrite       ; 
  wire  [AXI_DW/8-1 : 0]    gen_m0_mwstrb       ; 
  wire                      gen_m0_saccept      ; 
  wire  [AXI_DW-1   : 0]    gen_m0_sdata        ; 
  wire  [AXI_MIDW-1 : 0]    gen_m0_sid          ; 
  wire                      gen_m0_slast        ; 
  wire  [2          : 0]    gen_m0_sresp        ; 
  wire                      gen_m0_svalid       ; 

  // sdram
  wire                      sdram_clk           ;
  wire   [12       : 0]     sdram_addr          ;
  wire   [31       : 0]     sdram_dq            ;
  wire   [1        : 0]     sdram_bank_addr     ;
  wire   [3        : 0]     sdram_dqm           ;
  wire                      sdram_ras_n         ;
  wire                      sdram_cas_n         ;
  wire                      sdram_cke           ;
  wire                      sdram_we_n          ;
  wire                      sdram_sel_n         ;
  wire   [3        : 0]     sdram_dout_valid    ;
  wire   [31       : 0]     sdram_rd_data       ;
  wire   [31       : 0]     sdram_wr_data       ;
 

  reverse_top_with_gm reverse_top_with_gm (
    // global  
    .axi_clk                  ( axi_clk           ), 
    .axi_rstn                 ( axi_rstn          ),
    .enc_clk                  ( enc_clk           ), 
    .enc_rstn                 ( enc_rstn          ),
    // apb_s       
    .apb_s_prdata             ( apb_s_prdata      ),
    .apb_s_paddr              ( apb_s_paddr       ),
    .apb_s_penable            ( apb_s_penable     ),
    .apb_s_psel               ( apb_s_psel        ),
    .apb_s_pwdata             ( apb_s_pwdata      ),
    .apb_s_pwrite             ( apb_s_pwrite      ),
    // axi_m0       
    .gen_m0_maddr             ( gen_m0_maddr      ),
    .gen_m0_mburst            ( gen_m0_mburst     ),
    .gen_m0_mcache            ( gen_m0_mcache     ),
    .gen_m0_mdata             ( gen_m0_mdata      ),
    .gen_m0_mid               ( gen_m0_mid        ),
    .gen_m0_mlen              ( gen_m0_mlen       ),
    .gen_m0_mlock             ( gen_m0_mlock      ),
    .gen_m0_mprot             ( gen_m0_mprot      ),
    .gen_m0_mread             ( gen_m0_mread      ),
    .gen_m0_mready            ( gen_m0_mready     ),
    .gen_m0_msize             ( gen_m0_msize      ),
    .gen_m0_mwrite            ( gen_m0_mwrite     ),
    .gen_m0_mwstrb            ( gen_m0_mwstrb     ),
    .gen_m0_saccept           ( gen_m0_saccept    ),
    .gen_m0_sdata             ( gen_m0_sdata      ),
    .gen_m0_sid               ( gen_m0_sid        ),
    .gen_m0_slast             ( gen_m0_slast      ),
    .gen_m0_sresp             ( gen_m0_sresp      ),
    .gen_m0_svalid            ( gen_m0_svalid     )     
  ); 

  axi axi (
      // axi_clk & axi_rstn
      .ACLK_aclk              ( axi_clk           ),
      .ARESETn_aresetn        ( axi_rstn          ),
      .HCLK_hclk              ( axi_clk           ),
      .HRESETn_hresetn        ( axi_rstn          ),
      .PCLK_pclk              ( axi_clk           ),
      .PRESETn_presetn        ( axi_rstn          ),
      // remap
      .i_axi_remap_n          ( 1'b1              ),
      // axi_clk enable
      .gm_0_gclken            ( 1'b1              ),
      .gm_1_gclken            ( 1'b1              ),
      .gm_2_gclken            ( 1'b1              ),
      // apb slave
      .apb_s_0_prdata         (                   ),
      .apb_s_0_paddr          (                   ),
      .apb_s_0_penable        (                   ),
      .apb_s_0_psel           (                   ),
      .apb_s_0_pwdata         (                   ),
      .apb_s_0_pwrite         (                   ),
      // apb slave                                
      .apb_s_1_prdata         (                   ),
      .apb_s_1_paddr          (                   ),
      .apb_s_1_penable        (                   ),
      .apb_s_1_psel           (                   ),
      .apb_s_1_pwdata         (                   ),
      .apb_s_1_pwrite         (                   ),
      // apb slave                                
      .apb_s_2_prdata         (                   ),
      .apb_s_2_paddr          (                   ),
      .apb_s_2_penable        (                   ),
      .apb_s_2_psel           (                   ),
      .apb_s_2_pwdata         (                   ),
      .apb_s_2_pwrite         (                   ),
      // gen master                               
      .gen_m_0_maddr          ( gen_m0_maddr      ),
      .gen_m_0_mburst         ( gen_m0_mburst     ),
      .gen_m_0_mcache         ( gen_m0_mcache     ),
      .gen_m_0_mdata          ( gen_m0_mdata      ),
      .gen_m_0_mlen           ( gen_m0_mlen       ),
      .gen_m_0_mid            ( gen_m0_mid        ),
      .gen_m_0_mlock          ( gen_m0_mlock      ),
      .gen_m_0_mprot          ( gen_m0_mprot      ),
      .gen_m_0_mread          ( gen_m0_mread      ),
      .gen_m_0_mready         ( gen_m0_mready     ),
      .gen_m_0_msize          ( gen_m0_msize      ),
      .gen_m_0_mwrite         ( gen_m0_mwrite     ),
      .gen_m_0_mwstrb         ( gen_m0_mwstrb     ),
      .gen_m_0_saccept        ( gen_m0_saccept    ),
      .gen_m_0_sdata          ( gen_m0_sdata      ),
      .gen_m_0_sid            ( gen_m0_sid        ),
      .gen_m_0_slast          ( gen_m0_slast      ),
      .gen_m_0_sresp          ( gen_m0_sresp      ),
      .gen_m_0_svalid         ( gen_m0_svalid     ),
      // gen master
      .gen_m_1_maddr          (                   ),
      .gen_m_1_mburst         (                   ),
      .gen_m_1_mcache         (                   ),
      .gen_m_1_mdata          (                   ),
      .gen_m_1_mid            (                   ),
      .gen_m_1_mlen           (                   ),
      .gen_m_1_mlock          (                   ),
      .gen_m_1_mprot          (                   ),
      .gen_m_1_mread          (                   ),
      .gen_m_1_mready         (                   ),
      .gen_m_1_msize          (                   ),
      .gen_m_1_mwrite         (                   ),
      .gen_m_1_mwstrb         (                   ),
      .gen_m_1_saccept        (                   ),
      .gen_m_1_sdata          (                   ),
      .gen_m_1_sid            (                   ),
      .gen_m_1_slast          (                   ),
      .gen_m_1_sresp          (                   ),
      .gen_m_1_svalid         (                   ),
      // gen master
      .gen_m_2_maddr          (                   ),
      .gen_m_2_mburst         (                   ),
      .gen_m_2_mcache         (                   ),
      .gen_m_2_mdata          (                   ),
      .gen_m_2_mid            (                   ),
      .gen_m_2_mlen           (                   ),
      .gen_m_2_mlock          (                   ),
      .gen_m_2_mprot          (                   ),
      .gen_m_2_mread          (                   ),
      .gen_m_2_mready         (                   ),
      .gen_m_2_msize          (                   ),
      .gen_m_2_mwrite         (                   ),
      .gen_m_2_mwstrb         (                   ),
      .gen_m_2_saccept        (                   ),
      .gen_m_2_sdata          (                   ),
      .gen_m_2_sid            (                   ),
      .gen_m_2_slast          (                   ),
      .gen_m_2_sresp          (                   ),
      .gen_m_2_svalid         (                   ),
      // sdram ports from memctl
      .i_memctl_clear_sr_dp   ( 1'b0              ),
      .i_memctl_gpi           ( 8'b0              ),
      .i_memctl_power_down    ( 1'b0              ),
      .i_memctl_remap         ( 1'b0              ),
      .i_memctl_s_rd_data     ( sdram_rd_data     ),
      .i_memctl_s_rd_ready    ( 1'b0              ),
      .i_memctl_s_sda_in      ( 1'b0              ),
      .i_memctl_s_cas_n       ( sdram_cas_n       ),
      .i_memctl_s_cke         ( sdram_cke         ),
      .i_memctl_s_dout_valid  ( sdram_dout_valid  ),
      .i_memctl_s_dqm         ( sdram_dqm         ),
      .i_memctl_s_ras_n       ( sdram_ras_n       ),
      .i_memctl_s_addr        ( sdram_addr        ),
      .i_memctl_s_bank_addr   ( sdram_bank_addr   ),
      .i_memctl_s_sel_n       ( sdram_sel_n       ),
      .i_memctl_s_we_n        ( sdram_we_n        ),
      .i_memctl_s_wr_data     ( sdram_wr_data     )
  );

    assign sdram_dq[31:24] = sdram_dout_valid[3] ? sdram_wr_data[31:24] : 8'hzz ;
    assign sdram_dq[23:16] = sdram_dout_valid[2] ? sdram_wr_data[23:16] : 8'hzz ;
    assign sdram_dq[15:08] = sdram_dout_valid[1] ? sdram_wr_data[15:08] : 8'hzz ;
    assign sdram_dq[07:00] = sdram_dout_valid[0] ? sdram_wr_data[07:00] : 8'hzz ;
    assign sdram_rd_data   = sdram_dq                                           ;
    assign sdram_clk       = axi_clk                                            ; 

      // sdram_model
    mt48lc4m16a2 #(
        .mem_sizes              ( 32*1024*1024      ),    // 64 MB for each chip
        .DEBUG                  ( 0                 )    
        ) u_mt48lc4m16a2a(    
        .Dq                     ( sdram_dq[15:0]    ),
        .Addr                   ( sdram_addr        ),
        .Ba                     ( sdram_bank_addr   ),
        .Clk                    ( sdram_clk         ),
        .Cke                    ( sdram_cke         ),
        .Cs_n                   ( sdram_sel_n       ),
        .Ras_n                  ( sdram_ras_n       ),
        .Cas_n                  ( sdram_cas_n       ),
        .We_n                   ( sdram_we_n        ),
        .Dqm                    ( sdram_dqm[1:0]    )
    );

    mt48lc4m16a2 #(
        .mem_sizes              ( 32*1024*1024      ),
        .DEBUG                  ( 0                 )
        ) u_mt48lc4m16a2b(    
        .Dq                     ( sdram_dq[31:16]   ),
        .Addr                   ( sdram_addr        ),
        .Ba                     ( sdram_bank_addr   ),
        .Clk                    ( sdram_clk         ),
        .Cke                    ( sdram_cke         ),
        .Cs_n                   ( sdram_sel_n       ),
        .Ras_n                  ( sdram_ras_n       ),
        .Cas_n                  ( sdram_cas_n       ),
        .We_n                   ( sdram_we_n        ),
        .Dqm                    ( sdram_dqm[3:2]    )
    );

endmodule
