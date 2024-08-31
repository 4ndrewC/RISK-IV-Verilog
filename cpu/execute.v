`include "fmt.v"

/* 
Execution inputs (values used in execution):
- opcode
- reg1, reg2
- data from mem[imm]
- immediate
- SREG

Results of execution: 
- Write into memory (val and code)
- Write into register (val and code)
- Write into flag register (val)
- PC jump, rjump (rjump always at least 1 by default)
- PC jump increment


Execute split into three different stages
- get all values first (immediate, data from addr, reg1 data, reg2 data)
- decode and execute
- write back into memory or register or status flag
*/

module execute(
    input [`OPSIZE-1:0] opcode,
    input [2:0] reg1_code,
    input [2:0] reg2_code,
    input signed [`WORD-1:0] imm,
    input [`WORD-1:0] SREG_in,
    output reg [`WORD-1:0] SREG_out,
    output reg flag_update,
    output reg signed [`WORD-1:0] mem_write_val,
    output reg [`WORD-1:0] mem_write_addr,
    output reg signed [`WORD-1:0] reg_write_val,
    output reg [2:0] reg_write_code,
    input signed [`WORD-1:0] mem_read_data,
    input signed [`WORD-1:0] reg1_input_data,
    input signed [`WORD-1:0] reg2_input_data,
    output reg [`WORD-1:0] PC_jump_loc,
    output reg [`WORD-1:0] PC_jump_inc,
    output reg jump,
    output reg rjump,
    output reg mem_wb,
    output reg reg_wb,
    input dne_tr,
    input clk
);

    // alu variables
    reg has_imm;
    reg [`WORD-1:0] res;

    reg [`WORD-1:0] execution_cnt;

    initial begin execution_cnt <= 16'b0; end;

    always @(posedge clk) begin
        if(dne_tr) begin
            SREG_out = SREG_in;
            execution_cnt = execution_cnt + 1;
            $display("executing opcode: %5b", opcode);
            // $display("execution count: %0d", execution_cnt);
            reg_wb      = 1'b0;
            mem_wb      = 1'b0;
            jump        = 1'b0;
            rjump       = 1'b0;
            flag_update = 1'b0;
            
            if(opcode<=5'b01011) begin // ALU instructions
                case (opcode)
                    `ADD: begin res = reg1_input_data+reg2_input_data; has_imm = 1'b0; end
                    `ADDI: begin res = reg1_input_data+imm; has_imm = 1'b1; end
                    `SUB: begin res = reg1_input_data-reg2_input_data; has_imm = 1'b0; end
                    `SUBI: begin res = reg1_input_data-imm; has_imm = 1'b1; end
                    `AND: begin res = reg1_input_data&reg2_input_data; has_imm = 1'b0; end
                    `ANDI: begin res = reg1_input_data&imm; has_imm = 1'b1; end
                    `OR: begin res = reg1_input_data|reg2_input_data; has_imm = 1'b0; end
                    `ORI: begin res = reg1_input_data|imm; has_imm = 1'b1; end
                    `XOR: begin res = reg1_input_data^reg2_input_data; has_imm = 1'b0; end
                    `XORI: begin res = reg1_input_data^imm; has_imm = 1'b1; end
                    `CMP: begin res = reg2_input_data-reg1_input_data; has_imm = 1'b0; end
                    `CMPI: begin res = reg1_input_data-imm; has_imm = 1'b1; end
                    default: begin res = 0; has_imm = 1'b0; end
                endcase

                if(res==0) SREG_out[`Zf] = 1'b1;
                else SREG_out[`Zf] = 1'b0;
                

                if(opcode!=`CMP && opcode!=`CMPI) begin
                    reg_write_code = reg1_code;
                    reg_write_val = res;
                    reg_wb = 1'b1;
                    $display("ALU RES: %0d", res);
                end
                $display("Zero flag: %0d", res==0);
                
                // if(has_imm) begin
                //     PC_jump_inc = 2;
                // end
                // else PC_jump_inc = 1;
                flag_update = 1'b1;
                // rjump = 1'b1;
            end
            else if(opcode>=5'b10100) begin // flag modification instructions
                case (opcode)
                    `CLC: SREG_out[`Cf] = 1'b0;
                    `CLZ: SREG_out[`Zf] = 1'b0;
                    `CLN: SREG_out[`Nf] = 1'b0;
                    // `CLS: SREG_out[`Sf] = 1'b0;
                    `CLI: SREG_out[`If] = 1'b0;
                    `SLC: SREG_out[`Cf] = 1'b1;
                    `SLZ: SREG_out[`Zf] = 1'b1;
                    `SLN: SREG_out[`Nf] = 1'b1;
                    // `SLS: SREG_out[`Sf] = 1'b1;
                    `SLI: SREG_out[`If] = 1'b1;
                endcase
                // rjump = 1'b1;
                // PC_jump_inc = 1;
                flag_update = 1'b1;
            end
            else begin // other instructions
                case (opcode)
                    `LDI: begin
                        reg_write_code <= reg1_code;
                        reg_write_val <= imm;
                        reg_wb = 1'b1;
                        // PC_jump_inc = 2;
                        // rjump = 1'b1;
                    end
                    `LDA: begin
                        reg_write_code <= reg1_code;
                        reg_write_val <= mem_read_data;
                        reg_wb = 1'b1;
                        // PC_jump_inc = 2;
                        // rjump = 1'b1;
                    end
                    `LDW: begin
                        // $display("LDW instruction");
                        mem_write_addr <= imm;
                        mem_write_val <= reg1_input_data;
                        mem_wb = 1'b1;
                        // PC_jump_inc = 2;
                        // rjump = 1'b1;
                    end
                    `JMP: begin
                        PC_jump_loc = imm;
                        PC_jump_inc = 0;
                        jump = 1'b1;
                    end
                    `RJMP: begin
                        // $display("RJMP");
                        PC_jump_inc = imm;
                        rjump = 1'b1;
                    end
                    `MOV: begin
                        // $display("MOV EXECUTED");
                        reg_write_code <= reg1_code;
                        reg_write_val <= reg2_input_data;
                        reg_wb = 1'b1;
                        // PC_jump_inc = 1;
                        // rjump = 1'b1;
                    end
                    `BREQ: begin
                        if(SREG_in[`Zf]) begin
                            $display("branch");
                            PC_jump_loc = imm;
                            PC_jump_inc = 0;
                            jump = 1'b1;
                        end
                        else begin
                            $display("don't branch");
                            // PC_jump_inc = 2;
                        end
                    end
                    `CLR: begin
                        reg_write_code <= reg1_code;
                        reg_write_val <= 0;
                        reg_wb = 1'b1;
                        // PC_jump_inc = 2;
                        // rjump = 1'b1;
                    end
                endcase
            end
        end
    end


endmodule
