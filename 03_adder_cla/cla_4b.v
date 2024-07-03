module cla_4b
(	
	output		[3:0]	o_s,
	output				o_c,
	input		[3:0]	i_a,
	input		[3:0]	i_b,
	input				i_c
);
	wire		[3:1]	C;
	wire		[3:0]	P		= i_a ^	i_b;
	wire		[3:0]	G		= i_a & i_b;
	
	wire				P_3_0	= &P;
	wire				G_3_0	= G[3] | (P[3] & (G[2] | (P[2] & (G[1] | (P[1] & G[0])))));

	assign C[1]	= G[0] || (P[0] && i_c);  
    assign C[2]	= G[1] || (P[1] && C[1]);
    assign C[3]	= G[2] || (P[2] && C[2]);

	assign o_s	= P ^ {C, i_c};
	assign o_c	= G_3_0 || (P_3_0 & i_c);
	
endmodule
