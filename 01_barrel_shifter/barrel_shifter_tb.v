// --------------------------------------------------
//	Define Global Variables
// --------------------------------------------------
`define	CLKFREQ		100					// Clock Freq. (Unit: MHz)
`define	SIMCYCLE	30					// Sim. Cycles
`define BW_DATA		8					// Bitwidth of data

// --------------------------------------------------
//	Includes
// --------------------------------------------------
`include	"barrel_shifter.v"

module barrel_shifter_tb;
// --------------------------------------------------
//	DUT Signals & Instantiate
// --------------------------------------------------
	wire 	[`BW_DATA-1:0]				o_y;
	wire 	[`BW_DATA-1:0]				o_y_beh;
	reg		[`BW_DATA-1:0]				i_a;
	reg		[$clog2(`BW_DATA)-1:0]		i_k;    
	reg									i_left; 

	barrel_shifter
	#(
		.BW_DATA			(`BW_DATA			)
	)
	u_barrel_shifter(
		.o_y				(o_y				),
		.i_a				(i_a				),
		.i_k				(i_k				),
		.i_left				(i_left				)
	);

	barrel_shifter_beh
	#(
		.BW_DATA			(`BW_DATA			)
	)
	u_barrel_shifter_beh(
		.o_y				(o_y_beh			),
		.i_a				(i_a				),
		.i_k				(i_k				),
		.i_left				(i_left				)
	);
// --------------------------------------------------
//	Tasks
// --------------------------------------------------
	integer	err;

	task init;
		begin
			err					= 0;
			i_a					= 0;
			i_k					= 0;
			i_left				= 0;
		end
	endtask

// --------------------------------------------------
//	Test Stimulus
// --------------------------------------------------
	integer	i, j;
	initial begin
		init();
		for (i = 0; i < `SIMCYCLE; i=i+1) begin
			i_a		= $urandom;
			i_k		= i % `BW_DATA;
			i_left	= $urandom;
			#(1000/`CLKFREQ);
		end
		if (err==0) begin
			$display("No error occurred.");
		end
		$finish;
	end

	always #(1000/`CLKFREQ) begin
		if (o_y != o_y_beh) begin
			$display("ERROR at time %t", $time);
			err=err+1;
		end
	end
// --------------------------------------------------
//	Dump VCD
// --------------------------------------------------
	reg	[8*32-1:0]	vcd_file;
	initial begin
		if ($value$plusargs("vcd_file=%s", vcd_file)) begin
			$dumpfile(vcd_file);
			$dumpvars;
			for (j=0; j<=$clog2(`BW_DATA); j++) begin
				$dumpvars(0, u_barrel_shifter.stage[i]);
			end
		end else begin
			$dumpfile("barrel_shifter_tb.vcd");
			$dumpvars;
		end
	end

endmodule
