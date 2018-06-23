`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/27/2017 12:47:07 PM
// Design Name: 
// Module Name: sim_queue
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

`define PER_H 2.5

module sim_queue();
    parameter DONE = 6'b11_1111;
	
	reg  Clk_32UI;
	reg  reset_n;
	
	reg  DRAM_get;
	reg [31:0] cnt_a0,cnt_a1,cnt_a2,cnt_a3;
	reg [63:0] cnt_b0,cnt_b1,cnt_b2,cnt_b3;
	reg [31:0] cntl_a0,cntl_a1,cntl_a2,cntl_a3;
	reg [63:0] cntl_b0,cntl_b1,cntl_b2,cntl_b3;
	
	//forward data
	reg  [5:0] status;
	reg  [6:0] ptr_curr; // record the status of curr and mem queue
	reg  [9:0] read_num;
	reg  [63:0] ik_x0, ik_x1, ik_x2, ik_info;
	reg  [6:0] forward_i;
	reg  [6:0] min_intv;
	reg  [7:0] CAM_query; //** next query should be prepared in the last stages of the datapath
	
	//forward output
	wire [5:0] status_out;
	wire [6:0] ptr_curr_out; // record the status of curr and mem queue
	wire [9:0] read_num_out;
	wire [63:0] ik_x0_out, ik_x1_out, ik_x2_out, ik_info_out;
	wire [6:0] forward_i_out;
	wire [6:0] min_intv_out;
	wire [7:0] query_out;
	
	wire [31:0] cnt_a0_out,cnt_a1_out,cnt_a2_out,cnt_a3_out;
	wire [63:0] cnt_b0_out,cnt_b1_out,cnt_b2_out,cnt_b3_out;
	wire [31:0] cntl_a0_out,cntl_a1_out,cntl_a2_out,cntl_a3_out;
	wire [63:0] cntl_b0_out,cntl_b1_out,cntl_b2_out,cntl_b3_out;

	//interaction with CAM
	wire new_read;
	reg  new_read_valid;
	reg  [9:0] new_read_num; //should be prepared before hand. every time new_read is set, next_read_num should be updated.
	reg  [7:0] new_read_query;
	reg  [63:0] new_ik_x0, new_ik_x1, new_ik_x2, new_ik_info;
	
	
	Queue uut(
		.Clk_32UI(Clk_32UI),
		.reset_n(reset_n),
		
		.DRAM_get(DRAM_get),
		.cnt_a0           (cnt_a0),		.cnt_a1           (cnt_a1),
		.cnt_a2           (cnt_a2),		.cnt_a3           (cnt_a3),
		.cnt_b0           (cnt_b0),		.cnt_b1           (cnt_b1),
		.cnt_b2           (cnt_b2),		.cnt_b3           (cnt_b3),
		.cntl_a0          (cntl_a0),	.cntl_a1          (cntl_a1),
		.cntl_a2          (cntl_a2),	.cntl_a3          (cntl_a3),
		.cntl_b0          (cntl_b0),	.cntl_b1          (cntl_b1),
		.cntl_b2          (cntl_b2),	.cntl_b3          (cntl_b3),
		
		//forward data
		.status(status),
		.ptr_curr(ptr_curr), // record the status of curr and mem queue
		.read_num(read_num),
		.ik_x0(ik_x0), .ik_x1(ik_x1), .ik_x2(ik_x2), .ik_info(ik_info),
		.forward_i(forward_i),
		.min_intv(min_intv),
		.CAM_query(CAM_query), //** next query should be prepared in the last stages of the datapath
		
		//forward output
		.status_out(status_out),
		.ptr_curr_out(ptr_curr_out), // record the status of curr and mem queue
		.read_num_out(read_num_out),
		.ik_x0_out(ik_x0_out), .ik_x1_out(ik_x1_out), .ik_x2_out(ik_x2_out), .ik_info_out(ik_info_out),
		.forward_i_out(forward_i_out),
		.min_intv_out(min_intv_out),
		.query_out(query_out),
		
		.cnt_a0_out           (cnt_a0_out),		.cnt_a1_out           (cnt_a1_out),
		.cnt_a2_out           (cnt_a2_out),		.cnt_a3_out           (cnt_a3_out),
		.cnt_b0_out           (cnt_b0_out),		.cnt_b1_out           (cnt_b1_out),
		.cnt_b2_out           (cnt_b2_out),		.cnt_b3_out           (cnt_b3_out),
		.cntl_a0_out          (cntl_a0_out),	.cntl_a1_out          (cntl_a1_out),
		.cntl_a2_out          (cntl_a2_out),	.cntl_a3_out          (cntl_a3_out),
		.cntl_b0_out          (cntl_b0_out),	.cntl_b1_out          (cntl_b1_out),
		.cntl_b2_out          (cntl_b2_out),	.cntl_b3_out          (cntl_b3_out),

		//interaction with CAM
		.new_read(new_read),
		.new_read_valid(new_read_valid),
		.new_read_num(new_read_num), //should be prepared before hand. every time new_read is set, next_read_num should be updated.
		.new_read_query(new_read_query),
		.new_ik_x0(new_ik_x0), .new_ik_x1(new_ik_x1), .new_ik_x2(new_ik_x2), .new_ik_info(new_ik_info)
		
	);
	
	initial forever #`PER_H Clk_32UI=!Clk_32UI; 
	
	initial begin
		Clk_32UI = 1;
		reset_n = 0;
		DRAM_get = 0;
		cnt_a0 	= 0;
		cnt_a1 	= 0;
		cnt_a2 	= 0;
		cnt_a3 	= 0;
		cnt_b0 	= 0;
		cnt_b1 	= 0;
		cnt_b2 	= 0;
		cnt_b3 	= 0;
		cntl_a0 = 0;
		cntl_a1 = 0;
		cntl_a2 = 0;
		cntl_a3 = 0;
		cntl_b0 = 0;
		cntl_b1 = 0;
		cntl_b2 = 0;
		cntl_b3 = 0;

		status = DONE;
		ptr_curr = 0; // record the status of curr and mem queue
		read_num = 0;
		ik_x0 = 0;
		ik_x1 = 0;
		ik_x2 = 0;
		ik_info = 0;
		forward_i = 0;
		min_intv = 0;
		CAM_query = 0; //** next query should be prepared in the last stages of the datapath

		new_read_valid = 0;
		new_read_num = 0; //should be prepared before hand. every time new_read is set, next_read_num should be updated.
		new_read_query = 0;
		new_ik_x0 = 0;
		new_ik_x1 = 0;
		new_ik_x2 = 0;
		new_ik_info = 0;
		
		#`PER_H;	#`PER_H;
		#`PER_H;	#`PER_H;
		
		reset_n = 1;
		
		#`PER_H;	#`PER_H;
		#`PER_H;	#`PER_H;
		#0.1;
		
		//------------------------------
		//initial case,  contents in pipeline should be reset to DONE
		#`PER_H;	#`PER_H;
		DRAM_get = 0;
		cnt_a0 	= 0;
		cnt_a1 	= 0;
		cnt_a2 	= 0;
		cnt_a3 	= 0;
		cnt_b0 	= 0;
		cnt_b1 	= 0;
		cnt_b2 	= 0;
		cnt_b3 	= 0;
		cntl_a0 = 0;
		cntl_a1 = 0;
		cntl_a2 = 0;
		cntl_a3 = 0;
		cntl_b0 = 0;
		cntl_b1 = 0;
		cntl_b2 = 0;
		cntl_b3 = 0;

		status = DONE;
		ptr_curr = 0; // record the status of curr and mem queue
		read_num = 0;
		ik_x0 = 0;
		ik_x1 = 0;
		ik_x2 = 0;
		ik_info = 0;
		forward_i = 0;
		min_intv = 0;
		CAM_query = 0; //** next query should be prepared in the last stages of the datapath

		new_read_valid = 0;
		new_read_num = 0; //should be prepared before hand. every time new_read is set, next_read_num should be updated.
		new_read_query = 0;
		new_ik_x0 = 0;
		new_ik_x1 = 0;
		new_ik_x2 = 0;
		new_ik_info = 0;
		
		//------------------------------
		// no memory responses and no more reads
		#`PER_H;	#`PER_H;
		DRAM_get = 0;
		cnt_a0 	= 0;
		cnt_a1 	= 0;
		cnt_a2 	= 0;
		cnt_a3 	= 0;
		cnt_b0 	= 0;
		cnt_b1 	= 0;
		cnt_b2 	= 0;
		cnt_b3 	= 0;
		cntl_a0 = 0;
		cntl_a1 = 0;
		cntl_a2 = 0;
		cntl_a3 = 0;
		cntl_b0 = 0;
		cntl_b1 = 0;
		cntl_b2 = 0;
		cntl_b3 = 0;

		status = 1;
		ptr_curr = 1; // record the status of curr and mem queue
		read_num = 1;
		ik_x0 = 1;
		ik_x1 = 1;
		ik_x2 = 1;
		ik_info = 1;
		forward_i = 1;
		min_intv = 1;
		CAM_query = 1; //** next query should be prepared in the last stages of the datapath

		new_read_valid = 0;
		new_read_num = 0; //should be prepared before hand. every time new_read is set, next_read_num should be updated.
		new_read_query = 0;
		new_ik_x0 = 0;
		new_ik_x1 = 0;
		new_ik_x2 = 0;
		new_ik_info = 0;
		
		//------------------------------
		// get memory responses, output old read
		#`PER_H;	#`PER_H;
		DRAM_get = 1;
		cnt_a0 	= 1;
		cnt_a1 	= 1;
		cnt_a2 	= 1;
		cnt_a3 	= 1;
		cnt_b0 	= 1;
		cnt_b1 	= 1;
		cnt_b2 	= 1;
		cnt_b3 	= 1;
		cntl_a0 = 1;
		cntl_a1 = 1;
		cntl_a2 = 1;
		cntl_a3 = 1;
		cntl_b0 = 1;
		cntl_b1 = 1;
		cntl_b2 = 1;
		cntl_b3 = 1;

		status = 2;
		ptr_curr = 2; // record the status of curr and mem queue
		read_num = 2;
		ik_x0 = 2;
		ik_x1 = 2;
		ik_x2 = 2;
		ik_info = 2;
		forward_i = 2;
		min_intv = 2;
		CAM_query = 2; //** next query should be prepared in the last stages of the datapath

		new_read_valid = 1;
		new_read_num = 3; //should be prepared before hand. every time new_read is set, next_read_num should be updated.
		new_read_query = 3;
		new_ik_x0 = 3;
		new_ik_x1 = 3;
		new_ik_x2 = 3;
		new_ik_info = 3;
		
		//------------------------------
		// no memory responses, fetch new read
		#`PER_H;	#`PER_H;
		DRAM_get = 0;
		cnt_a0 	= 0;
		cnt_a1 	= 0;
		cnt_a2 	= 0;
		cnt_a3 	= 0;
		cnt_b0 	= 0;
		cnt_b1 	= 0;
		cnt_b2 	= 0;
		cnt_b3 	= 0;
		cntl_a0 = 0;
		cntl_a1 = 0;
		cntl_a2 = 0;
		cntl_a3 = 0;
		cntl_b0 = 0;
		cntl_b1 = 0;
		cntl_b2 = 0;
		cntl_b3 = 0;

		status = 4;
		ptr_curr = 4; // record the status of curr and mem queue
		read_num = 4;
		ik_x0 = 4;
		ik_x1 = 4;
		ik_x2 = 4;
		ik_info = 4;
		forward_i = 4;
		min_intv = 4;
		CAM_query = 4; //** next query should be prepared in the last stages of the datapath

		new_read_valid = 1;
		new_read_num = 5; //should be prepared before hand. every time new_read is set, next_read_num should be updated.
		new_read_query = 5;
		new_ik_x0 = 5;
		new_ik_x1 = 5;
		new_ik_x2 = 5;
		new_ik_info = 5;
		
		//------------------------------
		// memory responses, no more reads
		#`PER_H;	#`PER_H;
		DRAM_get = 1;
		cnt_a0 	= 2;
		cnt_a1 	= 2;
		cnt_a2 	= 2;
		cnt_a3 	= 2;
		cnt_b0 	= 2;
		cnt_b1 	= 2;
		cnt_b2 	= 2;
		cnt_b3 	= 2;
		cntl_a0 = 2;
		cntl_a1 = 2;
		cntl_a2 = 2;
		cntl_a3 = 2;
		cntl_b0 = 2;
		cntl_b1 = 2;
		cntl_b2 = 2;
		cntl_b3 = 2;

		status = DONE;
		ptr_curr = 0; // record the status of curr and mem queue
		read_num = 0;
		ik_x0 = 0;
		ik_x1 = 0;
		ik_x2 = 0;
		ik_info = 0;
		forward_i = 0;
		min_intv = 0;
		CAM_query = 0; //** next query should be prepared in the last stages of the datapath

		new_read_valid = 0;
		new_read_num = 0; //should be prepared before hand. every time new_read is set, next_read_num should be updated.
		new_read_query = 0;
		new_ik_x0 = 0;
		new_ik_x1 = 0;
		new_ik_x2 = 0;
		new_ik_info = 0;
		
		// no memory responses, no more reads
		#`PER_H;	#`PER_H;
		DRAM_get = 0;

		status = DONE;
		ptr_curr = 0; // record the status of curr and mem queue
		read_num = 0;
		ik_x0 = 0;
		ik_x1 = 0;
		ik_x2 = 0;
		ik_info = 0;
		forward_i = 0;
		min_intv = 0;
		CAM_query = 0; //** next query should be prepared in the last stages of the datapath

		new_read_valid = 0;
		new_read_num = 0; //should be prepared before hand. every time new_read is set, next_read_num should be updated.
		new_read_query = 0;
		new_ik_x0 = 0;
		new_ik_x1 = 0;
		new_ik_x2 = 0;
		new_ik_info = 0;
		
		#`PER_H;	#`PER_H;
        #`PER_H;    #`PER_H;
        #`PER_H;	#`PER_H;
        #`PER_H;    #`PER_H;
        #`PER_H;	#`PER_H;
        #`PER_H;    #`PER_H;
        #`PER_H;	#`PER_H;
        #`PER_H;    #`PER_H;
        #`PER_H;	#`PER_H;
        #`PER_H;    #`PER_H;
        $finish;
		
		
	end

	
endmodule
