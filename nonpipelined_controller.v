`timescale 1ns / 1ps

module BRAM_Controller(
    input wire clk,
    input wire reset,
    input wire start,
    output reg done_all,

    // BRAM Write Interface (Port A)
    output reg [5:0] bram_addr_a,
    output reg [63:0] bram_din_a,
    output reg bram_we_a,

    // BRAM Read Interface (Port B)
    output reg [5:0] bram_addr_b,
    output reg bram_en_b,
    input wire [63:0] bram_dout_b,

    // DES Interface
    output reg des_start,
    output reg [63:0] des_plain,
    output reg [63:0] des_key,
    input wire [63:0] des_cipher,
    input wire des_done
    );

    // State Encoding
    localparam IDLE      = 3'd0;
    localparam READ_RAM  = 3'd1;
    localparam WAIT_RAM  = 3'd2;
    localparam START_DES = 3'd3;
    localparam WAIT_DES  = 3'd4;
    localparam WRITE_RAM = 3'd5;
    localparam FINISH    = 3'd6;

    reg [2:0] state;

    // Hardcoded Key for this example (0x133457799BBCDFF1)
    wire [63:0] FIXED_KEY = 64'h133457799BBCDFF1;

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            state <= IDLE;
            done_all <= 0;
            bram_we_a <= 0;
            bram_en_b <= 0;
            des_start <= 0;
            bram_addr_a <= 0;
            bram_addr_b <= 0;
            des_plain <= 0;
            des_key <= 0;
            bram_din_a <= 0;
        end else begin
            case (state)
                IDLE: begin
                    done_all <= 0;
                    if (start) state <= READ_RAM;
                end

                READ_RAM: begin
                    // Read Plaintext from Address 0
                    bram_addr_b <= 6'd0;
                    bram_en_b <= 1'b1;
                    state <= WAIT_RAM;
                end

                WAIT_RAM: begin
                    // Wait 1 cycle for BRAM latency
                    bram_en_b <= 1'b0; 
                    state <= START_DES;
                end

                START_DES: begin
                    // Load data from BRAM output to DES inputs
                    des_plain <= bram_dout_b; 
                    des_key <= FIXED_KEY;
                    des_start <= 1'b1;
                    state <= WAIT_DES;
                end

                WAIT_DES: begin
                    des_start <= 1'b0;
                    // Wait for DES engine to finish
                    if (des_done) begin
                        state <= WRITE_RAM;
                    end
                end

                WRITE_RAM: begin
                    // Write Ciphertext to Address 1
                    bram_addr_a <= 6'd1; 
                    bram_din_a <= des_cipher;
                    bram_we_a <= 1'b1;
                    state <= FINISH;
                end
                
                FINISH: begin
                    bram_we_a <= 1'b0;
                    done_all <= 1'b1;
                    // Stay here until reset
                end
            endcase
        end
    end
endmodule
