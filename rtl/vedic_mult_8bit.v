`timescale 1ns / 1ps

module vedic_2x2 (
    input  wire [1:0] a,
    input  wire [1:0] b,
    output wire [3:0] q
);
    wire p0 = a[0] & b[0];
    wire p1 = a[1] & b[0];
    wire p2 = a[0] & b[1];
    wire p3 = a[1] & b[1];

    wire ha0_s = p1 ^ p2;
    wire ha0_c = p1 & p2;

    wire ha1_s = ha0_c ^ p3;
    wire ha1_c = ha0_c & p3;

    assign q = {ha1_c, ha1_s, ha0_s, p0};
endmodule

module vedic_4x4 (
    input  wire [3:0] a,
    input  wire [3:0] b,
    output wire [7:0] q
);
    wire [3:0] q0, q1, q2, q3;

    vedic_2x2 v0 (.a(a[1:0]), .b(b[1:0]), .q(q0));
    vedic_2x2 v1 (.a(a[3:2]), .b(b[1:0]), .q(q1));
    vedic_2x2 v2 (.a(a[1:0]), .b(b[3:2]), .q(q2));
    vedic_2x2 v3 (.a(a[3:2]), .b(b[3:2]), .q(q3));

    wire [5:0] sum1 = {2'b00, q0[3:2]} + {2'b00, q1};
    wire [5:0] sum2 = sum1 + {2'b00, q2};
    wire [5:0] sum3 = {2'b00, q3} + {2'b00, sum2[5:2]};

    assign q = {sum3[3:0], sum2[1:0], q0[1:0]};
endmodule

(* use_dsp = "no" *)
module vedic_mult_8bit (
    input  wire [7:0]  a,
    input  wire [7:0]  b,
    output wire [15:0] product
);
    wire [7:0] q0, q1, q2, q3;

    vedic_4x4 v0 (.a(a[3:0]), .b(b[3:0]), .q(q0));
    vedic_4x4 v1 (.a(a[7:4]), .b(b[3:0]), .q(q1));
    vedic_4x4 v2 (.a(a[3:0]), .b(b[7:4]), .q(q2));
    vedic_4x4 v3 (.a(a[7:4]), .b(b[7:4]), .q(q3));

    wire [11:0] mid_sum  = {4'b0, q0[7:4]} + {4'b0, q1} + {4'b0, q2};
    wire [11:0] high_sum = {4'b0, q3} + {4'b0, mid_sum[11:4]};

    assign product = {high_sum[7:0], mid_sum[3:0], q0[3:0]};
endmodule
