////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////
//
// Copyright 2016,2017 International Business Machines
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions AND
// limitations under the License.
//
////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////

`timescale 1ns/1ps

module action_wrapper #(
    // Parameters of Axi Master Bus Interface AXI_CARD_MEM0 ; to DDR memory
    parameter C_M_AXI_CARD_MEM0_ID_WIDTH     = 4,
    parameter C_M_AXI_CARD_MEM0_ADDR_WIDTH   = 33,
    parameter C_M_AXI_CARD_MEM0_DATA_WIDTH   = 512,
    parameter C_M_AXI_CARD_MEM0_AWUSER_WIDTH = 1,
    parameter C_M_AXI_CARD_MEM0_ARUSER_WIDTH = 1,
    parameter C_M_AXI_CARD_MEM0_WUSER_WIDTH  = 1,
    parameter C_M_AXI_CARD_MEM0_RUSER_WIDTH  = 1,
    parameter C_M_AXI_CARD_MEM0_BUSER_WIDTH  = 1,

    // Parameters of Axi Slave Bus Interface AXI_CTRL_REG
    parameter C_S_AXI_CTRL_REG_DATA_WIDTH    = 32,
    parameter C_S_AXI_CTRL_REG_ADDR_WIDTH    = 32,

    // Parameters of Axi Master Bus Interface AXI_HOST_MEM ; to Host memory
    parameter C_M_AXI_HOST_MEM_ID_WIDTH      = 1,
    parameter C_M_AXI_HOST_MEM_ADDR_WIDTH    = 64,
    parameter C_M_AXI_HOST_MEM_DATA_WIDTH    = 512,
    parameter C_M_AXI_HOST_MEM_AWUSER_WIDTH  = 8,
    parameter C_M_AXI_HOST_MEM_ARUSER_WIDTH  = 8,
    parameter C_M_AXI_HOST_MEM_WUSER_WIDTH   = 1,
    parameter C_M_AXI_HOST_MEM_RUSER_WIDTH   = 1,
    parameter C_M_AXI_HOST_MEM_BUSER_WIDTH   = 1,
    parameter INT_BITS                       = 3,
    parameter CONTEXT_BITS                   = 8,

    parameter INPUT_PACKET_STAT_WIDTH        = 48,
    parameter INPUT_BATCH_WIDTH              = 512,
    parameter INPUT_BATCH_PER_PACKET         = 1,
    //parameter CONFIG_CNT_WIDTH               = 3, // CONFIG_CNT_WIDTH = log2NUM_OF_PU;
    parameter OUTPUT_STAT_WIDTH              = 80,
    //parameter PATTERN_WIDTH                  = 448, 
    parameter PATTERN_ID_WIDTH               = 32,
    parameter MAX_OR_NUM                     = 8,
    parameter MAX_TOKEN_NUM                  = 8,//16,
    parameter MAX_STATE_NUM                  = 8,//16,
    parameter MAX_TOKEN_LEN                  = 8,//16,
    parameter MAX_CHAR_NUM                   = 8,//32,
    parameter PATTERN_NUM_FL                 = 2,
    parameter PATTERN_NUM_SL                 = 4,
    parameter NUM_OF_PU                      = 8,
    parameter NUM_BUFFER_SL                  = 2,
    parameter NUM_BUFFER_TL                  = 2,
    parameter NUM_BUFFER_4THL                = 2,
    parameter NUM_STRING_MATCH_PIPELINE      = 8,
    parameter NUM_PIPELINE_IN_A_GROUP        = 1,
    parameter NUM_OF_PIPELINE_GROUP          = 8 
)
(
    input  ap_clk                    ,
    input  clk_125MHz                    ,
    input  ap_rst_n                  ,
    output interrupt                 ,
    output [INT_BITS-2 : 0] interrupt_src             ,
    output [CONTEXT_BITS-1 : 0] interrupt_ctx             ,
    input  interrupt_ack             ,
    //                                                                                                 
    // AXI SDRAM Interface                                                                             
    output [C_M_AXI_CARD_MEM0_ADDR_WIDTH-1 : 0 ] m_axi_card_mem0_araddr    ,     
    output [1 : 0 ] m_axi_card_mem0_arburst   ,                                  
    output [3 : 0 ] m_axi_card_mem0_arcache   ,                                  
    output [C_M_AXI_CARD_MEM0_ID_WIDTH-1 : 0 ] m_axi_card_mem0_arid      ,       
    output [7 : 0 ] m_axi_card_mem0_arlen     ,                                  
    output [1 : 0 ] m_axi_card_mem0_arlock    ,                                  
    output [2 : 0 ] m_axi_card_mem0_arprot    ,                                  
    output [3 : 0 ] m_axi_card_mem0_arqos     ,                                  
    input  m_axi_card_mem0_arready   ,                                                        
    output [3 : 0 ] m_axi_card_mem0_arregion  ,                                  
    output [2 : 0 ] m_axi_card_mem0_arsize    ,                                  
    output [C_M_AXI_CARD_MEM0_ARUSER_WIDTH-1 : 0 ] m_axi_card_mem0_aruser    ,   
    output m_axi_card_mem0_arvalid   ,                                                        
    output [C_M_AXI_CARD_MEM0_ADDR_WIDTH-1 : 0 ] m_axi_card_mem0_awaddr    ,     
    output [1 : 0 ] m_axi_card_mem0_awburst   ,                                  
    output [3 : 0 ] m_axi_card_mem0_awcache   ,                                  
    output [C_M_AXI_CARD_MEM0_ID_WIDTH-1 : 0 ] m_axi_card_mem0_awid      ,       
    output [7 : 0 ] m_axi_card_mem0_awlen     ,                                  
    output [1 : 0 ] m_axi_card_mem0_awlock    ,                                  
    output [2 : 0 ] m_axi_card_mem0_awprot    ,                                  
    output [3 : 0 ] m_axi_card_mem0_awqos     ,                                  
    input  m_axi_card_mem0_awready   ,                                                        
    output [3 : 0 ] m_axi_card_mem0_awregion  ,                                  
    output [2 : 0 ] m_axi_card_mem0_awsize    ,                                  
    output [C_M_AXI_CARD_MEM0_AWUSER_WIDTH-1 : 0 ] m_axi_card_mem0_awuser    ,   
    output m_axi_card_mem0_awvalid   ,                                                        
    input  [C_M_AXI_CARD_MEM0_ID_WIDTH-1 : 0 ] m_axi_card_mem0_bid       ,       
    output m_axi_card_mem0_bready    ,                                                        
    input  [1 : 0 ] m_axi_card_mem0_bresp     ,                                  
    input  [C_M_AXI_CARD_MEM0_BUSER_WIDTH-1 : 0 ] m_axi_card_mem0_buser     ,    
    input  m_axi_card_mem0_bvalid    ,                                                        
    input  [C_M_AXI_CARD_MEM0_DATA_WIDTH-1 : 0 ] m_axi_card_mem0_rdata     ,     
    input  [C_M_AXI_CARD_MEM0_ID_WIDTH-1 : 0 ] m_axi_card_mem0_rid       ,       
    input  m_axi_card_mem0_rlast     ,                                                        
    output m_axi_card_mem0_rready    ,                                                        
    input  [1 : 0 ] m_axi_card_mem0_rresp     ,                                  
    input  [C_M_AXI_CARD_MEM0_RUSER_WIDTH-1 : 0 ] m_axi_card_mem0_ruser     ,    
    input  m_axi_card_mem0_rvalid    ,                                                        
    output [C_M_AXI_CARD_MEM0_DATA_WIDTH-1 : 0 ] m_axi_card_mem0_wdata     ,     
    output m_axi_card_mem0_wlast     ,                                                        
    input  m_axi_card_mem0_wready    ,                                                        
    output [(C_M_AXI_CARD_MEM0_DATA_WIDTH/8)-1 : 0 ] m_axi_card_mem0_wstrb     , 
    output [C_M_AXI_CARD_MEM0_WUSER_WIDTH-1 : 0 ] m_axi_card_mem0_wuser     ,    
    output m_axi_card_mem0_wvalid    ,                                                        
 
    //
    // AXI Control Register Interface
    input  [C_S_AXI_CTRL_REG_ADDR_WIDTH-1 : 0 ] s_axi_ctrl_reg_araddr     ,
    output s_axi_ctrl_reg_arready    ,
    input  s_axi_ctrl_reg_arvalid    ,
    input  [C_S_AXI_CTRL_REG_ADDR_WIDTH-1 : 0 ] s_axi_ctrl_reg_awaddr     ,
    output s_axi_ctrl_reg_awready    ,
    input  s_axi_ctrl_reg_awvalid    ,
    input  s_axi_ctrl_reg_bready     ,
    output [1 : 0 ] s_axi_ctrl_reg_bresp      ,
    output s_axi_ctrl_reg_bvalid     ,
    output [C_S_AXI_CTRL_REG_DATA_WIDTH-1 : 0 ] s_axi_ctrl_reg_rdata      ,
    input  s_axi_ctrl_reg_rready     ,
    output [1 : 0 ] s_axi_ctrl_reg_rresp      ,
    output s_axi_ctrl_reg_rvalid     ,
    input  [C_S_AXI_CTRL_REG_DATA_WIDTH-1 : 0 ] s_axi_ctrl_reg_wdata      ,
    output s_axi_ctrl_reg_wready     ,
    input  [(C_S_AXI_CTRL_REG_DATA_WIDTH/8)-1 : 0 ] s_axi_ctrl_reg_wstrb      ,
    input  s_axi_ctrl_reg_wvalid     ,
    //
    // AXI Host Memory Interface
    output [C_M_AXI_HOST_MEM_ADDR_WIDTH-1 : 0 ] m_axi_host_mem_araddr     ,
    output [1 : 0 ] m_axi_host_mem_arburst    ,
    output [3 : 0 ] m_axi_host_mem_arcache    ,
    output [C_M_AXI_HOST_MEM_ID_WIDTH-1 : 0 ] m_axi_host_mem_arid       ,
    output [7 : 0 ] m_axi_host_mem_arlen      ,
    output [1 : 0 ] m_axi_host_mem_arlock     ,
    output [2 : 0 ] m_axi_host_mem_arprot     ,
    output [3 : 0 ] m_axi_host_mem_arqos      ,
    input  m_axi_host_mem_arready    ,
    output [3 : 0 ] m_axi_host_mem_arregion   ,
    output [2 : 0 ] m_axi_host_mem_arsize     ,
    output [C_M_AXI_HOST_MEM_ARUSER_WIDTH-1 : 0 ] m_axi_host_mem_aruser     ,
    output m_axi_host_mem_arvalid    ,
    output [C_M_AXI_HOST_MEM_ADDR_WIDTH-1 : 0 ] m_axi_host_mem_awaddr     ,
    output [1 : 0 ] m_axi_host_mem_awburst    ,
    output [3 : 0 ] m_axi_host_mem_awcache    ,
    output [C_M_AXI_HOST_MEM_ID_WIDTH-1 : 0 ] m_axi_host_mem_awid       ,
    output [7 : 0 ] m_axi_host_mem_awlen      ,
    output [1 : 0 ] m_axi_host_mem_awlock     ,
    output [2 : 0 ] m_axi_host_mem_awprot     ,
    output [3 : 0 ] m_axi_host_mem_awqos      ,
    input  m_axi_host_mem_awready    ,
    output [3 : 0 ] m_axi_host_mem_awregion   ,
    output [2 : 0 ] m_axi_host_mem_awsize     ,
    output [C_M_AXI_HOST_MEM_AWUSER_WIDTH-1 : 0 ] m_axi_host_mem_awuser     ,
    output m_axi_host_mem_awvalid    ,
    input  [C_M_AXI_HOST_MEM_ID_WIDTH-1 : 0 ] m_axi_host_mem_bid        ,
    output m_axi_host_mem_bready     ,
    input  [1 : 0 ] m_axi_host_mem_bresp      ,
    input  [C_M_AXI_HOST_MEM_BUSER_WIDTH-1 : 0 ] m_axi_host_mem_buser      ,
    input  m_axi_host_mem_bvalid     ,
    input  [C_M_AXI_HOST_MEM_DATA_WIDTH-1 : 0 ] m_axi_host_mem_rdata      ,
    input  [C_M_AXI_HOST_MEM_ID_WIDTH-1 : 0 ] m_axi_host_mem_rid        ,
    input  m_axi_host_mem_rlast      ,
    output m_axi_host_mem_rready     ,
    input  [1 : 0 ] m_axi_host_mem_rresp      ,
    input  [C_M_AXI_HOST_MEM_RUSER_WIDTH-1 : 0 ] m_axi_host_mem_ruser      ,
    input  m_axi_host_mem_rvalid     ,
    output [C_M_AXI_HOST_MEM_DATA_WIDTH-1 : 0 ] m_axi_host_mem_wdata      ,
    output m_axi_host_mem_wlast      ,
    input  m_axi_host_mem_wready     ,
    output [(C_M_AXI_HOST_MEM_DATA_WIDTH/8)-1 : 0 ] m_axi_host_mem_wstrb      ,
    output [C_M_AXI_HOST_MEM_WUSER_WIDTH-1 : 0 ] m_axi_host_mem_wuser      ,
    output m_axi_host_mem_wvalid
);

    // Make wuser stick to 0
    assign m_axi_card_mem0_wuser = 0;
    assign m_axi_card_mem0_aruser = 0;
    assign m_axi_card_mem0_arqos = 0;
    assign m_axi_card_mem0_arregion = 0;
    assign m_axi_card_mem0_awuser = 0;
    assign m_axi_card_mem0_awqos = 0;
    assign m_axi_card_mem0_awregion = 0;
    assign m_axi_host_mem_wuser = 0;
    assign m_axi_host_mem_aruser = 0;
    assign m_axi_host_mem_arqos = 0;
    assign m_axi_host_mem_arregion = 0;
    assign m_axi_host_mem_awuser = 0;
    assign m_axi_host_mem_awqos = 0;
    assign m_axi_host_mem_awregion = 0;

    h265enc_top_with_axi h265enc_top_with_axi_0 (
        .axi_clk            (ap_clk),
        .axi_rstn           (ap_rst_n),
		.enc_clk            (clk_125MHz),
        .enc_rstn           (ap_rst_n),
    
        //---- AXI bus interfaced with SNAP core ----               
        // AXI write address channel      
        .axi_m0_awid        (m_axi_host_mem_awid),  
        .axi_m0_awaddr      (m_axi_host_mem_awaddr),  
        .axi_m0_awlen       (m_axi_host_mem_awlen),  
        .axi_m0_awsize      (m_axi_host_mem_awsize),  
        .axi_m0_awburst     (m_axi_host_mem_awburst),  
        .axi_m0_awcache     (m_axi_host_mem_awcache),  
        .axi_m0_awlock      (m_axi_host_mem_awlock),  
        .axi_m0_awprot      (m_axi_host_mem_awprot),  
        .axi_m0_awvalid     (m_axi_host_mem_awvalid),  
        .axi_m0_awready     (m_axi_host_mem_awready),
        // AXI write data channel         
        .axi_m0_wdata       (m_axi_host_mem_wdata),  
        .axi_m0_wstrb       (m_axi_host_mem_wstrb),  
        .axi_m0_wlast       (m_axi_host_mem_wlast),  
        .axi_m0_wvalid      (m_axi_host_mem_wvalid),  
        .axi_m0_wready      (m_axi_host_mem_wready),
        // AXI write response channel     
        .axi_m0_bready      (m_axi_host_mem_bready),  
        .axi_m0_bid         (m_axi_host_mem_bid),
        .axi_m0_bresp       (m_axi_host_mem_bresp),
        .axi_m0_bvalid      (m_axi_host_mem_bvalid),
        // AXI read address channel       
        .axi_m0_arid        (m_axi_host_mem_arid),  
        .axi_m0_araddr      (m_axi_host_mem_araddr),  
        .axi_m0_arlen       (m_axi_host_mem_arlen),  
        .axi_m0_arsize      (m_axi_host_mem_arsize),  
        .axi_m0_arburst     (m_axi_host_mem_arburst),  
        .axi_m0_arcache     (m_axi_host_mem_arcache), 
        .axi_m0_arlock      (m_axi_host_mem_arlock),  
        .axi_m0_arprot      (m_axi_host_mem_arprot), 
        .axi_m0_arvalid     (m_axi_host_mem_arvalid), 
        .axi_m0_arready     (m_axi_host_mem_arready),
        // AXI  ead data channel          
        .axi_m0_rready      (m_axi_host_mem_rready), 
        .axi_m0_rid         (m_axi_host_mem_rid),
        .axi_m0_rdata       (m_axi_host_mem_rdata),
        .axi_m0_rresp       (m_axi_host_mem_rresp),
        .axi_m0_rlast       (m_axi_host_mem_rlast),
        .axi_m0_rvalid      (m_axi_host_mem_rvalid),
    
        //---- AXI bus interfaced with DDR ----               
        // AXI write address channel      
        .axi_m1_awid        (m_axi_card_mem0_awid),  
        .axi_m1_awaddr      (m_axi_card_mem0_awaddr),  
        .axi_m1_awlen       (m_axi_card_mem0_awlen),  
        .axi_m1_awsize      (m_axi_card_mem0_awsize),  
        .axi_m1_awburst     (m_axi_card_mem0_awburst),  
        .axi_m1_awcache     (m_axi_card_mem0_awcache),  
        .axi_m1_awlock      (m_axi_card_mem0_awlock),  
        .axi_m1_awprot      (m_axi_card_mem0_awprot),  
        .axi_m1_awvalid     (m_axi_card_mem0_awvalid),  
        .axi_m1_awready     (m_axi_card_mem0_awready),
        // AXI write data channel         
        //.axi_m1_wid         (0), 
        .axi_m1_wdata       (m_axi_card_mem0_wdata),  
        .axi_m1_wstrb       (m_axi_card_mem0_wstrb),  
        .axi_m1_wlast       (m_axi_card_mem0_wlast),  
        .axi_m1_wvalid      (m_axi_card_mem0_wvalid),  
        .axi_m1_wready      (m_axi_card_mem0_wready),
        // AXI write response channel     
        .axi_m1_bready      (m_axi_card_mem0_bready),  
        .axi_m1_bid         (m_axi_card_mem0_bid),
        .axi_m1_bresp       (m_axi_card_mem0_bresp),
        .axi_m1_bvalid      (m_axi_card_mem0_bvalid),
        // AXI read address channel       
        .axi_m1_arid        (m_axi_card_mem0_arid),  
        .axi_m1_araddr      (m_axi_card_mem0_araddr),  
        .axi_m1_arlen       (m_axi_card_mem0_arlen),  
        .axi_m1_arsize      (m_axi_card_mem0_arsize),  
        .axi_m1_arburst     (m_axi_card_mem0_arburst),  
        .axi_m1_arcache     (m_axi_card_mem0_arcache), 
        .axi_m1_arlock      (m_axi_card_mem0_arlock),  
        .axi_m1_arprot      (m_axi_card_mem0_arprot), 
        .axi_m1_arvalid     (m_axi_card_mem0_arvalid), 
        .axi_m1_arready     (m_axi_card_mem0_arready),
        // AXI  ead data channel          
        .axi_m1_rready      (m_axi_card_mem0_rready), 
        .axi_m1_rid         (m_axi_card_mem0_rid),
        .axi_m1_rdata       (m_axi_card_mem0_rdata),
        .axi_m1_rresp       (m_axi_card_mem0_rresp),
        .axi_m1_rlast       (m_axi_card_mem0_rlast),
        .axi_m1_rvalid      (m_axi_card_mem0_rvalid),
    
        //---- AXI Lite bus interfaced with SNAP core ----               
        // AXI write address channel
        .s_axi_awready	    (s_axi_ctrl_reg_awready),   
        .s_axi_awaddr       (s_axi_ctrl_reg_awaddr),
        .s_axi_awvalid      (s_axi_ctrl_reg_awvalid),
        // axi write data channel             
        .s_axi_wready       (s_axi_ctrl_reg_wready),
        .s_axi_wdata        (s_axi_ctrl_reg_wdata),
        .s_axi_wstrb        (s_axi_ctrl_reg_wstrb),
        .s_axi_wvalid       (s_axi_ctrl_reg_wvalid),
        // AXI response channel
        .s_axi_bresp        (s_axi_ctrl_reg_bresp),
        .s_axi_bvalid       (s_axi_ctrl_reg_bvalid),
        .s_axi_bready       (s_axi_ctrl_reg_bready),
        // AXI read address channel
        .s_axi_arready      (s_axi_ctrl_reg_arready),
        .s_axi_arvalid      (s_axi_ctrl_reg_arvalid),
        .s_axi_araddr       (s_axi_ctrl_reg_araddr),
        // AXI read data channel
        .s_axi_rdata        (s_axi_ctrl_reg_rdata),
        .s_axi_rresp        (s_axi_ctrl_reg_rresp),
        .s_axi_rready       (s_axi_ctrl_reg_rready),
        .s_axi_rvalid       (s_axi_ctrl_reg_rvalid)
    );
    
endmodule
