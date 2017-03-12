import lc3b_types::*;

module control_rom (
	input lc3b_word inst,
	output lc3b_control_word ctrl
);

always_comb
begin
	/* Default assignments */
	ctrl.opcode = lc3b_opcode'(data[15:12]);
	ctrl.load_cc = 1'b0;
	ctrl.load_pc = 1'b0;
	ctrl.load_ir = 1'b0;
	ctrl.load_regfile = 1'b0;
	ctrl.load_mar = 1'b0;
	ctrl.load_mdr = 1'b0;
	ctrl.pcmux_sel = 2'b00;
	ctrl.storemux_sel = 1'b0;
	ctrl.alumux_sel = 2'b00;
	ctrl.regfilemux_sel = 3'b000;
	ctrl.marmux_sel = 3'b000;
	ctrl.mdrmux_sel = 2'b00;
	ctrl.alu_op = alu_add;
	ctrl.mem_read = 1'b0;
	ctrl.mem_write = 1'b0;
	ctrl.mem_byte_enable = 2'b11;
	ctrl.br_addmux_sel = 0;
	ctrl.destmux_sel = 0;

	/*
	tdubey3 - Personal reminder: fetch1/2/3 are all handled in IF pipeline, this is the decode stage,
		so just worry about the signals that propagate forward through the pipeline.
		Workflow is: Go through state and next state for whole instruction: compile all states as one.
	*/

	case(lc3b_opcode'(data[15:12]))
		// ADD -> FETCH1
		op_add: begin
			ctrl.aluop = alu_add;
			ctrl.load_regfile = 1;
			ctrl.load_cc = 1;
			if (inst[5] == 1)
				ctrl.alumux_sel = 2'b10;
		end

		// AND -> FETCH1
		op_and: begin
			ctrl.aluop = alu_and;
			ctrl.load_regfile = 1;
			ctrl.load_cc = 1;
			if (inst[5] == 1)
				ctrl.alumux_sel = 2'b10;
		end

		// NOT -> FETCH1
		op_not: begin
			ctrl.alu_op = alu_not;
            ctrl.load_regfile = 1;
            ctrl.load_cc = 1;
        end

        // CALC_ADDR -> LDR1 (MEM WAIT) -> LDR2 -> FETCH1
        op_ldr: begin
        	//MAR <= SRA + SEXT(IR[5:0] << 1) (CALC_ADDR)
            ctrl.alumux_sel = 2'b01;
            ctrl.alu_op = alu_add;
            ctrl.load_mar = 1;

        	// MDR <= M[MAR] (LDR1)
        	ctrl.mdrmux_sel = 2'b01;
            ctrl.load_mdr = 1;
            ctrl.mem_read = 1;

            // DR <= MDR (LDR2)
            ctrl.regfilemux_sel = 3'b001;
            ctrl.load_regfile = 1;
            ctrl.load_cc = 1;
        end

        // CALC_ADDR -> STR1 -> STR2 (MEM WAIT) -> FETCH1
        op_str: begin
        	// MAR <= SRA + SEXT(IR[5:0] << 1) (CALC_ADDR)
            ctrl.alumux_sel = 2'b01;
            ctrl.alu_op = alu_add;
            ctrl.load_mar = 1;

            // MDR<=SR (STR1)
            ctrl.storemux_sel = 1;
            ctrl.alu_op = alu_pass;
            ctrl.load_mdr = 1;

            // M[MAR] <= MDR (STR2)
            ctrl.mem_write = 1;
        end

        // BR -> IF(BR_EN) BR_TAKEN -> FETCH1
        //       |-> ELSE -> FETCH1
        op_br: begin
        	// (BR)
        	// Does Nothing I guess
        end
		
		default: begin
			ctrl = 0;
		end
	endcase
end
endmodule : control_rom