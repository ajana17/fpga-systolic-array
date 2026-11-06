`timescale 1ns / 1ps

module tb_compare_multipliers;

    reg  [7:0]  a;
    reg  [7:0]  b;
    wire [15:0] prod_booth;
    wire [15:0] prod_vedic;
  
    booth_mult_8bit u_booth (.a(a), .b(b), .product(prod_booth));
    vedic_mult_8bit u_vedic (.a(a), .b(b), .product(prod_vedic));

    integer i;
    integer errors = 0;
    wire [15:0] expected = a * b;

    initial begin
        $display("Starting Multiplier Verification...");
      
        check_vector(8'd0,   8'd0);
        check_vector(8'd255, 8'd255);
        check_vector(8'd255, 8'd1);
        check_vector(8'd128, 8'd2);

        for (i = 0; i < 100; i = i + 1) begin
            check_vector($urandom_range(0, 255), $urandom_range(0, 255));
        end

        if (errors == 0) begin
            $display("SUCCESS: All test vectors passed identically for both multipliers!");
        end else begin
            $display("FAILURE: %0d mismatches found.", errors);
        end
        $finish;
    end

    task check_vector(input [7:0] in_a, input [7:0] in_b);
        begin
            a = in_a;
            b = in_b;
            #10;
            if (prod_booth !== expected || prod_vedic !== expected) begin
                $display("ERROR at A=%d, B=%d | Expected=%d, Booth=%d, Vedic=%d",
                         in_a, in_b, expected, prod_booth, prod_vedic);
                errors = errors + 1;
            end
        end
    endtask

endmodule
