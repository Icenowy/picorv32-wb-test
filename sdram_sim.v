module sdram(clk, ras_n, cas_n, we_n, addr, ba, dq, cs_n, dm, cke);
input clk;
input ras_n;
input cas_n;
input we_n;
input [10:0]addr;
input [1:0]ba;
inout [31:0]dq;
input cs_n;
input [3:0]dm;
input cke;

mt48lc2m32b2 mt_sdram_model(
	.Dq(dq),
	.Addr(addr),
	.Ba(ba),
	.Clk(clk),
	.Cke(cke),
	.Cs_n(cs_n),
	.Ras_n(ras_n),
	.Cas_n(cas_n),
	.We_n(we_n),
	.Dqm(dm)
);
endmodule
