`define CL 512
`define MAX_READ 1024
`define READ_NUM_WIDTH 10

module CONTROL_STAGE1(
input wire clk,
input wire rst,
input wire stall,

input wire [`READ_NUM_WIDTH - 1:0] read_num_q,
input wire [5:0] status_q,
//data portion
input wire [6:0] backward_x,
input wire [63:0] primary_q,
input wire [63:0] ok0_x0, ok0_x1, ok0_x2,
input wire [63:0] ok1_x0, ok1_x1, ok1_x2,
input wire [63:0] ok2_x0, ok2_x1, ok2_x2,
input wire [63:0] ok3_x0, ok3_x1, ok3_x2,
input wire [63:0] p_x0,p_x1,p_x2,p_info,

input wire [6:0] min_intv_q,
input wire iteration_boundary_q,
input wire [6:0] backward_i_q,backward_j_q,
input wire [6:0] current_wr_addr_q,current_rd_addr_q,mem_wr_addr_q,
input wire [6:0] new_size_q,
input wire [6:0] new_last_size_q,
input wire [6:0] forward_size_n_q,

input wire [31:0] last_mem_info,
input wire [63:0] last_token_x2,
input wire [7:0] output_c_q,


//signals handled to READ parse unit
output reg [`READ_NUM_WIDTH - 1:0] read_num,
output reg [6:0] current_rd_addr,
//signals handled to next stage
output reg [6:0]	new_size,
output reg [63:0]	primary,
output reg [6:0]	current_wr_addr,mem_wr_addr,
output reg [63:0]	reserved_token_x2,
output reg [31:0]	reserved_mem_info,
output reg [6:0]	min_intv,
output reg [6:0]	backward_i,backward_j,
output reg [6:0]	new_last_size,forward_size_n,
output reg [7:0]	output_c,


//signals handled to storage unit
output reg			store_valid_mem,			
output reg [63:0]	mem_x_0,
output reg [63:0]	mem_x_1,
output reg [63:0]	mem_x_2,
output reg [63:0]	mem_x_info,
output reg [6:0]    mem_x_addr,

output reg			store_valid_curr,			
output reg [63:0]	curr_x_0,
output reg [63:0]	curr_x_1,
output reg [63:0]	curr_x_2,
output reg [63:0]	curr_x_info,
output reg [6:0]    curr_x_addr,

output reg last_one_read,
output reg iteration_boundary,
output reg [5:0] status,
input [63:0] ok_b_temp_x0,ok_b_temp_x1,ok_b_temp_x2
);
	parameter Len = 101;
	
	parameter F_init = 	6'b00_0001; // F_init will disable the forward pipeline
	parameter F_run =  	6'b00_0010;
	parameter F_break = 6'b00_0100;
	parameter BCK_INI = 6'b00_1000;	//100
	parameter BCK_RUN = 6'b01_0000;	//101
	parameter BCK_END = 6'b10_0000;	//110
	parameter BUBBLE = 	6'b00_0000;

wire [6:0] new_i;
wire ambiguous;
wire [6:0] new_size_d;
wire [6:0]  mem_wr_addr_d;
wire [6:0]  current_wr_addr_d;
wire [63:0] reserved_token_x2_d;
wire [31:0] reserved_mem_info_d;
wire store_valid_curr_d,store_valid_mem_d;
wire cond_1,cond_2;
wire if_cond;
wire [6:0] ini_pos;
//read_num is provided outside this.
assign if_cond = (ambiguous==1) || (iteration_boundary_q==1) || (ok_b_temp_x2 < min_intv_q);
assign cond_1 = (if_cond) && (new_size_q==0) && ((mem_wr_addr_q == 0) || (new_i < last_mem_info));

assign cond_2 = (!if_cond) && ((new_size_q==0) || (ok_b_temp_x2 != last_token_x2));

assign mem_wr_addr_d			= cond_1 ? (mem_wr_addr_q + 1) : mem_wr_addr_q;
assign reserved_mem_info_d		= cond_1 ? new_i : last_mem_info;

assign current_wr_addr_d		= cond_2 ? (current_wr_addr_q - 1) : current_wr_addr_q;
assign reserved_token_x2_d		= cond_2 ? ok_b_temp_x2 : last_token_x2;
assign new_size_d				= cond_2 ? (new_size_q + 1) : new_size_q;
assign store_valid_mem_d		= cond_1 ; 
assign store_valid_curr_d		= cond_2 ; 
assign new_i				= iteration_boundary_q ? 0 : backward_i_q + 1;
assign ambiguous			= output_c_q < 4 ? 0 : 1;//decide whether the current c is ambiguous
assign ini_pos = forward_size_n_q - 1;
wire j_bound;
wire [6:0] current_rd_addr_d;
assign j_bound			= (backward_j_q == (new_last_size_q - 1));
assign current_rd_addr_d	= j_bound ? ini_pos : current_rd_addr_q - 1; //request for new read data

reg stall_pulse;
reg stall_sig,stall_sig_q;

wire lastone;
assign lastone = (new_size_q == 0) && cond_2 && j_bound;

always@(posedge clk) begin
	if(!rst)begin
		stall_sig_q <= 0;
	end
	else
	stall_sig_q <= stall_sig;
end
always@(posedge clk) begin
	if(!rst)begin
		stall_pulse <= 0;
	end
	else if (stall_sig == 1 && stall_sig_q==0 && stall == 1)
		stall_pulse <= 1;
	else
		stall_pulse <= 0;
end
always@(posedge clk) begin
	//handled to the next stage
	if(!rst)begin
		last_one_read <= 0;
		read_num			<= 0;
		current_rd_addr		<= 0;
		min_intv		<= 0;
		backward_i		<= 0;
		backward_j		<= 0;
		new_last_size	<= 0;
		forward_size_n	<= 0;
		output_c		<= 0;
		//generated signals

		new_size	<= 0;
		mem_wr_addr <= 0;
		current_wr_addr		<= 0;
		reserved_token_x2	<= 0;
		reserved_mem_info	<= 0;
		iteration_boundary	<= 0;
		primary				<= 0;
		store_valid_mem		<= 0;
		store_valid_curr	<= 0;
		stall_sig <= 0;
		status <= BUBBLE;
	end
	else if (stall == 1) begin
		last_one_read	<= last_one_read;
		primary			<= primary;
		read_num		<= read_num;
		current_rd_addr	<= current_rd_addr;
		min_intv		<= min_intv;
		backward_i		<= backward_i;
		backward_j		<= backward_j;
		new_last_size	<= new_last_size;
		forward_size_n	<= forward_size_n;
		output_c		<= output_c;
		//generated signals

		new_size			<= new_size;
		mem_wr_addr			<= mem_wr_addr;
		current_wr_addr		<= current_wr_addr;
		reserved_token_x2	<= reserved_token_x2;
		reserved_mem_info	<= reserved_mem_info;
		iteration_boundary	<= iteration_boundary;
		store_valid_mem		<= store_valid_mem;
		store_valid_curr	<= store_valid_curr;
		stall_sig <= 1;
		status	<= status;	
	end
	else if(status_q==BCK_INI) begin
		last_one_read	<= 0;
		primary			<= primary_q;
		read_num		<= read_num_q;
		current_rd_addr	<= ini_pos;
		current_wr_addr	<= ini_pos;
		min_intv		<= min_intv_q;
		if(backward_x == 0)begin
			backward_i		<= 0;
			iteration_boundary <= 1;
			
			//[licheng]
			output_c <= 8'bxxxx_xxxx;
		end
		else begin
			backward_i		<= backward_x - 1;
			iteration_boundary <= 0;
			//[licheng]
			output_c <= backward_x - 1;
		end
		backward_j		<= 0;
		new_last_size	<= forward_size_n_q;
		forward_size_n	<= forward_size_n_q;
		//output_c		<= 0;
		//generated signals
		new_size		<= 0;
		mem_wr_addr		<= 7'b0;
		reserved_token_x2	<= 0;
		reserved_mem_info	<= 0;
		
		store_valid_mem		<= 0;
		store_valid_curr	<= 0;
		status <= status_q;
	end
	
	else if(status_q==BCK_RUN) begin
		last_one_read	<= lastone;
		primary			<= primary_q;
		read_num		<= read_num_q;
		current_rd_addr	<= current_rd_addr_d;
		min_intv		<= min_intv_q;
		backward_i		<= backward_i_q;
		backward_j		<= backward_j_q;
		new_last_size	<= new_last_size_q;
		forward_size_n	<= forward_size_n_q;
		//output_c		<= output_c_q;
		//[licheng]
		output_c <= backward_i_q;
		
		//generated signals

		new_size			<= new_size_d;
		mem_wr_addr			<= mem_wr_addr_d;
		current_wr_addr		<= current_wr_addr_d;
		reserved_token_x2	<= reserved_token_x2_d;
		reserved_mem_info	<= reserved_mem_info_d;
		iteration_boundary	<= iteration_boundary_q;
		store_valid_mem		<= store_valid_mem_d;
		store_valid_curr	<= store_valid_curr_d;
		status <= BCK_RUN;
	end
	else begin
		last_one_read	<= 0;
		primary			<= 0;
		read_num		<= 0;
		current_rd_addr	<= 0;
		min_intv		<= 0;
		backward_i		<= 0;
		backward_j		<= 0;
		new_last_size	<= 0;
		forward_size_n	<= 0;
		output_c		<= 0;
		//generated signals

		new_size			<= 0;
		mem_wr_addr			<= 0;
		current_wr_addr		<= 0;
		reserved_token_x2	<= 0;
		reserved_mem_info	<= 0;
		iteration_boundary	<= 0;
		store_valid_mem		<= 0;
		store_valid_curr	<= 0;
		status	<= BUBBLE;		
	end
end

always @(posedge clk) begin
	if(!stall) begin
   	if((ambiguous==1) || (iteration_boundary_q==1) || (ok_b_temp_x2 < min_intv_q)) begin
   		if(new_size_q==0) begin
   	 		if((mem_wr_addr_q == 0) || (new_i < last_mem_info)) begin
				mem_x_0 <= p_x0;
				mem_x_1 <= p_x1;
				mem_x_2 <= p_x2;
				mem_x_info <= {new_i,p_info[31:0]};
				mem_x_addr <= mem_wr_addr_q;
   	 		end
   		end
   	end
   	else if((new_size_q==0) || (ok_b_temp_x2 != last_token_x2)) begin
		curr_x_0			<= ok_b_temp_x0;
		curr_x_1			<= ok_b_temp_x1;
		curr_x_2			<= ok_b_temp_x2;
		curr_x_info			<= p_info;
		curr_x_addr			<= current_wr_addr_q;
	end
	end
end


endmodule