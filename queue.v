//The read itself should also be stored in a centered structure.
//previously 8 bits represent a nucleobase => too wasteful 
//=> convert to 4-bit data

//if every time pull 1000 reads into the chip
//read itself 4*101
//curr_queue 256*101;
//mem_queue 256*101; 
// ** why Bug made it 256*128?
// ** besides, I highly doubt one entry needs 256 bits.


//Other elements (current nucleobase, status registers, etc.) 
//will all run in the pipeline

//==========================
`define CL 512
`define MAX_READ 1024
`define READ_NUM_WIDTH 10

`define WIDTH_read 308 + 100 //[important] be careful not to exceed the width
`define WIDTH_memory 768
module Queue(
	input Clk_32UI,
	input reset_n,
	input stall,
	
	input DRAM_get,
	input [31:0] cnt_a0,cnt_a1,cnt_a2,cnt_a3,
	input [63:0] cnt_b0,cnt_b1,cnt_b2,cnt_b3,
	input [31:0] cntl_a0,cntl_a1,cntl_a2,cntl_a3,
	input [63:0] cntl_b0,cntl_b1,cntl_b2,cntl_b3,
	
	output reg [31:0] cnt_a0_out_q,cnt_a1_out_q,cnt_a2_out_q,cnt_a3_out_q,
	output reg [63:0] cnt_b0_out_q,cnt_b1_out_q,cnt_b2_out_q,cnt_b3_out_q,
	output reg [31:0] cntl_a0_out_q,cntl_a1_out_q,cntl_a2_out_q,cntl_a3_out_q,
	output reg [63:0] cntl_b0_out_q,cntl_b1_out_q,cntl_b2_out_q,cntl_b3_out_q,
	
	//======================================================================
	
	//Forward Pipeline -> Queue
	input [5:0] status,
	input [6:0] ptr_curr, // record the status of curr and mem queue
	input [`READ_NUM_WIDTH - 1 :0] read_num,
	input [63:0] ik_x0, ik_x1, ik_x2, ik_info,
	input [6:0] forward_i,
	input [6:0] min_intv,
	input [6:0] backward_x,
	
	//forward query position
	input [6:0] next_query_position,
	input [`READ_NUM_WIDTH - 1 :0] read_num_query,
	input [5:0] status_query,
	
	//Queue -> Forward Pipeline
	output reg [5:0] status_out_q,
	output reg [6:0] ptr_curr_out_q, // record the status of curr and mem queue
	output reg [`READ_NUM_WIDTH - 1 :0] read_num_out_q,
	
	output reg [63:0] ik_x0_out_q, ik_x1_out_q, ik_x2_out_q, ik_info_out_q,
	output reg [63:0] forward_k_temp_q,
	output reg [63:0] forward_l_temp_q,
	
	output reg [6:0] forward_i_out_q,
	output reg [6:0] min_intv_out_q,
	output reg [6:0] backward_x_out_q,
	output reg [7:0] query_out_q,
	
	//======================================================================
	
	//Backward Pipelie -> Queue
	
	//backward query position
	input [6:0] next_query_position_B,
	input [`READ_NUM_WIDTH - 1 :0] read_num_query_B,
	input [5:0] status_query_B,
	
	
	//[important] should stay unchanged during stall condition
	input [6:0] forward_size_n_B,	
	input [`READ_NUM_WIDTH - 1 :0] read_num_B,
	input [6:0] min_intv_B,
	input [5:0] status_B,
	input [6:0] new_size_B,
	input [6:0] new_last_size_B,
	input [63:0] primary_B,
	input [6:0] current_rd_addr_B,
	input [6:0] current_wr_addr_B,mem_wr_addr_B,
	input [6:0] backward_i_B, backward_j_B,
	input iteration_boundary_B,
	input [63:0] p_x0_B,p_x1_B,p_x2_B,p_info_B,
	input [63:0] reserved_token_x2_B, //reserved_token_x2 => last_token_x2_q
	input [31:0] reserved_mem_info_B, //reserved_mem_info => last_mem_info_q
	input [63:0] backward_k_B,backward_l_B, // backward_k == k, backward_l==l;
	
	input [6:0] output_c_B, // address for next query
	
	// Queue -> Backward Pipeline
	// queue special provide 
	output reg [63:0] ik_x0_new_q_q,
	output reg [63:0] ik_x1_new_q_q,
	output reg [63:0] ik_x2_new_q_q,
	output reg [6:0] backward_x_q_q, // x
	output reg [7:0] backward_c_q_q, // next bp
	output reg forward_all_done_q,
	output reg [6:0] forward_size_n_q_q, //foward curr array size	
	
	// circular provide
	output reg [`READ_NUM_WIDTH - 1 :0] read_num_q_q,
	output reg [6:0] min_intv_q_q,	//
	output reg [5:0] status_q_q,
	output reg [6:0] new_size_q_q,
	output reg [6:0] new_last_size_q_q,
	output reg [63:0] primary_q_q,
	output reg [6:0] current_rd_addr_q_q,
	output reg [6:0] current_wr_addr_q_q,
	output reg [6:0] mem_wr_addr_q_q,
	output reg [6:0] backward_i_q_q, 
	output reg [6:0] backward_j_q_q,
	output reg iteration_boundary_q_q,
	output reg [63:0] p_x0_q_q, // same as ik in forward datapath_q, store the p_x0 value into queue
	output reg [63:0] p_x1_q_q,
	output reg [63:0] p_x2_q_q,
	output reg [63:0] p_info_q_q,
	output reg [63:0] last_token_x2_q_q, //pushed to queue
	output reg [31:0] last_mem_info_q_q,
	output reg [63:0] k_q_q,
	output reg [63:0] l_q_q,
	

	
	//========================================================================
	//fetch new read at the end of queue
	output new_read,
	input new_read_valid,
	input load_done,
	
	input [`READ_NUM_WIDTH - 1 :0] new_read_num, //should be prepared before hand. every time new_read is set, next_read_num should be updated.
	input [63:0] new_ik_x0, new_ik_x1, new_ik_x2, new_ik_info,
	input [6:0] new_forward_i,
	input [6:0] new_min_intv,
	
	//fetch new query at the start of queue
	output [6:0] query_position_2RAM,
	output [`READ_NUM_WIDTH - 1 :0] query_read_num_2RAM,
	output [5:0] query_status_2RAM,
	input [7:0] new_read_query_2Queue,

	//debugging info
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
	
	reg [31:0] cnt_a0_out,cnt_a1_out,cnt_a2_out,cnt_a3_out;
	reg [63:0] cnt_b0_out,cnt_b1_out,cnt_b2_out,cnt_b3_out;
	reg [31:0] cntl_a0_out,cntl_a1_out,cntl_a2_out,cntl_a3_out;
	reg [63:0] cntl_b0_out,cntl_b1_out,cntl_b2_out,cntl_b3_out;
	
	//======================================================================
	
	//Queue -> Forward Pipeline
	reg [5:0] status_out;
	reg [6:0] ptr_curr_out; // record the status of curr and mem queue
	reg [`READ_NUM_WIDTH - 1 :0] read_num_out;
	reg [63:0] ik_x0_out, ik_x1_out, ik_x2_out, ik_info_out;
	reg [6:0] forward_i_out;
	reg [6:0] min_intv_out;
	reg [6:0] backward_x_out;
	reg [7:0] query_out;
	
	//======================================================================
	
	// Queue -> Backward Pipeline
	// queue special provide 
	reg [63:0] ik_x0_new_q;
	reg [63:0] ik_x1_new_q;
	reg [63:0] ik_x2_new_q;
	reg [6:0] backward_x_q; // x
	reg [7:0] backward_c_q; // next bp
	reg forward_all_done;
	reg [6:0] forward_size_n_q; //foward curr array size	
	
	// circular provide
	reg [`READ_NUM_WIDTH - 1 :0] read_num_q;
	reg [6:0] min_intv_q;	//
	reg [5:0] status_q;
	reg [6:0] new_size_q;
	reg [6:0] new_last_size_q;
	reg [63:0] primary_q;
	reg [6:0] current_rd_addr_q;
	reg [6:0] current_wr_addr_q;
	reg [6:0] mem_wr_addr_q;
	reg [6:0] backward_i_q; 
	reg [6:0] backward_j_q;
	reg iteration_boundary_q;
	reg [63:0] p_x0_q; // same as ik in forward datapath; store the p_x0 value into queue
	reg [63:0] p_x1_q;
	reg [63:0] p_x2_q;
	reg [63:0] p_info_q;
	reg [63:0] last_token_x2_q; //pushed to queue
	reg [31:0] last_mem_info_q;
	reg [63:0] k_q;
	reg [63:0] l_q;
	
	always@(posedge Clk_32UI) begin
		if(!reset_n) begin
			status_out_q <= BUBBLE;
			status_q_q <= BUBBLE;
		
		end
		else if(!stall) begin
	
			cnt_a0_out_q <= cnt_a0_out;
			cnt_a1_out_q <= cnt_a1_out;
			cnt_a2_out_q <= cnt_a2_out;
			cnt_a3_out_q <= cnt_a3_out;

			cnt_b0_out_q <= cnt_b0_out;
			cnt_b1_out_q <= cnt_b1_out;
			cnt_b2_out_q <= cnt_b2_out;
			cnt_b3_out_q <= cnt_b3_out;

			cntl_a0_out_q <= cntl_a0_out;
			cntl_a1_out_q <= cntl_a1_out;
			cntl_a2_out_q <= cntl_a2_out;
			cntl_a3_out_q <= cntl_a3_out;

			cntl_b0_out_q <= cntl_b0_out;
			cntl_b1_out_q <= cntl_b1_out;
			cntl_b2_out_q <= cntl_b2_out;
			cntl_b3_out_q <= cntl_b3_out;

				
			//======================================================================
				
			//Queue -> Forward Pipeline
			status_out_q <= status_out;
			ptr_curr_out_q <= ptr_curr_out; // record the status of curr and mem queue
			read_num_out_q <= read_num_out;
			ik_x0_out_q <= ik_x0_out;
			ik_x1_out_q <= ik_x1_out;
			ik_x2_out_q <= ik_x2_out;
			ik_info_out_q <= ik_info_out;
			forward_i_out_q <= forward_i_out;
			min_intv_out_q <= min_intv_out;
			backward_x_out_q <= backward_x_out;
			query_out_q <= query_out;
			
			forward_k_temp_q <= ik_x1_out - 1;
			forward_l_temp_q <= ik_x1_out - 1 + ik_x2_out;
				
			//======================================================================
				
			// Queue -> Backward Pipeline
			// queue special provide 
			ik_x0_new_q_q <= ik_x0_new_q;
			ik_x1_new_q_q <= ik_x1_new_q;
			ik_x2_new_q_q <= ik_x2_new_q;
			backward_x_q_q <= backward_x_q; // x
			backward_c_q_q <= backward_c_q; // next bp
			forward_all_done_q <= forward_all_done;
			forward_size_n_q_q <= forward_size_n_q; //foward curr array size	
				
			// circular provide
			read_num_q_q <= read_num_q;
			min_intv_q_q <= min_intv_q;	//
			status_q_q <= status_q;
			new_size_q_q <= new_size_q;
			new_last_size_q_q <= new_last_size_q;
			primary_q_q <= primary_q;
			current_rd_addr_q_q <= current_rd_addr_q;
			current_wr_addr_q_q <= current_wr_addr_q;
			mem_wr_addr_q_q <= mem_wr_addr_q;
			backward_i_q_q <= backward_i_q; 
			backward_j_q_q <= backward_j_q;
			iteration_boundary_q_q <= iteration_boundary_q;
			p_x0_q_q <= p_x0_q; // same as ik in forward datapath_q <= datapath; store the p_x0 value into queue
			p_x1_q_q <= p_x1_q;
			p_x2_q_q <= p_x2_q;
			p_info_q_q <= p_info_q;
			last_token_x2_q_q <= last_token_x2_q; //pushed to queue
			last_mem_info_q_q <= last_mem_info_q;
			k_q_q <= k_q;
			l_q_q <= l_q;
		
		
		end
	end

	
	//===========================================================================================
	
	//[licheng] I don't understand why there must be 2*MAX_READ slots in the queue.
	reg [`WIDTH_read - 1 :0] RAM_forward[`MAX_READ*2 - 1:0];
	reg [5 :0] RAM_forward_status[`MAX_READ*2 - 1:0];
	reg [`WIDTH_read - 1 :0] output_data, f_data, b_data;
	reg [`READ_NUM_WIDTH+1 - 1:0] read_ptr_f;
	reg [`READ_NUM_WIDTH+1 - 1:0] read_ptr_f_q;
	reg [`READ_NUM_WIDTH+1 - 1:0] write_ptr_f;
	
	//circular queue for memory responses.

	
	reg [`WIDTH_memory - 1:0] RAM_memory[`MAX_READ - 1:0];
	reg [`READ_NUM_WIDTH - 1:0] read_ptr_m; //[important] for FIFO, the extension of ptr should be equal to that of RAM
	reg [`READ_NUM_WIDTH - 1:0] write_ptr_m;
	reg [`READ_NUM_WIDTH - 1:0] read_ptr_m_q;
	
	
	reg [5:0] status_L0;
	reg [6:0] ptr_curr_L0; // record the status of curr and mem queue
	reg [`READ_NUM_WIDTH - 1 :0] read_num_L0;
	reg [63:0] ik_x0_L0, ik_x1_L0, ik_x2_L0, ik_info_L0;
	reg [6:0] forward_i_L0;
	reg [6:0] min_intv_L0;
	reg [6:0] backward_x_L0;
	
	reg [5:0] status_L1;
	reg [6:0] ptr_curr_L1; // record the status of curr and mem queue
	reg [`READ_NUM_WIDTH - 1 :0] read_num_L1;
	reg [63:0] ik_x0_L1, ik_x1_L1, ik_x2_L1, ik_info_L1;
	reg [6:0] forward_i_L1;
	reg [6:0] min_intv_L1;
	reg [6:0] backward_x_L1;
	
	reg [5:0] status_L2;
	reg [6:0] ptr_curr_L2; // record the status of curr and mem queue
	reg [`READ_NUM_WIDTH - 1 :0] read_num_L2;
	reg [63:0] ik_x0_L2, ik_x1_L2, ik_x2_L2, ik_info_L2;
	reg [6:0] forward_i_L2;
	reg [6:0] min_intv_L2;
	reg [6:0] backward_x_L2;
	
	reg [6:0] forward_size_n_B_L0;	
	reg [`READ_NUM_WIDTH - 1 :0] read_num_B_L0;
	reg [6:0] min_intv_B_L0;
	// reg [5:0] status_B_L0;
	reg [6:0] new_size_B_L0;
	reg [6:0] new_last_size_B_L0;
	reg [63:0] primary_B_L0;
	reg [6:0] current_rd_addr_B_L0;
	reg [6:0] current_wr_addr_B_L0,mem_wr_addr_B_L0;
	reg [6:0] backward_i_B_L0, backward_j_B_L0;
	reg iteration_boundary_B_L0;
	reg [63:0] p_x0_B_L0,p_x1_B_L0,p_x2_B_L0,p_info_B_L0;
	reg [63:0] reserved_token_x2_B_L0; //reserved_token_x2 => last_token_x2_q
	reg [31:0] reserved_mem_info_B_L0; //reserved_mem_info => last_mem_info_q
	reg [63:0] backward_k_B_L0,backward_l_B_L0; // backward_k == k, backward_l==l;
	
	reg [6:0] forward_size_n_B_L1;	
	reg [`READ_NUM_WIDTH - 1 :0] read_num_B_L1;
	reg [6:0] min_intv_B_L1;
	// reg [5:0] status_B_L1;
	reg [6:0] new_size_B_L1;
	reg [6:0] new_last_size_B_L1;
	reg [63:0] primary_B_L1;
	reg [6:0] current_rd_addr_B_L1;
	reg [6:0] current_wr_addr_B_L1, mem_wr_addr_B_L1;
	reg [6:0] backward_i_B_L1, backward_j_B_L1;
	reg iteration_boundary_B_L1;
	reg [63:0] p_x0_B_L1, p_x1_B_L1, p_x2_B_L1, p_info_B_L1;
	reg [63:0] reserved_token_x2_B_L1; //reserved_token_x2 => last_token_x2_q
	reg [31:0] reserved_mem_info_B_L1; //reserved_mem_info => last_mem_info_q
	reg [63:0] backward_k_B_L1, backward_l_B_L1; // backward_k == k, backward_l==l;
	
	reg [6:0] forward_size_n_B_L2;	//7	
	reg [`READ_NUM_WIDTH - 1 :0] read_num_B_L2;		//9
	reg [6:0] min_intv_B_L2;		//7
	// reg [5:0] status_B_L2;		//6
	reg [6:0] new_size_B_L2;		//7
	reg [6:0] new_last_size_B_L2;	//7
	reg [63:0] primary_B_L2;		//0 RAM_read provides. fix value
	reg [6:0] current_rd_addr_B_L2; //7
	reg [6:0] current_wr_addr_B_L2, mem_wr_addr_B_L2; 	//14
	reg [6:0] backward_i_B_L2, backward_j_B_L2;			//14
	reg iteration_boundary_B_L2;						//1
	reg [63:0] p_x0_B_L2, p_x1_B_L2, p_x2_B_L2, p_info_B_L2;	//33*3+14 = 113
	reg [63:0] reserved_token_x2_B_L2; 					//33					
	reg [31:0] reserved_mem_info_B_L2; 					//7
	reg [63:0] backward_k_B_L2, backward_l_B_L2; 		//33+33 
	
	
	reg [5:0] status_L3;
	
	// 3 stage pipe to wait for the delay of retrieving query
	//------------------------------------------------
	
	assign query_position_2RAM = (status_query != BUBBLE ) ? next_query_position : next_query_position_B ;
	assign query_read_num_2RAM = (status_query != BUBBLE ) ? read_num_query :  read_num_query_B ;
	//assign query_status_2RAM = (status != BUBBLE && status != F_break) ? status : (status_B != BUBBLE && status_B != BCK_END) ? status_B : 6'b11_1111;
	assign query_status_2RAM = status_query;

	always@(posedge Clk_32UI) begin
		if(!stall) begin
			status_L0 <=  ( status != BUBBLE ) ? status : (status_B != BUBBLE) ?  status_B : BUBBLE ;
			
			ptr_curr_L0 <= ptr_curr; // record the status of curr and mem queue
			read_num_L0 <= read_num;
			ik_x0_L0 <= ik_x0;
			ik_x1_L0 <= ik_x1;
			ik_x2_L0 <= ik_x2;
			ik_info_L0 <= ik_info;
			forward_i_L0 <= forward_i;
			min_intv_L0 <= min_intv;
			backward_x_L0 <= backward_x;
			
			forward_size_n_B_L0 	<= forward_size_n_B;	
			read_num_B_L0 			<= read_num_B;
			min_intv_B_L0 			<= min_intv_B;
			// reg [5:0] status_B_L0;
			new_size_B_L0 			<= new_size_B;
			new_last_size_B_L0 		<= new_last_size_B;
			primary_B_L0 			<= primary_B;
			current_rd_addr_B_L0 	<= current_rd_addr_B;
			current_wr_addr_B_L0 	<= current_wr_addr_B;
			mem_wr_addr_B_L0 		<= mem_wr_addr_B;
			backward_i_B_L0 		<= backward_i_B;
			backward_j_B_L0 		<= backward_j_B;
			iteration_boundary_B_L0 <= iteration_boundary_B;
			p_x0_B_L0 				<= p_x0_B;
			p_x1_B_L0 				<= p_x1_B;
			p_x2_B_L0 				<= p_x2_B;
			p_info_B_L0 			<= p_info_B;
			reserved_token_x2_B_L0 	<= reserved_token_x2_B; //reserved_token_x2 => last_token_x2_q
			reserved_mem_info_B_L0 	<= reserved_mem_info_B; //reserved_mem_info => last_mem_info_q
			backward_k_B_L0 		<= backward_k_B;
			backward_l_B_L0 		<= backward_l_B; // backward_k == k, backward_l==l;
		end
	end
	
	always@(posedge Clk_32UI) begin
		if(!stall) begin
			status_L1 <= status_L0;
			
			ptr_curr_L1 <= ptr_curr_L0; // record the status of curr and mem queue
			read_num_L1 <= read_num_L0;
			ik_x0_L1 <= ik_x0_L0;
			ik_x1_L1 <= ik_x1_L0;
			ik_x2_L1 <= ik_x2_L0;
			ik_info_L1 <= ik_info_L0;
			forward_i_L1 <= forward_i_L0;
			min_intv_L1 <= min_intv_L0;
			backward_x_L1 <= backward_x_L0;
			
			forward_size_n_B_L1 	<= forward_size_n_B_L0;	
			read_num_B_L1 			<= read_num_B_L0;
			min_intv_B_L1 			<= min_intv_B_L0;
			// reg [5:0] status_B_L0;
			new_size_B_L1 			<= new_size_B_L0;
			new_last_size_B_L1 		<= new_last_size_B_L0;
			primary_B_L1 			<= primary_B_L0;
			current_rd_addr_B_L1 	<= current_rd_addr_B_L0;
			current_wr_addr_B_L1 	<= current_wr_addr_B_L0;
			mem_wr_addr_B_L1 		<= mem_wr_addr_B_L0;
			backward_i_B_L1 		<= backward_i_B_L0;
			backward_j_B_L1 		<= backward_j_B_L0;
			iteration_boundary_B_L1 <= iteration_boundary_B_L0;
			p_x0_B_L1 				<= p_x0_B_L0;
			p_x1_B_L1 				<= p_x1_B_L0;
			p_x2_B_L1 				<= p_x2_B_L0;
			p_info_B_L1 			<= p_info_B_L0;
			reserved_token_x2_B_L1 	<= reserved_token_x2_B_L0; //reserved_token_x2 => last_token_x2_q
			reserved_mem_info_B_L1 	<= reserved_mem_info_B_L0; //reserved_mem_info => last_mem_info_q
			backward_k_B_L1 		<= backward_k_B_L0;
			backward_l_B_L1 		<= backward_l_B_L0; // backward_k == k, backward_l==l;
		end
	end
	
	always@(posedge Clk_32UI) begin
		if(!stall) begin
			status_L2 <= status_L1;
			ptr_curr_L2 <= ptr_curr_L1; // record the status of curr and mem queue
			read_num_L2 <= read_num_L1;
			ik_x0_L2 <= ik_x0_L1;
			ik_x1_L2 <= ik_x1_L1;
			ik_x2_L2 <= ik_x2_L1;
			ik_info_L2 <= ik_info_L1;
			forward_i_L2 <= forward_i_L1;
			min_intv_L2 <= min_intv_L1;
			backward_x_L2 <= backward_x_L1;
			
			forward_size_n_B_L2 	<= forward_size_n_B_L1;	
			read_num_B_L2 			<= read_num_B_L1;
			min_intv_B_L2 			<= min_intv_B_L1;
			// reg [5:0] status_B_L0;
			new_size_B_L2 			<= new_size_B_L1;
			new_last_size_B_L2 		<= new_last_size_B_L1;
			primary_B_L2 			<= primary_B_L1;
			current_rd_addr_B_L2 	<= current_rd_addr_B_L1;
			current_wr_addr_B_L2 	<= current_wr_addr_B_L1;
			mem_wr_addr_B_L2 		<= mem_wr_addr_B_L1;
			backward_i_B_L2 		<= backward_i_B_L1;
			backward_j_B_L2 		<= backward_j_B_L1;
			iteration_boundary_B_L2 <= iteration_boundary_B_L1;
			p_x0_B_L2 				<= p_x0_B_L1;
			p_x1_B_L2 				<= p_x1_B_L1;
			p_x2_B_L2 				<= p_x2_B_L1;
			p_info_B_L2 			<= p_info_B_L1;
			reserved_token_x2_B_L2 	<= reserved_token_x2_B_L1; //reserved_token_x2 => last_token_x2_q
			reserved_mem_info_B_L2 	<= reserved_mem_info_B_L1; //reserved_mem_info => last_mem_info_q
			backward_k_B_L2 		<= backward_k_B_L1;
			backward_l_B_L2 		<= backward_l_B_L1; // backward_k == k, backward_l==l;
		end
	end
	
	always@(posedge Clk_32UI) begin
		if(!stall) begin
			//received query fetch responses from RAM
			f_data <= {	ptr_curr_L2, read_num_L2, ik_x0_L2[32:0], ik_x1_L2[32:0], ik_x2_L2[32:0], ik_info_L2[38:32], ik_info_L2[6:0], 
						forward_i_L2, min_intv_L2, new_read_query_2Queue, backward_x_L2,
						status_L2
					  };
			b_data <= {	5'b10101,new_read_query_2Queue, forward_size_n_B_L2, read_num_B_L2, min_intv_B_L2, new_size_B_L2, 
						new_last_size_B_L2, primary_B_L2, current_rd_addr_B_L2, current_wr_addr_B_L2, mem_wr_addr_B_L2,
						backward_i_B_L2, backward_j_B_L2, iteration_boundary_B_L2,
						p_x0_B_L2[32:0], p_x1_B_L2[32:0], p_x2_B_L2[32:0], p_info_B_L2[38:32], p_info_B_L2[6:0],
						reserved_token_x2_B_L2[32:0], reserved_mem_info_B_L2[6:0], backward_k_B_L2[32:0], backward_l_B_L2[32:0],
						status_L2
					  };
			status_L3 <= status_L2;
		end
	end
	//------------------------------------------------
	


	//circular queue for reads
	always@(posedge Clk_32UI) begin
		if(!reset_n) begin
			write_ptr_f <= 0;
		end
		else if(!stall) begin	

			if ( status_L3 == BCK_RUN ) begin
				RAM_forward[write_ptr_f] <= b_data;
				RAM_forward_status[write_ptr_f] <= status_L3;
				write_ptr_f <= write_ptr_f + 1;
			end
			
			else if((status_L3 == F_init) ||(status_L3 == F_run) || (status_L3 == F_break) || (status_L3 == BCK_INI)) begin 
				RAM_forward[write_ptr_f] <= f_data;
				RAM_forward_status[write_ptr_f] <= status_L3;
				write_ptr_f <= write_ptr_f + 1;
			end
		end
	end

	wire memory_valid = (write_ptr_m != read_ptr_m);
	
	always@(posedge Clk_32UI) begin
		if(!reset_n) begin
			write_ptr_m <= 0;
		end
		else begin
			if(DRAM_get) begin
				RAM_memory[write_ptr_m] <= {cnt_a0,cnt_a1,cnt_a2,cnt_a3,cnt_b0,cnt_b1,cnt_b2,cnt_b3, cntl_a0,cntl_a1,cntl_a2,cntl_a3,cntl_b0,cntl_b1,cntl_b2,cntl_b3};
				write_ptr_m <= write_ptr_m + 1;
			end
			
			if(!stall) begin
				{cnt_a0_out,cnt_a1_out,cnt_a2_out,cnt_a3_out,cnt_b0_out,cnt_b1_out,cnt_b2_out,cnt_b3_out, cntl_a0_out,cntl_a1_out,cntl_a2_out,cntl_a3_out,cntl_b0_out,cntl_b1_out,cntl_b2_out,cntl_b3_out} <= RAM_memory[read_ptr_m];
			end
		end
	end
	
	//[important] whether to fetch new read
	wire [5:0] next_status = (read_ptr_f != write_ptr_f) ? RAM_forward_status[read_ptr_f][5:0] : BUBBLE;
	// assign new_read = new_read_valid & (!memory_valid) & (!stall) & (next_status != F_break) & (next_status != BCK_INI);
	assign new_read = new_read_valid & (!stall) & (next_status != F_break) & (next_status != BCK_INI);
	reg [10:0] total_inqueue_num;

	always@(posedge Clk_32UI) begin
		if (!reset_n) begin
			total_inqueue_num <= 0;
		end
		else if (stall) begin
			total_inqueue_num <= write_ptr_f - read_ptr_f;
		end
		else begin
			total_inqueue_num <= total_inqueue_num;
		end
	end


	assign num_reads_inqueue = total_inqueue_num;

	always@(posedge Clk_32UI) begin
		if (!reset_n) begin
			read_ptr_f <= 0;
			read_ptr_m <= 0;
			status_out <= BUBBLE;
			
			ik_x0_out[63:33] <= 0;
			ik_x1_out[63:33] <= 0;
			ik_x2_out[63:33] <= 0;
			ik_info_out[63:39] <= 0;
			ik_info_out[31:7] <= 0;
			
			ik_x0_new_q[63:33] <= 0;
			ik_x1_new_q[63:33] <= 0;
			ik_x2_new_q[63:33] <= 0;
			
			p_x0_q[63:33] <= 0;
			p_x1_q[63:33] <= 0;
			p_x2_q[63:33] <= 0;
			p_info_q[63:39] <= 0;
			p_info_q[31:7] <= 0;

			last_token_x2_q[63:33] <= 0;
			last_mem_info_q[31:7] <= 0;
			k_q[63:33] <= 0;
			l_q[63:33] <= 0;
		end
		else if (!stall) begin
			
			if(next_status == F_break) begin
				//[important] pop out without memory response
				
				//======== forward ports =============
				{ptr_curr_out, read_num_out, ik_x0_out[32:0], ik_x1_out[32:0], ik_x2_out[32:0], ik_info_out[38:32], ik_info_out[6:0], 
				forward_i_out,min_intv_out, query_out, backward_x_out,
				status_out} <= RAM_forward[read_ptr_f];

				
				//=====================================
				
				read_ptr_f <= read_ptr_f + 1;
				
				//======== backward ports =============
				status_q <= BUBBLE;
				//=====================================
			end
			
			else if (next_status == BCK_INI) begin
				//[important] pop out without memory response
				
				//======== forward ports =============
				status_out <= BUBBLE;
				//=====================================
						
				//======== backward initial ===========
				//provide initial value to backward datapath
				//only _q ports are meaningful, others are placeholder
				{	forward_size_n_q, read_num_q, 
					ik_x0_new_q[32:0], ik_x1_new_q[32:0], ik_x2_new_q[32:0], 
					ik_info_out[38:32], ik_info_out[6:0], forward_i_out, min_intv_q, query_out,  //place holder
					backward_x_q, status_q
				} <= RAM_forward[read_ptr_f];
				

				
				read_ptr_f <= read_ptr_f + 1;
				
				forward_all_done <= 1;
				
				//other ports left random
				
				//======================================
			end
			///////////////////////////////////////////
			
			else if (new_read_valid) begin // no memory response, fetch new read

				//-------------------
                status_out <= F_init;
                ptr_curr_out <= 0;
                read_num_out <= new_read_num; //from RAM
                ik_x0_out[32:0] <= new_ik_x0[32:0]; //from RAM
                ik_x1_out[32:0] <= new_ik_x1[32:0]; //from RAM
                ik_x2_out[32:0] <= new_ik_x2[32:0]; //from RAM
                ik_info_out[38:32] <= new_ik_info[38:32]; //from RAM
				ik_info_out[6:0] <= new_ik_info[6:0]; //from RAM
                forward_i_out <= new_forward_i + 1; // from RAM
				backward_x_out <= new_forward_i;
                min_intv_out <= new_min_intv; 
                query_out <= 0; // !!!!the first round doesn't need query
				
                //-------------------

				status_q <= BUBBLE;

			end
			
			
			else if (memory_valid) begin // get memory responses, output old read
					if(next_status == F_run) begin
						{ptr_curr_out, read_num_out, ik_x0_out[32:0], ik_x1_out[32:0], ik_x2_out[32:0], ik_info_out[38:32], ik_info_out[6:0], 
						forward_i_out,min_intv_out, query_out, backward_x_out,
						status_out} <= RAM_forward[read_ptr_f];
						
						//======== backward ports =============
						status_q <= BUBBLE;
						//=====================================
					end
					else if (next_status == BCK_RUN) begin
						//=========== forward ports ==============
						status_out <= BUBBLE;
						//==========================================
						
						//=========== backward ports ===============
						{	backward_c_q, forward_size_n_q, read_num_q, min_intv_q, new_size_q, 
							new_last_size_q, primary_q, current_rd_addr_q, current_wr_addr_q, mem_wr_addr_q,
							backward_i_q, backward_j_q, iteration_boundary_q,
							p_x0_q[32:0], p_x1_q[32:0], p_x2_q[32:0], p_info_q[38:32], p_info_q[6:0],
							last_token_x2_q[32:0], last_mem_info_q[6:0], k_q[32:0], l_q[32:0],
							status_q
						} <= RAM_forward[read_ptr_f];
						

						
						forward_all_done <= 1;
						//==========================================
					end
					
					
					read_ptr_f <= read_ptr_f + 1;
					read_ptr_m <= read_ptr_m + 1;
			end
			
			
			
			else begin // no memory responses and no more reads
				// new_read <= 0;
				//-------------------
                status_out <= BUBBLE;
				status_q <= BUBBLE;

			end
		end
	end	

endmodule
