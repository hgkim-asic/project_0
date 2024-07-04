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

	localparam	S0		= 2'd0;
	localparam	S1		= 2'd1;
	localparam	S2		= 2'd2;
	localparam	S3		= 2'd3;

	localparam	GREEN	= 2'd0;
	localparam	YELLOW	= 2'd1;
	localparam	RED		= 2'd2;
	
	reg	[2:0]	c_state_L, n_state_L;
	reg [1:0]	c_state_M, n_state_M;

	wire	M 	= c_state_M == S1;

	always @(posedge i_clk) begin
		if(!i_rstn) begin
			c_state_L	<= S0;
		end else begin
			c_state_L	<= n_state_L;	
		end
	end
	
	always @(*) begin
		case (c_state_L)
			S0	: n_state_L = ~i_TA			? S1 : S0;
			S1	: n_state_L = S2;
			S2	: n_state_L = ~M && ~i_TB	? S3 : S2;
			S3	: n_state_L = S0;
		endcase
	end

	always @(posedge i_clk) begin
		if(!i_rstn) begin
			c_state_M	<= S0;	
		end else begin
			c_state_M	<= n_state_M;	
		end
	end
	
	always @(*) begin
		case (c_state_M)
			S0	: n_state_M = i_P ? S1 : S0;
			S1	: n_state_M = i_R ? S0 : S1;
		endcase
	end

	always @(*) begin
		case (c_state_L)
			S0 : begin
				o_LA = GREEN;
				o_LB = RED;
			end
			S1 : begin
				o_LA = YELLOW;
				o_LB = RED;
			end
			S2 : begin
				o_LA = RED;
				o_LB = GREEN;
			end
			S3 : begin
				o_LA = RED;
				o_LB = YELLOW;
			end
		endcase
	end
endmodule
