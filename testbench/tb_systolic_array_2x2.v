`timescale 1ns / 1ps

module tb_systolic_array_2x2;

    reg clk;
    reg rst_n;
    reg clr_acc;
    reg valid_in;
    reg [7:0] a0_in, a1_in;
    reg [7:0] b0_in, b1_in;

    wire [31:0] c00, c01, c10, c11;

    systolic_array_2x2 uut (
        .clk(clk),
        .rst_n(rst_n),
        .clr_acc(clr_acc),
        .valid_in(valid_in),
        .a0_in(a0_in),
        .a1_in(a1_in),
        .b0_in(b0_in),
        .b1_in(b1_in),
        .c00(c00),
        .c01(c01),
        .c10(c10),
        .c11(c11)
    );

    // Clock generator (100 MHz)
    always #5 clk = ~clk;

    initial begin
        clk = 0;
        rst_n = 0;
        clr_acc = 1;
        valid_in = 0;
        a0_in = 0; a1_in = 0;
        b0_in = 0; b1_in = 0;

        #20;
        rst_n = 1;
        #10;
        clr_acc = 0;

        @(posedge clk);
        valid_in = 1;
        a0_in = 8'd2; b0_in = 8'd1;
        a1_in = 8'd4; b1_in = 8'd2; 

        @(posedge clk);
        a0_in = 8'd3; b0_in = 8'd3;
        a1_in = 8'd5; b1_in = 8'd4;

        @(posedge clk);
        a0_in = 8'd0; b0_in = 8'd0;
        a1_in = 8'd0; b1_in = 8'd0;

        repeat (4) @(posedge clk);
        valid_in = 0;

        #20;
        $display("======= Matrix Multiplication Results =======");
        $display("C[0][0] = %0d (Expected: 11)", c00);
        $display("C[0][1] = %0d (Expected: 16)", c01);
        $display("C[1][0] = %0d (Expected: 19)", c10);
        $display("C[1][1] = %0d (Expected: 28)", c11);
        $display("=============================================");

        if (c00 == 11 && c01 == 16 && c10 == 19 && c11 == 28)
            $display("TEST PASSED: Systolic Array computation is 100%% accurate!");
        else
            $display("TEST FAILED: Result mismatch.");

        $finish;
    end

endmodule
