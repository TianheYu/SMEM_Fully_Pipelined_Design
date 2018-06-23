`define CL 512
`define MAX_READ 1024
`define READ_NUM_WIDTH 10

module Backward_wrapper(
	input clk,  
	input rst,
	input stall,
	
	input forward_all_done,     
	input [63:0] k_q,
	input [63:0] l_q,
	input [31:0] cnt_a0_q,
	input [31:0] cnt_a1_q,
	input [31:0] cnt_a2_q,
	input [31:0] cnt_a3_q,
	input [63:0] cnt_b0_q,
	input [63:0] cnt_b1_q,
	input [63:0] cnt_b2_q,
	input [63:0] cnt_b3_q,
	input [31:0] cntl_a0_q,         
	input [31:0] cntl_a1_q,
	input [31:0] cntl_a2_q,
	input [31:0] cntl_a3_q,
	input [63:0] cntl_b0_q,
	input [63:0] cntl_b1_q,
	input [63:0] cntl_b2_q,
	input [63:0] cntl_b3_q,
	
	//backward data required
	input [63:0] ik_x0_new_q,
	input [63:0] ik_x1_new_q,
	input [63:0] ik_x2_new_q,
	input [`READ_NUM_WIDTH - 1:0] read_num_q,
	input [6:0] forward_size_n_q, //foward curr array size
	input [6:0] min_intv_q,	//
	input [6:0] backward_x_q, // x
	input [7:0] backward_c_q, // next bp
	
	//backward data only.
	input [5:0] status_q,
	input [6:0] new_size_q,
	input [6:0] new_last_size_q,
	input [63:0] primary_q,
	input [6:0] current_rd_addr_q,
	input [6:0] current_wr_addr_q,
	input [6:0] mem_wr_addr_q,
	input [6:0] backward_i_q, 
	input [6:0] backward_j_q,
	input iteration_boundary_q,
	input [63:0] p_x0_q, // same as ik in forward datapath, store the p_x0 value into queue
	input [63:0] p_x1_q,
	input [63:0] p_x2_q,
	input [63:0] p_info_q,
	input [63:0] last_token_x2_q, //pushed to queue
	input [31:0] last_mem_info_q,
	
	//output to queue
	output [5:0] status,
	output [`READ_NUM_WIDTH - 1:0] read_num,
	output [6:0] forward_size_n,
	output [6:0] new_size,
	output [63:0] primary,
	output [6:0] new_last_size,
	output [6:0] current_rd_addr,
	output [6:0] current_wr_addr,mem_wr_addr,
	output [6:0] backward_i, backward_j,
	output [7:0] output_c,
	output [6:0] min_intv,
	output iteration_boundary,
	output [63:0] backward_k,backward_l, // backward_k == k, backward_l==l;
	output [63:0] p_x0,p_x1,p_x2,p_info,
	output [63:0]	reserved_token_x2, //reserved_token_x2 => last_token_x2_q
	output [31:0]	reserved_mem_info, //reserved_mem_info => last_mem_info_q
	
	output [5:0] status_query_B,
	output [`READ_NUM_WIDTH - 1:0] read_num_query_B,
	output [6:0] next_query_position_B,
	
	//================================================
	output [`READ_NUM_WIDTH - 1:0] curr_read_num_2,
	output [6:0] curr_addr_2,
	input [255:0] curr_q_2,
	
	//read and write all from control stage 1
	//write to curr/mem array
	
	output [`READ_NUM_WIDTH - 1:0] mem_read_num_1,
	output mem_we_1,
	output [255:0] mem_data_1,
	output [6:0] mem_addr_1,
	
	output [`READ_NUM_WIDTH - 1:0] curr_read_num_1,
	output curr_we_1,
	output [255:0] curr_data_1,
	output [6:0] curr_addr_1,

	//================================================
	//output for memory request 
	output request_valid,
	output [41:0] addr_k,addr_l,

	//outputing finish_sign+read_num+mem_size to another module
	output finish_sign, //read_num on line 88
	output [6:0] mem_size,
	output [`READ_NUM_WIDTH - 1:0] mem_size_read_num //[licheng add]
	
	
);	
	parameter Len = 101;
	
	parameter F_init = 	6'b00_0001; // F_init will disable the forward pipeline
	parameter F_run =  	6'b00_0010;
	parameter F_break = 6'b00_0100;
	parameter BCK_INI = 6'b00_1000;	//100
	parameter BCK_RUN = 6'b01_0000;	//101
	parameter BCK_END = 6'b10_0000;	//110
	parameter BUBBLE = 	6'b00_0000;

	reg forward_all_done_L0;
     
	reg [63:0] k_q_L0;
	reg [63:0] l_q_L0;
	reg [31:0] cnt_a0_q_L0;
	reg [31:0] cnt_a1_q_L0;
	reg [31:0] cnt_a2_q_L0;
	reg [31:0] cnt_a3_q_L0;
	reg [63:0] cnt_b0_q_L0;
	reg [63:0] cnt_b1_q_L0;
	reg [63:0] cnt_b2_q_L0;
	reg [63:0] cnt_b3_q_L0;
	reg [31:0] cntl_a0_q_L0;         
	reg [31:0] cntl_a1_q_L0;
	reg [31:0] cntl_a2_q_L0;
	reg [31:0] cntl_a3_q_L0;
	reg [63:0] cntl_b0_q_L0;
	reg [63:0] cntl_b1_q_L0;
	reg [63:0] cntl_b2_q_L0;
	reg [63:0] cntl_b3_q_L0;
	//forward bwt_input
	reg [63:0] ik_x0_new_q_L0;
	reg [63:0] ik_x1_new_q_L0;
	reg [63:0] ik_x2_new_q_L0;

	//backward data required
	reg [`READ_NUM_WIDTH - 1:0] read_num_q_L0;
	reg [6:0] forward_size_n_q_L0; //foward curr array size
	reg [6:0] min_intv_q_L0;	//
	reg [6:0] backward_x_q_L0; // x
	reg [7:0] backward_c_q_L0; // next bp
	
	//backward data only./////////////////////////////////////////////////
	reg [5:0] status_q_L0;
	reg [6:0] new_size_q_L0;
	reg [6:0] new_last_size_q_L0;
	reg [63:0] primary_q_L0;
	reg [6:0] current_rd_addr_q_L0;
	reg [6:0] current_wr_addr_q_L0;
	reg [6:0] mem_wr_addr_q_L0;
	reg [6:0] backward_i_q_L0; 
	reg [6:0] backward_j_q_L0;
	reg iteration_boundary_q_L0;
	reg [63:0] p_x0_q_L0; // same as ik in forward datapath_L0; store the p_x0 value into queue
	reg [63:0] p_x1_q_L0;
	reg [63:0] p_x2_q_L0;
	reg [63:0] p_info_q_L0;
	reg [63:0] last_token_x2_q_L0; //pushed to queue
	reg [31:0] last_mem_info_q_L0;

	//delay one cycle in the beginning
	always@(posedge clk) begin
		if(!rst) begin 
		
			forward_all_done_L0 <= 0;
			k_q_L0 <= 0;
			l_q_L0 <= 0;
			cnt_a0_q_L0 <= 0;
			cnt_a1_q_L0 <= 0;
			cnt_a2_q_L0 <= 0;
			cnt_a3_q_L0 <= 0;
			cnt_b0_q_L0 <= 0;
			cnt_b1_q_L0 <= 0;
			cnt_b2_q_L0 <= 0;
			cnt_b3_q_L0 <= 0;
			cntl_a0_q_L0 <= 0;         
			cntl_a1_q_L0 <= 0;
			cntl_a2_q_L0 <= 0;
			cntl_a3_q_L0 <= 0;
			cntl_b0_q_L0 <= 0;
			cntl_b1_q_L0 <= 0;
			cntl_b2_q_L0 <= 0;
			cntl_b3_q_L0 <= 0;
			//forward bwt_input
			ik_x0_new_q_L0 <= 0;
			ik_x1_new_q_L0 <= 0;
			ik_x2_new_q_L0 <= 0;

			//backward data required
			read_num_q_L0 <= 0;
			forward_size_n_q_L0 <= 0; //foward curr array size
			min_intv_q_L0 <= 0;	//
			backward_x_q_L0 <= 0; // x
			backward_c_q_L0 <= 0; // next bp

			//backward data only./////////////////////////////////////////////////
			status_q_L0 <= BUBBLE;
			new_size_q_L0 <= 0;
			new_last_size_q_L0 <= 0;
			primary_q_L0 <= 0;
			current_rd_addr_q_L0 <= 0;
			current_wr_addr_q_L0 <= 0;
			mem_wr_addr_q_L0 <= 0;
			backward_i_q_L0 <= 0; 
			backward_j_q_L0 <= 0;
			iteration_boundary_q_L0 <= 0;
			p_x0_q_L0 <= 0; // same as ik in forward datapath_L0; store the p_x0 value into queue
			p_x1_q_L0 <= 0;
			p_x2_q_L0 <= 0;
			p_info_q_L0 <= 0;
			last_token_x2_q_L0 <= 0; //pushed to queue
			last_mem_info_q_L0 <= 0;
	
		end
		else if (!stall) begin
			forward_all_done_L0 <= forward_all_done;
			k_q_L0 <= k_q;
			l_q_L0 <= l_q;
			cnt_a0_q_L0 <= cnt_a0_q;
			cnt_a1_q_L0 <= cnt_a1_q;
			cnt_a2_q_L0 <= cnt_a2_q;
			cnt_a3_q_L0 <= cnt_a3_q;
			cnt_b0_q_L0 <= cnt_b0_q;
			cnt_b1_q_L0 <= cnt_b1_q;
			cnt_b2_q_L0 <= cnt_b2_q;
			cnt_b3_q_L0 <= cnt_b3_q;
			cntl_a0_q_L0 <= cntl_a0_q;         
			cntl_a1_q_L0 <= cntl_a1_q;
			cntl_a2_q_L0 <= cntl_a2_q;
			cntl_a3_q_L0 <= cntl_a3_q;
			cntl_b0_q_L0 <= cntl_b0_q;
			cntl_b1_q_L0 <= cntl_b1_q;
			cntl_b2_q_L0 <= cntl_b2_q;
			cntl_b3_q_L0 <= cntl_b3_q;
			//forward bwt_input
			ik_x0_new_q_L0 <= ik_x0_new_q;
			ik_x1_new_q_L0 <= ik_x1_new_q;
			ik_x2_new_q_L0 <= ik_x2_new_q;

			//backward data required
			read_num_q_L0 <= read_num_q;
			forward_size_n_q_L0 <= forward_size_n_q; //foward curr array size
			min_intv_q_L0 <= min_intv_q;	//
			backward_x_q_L0 <= backward_x_q; // x
			backward_c_q_L0 <= backward_c_q; // next bp

			//backward data only./////////////////////////////////////////////////
			status_q_L0 <= status_q;
			new_size_q_L0 <= new_size_q;
			new_last_size_q_L0 <= new_last_size_q;
			primary_q_L0 <= primary_q;
			current_rd_addr_q_L0 <= current_rd_addr_q;
			current_wr_addr_q_L0 <= current_wr_addr_q;
			mem_wr_addr_q_L0 <= mem_wr_addr_q;
			backward_i_q_L0 <= backward_i_q; 
			backward_j_q_L0 <= backward_j_q;
			iteration_boundary_q_L0 <= iteration_boundary_q;
			p_x0_q_L0 <= p_x0_q; // same as ik in forward datapath_L0; store the p_x0 value into queue
			p_x1_q_L0 <= p_x1_q;
			p_x2_q_L0 <= p_x2_q;
			p_info_q_L0 <= p_info_q;
			last_token_x2_q_L0 <= last_token_x2_q; //pushed to queue
			last_mem_info_q_L0 <= last_mem_info_q;		
		end
	end 

	//output
	wire [`READ_NUM_WIDTH - 1:0] read_num_store_1;
	wire store_valid_mem;
	wire [63:0] mem_x_0;
	wire [63:0] mem_x_1;
	wire [63:0] mem_x_2;
	wire [63:0] mem_x_info;
	wire [6:0] mem_x_addr;
	
	//output
	wire store_valid_curr;
	wire  [63:0] curr_x_0;
	wire [63:0] curr_x_1;
	wire [63:0] curr_x_2;
	wire [63:0] curr_x_info;
	wire [6:0] curr_x_addr;
	
	//organized interface for mem write
	assign mem_read_num_1 = read_num_store_1;
	assign mem_we_1 = store_valid_mem;
	assign mem_data_1 = {mem_x_info, mem_x_2, mem_x_1, mem_x_0}; //[important] sequence matters!
	assign mem_addr_1 = mem_x_addr;
	
	//organized interface for curr port 1 (write)
	assign curr_read_num_1 = read_num_store_1;
	assign curr_we_1 = store_valid_curr;
	assign curr_data_1 = {curr_x_info, curr_x_2, curr_x_1, curr_x_0};
	assign curr_addr_1 = curr_x_addr;
	
	//output
	wire [`READ_NUM_WIDTH - 1:0] read_num_2;
	wire [6:0] current_rd_addr_2;
	//input
	wire [63:0] p_x0_q_S3_q; //curr array output data
	wire [63:0] p_x1_q_S3_q;
	wire [63:0] p_x2_q_S3_q;
	wire [63:0] p_info_q_S3_q;
	
	//organized interface for curr port 2 (read)
	assign {p_info_q_S3_q, p_x2_q_S3_q, p_x1_q_S3_q, p_x0_q_S3_q} = curr_q_2;
	assign curr_addr_2 = current_rd_addr_2;
	assign curr_read_num_2 = read_num_2;
	
	//organized interface for mem_size
	assign mem_size_read_num = read_num;
	
	
	Backward_data_path backward_datapath(
		//[licheng] query request one cycle ahead
		.next_query_position_B(next_query_position_B),
		.read_num_query_B(read_num_query_B),
		.status_query_B(status_query_B),
	
		.clk				(clk),  
		.rst				(rst),
		.stall				(stall),
		.forward_all_done	(forward_all_done_L0),
		 
		.k_q				(k_q_L0),
		.l_q				(l_q_L0),
		.cnt_a0_q			(cnt_a0_q_L0),
		.cnt_a1_q			(cnt_a1_q_L0),
		.cnt_a2_q			(cnt_a2_q_L0),
		.cnt_a3_q			(cnt_a3_q_L0),
		.cnt_b0_q			(cnt_b0_q_L0),
		.cnt_b1_q			(cnt_b1_q_L0),
		.cnt_b2_q			(cnt_b2_q_L0),
		.cnt_b3_q			(cnt_b3_q_L0),
		.cntl_a0_q			(cntl_a0_q_L0),         
		.cntl_a1_q			(cntl_a1_q_L0),
		.cntl_a2_q			(cntl_a2_q_L0),
		.cntl_a3_q			(cntl_a3_q_L0),
		.cntl_b0_q			(cntl_b0_q_L0),
		.cntl_b1_q			(cntl_b1_q_L0),
		.cntl_b2_q			(cntl_b2_q_L0),
		.cntl_b3_q			(cntl_b3_q_L0),
		//forward bwt_input
		.ik_x0_new_q		(ik_x0_new_q_L0),
		.ik_x1_new_q		(ik_x1_new_q_L0),
		.ik_x2_new_q		(ik_x2_new_q_L0),

		//backward data required
		.read_num_q			(read_num_q_L0),
		.forward_size_n_q	(forward_size_n_q_L0), //foward curr array size
		.min_intv_q			(min_intv_q_L0),	//
		.backward_x_q		(backward_x_q_L0), // x
		.backward_c_q		(backward_c_q_L0), // next bp
		
		//backward data only./////////////////////////////////////////////////
		.status_q			(status_q_L0),
		.new_size_q			(new_size_q_L0),
		.new_last_size_q	(new_last_size_q_L0),
		.primary_q			(primary_q_L0),
		.current_rd_addr_q	(current_rd_addr_q_L0),
		.current_wr_addr_q	(current_wr_addr_q_L0),
		.mem_wr_addr_q		(mem_wr_addr_q_L0),
		.backward_i_q		(backward_i_q_L0), 
		.backward_j_q		(backward_j_q_L0),
		.iteration_boundary_q(iteration_boundary_q_L0),
		.p_x0_q				(p_x0_q_L0), // same as ik in forward datapath, store the p_x0 value into queue
		.p_x1_q				(p_x1_q_L0),
		.p_x2_q				(p_x2_q_L0),
		.p_info_q			(p_info_q_L0),
		.last_token_x2_q	(last_token_x2_q_L0), //pushed to queue
		.last_mem_info_q	(last_mem_info_q_L0),
		
		/////////////////////////////stage3 input///////////////////////////
		.p_x0_q_S3_q		(p_x0_q_S3_q), //curr array output data
		.p_x1_q_S3_q		(p_x1_q_S3_q),
		.p_x2_q_S3_q		(p_x2_q_S3_q),
		.p_info_q_S3_q		(p_info_q_S3_q),
	///////////////////////////////////////////////////////////////////////////////////////////////////
	///read and write all from control stage 1

		//write to curr/mem array
		.read_num_store_1	(read_num_store_1),
		.store_valid_mem	(store_valid_mem),
		.mem_x_0			(mem_x_0),
		.mem_x_1			(mem_x_1),
		.mem_x_2			(mem_x_2),
		.mem_x_info			(mem_x_info),
		.mem_x_addr			(mem_x_addr),

		.store_valid_curr	(store_valid_curr),
		.curr_x_0			(curr_x_0),
		.curr_x_1			(curr_x_1),
		.curr_x_2			(curr_x_2),
		.curr_x_info		(curr_x_info),
		.curr_x_addr		(curr_x_addr),

	///////////////////////////////////////////////////////////////
		//stage 1 output					//read from curr array
		.read_num_2			(read_num_2),
		.current_rd_addr_2	(current_rd_addr_2),
	////////////////////////////////////////////////////////////////

		//output to queue
		.read_num			(read_num),
		.forward_size_n		(forward_size_n),
		.new_size			(new_size),
		.primary			(primary),
		.new_last_size		(new_last_size),
		.current_rd_addr	(current_rd_addr),
		.current_wr_addr	(current_wr_addr),
		.mem_wr_addr		(mem_wr_addr),
		.backward_i			(backward_i), 
		.backward_j			(backward_j),
		.output_c			(output_c),
		.min_intv			(min_intv),
		.iteration_boundary	(iteration_boundary),

		//output to bwt_extend but not used in control logic
		.backward_k			(backward_k),
		.backward_l			(backward_l), // backward_k == k, backward_l==l;
		.p_x0				(p_x0),
		.p_x1				(p_x1),
		.p_x2				(p_x2),
		.p_info				(p_info),
		.reserved_token_x2	(reserved_token_x2), //reserved_token_x2 => last_token_x2_q
		.reserved_mem_info	(reserved_mem_info), //reserved_mem_info => last_mem_info_q
		
	///////////output for memory request ///////////////
		.request_valid		(request_valid),
		.addr_k				(addr_k),
		.addr_l				(addr_l),
	/////////////////////////////////////////////////

	//outputing finish_sign+read_num+mem_size to another module
		.finish_sign		(finish_sign), //read_num on line 88
		.mem_size			(mem_size),
		.status				(status)
	);


endmodule