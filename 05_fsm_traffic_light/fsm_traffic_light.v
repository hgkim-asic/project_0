module fsm_traffic_light
(	
	output reg	[1:0]	o_LA,
	output reg	[1:0]	o_LB,
	input				i_TA,
	input				i_TB,
	input				i_P,
	input				i_R,
	input				i_clk,
	input				i_rstn
);

	localparam	S0_L	= 2'd0;
	localparam	S1_L	= 2'd1;
	localparam	S2_L	= 2'd2;
	localparam	S3_L	= 2'd3;
	
	localparam	S0_M	= 1'd0;
	localparam	S1_M	= 1'd1;

	localparam	GREEN	= 2'd0;
	localparam	YELLOW	= 2'd1;
	localparam	RED		= 2'd2;
	
	reg	[2:0]	c_state_L, n_state_L;
	reg [1:0]	c_state_M, n_state_M;

	wire		M 		= c_state_M == S1_M;

	always @(posedge i_clk) begin
		if(!i_rstn) begin
			c_state_L	<= S0_L;
		end else begin
			c_state_L	<= n_state_L;	
		end
	end
	
	always @(*) begin
		case (c_state_L)
			S0_L	: n_state_L = ~i_TA			? S1_L : S0_L;
			S1_L	: n_state_L = S2_L;
			S2_L	: n_state_L = ~M && ~i_TB	? S3_L : S2_L;
			S3_L	: n_state_L = S0_L;
		endcase
	end

	always @(posedge i_clk) begin
		if(!i_rstn) begin
			c_state_M	<= S0_M;	
		end else begin
			c_state_M	<= n_state_M;	
		end
	end
	
	always @(*) begin
		case (c_state_M)
			S0_M	: n_state_M = i_P ? S1_M : S0_M;
			S1_M	: n_state_M = i_R ? S0_M : S1_M;
		endcase
	end

	always @(*) begin
		case (c_state_L)
			S0_L : begin
				o_LA = GREEN;
				o_LB = RED;
			end
			S1_L : begin
				o_LA = YELLOW;
				o_LB = RED;
			end
			S2_L : begin
				o_LA = RED;
				o_LB = GREEN;
			end
			S3_L : begin
				o_LA = RED;
				o_LB = YELLOW;
			end
		endcase
	end
	 
endmodule
