`define CL 512
`define MAX_READ 1024
`define READ_NUM_WIDTH 10

module BWT_extend_lc(
	input Clk_32UI,
	input reset_BWT_extend,
	input forward_all_done, //whether it is forward or backward
	input stall,

	//input [63:0] primary, // fix value
	input [63:0] k,l,
	input [31:0] cnt_a0,cnt_a1,cnt_a2,cnt_a3,
	input [63:0] cnt_b0,cnt_b1,cnt_b2,cnt_b3,
	input [31:0] cntl_a0,cntl_a1,cntl_a2,cntl_a3,
	input [63:0] cntl_b0,cntl_b1,cntl_b2,cntl_b3,

	input [63:0] ik_x0, ik_x1, ik_x2,

	//added input registered signals
	input [`READ_NUM_WIDTH - 1:0] read_num_q,
	input [5:0] status_q,
	input [6:0] forward_size_n_q,
	input [6:0] new_size_q,
	input [6:0] new_last_size_q,
	input [63:0] primary_q,


	input [6:0] current_rd_addr_q,
	input [6:0] current_wr_addr_q,mem_wr_addr_q,
	input [6:0] backward_i_q, backward_j_q,
	
	input [7:0] output_c_q,
	input [6:0] min_intv_q,
	input iteration_boundary_q,
	//input [63:0] backward_k,backward_l,// is the k and l above

	input [63:0] p_x0_q,p_x1_q,p_x2_q,p_info_q,
	input [63:0]	reserved_token_x2,
	input [31:0]	reserved_mem_info,
	input [6:0] backward_x_q,
//////////////////////////////////////////////////////////////////////////////
	//added output registered signals
	output  [`READ_NUM_WIDTH - 1:0] read_num,

	output  [6:0] forward_size_n,
	output  [6:0] new_size,
	output  [6:0] new_last_size,
	output  [63:0] primary,

	output  [6:0] current_wr_addr,current_rd_addr,mem_wr_addr,
	output  [6:0] backward_i,backward_j,
	output  [7:0] output_c,
	output  [6:0] min_intv,
	output  iteration_boundary,
	output  [31:0] last_mem_info,
	output  [63:0] last_token_x2,
	output  [6:0] backward_x,
	output  [5:0] status,
//////////////////////////////////////////////////////////////////////////////
	output  BWT_extend_done,
	output  reg [63:0] ok0_x0, ok0_x1, ok0_x2,
	output  reg [63:0] ok1_x0, ok1_x1, ok1_x2,
	output  reg [63:0] ok2_x0, ok2_x1, ok2_x2,
	output  reg [63:0] ok3_x0, ok3_x1, ok3_x2,
	output  [63:0] p_x0,p_x1,p_x2,p_info,

	output  reg [63:0] ok_b_temp_x0,ok_b_temp_x1,ok_b_temp_x2
);
	parameter Len = 101;
	
	parameter F_init = 	6'b00_0001; // F_init will disable the forward pipeline
	parameter F_run =  	6'b00_0010;
	parameter F_break = 6'b00_0100;
	parameter BCK_INI = 6'b00_1000;	//100
	parameter BCK_RUN = 6'b01_0000;	//101
	parameter BCK_END = 6'b10_0000;	//110
	parameter BUBBLE = 	6'b00_0000;
      
	wire finish_k, finish_l, BWT_2occ4_finish;
	wire [31:0] cnt_tk_out0,cnt_tk_out1,cnt_tk_out2,cnt_tk_out3;
	wire [31:0] cnt_tl_out0,cnt_tl_out1,cnt_tl_out2,cnt_tl_out3;
	reg [63:0] L2_0, L2_1, L2_2, L2_3; //fix value

//declaration
reg[`READ_NUM_WIDTH - 1:0] read_num_L1;
reg[5:0] status_L1;
reg[6:0] forward_size_n_L1; 
reg[6:0] new_size_L1; 
reg[63:0] primary_L1; 
reg[6:0] new_last_size_L1; 
reg[6:0] current_wr_addr_L1; 
reg[6:0] current_rd_addr_L1; 
reg[6:0] mem_wr_addr_L1; 
reg[6:0] backward_i_L1; 
reg[6:0] backward_j_L1; 
reg[7:0] output_c_L1; 
reg[6:0] min_intv_L1; 
reg  iteration_boundary_L1; 
reg[63:0] p_x0_L1; 
reg[63:0] p_x1_L1; 
reg[63:0] p_x2_L1; 
reg[63:0] p_info_L1; 
reg[31:0] last_mem_info_L1; 
reg[63:0] last_token_x2_L1; 
reg[6:0] backward_x_L1; 
reg[`READ_NUM_WIDTH - 1:0] read_num_L2;
reg[5:0] status_L2;
reg[6:0] forward_size_n_L2; 
reg[6:0] new_size_L2; 
reg[63:0] primary_L2; 
reg[6:0] new_last_size_L2; 
reg[6:0] current_wr_addr_L2; 
reg[6:0] current_rd_addr_L2; 
reg[6:0] mem_wr_addr_L2; 
reg[6:0] backward_i_L2; 
reg[6:0] backward_j_L2; 
reg[7:0] output_c_L2; 
reg[6:0] min_intv_L2; 
reg  iteration_boundary_L2; 
reg[63:0] p_x0_L2; 
reg[63:0] p_x1_L2; 
reg[63:0] p_x2_L2; 
reg[63:0] p_info_L2; 
reg[31:0] last_mem_info_L2; 
reg[63:0] last_token_x2_L2; 
reg[6:0] backward_x_L2; 
reg[`READ_NUM_WIDTH - 1:0] read_num_L3;
reg[5:0] status_L3;
reg[6:0] forward_size_n_L3; 
reg[6:0] new_size_L3; 
reg[63:0] primary_L3; 
reg[6:0] new_last_size_L3; 
reg[6:0] current_wr_addr_L3; 
reg[6:0] current_rd_addr_L3; 
reg[6:0] mem_wr_addr_L3; 
reg[6:0] backward_i_L3; 
reg[6:0] backward_j_L3; 
reg[7:0] output_c_L3; 
reg[6:0] min_intv_L3; 
reg  iteration_boundary_L3; 
reg[63:0] p_x0_L3; 
reg[63:0] p_x1_L3; 
reg[63:0] p_x2_L3; 
reg[63:0] p_info_L3; 
reg[31:0] last_mem_info_L3; 
reg[63:0] last_token_x2_L3; 
reg[6:0] backward_x_L3; 
reg[`READ_NUM_WIDTH - 1:0] read_num_L4;
reg[5:0] status_L4;
reg[6:0] forward_size_n_L4; 
reg[6:0] new_size_L4; 
reg[63:0] primary_L4; 
reg[6:0] new_last_size_L4; 
reg[6:0] current_wr_addr_L4; 
reg[6:0] current_rd_addr_L4; 
reg[6:0] mem_wr_addr_L4; 
reg[6:0] backward_i_L4; 
reg[6:0] backward_j_L4; 
reg[7:0] output_c_L4; 
reg[6:0] min_intv_L4; 
reg  iteration_boundary_L4; 
reg[63:0] p_x0_L4; 
reg[63:0] p_x1_L4; 
reg[63:0] p_x2_L4; 
reg[63:0] p_info_L4; 
reg[31:0] last_mem_info_L4; 
reg[63:0] last_token_x2_L4; 
reg[6:0] backward_x_L4; 
reg[`READ_NUM_WIDTH - 1:0] read_num_L5;
reg[5:0] status_L5;
reg[6:0] forward_size_n_L5; 
reg[6:0] new_size_L5; 
reg[63:0] primary_L5; 
reg[6:0] new_last_size_L5; 
reg[6:0] current_wr_addr_L5; 
reg[6:0] current_rd_addr_L5; 
reg[6:0] mem_wr_addr_L5; 
reg[6:0] backward_i_L5; 
reg[6:0] backward_j_L5; 
reg[7:0] output_c_L5; 
reg[6:0] min_intv_L5; 
reg  iteration_boundary_L5; 
reg[63:0] p_x0_L5; 
reg[63:0] p_x1_L5; 
reg[63:0] p_x2_L5; 
reg[63:0] p_info_L5; 
reg[31:0] last_mem_info_L5; 
reg[63:0] last_token_x2_L5; 
reg[6:0] backward_x_L5; 
reg[`READ_NUM_WIDTH - 1:0] read_num_L6;
reg[5:0] status_L6;
reg[6:0] forward_size_n_L6; 
reg[6:0] new_size_L6; 
reg[63:0] primary_L6; 
reg[6:0] new_last_size_L6; 
reg[6:0] current_wr_addr_L6; 
reg[6:0] current_rd_addr_L6; 
reg[6:0] mem_wr_addr_L6; 
reg[6:0] backward_i_L6; 
reg[6:0] backward_j_L6; 
reg[7:0] output_c_L6; 
reg[6:0] min_intv_L6; 
reg  iteration_boundary_L6; 
reg[63:0] p_x0_L6; 
reg[63:0] p_x1_L6; 
reg[63:0] p_x2_L6; 
reg[63:0] p_info_L6; 
reg[31:0] last_mem_info_L6; 
reg[63:0] last_token_x2_L6; 
reg[6:0] backward_x_L6; 
reg[`READ_NUM_WIDTH - 1:0] read_num_L7;
reg[5:0] status_L7;
reg[6:0] forward_size_n_L7; 
reg[6:0] new_size_L7; 
reg[63:0] primary_L7; 
reg[6:0] new_last_size_L7; 
reg[6:0] current_wr_addr_L7; 
reg[6:0] current_rd_addr_L7; 
reg[6:0] mem_wr_addr_L7; 
reg[6:0] backward_i_L7; 
reg[6:0] backward_j_L7; 
reg[7:0] output_c_L7; 
reg[6:0] min_intv_L7; 
reg  iteration_boundary_L7; 
reg[63:0] p_x0_L7; 
reg[63:0] p_x1_L7; 
reg[63:0] p_x2_L7; 
reg[63:0] p_info_L7; 
reg[31:0] last_mem_info_L7; 
reg[63:0] last_token_x2_L7; 
reg[6:0] backward_x_L7; 
reg[`READ_NUM_WIDTH - 1:0] read_num_L8;
reg[5:0] status_L8;
reg[6:0] forward_size_n_L8; 
reg[6:0] new_size_L8; 
reg[63:0] primary_L8; 
reg[6:0] new_last_size_L8; 
reg[6:0] current_wr_addr_L8; 
reg[6:0] current_rd_addr_L8; 
reg[6:0] mem_wr_addr_L8; 
reg[6:0] backward_i_L8; 
reg[6:0] backward_j_L8; 
reg[7:0] output_c_L8; 
reg[6:0] min_intv_L8; 
reg  iteration_boundary_L8; 
reg[63:0] p_x0_L8; 
reg[63:0] p_x1_L8; 
reg[63:0] p_x2_L8; 
reg[63:0] p_info_L8; 
reg[31:0] last_mem_info_L8; 
reg[63:0] last_token_x2_L8; 
reg[6:0] backward_x_L8; 
reg[`READ_NUM_WIDTH - 1:0] read_num_L9;
reg[5:0] status_L9;
reg[6:0] forward_size_n_L9; 
reg[6:0] new_size_L9; 
reg[63:0] primary_L9; 
reg[6:0] new_last_size_L9; 
reg[6:0] current_wr_addr_L9; 
reg[6:0] current_rd_addr_L9; 
reg[6:0] mem_wr_addr_L9; 
reg[6:0] backward_i_L9; 
reg[6:0] backward_j_L9; 
reg[7:0] output_c_L9; 
reg[6:0] min_intv_L9; 
reg  iteration_boundary_L9; 
reg[63:0] p_x0_L9; 
reg[63:0] p_x1_L9; 
reg[63:0] p_x2_L9; 
reg[63:0] p_info_L9; 
reg[31:0] last_mem_info_L9; 
reg[63:0] last_token_x2_L9; 
reg[6:0] backward_x_L9; 
reg[`READ_NUM_WIDTH - 1:0] read_num_L10;
reg[5:0] status_L10;
reg[6:0] forward_size_n_L10; 
reg[6:0] new_size_L10; 
reg[63:0] primary_L10; 
reg[6:0] new_last_size_L10; 
reg[6:0] current_wr_addr_L10; 
reg[6:0] current_rd_addr_L10; 
reg[6:0] mem_wr_addr_L10; 
reg[6:0] backward_i_L10; 
reg[6:0] backward_j_L10; 
reg[7:0] output_c_L10; 
reg[6:0] min_intv_L10; 
reg  iteration_boundary_L10; 
reg[63:0] p_x0_L10; 
reg[63:0] p_x1_L10; 
reg[63:0] p_x2_L10; 
reg[63:0] p_info_L10; 
reg[31:0] last_mem_info_L10; 
reg[63:0] last_token_x2_L10; 
reg[6:0] backward_x_L10; 
reg[`READ_NUM_WIDTH - 1:0] read_num_L11;
reg[5:0] status_L11;
reg[6:0] forward_size_n_L11; 
reg[6:0] new_size_L11; 
reg[63:0] primary_L11; 
reg[6:0] new_last_size_L11; 
reg[6:0] current_wr_addr_L11; 
reg[6:0] current_rd_addr_L11; 
reg[6:0] mem_wr_addr_L11; 
reg[6:0] backward_i_L11; 
reg[6:0] backward_j_L11; 
reg[7:0] output_c_L11; 
reg[6:0] min_intv_L11; 
reg  iteration_boundary_L11; 
reg[63:0] p_x0_L11; 
reg[63:0] p_x1_L11; 
reg[63:0] p_x2_L11; 
reg[63:0] p_info_L11; 
reg[31:0] last_mem_info_L11; 
reg[63:0] last_token_x2_L11; 
reg[6:0] backward_x_L11; 
reg[`READ_NUM_WIDTH - 1:0] read_num_L12;
reg[5:0] status_L12;
reg[6:0] forward_size_n_L12; 
reg[6:0] new_size_L12; 
reg[63:0] primary_L12; 
reg[6:0] new_last_size_L12; 
reg[6:0] current_wr_addr_L12; 
reg[6:0] current_rd_addr_L12; 
reg[6:0] mem_wr_addr_L12; 
reg[6:0] backward_i_L12; 
reg[6:0] backward_j_L12; 
reg[7:0] output_c_L12; 
reg[6:0] min_intv_L12; 
reg  iteration_boundary_L12; 
reg[63:0] p_x0_L12; 
reg[63:0] p_x1_L12; 
reg[63:0] p_x2_L12; 
reg[63:0] p_info_L12; 
reg[31:0] last_mem_info_L12; 
reg[63:0] last_token_x2_L12; 
reg[6:0] backward_x_L12; 
   
	assign read_num = read_num_L12;
	assign status = status_L12;
	assign forward_size_n = forward_size_n_L12;
	assign new_size = new_size_L12;
	assign new_last_size = new_last_size_L12;
	assign primary = primary_L12;

	assign current_wr_addr = current_wr_addr_L12;
	assign current_rd_addr = current_rd_addr_L12;
	assign mem_wr_addr = mem_wr_addr_L12;
	assign backward_i = backward_i_L12;
	assign backward_j = backward_j_L12;
	assign output_c = output_c_L12;
	assign min_intv = min_intv_L12;
	assign iteration_boundary = iteration_boundary_L12;
	//assign last_mem_info = reserved_mem_info;
	//assign last_token_x2 = reserved_token_x2;
	//[licheng] licheng is dying debugging this code.
	assign last_mem_info = last_mem_info_L12;
	assign last_token_x2 = last_token_x2_L12;
	
	assign p_x0 = p_x0_L12;
	assign p_x1 = p_x1_L12;
	assign p_x2 = p_x2_L12;
	assign p_info = p_info_L12;
	assign backward_x = backward_x_L12;

	BWT_OCC4_lc BWT_OCC4_k(
		.reset_BWT_extend(reset_BWT_extend),
		.stall(stall),
		.Clk_32UI       (Clk_32UI),
		.k              (k),
		.cnt_a0         (cnt_a0),
		.cnt_a1         (cnt_a1),
		.cnt_a2         (cnt_a2),
		.cnt_a3         (cnt_a3),
		.cnt_b0         (cnt_b0),
		.cnt_b1         (cnt_b1),
		.cnt_b2         (cnt_b2),
		.cnt_b3         (cnt_b3),
		.cnt_out0       (cnt_tk_out0),
		.cnt_out1       (cnt_tk_out1),
		.cnt_out2       (cnt_tk_out2),
		.cnt_out3       (cnt_tk_out3)
	);

	BWT_OCC4_lc BWT_OCC4_l(
		.reset_BWT_extend(reset_BWT_extend),
		.stall(stall),
		.Clk_32UI       (Clk_32UI),
		.k              (l),
		.cnt_a0         (cntl_a0),
		.cnt_a1         (cntl_a1),
		.cnt_a2         (cntl_a2),
		.cnt_a3         (cntl_a3),
		.cnt_b0         (cntl_b0),
		.cnt_b1         (cntl_b1),
		.cnt_b2         (cntl_b2),
		.cnt_b3         (cntl_b3),
		.cnt_out0       (cnt_tl_out0),
		.cnt_out1       (cnt_tl_out1),
		.cnt_out2       (cnt_tl_out2),
		.cnt_out3       (cnt_tl_out3)
	);
   reg [5:0] BWT_extend_counter_t;
   reg start;


   always @(posedge Clk_32UI) begin		
		if (!reset_BWT_extend) begin
		read_num_L1 <= 0; 
		status_L1 <= 0; 
		forward_size_n_L1 <= 0; 
		new_size_L1 <= 0; 
		new_last_size_L1 <= 0; 
		primary_L1 <= 0; 
		current_wr_addr_L1 <= 0; 
		current_rd_addr_L1 <= 0; 
		mem_wr_addr_L1 <= 0; 
		backward_i_L1 <= 0; 
		backward_j_L1 <= 0; 
		output_c_L1 <= 0; 
		min_intv_L1 <= 0; 
		iteration_boundary_L1 <= 0; 
		last_mem_info_L1 <= 0; 
		last_token_x2_L1 <= 0; 
		p_x0_L1 <= 0; 
		p_x1_L1 <= 0; 
		p_x2_L1 <= 0; 
		p_info_L1 <= 0; 
		backward_x_L1 <= 0; 
		read_num_L2 <= 0; 
		status_L2 <= 0; 
		forward_size_n_L2 <= 0; 
		new_size_L2 <= 0; 
		new_last_size_L2 <= 0; 
		primary_L2 <= 0; 
		current_wr_addr_L2 <= 0; 
		current_rd_addr_L2 <= 0; 
		mem_wr_addr_L2 <= 0; 
		backward_i_L2 <= 0; 
		backward_j_L2 <= 0; 
		output_c_L2 <= 0; 
		min_intv_L2 <= 0; 
		iteration_boundary_L2 <= 0; 
		last_mem_info_L2 <= 0; 
		last_token_x2_L2 <= 0; 
		p_x0_L2 <= 0; 
		p_x1_L2 <= 0; 
		p_x2_L2 <= 0; 
		p_info_L2 <= 0; 
		backward_x_L2 <= 0; 
		read_num_L3 <= 0; 
		status_L3 <= 0; 
		forward_size_n_L3 <= 0; 
		new_size_L3 <= 0; 
		new_last_size_L3 <= 0; 
		primary_L3 <= 0; 
		current_wr_addr_L3 <= 0; 
		current_rd_addr_L3 <= 0; 
		mem_wr_addr_L3 <= 0; 
		backward_i_L3 <= 0; 
		backward_j_L3 <= 0; 
		output_c_L3 <= 0; 
		min_intv_L3 <= 0; 
		iteration_boundary_L3 <= 0; 
		last_mem_info_L3 <= 0; 
		last_token_x2_L3 <= 0; 
		p_x0_L3 <= 0; 
		p_x1_L3 <= 0; 
		p_x2_L3 <= 0; 
		p_info_L3 <= 0; 
		backward_x_L3 <= 0; 
		read_num_L4 <= 0; 
		status_L4 <= 0; 
		forward_size_n_L4 <= 0; 
		new_size_L4 <= 0; 
		new_last_size_L4 <= 0; 
		primary_L4 <= 0; 
		current_wr_addr_L4 <= 0; 
		current_rd_addr_L4 <= 0; 
		mem_wr_addr_L4 <= 0; 
		backward_i_L4 <= 0; 
		backward_j_L4 <= 0; 
		output_c_L4 <= 0; 
		min_intv_L4 <= 0; 
		iteration_boundary_L4 <= 0; 
		last_mem_info_L4 <= 0; 
		last_token_x2_L4 <= 0; 
		p_x0_L4 <= 0; 
		p_x1_L4 <= 0; 
		p_x2_L4 <= 0; 
		p_info_L4 <= 0; 
		backward_x_L4 <= 0; 
		read_num_L5 <= 0; 
		status_L5 <= 0; 
		forward_size_n_L5 <= 0; 
		new_size_L5 <= 0; 
		new_last_size_L5 <= 0; 
		primary_L5 <= 0; 
		current_wr_addr_L5 <= 0; 
		current_rd_addr_L5 <= 0; 
		mem_wr_addr_L5 <= 0; 
		backward_i_L5 <= 0; 
		backward_j_L5 <= 0; 
		output_c_L5 <= 0; 
		min_intv_L5 <= 0; 
		iteration_boundary_L5 <= 0; 
		last_mem_info_L5 <= 0; 
		last_token_x2_L5 <= 0; 
		p_x0_L5 <= 0; 
		p_x1_L5 <= 0; 
		p_x2_L5 <= 0; 
		p_info_L5 <= 0; 
		backward_x_L5 <= 0; 
		read_num_L6 <= 0; 
		status_L6 <= 0; 
		forward_size_n_L6 <= 0; 
		new_size_L6 <= 0; 
		new_last_size_L6 <= 0; 
		primary_L6 <= 0; 
		current_wr_addr_L6 <= 0; 
		current_rd_addr_L6 <= 0; 
		mem_wr_addr_L6 <= 0; 
		backward_i_L6 <= 0; 
		backward_j_L6 <= 0; 
		output_c_L6 <= 0; 
		min_intv_L6 <= 0; 
		iteration_boundary_L6 <= 0; 
		last_mem_info_L6 <= 0; 
		last_token_x2_L6 <= 0; 
		p_x0_L6 <= 0; 
		p_x1_L6 <= 0; 
		p_x2_L6 <= 0; 
		p_info_L6 <= 0; 
		backward_x_L6 <= 0; 
		read_num_L7 <= 0; 
		status_L7 <= 0; 
		forward_size_n_L7 <= 0; 
		new_size_L7 <= 0; 
		new_last_size_L7 <= 0; 
		primary_L7 <= 0; 
		current_wr_addr_L7 <= 0; 
		current_rd_addr_L7 <= 0; 
		mem_wr_addr_L7 <= 0; 
		backward_i_L7 <= 0; 
		backward_j_L7 <= 0; 
		output_c_L7 <= 0; 
		min_intv_L7 <= 0; 
		iteration_boundary_L7 <= 0; 
		last_mem_info_L7 <= 0; 
		last_token_x2_L7 <= 0; 
		p_x0_L7 <= 0; 
		p_x1_L7 <= 0; 
		p_x2_L7 <= 0; 
		p_info_L7 <= 0; 
		backward_x_L7 <= 0; 
		read_num_L8 <= 0; 
		status_L8 <= 0; 
		forward_size_n_L8 <= 0; 
		new_size_L8 <= 0; 
		new_last_size_L8 <= 0; 
		primary_L8 <= 0; 
		current_wr_addr_L8 <= 0; 
		current_rd_addr_L8 <= 0; 
		mem_wr_addr_L8 <= 0; 
		backward_i_L8 <= 0; 
		backward_j_L8 <= 0; 
		output_c_L8 <= 0; 
		min_intv_L8 <= 0; 
		iteration_boundary_L8 <= 0; 
		last_mem_info_L8 <= 0; 
		last_token_x2_L8 <= 0; 
		p_x0_L8 <= 0; 
		p_x1_L8 <= 0; 
		p_x2_L8 <= 0; 
		p_info_L8 <= 0; 
		backward_x_L8 <= 0; 
		read_num_L9 <= 0; 
		status_L9 <= 0; 
		forward_size_n_L9 <= 0; 
		new_size_L9 <= 0; 
		new_last_size_L9 <= 0; 
		primary_L9 <= 0; 
		current_wr_addr_L9 <= 0; 
		current_rd_addr_L9 <= 0; 
		mem_wr_addr_L9 <= 0; 
		backward_i_L9 <= 0; 
		backward_j_L9 <= 0; 
		output_c_L9 <= 0; 
		min_intv_L9 <= 0; 
		iteration_boundary_L9 <= 0; 
		last_mem_info_L9 <= 0; 
		last_token_x2_L9 <= 0; 
		p_x0_L9 <= 0; 
		p_x1_L9 <= 0; 
		p_x2_L9 <= 0; 
		p_info_L9 <= 0; 
		backward_x_L9 <= 0; 
		read_num_L10 <= 0; 
		status_L10 <= 0; 
		forward_size_n_L10 <= 0; 
		new_size_L10 <= 0; 
		new_last_size_L10 <= 0; 
		primary_L10 <= 0; 
		current_wr_addr_L10 <= 0; 
		current_rd_addr_L10 <= 0; 
		mem_wr_addr_L10 <= 0; 
		backward_i_L10 <= 0; 
		backward_j_L10 <= 0; 
		output_c_L10 <= 0; 
		min_intv_L10 <= 0; 
		iteration_boundary_L10 <= 0; 
		last_mem_info_L10 <= 0; 
		last_token_x2_L10 <= 0; 
		p_x0_L10 <= 0; 
		p_x1_L10 <= 0; 
		p_x2_L10 <= 0; 
		p_info_L10 <= 0; 
		backward_x_L10 <= 0; 
		read_num_L11 <= 0; 
		status_L11 <= 0; 
		forward_size_n_L11 <= 0; 
		new_size_L11 <= 0; 
		new_last_size_L11 <= 0; 
		primary_L11 <= 0; 
		current_wr_addr_L11 <= 0; 
		current_rd_addr_L11 <= 0; 
		mem_wr_addr_L11 <= 0; 
		backward_i_L11 <= 0; 
		backward_j_L11 <= 0; 
		output_c_L11 <= 0; 
		min_intv_L11 <= 0; 
		iteration_boundary_L11 <= 0; 
		last_mem_info_L11 <= 0; 
		last_token_x2_L11 <= 0; 
		p_x0_L11 <= 0; 
		p_x1_L11 <= 0; 
		p_x2_L11 <= 0; 
		p_info_L11 <= 0; 
		backward_x_L11 <= 0; 
		read_num_L12 <= 0; 
		status_L12 <= 0; 
		forward_size_n_L12 <= 0; 
		new_size_L12 <= 0; 
		new_last_size_L12 <= 0; 
		primary_L12 <= 0; 
		current_wr_addr_L12 <= 0; 
		current_rd_addr_L12 <= 0; 
		mem_wr_addr_L12 <= 0; 
		backward_i_L12 <= 0; 
		backward_j_L12 <= 0; 
		output_c_L12 <= 0; 
		min_intv_L12 <= 0; 
		iteration_boundary_L12 <= 0; 
		last_mem_info_L12 <= 0; 
		last_token_x2_L12 <= 0; 
		p_x0_L12 <= 0; 
		p_x1_L12 <= 0; 
		p_x2_L12 <= 0; 
		p_info_L12 <= 0; 
		backward_x_L12 <= 0; 
		end
		else if (stall) begin
		read_num_L1 <= read_num_L1; 
		status_L1 <= status_L1; 
		forward_size_n_L1 <= forward_size_n_L1; 
		new_size_L1 <= new_size_L1; 
		new_last_size_L1 <= new_last_size_L1; 
		primary_L1 <= primary_L1; 
		current_wr_addr_L1 <= current_wr_addr_L1; 
		current_rd_addr_L1 <= current_rd_addr_L1; 
		mem_wr_addr_L1 <= mem_wr_addr_L1; 
		backward_i_L1 <= backward_i_L1; 
		backward_j_L1 <= backward_j_L1; 
		output_c_L1 <= output_c_L1; 
		min_intv_L1 <= min_intv_L1; 
		iteration_boundary_L1 <= iteration_boundary_L1; 
		last_mem_info_L1 <= last_mem_info_L1; 
		last_token_x2_L1 <= last_token_x2_L1; 
		p_x0_L1 <= p_x0_L1; 
		p_x1_L1 <= p_x1_L1; 
		p_x2_L1 <= p_x2_L1; 
		p_info_L1 <= p_info_L1; 
		backward_x_L1 <= backward_x_L1; 
		read_num_L2 <= read_num_L2; 
		status_L2 <= status_L2; 
		forward_size_n_L2 <= forward_size_n_L2; 
		new_size_L2 <= new_size_L2; 
		new_last_size_L2 <= new_last_size_L2; 
		primary_L2 <= primary_L2; 
		current_wr_addr_L2 <= current_wr_addr_L2; 
		current_rd_addr_L2 <= current_rd_addr_L2; 
		mem_wr_addr_L2 <= mem_wr_addr_L2; 
		backward_i_L2 <= backward_i_L2; 
		backward_j_L2 <= backward_j_L2; 
		output_c_L2 <= output_c_L2; 
		min_intv_L2 <= min_intv_L2; 
		iteration_boundary_L2 <= iteration_boundary_L2; 
		last_mem_info_L2 <= last_mem_info_L2; 
		last_token_x2_L2 <= last_token_x2_L2; 
		p_x0_L2 <= p_x0_L2; 
		p_x1_L2 <= p_x1_L2; 
		p_x2_L2 <= p_x2_L2; 
		p_info_L2 <= p_info_L2; 
		backward_x_L2 <= backward_x_L2; 
		read_num_L3 <= read_num_L3; 
		status_L3 <= status_L3; 
		forward_size_n_L3 <= forward_size_n_L3; 
		new_size_L3 <= new_size_L3; 
		new_last_size_L3 <= new_last_size_L3; 
		primary_L3 <= primary_L3; 
		current_wr_addr_L3 <= current_wr_addr_L3; 
		current_rd_addr_L3 <= current_rd_addr_L3; 
		mem_wr_addr_L3 <= mem_wr_addr_L3; 
		backward_i_L3 <= backward_i_L3; 
		backward_j_L3 <= backward_j_L3; 
		output_c_L3 <= output_c_L3; 
		min_intv_L3 <= min_intv_L3; 
		iteration_boundary_L3 <= iteration_boundary_L3; 
		last_mem_info_L3 <= last_mem_info_L3; 
		last_token_x2_L3 <= last_token_x2_L3; 
		p_x0_L3 <= p_x0_L3; 
		p_x1_L3 <= p_x1_L3; 
		p_x2_L3 <= p_x2_L3; 
		p_info_L3 <= p_info_L3; 
		backward_x_L3 <= backward_x_L3; 
		read_num_L4 <= read_num_L4; 
		status_L4 <= status_L4; 
		forward_size_n_L4 <= forward_size_n_L4; 
		new_size_L4 <= new_size_L4; 
		new_last_size_L4 <= new_last_size_L4; 
		primary_L4 <= primary_L4; 
		current_wr_addr_L4 <= current_wr_addr_L4; 
		current_rd_addr_L4 <= current_rd_addr_L4; 
		mem_wr_addr_L4 <= mem_wr_addr_L4; 
		backward_i_L4 <= backward_i_L4; 
		backward_j_L4 <= backward_j_L4; 
		output_c_L4 <= output_c_L4; 
		min_intv_L4 <= min_intv_L4; 
		iteration_boundary_L4 <= iteration_boundary_L4; 
		last_mem_info_L4 <= last_mem_info_L4; 
		last_token_x2_L4 <= last_token_x2_L4; 
		p_x0_L4 <= p_x0_L4; 
		p_x1_L4 <= p_x1_L4; 
		p_x2_L4 <= p_x2_L4; 
		p_info_L4 <= p_info_L4; 
		backward_x_L4 <= backward_x_L4; 
		read_num_L5 <= read_num_L5; 
		status_L5 <= status_L5; 
		forward_size_n_L5 <= forward_size_n_L5; 
		new_size_L5 <= new_size_L5; 
		new_last_size_L5 <= new_last_size_L5; 
		primary_L5 <= primary_L5; 
		current_wr_addr_L5 <= current_wr_addr_L5; 
		current_rd_addr_L5 <= current_rd_addr_L5; 
		mem_wr_addr_L5 <= mem_wr_addr_L5; 
		backward_i_L5 <= backward_i_L5; 
		backward_j_L5 <= backward_j_L5; 
		output_c_L5 <= output_c_L5; 
		min_intv_L5 <= min_intv_L5; 
		iteration_boundary_L5 <= iteration_boundary_L5; 
		last_mem_info_L5 <= last_mem_info_L5; 
		last_token_x2_L5 <= last_token_x2_L5; 
		p_x0_L5 <= p_x0_L5; 
		p_x1_L5 <= p_x1_L5; 
		p_x2_L5 <= p_x2_L5; 
		p_info_L5 <= p_info_L5; 
		backward_x_L5 <= backward_x_L5; 
		read_num_L6 <= read_num_L6; 
		status_L6 <= status_L6; 
		forward_size_n_L6 <= forward_size_n_L6; 
		new_size_L6 <= new_size_L6; 
		new_last_size_L6 <= new_last_size_L6; 
		primary_L6 <= primary_L6; 
		current_wr_addr_L6 <= current_wr_addr_L6; 
		current_rd_addr_L6 <= current_rd_addr_L6; 
		mem_wr_addr_L6 <= mem_wr_addr_L6; 
		backward_i_L6 <= backward_i_L6; 
		backward_j_L6 <= backward_j_L6; 
		output_c_L6 <= output_c_L6; 
		min_intv_L6 <= min_intv_L6; 
		iteration_boundary_L6 <= iteration_boundary_L6; 
		last_mem_info_L6 <= last_mem_info_L6; 
		last_token_x2_L6 <= last_token_x2_L6; 
		p_x0_L6 <= p_x0_L6; 
		p_x1_L6 <= p_x1_L6; 
		p_x2_L6 <= p_x2_L6; 
		p_info_L6 <= p_info_L6; 
		backward_x_L6 <= backward_x_L6; 
		read_num_L7 <= read_num_L7; 
		status_L7 <= status_L7; 
		forward_size_n_L7 <= forward_size_n_L7; 
		new_size_L7 <= new_size_L7; 
		new_last_size_L7 <= new_last_size_L7; 
		primary_L7 <= primary_L7; 
		current_wr_addr_L7 <= current_wr_addr_L7; 
		current_rd_addr_L7 <= current_rd_addr_L7; 
		mem_wr_addr_L7 <= mem_wr_addr_L7; 
		backward_i_L7 <= backward_i_L7; 
		backward_j_L7 <= backward_j_L7; 
		output_c_L7 <= output_c_L7; 
		min_intv_L7 <= min_intv_L7; 
		iteration_boundary_L7 <= iteration_boundary_L7; 
		last_mem_info_L7 <= last_mem_info_L7; 
		last_token_x2_L7 <= last_token_x2_L7; 
		p_x0_L7 <= p_x0_L7; 
		p_x1_L7 <= p_x1_L7; 
		p_x2_L7 <= p_x2_L7; 
		p_info_L7 <= p_info_L7; 
		backward_x_L7 <= backward_x_L7; 
		read_num_L8 <= read_num_L8; 
		status_L8 <= status_L8; 
		forward_size_n_L8 <= forward_size_n_L8; 
		new_size_L8 <= new_size_L8; 
		new_last_size_L8 <= new_last_size_L8; 
		primary_L8 <= primary_L8; 
		current_wr_addr_L8 <= current_wr_addr_L8; 
		current_rd_addr_L8 <= current_rd_addr_L8; 
		mem_wr_addr_L8 <= mem_wr_addr_L8; 
		backward_i_L8 <= backward_i_L8; 
		backward_j_L8 <= backward_j_L8; 
		output_c_L8 <= output_c_L8; 
		min_intv_L8 <= min_intv_L8; 
		iteration_boundary_L8 <= iteration_boundary_L8; 
		last_mem_info_L8 <= last_mem_info_L8; 
		last_token_x2_L8 <= last_token_x2_L8; 
		p_x0_L8 <= p_x0_L8; 
		p_x1_L8 <= p_x1_L8; 
		p_x2_L8 <= p_x2_L8; 
		p_info_L8 <= p_info_L8; 
		backward_x_L8 <= backward_x_L8; 
		read_num_L9 <= read_num_L9; 
		status_L9 <= status_L9; 
		forward_size_n_L9 <= forward_size_n_L9; 
		new_size_L9 <= new_size_L9; 
		new_last_size_L9 <= new_last_size_L9; 
		primary_L9 <= primary_L9; 
		current_wr_addr_L9 <= current_wr_addr_L9; 
		current_rd_addr_L9 <= current_rd_addr_L9; 
		mem_wr_addr_L9 <= mem_wr_addr_L9; 
		backward_i_L9 <= backward_i_L9; 
		backward_j_L9 <= backward_j_L9; 
		output_c_L9 <= output_c_L9; 
		min_intv_L9 <= min_intv_L9; 
		iteration_boundary_L9 <= iteration_boundary_L9; 
		last_mem_info_L9 <= last_mem_info_L9; 
		last_token_x2_L9 <= last_token_x2_L9; 
		p_x0_L9 <= p_x0_L9; 
		p_x1_L9 <= p_x1_L9; 
		p_x2_L9 <= p_x2_L9; 
		p_info_L9 <= p_info_L9; 
		backward_x_L9 <= backward_x_L9; 
		read_num_L10 <= read_num_L10; 
		status_L10 <= status_L10; 
		forward_size_n_L10 <= forward_size_n_L10; 
		new_size_L10 <= new_size_L10; 
		new_last_size_L10 <= new_last_size_L10; 
		primary_L10 <= primary_L10; 
		current_wr_addr_L10 <= current_wr_addr_L10; 
		current_rd_addr_L10 <= current_rd_addr_L10; 
		mem_wr_addr_L10 <= mem_wr_addr_L10; 
		backward_i_L10 <= backward_i_L10; 
		backward_j_L10 <= backward_j_L10; 
		output_c_L10 <= output_c_L10; 
		min_intv_L10 <= min_intv_L10; 
		iteration_boundary_L10 <= iteration_boundary_L10; 
		last_mem_info_L10 <= last_mem_info_L10; 
		last_token_x2_L10 <= last_token_x2_L10; 
		p_x0_L10 <= p_x0_L10; 
		p_x1_L10 <= p_x1_L10; 
		p_x2_L10 <= p_x2_L10; 
		p_info_L10 <= p_info_L10; 
		backward_x_L10 <= backward_x_L10; 
		read_num_L11 <= read_num_L11; 
		status_L11 <= status_L11; 
		forward_size_n_L11 <= forward_size_n_L11; 
		new_size_L11 <= new_size_L11; 
		new_last_size_L11 <= new_last_size_L11; 
		primary_L11 <= primary_L11; 
		current_wr_addr_L11 <= current_wr_addr_L11; 
		current_rd_addr_L11 <= current_rd_addr_L11; 
		mem_wr_addr_L11 <= mem_wr_addr_L11; 
		backward_i_L11 <= backward_i_L11; 
		backward_j_L11 <= backward_j_L11; 
		output_c_L11 <= output_c_L11; 
		min_intv_L11 <= min_intv_L11; 
		iteration_boundary_L11 <= iteration_boundary_L11; 
		last_mem_info_L11 <= last_mem_info_L11; 
		last_token_x2_L11 <= last_token_x2_L11; 
		p_x0_L11 <= p_x0_L11; 
		p_x1_L11 <= p_x1_L11; 
		p_x2_L11 <= p_x2_L11; 
		p_info_L11 <= p_info_L11; 
		backward_x_L11 <= backward_x_L11; 
		end
		else begin
		read_num_L1 <= read_num_q;		
		status_L1 <= status_q;
		forward_size_n_L1 <= forward_size_n_q;
		new_size_L1		<= new_size_q;
		new_last_size_L1	<= new_last_size_q;
		primary_L1		<= primary_q;
		current_wr_addr_L1	<= current_wr_addr_q;
		current_rd_addr_L1 <= current_rd_addr_q;
		mem_wr_addr_L1		<= mem_wr_addr_q;
		backward_i_L1		<= backward_i_q;
		backward_j_L1		<= backward_j_q;
		output_c_L1		<= output_c_q;
		min_intv_L1		<= min_intv_q;
		iteration_boundary_L1 <= iteration_boundary_q;
		last_mem_info_L1	<= reserved_mem_info;
		last_token_x2_L1	<= reserved_token_x2;
		p_x0_L1 <= p_x0_q;
		p_x1_L1 <= p_x1_q;
		p_x2_L1 <= p_x2_q;
		p_info_L1 <= p_info_q;
		backward_x_L1		<= backward_x_q;
		read_num_L2 <= read_num_L1; 
		status_L2 <= status_L1; 
		forward_size_n_L2 <= forward_size_n_L1; 
		new_size_L2 <= new_size_L1; 
		new_last_size_L2 <= new_last_size_L1; 
		primary_L2 <= primary_L1; 
		current_wr_addr_L2 <= current_wr_addr_L1; 
		current_rd_addr_L2 <= current_rd_addr_L1; 
		mem_wr_addr_L2 <= mem_wr_addr_L1; 
		backward_i_L2 <= backward_i_L1; 
		backward_j_L2 <= backward_j_L1; 
		output_c_L2 <= output_c_L1; 
		min_intv_L2 <= min_intv_L1; 
		iteration_boundary_L2 <= iteration_boundary_L1; 
		last_mem_info_L2 <= last_mem_info_L1; 
		last_token_x2_L2 <= last_token_x2_L1; 
		p_x0_L2 <= p_x0_L1; 
		p_x1_L2 <= p_x1_L1; 
		p_x2_L2 <= p_x2_L1; 
		p_info_L2 <= p_info_L1; 
		backward_x_L2 <= backward_x_L1; 
		read_num_L3 <= read_num_L2; 
		status_L3 <= status_L2; 
		forward_size_n_L3 <= forward_size_n_L2; 
		new_size_L3 <= new_size_L2; 
		new_last_size_L3 <= new_last_size_L2; 
		primary_L3 <= primary_L2; 
		current_wr_addr_L3 <= current_wr_addr_L2; 
		current_rd_addr_L3 <= current_rd_addr_L2; 
		mem_wr_addr_L3 <= mem_wr_addr_L2; 
		backward_i_L3 <= backward_i_L2; 
		backward_j_L3 <= backward_j_L2; 
		output_c_L3 <= output_c_L2; 
		min_intv_L3 <= min_intv_L2; 
		iteration_boundary_L3 <= iteration_boundary_L2; 
		last_mem_info_L3 <= last_mem_info_L2; 
		last_token_x2_L3 <= last_token_x2_L2; 
		p_x0_L3 <= p_x0_L2; 
		p_x1_L3 <= p_x1_L2; 
		p_x2_L3 <= p_x2_L2; 
		p_info_L3 <= p_info_L2; 
		backward_x_L3 <= backward_x_L2; 
		read_num_L4 <= read_num_L3; 
		status_L4 <= status_L3; 
		forward_size_n_L4 <= forward_size_n_L3; 
		new_size_L4 <= new_size_L3; 
		new_last_size_L4 <= new_last_size_L3; 
		primary_L4 <= primary_L3; 
		current_wr_addr_L4 <= current_wr_addr_L3; 
		current_rd_addr_L4 <= current_rd_addr_L3; 
		mem_wr_addr_L4 <= mem_wr_addr_L3; 
		backward_i_L4 <= backward_i_L3; 
		backward_j_L4 <= backward_j_L3; 
		output_c_L4 <= output_c_L3; 
		min_intv_L4 <= min_intv_L3; 
		iteration_boundary_L4 <= iteration_boundary_L3; 
		last_mem_info_L4 <= last_mem_info_L3; 
		last_token_x2_L4 <= last_token_x2_L3; 
		p_x0_L4 <= p_x0_L3; 
		p_x1_L4 <= p_x1_L3; 
		p_x2_L4 <= p_x2_L3; 
		p_info_L4 <= p_info_L3; 
		backward_x_L4 <= backward_x_L3; 
		read_num_L5 <= read_num_L4; 
		status_L5 <= status_L4; 
		forward_size_n_L5 <= forward_size_n_L4; 
		new_size_L5 <= new_size_L4; 
		new_last_size_L5 <= new_last_size_L4; 
		primary_L5 <= primary_L4; 
		current_wr_addr_L5 <= current_wr_addr_L4; 
		current_rd_addr_L5 <= current_rd_addr_L4; 
		mem_wr_addr_L5 <= mem_wr_addr_L4; 
		backward_i_L5 <= backward_i_L4; 
		backward_j_L5 <= backward_j_L4; 
		output_c_L5 <= output_c_L4; 
		min_intv_L5 <= min_intv_L4; 
		iteration_boundary_L5 <= iteration_boundary_L4; 
		last_mem_info_L5 <= last_mem_info_L4; 
		last_token_x2_L5 <= last_token_x2_L4; 
		p_x0_L5 <= p_x0_L4; 
		p_x1_L5 <= p_x1_L4; 
		p_x2_L5 <= p_x2_L4; 
		p_info_L5 <= p_info_L4; 
		backward_x_L5 <= backward_x_L4; 
		read_num_L6 <= read_num_L5; 
		status_L6 <= status_L5; 
		forward_size_n_L6 <= forward_size_n_L5; 
		new_size_L6 <= new_size_L5; 
		new_last_size_L6 <= new_last_size_L5; 
		primary_L6 <= primary_L5; 
		current_wr_addr_L6 <= current_wr_addr_L5; 
		current_rd_addr_L6 <= current_rd_addr_L5; 
		mem_wr_addr_L6 <= mem_wr_addr_L5; 
		backward_i_L6 <= backward_i_L5; 
		backward_j_L6 <= backward_j_L5; 
		output_c_L6 <= output_c_L5; 
		min_intv_L6 <= min_intv_L5; 
		iteration_boundary_L6 <= iteration_boundary_L5; 
		last_mem_info_L6 <= last_mem_info_L5; 
		last_token_x2_L6 <= last_token_x2_L5; 
		p_x0_L6 <= p_x0_L5; 
		p_x1_L6 <= p_x1_L5; 
		p_x2_L6 <= p_x2_L5; 
		p_info_L6 <= p_info_L5; 
		backward_x_L6 <= backward_x_L5; 
		read_num_L7 <= read_num_L6; 
		status_L7 <= status_L6; 
		forward_size_n_L7 <= forward_size_n_L6; 
		new_size_L7 <= new_size_L6; 
		new_last_size_L7 <= new_last_size_L6; 
		primary_L7 <= primary_L6; 
		current_wr_addr_L7 <= current_wr_addr_L6; 
		current_rd_addr_L7 <= current_rd_addr_L6; 
		mem_wr_addr_L7 <= mem_wr_addr_L6; 
		backward_i_L7 <= backward_i_L6; 
		backward_j_L7 <= backward_j_L6; 
		output_c_L7 <= output_c_L6; 
		min_intv_L7 <= min_intv_L6; 
		iteration_boundary_L7 <= iteration_boundary_L6; 
		last_mem_info_L7 <= last_mem_info_L6; 
		last_token_x2_L7 <= last_token_x2_L6; 
		p_x0_L7 <= p_x0_L6; 
		p_x1_L7 <= p_x1_L6; 
		p_x2_L7 <= p_x2_L6; 
		p_info_L7 <= p_info_L6; 
		backward_x_L7 <= backward_x_L6; 
		read_num_L8 <= read_num_L7; 
		status_L8 <= status_L7; 
		forward_size_n_L8 <= forward_size_n_L7; 
		new_size_L8 <= new_size_L7; 
		new_last_size_L8 <= new_last_size_L7; 
		primary_L8 <= primary_L7; 
		current_wr_addr_L8 <= current_wr_addr_L7; 
		current_rd_addr_L8 <= current_rd_addr_L7; 
		mem_wr_addr_L8 <= mem_wr_addr_L7; 
		backward_i_L8 <= backward_i_L7; 
		backward_j_L8 <= backward_j_L7; 
		output_c_L8 <= output_c_L7; 
		min_intv_L8 <= min_intv_L7; 
		iteration_boundary_L8 <= iteration_boundary_L7; 
		last_mem_info_L8 <= last_mem_info_L7; 
		last_token_x2_L8 <= last_token_x2_L7; 
		p_x0_L8 <= p_x0_L7; 
		p_x1_L8 <= p_x1_L7; 
		p_x2_L8 <= p_x2_L7; 
		p_info_L8 <= p_info_L7; 
		backward_x_L8 <= backward_x_L7; 
		read_num_L9 <= read_num_L8; 
		status_L9 <= status_L8; 
		forward_size_n_L9 <= forward_size_n_L8; 
		new_size_L9 <= new_size_L8; 
		new_last_size_L9 <= new_last_size_L8; 
		primary_L9 <= primary_L8; 
		current_wr_addr_L9 <= current_wr_addr_L8; 
		current_rd_addr_L9 <= current_rd_addr_L8; 
		mem_wr_addr_L9 <= mem_wr_addr_L8; 
		backward_i_L9 <= backward_i_L8; 
		backward_j_L9 <= backward_j_L8; 
		output_c_L9 <= output_c_L8; 
		min_intv_L9 <= min_intv_L8; 
		iteration_boundary_L9 <= iteration_boundary_L8; 
		last_mem_info_L9 <= last_mem_info_L8; 
		last_token_x2_L9 <= last_token_x2_L8; 
		p_x0_L9 <= p_x0_L8; 
		p_x1_L9 <= p_x1_L8; 
		p_x2_L9 <= p_x2_L8; 
		p_info_L9 <= p_info_L8; 
		backward_x_L9 <= backward_x_L8; 
		read_num_L10 <= read_num_L9; 
		status_L10 <= status_L9; 
		forward_size_n_L10 <= forward_size_n_L9; 
		new_size_L10 <= new_size_L9; 
		new_last_size_L10 <= new_last_size_L9; 
		primary_L10 <= primary_L9; 
		current_wr_addr_L10 <= current_wr_addr_L9; 
		current_rd_addr_L10 <= current_rd_addr_L9; 
		mem_wr_addr_L10 <= mem_wr_addr_L9; 
		backward_i_L10 <= backward_i_L9; 
		backward_j_L10 <= backward_j_L9; 
		output_c_L10 <= output_c_L9; 
		min_intv_L10 <= min_intv_L9; 
		iteration_boundary_L10 <= iteration_boundary_L9; 
		last_mem_info_L10 <= last_mem_info_L9; 
		last_token_x2_L10 <= last_token_x2_L9; 
		p_x0_L10 <= p_x0_L9; 
		p_x1_L10 <= p_x1_L9; 
		p_x2_L10 <= p_x2_L9; 
		p_info_L10 <= p_info_L9; 
		backward_x_L10 <= backward_x_L9; 
		read_num_L11 <= read_num_L10; 
		status_L11 <= status_L10; 
		forward_size_n_L11 <= forward_size_n_L10; 
		new_size_L11 <= new_size_L10; 
		new_last_size_L11 <= new_last_size_L10; 
		primary_L11 <= primary_L10; 
		current_wr_addr_L11 <= current_wr_addr_L10; 
		current_rd_addr_L11 <= current_rd_addr_L10; 
		mem_wr_addr_L11 <= mem_wr_addr_L10; 
		backward_i_L11 <= backward_i_L10; 
		backward_j_L11 <= backward_j_L10; 
		output_c_L11 <= output_c_L10; 
		min_intv_L11 <= min_intv_L10; 
		iteration_boundary_L11 <= iteration_boundary_L10; 
		last_mem_info_L11 <= last_mem_info_L10; 
		last_token_x2_L11 <= last_token_x2_L10; 
		p_x0_L11 <= p_x0_L10; 
		p_x1_L11 <= p_x1_L10; 
		p_x2_L11 <= p_x2_L10; 
		p_info_L11 <= p_info_L10; 
		backward_x_L11 <= backward_x_L10; 
		read_num_L12 <= read_num_L11; 
		status_L12 <= status_L11; 
		forward_size_n_L12 <= forward_size_n_L11; 
		new_size_L12 <= new_size_L11; 
		new_last_size_L12 <= new_last_size_L11; 
		primary_L12 <= primary_L11; 
		current_wr_addr_L12 <= current_wr_addr_L11; 
		current_rd_addr_L12 <= current_rd_addr_L11; 
		mem_wr_addr_L12 <= mem_wr_addr_L11; 
		backward_i_L12 <= backward_i_L11; 
		backward_j_L12 <= backward_j_L11; 
		output_c_L12 <= output_c_L11; 
		min_intv_L12 <= min_intv_L11; 
		iteration_boundary_L12 <= iteration_boundary_L11; 
		last_mem_info_L12 <= last_mem_info_L11; 
		last_token_x2_L12 <= last_token_x2_L11; 
		p_x0_L12 <= p_x0_L11; 
		p_x1_L12 <= p_x1_L11; 
		p_x2_L12 <= p_x2_L11; 
		p_info_L12 <= p_info_L11; 
		backward_x_L12 <= backward_x_L11; 
		end
   end
  	
   //-------------------------------
	
	//=================================================
	wire [63:0] ik_x0_L0, ik_x1_L0, ik_x2_L0;
	reg  [63:0] ik_x0_L1, ik_x1_L1, ik_x2_L1;
	wire [63:0] ikorp_x0,ikorp_x1,ikorp_x2;
	wire forward_all_done_L0;
	reg forward_all_done_L1;
	reg forward_all_done_L2;
	reg forward_all_done_L3;
	reg forward_all_done_L4;
	assign ikorp_x0 = forward_all_done ? p_x0_q : ik_x0;
	assign ikorp_x1 = forward_all_done ? p_x1_q : ik_x1;
	assign ikorp_x2 = forward_all_done ? p_x2_q : ik_x2;
	always @(posedge Clk_32UI) begin
		if(!reset_BWT_extend) begin
			L2_0   	<= 64'h0000_0000_0000_0000; 
			L2_1   	<= 64'h0000_0000_6bfa_2ffe; 
			L2_2   	<= 64'h0000_0000_b8e1_c8c3; 
			L2_3   	<= 64'h0000_0001_05c9_6188; 
		end
	end
	
	wire [63:0] ik_x0_L0_ik_x2_L0_A;
	wire [63:0] ik_x1_L0_ik_x2_L0_B;
	
	Pipe_yth pipe(
		.Clk_32UI(Clk_32UI),
		.stall(stall),	
		.ik_x0(ikorp_x0),
		.ik_x1(ikorp_x1),
		.ik_x2(ikorp_x2),
		.forward_all_done(forward_all_done),

		
		.ik_x0_pipe(ik_x0_L0),
		.ik_x1_pipe(ik_x1_L0),
		.ik_x2_pipe(ik_x2_L0),
		.ik_x0_L0_ik_x2_L0_A(ik_x0_L0_ik_x2_L0_A),
		.ik_x1_L0_ik_x2_L0_B(ik_x1_L0_ik_x2_L0_B),
		.forward_all_done_pipe(forward_all_done_L0)		

	);
	
	reg [63:0] ok0_x2_L1, ok1_x2_L1, ok2_x2_L1, ok3_x2_L1;
	reg [63:0] ok0_x2_L2, ok1_x2_L2, ok2_x2_L2, ok3_x2_L2;
	reg [63:0] ok0_x2_L3, ok1_x2_L3, ok2_x2_L3, ok3_x2_L3;
	reg [63:0] ok0_x2_L4, ok1_x2_L4, ok2_x2_L4, ok3_x2_L4;
	
	reg [63:0] ok0_x1_L1, ok1_x1_L1, ok2_x1_L1, ok3_x1_L1;
	reg [63:0] ok0_x1_L2, ok1_x1_L2, ok2_x1_L2, ok3_x1_L2;
	reg [63:0] ok0_x1_L3, ok1_x1_L3, ok2_x1_L3, ok3_x1_L3;
	reg [63:0] ok0_x1_L4, ok1_x1_L4, ok2_x1_L4, ok3_x1_L4;
	
	reg [63:0] ok0_x0_L1, ok1_x0_L1, ok2_x0_L1, ok3_x0_L1;
	reg [63:0] ok0_x0_L2, ok1_x0_L2, ok2_x0_L2, ok3_x0_L2;
	reg [63:0] ok0_x0_L3, ok1_x0_L3, ok2_x0_L3, ok3_x0_L3;
	reg [63:0] ok0_x0_L4, ok1_x0_L4, ok2_x0_L4, ok3_x0_L4;

	reg is_x1_add_A, is_x1_add_B, is_x0_add_C, is_x0_add_D;
	wire [63:0] primary_add_1 = primary + 1;
	// L1 ///level8
	always@(posedge Clk_32UI) begin
	if(stall) begin
		ok0_x2_L1 <= ok0_x2_L1;
		ok1_x2_L1 <= ok1_x2_L1;
		ok2_x2_L1 <= ok2_x2_L1;
		ok3_x2_L1 <= ok3_x2_L1;   
		
		ok0_x0_L1 <= ok0_x0_L1;
		ok1_x0_L1 <= ok1_x0_L1;
		ok2_x0_L1 <= ok2_x0_L1;
		ok3_x0_L1 <= ok3_x0_L1;
		ok0_x1_L1 <= ok0_x1_L1;
		ok1_x1_L1 <= ok1_x1_L1;
		ok2_x1_L1 <= ok2_x1_L1;
		ok3_x1_L1 <= ok3_x1_L1;			

		ik_x1_L1 <= ik_x1_L1;
		ik_x0_L1 <= ik_x0_L1;
		forward_all_done_L1 <= forward_all_done_L1;
	end
	else begin
		ok0_x2_L1 <= cnt_tl_out0 - cnt_tk_out0;
		ok1_x2_L1 <= cnt_tl_out1 - cnt_tk_out1;
		ok2_x2_L1 <= cnt_tl_out2 - cnt_tk_out2;
		ok3_x2_L1 <= cnt_tl_out3 - cnt_tk_out3;   
		

			ok0_x0_L1 <= L2_0 + cnt_tk_out0 + 1;
			ok1_x0_L1 <= L2_1 + cnt_tk_out1 + 1;
			ok2_x0_L1 <= L2_2 + cnt_tk_out2 + 1;
			ok3_x0_L1 <= L2_3 + cnt_tk_out3 + 1;
			
			is_x1_add_A <= (ik_x0_L0 <= primary);
			is_x1_add_B <= (ik_x0_L0_ik_x2_L0_A - 1 >= primary); // for use in next stage		

		
		ik_x1_L1 <= ik_x1_L0;
		ik_x0_L1 <= ik_x0_L0;
		forward_all_done_L1 <= forward_all_done_L0;
	end

	end
	
	//L2 ///level9
	always@(posedge Clk_32UI) begin
	if(stall) begin
		ok0_x1_L2 <= ok0_x1_L2;
		ok1_x1_L2 <= ok1_x1_L2;
		ok2_x1_L2 <= ok2_x1_L2;
		ok3_x1_L2 <= ok3_x1_L2;

		
		ok0_x0_L2 <= ok0_x0_L2;
		ok1_x0_L2 <= ok1_x0_L2;
		ok2_x0_L2 <= ok2_x0_L2;
		ok3_x0_L2 <= ok3_x0_L2;

		forward_all_done_L2 <= forward_all_done_L2;
		ok0_x2_L2 <= ok0_x2_L2;
		ok1_x2_L2 <= ok1_x2_L2;
		ok2_x2_L2 <= ok2_x2_L2;
		ok3_x2_L2 <= ok3_x2_L2;   
	end
	else begin

			ok3_x1_L2 <= ik_x1_L1 + (is_x1_add_A & is_x1_add_B);
			
			ok0_x0_L2 <= ok0_x0_L1;
			ok1_x0_L2 <= ok1_x0_L1;
			ok2_x0_L2 <= ok2_x0_L1;
			ok3_x0_L2 <= ok3_x0_L1;

		

		
		forward_all_done_L2 <= forward_all_done_L1;
		ok0_x2_L2 <= ok0_x2_L1;
		ok1_x2_L2 <= ok1_x2_L1;
		ok2_x2_L2 <= ok2_x2_L1;
		ok3_x2_L2 <= ok3_x2_L1;   
	end
		
	end
	 
	//L3 ///level10
	always@(posedge Clk_32UI) begin
	if(stall) begin	
		ok0_x0_L3 <= ok0_x0_L3;
		ok1_x0_L3 <= ok1_x0_L3;
		ok2_x0_L3 <= ok2_x0_L3;
		ok3_x0_L3 <= ok3_x0_L3;
 			
		ok0_x1_L3 <= ok0_x1_L3;
		ok1_x1_L3 <= ok1_x1_L3;
		ok2_x1_L3 <= ok2_x1_L3;
		ok3_x1_L3 <= ok3_x1_L3;

		forward_all_done_L3 <= forward_all_done_L3;
		ok0_x2_L3 <= ok0_x2_L3;
		ok1_x2_L3 <= ok1_x2_L3;
		ok2_x2_L3 <= ok2_x2_L3;
		ok3_x2_L3 <= ok3_x2_L3;  
	end
	else begin

			ok2_x1_L3 <= ok3_x1_L2 + ok3_x2_L2;
			
			ok3_x1_L3 <= ok3_x1_L2;
			
			ok0_x0_L3 <= ok0_x0_L2;
			ok1_x0_L3 <= ok1_x0_L2;
			ok2_x0_L3 <= ok2_x0_L2;
			ok3_x0_L3 <= ok3_x0_L2;

		
		forward_all_done_L3 <= forward_all_done_L2;
		ok0_x2_L3 <= ok0_x2_L2;
		ok1_x2_L3 <= ok1_x2_L2;
		ok2_x2_L3 <= ok2_x2_L2;
		ok3_x2_L3 <= ok3_x2_L2;  
	end
		
	end
	
	//L4   ///level11
	always@(posedge Clk_32UI) begin
		if(stall) begin
			ok0_x0_L4 <= ok0_x0_L4;
			ok1_x0_L4 <= ok1_x0_L4;
			ok2_x0_L4 <= ok2_x0_L4;
			ok3_x0_L4 <= ok3_x0_L4;
					
			ok0_x1_L4 <= ok0_x1_L4;
			ok1_x1_L4 <= ok1_x1_L4;
			ok2_x1_L4 <= ok2_x1_L4;
			ok3_x1_L4 <= ok3_x1_L4;
		
			forward_all_done_L4 <= forward_all_done_L4;
			ok0_x2_L4 <= ok0_x2_L4;
			ok1_x2_L4 <= ok1_x2_L4;
			ok2_x2_L4 <= ok2_x2_L4;
			ok3_x2_L4 <= ok3_x2_L4;   
		end
		else begin

				ok1_x1_L4 <= ok2_x1_L3 + ok2_x2_L3;
			
				ok2_x1_L4 <= ok2_x1_L3;
				ok3_x1_L4 <= ok3_x1_L3;
			
				ok0_x0_L4 <= ok0_x0_L3;
				ok1_x0_L4 <= ok1_x0_L3;
				ok2_x0_L4 <= ok2_x0_L3;
				ok3_x0_L4 <= ok3_x0_L3;

		
			forward_all_done_L4 <= forward_all_done_L3;
			ok0_x2_L4 <= ok0_x2_L3;
			ok1_x2_L4 <= ok1_x2_L3;
			ok2_x2_L4 <= ok2_x2_L3;
			ok3_x2_L4 <= ok3_x2_L3;   
		end
	end
	
	//L5   ///level12
	always@(posedge Clk_32UI) begin
	if(stall) begin
		ok0_x0 <= ok0_x0;
		ok1_x0 <= ok1_x0;
		ok2_x0 <= ok2_x0;
		ok3_x0 <= ok3_x0;
			
		ok0_x1 <= ok0_x1;
		ok1_x1 <= ok1_x1;
		ok2_x1 <= ok2_x1;
		ok3_x1 <= ok3_x1;

		
		ok0_x2 <= ok0_x2;
		ok1_x2 <= ok1_x2;
		ok2_x2 <= ok2_x2;
		ok3_x2 <= ok3_x2;   
	end
	else begin

			ok0_x1 <= ok1_x1_L4 + ok1_x2_L4;
			ok1_x1 <= ok1_x1_L4;
			ok2_x1 <= ok2_x1_L4;
			ok3_x1 <= ok3_x1_L4;
			
			ok0_x0 <= ok0_x0_L4;
			ok1_x0 <= ok1_x0_L4;
			ok2_x0 <= ok2_x0_L4;
			ok3_x0 <= ok3_x0_L4;

		
		ok0_x2 <= ok0_x2_L4;
		ok1_x2 <= ok1_x2_L4;
		ok2_x2 <= ok2_x2_L4;
		ok3_x2 <= ok3_x2_L4;   
		
		ok_b_temp_x0 <= output_c_L11[1]? (output_c_L11[0]?ok3_x0_L4:ok2_x0_L4) : (output_c_L11[0]?ok1_x0_L4:ok0_x0_L4);
		ok_b_temp_x1 <= output_c_L11[1]? (output_c_L11[0]?ok3_x1_L4:ok2_x1_L4) : (output_c_L11[0]?ok1_x1_L4:ok1_x1_L4 + ok1_x2_L4);
		ok_b_temp_x2 <= output_c_L11[1]? (output_c_L11[0]?ok3_x2_L4:ok2_x2_L4) : (output_c_L11[0]?ok1_x2_L4:ok0_x2_L4);
	end

	end
		
endmodule

////////////////////////////////////////////////////
// BWT_OCC4                                       //
////////////////////////////////////////////////////

//calculate cnt0123, at the same time register the input using the "pipe"
module BWT_OCC4_lc(
	input reset_BWT_extend,
	input stall,
   input Clk_32UI,

   input [63:0] k,
   input [31:0] cnt_a0,cnt_a1,cnt_a2,cnt_a3,
   input [63:0] cnt_b0,cnt_b1,cnt_b2,cnt_b3,

   output reg [31:0] cnt_out0,cnt_out1,cnt_out2,cnt_out3
);

   wire [63:0] x_new_reg;
   wire [31:0] mask;
   
   reg [31:0] ram1[255:0];
   reg [31:0] ram2[255:0];
 
   reg[31:0] x_reg, x_licheng, x_licheng_q, x_licheng_r;
   reg [2:0] mem_counter_q,mem_counter_q1,mem_counter_q2;  
	
	//assign loop_times = k[6:4];
	assign mask = ~((1<<((~k & 15)<<1)) - 1);
	reg[31:0]  tmp_q;
	reg[31:0]  tmp;
	
	//------------------------------------------------
	//level 1
	reg [63:0] k_L1;
	reg [31:0] cnt_a0_L1,cnt_a1_L1,cnt_a2_L1,cnt_a3_L1;
    reg [63:0] cnt_b0_L1,cnt_b1_L1,cnt_b2_L1,cnt_b3_L1;
	
	always@(*)
	begin
		case(k[6:4])
			3'd0: tmp = cnt_b0[31:0] & mask;
			3'd1: tmp = cnt_b0[63:32] & mask;
			3'd2: tmp = cnt_b1[31:0] & mask;
			3'd3: tmp = cnt_b1[63:32] & mask;
			3'd4: tmp = cnt_b2[31:0] & mask;
			3'd5: tmp = cnt_b2[63:32] & mask;
			3'd6: tmp = cnt_b3[31:0] & mask;
			3'd7: tmp = cnt_b3[63:32] & mask;
			default: tmp = 0;
		endcase
	end
	
	reg debug1;
	always@(posedge Clk_32UI) begin
		if(!reset_BWT_extend) begin
			debug1 <= 1;
			cnt_b0_L1 <= 0;
			cnt_a0_L1 <= 0;
			tmp_q <= 0;
			k_L1 <= 0;
			cnt_a1_L1 <= 0; 
			cnt_a2_L1 <= 0; 
			cnt_a3_L1 <= 0;
			cnt_b1_L1 <= 0; 
			cnt_b2_L1 <= 0; 
			cnt_b3_L1 <= 0;
		end
		else if(stall) begin //stall == 1  stalls
			debug1 <= 2;
			cnt_b0_L1 <= cnt_b0_L1;
			cnt_a0_L1 <= cnt_a0_L1;
			tmp_q <= tmp_q;
			k_L1 <= k_L1;
			cnt_a1_L1 <= cnt_a1_L1; 
			cnt_a2_L1 <= cnt_a2_L1; 
			cnt_a3_L1 <= cnt_a3_L1;
			cnt_b1_L1 <= cnt_b1_L1; 
			cnt_b2_L1 <= cnt_b2_L1; 
			cnt_b3_L1 <= cnt_b3_L1;
		end
		else begin
			debug1 <= 3;
			cnt_b0_L1 <= cnt_b0;
			cnt_a0_L1 <= cnt_a0;
			tmp_q <= tmp;
			k_L1 <= k;
			cnt_a1_L1 <= cnt_a1; 
			cnt_a2_L1 <= cnt_a2; 
			cnt_a3_L1 <= cnt_a3;
			cnt_b1_L1 <= cnt_b1; 
			cnt_b2_L1 <= cnt_b2; 
			cnt_b3_L1 <= cnt_b3;
		end
	end
	
	//------------------------------------------------
	//level 2
	reg[31:0] sum1_r, sum2_r, sum3_r, sum4_r, sum5_r, sum6_r, sum7_r, sum8_r;
	
    reg[31:0] sum1, sum2, sum3, sum4, sum5, sum6, sum7, sum8;
	reg[31:0] sum1_q, sum2_q, sum3_q, sum4_q, sum5_q, sum6_q, sum7_q, sum8_q;
	reg[31:0] sum1_qq, sum2_qq, sum3_qq, sum4_qq, sum5_qq, sum6_qq, sum7_qq, sum8_qq;
	
	reg[31:0] sum1_1, sum2_1, sum3_1, sum4_1, sum5_1, sum6_1, sum7_1, sum8_1;
	reg[31:0] sum1_2, sum2_2, sum3_2, sum4_2, sum5_2, sum6_2, sum7_2, sum8_2;
	
	reg[31:0] sum1_1_q, sum2_1_q, sum3_1_q, sum4_1_q, sum5_1_q, sum6_1_q, sum7_1_q, sum8_1_q;
	reg[31:0] sum1_2_q, sum2_2_q, sum3_2_q, sum4_2_q, sum5_2_q, sum6_2_q, sum7_2_q, sum8_2_q;
	
	reg [63:0] k_L2;
	reg [31:0] cnt_a0_L2,cnt_a1_L2,cnt_a2_L2,cnt_a3_L2;
	
	always@(*) begin
		sum1_1 = ram2[tmp_q[7:0]] + ram2[tmp_q[15:8]];
		sum1_2 = ram2[tmp_q[23:16]] + ram2[tmp_q[31:24]];
		
		sum2_1 = ram2[cnt_b0_L1[7:0]] + ram2[cnt_b0_L1[15:8]];
		sum2_2 = ram2[cnt_b0_L1[23:16]] + ram2[cnt_b0_L1[31:24]];
		
		sum3_1 = ram2[cnt_b0_L1[39:32]] + ram2[cnt_b0_L1[47:40]];
		sum3_2 = ram2[cnt_b0_L1[55:48]] + ram2[cnt_b0_L1[63:56]];
		
		sum4_1 = ram2[cnt_b1_L1[7:0]] + ram2[cnt_b1_L1[15:8]];
		sum4_2 = ram2[cnt_b1_L1[23:16]] + ram2[cnt_b1_L1[31:24]];
		
		sum5_1 = ram2[cnt_b1_L1[39:32]] + ram2[cnt_b1_L1[47:40]];
		sum5_2 = ram2[cnt_b1_L1[55:48]] + ram2[cnt_b1_L1[63:56]];
		
		sum6_1 = ram2[cnt_b2_L1[7:0]] + ram2[cnt_b2_L1[15:8]];
		sum6_2 = ram2[cnt_b2_L1[23:16]] + ram2[cnt_b2_L1[31:24]];
		
		sum7_1 = ram2[cnt_b2_L1[39:32]] + ram2[cnt_b2_L1[47:40]];
		sum7_2 = ram2[cnt_b2_L1[55:48]] + ram2[cnt_b2_L1[63:56]];
		
		sum8_1 = ram2[cnt_b3_L1[7:0]] + ram2[cnt_b3_L1[15:8]];
		sum8_2 = ram2[cnt_b3_L1[23:16]] + ram2[cnt_b3_L1[31:24]];
	end
	
	always@(posedge Clk_32UI) begin
		if(!reset_BWT_extend) begin
			sum1_1_q <= 0;
			sum1_2_q <= 0;
		
			sum2_1_q <= 0;
			sum2_2_q <= 0;
		
			sum3_1_q <= 0;
			sum3_2_q <= 0;
		
			sum4_1_q <= 0;
			sum4_2_q <= 0;
		
			sum5_1_q <= 0;
			sum5_2_q <= 0;
		
			sum6_1_q <= 0;
			sum6_2_q <= 0;
		
			sum7_1_q <= 0;
			sum7_2_q <= 0;
		
			sum8_1_q <= 0;
			sum8_2_q <= 0;	
		
			k_L2 <= 0;
			cnt_a0_L2 <= 0;
			cnt_a1_L2 <= 0; 
			cnt_a2_L2 <= 0; 
			cnt_a3_L2 <= 0;
		end
		else if(stall) begin 
			sum1_1_q <= sum1_1_q;
			sum1_2_q <= sum1_2_q;
		
			sum2_1_q <= sum2_1_q;
			sum2_2_q <= sum2_2_q;
		
			sum3_1_q <= sum3_1_q;
			sum3_2_q <= sum3_2_q;
		
			sum4_1_q <= sum4_1_q;
			sum4_2_q <= sum4_2_q;
		
			sum5_1_q <= sum5_1_q;
			sum5_2_q <= sum5_2_q;
		
			sum6_1_q <= sum6_1_q;
			sum6_2_q <= sum6_2_q;
		
			sum7_1_q <= sum7_1_q;
			sum7_2_q <= sum7_2_q;
		
			sum8_1_q <= sum8_1_q;
			sum8_2_q <= sum8_2_q;	
		
			k_L2 <= k_L2;
			cnt_a0_L2 <= cnt_a0_L2;
			cnt_a1_L2 <= cnt_a1_L2; 
			cnt_a2_L2 <= cnt_a2_L2; 
			cnt_a3_L2 <= cnt_a3_L2;
		end
		else begin 
			sum1_1_q <= sum1_1;
			sum1_2_q <= sum1_2;
		
			sum2_1_q <= sum2_1;
			sum2_2_q <= sum2_2;
		
			sum3_1_q <= sum3_1;
			sum3_2_q <= sum3_2;
		
			sum4_1_q <= sum4_1;
			sum4_2_q <= sum4_2;
		
			sum5_1_q <= sum5_1;
			sum5_2_q <= sum5_2;
		
			sum6_1_q <= sum6_1;
			sum6_2_q <= sum6_2;
		
			sum7_1_q <= sum7_1;
			sum7_2_q <= sum7_2;
		
			sum8_1_q <= sum8_1;
			sum8_2_q <= sum8_2;	
		
			k_L2 <= k_L1;
			cnt_a0_L2 <= cnt_a0_L1;
			cnt_a1_L2 <= cnt_a1_L1; 
			cnt_a2_L2 <= cnt_a2_L1; 
			cnt_a3_L2 <= cnt_a3_L1;
		end
	end
	
	//------------------------------------------------
	//level 3
	
	reg [63:0] k_L3;
	reg [31:0] cnt_a0_L3,cnt_a1_L3,cnt_a2_L3,cnt_a3_L3;
	
	always@(*) begin
		sum1 = sum1_1_q + sum1_2_q;
		sum2 = sum2_1_q + sum2_2_q;
		sum3 = sum3_1_q + sum3_2_q;
		sum4 = sum4_1_q + sum4_2_q;
		sum5 = sum5_1_q + sum5_2_q;
		sum6 = sum6_1_q + sum6_2_q;
		sum7 = sum7_1_q + sum7_2_q;
		sum8 = sum8_1_q + sum8_2_q;
	end
	
	always@(posedge Clk_32UI) begin
		if(!reset_BWT_extend) begin
		sum1_q <= 0;
		sum2_q <= 0;
		sum3_q <= 0;
		sum4_q <= 0;
		sum5_q <= 0;
		sum6_q <= 0;
		sum7_q <= 0;
		sum8_q <= 0;
		
		k_L3 <= 0;
		cnt_a0_L3 <= 0;
		cnt_a1_L3 <= 0; 
		cnt_a2_L3 <= 0; 
		cnt_a3_L3 <= 0;		
		end
		else if(stall) begin
		sum1_q <= sum1_q;
		sum2_q <= sum2_q;
		sum3_q <= sum3_q;
		sum4_q <= sum4_q;
		sum5_q <= sum5_q;
		sum6_q <= sum6_q;
		sum7_q <= sum7_q;
		sum8_q <= sum8_q;
		
		k_L3 <= k_L3;
		cnt_a0_L3 <= cnt_a0_L3;
		cnt_a1_L3 <= cnt_a1_L3; 
		cnt_a2_L3 <= cnt_a2_L3; 
		cnt_a3_L3 <= cnt_a3_L3;		
		end
		else begin 
		sum1_q <= sum1;
		sum2_q <= sum2;
		sum3_q <= sum3;
		sum4_q <= sum4;
		sum5_q <= sum5;
		sum6_q <= sum6;
		sum7_q <= sum7;
		sum8_q <= sum8;
		
		k_L3 <= k_L2;
		cnt_a0_L3 <= cnt_a0_L2;
		cnt_a1_L3 <= cnt_a1_L2; 
		cnt_a2_L3 <= cnt_a2_L2; 
		cnt_a3_L3 <= cnt_a3_L2;		
		end 
		
	end
	
	//------------------------------------------------
	//level 4
	
	reg [31:0] total_12, total_34, total_56, total_78;
	reg [31:0] total_12_q, total_34_q, total_56_q, total_78_q;
	
	reg [31:0] total_1, total_5, total_123, total_567, total_1234, total_5678;
	reg [31:0] total_1_q, total_5_q, total_123_q, total_567_q, total_1234_q, total_5678_q;
	
	reg [31:0] total_12_qq, total_56_qq;
	
	reg [63:0] k_L4;
	reg [31:0] cnt_a0_L4,cnt_a1_L4,cnt_a2_L4,cnt_a3_L4;
	
	always@(*) begin
		total_12 = sum1_q + sum2_q;
		total_34 = sum3_q + sum4_q;
		total_56 = sum5_q + sum6_q;
		total_78 = sum7_q + sum8_q;	
	end
	
	always@(posedge Clk_32UI) begin
		if(!reset_BWT_extend) begin
		total_12_q <= 0;
		total_34_q <= 0;
		total_56_q <= 0;
		total_78_q <= 0;
		
		sum1_qq <= 0;
		sum3_qq <= 0;
		sum5_qq <= 0;
		sum7_qq <= 0;

		k_L4 <= 0;
		cnt_a0_L4 <= 0;
		cnt_a1_L4 <= 0; 
		cnt_a2_L4 <= 0; 
		cnt_a3_L4 <= 0;		
		end
		else if(stall) begin
		total_12_q <= total_12_q;
		total_34_q <= total_34_q;
		total_56_q <= total_56_q;
		total_78_q <= total_78_q;
		
		sum1_qq <= sum1_qq;

		sum3_qq <= sum3_qq;

		sum5_qq <= sum5_qq;

		sum7_qq <= sum7_qq;

		
		k_L4 <= k_L4;
		cnt_a0_L4 <= cnt_a0_L4;
		cnt_a1_L4 <= cnt_a1_L4; 
		cnt_a2_L4 <= cnt_a2_L4; 
		cnt_a3_L4 <= cnt_a3_L4;		
		end
		else begin 
		
		total_12_q <= total_12;
		total_34_q <= total_34;
		total_56_q <= total_56;
		total_78_q <= total_78;
		
		sum1_qq <= sum1_q;
		sum3_qq <= sum3_q;
		sum5_qq <= sum5_q;
		sum7_qq <= sum7_q;

		k_L4 <= k_L3;
		cnt_a0_L4 <= cnt_a0_L3;
		cnt_a1_L4 <= cnt_a1_L3; 
		cnt_a2_L4 <= cnt_a2_L3; 
		cnt_a3_L4 <= cnt_a3_L3;		
		end 
		
	end
	
	//------------------------------------------------
	//level 5

    reg [63:0] k_L5;
	reg [31:0] cnt_a0_L5,cnt_a1_L5,cnt_a2_L5,cnt_a3_L5;
	
	always@(*) begin
		total_1 = sum1_qq;
		// /*total_12 unchanged*/
		total_123 = total_12_q + sum3_qq;
		total_1234 = total_12_q + total_34_q;
		
		total_5 = sum5_qq;
		// /*total_56 unchanged*/
		total_567 = total_56_q + sum7_qq;
		total_5678 = total_56_q + total_78_q;
	end
	
	always@(posedge Clk_32UI) begin
		if(!reset_BWT_extend) begin
		total_1_q <= 0;
		total_12_qq <= 0;
		total_123_q <= 0;
		total_1234_q <= 0;
	
		total_5_q <= 0;
		total_56_qq <= 0;
		total_567_q <= 0;
		total_5678_q <= 0;
		
		k_L5 <= 0;
		cnt_a0_L5 <= 0;
		cnt_a1_L5 <= 0; 
		cnt_a2_L5 <= 0; 
		cnt_a3_L5 <= 0;		
		end
		else if(stall) begin
		total_1_q <= total_1_q;
		total_12_qq <= total_12_qq;
		total_123_q <= total_123_q;
		total_1234_q <= total_1234_q;
	
		total_5_q <= total_5_q;
		total_56_qq <= total_56_qq;
		total_567_q <= total_567_q;
		total_5678_q <= total_5678_q;
		
		k_L5 <= k_L5;
		cnt_a0_L5 <= cnt_a0_L5;
		cnt_a1_L5 <= cnt_a1_L5; 
		cnt_a2_L5 <= cnt_a2_L5; 
		cnt_a3_L5 <= cnt_a3_L5;		
		end
		else begin 
		total_1_q <= total_1;
		total_12_qq <= total_12_q;
		total_123_q <= total_123;
		total_1234_q <= total_1234;
	
		total_5_q <= total_5;
		total_56_qq <= total_56_q;
		total_567_q <= total_567;
		total_5678_q <= total_5678;
		
		k_L5 <= k_L4;
		cnt_a0_L5 <= cnt_a0_L4;
		cnt_a1_L5 <= cnt_a1_L4; 
		cnt_a2_L5 <= cnt_a2_L4; 
		cnt_a3_L5 <= cnt_a3_L4;
		end 
		
	end
	
	//------------------------------------------------
	//level 6

	reg [63:0] k_L6;
	reg [31:0] cnt_a0_L6,cnt_a1_L6,cnt_a2_L6,cnt_a3_L6;
	
	always@(*) begin
		case(k_L5[6:4])
			
			3'd0:x_licheng = total_1_q;
			3'd1:x_licheng = total_12_qq;
			3'd2:x_licheng = total_123_q;
			3'd3:x_licheng = total_1234_q;
			3'd4:x_licheng = total_1234_q + total_5_q;
			3'd5:x_licheng = total_1234_q + total_56_qq;
			3'd6:x_licheng = total_1234_q + total_567_q;
			3'd7:x_licheng = total_1234_q + total_5678_q;

			default: x_licheng = 0;
		endcase
	end
	
	always@(posedge Clk_32UI) begin
		if(!reset_BWT_extend) begin
		x_licheng_q <= 0;
		
		k_L6 <= 0;
		cnt_a0_L6 <= 0;
		cnt_a1_L6 <= 0; 
		cnt_a2_L6 <= 0; 
		cnt_a3_L6 <= 0;
		end
		else if(stall) begin
		x_licheng_q <= x_licheng_q;
		
		k_L6 <= k_L6;
		cnt_a0_L6 <= cnt_a0_L6;
		cnt_a1_L6 <= cnt_a1_L6; 
		cnt_a2_L6 <= cnt_a2_L6; 
		cnt_a3_L6 <= cnt_a3_L6;		
		end
		else begin 
		x_licheng_q <= x_licheng;
		
		k_L6 <= k_L5;
		cnt_a0_L6 <= cnt_a0_L5;
		cnt_a1_L6 <= cnt_a1_L5; 
		cnt_a2_L6 <= cnt_a2_L5; 
		cnt_a3_L6 <= cnt_a3_L5;		
		end 

	end
	
	//=================================================
	//------------------------------------------------
	//level 7
	   
   assign x_new_reg = x_licheng_q - (~k_L6 & 15); 
   
   always @(posedge Clk_32UI) begin
   		if(!reset_BWT_extend) begin
	   		cnt_out0 <= 0;
   			cnt_out1 <= 0;
   			cnt_out2 <= 0;
   			cnt_out3 <= 0;	
		end
		else if(stall) begin
			cnt_out0 <= cnt_out0;
   			cnt_out1 <= cnt_out1;
   			cnt_out2 <= cnt_out2;
   			cnt_out3 <= cnt_out3;  
		end
		else begin 
   			cnt_out0 <= cnt_a0_L6 + x_new_reg[7:0];
   			cnt_out1 <= cnt_a1_L6 + x_new_reg[15:8];
   			cnt_out2 <= cnt_a2_L6 + x_new_reg[23:16];
   			cnt_out3 <= cnt_a3_L6 + x_new_reg[31:24];  		
		end 
  			
   end  
   
   //======================================================================
	
	always @(posedge Clk_32UI) begin
		if(!reset_BWT_extend) begin
			ram2[0] <= 32'h4;
			ram2[1] <= 32'h103;
			ram2[2] <= 32'h10003;
			ram2[3] <= 32'h1000003;
			ram2[4] <= 32'h103;
			ram2[5] <= 32'h202;
			ram2[6] <= 32'h10102;
			ram2[7] <= 32'h1000102;
			ram2[8] <= 32'h10003;
			ram2[9] <= 32'h10102;
			ram2[10] <= 32'h20002;
			ram2[11] <= 32'h1010002;
			ram2[12] <= 32'h1000003;
			ram2[13] <= 32'h1000102;
			ram2[14] <= 32'h1010002;
			ram2[15] <= 32'h2000002;
			ram2[16] <= 32'h103;
			ram2[17] <= 32'h202;
			ram2[18] <= 32'h10102;
			ram2[19] <= 32'h1000102;
			ram2[20] <= 32'h202;
			ram2[21] <= 32'h301;
			ram2[22] <= 32'h10201;
			ram2[23] <= 32'h1000201;
			ram2[24] <= 32'h10102;
			ram2[25] <= 32'h10201;
			ram2[26] <= 32'h20101;
			ram2[27] <= 32'h1010101;
			ram2[28] <= 32'h1000102;
			ram2[29] <= 32'h1000201;
			ram2[30] <= 32'h1010101;
			ram2[31] <= 32'h2000101;
			ram2[32] <= 32'h10003;
			ram2[33] <= 32'h10102;
			ram2[34] <= 32'h20002;
			ram2[35] <= 32'h1010002;
			ram2[36] <= 32'h10102;
			ram2[37] <= 32'h10201;
			ram2[38] <= 32'h20101;
			ram2[39] <= 32'h1010101;
			ram2[40] <= 32'h20002;
			ram2[41] <= 32'h20101;
			ram2[42] <= 32'h30001;
			ram2[43] <= 32'h1020001;
			ram2[44] <= 32'h1010002;
			ram2[45] <= 32'h1010101;
			ram2[46] <= 32'h1020001;
			ram2[47] <= 32'h2010001;
			ram2[48] <= 32'h1000003;
			ram2[49] <= 32'h1000102;
			ram2[50] <= 32'h1010002;
			ram2[51] <= 32'h2000002;
			ram2[52] <= 32'h1000102;
			ram2[53] <= 32'h1000201;
			ram2[54] <= 32'h1010101;
			ram2[55] <= 32'h2000101;
			ram2[56] <= 32'h1010002;
			ram2[57] <= 32'h1010101;
			ram2[58] <= 32'h1020001;
			ram2[59] <= 32'h2010001;
			ram2[60] <= 32'h2000002;
			ram2[61] <= 32'h2000101;
			ram2[62] <= 32'h2010001;
			ram2[63] <= 32'h3000001;
			ram2[64] <= 32'h103;
			ram2[65] <= 32'h202;
			ram2[66] <= 32'h10102;
			ram2[67] <= 32'h1000102;
			ram2[68] <= 32'h202;
			ram2[69] <= 32'h301;
			ram2[70] <= 32'h10201;
			ram2[71] <= 32'h1000201;
			ram2[72] <= 32'h10102;
			ram2[73] <= 32'h10201;
			ram2[74] <= 32'h20101;
			ram2[75] <= 32'h1010101;
			ram2[76] <= 32'h1000102;
			ram2[77] <= 32'h1000201;
			ram2[78] <= 32'h1010101;
			ram2[79] <= 32'h2000101;
			ram2[80] <= 32'h202;
			ram2[81] <= 32'h301;
			ram2[82] <= 32'h10201;
			ram2[83] <= 32'h1000201;
			ram2[84] <= 32'h301;
			ram2[85] <= 32'h400;
			ram2[86] <= 32'h10300;
			ram2[87] <= 32'h1000300;
			ram2[88] <= 32'h10201;
			ram2[89] <= 32'h10300;
			ram2[90] <= 32'h20200;
			ram2[91] <= 32'h1010200;
			ram2[92] <= 32'h1000201;
			ram2[93] <= 32'h1000300;
			ram2[94] <= 32'h1010200;
			ram2[95] <= 32'h2000200;
			ram2[96] <= 32'h10102;
			ram2[97] <= 32'h10201;
			ram2[98] <= 32'h20101;
			ram2[99] <= 32'h1010101;
			ram2[100] <= 32'h10201;
			ram2[101] <= 32'h10300;
			ram2[102] <= 32'h20200;
			ram2[103] <= 32'h1010200;
			ram2[104] <= 32'h20101;
			ram2[105] <= 32'h20200;
			ram2[106] <= 32'h30100;
			ram2[107] <= 32'h1020100;
			ram2[108] <= 32'h1010101;
			ram2[109] <= 32'h1010200;
			ram2[110] <= 32'h1020100;
			ram2[111] <= 32'h2010100;
			ram2[112] <= 32'h1000102;
			ram2[113] <= 32'h1000201;
			ram2[114] <= 32'h1010101;
			ram2[115] <= 32'h2000101;
			ram2[116] <= 32'h1000201;
			ram2[117] <= 32'h1000300;
			ram2[118] <= 32'h1010200;
			ram2[119] <= 32'h2000200;
			ram2[120] <= 32'h1010101;
			ram2[121] <= 32'h1010200;
			ram2[122] <= 32'h1020100;
			ram2[123] <= 32'h2010100;
			ram2[124] <= 32'h2000101;
			ram2[125] <= 32'h2000200;
			ram2[126] <= 32'h2010100;
			ram2[127] <= 32'h3000100;
			ram2[128] <= 32'h10003;
			ram2[129] <= 32'h10102;
			ram2[130] <= 32'h20002;
			ram2[131] <= 32'h1010002;
			ram2[132] <= 32'h10102;
			ram2[133] <= 32'h10201;
			ram2[134] <= 32'h20101;
			ram2[135] <= 32'h1010101;
			ram2[136] <= 32'h20002;
			ram2[137] <= 32'h20101;
			ram2[138] <= 32'h30001;
			ram2[139] <= 32'h1020001;
			ram2[140] <= 32'h1010002;
			ram2[141] <= 32'h1010101;
			ram2[142] <= 32'h1020001;
			ram2[143] <= 32'h2010001;
			ram2[144] <= 32'h10102;
			ram2[145] <= 32'h10201;
			ram2[146] <= 32'h20101;
			ram2[147] <= 32'h1010101;
			ram2[148] <= 32'h10201;
			ram2[149] <= 32'h10300;
			ram2[150] <= 32'h20200;
			ram2[151] <= 32'h1010200;
			ram2[152] <= 32'h20101;
			ram2[153] <= 32'h20200;
			ram2[154] <= 32'h30100;
			ram2[155] <= 32'h1020100;
			ram2[156] <= 32'h1010101;
			ram2[157] <= 32'h1010200;
			ram2[158] <= 32'h1020100;
			ram2[159] <= 32'h2010100;
			ram2[160] <= 32'h20002;
			ram2[161] <= 32'h20101;
			ram2[162] <= 32'h30001;
			ram2[163] <= 32'h1020001;
			ram2[164] <= 32'h20101;
			ram2[165] <= 32'h20200;
			ram2[166] <= 32'h30100;
			ram2[167] <= 32'h1020100;
			ram2[168] <= 32'h30001;
			ram2[169] <= 32'h30100;
			ram2[170] <= 32'h40000;
			ram2[171] <= 32'h1030000;
			ram2[172] <= 32'h1020001;
			ram2[173] <= 32'h1020100;
			ram2[174] <= 32'h1030000;
			ram2[175] <= 32'h2020000;
			ram2[176] <= 32'h1010002;
			ram2[177] <= 32'h1010101;
			ram2[178] <= 32'h1020001;
			ram2[179] <= 32'h2010001;
			ram2[180] <= 32'h1010101;
			ram2[181] <= 32'h1010200;
			ram2[182] <= 32'h1020100;
			ram2[183] <= 32'h2010100;
			ram2[184] <= 32'h1020001;
			ram2[185] <= 32'h1020100;
			ram2[186] <= 32'h1030000;
			ram2[187] <= 32'h2020000;
			ram2[188] <= 32'h2010001;
			ram2[189] <= 32'h2010100;
			ram2[190] <= 32'h2020000;
			ram2[191] <= 32'h3010000;
			ram2[192] <= 32'h1000003;
			ram2[193] <= 32'h1000102;
			ram2[194] <= 32'h1010002;
			ram2[195] <= 32'h2000002;
			ram2[196] <= 32'h1000102;
			ram2[197] <= 32'h1000201;
			ram2[198] <= 32'h1010101;
			ram2[199] <= 32'h2000101;
			ram2[200] <= 32'h1010002;
			ram2[201] <= 32'h1010101;
			ram2[202] <= 32'h1020001;
			ram2[203] <= 32'h2010001;
			ram2[204] <= 32'h2000002;
			ram2[205] <= 32'h2000101;
			ram2[206] <= 32'h2010001;
			ram2[207] <= 32'h3000001;
			ram2[208] <= 32'h1000102;
			ram2[209] <= 32'h1000201;
			ram2[210] <= 32'h1010101;
			ram2[211] <= 32'h2000101;
			ram2[212] <= 32'h1000201;
			ram2[213] <= 32'h1000300;
			ram2[214] <= 32'h1010200;
			ram2[215] <= 32'h2000200;
			ram2[216] <= 32'h1010101;
			ram2[217] <= 32'h1010200;
			ram2[218] <= 32'h1020100;
			ram2[219] <= 32'h2010100;
			ram2[220] <= 32'h2000101;
			ram2[221] <= 32'h2000200;
			ram2[222] <= 32'h2010100;
			ram2[223] <= 32'h3000100;
			ram2[224] <= 32'h1010002;
			ram2[225] <= 32'h1010101;
			ram2[226] <= 32'h1020001;
			ram2[227] <= 32'h2010001;
			ram2[228] <= 32'h1010101;
			ram2[229] <= 32'h1010200;
			ram2[230] <= 32'h1020100;
			ram2[231] <= 32'h2010100;
			ram2[232] <= 32'h1020001;
			ram2[233] <= 32'h1020100;
			ram2[234] <= 32'h1030000;
			ram2[235] <= 32'h2020000;
			ram2[236] <= 32'h2010001;
			ram2[237] <= 32'h2010100;
			ram2[238] <= 32'h2020000;
			ram2[239] <= 32'h3010000;
			ram2[240] <= 32'h2000002;
			ram2[241] <= 32'h2000101;
			ram2[242] <= 32'h2010001;
			ram2[243] <= 32'h3000001;
			ram2[244] <= 32'h2000101;
			ram2[245] <= 32'h2000200;
			ram2[246] <= 32'h2010100;
			ram2[247] <= 32'h3000100;
			ram2[248] <= 32'h2010001;
			ram2[249] <= 32'h2010100;
			ram2[250] <= 32'h2020000;
			ram2[251] <= 32'h3010000;
			ram2[252] <= 32'h3000001;
			ram2[253] <= 32'h3000100;
			ram2[254] <= 32'h3010000;
			ram2[255] <= 32'h4000000;
		end
	
	end
      
endmodule


module Pipe_yth(
	input Clk_32UI,
	input stall,
	input [63:0] ik_x0, ik_x1, ik_x2,
	input forward_all_done,

	
	output reg [63:0] ik_x0_pipe, ik_x1_pipe, ik_x2_pipe,
	output reg [63:0] ik_x0_L0_ik_x2_L0_A,
	output reg [63:0] ik_x1_L0_ik_x2_L0_B,
	output reg forward_all_done_pipe
);
	
	reg [63:0] ik_x0_L1, ik_x1_L1, ik_x2_L1;
	reg [63:0] ik_x0_L2, ik_x1_L2, ik_x2_L2;
	reg [63:0] ik_x0_L3, ik_x1_L3, ik_x2_L3;
	reg [63:0] ik_x0_L4, ik_x1_L4, ik_x2_L4;
	reg [63:0] ik_x0_L5, ik_x1_L5, ik_x2_L5;
	reg [63:0] ik_x0_L6, ik_x1_L6, ik_x2_L6;
	
	reg forward_all_done_L1;
	reg forward_all_done_L2;
	reg forward_all_done_L3;
	reg forward_all_done_L4;
	reg forward_all_done_L5;
	reg forward_all_done_L6;
	//1
	always @ (posedge Clk_32UI) begin
		if(stall) begin
			ik_x0_L1 <= ik_x0_L1;
			ik_x1_L1 <= ik_x1_L1;
			ik_x2_L1 <= ik_x2_L1;
			forward_all_done_L1 <= forward_all_done_L1;

		end
		else begin
			ik_x0_L1 <= ik_x0;
			ik_x1_L1 <= ik_x1;
			ik_x2_L1 <= ik_x2;
			forward_all_done_L1 <= forward_all_done;
	
		end
	end
	//2
	always @ (posedge Clk_32UI) begin
		if(stall) begin
			ik_x0_L2 <= ik_x0_L2;
			ik_x1_L2 <= ik_x1_L2;
			ik_x2_L2 <= ik_x2_L2;
			forward_all_done_L2 <= forward_all_done_L2;

		end
		else begin
			ik_x0_L2 <= ik_x0_L1;
			ik_x1_L2 <= ik_x1_L1;
			ik_x2_L2 <= ik_x2_L1;
			forward_all_done_L2 <= forward_all_done_L1;

		end
	end
	//3
	always @ (posedge Clk_32UI) begin
	if(stall) begin
		ik_x0_L3 <= ik_x0_L3;
		ik_x1_L3 <= ik_x1_L3;
		ik_x2_L3 <= ik_x2_L3;
		forward_all_done_L3 <= forward_all_done_L3;

	end
	else begin
		ik_x0_L3 <= ik_x0_L2;
		ik_x1_L3 <= ik_x1_L2;
		ik_x2_L3 <= ik_x2_L2;
		forward_all_done_L3 <= forward_all_done_L2;

	end
	end
	//4
	always @ (posedge Clk_32UI) begin
	if(stall) begin
		ik_x0_L4 <= ik_x0_L4;
		ik_x1_L4 <= ik_x1_L4;
		ik_x2_L4 <= ik_x2_L4;
		forward_all_done_L4 <= forward_all_done_L4;

	end
	else begin
		ik_x0_L4 <= ik_x0_L3;
		ik_x1_L4 <= ik_x1_L3;
		ik_x2_L4 <= ik_x2_L3;
		forward_all_done_L4 <= forward_all_done_L3;

	end
	end
	//5
	always @ (posedge Clk_32UI) begin
		if(stall) begin
		ik_x0_L5 <= ik_x0_L5;
		ik_x1_L5 <= ik_x1_L5;
		ik_x2_L5 <= ik_x2_L5;
		forward_all_done_L5 <= forward_all_done_L5;

		end
		else begin
		ik_x0_L5 <= ik_x0_L4;
		ik_x1_L5 <= ik_x1_L4;
		ik_x2_L5 <= ik_x2_L4;
		forward_all_done_L5 <= forward_all_done_L4;

		end
	end
	//6
	always @ (posedge Clk_32UI) begin
		if(stall) begin
		ik_x0_L6 <= ik_x0_L6;
		ik_x1_L6 <= ik_x1_L6;
		ik_x2_L6 <= ik_x2_L6;
		forward_all_done_L6 <= forward_all_done_L6;

		end
		else begin
		ik_x0_L6 <= ik_x0_L5;
		ik_x1_L6 <= ik_x1_L5;
		ik_x2_L6 <= ik_x2_L5;
		forward_all_done_L6 <= forward_all_done_L5;

		end
	end
	//7
	always @ (posedge Clk_32UI) begin
		if(stall) begin
		ik_x0_pipe <= ik_x0_pipe;
		ik_x1_pipe <= ik_x1_pipe;
		ik_x2_pipe <= ik_x2_pipe;
		forward_all_done_pipe <= forward_all_done_pipe;

		end
		else begin
		ik_x0_pipe <= ik_x0_L6;
		ik_x1_pipe <= ik_x1_L6;
		ik_x2_pipe <= ik_x2_L6;
		forward_all_done_pipe <= forward_all_done_L6;
		
		ik_x0_L0_ik_x2_L0_A <= ik_x0_L6 + ik_x2_L6;
		ik_x1_L0_ik_x2_L0_B <= ik_x1_L6 + ik_x2_L6;

		end
	end
	
endmodule
