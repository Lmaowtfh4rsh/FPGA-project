`timescale 1ns / 1ps

module tb_Top_DES_System();

    // Signals
    reg clk;
    reg reset;
    reg start_btn;
    wire done_led;

    // Instantiate the Top Module
    Top_DES_System uut (
        .clk(clk), 
        .reset(reset), 
        .start_btn(start_btn), 
        .done_led(done_led)
    );

    // Clock Generation (100MHz)
    always #5 clk = ~clk;

    // Test Procedure
    initial begin
        // Initialize Inputs
        clk = 0;
        reset = 1;
        start_btn = 0;

        // --- BACKDOOR MEMORY INITIALIZATION ---
        // We need to put data into the BRAM at Address 0 so the 
        // controller has something to read.
        // Access path: uut -> bram_inst -> inst -> native_mem_module...
        // Note: This path depends on Vivado IP version, but usually works:
        // If this fails, simulation will run but read X or 0.
        // --------------------------------------
        
        // Wait for Global Reset
        #100;
        reset = 0;
        
        // OPTIONAL: Force data into BRAM if backdoor fails
        // A cleaner way is to update the Controller to WRITE data first, 
        // but for this structure, we assume Memory has data.
        // Let's simulate the return data from BRAM using force for clarity 
        // if you don't have a .coe file loaded.
        force uut.bram_inst.inst.native_mem_module.blk_mem_gen_v8_4_5_inst.memory[0] = 64'h123456789ABCDEF0; 
        // Note: You might need to adjust the "v8_4_5" part based on your Vivado version
        // visible in the Simulation Scope window.

        #20;
        $display("Starting System...");
        start_btn = 1;
        #10 start_btn = 0;

        // Wait for Done
        wait(done_led == 1);
        #20;
        
        $display("Encryption Done.");
        $display("Ciphertext written to Address 1.");
        $finish;
    end

endmodule
