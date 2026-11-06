`timescale 1ns / 1ps

module systolic_array_2x2 (
    input  wire        clk,
    input  wire        rst_n,
    input  wire        clr_acc,
    input  wire        valid_in,

    input  wire [7:0]  a0_in,
    input  wire [7:0]  a1_in, 

    input  wire [7:0]  b0_in, 
    input  wire [7:0]  b1_in, 

    output wire [31:0] c00,
    output wire [31:0] c01,
    output wire [31:0] c10,
    output wire [31:0] c11
);

    reg [7:0] a1_d1;
    reg [7:0] b1_d1;
    reg       val_d1;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            a1_d1  <= 8'd0;
            b1_d1  <= 8'd0;
            val_d1 <= 1'b0;
        end else begin
            a1_d1  <= a1_in;
            b1_d1  <= b1_in;
            val_d1 <= valid_in;
        end
    end
  
    wire [7:0] a00_to_a01, b00_to_b10;
    wire [7:0] a10_to_a11, b01_to_b11;
    wire [7:0] dummy_a01, dummy_b10, dummy_a11, dummy_b11;

    pe pe00 (
        .clk(clk),
        .rst_n(rst_n),
        .clr_acc(clr_acc),
        .valid_in(valid_in),
        .a_in(a0_in),
        .b_in(b0_in),
        .a_out(a00_to_a01),
        .b_out(b00_to_b10),
        .c_accum(c00)
    );

    pe pe01 (
        .clk(clk),
        .rst_n(rst_n),
        .clr_acc(clr_acc),
        .valid_in(valid_in),
        .a_in(a00_to_a01),
        .b_in(b1_d1),
        .a_out(dummy_a01),
        .b_out(b01_to_b11),
        .c_accum(c01)
    );

    pe pe10 (
        .clk(clk),
        .rst_n(rst_n),
        .clr_acc(clr_acc),
        .valid_in(val_d1),
        .a_in(a1_d1),
        .b_in(b00_to_b10),
        .a_out(a10_to_a11),
        .b_out(dummy_b10),
        .c_accum(c10)
    );

    pe pe11 (
        .clk(clk),
        .rst_n(rst_n),
        .clr_acc(clr_acc),
        .valid_in(val_d1),
        .a_in(a10_to_a11),
        .b_in(b01_to_b11),
        .a_out(dummy_a11),
        .b_out(dummy_b11),
        .c_accum(c11)
    );

endmodule
