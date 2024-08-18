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
    re, 
    we, 
    reg1,
    reg2,
    reg_write_code,
    data_in, 
    data_out1, 
    data_out2,
    SREG_read,
    SREG_write, 
    get_reg_en,
    reg_write_back,
    flag_update,
    clk
);

    input re, we, get_reg_en, clk, reg_write_back, flag_update;
    input [2:0] reg1, reg2, reg_write_code;
    input signed [`WORD-1:0] data_in, SREG_write;

    output reg signed [`WORD-1:0] data_out1, data_out2, SREG_read;

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
        if(flag_update) begin
            registers[`SREG] = SREG_write;
            $display("writing into status flag: %16b", SREG_write);
        end
    end

    // always @(posedge reg_write_done) begin
    //     $display("register inputted: %16b", registers[reg_write_code]);
    // end

endmodule