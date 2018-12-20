module top(
	input clk,
	input rst_n,

	input ser_rx,
	output ser_tx
);

reg [1:0] internal_rst_count = 0;

always @(posedge clk) begin
	if (internal_rst_count != 2'b11)
		internal_rst_count <= internal_rst_count + 1;
end

assign internal_rst = internal_rst_count != 2'b11;

wire sdram_clk = clk;

`include "wb_common.v"

wire wb_clk = clk;
wire wb_rst = internal_rst ? internal_rst : ~rst_n;

`include "wb_intercon.vh"

assign wb_m2s_ram0_rty = 0;

wb_ram #(
	.depth('h1000),
	.memfile("firmware.hex")
) ram0(
	.wb_clk_i(wb_clk),
	.wb_rst_i(wb_rst),

	.wb_adr_i(wb_m2s_ram0_adr),
	.wb_dat_i(wb_m2s_ram0_dat),
	.wb_sel_i(wb_m2s_ram0_sel),
	.wb_we_i(wb_m2s_ram0_we),
	.wb_bte_i(wb_m2s_ram0_bte),
	.wb_cti_i(wb_m2s_ram0_cti),
	.wb_cyc_i(wb_m2s_ram0_cyc),
	.wb_stb_i(wb_m2s_ram0_stb),

	.wb_ack_o(wb_s2m_ram0_ack),
	.wb_err_o(wb_s2m_ram0_err),
	.wb_dat_o(wb_s2m_ram0_dat)
);

wire	uart0_irq;

assign	wb_s2m_uart0_err = 0;
assign	wb_s2m_uart0_rty = 0;

uart_top uart0 (
	.wb_clk_i(wb_clk),
	.wb_rst_i(wb_rst),
	.wb_adr_i(wb_m2s_uart0_adr[4:2]),
	.wb_dat_i(wb_m2s_uart0_dat),
	.wb_we_i(wb_m2s_uart0_we),
	.wb_stb_i(wb_m2s_uart0_stb),
	.wb_cyc_i(wb_m2s_uart0_cyc),
	.wb_sel_i(4'b0),
	.wb_dat_o(wb_s2m_uart0_dat),
	.wb_ack_o(wb_s2m_uart0_ack),

	.int_o(uart0_irq),
	.stx_pad_o(ser_tx),
	.rts_pad_o(),
	.dtr_pad_o(),

	.srx_pad_i(ser_rx),
	.cts_pad_i(1'b0),
	.dsr_pad_i(1'b0),
	.ri_pad_i(1'b0),
	.dcd_pad_i(1'b0)
);

wire dram0_sdram_ras_n;
wire dram0_sdram_cas_n;
wire dram0_sdram_we_n;
wire [10:0]dram0_sdram_addr;
wire [1:0]dram0_sdram_ba;
wire [31:0]dram0_sdram_dq;
wire dram0_sdram_cs_n;
wire [3:0]dram0_sdram_dm;
wire dram0_sdram_cke;

sdram dram0_sdram(
	.clk(sdram_clk),
	.ras_n(dram0_sdram_ras_n),
	.cas_n(dram0_sdram_cas_n),
	.we_n(dram0_sdram_we_n),
	.addr(dram0_sdram_addr),
	.ba(dram0_sdram_ba),
	.dq(dram0_sdram_dq),
	.cs_n(dram0_sdram_cs_n),
	.dm(dram0_sdram_dm),
	.cke(dram0_sdram_cke)
);

wire dram0_sdr_init_done;

assign	wb_s2m_dram0_err = 0;
assign	wb_s2m_dram0_rty = 0;

sdrc_top #(
	.SDR_DW(32),
	.SDR_BW(4)
) dram0 (
	.cfg_sdr_width(2'b00),
	.cfg_colbits(2'b00),

	.wb_rst_i(wb_rst),
	.wb_clk_i(wb_clk),

	.wb_stb_i(wb_m2s_dram0_stb),
	.wb_ack_o(wb_s2m_dram0_ack),
	.wb_addr_i(wb_m2s_dram0_adr),
	.wb_we_i(wb_m2s_dram0_we),
	.wb_dat_i(wb_m2s_dram0_dat),
	.wb_sel_i(wb_m2s_dram0_sel),
	.wb_dat_o(wb_s2m_dram0_dat),
	.wb_cyc_i(wb_m2s_dram0_cyc),
	.wb_cti_i(wb_m2s_dram0_cti),

	.sdram_clk(sdram_clk),
	.sdram_resetn(~wb_rst),
	.sdr_cs_n(dram0_sdram_cs_n),
	.sdr_cke(dram0_sdram_cke),
	.sdr_ras_n(dram0_sdram_ras_n),
	.sdr_cas_n(dram0_sdram_cas_n),
	.sdr_we_n(dram0_sdram_we_n),
	.sdr_dqm(dram0_sdram_dm),
	.sdr_ba(dram0_sdram_ba),
	.sdr_addr(dram0_sdram_addr),
	.sdr_dq(dram0_sdram_dq),

	.sdr_init_done(dram0_sdr_init_done),
	.cfg_req_depth(2'h3),
	.cfg_sdr_en(1'b1),
	.cfg_sdr_mode_reg(13'h033),
	.cfg_sdr_tras_d(4'h4),
	.cfg_sdr_trp_d(4'h2),
	.cfg_sdr_trcd_d(4'h2),
	.cfg_sdr_cas(3'h3),
	.cfg_sdr_trcar_d(4'h7),
	.cfg_sdr_twr_d(4'h1),
	.cfg_sdr_rfsh(12'h100),
	.cfg_sdr_rfmax(3'h6)
);

wire picorv32_0_trap;
wire picorv32_0_trace_valid;
wire [35:0] picorv32_0_trace_data;

assign wb_m2s_picorv32_cti = 0;
assign wb_m2s_picorv32_bte = 0;

picorv32_wb #(
	.COMPRESSED_ISA(1),
	.ENABLE_COUNTERS(1),
	.ENABLE_MUL(1),
	.ENABLE_DIV(1)
) picorv32_0(
	.trap(picorv32_0_trap),

	.wb_clk_i(wb_clk),
	.wb_rst_i(wb_rst),

	.wbm_adr_o(wb_m2s_picorv32_adr),
	.wbm_dat_o(wb_m2s_picorv32_dat),
	.wbm_dat_i(wb_s2m_picorv32_dat),
	.wbm_we_o(wb_m2s_picorv32_we),
	.wbm_sel_o(wb_m2s_picorv32_sel),
	.wbm_stb_o(wb_m2s_picorv32_stb),
	.wbm_ack_i(wb_s2m_picorv32_ack),
	.wbm_cyc_o(wb_m2s_picorv32_cyc),

	.trace_valid(picorv32_0_trace_valid),
	.trace_data(picorv32_0_trace_data)
);

endmodule
