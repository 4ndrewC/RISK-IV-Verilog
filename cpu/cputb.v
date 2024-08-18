`timescale 1ns/1ns
`include "cpu.v"


module cputb;

    reg clk;
    reg [`WORD-1:0] cycles;

    cpu uut(clk, cycles);

    always begin 
        clk = ~clk; #10;
    end

    always begin cycles = cycles + 1; #20; end


    initial begin
        $dumpfile("cpu.vcd");
        $dumpvars(0, cputb);

        $display("\nSIMULATION BEGIN\n\n");
        
        cycles <= 0;
        clk <= 1'b0;

        #900;
        
        $finish;
    end;


endmodule
