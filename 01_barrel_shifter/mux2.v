module mux2
(
	output						o_data,
	input						i_data0,
	input						i_data1,
	input						i_sel
);

	assign o_data = i_sel ? i_data1 : i_data0;

endmodule
