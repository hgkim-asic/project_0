`include "spsram.v"

module sram_extension_param
#(
	parameter	BW_DATA			= 64,
	parameter	BW_ADDR			= 6,
	parameter	BW_DATA_UNIT	= 32,
	parameter	BW_ADDR_UNIT	= 4
)
(
	output		[BW_DATA-1:0]				o_data,
	input		[BW_DATA-1:0]				i_data,
	input		[BW_ADDR-1:0]				i_addr,
	input									i_wen,
	input									i_oen,
	input									i_clk
);
	localparam  chip_count_for_addr			= 2**(BW_ADDR-BW_ADDR_UNIT);
	localparam  chip_count_for_data			= BW_DATA/BW_DATA_UNIT;
	localparam	total_chip_count			= chip_count_for_addr*chip_count_for_data;

	wire		[total_chip_count-1:0]		cen;

	assign cen = 1 << i_addr[(BW_ADDR-1)-:(BW_ADDR-BW_ADDR_UNIT)];

	genvar i, j;
	generate 
		for (i=0; i<chip_count_for_addr; i=i+1) begin
			for (j=0; j<chip_count_for_data; j=j+1) begin
				spsram
				#(
					.BW_DATA		(BW_DATA_UNIT    ),
					.BW_ADDR		(BW_ADDR_UNIT    )
				)
				u_spsram(
					.o_data			(o_data[BW_DATA_UNIT*j+:BW_DATA_UNIT]),
					.i_data			(i_data[BW_DATA_UNIT*j+:BW_DATA_UNIT]),
					.i_addr			(i_addr[BW_ADDR_UNIT-1:0]  	),
					.i_wen			(i_wen			),
					.i_cen			(cen[i]       	),
					.i_oen			(i_oen			),
					.i_clk			(i_clk        	)
				);
			end
		end
	endgenerate
endmodule
