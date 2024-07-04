// --------------------------------------------------
//	Define Global Variables
// --------------------------------------------------
`define	CLKFREQ		100		// Clock Freq. (Unit: MHz)
`define	SIMCYCLE	100		// Sim. Cycles

// --------------------------------------------------
//	Includes
// --------------------------------------------------
`include	"fsm_traffic_light.v"

module fsm_traffic_light_tb;
// --------------------------------------------------
//	DUT Signals & Instantiate
// --------------------------------------------------
	wire	[1:0]	o_LA;
	wire	[1:0]	o_LB;
	reg				i_TA;
	reg				i_TB;
	reg				i_P;
	reg				i_R;
	reg				i_clk;
	reg				i_rstn;

	fsm_traffic_light
	u_fsm_traffic_light(
		.o_LA				(o_LA				),
		.o_LB				(o_LB				),
		.i_TA				(i_TA				),
		.i_TB				(i_TB				),
		.i_P				(i_P				),
		.i_R				(i_R				),
		.i_clk				(i_clk				),
		.i_rstn				(i_rstn				)
	);

// --------------------------------------------------
//	Clock
// --------------------------------------------------
	always	#(500/`CLKFREQ)		i_clk = ~i_clk;

// --------------------------------------------------
//	Tasks
// --------------------------------------------------
	task init;
		begin
			i_TA			= 1;
			i_TB			= 0;
			i_P				= 0;
			i_R				= 0;
			i_clk			= 0;
			i_rstn			= 1;
		end
	endtask

	task resetNCycle;
		input	[9:0]	i;
		begin
			i_rstn			= 1'b0;
			#(i*1000/`CLKFREQ);
			i_rstn			= 1'b1;
		end
	endtask

// --------------------------------------------------
//	Test Stimulus
// --------------------------------------------------
	integer		i;
	initial begin
		init();
		#(1000/`CLKFREQ);
		resetNCycle(1);
		#(1000/`CLKFREQ);
		for (i=0; i<`SIMCYCLE; i=i+1) begin
			#(2000/`CLKFREQ);
			{i_TA, i_TB, i_P, i_R} = $urandom;
		end
		#(1000/`CLKFREQ);
		$finish;
	end
	
	reg		[4*32-1:0]	L_State, M_State;
	reg		[4*32-1:0]	color_LA, color_LB;

	always @(*) begin
		case (u_fsm_traffic_light.c_state_L)
			2'd0	: L_State = "S0";
			2'd1	: L_State = "S1";
			2'd2	: L_State = "S2";
			2'd3	: L_State = "S3";
		endcase
	end

	always @(*) begin
		case (u_fsm_traffic_light.c_state_M)
			2'd0	: M_State = "S0";
			2'd1	: M_State = "S1";
		endcase
	end
	
	always @(*) begin
		case (o_LA)
			2'd0	: color_LA = "GREEN";
			2'd1	: color_LA = "YELLOW";
			2'd2	: color_LA = "RED";
		endcase
	end

	always @(*) begin
		case (o_LB)
			2'd0	: color_LB = "GREEN";
			2'd1	: color_LB = "YELLOW";
			2'd2	: color_LB = "RED";
		endcase
	end

// --------------------------------------------------
//	Dump VCD
// --------------------------------------------------
	reg	[8*32-1:0]	vcd_file;
	initial begin
		if ($value$plusargs("vcd_file=%s", vcd_file)) begin
			$dumpfile(vcd_file);
			$dumpvars;
		end else begin
			$dumpfile("fsm_traffic_light_tb.vcd");
			$dumpvars;
		end
	end

endmodule
