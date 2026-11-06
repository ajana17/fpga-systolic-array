`timescale 1ns / 1ps

(* use_dsp = "no" *)
module booth_mult_8bit (
    input  wire [7:0]  a,        
    input  wire [7:0]  b,        
    output wire [15:0] product
);

    wire [10:0] b_ext = {2'b00, b, 1'b0};

    wire signed [17:0] pp0, pp1, pp2, pp3, pp4;
    wire c0, c1, c2, c3, c4;

    booth_radix4_slice slice0 (.m(a), .window(b_ext[2:0]),  .pp(pp0), .cin(c0));
    booth_radix4_slice slice1 (.m(a), .window(b_ext[4:2]),  .pp(pp1), .cin(c1));
    booth_radix4_slice slice2 (.m(a), .window(b_ext[6:4]),  .pp(pp2), .cin(c2));
    booth_radix4_slice slice3 (.m(a), .window(b_ext[8:6]),  .pp(pp3), .cin(c3));
    booth_radix4_slice slice4 (.m(a), .window(b_ext[10:8]), .pp(pp4), .cin(c4));

    wire signed [17:0] sum0 = (pp0 + c0);
    wire signed [17:0] sum1 = (pp1 + c1) <<< 2;
    wire signed [17:0] sum2 = (pp2 + c2) <<< 4;
    wire signed [17:0] sum3 = (pp3 + c3) <<< 6;
    wire signed [17:0] sum4 = (pp4 + c4) <<< 8;

    wire signed [17:0] total = sum0 + sum1 + sum2 + sum3 + sum4;

    assign product = total[15:0];

endmodule

module booth_radix4_slice (
    input  wire [7:0]         m,
    input  wire [2:0]         window,
    output reg  signed [17:0] pp,
    output reg                cin
);
  
    wire signed [17:0] m_ext = {10'd0, m};

    always @(*) begin
        case (window)
            3'b000, 3'b111: begin 
                pp  = 18'sd0;
                cin = 1'b0;
            end
            3'b001, 3'b010: begin 
                pp  = m_ext;
                cin = 1'b0;
            end
            3'b011: begin        
                pp  = m_ext <<< 1;
                cin = 1'b0;
            end
            3'b100: begin     
                pp  = ~(m_ext <<< 1);
                cin = 1'b1;
            end
            3'b101, 3'b110: begin 
                pp  = ~m_ext;
                cin = 1'b1;
            end
            default: begin
                pp  = 18'sd0;
                cin = 1'b0;
            end
        endcase
    end

endmodule
