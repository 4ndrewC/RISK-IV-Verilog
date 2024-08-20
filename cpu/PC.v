`include "fmt.v"

module program_counter(
    input PC_wb_tr,
    input PC_fetch,
    input jump,
    input rjump,
    input [`WORD-1:0] jump_loc,
    input signed [`WORD-1:0] jump_inc,
    output reg [`WORD-1:0] location,
    input clk
);

    reg [`WORD-1:0] PC;

    // for debugging
    reg [`WORD-1:0] jump_count; // keep track of how many times PC has jumped
    reg [`WORD-1:0] PC_count;

    initial begin
        PC <= 16'b0;
        jump_count <= 16'b0;
        PC_count <= 16'b0;
    end

    always @(posedge clk) begin
        // $monitor("executed");
        if(PC_fetch) begin
            $display("PC FETCH TRIGGERED\n");
            // $display("PC fetch count: %0d", PC_count);
            location <= PC;
            // PC_count <= PC_count + 1;
            // PC <= PC + 1;
        end
        else begin
            if(jump) begin
                $display("jumped");
                PC <= jump_loc;
            end
        end
        
        if(PC_wb_tr) begin
            // $monitor("PC jumping to: %0d", PC);
            jump_count <= jump_count + 1;
            PC <= PC + jump_inc;
            $monitor("PC jumping to: %0d", PC);
            // $display("number of jumps: %0d", jump_count);
        end
        

    end


endmodule
