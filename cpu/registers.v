`include "fmt.v"

/*
What to query from registers per fetch?
- Execution parameters
    - reg1_code
    - reg2_code
    - reg1_val
    - reg2_val
*/

module registers(
    input re, 
    input we, 
    input [2:0] reg1,
    input [2:0] reg2,
    input [2:0] reg_write_code,
    input signed [`WORD-1:0] data_in, 
    output reg signed [`WORD-1:0] data_out1, 
    output reg signed [`WORD-1:0] data_out2,
    output reg signed [`WORD-1:0] SREG_read,
    input signed [`WORD-1:0] SREG_write, 
    input get_reg_en,
    input reg_write_back,
    input flag_update,
    input clk
);

    reg signed [`WORD-1:0] registers[`REGISTERS-1:0];

    reg [`WORD-1:0] disptemp;
    reg w_success;

    always @(posedge clk) begin
        if(get_reg_en) begin
            $display("REGISTER DATA FETCH");
            data_out1 = registers[reg1];
            data_out2 = registers[reg2];
            SREG_read = registers[`SREG];
            $display("status flag: %16b", registers[`SREG]);
            $display("register %3b data: %16b", reg1, data_out1);
            $display("register %3b data: %16b\n", reg2, data_out2);
        end
        if(reg_write_back) begin
            $display("\n<<<register write back enabled>>>");
            registers[reg_write_code] = data_in;
            $display("writing %16b into register %3b\n", data_in, reg_write_code);
        end
        // if(flag_update) begin
        //     registers[`SREG] = SREG_write;
        //     $display("writing into status flag: %16b", SREG_write);
        // end
    end

    // always @(posedge reg_write_done) begin
    //     $display("register inputted: %16b", registers[reg_write_code]);
    // end

endmodule
