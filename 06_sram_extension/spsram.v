module spsram
#(
	parameter	 BW_DATA		 = 32,
	parameter	 BW_ADDR		 = 8
)(
	output		[BW_DATA-1:0]	o_data,
	input		[BW_DATA-1:0]	i_data,
	input		[BW_ADDR-1:0]	i_addr,
	input						i_wen,
	input						i_cen,
	input						i_oen,
	input						i_clk
);

	reg		[BW_DATA-1:0]	mem[0:2**BW_ADDR-1];

	always @(posedge i_clk) begin
		if (i_cen && i_wen) begin
			mem[i_addr]	<= i_data;
		end
		else begin
			mem[i_addr]	<= mem[i_addr];
		end
	end	

	`ifdef	SPSRAM_ASYNC
		assign o_data	=	!i_oen			 ? 'bz :
							i_cen &&  !i_wen ? mem[i_addr] : 'bz;
	`else
		reg		[BW_DATA-1:0] o_data;
		
		always @(posedge i_clk) begin
			if (i_oen) begin
				if (i_cen && !i_wen) begin
					o_data	<= mem[i_addr];
				end	
				else begin
					o_data <= 'bz;
				end	
			end 
			else begin
				o_data	<= 'bz;
			end	
		end	
	`endif
endmodule
