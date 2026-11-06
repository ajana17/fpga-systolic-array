`timescale 1ns / 1ps

module pe (
    input  wire        clk,
    input  wire        rst_n,
    input  wire        clr_acc,  
    input  wire        valid_in, 
    input  wire [7:0]  a_in,     
    input  wire [7:0]  b_in,     
    output reg  [7:0]  a_out,    
    output reg  [7:0]  b_out,    
    output reg  [31:0] c_accum   
);

    wire [15:0] mult_product;
    booth_mult_8bit u_mult (
        .a(a_in),
        .b(b_in),
        .product(mult_product)
    );

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            a_out   <= 8'd0;
            b_out   <= 8'd0;
            c_accum <= 32'd0;
        end else begin
            a_out <= a_in;
            b_out <= b_in;

            // Multiply-Accumulate logic
            if (clr_acc) begin
                c_accum <= valid_in ? {16'd0, mult_product} : 32'd0;
            end else if (valid_in) begin
                c_accum <= c_accum + {16'd0, mult_product};
            end
        end
    end

endmodule
