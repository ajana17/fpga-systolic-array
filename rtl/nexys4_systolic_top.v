`timescale 1ns / 1ps

module nexys4_systolic_top (
    input  wire        CLK100MHZ,  
    input  wire        CPU_RESETN, 
    input  wire        BTNC,       
    input  wire [1:0]  SW,         
    output wire [7:0]  AN,      
    output wire [6:0]  SEG,       
    output reg  [3:0]  LED         
);

    wire sys_rst_n = CPU_RESETN;

    localparam IDLE  = 3'd0,
               FEED0 = 3'd1,
               FEED1 = 3'd2,
               FLUSH = 3'd3,
               DONE  = 3'd4;

    reg [2:0] state;
    reg       clr_acc;
    reg       valid_in;
    reg [7:0] a0, a1, b0, b1;
    reg [2:0] flush_cnt;

    wire [31:0] c00, c01, c10, c11;

    systolic_array_2x2 u_array (
        .clk(CLK100MHZ),
        .rst_n(sys_rst_n),
        .clr_acc(clr_acc),
        .valid_in(valid_in),
        .a0_in(a0),
        .a1_in(a1),
        .b0_in(b0),
        .b1_in(b1),
        .c00(c00),
        .c01(c01),
        .c10(c10),
        .c11(c11)
    );

    reg btnc_d1, btnc_d2;
    always @(posedge CLK100MHZ) begin
        btnc_d1 <= BTNC;
        btnc_d2 <= btnc_d1;
    end
    wire start_pulse = btnc_d1 & ~btnc_d2;


    always @(posedge CLK100MHZ or negedge sys_rst_n) begin
        if (!sys_rst_n) begin
            state     <= IDLE;
            clr_acc   <= 1'b1;
            valid_in  <= 1'b0;
            a0        <= 8'd0;
            a1        <= 8'd0;
            b0        <= 8'd0;
            b1        <= 8'd0;
            flush_cnt <= 3'd0;
            LED       <= 4'b0001; 
        end else begin
            case (state)
                IDLE: begin
                    clr_acc  <= 1'b1;
                    valid_in <= 1'b0;
                    if (start_pulse) begin
                        clr_acc  <= 1'b0;
                        valid_in <= 1'b1;
                      
                        a0 <= 8'd2; b0 <= 8'd1;
                        a1 <= 8'd4; b1 <= 8'd2;
                        state <= FEED0;
                        LED   <= 4'b0010; /
                    end
                end

                FEED0: begin
                    a0 <= 8'd3; b0 <= 8'd3;
                    a1 <= 8'd5; b1 <= 8'd4;
                    state <= FEED1;
                end

                FEED1: begin
                    a0 <= 8'd0; b0 <= 8'd0;
                    a1 <= 8'd0; b1 <= 8'd0;
                    flush_cnt <= 3'd0;
                    state <= FLUSH;
                end

                FLUSH: begin
                    if (flush_cnt == 3'd4) begin
                        valid_in <= 1'b0;
                        state    <= DONE;
                        LED      <= 4'b1000; 
                    end else begin
                        flush_cnt <= flush_cnt + 1'b1;
                    end
                end

                DONE: begin
                    if (start_pulse) begin
                        state <= IDLE;
                    end
                end
            endcase
        end
    end

    reg [31:0] display_data;
    always @(*) begin
        case (SW)
            2'b00: display_data = c00; 
            2'b01: display_data = c01; 
            2'b10: display_data = c10; 
            2'b11: display_data = c11; 
        endcase
    end

    seven_seg_controller u_disp (
        .clk(CLK100MHZ),
        .rst(~sys_rst_n),
        .value(display_data),
        .an(AN),
        .seg(SEG)
    );

endmodule
