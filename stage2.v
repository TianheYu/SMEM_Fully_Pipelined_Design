`define CL 512
`define MAX_READ 1024
`define READ_NUM_WIDTH 10
module CONTROL_STAGE2(
input wire clk,
input wire rst,
input wire stall,

input wire last_one_read_q,
input wire [63:0]	pendingcurr_x_0_q,
input wire [63:0]	pendingcurr_x_1_q,
input wire [63:0]	pendingcurr_x_2_q,
input wire [63:0]	pendingcurr_x_info_q,

input wire [`READ_NUM_WIDTH - 1:0] read_num_q,//onchip reads will not exceed 1024
input wire [5:0] status_q,
input wire [63:0] primary_q,
input wire [6:0] forward_size_n_q,
input wire [6:0] new_size_q,
input wire [6:0] new_last_size_q,
input wire [6:0] current_wr_addr_q,current_rd_addr_q,mem_wr_addr_q,
input wire [6:0] backward_i_q, backward_j_q,
input wire [7:0] output_c_q,//new_output_c,
input wire [6:0] min_intv_q,
input wire [63:0]	reserved_token_x2_q,
input wire [31:0]	reserved_mem_info_q,
input wire iteration_boundary_q,
//input wire j_bound;

output reg [`READ_NUM_WIDTH - 1:0] read_num,
output reg [6:0] current_rd_addr,

output reg last_one_read,
output reg [63:0]	pendingcurr_x_0,
output reg [63:0]	pendingcurr_x_1,
output reg [63:0]	pendingcurr_x_2,
output reg [63:0]	pendingcurr_x_info,

//signals handled to next stage
output reg [63:0] primary,
output reg [6:0] forward_size_n,
output reg [6:0] new_size,
output reg [6:0] new_last_size,
output reg [6:0] current_wr_addr,mem_wr_addr,
output reg [6:0] backward_i, backward_j,
output reg [7:0] output_c,
output reg [6:0] min_intv,
output reg finish_sign,iteration_boundary,
output reg [63:0]	reserved_token_x2,
output reg [31:0]	reserved_mem_info,
output reg [5:0] status
);
	parameter Len = 101;
	
	parameter F_init = 	6'b00_0001; // F_init will disable the forward pipeline
	parameter F_run =  	6'b00_0010;
	parameter F_break = 6'b00_0100;
	parameter BCK_INI = 6'b00_1000;	//100
	parameter BCK_RUN = 6'b01_0000;	//101
	parameter BCK_END = 6'b10_0000;	//110
	parameter BUBBLE = 	6'b00_0000;
	//j & i control logic 

	wire [6:0] backward_j_d, backward_i_d;
	wire finish_sign_d,iteration_boundary_d;
	wire [6:0] initial_pos;
	wire i_bound;
	wire i_bound_n;
	wire [7:0] output_c_d;
	wire [6:0] current_wr_addr_d;
	//during execution
	wire [6:0] new_last_size_d,new_size_d;

	assign initial_pos		= forward_size_n_q - 1;
	assign j_bound			= (backward_j_q == (new_last_size_q - 1));
	assign i_bound			= j_bound & (backward_i_q > 0);
	assign i_bound_n		= j_bound & (backward_i_q == 0);

	assign finish_sign_d		= j_bound & (new_size_q == 0);
	assign iteration_boundary_d = iteration_boundary_q | (i_bound_n);
	assign backward_i_d			= i_bound ? (backward_i_q - 1) : backward_i_q;
//	assign output_c_d			= i_bound ? new_output_c : output_c_q; //read[read_num_q][backward_i_q*8-1 : (backward_i_q*8-8)]
	assign backward_j_d			= j_bound ? 0 : (backward_j_q + 1); //if reach to the bound, change to 0. otherwisre + 1;
	assign current_wr_addr_d	= j_bound ? initial_pos : current_wr_addr_q;
	
	assign new_last_size_d		= j_bound ? new_size_q : new_last_size_q;
	assign new_size_d			= j_bound ? 0 : new_size_q;

	//wire lastone;
	//assign lastone = (new_size_q == 7'b1) && j_bound;

	always @(posedge clk) begin
		if(!rst)begin
			pendingcurr_x_0 <= 0;
			pendingcurr_x_1 <= 0;
			pendingcurr_x_2 <= 0;
			pendingcurr_x_info <= 0;
			finish_sign			<= 0;
			iteration_boundary	<= 0;
			backward_i			<= 0;
			backward_j			<= 0;
			output_c			<= 0;
			current_wr_addr		<= 0;
			current_rd_addr		<= 0;
		
			min_intv			<= 0;
			new_size			<= 0;
			read_num			<= 0;
			mem_wr_addr			<= 0;
			forward_size_n		<= 0;
			new_last_size		<= 0;
			primary				<= 0;
			reserved_token_x2	<= 0;
			reserved_mem_info	<= 0;
			last_one_read <= 0;
			status <= 5'b11110;
		end	
		else if (stall == 1) begin
			primary				<= primary;
						pendingcurr_x_0 <= pendingcurr_x_0;
			pendingcurr_x_1 <= pendingcurr_x_1;
			pendingcurr_x_2 <= pendingcurr_x_2;
			pendingcurr_x_info <= pendingcurr_x_info;
			reserved_token_x2	<= reserved_token_x2;
			reserved_mem_info	<= reserved_mem_info;
			finish_sign			<= finish_sign;
			iteration_boundary	<= iteration_boundary;
			backward_i			<= backward_i;
			backward_j			<= backward_j;
			output_c			<= output_c;
			current_wr_addr		<= current_wr_addr;
			current_rd_addr		<= current_rd_addr;
			new_size			<= new_size;
			new_last_size		<= new_last_size;
			last_one_read <= last_one_read;
			min_intv			<= min_intv;
			read_num			<= read_num;
			mem_wr_addr			<= mem_wr_addr;
			forward_size_n		<= forward_size_n;
			
			status				<= status;
		end
		else if(status_q==BCK_INI) begin
			read_num			<= read_num_q;
			current_rd_addr		<= current_rd_addr_q;
			pendingcurr_x_0 <= 0;
			pendingcurr_x_1 <= 0;
			pendingcurr_x_2 <= 0;
			pendingcurr_x_info <= 0;			
			last_one_read <= 0;
			//signals handled to next stage
			primary				<= primary_q;
			forward_size_n		<= forward_size_n_q;
			new_size			<= new_size_q;
			new_last_size		<= new_last_size_q;
			current_wr_addr		<= current_wr_addr_q;
			mem_wr_addr			<= mem_wr_addr_q;
			backward_i			<= backward_i_q; 
			backward_j			<= backward_j_q;
			output_c			<= 0 ;
			min_intv			<= min_intv_q;
			finish_sign			<= 0;
			iteration_boundary  <= iteration_boundary_q;
			reserved_token_x2	<= reserved_token_x2_q;
			reserved_mem_info	<= reserved_mem_info_q;
			
			status				<= BCK_INI;
		end
		else if(status_q==BCK_RUN) begin
			last_one_read <= last_one_read_q;
			pendingcurr_x_0 <= pendingcurr_x_0_q;
			pendingcurr_x_1 <= pendingcurr_x_1_q;
			pendingcurr_x_2 <= pendingcurr_x_2_q;
			pendingcurr_x_info <= pendingcurr_x_info_q;	
			
			primary		<= primary_q;
			reserved_token_x2	<= reserved_token_x2_q;
			reserved_mem_info	<= reserved_mem_info_q;
			finish_sign			<= finish_sign_d;
			iteration_boundary	<= iteration_boundary_d;
			if(iteration_boundary_q)	backward_i <= 0;
			else			backward_i	<= backward_i_d;
			backward_j			<= backward_j_d;
			output_c			<= output_c_q;
			current_wr_addr		<= current_wr_addr_d;
			current_rd_addr		<= current_rd_addr_q;
			new_size			<= new_size_d;
			new_last_size		<= new_last_size_d;
			
			min_intv			<= min_intv_q;
			read_num			<= read_num_q;
			mem_wr_addr			<= mem_wr_addr_q;
			forward_size_n		<= forward_size_n_q;
			
			status				<= status_q;
		end
		else begin
			last_one_read <= 0;
			pendingcurr_x_0 <= 0;
			pendingcurr_x_1 <= 0;
			pendingcurr_x_2 <= 0;
			pendingcurr_x_info <= 0;
			primary				<= 0;
			reserved_token_x2	<= 0;
			reserved_mem_info	<= 0;
			finish_sign			<= 0;
			iteration_boundary	<= 0;
			backward_i			<= 0;
			backward_j			<= 0;
			output_c			<= 0;
			current_wr_addr		<= 0;
			current_rd_addr		<= 0;
			new_size			<= 0;
			new_last_size		<= 0;
			
			min_intv			<= 0;
			read_num			<= 0;
			mem_wr_addr			<= 0;
			forward_size_n		<= 0;
			
			status				<= BUBBLE;
		end
	end
	
	    
endmodule
