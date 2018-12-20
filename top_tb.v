`timescale 1ns/1ps
module top_tb();

reg clk;
reg rst;

wire ser_rx;
wire ser_tx;

top top_module(clk, ~rst, ser_rx, ser_tx);

initial begin
	$dumpfile("top_tb.vcd");
        $dumpvars(0,top_tb);
	clk = 1;
	rst = 0;
	#20.833
	rst = 1;
	#104.167
	rst = 0;
	#1000000
	$stop;
end

always begin
	#20.833
	clk = ~clk;
end

endmodule
