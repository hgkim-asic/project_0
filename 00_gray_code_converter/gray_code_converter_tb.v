// --------------------------------------------------
//	Define Global Variables
// --------------------------------------------------
`define	CLKFREQ		100		// Clock Freq. (Unit: MHz)
`define	SIMCYCLE	2**`N	// Sim. Cycles
`define N			8		// Bitwidth of DATA

// --------------------------------------------------
//	Includes
// --------------------------------------------------
`include	"gray_code_converter.v"

module gray_code_converter_tb;
// --------------------------------------------------
//	DUT Signals & Instantiate
// --------------------------------------------------
	wire 	[`N-1:0]	o_B;
	wire 	[`N-1:0]	o_G;
	reg		[`N-1:0]	i_B;

	bin_to_gray
	#(
		.N					(`N					)
	)
	u_bin_to_gray(
		.o_G				(o_G				),
		.i_B				(i_B				)
	);

	gray_to_bin
	#(
		.N					(`N					)
	)
	u_gray_to_bin(
		.i_G				(o_G				),
		.o_B				(o_B				)
	);


// --------------------------------------------------
//	Tasks
// --------------------------------------------------
	integer				err	= 0;

	task init;
		begin
			i_B				= 0;
		end
	endtask

// --------------------------------------------------
//	Test Stimulus
// --------------------------------------------------
	integer		i, j;
	initial begin
		init();
		for (i=0; i<`SIMCYCLE; i++) begin
			i_B = i;	
			#(1000/`CLKFREQ);
			if (i_B != o_B) begin
				err = err + 1;
			end
		end
		#(1000/`CLKFREQ);
		if (err == 0) begin
			$display("Sim Completed : No Error Occurred.");
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
			$dumpfile("gray_code_converter_tb.vcd");
			$dumpvars;
		end
	end

endmodule
