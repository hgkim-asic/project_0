module shift_register
#(	
	parameter	BW_DATA			= 32
)
(	
	output reg	[BW_DATA-1:0]	o_q,
	input		[BW_DATA-1:0]	i_d,
	input						i_load,
	input						i_clk,
	input						i_s
);
	always @(posedge i_clk) begin
		if (i_load)	begin
			o_q <= i_d;
		end else begin
			o_q <= {o_q[BW_DATA-2:0], i_s};
		end
	end

endmodule
