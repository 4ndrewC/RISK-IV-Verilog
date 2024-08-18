`include "fmt.v"


/*
What to query from memory per fetch?
- Instruction at PC
- Execution parameters
    - immediate
    - data in memory[immedate]
*/


module mem(
    re, 
    we, 
    data_in, 
    data_out, 
    instr,
    read_addr,
    write_addr, 
    fetch_addr,
    imm, 
    fetch,
    write_back_en,
    clk
);

    input re, we, clk, fetch, write_back_en;
    input [`WORD-1:0] read_addr, write_addr, fetch_addr;
    input signed [`WORD-1:0] data_in;

    output reg [`WORD-1:0] data_out, imm;
    output reg signed [`WORD-1:0] instr;

    reg signed [`WORD-1:0] memory [`MEMSIZE-1:0];

    reg r_success;

    always @(posedge clk) begin
        if(fetch) begin
            instr <= memory[fetch_addr];
            imm <= memory[fetch_addr+1];
            data_out <= memory[memory[fetch_addr+1]];
            // $display("memory fetch data: %16b", data_out);
        end
        if(write_back_en) begin
            $display("\n<<<memory write back enabled>>>");
            $display("writing %16b into location %16b\n", data_in, write_addr);
            memory[write_addr] <= data_in;
        end
    end


    //testing
    initial begin
        //LDI test
        // memory[0] <= 16'b0110011000000000;
        // memory[1] <= 16'b0000000000000001;
        // // LDW test
        // memory[2] <= 16'b0111011000000000;
        // memory[3] <= 16'b0000000000001000;
        // // LDA test
        // memory[4] <= 16'b0110110000000000;
        // memory[5] <= 16'b0000000000001000;
        // // RJMP test
        // memory[6] <= 16'b1000000000000000;
        // memory[7] <= 16'b0000000000000011;

        // // // JMP test
        // // memory[6] <= 16'b0111100000000000;
        // // memory[7] <= 16'b0000000000001001;
    
        // // LDI
        // memory[9] <= 16'b0110010100000000;
        // memory[10] <= 16'b0000000000001110;

        // // MOV
        // memory[11] <= 16'b1001001010100000;

        // ADDI
        // memory[2] <= 16'b0000111000000000;
        // memory[3] <= 16'b0000000000000011;
        $readmemb("input.txt", memory);
    end

endmodule