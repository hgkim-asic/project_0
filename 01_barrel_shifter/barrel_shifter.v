`include "mux2.v"

module barrel_shifter
#(
    parameter   BW_DATA         = 8,
    parameter   BW_CTRL         = 3
)
(   
    output      [BW_DATA-1:0]           o_y,
    input       [BW_DATA-1:0]           i_a,
    input       [BW_CTRL-1:0]           i_k,    // rotate amount
    input                               i_left  // rotate direction (1:left , 0:right)
);

    wire        [BW_DATA-1:0]           stage[BW_CTRL:0]; // stage[p][q] : q-th 'x' from left of p-th row
    
    genvar i, j;
    generate 
        for (i=0; i<=BW_CTRL; i=i+1) begin
            for (j=0; j<BW_DATA; j=j+1) begin
                mux2 
                u_mux2(
                    .o_data         (stage[i][j]                                                                    ),
                    .i_data0        (i==0       ? i_a[j]               : stage[i-1][j]                              ),
                    .i_data1        (i==0       ? i_a[(j+1) % BW_DATA] : stage[i-1][(j+2**(BW_CTRL-i)) % BW_DATA]   ),
                    .i_sel          (i==0       ? i_left               : i_left^i_k[BW_CTRL-i]                      )
                );
            end
        end
    endgenerate
    
    assign o_y = stage[BW_CTRL];
endmodule
    
module barrel_shifter_beh
#(  
    parameter   BW_DATA         = 8,
    parameter   BW_CTRL         = 3
)
(   
    output      [BW_DATA-1:0]           o_y,
    input       [BW_DATA-1:0]           i_a,
    input       [BW_CTRL-1:0]           i_k,    // rotate amount
    input                               i_left  // rotate direction (1:left , 0:right)
);
    assign o_y = i_left ?   (i_a << i_k) | (i_a >> (BW_DATA-i_k)) :
                            (i_a >> i_k) | (i_a << (BW_DATA-i_k));
endmodule
