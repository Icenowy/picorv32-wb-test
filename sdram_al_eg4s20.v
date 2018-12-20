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

EG_PHY_SDRAM_2M_32 eg_sdram(
	.clk(clk),
	.ras_n(ras_n),
	.cas_n(cas_n),
	.we_n(we_n),
	.addr(addr),
	.ba(ba),
	.dq(dq),
	.cs_n(cs_n),
	.dm0(dm[0]),
	.dm1(dm[1]),
	.dm2(dm[2]),
	.dm3(dm[3]),
	.cke(cke)
);
endmodule
