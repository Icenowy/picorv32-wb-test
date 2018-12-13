module wb_ram_generic
  #(parameter depth=4096,
    parameter memfile = "")
  (input clk,
   input [3:0]	 we,
   input [31:0]  din,
   input [$clog2(depth)-1:0] 	 waddr,
   input [$clog2(depth)-1:0] 	 raddr,
   output [31:0] dout);

   al_ip_bram_simple_dual_emb9k_4kbyte bram(
      .dia(din),
      .addra(waddr),
      .clka(clk),
      .rsta(0),
      .wea(we),

      .dob(dout),
      .addrb(raddr),
      .clkb(clk),
      .rstb(0)
   );

endmodule
