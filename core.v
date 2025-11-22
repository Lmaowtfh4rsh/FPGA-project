`timescale 1ns / 1ps

module DES_Core(
    input wire clk,
    input wire reset,
    input wire start_i,
    input wire [63:0] plaintext_i,
    input wire [63:0] key_i,
    output reg [63:0] ciphertext_o,
    output reg done_o
    );

    // State Machine
    reg [1:0] state;
    localparam IDLE = 2'd0, PROCESS = 2'd1, DONE = 2'd2;
    
    reg [3:0] round_ctr;
    reg [31:0] L, R, next_L, next_R;
    
    // Simple Key Schedule (Circular Shift)
    reg [63:0] k_reg;

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            state <= IDLE;
            done_o <= 0;
            round_ctr <= 0;
            ciphertext_o <= 0;
        end else begin
            case (state)
                IDLE: begin
                    done_o <= 0;
                    if (start_i) begin
                        // Initial Permutation (Simplified: just load)
                        L <= plaintext_i[63:32];
                        R <= plaintext_i[31:0];
                        k_reg <= key_i;
                        round_ctr <= 0;
                        state <= PROCESS;
                    end
                end

                PROCESS: begin
                    // Feistel Structure: L(n+1) = R(n), R(n+1) = L(n) ^ f(R(n), K(n))
                    L <= R;
                    
                    // "f" function (Simplified for compactness: Rotate + XOR)
                    // For Real DES, replace this line with Expansion -> SBOX -> Permutation
                    R <= L ^ {R[28:0], R[31:29]} ^ k_reg[31:0]; 
                    
                    // Rotate Key for next round
                    k_reg <= {k_reg[62:0], k_reg[63]};

                    if (round_ctr == 15) begin
                        state <= DONE;
                    end else begin
                        round_ctr <= round_ctr + 1;
                    end
                end

                DONE: begin
                    // Final Permutation (Simplified: Combine L and R)
                    // Note: In standard DES, R and L are swapped in the final output
                    ciphertext_o <= {R, L}; 
                    done_o <= 1'b1;
                    if (!start_i) state <= IDLE; // Handshake
                end
            endcase
        end
    end
endmodule
