// --------------------------------------------------
//	Define Global Variables
// --------------------------------------------------
`define	CLKFREQ		100		// Clock Freq. (Unit: MHz)
`define	SIMCYCLE	64		// Sim. Cycles

// --------------------------------------------------
//	Includes
// --------------------------------------------------
`include	"sram_extension.v"

module sram_extension_tb;
// --------------------------------------------------
//	DUT Signals & Instantiate
// --------------------------------------------------

	wire	[63:0]	o_data;
	reg		[63:0]	i_data;
	reg		[5:0]	i_addr;
	reg				i_wen;
	reg				i_oen;
	reg				i_clk;

	sram_extension
	u_sram_extension(
		.o_data				(o_data				),
		.i_data				(i_data				),
		.i_addr				(i_addr				),
		.i_wen				(i_wen				),
		.i_oen				(i_oen				),
		.i_clk				(i_clk				)
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
			i_data				= 0;
			i_addr				= 0;
			i_wen				= 0;
			i_oen				= 0;
			i_clk				= 0;
		end
	endtask

	task memWR;
		input [63:0]	ti_data;
		input [5:0]		ti_addr;
		begin
			@(negedge i_clk) begin
				i_data		= ti_data;
				i_addr		= ti_addr;
				i_wen		= 1;
				i_oen		= 0;
			end
		end
	endtask
	
	task memRD;
		input	[5:0]	ti_addr;
		begin
			@(negedge i_clk) begin
				i_addr		= ti_addr;
				i_wen		= 0;
				i_oen		= 1;
			end
		end
	endtask

// --------------------------------------------------
//	Test Stimulus
// --------------------------------------------------
	integer		i, j;
	initial begin
		init();
		#(1000/`CLKFREQ);
		for (i=0; i<`SIMCYCLE; i=i+1) begin
			memWR(i,i);
		end
		for (i=0; i<`SIMCYCLE; i=i+1) begin
			memRD(i);
		end
		#(1000/`CLKFREQ);
		i_oen = 0;
		for (i=0; i<20; i=i+1) begin
			#(1000/`CLKFREQ);
		end
		$finish;
	end
	
	always @(*) begin
		case ({i_wen, i_oen})
			2'b00 : taskState = "STANDBY";
			2'b01 : begin
				case (u_sram_extension.cen)
					4'b0001 : taskState = "RD_C0X";
					4'b0010 : taskState = "RD_C1X";
					4'b0100 : taskState = "RD_C2X";
					4'b1000 : taskState = "RD_C3X";
				endcase
			end
			2'b10 : begin
				case (u_sram_extension.cen)
					4'b0001 : taskState = "WR_C0X";
					4'b0010 : taskState = "WR_C1X";
					4'b0100 : taskState = "WR_C2X";
					4'b1000 : taskState = "WR_C3X";
				endcase
			end
			default : taskState = "NOT_ALLOWED";
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
			$dumpfile("sram_extension_tb.vcd");
			$dumpvars;
		end
	end

endmodule
