// --------------------------------------------------
//	Define Global Variables
// --------------------------------------------------
`define	CLKFREQ		100		// Clock Freq. (Unit: MHz)
`define	SIMCYCLE	20		// Sim. Cycles
`define BW_DATA		8		// Bitwidth of ~~

// --------------------------------------------------
//	Includes
// --------------------------------------------------
`include	"shift_register.v"

module shift_register_tb;
// --------------------------------------------------
//	DUT Signals & Instantiate
// --------------------------------------------------
	wire	[`BW_DATA-1:0]	o_q;
	reg		[`BW_DATA-1:0]	i_d;
	reg						i_load;
	reg						i_clk;
	reg						i_s;

	shift_register
	#(
		.BW_DATA			(`BW_DATA			)
		
	)
	u_shift_register(
		.o_q				(o_q				),
		.i_d				(i_d				),
		.i_load				(i_load				),
		.i_clk				(i_clk				),
		.i_s				(i_s				)
		
	);

// --------------------------------------------------
//	Clock
// --------------------------------------------------
	always	#(500/`CLKFREQ)		i_clk = ~i_clk;

// --------------------------------------------------
//	Tasks
// --------------------------------------------------
	reg		[4*32-1:0]	taskState;

	task init;
		begin
			taskState		= "Init";
			i_d				= 0;
			i_load			= 0;
			i_clk			= 0;
			i_s				= 0;
		end
	endtask

	task p_load;
		input [`BW_DATA-1:0]	ti_data;
		begin
			@(negedge i_clk);
			taskState		= "Load";
			i_d				= ti_data;
			i_load			= 1;
		end
	endtask

	task shift;
		input	ti_data;
		begin
			@(negedge i_clk);
			taskState		= "Shift";
			i_load			= 0;
			i_s				= ti_data;
		end
	endtask

	
// --------------------------------------------------
//	Test Stimulus
// --------------------------------------------------
	integer		i, j;
	initial begin
		init();
		p_load($urandom);
		#(1000/`CLKFREQ);
		for (i=0; i<`SIMCYCLE; i=i+1) begin
			shift($urandom);
		end
		$finish;
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
			$dumpfile("shift_register_tb.vcd");
			$dumpvars;
		end
	end

endmodule
