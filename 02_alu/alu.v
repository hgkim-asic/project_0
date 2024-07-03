// module alu
// #(	
// 	parameter	N			= 32
// )
// (	
// 	output reg	[N-1:0]		o_y,
// 	output 					o_c,
// 	input		[N-1:0]		i_a,
// 	input		[N-1:0]		i_b,
// 	input		[2:0]		i_f
// );
// 	wire		[N-1:0]		bmux = i_f[2] ? ~i_b : i_b;
// 	wire		[N-1:0]		sum_a_bmux;
// 
// 	assign {o_c, sum_a_bmux} = i_a + bmux + i_f[2];
// 	
// 	always @(*) begin
// 		case (i_f[1:0])
// 			2'b00 : o_y = i_a & bmux;
// 			2'b01 : o_y = i_a | bmux;
// 			2'b10 : o_y = sum_a_bmux;
// 			2'b11 : o_y = {{(N-1){1'b0}}, sum_a_bmux[N-1]};
// 		endcase
// 	end
// endmodule

module alu
#(	
	parameter	N			= 32
)
(	
	output reg signed	[N-1:0]		o_y,
	output	 						o_c,
	output							o_ovf,
	input signed		[N-1:0]		i_a,
	input signed 		[N-1:0]		i_b,
	input 				[2:0]		i_f
);

	wire signed			[N-1:0]		sum;
	wire							ovf_add	=	(i_f == 3'b010) &&
												((~i_a[N-1] && ~i_b[N-1] && sum[N-1]) || (i_a[N-1] && i_b[N-1] && ~sum[N-1]));
	wire							ovf_sub =	(i_f == 3'b110) && 
												((~i_a[N-1] && i_b[N-1] && sum[N-1]) || (i_a[N-1] && ~i_b[N-1] && ~sum[N-1]));

	assign o_ovf = ovf_add || ovf_sub;	
	assign {o_c, sum} = i_f[2] ? i_a-i_b : i_a+i_b;

	always @(*) begin
		case (i_f)
			3'b000	: o_y = i_a & i_b;
			3'b001	: o_y = i_a | i_b;
			3'b010	: o_y = sum;
			3'b100	: o_y = i_a & ~i_b;
			3'b101	: o_y = i_a | ~i_b;
			3'b110	: o_y = sum;
			3'b111	: o_y = i_a < i_b;
			default : o_y = 'd0;
		endcase
	end
endmodule
