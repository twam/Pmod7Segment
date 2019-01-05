`timescale 1ns / 1ps
//define our module and it's inputs/outputs
module top(
	input CLK,
	output P1A1, P1A2, P1A3, P1A4, P1A7, P1A8, P1A9, P1A10
    );

	wire [7:0] pmodmap;

	assign pmodmap[0] = P1A1;
	assign pmodmap[1] = P1A8;
	assign pmodmap[2] = P1A4;
	assign pmodmap[3] = P1A10;
	assign pmodmap[4] = P1A9;
	assign pmodmap[5] = P1A2;
	assign pmodmap[6] = P1A7;
	assign pmodmap[7] = P1A3;

	pmodcharlie pmodCharlieA(
		.clk(CLK),
		.pins(pmodmap),
		.display_data('hDEADBEEF)
		);

endmodule
