module top(
	input clk,
	input rst_n,

	input ser_rx,
	output ser_tx
);

`include "wb_common.v"

wire wb_clk = clk;
wire wb_rst = ~rst_n;

`include "wb_intercon.vh"

assign wb_m2s_ram_rty = 0;

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
