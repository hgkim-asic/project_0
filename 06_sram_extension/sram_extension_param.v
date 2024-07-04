module sram_extension_param
#(
	parameter	BW_DATA		= 64,
	parameter	BW_ADDR		= 6
)
(
	output		[BW_DATA-1:0]				o_data,
	input		[BW_DATA-1:0]				i_data,
	input		[BW_ADDR-1:0]				i_addr,
	input									i_wen,
	input									i_oen,
	input									i_clk
);
	localparam  chip_count_for_addr			= 2**(BW_ADDR-4);
	localparam  chip_count_for_data			= BW_DATA/32;
	localparam	total_chip_count			= chip_count_for_addr*chip_count_for_data;

	wire		[BW_DATA/2-1:0]				w_o_data[BW_DATA/32-1:0];	// i/o data is divided to 2 parts
	wire		[BW_DATA/2-1:0]				w_i_data[BW_DATA/32-1:0];	// chip select
	wire		[total_chip_count-1:0]		cen;
	
	genvar i, j;
	generate 
		for (i=0; i<BW_DATA/32; i=i+1) begin
			assign o_data[32*i+:32] = w_o_data[i];
		end
	endgenerate

	generate 
		for (i=0; i<BW_DATA/32; i=i+1) begin
			assign w_i_data[i] = i_data[32*i+:32];
		end
	endgenerate

	assign cen = 1 << i_addr[(BW_ADDR-1)-:(BW_ADDR-4)];

	generate 
		for (i=0; i<chip_count_for_addr; i=i+1) begin		// i==0 : lowest mem addresses, i==3 : highest mem addresses
			for (j=0; j<chip_count_for_data; j=j+1) begin	// j==0 : lower 32-bit data, j==1 : upper 32-bit data
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
