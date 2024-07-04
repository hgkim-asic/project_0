`include "spsram.v"

module sram_extension
(
	output		[63:0]	o_data,
	input		[63:0]	i_data,
	input		[5:0]	i_addr,
	input				i_wen,
	input				i_oen,
	input				i_clk
);

	wire		[31:0]	w_o_data[1:0];	// i/o data is divided to 2 parts
	wire		[31:0]	w_i_data[1:0];	// chip select
	reg			[3:0]	cen;

	assign o_data 						= {w_o_data[1], w_o_data[0]};
	assign {w_i_data[1], w_i_data[0]}	= i_data;
	
	always @(*) begin
		case (i_addr[5:4])				// 2 out of 8 chips are activated for each case.
			2'h0 : cen = 4'b0001;
			2'h1 : cen = 4'b0010;
			2'h2 : cen = 4'b0100;
			2'h3 : cen = 4'b1000;
		endcase
	end

	genvar i, j;
	generate 
		for (i=0; i<4; i=i+1) begin		// i==0 : lowest mem addresses, i==3 : highest mem addresses
			for (j=0; j<2; j=j+1) begin	// j==0 : lower 32-bit data, j==1 : upper 32-bit data
				spsram
				#(
					.BW_DATA		(32           	),
					.BW_ADDR		(4            	)
				)
				u_spsram(
					.o_data			(w_o_data[j]	),
					.i_data			(w_i_data[j]	),
					.i_addr			(i_addr[3:0]  	),
					.i_wen			(i_wen			),
					.i_cen			(cen[i]       	),
					.i_oen			(i_oen			),
					.i_clk			(i_clk        	)
				);
			end
		end
	endgenerate
endmodule
