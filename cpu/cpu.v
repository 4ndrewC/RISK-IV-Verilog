`include "fmt.v"
`include "mem.v"
`include "registers.v"
`include "PC.v"
`include "execute.v"

module cpu(
    clk,
    cycles
);

    input clk;
    input [`WORD-1:0] cycles;
    
    reg fetch_tr, dne_tr, reg_tr, mem_tr, PC_fetch, PC_wb_tr, reset_tr; // stages and triggers
    reg reg_wb_tr, mem_wb_tr, flag_update_tr;

    // PC variables
    wire jump, rjump, PC_done, PC_fetch_done;
    wire [`WORD-1:0] jump_loc, PC;
    wire signed [`WORD-1:0] jump_inc;

    // memory and register variables
    reg mem_read, mem_write, reg_read, reg_write;
    wire signed [`WORD-1:0] mem_data_in, reg_data_in;
    wire [2:0] reg1_code, reg2_code, reg_write_code;
    wire [`WORD-1:0] mem_write_addr, mem_read_addr; // memory address (read/write, no PC fetch), never changes
    wire signed [`WORD-1:0] mem_data_out, reg1_data_out, reg2_data_out;

    wire [`WORD-1:0] instr, imm; // never changes on its own
    wire [`OPSIZE-1:0] opcode; // never changes on its own

    
    wire [`WORD-1:0] SREG_read, SREG_write; // status flag register

    // execution write back triggers (for syncing)
    wire reg_write_en, mem_write_en, flag_update_en;


    program_counter pc_inst(
        .PC_wb_tr(PC_wb_tr),
        .PC_fetch(PC_fetch),
        .jump(jump),
        .rjump(rjump),
        .jump_loc(jump_loc),
        .jump_inc(jump_inc),
        .location(PC),
        .clk(clk)
    );

    mem mem_inst(
        .re(mem_read),
        .we(mem_write),
        .data_in(mem_data_in),
        .data_out(mem_data_out),
        .instr(instr),
        .read_addr(mem_read_addr),
        .write_addr(mem_write_addr),
        .fetch_addr(PC),
        .imm(imm),
        .fetch(fetch_tr),
        .write_back_en(mem_wb_tr),
        .clk(clk)
    );

    assign opcode = instr[15:11];
    assign reg1_code = instr[10:8];
    assign reg2_code = instr[7:5];

    execute ex_inst(
        .opcode(opcode),
        .reg1_code(reg1_code),
        .reg2_code(reg2_code),
        .imm(imm),
        .SREG_in(SREG_read),
        .SREG_out(SREG_write),
        .flag_update(flag_update_en),
        .mem_write_val(mem_data_in),
        .mem_write_addr(mem_write_addr),
        .reg_write_val(reg_data_in),
        .reg_write_code(reg_write_code),
        .mem_read_data(mem_data_out),
        .reg1_input_data(reg1_data_out),
        .reg2_input_data(reg2_data_out),
        .PC_jump_loc(jump_loc),
        .PC_jump_inc(jump_inc),
        .jump(jump),
        .rjump(rjump),
        .mem_wb(mem_write_en),
        .reg_wb(reg_write_en),
        .dne_tr(dne_tr),
        .clk(clk)
    );


    registers reg_inst(
        .re(reg_read),
        .we(reg_write),
        .reg1(reg1_code),
        .reg2(reg2_code),
        .reg_write_code(reg_write_code),
        .data_in(reg_data_in),
        .data_out1(reg1_data_out),
        .data_out2(reg2_data_out),
        .SREG_read(SREG_read),
        .SREG_write(SREG_write),    
        .get_reg_en(reg_tr),
        .reg_write_back(reg_wb_tr),
        .flag_update(flag_update_tr),
        .clk(clk)
    );

    // syncing PC write back after all other write backs
    reg [2:0] write_backs, written;
    reg execute_finished, check_wb;

    always @(posedge clk) begin
        if(PC_fetch) begin
            $display("----------------------------");
            write_backs <= 0;
            written <= 0;
            PC_fetch <= 1'b0;
            fetch_tr <= 1'b1; 
        end
        if(fetch_tr) begin
            $display("PC fetch location: %0d", PC);
            fetch_tr <= 1'b0;
            reg_tr <= 1'b1;
        end
        if(reg_tr) begin
            $display("current instruction: %16b\n", instr);
            reg_tr <= 1'b0;
            dne_tr <= 1'b1;
        end
        if(dne_tr) begin
            /* After decode and execute, do all necessary write backs
               After all write backs, reset to initial state
            */
            dne_tr <= 1'b0;
            check_wb <= 1'b1;
            execute_finished <= 1'b1;
        end
        if(check_wb) begin // sync write backs
            check_wb <= 1'b0;
            if(reg_write_en) begin
                reg_wb_tr <= 1'b1;
                write_backs <= write_backs + 1;
            end
            if(mem_write_en) begin
                mem_wb_tr <= 1'b1;
                write_backs <= write_backs + 1;
            end
            if(flag_update_en) begin
                flag_update_tr <= 1'b1;
                write_backs <= write_backs + 1;
            end
        end
        if(reg_wb_tr) begin
            written <= written + 1;
            reg_wb_tr <= 1'b0;
        end
        if(mem_wb_tr) begin
            written <= written + 1;
            mem_wb_tr <= 1'b0;
        end
        if(flag_update_tr) begin
            written <= written + 1;
            flag_update_tr <= 1'b0;
        end
        // reg/mem write backs before PC write back/increment
        if(written==write_backs & execute_finished) begin
            $display("number of write backs: %0d", write_backs);
            $display("number written: %0d", written);
            PC_wb_tr <= 1'b1;
            execute_finished <= 1'b0;
        end   
        if(PC_wb_tr) begin
            $display("\nClock cycles: %0d\n", cycles);
            PC_wb_tr <= 1'b0;
            PC_fetch <= 1'b1;
            // execute_finished <= 1'b0;
        end    
    end

    // always @(posedge dne_done) $monitor("%1b", reg_wb_tr);

    initial begin
        PC_fetch <= 1'b1;
    end
    

endmodule
