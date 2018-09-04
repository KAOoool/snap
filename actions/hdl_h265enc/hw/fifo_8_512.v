//-------------------------------------------------------------------
//
//  COPYRIGHT (C) 2011, VIPcore Group, Fudan University
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
//  Filename      : fifo_8_512.v
//  Author        : Gu Chen Hao
//  Created       : 2018-09-02
//  Description   : fifo, input 8 bits, output 512 bits
//
//-------------------------------------------------------------------

module fifo_8_512 (
    rst    ,
    wr_clk ,
    rd_clk ,
    din    ,
    wr_en  ,
    rd_en  ,
    dout   ,
    empty  
    );

    input               rst      ;
    input               wr_clk   ;
    input               rd_clk   ;
    input   [7  :   0]  din      ;
    input               wr_en    ;
    input               rd_en    ;
    output  [511:   0]  dout     ;
    output              empty    ;
 
    reg     [2  :   0]  cout     ;

    reg     [7  :   0]  din_0    ;   
    reg     [7  :   0]  din_1    ;   
    reg     [7  :   0]  din_2    ;   
    reg     [7  :   0]  din_3    ;   
    reg     [7  :   0]  din_4    ;   
    reg     [7  :   0]  din_5    ;   
    reg     [7  :   0]  din_6    ;   
 
    wire    [63 :   0]  din_64   ;  
    
    wire                wr_en_64 ;        

    always @(posedge wr_clk or posedge rst) begin
        if( rst ) begin
            cout <= 0;
        end 
        else begin
            if ( wr_en )
                cout <= cout + 3'd1;
        end
    end

    always @(posedge wr_clk or posedge rst) begin
        if( rst ) begin
            din_0 <= 8'd0 ;
            din_1 <= 8'd0 ;
            din_2 <= 8'd0 ;
            din_3 <= 8'd0 ;
            din_4 <= 8'd0 ;
            din_5 <= 8'd0 ;
            din_6 <= 8'd0 ;
        end 
        else begin
            if ( wr_en ) begin
                din_0 <= din   ;
                din_1 <= din_0 ;
                din_2 <= din_1 ;
                din_3 <= din_2 ;
                din_4 <= din_3 ;
                din_5 <= din_4 ;
                din_6 <= din_5 ;
            end
        end
    end

    assign din_64 = {din, din_0, din_1, din_2, din_3, din_4, din_5, din_6} ;

    assign wr_en_64 = ( cout == 3'd7 ) && wr_en ;

    fifo_64_512 fifo_64_512_bs(
      .rst              ( rst                       ),
      .wr_clk           ( wr_clk                    ),
      .rd_clk           ( rd_clk                    ),
      .din              ( din_64                    ),
      .wr_en            ( wr_en_64                  ),
      .rd_en            ( rd_en                     ),
      .dout             ( dout                      ),
      .empty            ( empty                     )
      );

endmodule // fifo_8_512
