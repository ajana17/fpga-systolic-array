`timescale 1ns / 1ps

(* use_dsp = "no" *)
module booth_wrapper (
    input  wire        clk,
    input  wire [7:0]  a_in,
    input  wire [7:0]  b_in,
    output reg  [15:0] prod_out
);
    reg [7:0] a_reg, b_reg;
    wire [15:0] prod_comb;

    always @(posedge clk) begin
        a_reg <= a_in;
        b_reg <= b_in;
    end

    booth_mult_8bit uut (
        .a(a_reg),
        .b(b_reg),
        .product(prod_comb)
    );

    always @(posedge clk) begin
        prod_out <= prod_comb;
    end
endmodule
