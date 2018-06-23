`define CL 512
`define MAX_READ 1024
`define READ_NUM_WIDTH 10

module Datapath(
	// input of BWT_extend
	input Clk_32UI,
	input reset_BWT_extend,
	input stall,
	
	input [63:0] primary, // fix value
	input [63:0] L2_0, L2_1, L2_2, L2_3, //fix value
	
	input [31:0] cnt_a0,cnt_a1,cnt_a2,cnt_a3,
	input [63:0] cnt_b0,cnt_b1,cnt_b2,cnt_b3,
	input [31:0] cntl_a0,cntl_a1,cntl_a2,cntl_a3,
	input [63:0] cntl_b0,cntl_b1,cntl_b2,cntl_b3,
	
	output reg DRAM_valid,
	output reg [31:0] addr_k, addr_l,
	//-------------------------------------
	input [5:0] status,
	input [7:0] query, //only send the current query into the pipeline
	input [6:0] ptr_curr, // record the status of curr and mem queue
	input [`READ_NUM_WIDTH - 1:0] read_num,

	input [63:0] ik_x0, ik_x1, ik_x2, ik_info,
	input [63:0] forward_k_temp,
	input [63:0] forward_l_temp,
	
	input [6:0] forward_i,
	input [6:0] min_intv,
	input [6:0] backward_x,
	
	output reg [5:0] status_out,
	output reg [6:0] ptr_curr_out, // record the status of curr and mem queue
	output reg [`READ_NUM_WIDTH - 1:0] read_num_out,
	output reg [63:0] ik_x0_out, ik_x1_out, ik_x2_out, ik_info_out,
	output reg [6:0] forward_i_out,
	output reg [6:0] min_intv_out,
	output reg [6:0] backward_x_out,
	
	
	//----------------------------
	
	output reg [5:0] status_query,
	output reg [`READ_NUM_WIDTH - 1:0] read_num_query,
	output reg [6:0] next_query_position,
	
	output reg [`READ_NUM_WIDTH - 1:0] curr_read_num_1,
	output reg curr_we_1,
	output reg [255:0] curr_data_1,
	output reg [6:0] curr_addr_1,	
	
	// output reg [9:0] curr_read_num_2,
	// output reg curr_we_2,
	// output reg [255:0] curr_data_2,
	// output reg [6:0] curr_addr_2,
	
	output reg ret_valid,
	output reg [6:0] ret,
	output reg [`READ_NUM_WIDTH - 1:0] ret_read_num
	
	
);
	parameter Len = 101;
	
	parameter F_init = 	6'b00_0001; // F_init will disable the forward pipeline
	parameter F_run =  	6'b00_0010;
	parameter F_break = 6'b00_0100;
	parameter BCK_INI = 6'b00_1000;	//100
	parameter BCK_RUN = 6'b01_0000;	//101
	parameter BCK_END = 6'b10_0000;	//110
	parameter BUBBLE = 	6'b00_0000;
	
	//-----------------------------------------------------------

	// wire [63:0] forward_k_temp = ik_x1 -1;
	// wire [63:0] forward_l_temp = forward_k_temp + ik_x2; 
	reg [63:0] forward_k_L0;
    reg [63:0] forward_l_L0; 
	reg forward_all_done_L0;
	
	reg [31:0] cnt_a0_L0,cnt_a1_L0,cnt_a2_L0,cnt_a3_L0;
	reg [63:0] cnt_b0_L0,cnt_b1_L0,cnt_b2_L0,cnt_b3_L0;
	reg [31:0] cntl_a0_L0,cntl_a1_L0,cntl_a2_L0,cntl_a3_L0;
	reg [63:0] cntl_b0_L0,cntl_b1_L0,cntl_b2_L0,cntl_b3_L0;
	
	reg [6:0] forward_i_L0;
	reg [6:0] backward_x_L0;
	reg [6:0] min_intv_L0;

	
	reg [5:0] status_L0;
	reg [7:0] query_L0;//only send the current query into the pipeline
	reg [6:0] ptr_curr_L0;// record the status of curr and mem queue

	
	reg [`READ_NUM_WIDTH - 1:0] read_num_L0;
	reg [63:0] ik_x0_L0, ik_x1_L0, ik_x2_L0, ik_info_L0;
	
	always@(posedge Clk_32UI) begin
		if(!reset_BWT_extend) begin
			status_L0 <= BUBBLE;
		end
		else if(!stall) begin
			// part 1 forward control
			if(status == F_run) begin
				if (forward_i >= Len) begin
					status_L0 <=  F_break;
					forward_all_done_L0 <= 1;
				end
				else begin
					status_L0 <= F_run;
					forward_all_done_L0 <= 0;
				end
				
			end
			else begin
				status_L0 <= status;
			end
					
			// part 3 
			forward_k_L0 <= (forward_k_temp >= primary) ? forward_k_temp -1 : forward_k_temp;
			forward_l_L0 <= (forward_l_temp >= primary) ? forward_l_temp -1 : forward_l_temp;
			
			//------------------------------
			// pipe

			cnt_a0_L0 <= cnt_a0;
			cnt_a1_L0 <= cnt_a1;
			cnt_a2_L0 <= cnt_a2;
			cnt_a3_L0 <= cnt_a3;
			cnt_b0_L0 <= cnt_b0;
			cnt_b1_L0 <= cnt_b1;
			cnt_b2_L0 <= cnt_b2;
			cnt_b3_L0 <= cnt_b3;
			cntl_a0_L0 <= cntl_a0;
			cntl_a1_L0 <= cntl_a1;
			cntl_a2_L0 <= cntl_a2;
			cntl_a3_L0 <= cntl_a3;
			cntl_b0_L0 <= cntl_b0;
			cntl_b1_L0 <= cntl_b1;
			cntl_b2_L0 <= cntl_b2;
			cntl_b3_L0 <= cntl_b3;

			forward_i_L0 <= forward_i;
			min_intv_L0 <= min_intv;
			backward_x_L0 <= backward_x;

			query_L0 <= query;//only send the current query into the pipeline
			ptr_curr_L0 <= ptr_curr;// record the status of curr and mem queue


			read_num_L0 <= read_num;
			ik_x0_L0 <= ik_x0;
			ik_x1_L0 <= ik_x1;
			ik_x2_L0 <= ik_x2;
			ik_info_L0 <= ik_info;
		end
	end
	
	//-----------------------------------------------------------
	wire [63:0] ok0_x0_L0, ok0_x1_L0, ok0_x2_L0;
	wire [63:0] ok1_x0_L0, ok1_x1_L0, ok1_x2_L0;
	wire [63:0] ok2_x0_L0, ok2_x1_L0, ok2_x2_L0;
	wire [63:0] ok3_x0_L0, ok3_x1_L0, ok3_x2_L0;
	
	wire [6:0] forward_i_L00;
	wire [6:0] min_intv_L00;
	wire [6:0] backward_x_L00;
	
	wire [5:0] status_L00;
	wire [7:0] query_L00;//only send the current query into the pipeline
	wire [6:0] ptr_curr_L00;// record the status of curr and mem queue
	wire [6:0] ptr_curr_L00_add_1;
	
	wire [`READ_NUM_WIDTH - 1:0] read_num_L00;
	wire [63:0] ik_x0_L00, ik_x1_L00, ik_x2_L00, ik_info_L00;
	
	wire [7:0] query_L00_one_cycle_ahead;
	wire [63:0] ok_target_x0_L0, ok_target_x1_L0, ok_target_x2_L0;
	reg  [63:0] ok_target_x0_L1, ok_target_x1_L1, ok_target_x2_L1;
	
	BWT_extend BWT_ext_U0(
		//.status(status_L0), 
		//------------------------------------------
		.stall(stall),
		 .Clk_32UI         (Clk_32UI),  
		 .reset_BWT_extend (reset_BWT_extend),
		 .forward_all_done (forward_all_done_L0),
		 .primary          (primary),
		 .k                (forward_k_L0),     	.l                (forward_l_L0),
		 .cnt_a0           (cnt_a0_L0),     		.cnt_a1           (cnt_a1_L0),
		 .cnt_a2           (cnt_a2_L0),     		.cnt_a3           (cnt_a3_L0),
		 .cnt_b0           (cnt_b0_L0),     		.cnt_b1           (cnt_b1_L0),
		 .cnt_b2           (cnt_b2_L0),     		.cnt_b3           (cnt_b3_L0),
		 .cntl_a0          (cntl_a0_L0),    		.cntl_a1          (cntl_a1_L0),
		 .cntl_a2          (cntl_a2_L0),     		.cntl_a3          (cntl_a3_L0),
		 .cntl_b0          (cntl_b0_L0),     		.cntl_b1          (cntl_b1_L0),
		 .cntl_b2          (cntl_b2_L0),     		.cntl_b3          (cntl_b3_L0),
		 .L2_0             (L2_0),     			.L2_1             (L2_1),
		 .L2_2             (L2_2),     			.L2_3             (L2_3),
		 .ik_x0            (ik_x0_L0),
		 .ik_x1            (ik_x1_L0),
		 .ik_x2            (ik_x2_L0),
		 
		 .query_L00_one_cycle_ahead(query_L00_one_cycle_ahead),
		 .ok_target_x0(ok_target_x0_L0), 
		 .ok_target_x1(ok_target_x1_L0), 
		 .ok_target_x2(ok_target_x2_L0),
		 
		 //output
		 .ok0_x0 (ok0_x0_L0),     .ok0_x1 (ok0_x1_L0),     .ok0_x2 (ok0_x2_L0),
		 .ok1_x0 (ok1_x0_L0),     .ok1_x1 (ok1_x1_L0),     .ok1_x2 (ok1_x2_L0),     
		 .ok2_x0 (ok2_x0_L0),     .ok2_x1 (ok2_x1_L0),     .ok2_x2 (ok2_x2_L0),
		 .ok3_x0 (ok3_x0_L0),     .ok3_x1 (ok3_x1_L0),     .ok3_x2 (ok3_x2_L0)  

		 //.status_L00(status_L00)
	);
   
	//need a pipe for other inputs
	wire status_L00_eq_F_run, status_L00_eq_F_break;
	wire forward_i_L00_eq_Len;
	Pipe_BWT_extend pipe_BWT_extend(
	    .Clk_32UI(Clk_32UI),
		.reset_BWT_extend(reset_BWT_extend),
		.stall(stall),
		
		.forward_i_L0 (forward_i_L0),
		.min_intv_L0 (min_intv_L0),
		.backward_x_L0(backward_x_L0),

		.status_L0 (status_L0),
		.query_L0 (query_L0),//only send the current query into the pipeline
		.ptr_curr_L0 (ptr_curr_L0),// record the status of curr and mem queue

		.read_num_L0 (read_num_L0),
		.ik_x0_L0 (ik_x0_L0),
		.ik_x1_L0 (ik_x1_L0),
		.ik_x2_L0 (ik_x2_L0),
		.ik_info_L0 (ik_info_L0),
	
		//----------------------
		
		.forward_i_pipe (forward_i_L00),
		
		.min_intv_pipe (min_intv_L00),
		.backward_x_pipe(backward_x_L00),

		.status_pipe (status_L00),
		
		.query_pipe (query_L00),//only send the current query into the pipeline
		.ptr_curr_pipe (ptr_curr_L00),// record the status of curr and mem queue
		.ptr_curr_pipe_add_1(ptr_curr_L00_add_1),
		.read_num_pipe (read_num_L00),
		.ik_x0_pipe (ik_x0_L00),
		.ik_x1_pipe (ik_x1_L00),
		.ik_x2_pipe (ik_x2_L00),
		.ik_info_pipe (ik_info_L00),
		
		.status_L00_eq_F_run(status_L00_eq_F_run),
		.status_L00_eq_F_break(status_L00_eq_F_break),
		.forward_i_L00_eq_Len(forward_i_L00_eq_Len),
		.query_L00_one_cycle_ahead(query_L00_one_cycle_ahead)
	
	);
	
	//--------------------------------------------------
	//L1
	reg is_update_ik, is_add_i;
	
	reg [63:0] ok0_x0_L1, ok0_x1_L1, ok0_x2_L1;
    reg [63:0] ok1_x0_L1, ok1_x1_L1, ok1_x2_L1;
    reg [63:0] ok2_x0_L1, ok2_x1_L1, ok2_x2_L1;
    reg [63:0] ok3_x0_L1, ok3_x1_L1, ok3_x2_L1;
	
	reg [6:0] forward_i_L1;
	reg [6:0] min_intv_L1;
	reg [6:0] backward_x_L1;
	
	reg [5:0] status_L1;
	reg [7:0] query_L1;//only send the current query into the pipeline
	reg [6:0] ptr_curr_L1;// record the status of curr and mem queue

	
	reg [`READ_NUM_WIDTH - 1:0] read_num_L1;
	reg [63:0] ik_x0_L1, ik_x1_L1, ik_x2_L1, ik_info_L1;

	
	
	always@(posedge Clk_32UI) begin
		if(!reset_BWT_extend) begin
			status_L1 <= BUBBLE;
			curr_read_num_1 <= 0;
			curr_we_1 <= 0;
			curr_data_1 <= 0;
			curr_addr_1 <= 0;
		end
		else if(!stall) begin
			curr_read_num_1 <= read_num_L00;
			curr_data_1 <= {ik_info_L00, ik_x2_L00, ik_x1_L00, ik_x0_L00};
			curr_addr_1 <= ptr_curr_L00;

			
			if(status_L00_eq_F_run) begin
				ret <= 0;
				ret_valid <= 0;
				ret_read_num <= 0;
				
				if (ok_target_x2_L0 != ik_x2_L00) begin
					
					curr_we_1 <= 1;
					
					ptr_curr_L1 <= ptr_curr_L00_add_1;
					
					if (ok_target_x2_L0 < min_intv_L00) begin
						status_L1 <= F_break; // if (ok[c].x[2] < min_intv) break;
						is_update_ik <= 0; // after break, "ik = ok[c]; ik.info = i + 1;" won't be executed.
						is_add_i <= 0;
					end
					else begin
						status_L1 <= status_L00;
						is_update_ik <= 1; // after break, "ik = ok[c]; ik.info = i + 1;" won't be executed.
						is_add_i <= 1;
					end
				end
				else begin
					curr_we_1 <= 0;

					ptr_curr_L1 <= ptr_curr_L00;
					status_L1 <= status_L00;
					is_update_ik <= 1;
					is_add_i <= 1;
				end
			end
			else if(status_L00_eq_F_break) begin
				if(forward_i_L00_eq_Len) begin
					curr_we_1 <= 1;
					ptr_curr_L1 <= ptr_curr_L00_add_1;
				end
				else begin
					curr_we_1 <= 0;
					ptr_curr_L1 <= ptr_curr_L00;
				end
				
				ret <= ik_info_L00[6:0];
				ret_valid <= 1;
				ret_read_num <= read_num_L00;
				
				status_L1 <= BCK_INI;
			
			end
			else begin
				curr_we_1 <= 0;
				ptr_curr_L1 <= ptr_curr_L00;
				status_L1 <= status_L00; // if (ok[c].x[2] < min_intv) break;
				is_update_ik <= 0; // after break, "ik = ok[c]; ik.info = i + 1;" won't be executed.
				is_add_i <= 0;
				
				ret <= 0;
				ret_valid <= 0;
				ret_read_num <= 0;
			end	
			
			//------------------------------
			
			ok0_x0_L1 <= ok0_x0_L0; ok0_x1_L1 <= ok0_x1_L0; ok0_x2_L1 <= ok0_x2_L0;
			ok1_x0_L1 <= ok1_x0_L0; ok1_x1_L1 <= ok1_x1_L0; ok1_x2_L1 <= ok1_x2_L0;
			ok2_x0_L1 <= ok2_x0_L0; ok2_x1_L1 <= ok2_x1_L0; ok2_x2_L1 <= ok2_x2_L0;
			ok3_x0_L1 <= ok3_x0_L0; ok3_x1_L1 <= ok3_x1_L0; ok3_x2_L1 <= ok3_x2_L0;
						
			ok_target_x0_L1 <= ok_target_x0_L0;
			ok_target_x1_L1 <= ok_target_x1_L0;
			ok_target_x2_L1 <= ok_target_x2_L0;
			
			forward_i_L1 <= forward_i_L00;
			min_intv_L1 <= min_intv_L00;
			backward_x_L1 <= backward_x_L00;
			
			query_L1 <= query_L00;//only send the current query into the pipeline
			read_num_L1 <= read_num_L00;
			ik_x0_L1 <= ik_x0_L00;
			ik_x1_L1 <= ik_x1_L00;
			ik_x2_L1 <= ik_x2_L00;
			ik_info_L1 <= ik_info_L00;	
		end
	end // end always
	
	//--------------------------------------------------
	//L2
	
		//----------------------
    
    reg [6:0] forward_i_L2;
    reg [6:0] min_intv_L2;
	reg [6:0] backward_x_L2;
    
    reg [5:0] status_L2;
    reg [7:0] query_L2;//only send the current query into the pipeline
    reg [6:0] ptr_curr_L2;// record the status of curr and mem queue

    
    reg [`READ_NUM_WIDTH - 1:0] read_num_L2;
    reg [63:0] ik_x0_L2, ik_x1_L2, ik_x2_L2, ik_info_L2;
	
	reg [63:0] forward_k_temp_L2;
	reg [63:0] forward_l_temp_L2;
	reg [63:0] forward_k_temp_L2_minus;
	reg [63:0] forward_l_temp_L2_minus;
	
	always@(posedge Clk_32UI) begin
		if(!reset_BWT_extend) begin
			status_L2 <= BUBBLE;
		end
		else if(!stall) begin
			if(status_L1 == F_run) begin
				if (is_update_ik) begin
					ik_x0_L2 <= ok_target_x0_L1;
					ik_x1_L2 <= ok_target_x1_L1;
					ik_x2_L2 <= ok_target_x2_L1;
					
					forward_k_temp_L2 <= ok_target_x1_L1 - 1;
					forward_l_temp_L2 <= ok_target_x1_L1 - 1 + ok_target_x2_L1;
					
					forward_k_temp_L2_minus <= ok_target_x1_L1 - 1 - 1;
					forward_l_temp_L2_minus <= ok_target_x1_L1 - 1 + ok_target_x2_L1 - 1;
					
					ik_info_L2 <= forward_i_L1 + 1;
				end
				else begin
					ik_x0_L2 <= ik_x0_L1;
					ik_x1_L2 <= ik_x1_L1;
					ik_x2_L2 <= ik_x2_L1;
					ik_info_L2 <= ik_info_L1;
					
					forward_k_temp_L2 <= ik_x1_L1 -1;
					forward_l_temp_L2 <= ik_x1_L1 -1 + ik_x2_L1;
					forward_k_temp_L2_minus <= ik_x1_L1 -1 - 1;
					forward_l_temp_L2_minus <= ik_x1_L1 -1 + ik_x2_L1 - 1;
				end
				
				if (is_add_i) begin
					forward_i_L2 <= forward_i_L1 + 1; //i++
				end
				else begin
					forward_i_L2 <= forward_i_L1;
				end         
			end
			else begin
				ik_x0_L2 <= ik_x0_L1;
				ik_x1_L2 <= ik_x1_L1;
				ik_x2_L2 <= ik_x2_L1;
				ik_info_L2 <= ik_info_L1;
				forward_i_L2 <= forward_i_L1;
				
				forward_k_temp_L2 <= ik_x1_L1 -1;
				forward_l_temp_L2 <= ik_x1_L1 -1 + ik_x2_L1;
				forward_k_temp_L2_minus <= ik_x1_L1 -1 - 1;
				forward_l_temp_L2_minus <= ik_x1_L1 -1 + ik_x2_L1 - 1;
			end
			status_L2 <= status_L1;

			min_intv_L2 <= min_intv_L1;
			backward_x_L2 <= backward_x_L1;

			status_L2 <= status_L1;
			//query_L2 <= query_L1; //no need to use query anymore
			ptr_curr_L2 <= ptr_curr_L1;


			read_num_L2 <= read_num_L1;
		end
	end // end always
	
	//==============================================================
	reg [6:0] forward_i_L22;
    reg [6:0] min_intv_L22;
	reg [6:0] backward_x_L22;
    
    reg [5:0] status_L22;
    reg [6:0] ptr_curr_L22;// record the status of curr and mem queue

    
    reg [`READ_NUM_WIDTH - 1:0] read_num_L22;
    reg [63:0] ik_x0_L22, ik_x1_L22, ik_x2_L22, ik_info_L22;
	
	reg [63:0] forward_k_temp_L22;
	reg [63:0] forward_l_temp_L22;
	reg [63:0] forward_k_temp_L22_minus;
	reg [63:0] forward_l_temp_L22_minus;
	
	//------------------------------
	
	reg [6:0] forward_i_L222;
    reg [6:0] min_intv_L222;
	reg [6:0] backward_x_L222;
    
    reg [5:0] status_L222;
    reg [6:0] ptr_curr_L222;// record the status of curr and mem queue

    
    reg [`READ_NUM_WIDTH - 1:0] read_num_L222;
    reg [63:0] ik_x0_L222, ik_x1_L222, ik_x2_L222, ik_info_L222;
	
	reg [63:0] forward_k_temp_L222;
	reg [63:0] forward_l_temp_L222;
	reg [63:0] forward_k_temp_L222_minus;
	reg [63:0] forward_l_temp_L222_minus;
	
	//------------------------------
	
	reg [6:0] forward_i_L2222;
    reg [6:0] min_intv_L2222;
	reg [6:0] backward_x_L2222;
    
    reg [5:0] status_L2222;
    reg [6:0] ptr_curr_L2222;// record the status of curr and mem queue

    
    reg [`READ_NUM_WIDTH - 1:0] read_num_L2222;
    reg [63:0] ik_x0_L2222, ik_x1_L2222, ik_x2_L2222, ik_info_L2222;
	
	reg [63:0] forward_k_temp_L2222;
	reg [63:0] forward_l_temp_L2222;
	reg [63:0] forward_k_temp_L2222_minus;
	reg [63:0] forward_l_temp_L2222_minus;
	
	always@(posedge Clk_32UI) begin
		if(!reset_BWT_extend) begin
			status_L2222 <= BUBBLE;
		
		end
		else if(!stall) begin
			forward_i_L2222 		<= forward_i_L2;
			min_intv_L2222 		<= min_intv_L2;
			backward_x_L2222 		<= backward_x_L2;
			status_L2222 			<= status_L2;
			ptr_curr_L2222 		<= ptr_curr_L2;
			read_num_L2222 		<= read_num_L2;
			ik_x0_L2222 			<= ik_x0_L2;
			ik_x1_L2222 			<= ik_x1_L2;
			ik_x2_L2222 			<= ik_x2_L2;
			ik_info_L2222 		<= ik_info_L2;
			forward_k_temp_L2222 	<= forward_k_temp_L2;
			forward_l_temp_L2222 	<= forward_l_temp_L2;
			forward_k_temp_L2222_minus 	<= forward_k_temp_L2_minus;
			forward_l_temp_L2222_minus 	<= forward_l_temp_L2_minus;		
		end
	
	end
	
	always@(posedge Clk_32UI) begin
		if(!reset_BWT_extend) begin
			status_L222 <= BUBBLE;
		
		end
		else if(!stall) begin
			forward_i_L222 		<= forward_i_L2222;
			min_intv_L222 		<= min_intv_L2222;
			backward_x_L222 		<= backward_x_L2222;
			status_L222 			<= status_L2222;
			ptr_curr_L222 		<= ptr_curr_L2222;
			read_num_L222 		<= read_num_L2222;
			ik_x0_L222 			<= ik_x0_L2222;
			ik_x1_L222 			<= ik_x1_L2222;
			ik_x2_L222 			<= ik_x2_L2222;
			ik_info_L222 		<= ik_info_L2222;
			forward_k_temp_L222 	<= forward_k_temp_L2222;
			forward_l_temp_L222 	<= forward_l_temp_L2222;
			forward_k_temp_L222_minus 	<= forward_k_temp_L2222_minus;
			forward_l_temp_L222_minus 	<= forward_l_temp_L2222_minus;		
		end
	
	end
	
	always@(posedge Clk_32UI) begin
		if(!reset_BWT_extend) begin
			status_L22 <= BUBBLE;
		
		end
		else if(!stall) begin
			forward_i_L22 		<= forward_i_L222;
			min_intv_L22 		<= min_intv_L222;
			backward_x_L22 		<= backward_x_L222;
			status_L22 			<= status_L222;
			ptr_curr_L22 		<= ptr_curr_L222;
			read_num_L22 		<= read_num_L222;
			ik_x0_L22 			<= ik_x0_L222;
			ik_x1_L22 			<= ik_x1_L222;
			ik_x2_L22 			<= ik_x2_L222;
			ik_info_L22 		<= ik_info_L222;
			forward_k_temp_L22 	<= forward_k_temp_L222;
			forward_l_temp_L22 	<= forward_l_temp_L222;
			forward_k_temp_L22_minus 	<= forward_k_temp_L222_minus;
			forward_l_temp_L22_minus 	<= forward_l_temp_L222_minus;		
			
			//query request one cycle ahead
			status_query <= status_L222;
			read_num_query <= read_num_L222;
			next_query_position <= forward_i_L222;
		end
	
	end
	
	
	//==============================================================
	//-----------------------------------------------------
	//L3 end of forward pipeline, send out memory request
	
	wire is_k_minus = forward_k_temp_L22 >= primary;
	wire is_l_minus = forward_l_temp_L22 >= primary;
	wire [63:0] forward_k_L22 = is_k_minus ? forward_k_temp_L22_minus : forward_k_temp_L22;
    wire [63:0] forward_l_L22 = is_l_minus ? forward_l_temp_L22_minus : forward_l_temp_L22;
	
	always@(posedge Clk_32UI) begin
		if(!reset_BWT_extend) begin
			status_out <= BUBBLE;
		end
		else if(!stall) begin
			if(status_L22 == F_init || status_L22 == F_run) begin //if break, no memory access and no next query
				DRAM_valid <= 1;
				addr_k <= {forward_k_L22[34:7], 4'b0};
				addr_l <= {forward_l_L22[34:7], 4'b0};
			end
			else begin
				DRAM_valid <= 0;
				addr_k <= 0;
				addr_l <= 0;
			end
			
			if (status_L22 == F_init) begin
				status_out <= F_run;
			end
			else begin
				status_out <= status_L22;
			end
			
			

			ptr_curr_out<= ptr_curr_L22; // record the status of curr and mem queue
			read_num_out<= read_num_L22;
			ik_x0_out<= ik_x0_L22; 
			ik_x1_out<= ik_x1_L22; 
			ik_x2_out<= ik_x2_L22; 
			ik_info_out<= ik_info_L22;
			forward_i_out <= forward_i_L22;
			min_intv_out <= min_intv_L22;
			backward_x_out <= backward_x_L22;
			

		end
		// else begin
			// [very important] in case the DRAM_valid is kept valid during stall. 
			// DRAM_valid <= 0;	
			// addr_k <= 0;
			// addr_l <= 0;
		// end
	end

endmodule

/////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////

module Pipe_BWT_extend(
		input reset_BWT_extend, 
        input Clk_32UI,
		input stall,
		
		input [6:0] forward_i_L0,
		input [6:0] min_intv_L0,
		input [6:0] backward_x_L0,

		input [5:0] status_L0,
		input [7:0] query_L0,//only send the current query into the pipeline
		input [6:0] ptr_curr_L0,// record the status of curr and mem queue


		input [`READ_NUM_WIDTH - 1:0] read_num_L0,
		input [63:0] ik_x0_L0, ik_x1_L0, ik_x2_L0, ik_info_L0,
	
		//----------------------
		
		output reg [6:0] forward_i_pipe,
		output reg forward_i_L00_eq_Len,
		
		output reg [6:0] min_intv_pipe,
		output reg [6:0] backward_x_pipe,

		output reg [5:0] status_pipe,
		output reg status_L00_eq_F_run, status_L00_eq_F_break,
		output reg [7:0] query_L00_one_cycle_ahead,
		
		output reg [7:0] query_pipe,//only send the current query into the pipeline
		output reg [6:0] ptr_curr_pipe,// record the status of curr and mem queue
		output reg [6:0] ptr_curr_pipe_add_1,

		output reg [`READ_NUM_WIDTH - 1:0] read_num_pipe,
		output reg [63:0] ik_x0_pipe, ik_x1_pipe, ik_x2_pipe, ik_info_pipe

	);
	
	parameter Len = 101;
	
	parameter F_init = 	6'b00_0001; // F_init will disable the forward pipeline
	parameter F_run =  	6'b00_0010;
	parameter F_break = 6'b00_0100;
	parameter BCK_INI = 6'b00_1000;	//100
	parameter BCK_RUN = 6'b01_0000;	//101
	parameter BCK_END = 6'b10_0000;	//110
	parameter BUBBLE = 	6'b00_0000;
	
	reg [6:0] forward_i_L1;
	reg [6:0] min_intv_L1;
	reg [6:0] backward_x_L1;
	
	reg [5:0] status_L1;
	reg [7:0] query_L1;//only send the current query into the pipeline
	reg [6:0] ptr_curr_L1;// record the status of curr and mem queue

	
	reg [`READ_NUM_WIDTH - 1:0] read_num_L1;
	reg [63:0] ik_x0_L1, ik_x1_L1, ik_x2_L1, ik_info_L1;

		//----------------------
	
	reg [6:0] forward_i_L2;
	reg [6:0] min_intv_L2;
	reg [6:0] backward_x_L2;
	
	reg [5:0] status_L2;
	reg [7:0] query_L2;//only send the current query into the pipeline
	reg [6:0] ptr_curr_L2;// record the status of curr and mem queue

	
	reg [`READ_NUM_WIDTH - 1:0] read_num_L2;
	reg [63:0] ik_x0_L2, ik_x1_L2, ik_x2_L2, ik_info_L2;

		//----------------------
	
	reg [6:0] forward_i_L3;
	reg [6:0] min_intv_L3;
	reg [6:0] backward_x_L3;
	
	reg [5:0] status_L3;
	reg [7:0] query_L3;//only send the current query into the pipeline
	reg [6:0] ptr_curr_L3;// record the status of curr and mem queue

	
	reg [`READ_NUM_WIDTH - 1:0] read_num_L3;
	reg [63:0] ik_x0_L3, ik_x1_L3, ik_x2_L3, ik_info_L3;

		//----------------------
	
	reg [6:0] forward_i_L4;
	reg [6:0] min_intv_L4;
	reg [6:0] backward_x_L4;
	
	reg [5:0] status_L4;
	reg [7:0] query_L4;//only send the current query into the pipeline
	reg [6:0] ptr_curr_L4;// record the status of curr and mem queue

	
	reg [`READ_NUM_WIDTH - 1:0] read_num_L4;
	reg [63:0] ik_x0_L4, ik_x1_L4, ik_x2_L4, ik_info_L4;

		//----------------------
	
	reg [6:0] forward_i_L5;
	reg [6:0] min_intv_L5;
	reg [6:0] backward_x_L5;
	
	reg [5:0] status_L5;
	reg [7:0] query_L5;//only send the current query into the pipeline
	reg [6:0] ptr_curr_L5;// record the status of curr and mem queue

	
	reg [`READ_NUM_WIDTH - 1:0] read_num_L5;
	reg [63:0] ik_x0_L5, ik_x1_L5, ik_x2_L5, ik_info_L5;

		//----------------------
	
	reg [6:0] forward_i_L6;
	reg [6:0] min_intv_L6;
	reg [6:0] backward_x_L6;
	
	reg [5:0] status_L6;
	reg [7:0] query_L6;//only send the current query into the pipeline
	reg [6:0] ptr_curr_L6;// record the status of curr and mem queue

	
	reg [`READ_NUM_WIDTH - 1:0] read_num_L6;
	reg [63:0] ik_x0_L6, ik_x1_L6, ik_x2_L6, ik_info_L6;

		//----------------------
	
	reg [6:0] forward_i_L7;
	reg [6:0] min_intv_L7;
	reg [6:0] backward_x_L7;
	
	reg [5:0] status_L7;
	reg [7:0] query_L7;//only send the current query into the pipeline
	reg [6:0] ptr_curr_L7;// record the status of curr and mem queue

	
	reg [`READ_NUM_WIDTH - 1:0] read_num_L7;
	reg [63:0] ik_x0_L7, ik_x1_L7, ik_x2_L7, ik_info_L7;

		//----------------------
	
	reg [6:0] forward_i_L8;
	reg [6:0] min_intv_L8;
	reg [6:0] backward_x_L8;
	
	reg [5:0] status_L8;
	reg [7:0] query_L8;//only send the current query into the pipeline
	reg [6:0] ptr_curr_L8;// record the status of curr and mem queue

	
	reg [`READ_NUM_WIDTH - 1:0] read_num_L8;
	reg [63:0] ik_x0_L8, ik_x1_L8, ik_x2_L8, ik_info_L8;

		//----------------------
	
	reg [6:0] forward_i_L9;
	reg [6:0] min_intv_L9;
	reg [6:0] backward_x_L9;
	
	reg [5:0] status_L9;
	reg [7:0] query_L9;//only send the current query into the pipeline
	reg [6:0] ptr_curr_L9;// record the status of curr and mem queue

	
	reg [`READ_NUM_WIDTH - 1:0] read_num_L9;
	reg [63:0] ik_x0_L9, ik_x1_L9, ik_x2_L9, ik_info_L9;

		//----------------------
	
	reg [6:0] forward_i_L10;
	reg [6:0] min_intv_L10;
	reg [6:0] backward_x_L10;
	
	reg [5:0] status_L10;
	reg [7:0] query_L10;//only send the current query into the pipeline
	reg [6:0] ptr_curr_L10;// record the status of curr and mem queue

	
	reg [`READ_NUM_WIDTH - 1:0] read_num_L10;
	reg [63:0] ik_x0_L10, ik_x1_L10, ik_x2_L10, ik_info_L10;

		//----------------------
	
	reg [6:0] forward_i_L11;
	reg [6:0] min_intv_L11;
	reg [6:0] backward_x_L11;
	
	reg [5:0] status_L11;
	reg [7:0] query_L11;//only send the current query into the pipeline
	reg [6:0] ptr_curr_L11;// record the status of curr and mem queue

	
	reg [`READ_NUM_WIDTH - 1:0] read_num_L11;
	reg [63:0] ik_x0_L11, ik_x1_L11, ik_x2_L11, ik_info_L11;
	
	
		//----------------------

	always@(posedge Clk_32UI) begin
		if(!reset_BWT_extend) begin
			status_L1 <= BUBBLE;
		end
		else if(!stall) begin
			forward_i_L1 <= forward_i_L0;
			min_intv_L1 <= min_intv_L0;
			backward_x_L1 <= backward_x_L0;

			status_L1 <= status_L0;
			query_L1 <= query_L0;//only send the current query into the pipeline
			ptr_curr_L1 <= ptr_curr_L0;// record the status of curr and mem queue


			read_num_L1 <= read_num_L0;
			ik_x0_L1 <= ik_x0_L0;
			ik_x1_L1 <= ik_x1_L0;
			ik_x2_L1 <= ik_x2_L0;
			ik_info_L1 <= ik_info_L0;		
		end
	end
	
	always@(posedge Clk_32UI) begin
		if(!reset_BWT_extend) begin
			status_L2 <= BUBBLE;
		end
		else if(!stall) begin
			forward_i_L2 <= forward_i_L1;
			min_intv_L2 <= min_intv_L1;
			backward_x_L2 <= backward_x_L1;

			status_L2 <= status_L1;
			query_L2 <= query_L1;//only send the current query into the pipeline
			ptr_curr_L2 <= ptr_curr_L1;// record the status of curr and mem queue


			read_num_L2 <= read_num_L1;
			ik_x0_L2 <= ik_x0_L1;
			ik_x1_L2 <= ik_x1_L1;
			ik_x2_L2 <= ik_x2_L1;
			ik_info_L2 <= ik_info_L1;	
		end
	end
	
	always@(posedge Clk_32UI) begin
		if(!reset_BWT_extend) begin
			status_L3 <= BUBBLE;
		end
		else if(!stall) begin
			forward_i_L3 <= forward_i_L2;
			min_intv_L3 <= min_intv_L2;
			backward_x_L3 <= backward_x_L2;

			status_L3 <= status_L2;
			query_L3 <= query_L2;//only send the current query into the pipeline
			ptr_curr_L3 <= ptr_curr_L2;// record the status of curr and mem queue


			read_num_L3 <= read_num_L2;
			ik_x0_L3 <= ik_x0_L2;
			ik_x1_L3 <= ik_x1_L2;
			ik_x2_L3 <= ik_x2_L2;
			ik_info_L3 <= ik_info_L2;		
		end
	end
	
	always@(posedge Clk_32UI) begin
		if(!reset_BWT_extend) begin
			status_L4 <= BUBBLE;
		end
		else if(!stall) begin
			forward_i_L4 <= forward_i_L3;
			min_intv_L4 <= min_intv_L3;
			backward_x_L4 <= backward_x_L3;

			status_L4 <= status_L3;
			query_L4 <= query_L3;//only send the current query into the pipeline
			ptr_curr_L4 <= ptr_curr_L3;// record the status of curr and mem queue


			read_num_L4 <= read_num_L3;
			ik_x0_L4 <= ik_x0_L3;
			ik_x1_L4 <= ik_x1_L3;
			ik_x2_L4 <= ik_x2_L3;
			ik_info_L4 <= ik_info_L3;		
		end
	end
	
	always@(posedge Clk_32UI) begin
		if(!reset_BWT_extend) begin
			status_L5 <= BUBBLE;
		end
		else if(!stall) begin
			forward_i_L5 <= forward_i_L4;
			min_intv_L5 <= min_intv_L4;
			backward_x_L5 <= backward_x_L4;

			status_L5 <= status_L4;
			query_L5 <= query_L4;//only send the current query into the pipeline
			ptr_curr_L5 <= ptr_curr_L4;// record the status of curr and mem queue


			read_num_L5 <= read_num_L4;
			ik_x0_L5 <= ik_x0_L4;
			ik_x1_L5 <= ik_x1_L4;
			ik_x2_L5 <= ik_x2_L4;
			ik_info_L5 <= ik_info_L4;		
		end
	end
	
	always@(posedge Clk_32UI) begin
		if(!reset_BWT_extend) begin
			status_L6 <= BUBBLE;
		end
		else if(!stall) begin
			forward_i_L6 <= forward_i_L5;
			min_intv_L6 <= min_intv_L5;
			backward_x_L6 <= backward_x_L5;

			status_L6 <= status_L5;
			query_L6 <= query_L5;//only send the current query into the pipeline
			ptr_curr_L6 <= ptr_curr_L5;// record the status of curr and mem queue


			read_num_L6 <= read_num_L5;
			ik_x0_L6 <= ik_x0_L5;
			ik_x1_L6 <= ik_x1_L5;
			ik_x2_L6 <= ik_x2_L5;
			ik_info_L6 <= ik_info_L5;		
		end
	end
	
	always@(posedge Clk_32UI) begin
		if(!reset_BWT_extend) begin
			status_L7 <= BUBBLE;
		end
		else if(!stall) begin	
			forward_i_L7 <= forward_i_L6;
			min_intv_L7 <= min_intv_L6;
			backward_x_L7 <= backward_x_L6;

			status_L7 <= status_L6;
			query_L7 <= query_L6;//only send the current query into the pipeline
			ptr_curr_L7 <= ptr_curr_L6;// record the status of curr and mem queue


			read_num_L7 <= read_num_L6;
			ik_x0_L7 <= ik_x0_L6;
			ik_x1_L7 <= ik_x1_L6;
			ik_x2_L7 <= ik_x2_L6;
			ik_info_L7 <= ik_info_L6;		
		end
	end
	
	always@(posedge Clk_32UI) begin
		if(!reset_BWT_extend) begin
			status_L8 <= BUBBLE;
		end
		else if(!stall) begin
			forward_i_L8 <= forward_i_L7;
			min_intv_L8 <= min_intv_L7;
			backward_x_L8 <= backward_x_L7;

			status_L8 <= status_L7;
			query_L8 <= query_L7;//only send the current query into the pipeline
			ptr_curr_L8 <= ptr_curr_L7;// record the status of curr and mem queue


			read_num_L8 <= read_num_L7;
			ik_x0_L8 <= ik_x0_L7;
			ik_x1_L8 <= ik_x1_L7;
			ik_x2_L8 <= ik_x2_L7;
			ik_info_L8 <= ik_info_L7;		
		end
	end
	
	always@(posedge Clk_32UI) begin
		if(!reset_BWT_extend) begin
			status_L9 <= BUBBLE;
		end
		else if(!stall) begin
			forward_i_L9 <= forward_i_L8;
			min_intv_L9 <= min_intv_L8;
			backward_x_L9 <= backward_x_L8;

			status_L9 <= status_L8;
			query_L9 <= query_L8;//only send the current query into the pipeline
			ptr_curr_L9 <= ptr_curr_L8;// record the status of curr and mem queue


			read_num_L9 <= read_num_L8;
			ik_x0_L9 <= ik_x0_L8;
			ik_x1_L9 <= ik_x1_L8;
			ik_x2_L9 <= ik_x2_L8;
			ik_info_L9 <= ik_info_L8;		
		end
	end
	
	always@(posedge Clk_32UI) begin
		if(!reset_BWT_extend) begin
			status_L10 <= BUBBLE;
		end
		else if(!stall) begin
			forward_i_L10 <= forward_i_L9;
			min_intv_L10 <= min_intv_L9;
			backward_x_L10 <= backward_x_L9;

			status_L10 <= status_L9;
			query_L10 <= query_L9;//only send the current query into the pipeline
			ptr_curr_L10 <= ptr_curr_L9;// record the status of curr and mem queue


			read_num_L10 <= read_num_L9;
			ik_x0_L10 <= ik_x0_L9;
			ik_x1_L10 <= ik_x1_L9;
			ik_x2_L10 <= ik_x2_L9;
			ik_info_L10 <= ik_info_L9;		
		end
	end
	
	always@(posedge Clk_32UI) begin
		if(!reset_BWT_extend) begin
			status_L11 <= BUBBLE;
		end
		else if(!stall) begin
			forward_i_L11 <= forward_i_L10;
			min_intv_L11 <= min_intv_L10;
			backward_x_L11 <= backward_x_L10;

			status_L11 <= status_L10;
			query_L11 <= query_L10;//only send the current query into the pipeline
			ptr_curr_L11 <= ptr_curr_L10;// record the status of curr and mem queue

			query_L00_one_cycle_ahead <=  query_L10;
			
			read_num_L11 <= read_num_L10;
			ik_x0_L11 <= ik_x0_L10;
			ik_x1_L11 <= ik_x1_L10;
			ik_x2_L11 <= ik_x2_L10;
			ik_info_L11 <= ik_info_L10;		
		end
	end
	
	always@(posedge Clk_32UI) begin
		if(!reset_BWT_extend) begin
			status_pipe <= BUBBLE;
		end
		else if(!stall) begin
			forward_i_pipe <= forward_i_L11;
			min_intv_pipe <= min_intv_L11;
			backward_x_pipe <= backward_x_L11;

			status_pipe <= status_L11;
			query_pipe <= query_L11;//only send the current query into the pipeline
			ptr_curr_pipe <= ptr_curr_L11;// record the status of curr and mem queue
			ptr_curr_pipe_add_1 <= ptr_curr_L11+1;

			read_num_pipe <= read_num_L11;
			ik_x0_pipe <= ik_x0_L11;
			ik_x1_pipe <= ik_x1_L11;
			ik_x2_pipe <= ik_x2_L11;
			ik_info_pipe <= ik_info_L11;	
			
			status_L00_eq_F_run <= (status_L11==F_run);
			status_L00_eq_F_break <= (status_L11 == F_break);
			forward_i_L00_eq_Len <= (forward_i_L11 == Len);
		end			
	end
	
endmodule