module bin_to_gray
#(	
	parameter	N	= 32
)
(	
	output 		[N-1:0]	o_G,
	input		[N-1:0]	i_B
);
	genvar i;
	generate 
		for (i=0; i<N-1; i=i+1) begin
			assign o_G[i]	= i_B[i] ^ i_B[i+1];
		end
	endgenerate

	assign o_G[N-1]	= i_B[N-1];

endmodule

module gray_to_bin
#(	
	parameter	N	= 32
)
(	
	output		[N-1:0]	o_B,
	input 		[N-1:0]	i_G
);
	genvar i;
	generate 
		for (i=0; i<N-1; i=i+1) begin
			assign o_B[i]	= i_G[i] ^ o_B[i+1];
		end
	endgenerate
	
	assign o_B[N-1]	= i_G[N-1];

endmodule
