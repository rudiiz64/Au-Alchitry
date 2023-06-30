// Timescale Directives
`timescale 10 ps/ 10ps

//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06/28/2023 10:41:59 AM
// Design Name: 
// Module Name: tb_fifo
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

// Preprocessor Directives
`define DELAY 10

module tb_fifo;

// Parameter definitions
parameter ENDTIME = 40000;

// DUT Input Regs
reg clk;
reg rst_n;
reg wr;
reg rd;
reg [7:0] d_in;

// DUT Output Wires
wire [7:0] d_out;
wire empty;
wire full;
wire threshold;
wire ovf;
wire undf;

// Integer for for loop
integer i;

// DUT Instantiation
fifo tb (/*AUTOARG*/
    // Outputs
    d_out, full, empty, threshold, ovf, undf, 
    //Inputs
    clk, rst_n, wr, rd, d_in);
    
// Initial Conditions: Set all regs to 0
initial
    begin
        clk = 1'b0;
        rst_n = 1'b0;
        wr = 1'b0;
        rd = 1'b0;
        d_in = 8'b0;
    end

// Test vector generation -> main TB program
initial
    begin
        main;
    end

// Main expansion
task main;
    fork
        clock_generator;    // Run clock_generator function
        reset_generator;    // Run reset_generator function
        operation_process;  // Run operation_process function
        debug_fifo;         // Run debug_fifo function
        endsimulation;      // Run endsimulation function
    join
endtask    

// Function breakdown
task clock_generator;
    begin
        forever #`DELAY clk = !clk; // Clock runs forever a 10ps increments
    end
endtask

task reset_generator;
    begin
        #(`DELAY * 2)   // Set delay to 20 ps
        rst_n = 1'b1;   // Set rst_n to HIGH
        # 7.9           // Delay 7.9 ps
        rst_n = 1'b0;   // Set rst_n to LOW
        # 7.09          // Delay 7.09 ps
        rst_n = 1'b1;   // Set rst_n to HIGH
    end
endtask

task operation_process;
    begin
        // for loop for write
        for (i = 0; i < 17; i = i + 1) begin: WRE
            #(`DELAY * 5)
            wr = 1'b1;
            d_in = d_in + 8'd1;
            #(`DELAY * 2)
            wr = 1'b0;
        end
        #(`DELAY)
        // for loop for read
        for (i = 0; i < 17; i = i + 1) begin: RDE
            #(`DELAY * 2)
            rd = 1'b1;
            #(`DELAY * 2)
            rd = 1'b0;
        end
    end
endtask

task debug_fifo;
    begin
        // Simple printing function
        $display("----------------------------------------------");  
        $display("------------------   -----------------------");  
        $display("----------- SIMULATION RESULT ----------------");  
        $display("--------------       -------------------");  
        $display("----------------     ---------------------");  
        $display("----------------------------------------------");
        $monitor("TIME = %d, wr = %b, rd = %b, d_in = %h", $time, wr, rd, d_in);
    end
endtask

// Self-checking
reg [5:0] waddr, raddr;
reg [7:0] mem[64:0];

always @ (posedge clk) begin
    // if rst_n low, reset waddr val
    if (~rst_n) begin
        waddr <= 6'd0;
    end
    
    // if wr high, set mem[waddr val] to d_in, increase waddr
    else if (wr) begin
    mem[waddr] <= d_in;
    waddr <= waddr + 1;
    end
    
    $display ("TIME = %d, d_out = %d, mem = %d", $time, d_out, mem[raddr]);
    // if rst_n low, reset raddr
    if (~rst_n)
        raddr <= 6'b0;
    // if rd = 1 and empty is low, increment raddr
    else if (rd & (~empty))
        raddr <= raddr + 1;
    
    if (rd & (~empty)) begin
        if (mem[raddr] == d_out) begin
            $display("=== PASS ===== PASS ==== PASS ==== PASS ===");
            if (raddr == 16) $finish;
        end
        else begin
            $display("=== FAIL ==== FAIL ==== FAIL ==== FAIL ===");
            $display("--------------- SIMULATION FINISHED ---------------");
            $finish;
        end
    end
end

task endsimulation;
    begin
        #ENDTIME
        $display("--------------- SIMULATION FINISHED ---------------");
        $finish;
    end
endtask
endmodule
