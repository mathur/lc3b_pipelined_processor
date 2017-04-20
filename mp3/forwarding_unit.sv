import lc3b_types::*;

module forwarding_unit
(
	input lc3b_reg id_ex_r_one, id_ex_r_two, ex_mem_r_dest, mem_wb_r_dest, if_id_r_one, if_id_r_two,
	input logic ex_mem_regfile_write,
	input logic mem_wb_regfile_write,
	input logic uses_sr1,
	input logic uses_sr2,
	input logic uses_sr1_mem,
	input logic uses_sr2_mem,
	input logic mem_read,
	input logic mem_write, 
	output logic [1:0] forward_a, forward_b,
	output logic stall_forwarding,
	output logic flush_forwarding
);

logic [1:0] forward_a_int;
logic [1:0] forward_b_int;

logic ex_forward_condition_a;
logic ex_forward_condition_b;
logic mem_forward_condition_a;
logic mem_forward_condition_b;

always_comb
begin
	// Default Values
	forward_a_int = 2'b00;
	forward_b_int = 2'b00;
	stall_forwarding = 0;
	flush_forwarding = 0;
    ex_forward_condition_a = ex_mem_regfile_write && (uses_sr1) && (ex_mem_r_dest == id_ex_r_one);
    ex_forward_condition_b = ex_mem_regfile_write && (uses_sr2) && (ex_mem_r_dest == id_ex_r_two);
    mem_forward_condition_a = mem_wb_regfile_write && (uses_sr1) && !(ex_mem_regfile_write && (uses_sr1) && (ex_mem_r_dest == id_ex_r_one)) && (mem_wb_r_dest == id_ex_r_one);
    mem_forward_condition_a = mem_wb_regfile_write && (uses_sr2) && !(ex_mem_regfile_write && (uses_sr2) && (ex_mem_r_dest == id_ex_r_two)) && (mem_wb_r_dest == id_ex_r_two);

	// EX to EX
	if (ex_mem_regfile_write && (uses_sr1) && (ex_mem_r_dest == id_ex_r_one)) begin 
		forward_a_int = 2'b01;
		if (mem_read) begin
			stall_forwarding = 1;
			flush_forwarding = 1;
		end
	end
	if (ex_mem_regfile_write && (uses_sr2) && (ex_mem_r_dest == id_ex_r_two)) begin 
		forward_b_int = 2'b01;
		if (mem_read) begin
			stall_forwarding = 1;
			flush_forwarding = 1;
		end
	end

	// MEM to EX
	if (mem_wb_regfile_write && (uses_sr1) && !(ex_mem_regfile_write
            && (uses_sr1) && (ex_mem_r_dest == id_ex_r_one)) && (mem_wb_r_dest == id_ex_r_one)) begin 
		forward_a_int = 2'b10;

	end
	if (mem_wb_regfile_write && (uses_sr2) && !(ex_mem_regfile_write
            && (uses_sr2) && (ex_mem_r_dest == id_ex_r_two)) && (mem_wb_r_dest == id_ex_r_two)) begin 
		forward_b_int = 2'b10;

	end
	
	// MEM to ID
    if (ex_mem_regfile_write && (ex_mem_r_dest == if_id_r_one)) begin
		if (mem_read) begin
			stall_forwarding = 1;
			flush_forwarding = 1;
		end
    end

    if (ex_mem_regfile_write && (ex_mem_r_dest == if_id_r_two)) begin
		if (mem_read) begin
			stall_forwarding = 1;
			flush_forwarding = 1;
		end
    end
end

assign forward_a = forward_a_int;
assign forward_b = forward_b_int;

endmodule
