# ALU
## Operation Principle

## Verilog Code
### DUT
```Verilog
module alu
#(  
    parameter   N           = 32
)
(   
    output reg signed   [N-1:0]     o_y,
    output                          o_c,
    output                          o_ovf,
    input signed        [N-1:0]     i_a,
    input signed        [N-1:0]     i_b,
    input               [2:0]       i_f
);

    wire signed         [N-1:0]     sum;
    wire                            ovf_add =   (i_f == 3'b010) &&
                                                ((~i_a[N-1] && ~i_b[N-1] && sum[N-1]) || (i_a[N-1] && i_b[N-1] && ~sum[N-1]));
    wire                            ovf_sub =   (i_f == 3'b110) && 
                                                ((~i_a[N-1] && i_b[N-1] && sum[N-1]) || (i_a[N-1] && ~i_b[N-1] && ~sum[N-1]));

    assign o_ovf = ovf_add || ovf_sub;  
    assign {o_c, sum} = i_f[2] ? i_a-i_b : i_a+i_b;

    always @(*) begin
        case (i_f)
            3'b000  : o_y = i_a & i_b;
            3'b001  : o_y = i_a | i_b;
            3'b010  : o_y = sum;
            3'b100  : o_y = i_a & ~i_b;
            3'b101  : o_y = i_a | ~i_b;
            3'b110  : o_y = sum;
            3'b111  : o_y = i_a < i_b;
            default : o_y = 'd0;
        endcase
    end
endmodule
```

### Testbench
```Verilog
[...]
    task perform_operation;
        input   [2:0]       ti_f;
        input   [`N-1:0]    ti_a;
        input   [`N-1:0]    ti_b;
        begin
            #(1000/`CLKFREQ);
            i_a = ti_a;
            i_b = ti_b;
            i_f = ti_f;
        end
    endtask

// --------------------------------------------------
//  Test Stimulus
// --------------------------------------------------
    integer i, fn;

    initial begin
        init();
        i   = 0;
        fn  = 0;
        while(i < `SIMCYCLE) begin
            if (fn%8 == 7) begin
                perform_operation(
                    fn,
                    $urandom,
                    $urandom
                );  
                i=i+1;
            end
            fn=fn+1;
        end
        #(1000/`CLKFREQ);
        $finish;
    end
    always @(*) begin
        case (i_f)
            3'b000  : operation = "AND";
            3'b001  : operation = "OR";
            3'b010  : operation = "ADD";
            3'b100  : operation = "AND_N";
            3'b101  : operation = "OR_N";
            3'b110  : operation = "SUB";
            3'b111  : operation = "SLT";
            default : operation = "NOT_USED";
        endcase
    end
[...]
```

## Simulation Result
![waveform](./waveform/waveform0.png)
