`define CL 512
`define MAX_READ 1024
`define READ_NUM_WIDTH 10

module Backward_data_path(
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
	//forward bwt_input
	input [63:0] ik_x0_new_q,
	input [63:0] ik_x1_new_q,
	input [63:0] ik_x2_new_q,

	//backward data required
	input [`READ_NUM_WIDTH - 1:0] read_num_q,
	input [6:0] forward_size_n_q, //foward curr array size
	input [6:0] min_intv_q,	//
	input [6:0] backward_x_q, // x
	input [7:0] backward_c_q, // next bp
	
	//backward data only./////////////////////////////////////////////////
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
	
	/////////////////////////////stage3 input///////////////////////////
	input [63:0] p_x0_q_S3_q, //curr array output data
	input [63:0] p_x1_q_S3_q,
	input [63:0] p_x2_q_S3_q,
	input [63:0] p_info_q_S3_q,
///////////////////////////////////////////////////////////////////////////////////////////////////
///read and write all from control stage 1

	//write to curr/mem array
	output [`READ_NUM_WIDTH - 1:0] read_num_store_1,
	output store_valid_mem,
	output [63:0] mem_x_0,
	output [63:0] mem_x_1,
	output [63:0] mem_x_2,
	output [63:0] mem_x_info,
	output [6:0] mem_x_addr,

	output store_valid_curr,
	output  [63:0] curr_x_0,
	output [63:0] curr_x_1,
	output [63:0] curr_x_2,
	output [63:0] curr_x_info,
	output [6:0] curr_x_addr,

///////////////////////////////////////////////////////////////
	//stage 1 output					//read from curr array
	output [`READ_NUM_WIDTH - 1:0] read_num_2,
	output [6:0] current_rd_addr_2,
////////////////////////////////////////////////////////////////

	output [5:0] status_query_B,
	output [`READ_NUM_WIDTH - 1:0] read_num_query_B,
	output [6:0] next_query_position_B,
	
	//output to queue
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

	//output to bwt_extend but not used in control logic
	output [63:0] backward_k,backward_l, // backward_k == k, backward_l==l;
	output [63:0] p_x0,p_x1,p_x2,p_info,
	output [63:0]	reserved_token_x2, //reserved_token_x2 => last_token_x2_q
	output [31:0]	reserved_mem_info, //reserved_mem_info => last_mem_info_q
	
///////////output for memory request ///////////////
	output request_valid,
	output [41:0] addr_k,addr_l,
/////////////////////////////////////////////////

//outputing finish_sign+read_num+mem_size to another module
	output finish_sign, //read_num on line 88
	output [6:0] mem_size,
	output [5:0] status
);
	parameter Len = 101;
	
	parameter F_init = 	6'b00_0001; // F_init will disable the forward pipeline
	parameter F_run =  	6'b00_0010;
	parameter F_break = 6'b00_0100;
	parameter BCK_INI = 6'b00_1000;	//100
	parameter BCK_RUN = 6'b01_0000;	//101
	parameter BCK_END = 6'b10_0000;	//110
	parameter BUBBLE = 	6'b00_0000;

	reg [5:0] status_BB;wire [5:0] status_B1;
	reg [63:0] ik_x0_new,ik_x1_new,ik_x2_new;
	wire [6:0] backward_x_B1;
	reg [31:0] cnt_a0,cnt_a1,cnt_a2,cnt_a3;
	reg [63:0] cnt_b0,cnt_b1,cnt_b2,cnt_b3;
	reg [31:0] cntl_a0,cntl_a1,cntl_a2,cntl_a3;
	reg [63:0] cntl_b0,cntl_b1,cntl_b2,cntl_b3;

	wire [`READ_NUM_WIDTH - 1:0] read_num_B1;
	wire [63:0] ok0_x0_B1, ok0_x1_B1, ok0_x2_B1;
	wire [63:0] ok1_x0_B1, ok1_x1_B1, ok1_x2_B1;
	wire [63:0] ok2_x0_B1, ok2_x1_B1, ok2_x2_B1;
	wire [63:0] ok3_x0_B1, ok3_x1_B1, ok3_x2_B1;
	wire [63:0] p_x0_B1,p_x1_B1,p_x2_B1,p_info_B1;
	wire [6:0] min_intv_B1;
	wire iteration_boundary_B1;
	wire [6:0] backward_i_B1,backward_j_B1;
	wire [6:0] current_wr_addr_B1,current_rd_addr_B1,mem_wr_addr_B1;

	wire [6:0] new_size_B1;
	wire [6:0] new_last_size_B1;
	wire [6:0] forward_size_n_B1;
	wire BWT_extend_done_B1;

	wire [63:0] primary_B1;
	wire [31:0] last_mem_info_B1;
	wire [63:0] last_token_x2_B1;
	wire [7:0] output_c_B1;
	
	wire [63:0] ok_b_temp_x0_B1,ok_b_temp_x1_B1,ok_b_temp_x2_B1;


BWT_extend_lc	BWT_ext_lc(
	.Clk_32UI         (clk),  
	.reset_BWT_extend (rst),
	.stall			(stall),
	.forward_all_done (forward_all_done),
     
	.k                (k_q),
	.l                (l_q),
	.cnt_a0           (cnt_a0_q),
	.cnt_a1           (cnt_a1_q),
	.cnt_a2           (cnt_a2_q),
	.cnt_a3           (cnt_a3_q),
	.cnt_b0           (cnt_b0_q),
	.cnt_b1           (cnt_b1_q),
	.cnt_b2           (cnt_b2_q),
	.cnt_b3           (cnt_b3_q),
	.cntl_a0          (cntl_a0_q),         
	.cntl_a1          (cntl_a1_q),
	.cntl_a2          (cntl_a2_q),
	.cntl_a3          (cntl_a3_q),
	.cntl_b0          (cntl_b0_q),
	.cntl_b1          (cntl_b1_q),
	.cntl_b2          (cntl_b2_q),
	.cntl_b3          (cntl_b3_q),
	.ik_x0            (ik_x0_new_q),
	.ik_x1            (ik_x1_new_q),
	.ik_x2            (ik_x2_new_q),
	.read_num_q (read_num_q),
	.status_q(status_q),
	.forward_size_n_q(forward_size_n_q),
	.new_size_q(new_size_q),
	.new_last_size_q(new_last_size_q),
	.primary_q(primary_q),
	.current_rd_addr_q(current_rd_addr_q),
	.current_wr_addr_q(current_wr_addr_q),.mem_wr_addr_q(mem_wr_addr_q),
	.backward_i_q(backward_i_q), .backward_j_q(backward_j_q),
	.output_c_q(backward_c_q),
	.min_intv_q(min_intv_q),
	.iteration_boundary_q(iteration_boundary_q),
	.p_x0_q(p_x0_q),.p_x1_q(p_x1_q),
	.p_x2_q(p_x2_q),.p_info_q(p_info_q),
	.reserved_token_x2(last_token_x2_q),
	.reserved_mem_info(last_mem_info_q),
	.backward_x_q(backward_x_q),
	//////////////////////////////////////////////////////////////////////////////
	.p_x0(p_x0_B1),.p_x1(p_x1_B1),
	.p_x2(p_x2_B1),.p_info(p_info_B1),
	
	//added output registered signals
	.read_num(read_num_B1),
	.status(status_B1),
	.forward_size_n(forward_size_n_B1),
	.new_size(new_size_B1),
	.new_last_size(new_last_size_B1),
	.primary(primary_B1),

	.current_wr_addr(current_wr_addr_B1),
	.current_rd_addr(current_rd_addr_B1),
	.mem_wr_addr(mem_wr_addr_B1),
	.backward_i(backward_i_B1),.backward_j(backward_j_B1),
	.output_c(output_c_B1),
	.min_intv(min_intv_B1),
	.iteration_boundary(iteration_boundary_B1),
	.last_mem_info(last_mem_info_B1),
	.last_token_x2(last_token_x2_B1),
	.backward_x(backward_x_B1),
	.BWT_extend_done  (BWT_extend_done_B1),
	.ok0_x0           (ok0_x0_B1),
	.ok0_x1           (ok0_x1_B1),
	.ok0_x2           (ok0_x2_B1),     
	.ok1_x0           (ok1_x0_B1),     
	.ok1_x1           (ok1_x1_B1),     
	.ok1_x2           (ok1_x2_B1),     
	.ok2_x0           (ok2_x0_B1),     
	.ok2_x1           (ok2_x1_B1),     
	.ok2_x2           (ok2_x2_B1),     
	.ok3_x0           (ok3_x0_B1),     
	.ok3_x1           (ok3_x1_B1),     
	.ok3_x2           (ok3_x2_B1),

	.ok_b_temp_x0(ok_b_temp_x0_B1),
	.ok_b_temp_x1(ok_b_temp_x1_B1),
	.ok_b_temp_x2(ok_b_temp_x2_B1)
);

control_top_back bck_ctrl(
	.clk(clk),
	.rst(rst),
	.stall(stall),
	.read_num_q(read_num_B1),
	.status_q(status_B1),
	.forward_size_n_q(forward_size_n_B1),
	.new_size_q(new_size_B1),
	.primary_q(primary_B1),
	.new_last_size_q(new_last_size_B1),
	.current_wr_addr_q(current_wr_addr_B1),
	.current_rd_addr_q(current_rd_addr_B1),
	.mem_wr_addr_q(mem_wr_addr_B1),	
	.backward_i_q(backward_i_B1),
	.backward_j_q(backward_j_B1),
	.output_c_q(output_c_B1),
	.min_intv_q(min_intv_B1),
	.iteration_boundary_q(iteration_boundary_B1),
	.p_x0_q(p_x0_B1),.p_x1_q(p_x1_B1),
	.p_x2_q(p_x2_B1),.p_info_q(p_info_B1),
	.last_mem_info(last_mem_info_B1),
	.last_token_x2(last_token_x2_B1),
	.backward_x(backward_x_B1),
	
//data portion
	.ok0_x0           (ok0_x0_B1),
	.ok0_x1           (ok0_x1_B1),
	.ok0_x2           (ok0_x2_B1),     
	.ok1_x0           (ok1_x0_B1),     
	.ok1_x1           (ok1_x1_B1),     
	.ok1_x2           (ok1_x2_B1),     
	.ok2_x0           (ok2_x0_B1),     
	.ok2_x1           (ok2_x1_B1),     
	.ok2_x2           (ok2_x2_B1),     
	.ok3_x0           (ok3_x0_B1),     
	.ok3_x1           (ok3_x1_B1),     
	.ok3_x2           (ok3_x2_B1),   
	
	.ok_b_temp_x0(ok_b_temp_x0_B1),
	.ok_b_temp_x1(ok_b_temp_x1_B1),
	.ok_b_temp_x2(ok_b_temp_x2_B1),
	 
	 //stage 3 input
	 .p_x0_q_S3(p_x0_q_S3_q),
	 .p_x1_q_S3(p_x1_q_S3_q),
	 .p_x2_q_S3(p_x2_q_S3_q),
	 .p_info_q_S3(p_info_q_S3_q),
	
	//stage 1 output
	.read_num_S1(read_num_store_1),
	.store_valid_mem(store_valid_mem),
	.mem_x_0(mem_x_0),
	.mem_x_1(mem_x_1),
	.mem_x_2(mem_x_2),
	.mem_x_info(mem_x_info),
	.mem_x_addr(mem_x_addr),

	.store_valid_curr(store_valid_curr),
	.curr_x_0(curr_x_0),
	.curr_x_1(curr_x_1),
	.curr_x_2(curr_x_2),
	.curr_x_info(curr_x_info),
	.curr_x_addr(curr_x_addr),

	//stage 2 output
	.read_num_S2(read_num_2),
	.current_rd_addr_S2(current_rd_addr_2),

	//output
	.read_num(read_num),
	.forward_size_n(forward_size_n),
	.new_size(new_size),
	.primary(primary),
	.new_last_size(new_last_size),
	.current_rd_addr(current_rd_addr),
	.current_wr_addr(current_wr_addr),
	.mem_wr_addr(mem_wr_addr),
	.backward_i(backward_i), 
	.backward_j(backward_j),
	.output_c(output_c),
	.min_intv(min_intv),
	.iteration_boundary(iteration_boundary),
	
	//[licheng] query request one cycle ahead
	.next_query_position_B(next_query_position_B),
	.read_num_query_B(read_num_query_B),
	.status_query_B(status_query_B),

	//output to bwt_extend but not used in control logic
	.backward_k(backward_k),
	.backward_l(backward_l),

	.p_x0(p_x0),.p_x1(p_x1),
	.p_x2(p_x2),.p_info(p_info),
	.reserved_token_x2(reserved_token_x2),
	.reserved_mem_info(reserved_mem_info),
	
	//memory request
	.request_valid(request_valid),
	.addr_k(addr_k),.addr_l(addr_l),
	
	//outputing finish_sign+read_num+mem_size to another module
	.finish_sign(finish_sign),
	.mem_size(mem_size),
	.status(status)
);

endmodule