// --------------------------------------------------
//	Define Global Variables
// --------------------------------------------------
`define	CLKFREQ			100			// Clock Freq. (Unit: MHz)
`define	SIMCYCLE		2**`BW_ADDR	// Sim. Cycles
`define	BW_DATA			256
`define	BW_ADDR			10
`define	BW_DATA_UNIT	64
`define	BW_ADDR_UNIT	6
// --------------------------------------------------
//	Includes
// --------------------------------------------------
`include	"sram_extension_param.v"

module sram_extension_tb;
// --------------------------------------------------
//	DUT Signals & Instantiate
// --------------------------------------------------
	wire	[`BW_DATA-1:0]				o_data;
	reg		[`BW_DATA-1:0]				i_data;
	reg		[`BW_ADDR-1:0]				i_addr;
	reg									i_wen;
	reg									i_oen;
	reg									i_clk;

	sram_extension_param
	#(
		.BW_DATA			(`BW_DATA			),
		.BW_ADDR			(`BW_ADDR			),
		.BW_DATA_UNIT		(`BW_DATA_UNIT		),
		.BW_ADDR_UNIT		(`BW_ADDR_UNIT		)
	)
	u_sram_extension_param(
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
	
//	always @(*) begin
//		case ({i_wen, i_oen})
//			2'b00 : taskState = "STANDBY";
//			2'b01 : begin
//				case (u_sram_extension_param.cen)
//					4'b0001 : taskState = "RD_C0X";
//					4'b0010 : taskState = "RD_C1X";
//					4'b0100 : taskState = "RD_C2X";
//					4'b1000 : taskState = "RD_C3X";
//				endcase
//			end
//			2'b10 : begin
//				case (u_sram_extension_param.cen)
//					4'b0001 : taskState = "WR_C0X";
//					4'b0010 : taskState = "WR_C1X";
//					4'b0100 : taskState = "WR_C2X";
//					4'b1000 : taskState = "WR_C3X";
//				endcase
//			end
//			default : taskState = "NOT_ALLOWED";
//		endcase
//	end

// --------------------------------------------------
//	Dump VCD
// --------------------------------------------------
	reg	[8*32-1:0]	vcd_file;
	initial begin
		if ($value$plusargs("vcd_file=%s", vcd_file)) begin
			$dumpfile(vcd_file);
			$dumpvars;
		//	for (j=0; j<16; j=j+1) begin
		//		$dumpvars(0, u_sram_extension.genblk1[0].genblk2[0].u_spsram.mem[j]); // mem of chip0l
		//		$dumpvars(0, u_sram_extension.genblk1[0].genblk2[1].u_spsram.mem[j]); // mem of chip0h
		//		$dumpvars(0, u_sram_extension.genblk1[1].genblk2[0].u_spsram.mem[j]); // mem of chip1l
		//		$dumpvars(0, u_sram_extension.genblk1[1].genblk2[1].u_spsram.mem[j]); // mem of chip1h
		//	end
		end else begin
			$dumpfile("sram_extension_tb.vcd");
			$dumpvars;
		end
	end

endmodule
