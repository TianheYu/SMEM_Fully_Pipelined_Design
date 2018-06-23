`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/26/2017 12:49:32 PM
// Design Name: 
// Module Name: Top
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

`define CL 512
`define MAX_READ 1024
`define READ_NUM_WIDTH 10

module Top(
	input Clk_32UI,
	input reset_n,
	input stall_B, stall_C, stall_D, stall_E, stall_F,
	
	//RAM for reads
	input load_valid,
	input [`CL -1:0] load_data,
	input [`READ_NUM_WIDTH+1 -1:0] batch_size,
	output read_load_done,
	
	//memory requests / responses
	output DRAM_valid,
	output [31:0] addr_k, addr_l,
	output [`READ_NUM_WIDTH-1:0] DRAM_read_num,
	
	input DRAM_get,
	input [31:0] cnt_a0,cnt_a1,cnt_a2,cnt_a3,
	input [63:0] cnt_b0,cnt_b1,cnt_b2,cnt_b3,
	input [31:0] cntl_a0,cntl_a1,cntl_a2,cntl_a3,
	input [63:0] cntl_b0,cntl_b1,cntl_b2,cntl_b3,
	
	output output_request,
	output [`READ_NUM_WIDTH+1 - 1:0] done_counter,
	input output_permit,
	
	output [`CL -1:0] output_data,
	output output_valid,
	output output_finish,
	
	//----------------------------
	//for test
	output [6:0] backward_i_q_test,
	output [6:0] backward_j_q_test,
	output wire [10:0] num_reads_inqueue
);
	
	parameter Len = 101;
	
	parameter F_init = 	6'b00_0001; // F_init will disable the forward pipeline
	parameter F_run =  	6'b00_0010;
	parameter F_break = 6'b00_0100;
	parameter BCK_INI = 6'b00_1000;	//100
	parameter BCK_RUN = 6'b01_0000;	//101
	parameter BCK_END = 6'b10_0000;	//110
	parameter BUBBLE = 	6'b00_0000;

	
	//from queue to forward
	wire [5:0] status;
	wire [7:0] query; //only send the current query into the pipeline
	wire [6:0] ptr_curr; // record the status of curr and mem queue
	wire [`READ_NUM_WIDTH - 1:0] read_num;
	
	wire [63:0] ik_x0, ik_x1, ik_x2, ik_info;
	wire [63:0] forward_k_temp;
	wire [63:0] forward_l_temp;
	
	wire [6:0] forward_i;
	wire [6:0] min_intv;
	wire [6:0] backward_x;
	
	//from forward to queue
	wire [5:0] status_out;
	wire [7:0] query_out; //only send the current query into the pipeline
	wire [6:0] ptr_curr_out; // record the status of curr and mem queue
	wire [`READ_NUM_WIDTH - 1:0] read_num_out;
	wire [63:0] ik_x0_out, ik_x1_out, ik_x2_out, ik_info_out;
	wire [6:0] forward_i_out;
	wire [6:0] min_intv_out;
	wire [6:0] backward_x_out;
	
	wire [6:0] next_query_position;
	wire [5:0] status_query;
	wire [`READ_NUM_WIDTH - 1:0] read_num_query;
	
	//from backward to queue
	wire [6:0] next_query_position_B;
	wire [5:0] status_query_B;
	wire [`READ_NUM_WIDTH - 1:0] read_num_query_B;
	
	wire [6:0] forward_size_n_B;	
	wire [`READ_NUM_WIDTH - 1:0] read_num_B;
	wire [6:0] min_intv_B;
	wire [5:0] status_B;
	wire [6:0] new_size_B;
	wire [6:0] new_last_size_B;
	wire [63:0] primary_B;
	wire [6:0] current_rd_addr_B;
	wire [6:0] current_wr_addr_B,mem_wr_addr_B;
	wire [6:0] backward_i_B, backward_j_B;
	wire iteration_boundary_B;
	wire [63:0] p_x0_B,p_x1_B,p_x2_B,p_info_B;
	wire [63:0] reserved_token_x2_B; //reserved_token_x2 => last_token_x2_q
	wire [31:0] reserved_mem_info_B; //reserved_mem_info => last_mem_info_q
	wire [63:0] backward_k_B,backward_l_B; // backward_k == k, backward_l==l;
	wire [6:0] output_c_B; // address for next query
	
	//from queue to backward
	// queue special provide 
	wire [63:0] ik_x0_new_q;
	wire [63:0] ik_x1_new_q;
	wire [63:0] ik_x2_new_q;
	wire [6:0] backward_x_q; // x
	wire [7:0] backward_c_q; // next bp
	wire forward_all_done;
	wire [6:0] forward_size_n_q; //foward curr array size	
	
	// circular provide
	wire [`READ_NUM_WIDTH - 1:0] read_num_q;
	wire [6:0] min_intv_q;	//
	wire [5:0] status_q;
	wire [6:0] new_size_q;
	wire [6:0] new_last_size_q;
	//wire [63:0] primary_q;
	wire [6:0] current_rd_addr_q;
	wire [6:0] current_wr_addr_q;
	wire [6:0] mem_wr_addr_q;
	wire [6:0] backward_i_q; 
	wire [6:0] backward_j_q;
	wire iteration_boundary_q;
	wire [63:0] p_x0_q; // same as ik in forward datapath; store the p_x0 value into queue
	wire [63:0] p_x1_q;
	wire [63:0] p_x2_q;
	wire [63:0] p_info_q;
	wire [63:0] last_token_x2_q; //pushed to queue
	wire [31:0] last_mem_info_q;
	wire [63:0] k_q;
	wire [63:0] l_q;

	
	wire [31:0] cnt_a0_out,cnt_a1_out,cnt_a2_out,cnt_a3_out;
	wire [63:0] cnt_b0_out,cnt_b1_out,cnt_b2_out,cnt_b3_out;
	wire [31:0] cntl_a0_out,cntl_a1_out,cntl_a2_out,cntl_a3_out;
	wire [63:0] cntl_b0_out,cntl_b1_out,cntl_b2_out,cntl_b3_out;
	
	
	
	// part 1: load all reads
	wire load_done;
	assign read_load_done = load_done;
	
	// part 2: provide new read to pipeline	
	wire new_read;
	wire new_read_valid;
	wire [`READ_NUM_WIDTH - 1:0] new_read_num; //should be prepared before hand. every time new_read is set, next_read_num should be updated.
	wire [63:0] new_ik_x0, new_ik_x1, new_ik_x2, new_ik_info;
	wire [6:0] new_forward_i;
	wire [6:0] new_min_intv;
	
	
	//part 3: provide new query to queue
	wire [5:0] status_query_queue;
	wire [6:0] query_position_queue;
	wire [`READ_NUM_WIDTH - 1:0] query_read_num_queue;
	wire [7:0] new_read_query_RAM_read;
	
	//part 4: parameters
	wire [63:0] primary, L2_0, L2_1, L2_2, L2_3;
	wire [63:0] primary_q = primary;
	//---------------------
	wire ret_valid;
	wire [6:0] ret;
	wire [`READ_NUM_WIDTH - 1:0] ret_read_num;
	
	wire  [`READ_NUM_WIDTH - 1:0] curr_read_num_1;
	wire  curr_we_1;
	wire  [255:0] curr_data_1;
	wire  [6:0] curr_addr_1;
	
	wire  [`READ_NUM_WIDTH - 1:0] curr_read_num_1_F;
	wire  curr_we_1_F;
	wire  [255:0] curr_data_1_F;
	wire  [6:0] curr_addr_1_F;
	
	wire  [`READ_NUM_WIDTH - 1:0] curr_read_num_1_B;
	wire  curr_we_1_B;
	wire  [255:0] curr_data_1_B;
	wire  [6:0] curr_addr_1_B;
	
	wire  [`READ_NUM_WIDTH - 1:0] curr_read_num_2;
	wire  [255:0] curr_q_2;
	wire  [6:0] curr_addr_2;
	
	//-------------------------
	
	//interface for backward
	
	// mem queue, port A
	wire [`READ_NUM_WIDTH - 1:0] mem_read_num_1;
	wire mem_we_1;
	wire [255:0] mem_data_1; //[important]sequence: [p_info, p_x2, p_x1, p_x0]
	wire [6:0] mem_addr_1;
	
	//---------------------------------
	
	//mem size
	wire mem_size_valid;
	wire[6:0] mem_size;
	wire[`READ_NUM_WIDTH - 1:0] mem_size_read_num;
	
	wire DRAM_valid_F;
	wire [41:0] addr_k_F, addr_l_F;
	
	wire DRAM_valid_B;
	wire [41:0] addr_k_B, addr_l_B;
	
	reg  [`READ_NUM_WIDTH-1:0] DRAM_read_num_q;
	always@(posedge Clk_32UI) begin
		if(!stall_B) begin
			DRAM_read_num_q <= DRAM_read_num;
		end
	end
	
	assign DRAM_valid = DRAM_valid_F | DRAM_valid_B;
	assign addr_k = DRAM_valid_F ? addr_k_F : DRAM_valid_B ? addr_k_B : 0;
	assign addr_l = DRAM_valid_F ? addr_l_F : DRAM_valid_B ? addr_l_B : 0;
	assign DRAM_read_num = DRAM_valid_F ? read_num_out : DRAM_valid_B? read_num_B : DRAM_read_num_q;
	
	always@(posedge Clk_32UI) begin
		if(DRAM_valid_F && !stall_B) begin
			$display("F read num = %2d,\taddr_k = %08x\t, addr_l = %08x\n", read_num_out, addr_k_F, addr_l_F);
		end
		else if (DRAM_valid_B && !stall_B) begin
			$display("B read num = %2d,\taddr_k = %08x\t, addr_l = %08x\n", read_num_B, addr_k_B, addr_l_B);
		end
	end
	
	RAM_read ram_read(
		.reset_n(reset_n),
		.clk(Clk_32UI),
		.stall(stall_B),
		
		// part 1: load all reads
		.load_valid(load_valid),
		.load_data(load_data),
		.batch_size(batch_size),
		.load_done(load_done),
		
		// part 2: provide new read to pipeline
		.new_read(new_read), //indicate RAM to update new_read
		.new_read_valid(new_read_valid),
		.new_read_num(new_read_num), //equal to read_num
		.new_ik_x0(new_ik_x0), 
		.new_ik_x1(new_ik_x1), 
		.new_ik_x2(new_ik_x2), 
		.new_ik_info(new_ik_info),
		.new_forward_i(new_forward_i),
		.new_min_intv(new_min_intv),
		
		//part 3: provide new query to queue
		.status_query_RAM_read(status_query_queue),
		.query_position_RAM_read(query_position_queue),
		.query_read_num_RAM_read(query_read_num_queue),
		.new_read_query_RAM_read(new_read_query_RAM_read),
		
		//part 4: parameters
		.primary(primary), 
		.L2_0(L2_0), 
		.L2_1(L2_1),
		.L2_2(L2_2), 
		.L2_3(L2_3)
	);

	Datapath datapath(
		// input of BWT_extend
		.Clk_32UI(Clk_32UI),
		.reset_BWT_extend(reset_n),
		.stall(stall_C),

		//from memory
		.primary(primary), // fix value
		.L2_0(L2_0),	.L2_1(L2_1),	.L2_2(L2_2),	.L2_3(L2_3), //fix value
		
		.cnt_a0(cnt_a0_out),	.cnt_a1(cnt_a1_out),	.cnt_a2(cnt_a2_out),	.cnt_a3(cnt_a3_out),	
		.cnt_b0(cnt_b0_out),	.cnt_b1(cnt_b1_out),	.cnt_b2(cnt_b2_out),	.cnt_b3(cnt_b3_out),
		.cntl_a0(cntl_a0_out),	.cntl_a1(cntl_a1_out),	.cntl_a2(cntl_a2_out),	.cntl_a3(cntl_a3_out),
		.cntl_b0(cntl_b0_out),	.cntl_b1(cntl_b1_out),	.cntl_b2(cntl_b2_out),	.cntl_b3(cntl_b3_out),
		
		//to memory 
		.DRAM_valid(DRAM_valid_F),
		.addr_k(addr_k_F), .addr_l(addr_l_F),

		//from queue
		.status(status),
		.query(query), //only send the current query into the pipeline
		.ptr_curr(ptr_curr), // record the status of curr and mem queue
		.read_num(read_num),
		
		.ik_x0(ik_x0), .ik_x1(ik_x1), .ik_x2(ik_x2), .ik_info(ik_info),
		.forward_k_temp(forward_k_temp),
		.forward_l_temp(forward_l_temp),
		
		.forward_i(forward_i),
		.min_intv(min_intv),
		.backward_x(backward_x),
		
		//to queue
		.status_out(status_out),
		.ptr_curr_out(ptr_curr_out), // record the status of curr and mem queue
		.read_num_out(read_num_out),
		.ik_x0_out(ik_x0_out), .ik_x1_out(ik_x1_out), .ik_x2_out(ik_x2_out), .ik_info_out(ik_info_out),
		.forward_i_out(forward_i_out),
		.min_intv_out(min_intv_out),
		.backward_x_out(backward_x_out),
		
		.next_query_position(next_query_position),
		.status_query(status_query),
		.read_num_query(read_num_query),
		
		//to RAM
		.curr_read_num_1(curr_read_num_1_F),
		.curr_we_1(curr_we_1_F),
		.curr_data_1(curr_data_1_F),
		.curr_addr_1(curr_addr_1_F),	
		
		.ret_valid(ret_valid),
		.ret(ret),
		.ret_read_num(ret_read_num)
	);
	
	//backward datapath
	Backward_wrapper backward_wrapper(
		//[licheng] query request one cycle ahead
		.next_query_position_B(next_query_position_B),
		.read_num_query_B(read_num_query_B),
		.status_query_B(status_query_B),
	
		.clk(Clk_32UI),  
		.rst(reset_n),
		.stall(stall_D),
		
		     
		
		.cnt_a0_q(cnt_a0_out),
		.cnt_a1_q(cnt_a1_out),
		.cnt_a2_q(cnt_a2_out),
		.cnt_a3_q(cnt_a3_out),
		.cnt_b0_q(cnt_b0_out),
		.cnt_b1_q(cnt_b1_out),
		.cnt_b2_q(cnt_b2_out),
		.cnt_b3_q(cnt_b3_out),
		.cntl_a0_q(cntl_a0_out),         
		.cntl_a1_q(cntl_a1_out),
		.cntl_a2_q(cntl_a2_out),
		.cntl_a3_q(cntl_a3_out),
		.cntl_b0_q(cntl_b0_out),
		.cntl_b1_q(cntl_b1_out),
		.cntl_b2_q(cntl_b2_out),
		.cntl_b3_q(cntl_b3_out),
		
		//Queue -> Backward
		.ik_x0_new_q(ik_x0_new_q),
		.ik_x1_new_q(ik_x1_new_q),
		.ik_x2_new_q(ik_x2_new_q),
		.read_num_q(read_num_q),
		.forward_size_n_q(forward_size_n_q), //foward curr array size
		.min_intv_q(min_intv_q),	//
		.backward_x_q(backward_x_q), // x
		.backward_c_q(backward_c_q), // next bp
		.status_q(status_q),
		.new_size_q(new_size_q),
		.new_last_size_q(new_last_size_q),
		.primary_q(primary_q), //fix value
		.current_rd_addr_q(current_rd_addr_q),
		.current_wr_addr_q(current_wr_addr_q),
		.mem_wr_addr_q(mem_wr_addr_q),
		.backward_i_q(backward_i_q), 
		.backward_j_q(backward_j_q),
		.iteration_boundary_q(iteration_boundary_q),
		.p_x0_q(p_x0_q), // same as ik in forward datapath, store the p_x0 value into queue
		.p_x1_q(p_x1_q),
		.p_x2_q(p_x2_q),
		.p_info_q(p_info_q),
		.last_token_x2_q(last_token_x2_q), //pushed to queue
		.last_mem_info_q(last_mem_info_q),
		.k_q(k_q),
		.l_q(l_q),
		.forward_all_done(forward_all_done),
		
		//Backward -> Queue
		.status(status_B),
		.read_num(read_num_B),
		.forward_size_n(forward_size_n_B),
		.new_size(new_size_B),
		.primary(primary_B), //useless
		.new_last_size(new_last_size_B),
		.current_rd_addr(current_rd_addr_B),
		.current_wr_addr(current_wr_addr_B),
		.mem_wr_addr(mem_wr_addr_B),
		.backward_i(backward_i_B), 
		.backward_j(backward_j_B),
		.output_c(output_c_B),
		.min_intv(min_intv_B),
		.iteration_boundary(iteration_boundary_B),
		.backward_k(backward_k_B),
		.backward_l(backward_l_B), // backward_k == k, backward_l==l;
		.p_x0(p_x0_B),
		.p_x1(p_x1_B),
		.p_x2(p_x2_B),
		.p_info(p_info_B),
		.reserved_token_x2(reserved_token_x2_B), //reserved_token_x2 => last_token_x2_q
		.reserved_mem_info(reserved_mem_info_B), //reserved_mem_info => last_mem_info_q
		
		//================================================
		.curr_read_num_2(curr_read_num_2),
		.curr_addr_2(curr_addr_2),
		.curr_q_2(curr_q_2),
		
		//read and write all from control stage 1
		//write to curr/mem array
		
		.mem_read_num_1(mem_read_num_1),
		.mem_we_1(mem_we_1),
		.mem_data_1(mem_data_1),
		.mem_addr_1(mem_addr_1),
		
		.curr_read_num_1(curr_read_num_1_B),
		.curr_we_1(curr_we_1_B),
		.curr_data_1(curr_data_1_B),
		.curr_addr_1(curr_addr_1_B),

		//================================================
		//output for memory request 
		.request_valid(DRAM_valid_B),
		.addr_k(addr_k_B),
		.addr_l(addr_l_B),

		//outputing finish_sign+read_num+mem_size to another module
		.finish_sign(mem_size_valid), //read_num on line 88
		.mem_size(mem_size),
		.mem_size_read_num(mem_size_read_num) //[licheng add]
		
		
	);
	
	always@(posedge Clk_32UI) begin
		if(!stall_B) begin
			if(mem_size_valid) begin
				$display("read %2d push mem size = %d", mem_size_read_num, mem_size);
			end
			
			if(mem_we_1) begin
				$display("read %d push mem", mem_read_num_1);
				$display("mem.x[0] = %08x\t", mem_data_1[63:0]);
				$display("mem.x[1] = %08x\t", mem_data_1[127:64]);
				$display("mem.x[2] = %08x\t", mem_data_1[191:128]);
				$display("mem.info = %08x\t", mem_data_1[255:192]);
			end
			
			// if(curr_we_1_B) begin
				// $display("read %d backward push curr", curr_read_num_1_B);
				// $display("curr.x[0] = %08x\t", curr_data_1_B[63:0]);
				// $display("curr.x[1] = %08x\t", curr_data_1_B[127:64]);
				// $display("curr.x[2] = %08x\t", curr_data_1_B[191:128]);
				// $display("curr.info = %08x\t", curr_data_1_B[255:192]);
			// end
			
			// if(curr_we_1_F) begin
				// $display("read %d forward push curr", curr_read_num_1_F);
				// $display("curr.x[0] = %08x\t", curr_data_1_F[63:0]);
				// $display("curr.x[1] = %08x\t", curr_data_1_F[127:64]);
				// $display("curr.x[2] = %08x\t", curr_data_1_F[191:128]);
				// $display("curr.info = %08x\t", curr_data_1_F[255:192]);
			// end
		end
	end
	
	
	
	Queue queue(
		//debugging
		.num_reads_inqueue(num_reads_inqueue),

		.next_query_position_B(next_query_position_B),
		.read_num_query_B(read_num_query_B),
		.status_query_B(status_query_B),
		
		.next_query_position(next_query_position),
		.read_num_query(read_num_query),
		.status_query(status_query),
		
		.Clk_32UI(Clk_32UI),
		.reset_n(reset_n),
		.stall(stall_E),
		
		.DRAM_get(DRAM_get),
		.cnt_a0           (cnt_a0),		.cnt_a1           (cnt_a1),
		.cnt_a2           (cnt_a2),		.cnt_a3           (cnt_a3),
		.cnt_b0           (cnt_b0),		.cnt_b1           (cnt_b1),
		.cnt_b2           (cnt_b2),		.cnt_b3           (cnt_b3),
		.cntl_a0          (cntl_a0),	.cntl_a1          (cntl_a1),
		.cntl_a2          (cntl_a2),	.cntl_a3          (cntl_a3),
		.cntl_b0          (cntl_b0),	.cntl_b1          (cntl_b1),
		.cntl_b2          (cntl_b2),	.cntl_b3          (cntl_b3),
		
		.cnt_a0_out_q           (cnt_a0_out),		.cnt_a1_out_q           (cnt_a1_out),
		.cnt_a2_out_q           (cnt_a2_out),		.cnt_a3_out_q           (cnt_a3_out),
		.cnt_b0_out_q           (cnt_b0_out),		.cnt_b1_out_q           (cnt_b1_out),
		.cnt_b2_out_q           (cnt_b2_out),		.cnt_b3_out_q           (cnt_b3_out),
		.cntl_a0_out_q          (cntl_a0_out),	.cntl_a1_out_q          (cntl_a1_out),
		.cntl_a2_out_q          (cntl_a2_out),	.cntl_a3_out_q          (cntl_a3_out),
		.cntl_b0_out_q          (cntl_b0_out),	.cntl_b1_out_q          (cntl_b1_out),
		.cntl_b2_out_q          (cntl_b2_out),	.cntl_b3_out_q          (cntl_b3_out),
		
		//-------------------------------------------------
		
		//forward to queue
		.status(status_out),
		.ptr_curr(ptr_curr_out), // record the status of curr and mem queue
		.read_num(read_num_out),
		.ik_x0(ik_x0_out), .ik_x1(ik_x1_out), .ik_x2(ik_x2_out), .ik_info(ik_info_out),
		.forward_i(forward_i_out),
		.min_intv(min_intv_out),
		.backward_x(backward_x_out),
		

		
		//queue to forward
		.status_out_q(status),
		.ptr_curr_out_q(ptr_curr), // record the status of curr and mem queue
		.read_num_out_q(read_num),
		.ik_x0_out_q(ik_x0), .ik_x1_out_q(ik_x1), .ik_x2_out_q(ik_x2), .ik_info_out_q(ik_info),
		.forward_k_temp_q(forward_k_temp),
		.forward_l_temp_q(forward_l_temp),
		
		.forward_i_out_q(forward_i),
		.min_intv_out_q(min_intv),
		.backward_x_out_q(backward_x),
		.query_out_q(query),
		
		//-------------------------------------------------
		
		//backward to queue
		.forward_size_n_B(forward_size_n_B),	
		.read_num_B(read_num_B),
		.min_intv_B(min_intv_B),
		.status_B(status_B),
		.new_size_B(new_size_B),
		.new_last_size_B(new_last_size_B),
		.primary_B(primary_B),
		.current_rd_addr_B(current_rd_addr_B),
		.current_wr_addr_B(current_wr_addr_B),
		.mem_wr_addr_B(mem_wr_addr_B),
		.backward_i_B(backward_i_B), 
		.backward_j_B(backward_j_B),
		.iteration_boundary_B(iteration_boundary_B),
		.p_x0_B(p_x0_B),
		.p_x1_B(p_x1_B),
		.p_x2_B(p_x2_B),
		.p_info_B(p_info_B),
		.reserved_token_x2_B(reserved_token_x2_B), //reserved_token_x2 => last_token_x2_q
		.reserved_mem_info_B(reserved_mem_info_B), //reserved_mem_info => last_mem_info_q
		.backward_k_B(backward_k_B),
		.backward_l_B(backward_l_B), // backward_k == k, backward_l==l;		
		.output_c_B(output_c_B), // address for next query
		
		//queue -> backward
		//backward data required
		.ik_x0_new_q_q			(ik_x0_new_q),
		.ik_x1_new_q_q			(ik_x1_new_q),
		.ik_x2_new_q_q			(ik_x2_new_q),
		.backward_x_q_q			(backward_x_q), // x
		.backward_c_q_q			(backward_c_q), // next bp
		.forward_all_done_q		(forward_all_done),
		.forward_size_n_q_q		(forward_size_n_q), //foward curr array size	
		.read_num_q_q				(read_num_q),
		.min_intv_q_q				(min_intv_q),	//
		.status_q_q				(status_q),
		.new_size_q_q				(new_size_q),
		.new_last_size_q_q		(new_last_size_q),
		.primary_q_q				(),//useless
		.current_rd_addr_q_q		(current_rd_addr_q),
		.current_wr_addr_q_q		(current_wr_addr_q),
		.mem_wr_addr_q_q			(mem_wr_addr_q),
		.backward_i_q_q			(backward_i_q), 
		.backward_j_q_q			(backward_j_q),
		.iteration_boundary_q_q	(iteration_boundary_q),
		.p_x0_q_q					(p_x0_q), // same as ik in forward datapath, store the p_x0 value into queue
		.p_x1_q_q					(p_x1_q),
		.p_x2_q_q					(p_x2_q),
		.p_info_q_q				(p_info_q),
		.last_token_x2_q_q		(last_token_x2_q), //pushed to queue
		.last_mem_info_q_q		(last_mem_info_q),
		.k_q_q					(k_q),
		.l_q_q					(l_q),
		
		//-------------------------------------------------
		
		//interaction with RAM
		
		//fetch new read at the end of queue
		.new_read(new_read),
		.new_read_valid(new_read_valid),
		.load_done(load_done),
		
		.new_read_num(new_read_num), //should be prepared before hand. every time new_read is set, next_read_num should be updated.
		.new_ik_x0(new_ik_x0), .new_ik_x1(new_ik_x1), .new_ik_x2(new_ik_x2), .new_ik_info(new_ik_info),
		.new_forward_i(new_forward_i),
		.new_min_intv(new_min_intv),
		
		//fetch new query at the start of queue
		.query_position_2RAM(query_position_queue),
		.query_read_num_2RAM(query_read_num_queue),
		.query_status_2RAM(status_query_queue),
		.new_read_query_2Queue(new_read_query_RAM_read)
	);
	
	assign curr_we_1 		= curr_we_1_F | curr_we_1_B ;

	assign curr_read_num_1 	= curr_we_1_F ? curr_read_num_1_F 	: curr_we_1_B ? curr_read_num_1_B 	: 0;
	assign curr_data_1		= curr_we_1_F ? curr_data_1_F 		: curr_we_1_B ? curr_data_1_B 		: 0;
	assign curr_addr_1 		= curr_we_1_F ? curr_addr_1_F 		: curr_we_1_B ? curr_addr_1_B 		: 0;
	
	RAM_curr_mem ram_curr_mem(
		.reset_n(reset_n),
		.clk(Clk_32UI),
		.stall(stall_F),
		.batch_size(batch_size),
		
		// curr queue, port A
		.curr_read_num_1(curr_read_num_1),
		.curr_we_1(curr_we_1),
		.curr_data_1(curr_data_1), //[important]sequence: [ik_info, ik_x2, ik_x1, ik_x0]
		.curr_addr_1(curr_addr_1),
		
		// curr queue, port B
		.curr_read_num_2(curr_read_num_2),
		.curr_addr_2(curr_addr_2),
		.curr_q_2(curr_q_2),
		
		//--------------------------------
		
		// mem queue, port A
		.mem_read_num_1(mem_read_num_1),
		.mem_we_1(mem_we_1),
		.mem_data_1(mem_data_1), //[important]sequence: [p_info, p_x2, p_x1, p_x0]
		.mem_addr_1(mem_addr_1),
		
		//---------------------------------
		
		//mem size
		.done_counter(done_counter),
		.mem_size_valid(mem_size_valid),
		.mem_size(mem_size),
		.mem_size_read_num(mem_size_read_num),
		
		//ret
		.ret_valid(ret_valid),
		.ret(ret),
		.ret_read_num(ret_read_num),
		
		//---------------------------------
		
		//output module
		.output_request(output_request),
		.output_permit(output_permit),
		.output_data(output_data),
		.output_valid(output_valid),
		.output_finish(output_finish)

	);
	
	
	assign backward_i_q_test = backward_i_q;
    assign backward_j_q_test = backward_j_q;
	
endmodule
