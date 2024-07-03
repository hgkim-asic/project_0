`include "cla_4b.v"

module adder_cla
#(	
	parameter	BW_DATA			= 32
)
(	
	output		[BW_DATA-1:0]	o_s,
	output		 			  	o_c,
	input		[BW_DATA-1:0]	i_a,
	input		[BW_DATA-1:0]	i_b,
	input						i_c
);
	wire		[BW_DATA/4:1]	carry; // carry[i] : cout of 'i-th' 4b CLA (cout of each '4i-th' bit)

	genvar i;
	generate 
		for (i=0; i<BW_DATA/4; i=i+1) begin
			cla_4b 
			u_cla_4b(
				.o_s	(o_s[i*4 +: 4]         ),
				.o_c	(carry[i+1]            ),
				.i_a	(i_a[i*4 +: 4]         ),
				.i_b	(i_b[i*4 +: 4]         ),
				.i_c	(i==0 ? i_c : carry[i] )
			);
		end
	endgenerate

	assign o_c = carry[BW_DATA/4];
endmodule
