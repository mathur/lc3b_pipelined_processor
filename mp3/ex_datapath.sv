import lc3b_types::*;

module ex_datapath (
    input clk,
    input lc3b_word ex_src1_data_in, ex_src2_data_in,
    input lc3b_word ex_instruction_in,
    input lc3b_word ex_pc_in,
    input lc3b_control_word ex_ctrl_in,
    output lc3b_word ex_alu_out, ex_br_out
);

lc3b_word adj5_out, adj6_out, adj6ns_out, adj9_out, adj11_out, br_addmux_out, alumux_out;

mux2 br_add_mux
(
    .sel(ex_ctrl_in.br_addmux_sel),
    .a(adj9_out),
    .b(adj11_out),
    .f(br_addmux_out)
);

badder #(.width(16)) br_add
(
    .a(br_addmux_out),
    .b(ex_pc_in),
    .f(ex_br_out)
);

mux4 alumux
(
    .sel(ex_ctrl_in.alumux_sel),
    .a(ex_src2_data_in),
    .b(adj6_out),
    .c(adj5_out),
    .d(adj6ns_out),
    .f(alumux_out)
);

alu alu_unit
(
    .alu_op(ex_ctrl_in.alu_op),
    .a(ex_src1_data_in),
    .b(alumux_out),
    .f(ex_alu_out)
);

adjns #(.width(5)) adj5
(
    .in(ex_instruction_in[4:0]),
    .out(adj5_out)
);

adj #(.width(6)) adj6
(
    .in(ex_instruction_in[5:0]),
    .out(adj6_out)
);

adjns #(.width(6)) adj6ns
(
    .in(ex_instruction_in[5:0]),
    .out(adj6ns_out)
);

adj #(.width(9)) adj9
(
    .in(ex_instruction_in[10:0]),
    .out(adj9_out)
);

adj #(.width(11)) adj11
(
    .in(ex_instruction_in[11:0]),
    .out(adj11_out)
);

// MISSING ALL FORWARDING UNIT STUFF

endmodule : ex_datapath