// --------------------------------------------------
//	Define Global Variables
// --------------------------------------------------
`define	CLKFREQ		100		// Clock Freq. (Unit: MHz)
`define	SIMCYCLE	100		// Sim. Cycles
`define N			32		// Bitwidth of data

// --------------------------------------------------
//	Includes
// --------------------------------------------------
`include	"alu.v"

module alu_tb;
// --------------------------------------------------
//	DUT Signals & Instantiate
// --------------------------------------------------
	wire	[`N-1:0]	o_y;
	wire				o_c;
//	wire				o_ovf;
	reg		[`N-1:0]	i_a;
	reg		[`N-1:0]	i_b;
	reg		[2:0]		i_f;

	alu
	#(
		.N			(`N			)
	)
	u_alu_beh(
		.o_y				(o_y				),
		.o_c				(o_c				),
//		.o_ovf				(o_ovf				),
		.i_a				(i_a				),
		.i_b				(i_b				),
		.i_f				(i_f				)
	);


// --------------------------------------------------
//	Tasks
// --------------------------------------------------
	reg		[4*32-1:0]	operation;

	task init;
		begin
			i_a				= 0;
			i_b				= 0;
			i_f				= 0;
		end
	endtask

	task perform_operation;
		input	[2:0]		ti_f;
		input	[`N-1:0]	ti_a;
		input	[`N-1:0]	ti_b;
		begin
			#(1000/`CLKFREQ);
			i_a	= ti_a;
			i_b	= ti_b;
			i_f	= ti_f;
		end
	endtask

// --------------------------------------------------
//	Test Stimulus
// --------------------------------------------------
	integer i, fn;

	initial begin
		init();
		i	= 0;
		fn	= 0;
		while(i < `SIMCYCLE) begin
			if (fn%8 != 3) begin
				perform_operation(
					fn,
					$urandom,
					$urandom
				);	
				i=i+1;
			end
			fn=fn+1;
		end
		#(1000/`CLKFREQ);
		$finish;
	end
	always @(*) begin
		case (i_f)
			3'b000	: operation = "AND";
			3'b001	: operation = "OR";
			3'b010	: operation = "ADD";
			3'b100	: operation = "AND_N";
			3'b101	: operation = "OR_N";
			3'b110	: operation = "SUB";
			3'b111	: operation = "SLT";
			default	: operation = "NOT_USED";
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
			$dumpfile("alu_tb.vcd");
			$dumpvars;
		end
	end

endmodule
