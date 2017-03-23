import lc3b_types::*;

module mem_datapath (
    input clk,
    input lc3b_control_word ctrl,
    input lc3b_word alu_out, pc_out, br_add_out, sr1_out, sr2_out, instruction,
    input lc3b_reg dest,

    // memory
    input logic resp_b,
    input logic [15:0] rdata_b,
    output logic read_b,
    output logic write_b,
    output logic [1:0] wmask_b,
    output logic [15:0] address_b,
    output logic [15:0] wdata_b,

    output lc3b_word regfilemux_out,
    output logic br_en, stall
);

lc3b_word trap_zext_out, marmux_out, mdrmux_out, zext_8_out, shift_out, ldb_zext_out, stbmux_out;
logic [7:0] ldbmux_out;
lc3b_nzp gencc_out, cc_out;

logic br_en_internal;

always_comb
begin
    read_b = ctrl.mem_read;
    write_b = ctrl.mem_write;
    

    if((read_b == 1'b1 || write_b == 1'b1) && (resp_b == 1'b0)) begin
        stall = 1'b1;
    end else begin
        stall = 1'b0;
    end

	if(br_en_internal && (ctrl.opcode == op_br)) begin
	   br_en = 1'b1;
	end else begin
	   br_en = 1'b0;
	end

    if((ctrl.opcode == op_stb) && (address_b[0] == 1)) begin
        wmask_b = 2'b10;
    end
    else if((ctrl.opcode == op_stb) && (address_b[0] == 0)) begin
        wmask_b = 2'b01;
    end
    else begin
        wmask_b = ctrl.mem_byte_enable;
    end
end

mux8 marmux
(
    .sel(ctrl.marmux_sel),
    .a(alu_out),
    .b(pc_out),
    .c(br_add_out),
    .d(rdata_b),
    .e(trap_zext_out),
    .f(16'b0),
    .g(16'b0),
    .h(16'b0),
    .i(address_b)
);

mux2 #(.width(16)) stbmux
(
    .sel(address_b[0]),
    .a(sr2_out),
    .b(sr2_out << 8),
    .f(stbmux_out)
);

mux8 mdrmux
(
    .sel(ctrl.mdrmux_sel),
    .a(alu_out),
    .b(rdata_b),
    .c(sr1_out << 8),
	.d(sr2_out),
    .e(stbmux_out),
    .f(16'b0),
    .g(16'b0),
    .h(16'b0),
    .i(wdata_b)
);

gencc gen_cc
(
    .in(regfilemux_out),
    .out(gencc_out)
);

register #(.width(3)) cc
(
    .clk(clk),
    .load(ctrl.load_cc),
    .in(gencc_out),
    .out(cc_out)
);

mux2 #(.width(8)) ldbmux
(
    .sel(address_b[0]),
    .a(rdata_b[7:0]),
    .b(rdata_b[15:8]),
    .f(ldbmux_out)
);

shiftunit sunit
(
    .a(instruction[5]),
    .d(instruction[4]),
    .sr(sr1_out),
    .imm4(instruction[3:0]),
    .f(shift_out)
);

udjns zext_8
(
    .in(rdata_b[7:0]),
    .out(zext_8_out)
);

udj trap_zext
(
    .in(instruction[7:0]),
    .out(trap_zext_out)
);

udjns ldbzext
(
    .in(ldbmux_out),
    .out(ldb_zext_out)
);

benable cccomp
(
    .n(cc_out[2]),
    .nr(dest[2]),
    .z(cc_out[1]),
    .zr(dest[1]),
    .p(cc_out[0]),
    .pr(dest[0]),
    .enable(br_en_internal)
);

mux8 regfilemux
(
    .sel(ctrl.regfilemux_sel),
    .a(alu_out),
    .b(rdata_b),
    .c(br_add_out),
    .d(pc_out),
    .e(zext_8_out),
    .f(shift_out),
    .g(ldb_zext_out),
    .h(16'b0),
    .i(regfilemux_out)
);

endmodule : mem_datapath