`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06/27/2023 10:35:26 AM
// Design Name: 
// Module Name: fifo
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


module fifo (d_out, full, empty, threshold, ovf, undf, clk, rst_n, wr, rd, d_in);
    input wr;           // write input
    input rd;           // read input
    input clk;          // clock input
    input rst_n;        // reset signal (active low)
    input [7:0] d_in;   // 8-bit data input
    output [7:0] d_out; // 8-bit data output
    output full;        // 1 when FIFO full, else 0
    output empty;       // 1 when FIFO empty, else 0
    output threshold;   // 1 when number of data in FIFO is less than threshold, else 0
    output ovf;         // 1 when FIFO full and still writing, else 0 
    output undf;         // 1 when FIFO empty and still reading, else 0
    
    wire [4:0] wptr, rptr; // Write and Read pointers
    wire fifo_we, fifo_rd; // Write and Read signals
    
    write_pointer top1(wptr, fifo_we, wr, full, clk, rst_n); // Module instantiation of write pointer function
    read_pointer top2 (rptr, fifo_rd, rd, empty, clk, rst_n); // Module instantiation of read pointer function
    memory_array top3 (d_out, d_in, clk, fifo_we, wptr, rptr); // Module instantiation of memory array function
    status_signal top4(full, empty, threshold, ovf, undf, wr, rd, fifo_we, fifo_rd, wptr, rptr, clk, rst_n); // Module instantiation of status signal function
endmodule

// Memory array module
// @input(s): d_out, d_in, clk, fifo_we, wptr, rptr
// @output(s): d_out
// @mid(s): reg d_out2, wire d_out
module memory_array(d_out, d_in, clk, fifo_we, wptr, rptr);
    input [7:0] d_in;       // 8-bit data input bus
    input clk, fifo_we;     // clock, FIFO write inputs
    input [4:0] wptr, rptr; // 5-bit write and read pointer bus
    output [7:0] d_out;     // 8-bit data output bus
    
    reg [7:0] d_out2 [15:0]; // 8-bit width, 16 stages
    wire [7:0] d_out;
    
    always @ (posedge clk)
    begin
        if (fifo_we)
            d_out2[wptr[3:0]] <= d_in;
        end
        assign d_out = d_out2[rptr[3:0]];
endmodule

// Read Pointer module
// @input(s): rd, empty, clk, rst_n
// @output(s): fifo_rd, rptr
// @mid(s): reg rptr
module read_pointer (rptr, fifo_rd, rd, empty, clk, rst_n);
    input rd, empty, clk, rst_n;
    output fifo_rd;
    output [4:0] rptr;
    
    reg [4:0] rptr;
    
    assign fifo_rd = (~empty) & rd;
    always @ (posedge clk or negedge rst_n)
    begin
        if (~rst_n)
            rptr <= 5'b000000;  // ACTIVE LOW RESET -> resets rptr
        else if (fifo_rd)
            rptr <= rptr + 5'b000001; // FIFO_RD sig high -> increment ptr 1
        else
            rptr <= rptr; // PTR does not change
    end
endmodule

// Status Signal module
// @input(s): wr, rd, fifo_we, fifo_rd, clk, rst_n, wptr, rptr
// @output(s): full, empty, threshold, ovf, undf
// @mid(s): wire fbit_comp, ovf_set, undf_set, ptr_eq, ptr_result, reg full, empty, threshold, ovf, undf
module status_signal (full, empty, threshold, ovf, undf, wr, rd, fifo_we, fifo_rd, wptr, rptr, clk, rst_n);
    input wr, rd, fifo_we, fifo_rd, clk, rst_n;
    input [4:0] wptr, rptr;
    output full, empty, threshold, ovf, undf;
    
    wire fbit_comp, ovf_set, undf_set;
    wire ptr_eq;
    wire [4:0] ptr_result;
    reg full, empty, threshold, ovf, undf;
    
    assign fbit_comp = wptr[4] ^ rptr[4];
    assign ptr_eq = (wptr[3:0] - rptr[3:0]) ? 0:1;
    assign ptr_result = wptr[4:0] - rptr[4:0];
    assign ovf_set = full & wr;
    assign und_set = empty & rd;
    
    always @ (*)
    begin
        full = fbit_comp & ptr_eq;
        empty = (~fbit_comp) & ptr_eq;
        threshold = (ptr_result[4] || ptr_result[3]) ? 1:0;
    end
    
    always @ (posedge clk or negedge rst_n)
    begin
        if (~rst_n)
            ovf <= 0;
        else if ((ovf_set == 1) && (fifo_rd == 0))
            ovf <= 1;
        else if (fifo_rd)
            ovf <= 0;
        else
            ovf <= ovf;
    end
    
    always @ (posedge clk or negedge rst_n)
    begin
        if (~rst_n)
            undf <= 0;
        else if ((und_set == 1) && (fifo_we == 0))
            undf <= 1;
        else if (fifo_we)
            undf <= 0;
        else
            undf <= undf;
    end
endmodule

// Write Pointer module
// @input(s): wr, full, clk, rst_n
// @output(s): wptr, fifo_we
// @mid(s): reg wptr
module write_pointer(wptr, fifo_we, wr, full, clk, rst_n);
    input wr, full, clk, rst_n;
    output [4:0] wptr;
    output fifo_we;
    
    reg [4:0] wptr;
    
    assign fifo_we = (~full) & wr;
    
    always @ (posedge clk or negedge rst_n)
    begin
        if (~rst_n)
            wptr <= 5'b000000;
        else if (fifo_we)
            wptr <= wptr + 5'b000001;
        else
            wptr <= wptr;
    end
endmodule