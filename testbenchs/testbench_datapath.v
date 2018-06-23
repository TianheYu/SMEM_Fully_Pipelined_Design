`timescale 1ns / 1ps
`define PERIOD 2.5
`define CYCLE 5
module testbench_datapath(


);
	reg clk;
	reg rst;
	reg stall;
	integer i,j;
	integer counter;
reg [63:0] k_in;
	reg [63:0] l_in;
	reg [31:0] cnt_a0_in,cnt_a1_in,cnt_a2_in,cnt_a3_in;
	reg [63:0] cnt_b0_in,cnt_b1_in;
	reg [63:0] cnt_b2_in,cnt_b3_in;
	reg [31:0] cntl_a0_in,cntl_a1_in;
	reg [31:0] cntl_a2_in,cntl_a3_in;
	reg [63:0] cntl_b0_in,cntl_b1_in;
	reg [63:0] cntl_b2_in,cntl_b3_in;
	reg [63:0] ik_x0_new_in,ik_x1_new_in,ik_x2_new_in;
	reg [8:0] read_num_in;
	reg [5:0] status_in;
	reg [6:0] forward_size_n_in;
	reg [6:0] new_size_in;
	reg [6:0] new_last_size_in;
	reg [63:0] primary_in;
	reg [6:0] current_rd_addr_in;
	reg [6:0] current_wr_addr_in;
	reg [6:0] mem_wr_addr_in;
	reg [6:0] backward_i_in; 
	reg [6:0] backward_j_in;
	reg [7:0] backward_c_in;
	reg [6:0] min_intv_in;
	reg iteration_boundary_in;
	reg [63:0] p_x0_in,p_x1_in,p_x2_in,p_info_in;
	reg [63:0] last_token_x2_in;
	reg [31:0] last_mem_info_in;
	reg [6:0] backward_x_in;
	reg [63:0] p_x0_S3_in,p_x1_S3_in,p_x2_S3_in;
	reg [63:0] p_info_S3_in;
	wire [8:0] read_num_store_1;
	wire store_valid_mem;
	wire [63:0] mem_x_0;
	wire [63:0] mem_x_1;
	wire [63:0] mem_x_2;
	wire [63:0] mem_x_info;
	wire [6:0] mem_x_addr;
	wire store_valid_curr;
	wire [63:0] curr_x_0;
	wire [63:0] curr_x_1;
	wire [63:0] curr_x_2;
	wire [63:0] curr_x_info;
	wire [6:0] curr_x_addr;
	wire [8:0] read_num_2;
	wire [6:0] current_rd_addr_2;
	wire [8:0] read_num_out;
	wire [6:0] forward_size_n_out;
	wire [6:0] new_size_out;
	wire [63:0] primary_out;
	wire [6:0] new_last_size_out;
	wire [6:0] current_rd_addr_out;
	wire [6:0] current_wr_addr_out,mem_wr_addr_out;
	wire [6:0] backward_i_out,backward_j_out;
	wire [7:0] output_c_out;
	wire [6:0] min_intv_out;
	wire iteration_boundary_out;
	wire [63:0] backward_k_out,backward_l_out;
	wire request_valid_out;
	wire [41:0] addr_k_out,addr_l_out;
	wire [63:0] p_x0_out,p_x1_out,p_x2_out,p_info_out;
	wire [63:0]	reserved_token_x2_out;
	wire [31:0]	reserved_mem_info_out;
	wire finish_sign_out;
	wire [6:0] mem_size_out;
	wire [5:0] status_out;
	reg forward_all_done;
	reg [280:0] store_temp_mem[100:0];
	reg [280:0] store_temp_curr[100:0];
	initial forever #`PERIOD clk=!clk; 
	localparam [5:0]
	F_init	= 6'h0,	//000
	F_run	= 6'h1,	//001
	F_break = 6'h2,	//010
	BCK_INI = 6'h4,	//100
	BCK_RUN = 6'h5,	//101
	BCK_END = 6'h6,	//110
	BUBBLE  = 6'h30,
	DONE	= 6'b100000;
initial begin
counter = 0;
clk=1;
rst = 0;
stall = 0;
#`CYCLE
i = 0;
j = 0;
rst = 1;
forward_all_done = 1;

primary_in  = 64'h0000_0000_9d38_3ea0;
ik_x0_new_in=0;ik_x1_new_in=0;ik_x2_new_in=0;
//read num 0
#`CYCLE
read_num_in = 0;
forward_size_n_in = 15;
backward_x_in = 0;
min_intv_in = 1;
status_in = BCK_INI;

k_in=0;
l_in=0;
cnt_a0_in=0;cnt_a1_in=0;cnt_a2_in=0;cnt_a3_in=0;
cnt_b0_in=0;cnt_b1_in=0;
cnt_b2_in=0;cnt_b3_in=0;
cntl_a0_in=0;cntl_a1_in=0;
cntl_a2_in=0;cntl_a3_in=0;
cntl_b0_in=0;cntl_b1_in=0;
cntl_b2_in=0;cntl_b3_in=0;

new_size_in=0;
new_last_size_in=0;
current_rd_addr_in=0;
current_wr_addr_in=0;
mem_wr_addr_in=0;
backward_i_in=0; 
backward_j_in=0;
backward_c_in=0;
iteration_boundary_in=0;
p_x0_in=0;p_x1_in=0;p_x2_in=0;p_info_in=0;
last_token_x2_in=0;
last_mem_info_in=0;



//read_num1
#`CYCLE
read_num_in = 1;
forward_size_n_in = 16;
backward_x_in = 15;
min_intv_in = 1;
status_in = BCK_INI;

k_in=0;
l_in=0;
cnt_a0_in=0;cnt_a1_in=0;cnt_a2_in=0;cnt_a3_in=0;
cnt_b0_in=0;cnt_b1_in=0;
cnt_b2_in=0;cnt_b3_in=0;
cntl_a0_in=0;cntl_a1_in=0;
cntl_a2_in=0;cntl_a3_in=0;
cntl_b0_in=0;cntl_b1_in=0;
cntl_b2_in=0;cntl_b3_in=0;
ik_x0_new_in=0;ik_x1_new_in=0;ik_x2_new_in=0;
new_size_in=0;
new_last_size_in=0;
current_rd_addr_in=0;
current_wr_addr_in=0;
mem_wr_addr_in=0;
backward_i_in=0; 
backward_j_in=0;
backward_c_in=0;
iteration_boundary_in=0;
p_x0_in=0;p_x1_in=0;p_x2_in=0;p_info_in=0;
last_token_x2_in=0;
last_mem_info_in=0;

#`CYCLE
read_num_in = 0;
forward_size_n_in = 0;
backward_x_in = 0;
min_intv_in = 0;
status_in = BUBBLE;

k_in=0;
l_in=0;
cnt_a0_in=0;cnt_a1_in=0;cnt_a2_in=0;cnt_a3_in=0;
cnt_b0_in=0;cnt_b1_in=0;
cnt_b2_in=0;cnt_b3_in=0;
cntl_a0_in=0;cntl_a1_in=0;
cntl_a2_in=0;cntl_a3_in=0;
cntl_b0_in=0;cntl_b1_in=0;
cntl_b2_in=0;cntl_b3_in=0;

new_size_in=0;
new_last_size_in=0;
current_rd_addr_in=0;
current_wr_addr_in=0;
mem_wr_addr_in=0;
backward_i_in=0; 
backward_j_in=0;
backward_c_in=0;
iteration_boundary_in=0;
p_x0_in=0;p_x1_in=0;p_x2_in=0;p_info_in=0;
last_token_x2_in=0;
last_mem_info_in=0;

#(`CYCLE*13)
read_num_in = 0;
forward_size_n_in = forward_size_n_out;
backward_x_in = 0;
min_intv_in = 1;
status_in = status_out;

k_in=backward_k_out;
l_in=backward_l_out;
//addr_k= 2a3f75e0; addr_l= 2a3f75f0;
cnt_a0_in=32'h63fed5af;
cnt_a1_in=0;
cnt_a2_in=32'h4648c205;
cnt_a3_in=0;
cnt_b0_in=64'h4acfed0c7973933b;
cnt_b1_in=64'h099fd1fbff1f0cbf;
cnt_b2_in=64'h5f00594155df3c48;
cnt_b3_in=0;
cntl_a0_in=32'h63fed5d7;cntl_a1_in=0;
cntl_a2_in=32'h4648c223;cntl_a3_in=0;
cntl_b0_in=0;cntl_b1_in=0;
cntl_b2_in=0;cntl_b3_in=0;

new_size_in=new_size_out;
new_last_size_in=new_last_size_out;
current_rd_addr_in=current_rd_addr_out;
current_wr_addr_in=current_wr_addr_out;
mem_wr_addr_in=mem_wr_addr_out;
backward_i_in=backward_i_out; 
backward_j_in=backward_j_out;
backward_c_in=0;
iteration_boundary_in=iteration_boundary_out;
p_x0_in=p_x0_out;
p_x1_in=p_x1_out;p_x2_in=p_x2_out;p_info_in=p_info_out;
last_token_x2_in=reserved_token_x2_out;
last_mem_info_in=reserved_mem_info_out;
stall = 1;
#`CYCLE
stall = 0;
#`CYCLE
read_num_in = 1;
forward_size_n_in = forward_size_n_out;
backward_x_in = 0;
min_intv_in = 1;
status_in = status_out;

k_in=backward_k_out;
l_in=backward_l_out;
//addr_k= 1f1ddc80;addr_l= 1f1ddc80;
cnt_a0_in=32'h4be1fbd4;
cnt_a1_in=0;
cnt_a2_in=32'h3256f525;
cnt_a3_in=0;
cnt_b0_in=64'h9b0f023f8cef2f0b;
cnt_b1_in=64'h111111;
cnt_b2_in=64'h111111;
cnt_b3_in=0;
cntl_a0_in=32'h4be1fbd4;cntl_a1_in=0;
cntl_a2_in=32'h3256f525;cntl_a3_in=0;
cntl_b0_in=64'h9b0f023f8cef2f0b;cntl_b1_in=64'h111111;
cntl_b2_in=64'h111111;cntl_b3_in=64'h111111;

new_size_in=new_size_out;
new_last_size_in=new_last_size_out;
current_rd_addr_in=current_rd_addr_out;
current_wr_addr_in=current_wr_addr_out;
mem_wr_addr_in=mem_wr_addr_out;
backward_i_in=backward_i_out; 
backward_j_in=backward_j_out;
backward_c_in=3;
iteration_boundary_in=iteration_boundary_out;
p_x0_in=p_x0_out;
p_x1_in=p_x1_out;p_x2_in=p_x2_out;p_info_in=p_info_out;
last_token_x2_in=reserved_token_x2_out;
last_mem_info_in=reserved_mem_info_out;

#`CYCLE
read_num_in = 0;
forward_size_n_in = 0;
backward_x_in = 0;
min_intv_in = 0;
status_in = BUBBLE;

k_in=0;
l_in=0;
cnt_a0_in=0;cnt_a1_in=0;cnt_a2_in=0;cnt_a3_in=0;
cnt_b0_in=0;cnt_b1_in=0;
cnt_b2_in=0;cnt_b3_in=0;
cntl_a0_in=0;cntl_a1_in=0;
cntl_a2_in=0;cntl_a3_in=0;
cntl_b0_in=0;cntl_b1_in=0;
cntl_b2_in=0;cntl_b3_in=0;

new_size_in=0;
new_last_size_in=0;
current_rd_addr_in=0;
current_wr_addr_in=0;
mem_wr_addr_in=0;
backward_i_in=0; 
backward_j_in=0;
backward_c_in=0;
iteration_boundary_in=0;
p_x0_in=0;p_x1_in=0;p_x2_in=0;p_info_in=0;
last_token_x2_in=0;
last_mem_info_in=0;

#(`CYCLE*12)
read_num_in = 0;
forward_size_n_in = forward_size_n_out;
backward_x_in = 0;
min_intv_in = 1;
status_in = status_out;

k_in=backward_k_out;
l_in=backward_l_out;
//addr_k= 2a3f75e0; addr_l= 2a3f75f0;
cnt_a0_in=32'h63fed5af;
cnt_a1_in=0;
cnt_a2_in=32'h4648c205;
cnt_a3_in=0;
cnt_b0_in=64'h4acfed0c7973933b;
cnt_b1_in=64'h099fd1fbff1f0cbf;
cnt_b2_in=64'h5f00594155df3c48;
cnt_b3_in=0;
cntl_a0_in=32'h63fed5af;cntl_a1_in=0;
cntl_a2_in=32'h4648c205;cntl_a3_in=0;
cntl_b0_in=64'h4acfed0c7973933b;cntl_b1_in=64'h099fd1fbff1f0cbf;
cntl_b2_in=64'h5f00594155df3c48;cntl_b3_in=0;

new_size_in=new_size_out;
new_last_size_in=new_last_size_out;
current_rd_addr_in=current_rd_addr_out;
current_wr_addr_in=current_wr_addr_out;
mem_wr_addr_in=mem_wr_addr_out;
backward_i_in=backward_i_out; 
backward_j_in=backward_j_out;
backward_c_in=0;
iteration_boundary_in=iteration_boundary_out;
p_x0_in=p_x0_out;
p_x1_in=p_x1_out;p_x2_in=p_x2_out;p_info_in=p_info_out;
last_token_x2_in=reserved_token_x2_out;
last_mem_info_in=reserved_mem_info_out;

#(`CYCLE*15)
read_num_in = 0;
forward_size_n_in = forward_size_n_out;
backward_x_in = 0;
min_intv_in = 1;
status_in = status_out;

k_in=backward_k_out;
l_in=backward_l_out;
//addr_k= 2a3f75e0; addr_l= 2a3f75f0;
cnt_a0_in=32'h63fed5af;
cnt_a1_in=0;
cnt_a2_in=32'h4648c205;
cnt_a3_in=0;
cnt_b0_in=64'h4acfed0c7973933b;
cnt_b1_in=64'h099fd1fbff1f0cbf;
cnt_b2_in=64'h5f00594155df3c48;
cnt_b3_in=0;
cntl_a0_in=32'h63fed5d7;cntl_a1_in=0;
cntl_a2_in=32'h4648c223;cntl_a3_in=0;
cntl_b0_in=0;cntl_b1_in=0;
cntl_b2_in=0;cntl_b3_in=0;

new_size_in=new_size_out;
new_last_size_in=new_last_size_out;
current_rd_addr_in=current_rd_addr_out;
current_wr_addr_in=current_wr_addr_out;
mem_wr_addr_in=mem_wr_addr_out;
backward_i_in=backward_i_out; 
backward_j_in=backward_j_out;
backward_c_in=0;
iteration_boundary_in=iteration_boundary_out;
p_x0_in=p_x0_out;
p_x1_in=p_x1_out;p_x2_in=p_x2_out;p_info_in=p_info_out;
last_token_x2_in=reserved_token_x2_out;
last_mem_info_in=reserved_mem_info_out;
#`CYCLE
status_in = BUBBLE;

end
///////////////////////////////////////////////

always @(posedge clk)begin
counter = counter + 1;
p_x0_S3_in=0;p_x1_S3_in=0;p_x2_S3_in=0;p_info_S3_in=0;
if(current_rd_addr_2 == 14 &&  read_num_2==0) begin
	p_x0_S3_in <= 64'd5670416243;
	p_x1_S3_in <= 64'd633867291;
	p_x2_S3_in <= 64'd1;
	p_info_S3_in <= 64'd15;
end
else if(current_rd_addr_2 == 13 &&  read_num_2==0) begin
	p_x0_S3_in <= 64'd5670416242;
	p_x1_S3_in <= 64'd1955378465;
	p_x2_S3_in <= 64'd2;
	p_info_S3_in <= 64'd14;
end
else if(current_rd_addr_2 == 12 &&  read_num_2==0) begin
	p_x0_S3_in <= 64'd5670416237;
	p_x1_S3_in <= 64'd690477599;
	p_x2_S3_in <= 64'd22;
	p_info_S3_in <= 64'd13;
end
else if(current_rd_addr_2 == 11 &&  read_num_2==0) begin
	p_x0_S3_in <= 64'd5670416205;
	p_x1_S3_in <= 64'd2172577543;
	p_x2_S3_in <= 64'd54;
	p_info_S3_in <= 64'd12;
end
else if(current_rd_addr_2 == 10 &&  read_num_2==0) begin
	p_x0_S3_in <= 64'd5670416128;
	p_x1_S3_in <= 64'd1476325292;
	p_x2_S3_in <= 64'd188;
	p_info_S3_in <= 64'd11;
end
else if(current_rd_addr_2 == 9 &&  read_num_2==0) begin
	p_x0_S3_in <= 64'd5670415655;
	p_x1_S3_in <= 64'd4844371900;
	p_x2_S3_in <= 64'd661;
	p_info_S3_in <= 64'd10;
end
else if(current_rd_addr_2 == 8 &&  read_num_2==0) begin
	p_x0_S3_in <= 64'd5670415655;
	p_x1_S3_in <= 64'd1986321214;
	p_x2_S3_in <= 64'd5464;
	p_info_S3_in <= 64'd9;
end
else if(current_rd_addr_2 == 7 &&  read_num_2==0) begin
	p_x0_S3_in <= 64'd5670408300;
	p_x1_S3_in <= 64'd790963567;
	p_x2_S3_in <= 64'd17312;
	p_info_S3_in <= 64'd8;
end
else if(current_rd_addr_2 == 6 &&  read_num_2==0) begin
	p_x0_S3_in <= 64'd5670362957;
	p_x1_S3_in <= 64'd2599266954;
	p_x2_S3_in <= 64'd62655;
	p_info_S3_in <= 64'd7;
end
else if(current_rd_addr_2 == 5 &&  read_num_2==0) begin
	p_x0_S3_in <= 64'd5669615812;
	p_x1_S3_in <= 64'd3365854682;
	p_x2_S3_in <= 64'd1317418;
	p_info_S3_in <= 64'd6;
end
else if(current_rd_addr_2 == 4 &&  read_num_2==0) begin
	p_x0_S3_in <= 64'd5668014094;
	p_x1_S3_in <= 64'd1239655253;
	p_x2_S3_in <= 64'd7254384;
	p_info_S3_in <= 64'd5;
end
else if(current_rd_addr_2 == 3 &&  read_num_2==0) begin
	p_x0_S3_in <= 64'd5653090440;
	p_x1_S3_in <= 64'd4073662037;
	p_x2_S3_in <= 64'd22178038;
	p_info_S3_in <= 64'd4;
end
else if(current_rd_addr_2 == 2 &&  read_num_2==0) begin
	p_x0_S3_in <= 64'd5613103804;
	p_x1_S3_in <= 64'd4392051081;
	p_x2_S3_in <= 64'd126564395;
	p_info_S3_in <= 64'd3;
end
else if(current_rd_addr_2 == 1 &&  read_num_2==0) begin
	p_x0_S3_in <= 64'd5613103804;
	p_x1_S3_in <= 64'd1;
	p_x2_S3_in <= 64'd590505675;
	p_info_S3_in <= 64'd2;
end
else if(current_rd_addr_2 == 0 &&  read_num_2==0) begin
	p_x0_S3_in <= 64'd4392051081;
	p_x1_S3_in <= 64'd1;
	p_x2_S3_in <= 64'd1811558398;
	p_info_S3_in <= 64'd1;
end
else if(current_rd_addr_2 == 15 &&  read_num_2==1) begin
	p_x0_S3_in <= 64'd4176405548;
	p_x1_S3_in <= 64'd5010236986;
	p_x2_S3_in <= 64'd2;
	p_info_S3_in <= 64'd31;
end
else if(current_rd_addr_2 == 14 &&  read_num_2==1) begin
	p_x0_S3_in <= 64'd4176405548;
	p_x1_S3_in <= 64'd2577212744;
	p_x2_S3_in <= 64'd5;
	p_info_S3_in <= 64'd30;
end
else if(current_rd_addr_2 == 13 &&  read_num_2==1) begin
	p_x0_S3_in <= 64'd4176405540;
	p_x1_S3_in <= 64'd3064168724;
	p_x2_S3_in <= 64'd14;
	p_info_S3_in <= 64'd29;
end

end

     
	
	
always @(posedge clk)begin
if (store_valid_mem) begin
store_temp_mem[i] <= {read_num_store_1,mem_x_0,mem_x_1,mem_x_2,mem_x_info,1'b0,mem_x_addr};
i = i+1;
end
if(store_valid_curr)begin
store_temp_curr[j] <= {read_num_store_1,curr_x_0,curr_x_1,curr_x_2,curr_x_info,1'b0,curr_x_addr}; //9+256+7=272
j = j+1;
end
end
Backward_data_path Instant(
	.clk(clk),
	.rst(rst),
	.stall(stall),
	.forward_all_done (forward_all_done),  
	.k_q      (k_in),
	.l_q      (l_in),
	.cnt_a0_q (cnt_a0_in),
	.cnt_a1_q (cnt_a1_in),
	.cnt_a2_q (cnt_a2_in),
	.cnt_a3_q (cnt_a3_in),
	.cnt_b0_q (cnt_b0_in),
	.cnt_b1_q (cnt_b1_in),
	.cnt_b2_q (cnt_b2_in),
	.cnt_b3_q (cnt_b3_in),
	.cntl_a0_q(cntl_a0_in),         
	.cntl_a1_q(cntl_a1_in),
	.cntl_a2_q(cntl_a2_in),
	.cntl_a3_q(cntl_a3_in),
	.cntl_b0_q(cntl_b0_in),
	.cntl_b1_q(cntl_b1_in),
	.cntl_b2_q(cntl_b2_in),
	.cntl_b3_q(cntl_b3_in),
	.ik_x0_new_q  (ik_x0_new_in),
	.ik_x1_new_q  (ik_x1_new_in),
	.ik_x2_new_q  (ik_x2_new_in),
	///////////////////////signals needs to be registered//////start////////
	.read_num_q(read_num_in),
	.status_q(status_in),
	.forward_size_n_q(forward_size_n_in),
	.new_size_q(new_size_in),
	.new_last_size_q(new_last_size_in),
	.primary_q(primary_in),
	.current_rd_addr_q(current_rd_addr_in),
	.current_wr_addr_q(current_wr_addr_in),.mem_wr_addr_q(mem_wr_addr_in),
	.backward_i_q(backward_i_in), .backward_j_q(backward_j_in),
	.backward_c_q(backward_c_in),
	.min_intv_q(min_intv_in),
	.iteration_boundary_q(iteration_boundary_in),
	.p_x0_q(p_x0_in),.p_x1_q(p_x1_in),
	.p_x2_q(p_x2_in),.p_info_q(p_info_in),
	.last_token_x2_q(last_token_x2_in),
	.last_mem_info_q(last_mem_info_in),
	.backward_x_q(backward_x_in),

	/////////////////////////////stage3 input///////////////////////////
	.p_x0_q_S3_q(p_x0_S3_in),
	.p_x1_q_S3_q(p_x1_S3_in),
	.p_x2_q_S3_q(p_x2_S3_in),
	.p_info_q_S3_q(p_info_S3_in),

	//output to curr/mem array
	.read_num_store_1(read_num_store_1),
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
	
	.read_num_2(read_num_2),
	.current_rd_addr_2(current_rd_addr_2),

	//output
	.read_num(read_num_out),
	.forward_size_n(forward_size_n_out),
	.new_size(new_size_out),
	.primary(primary_out),
	.new_last_size(new_last_size_out),
	.current_rd_addr(current_rd_addr_out),
	.current_wr_addr(current_wr_addr_out),
	.mem_wr_addr(mem_wr_addr_out),
	.backward_i(backward_i_out), 
	.backward_j(backward_j_out),
	.output_c(output_c_out),
	.min_intv(min_intv_out),
	.iteration_boundary(iteration_boundary_out),

	//output to bwt_extend but not used in control logic
	.backward_k(backward_k_out),
	.backward_l(backward_l_out),

	.p_x0(p_x0_out),.p_x1(p_x1_out),
	.p_x2(p_x2_out),.p_info(p_info_out),
	.reserved_token_x2(reserved_token_x2_out),
	.reserved_mem_info(reserved_mem_info_out),
	
	//memory request
	.request_valid(request_valid_out),
	.addr_k(addr_k_out),.addr_l(addr_l_out),
	
	//outputing finish_sign+read_num+mem_size to another module
	.finish_sign(finish_sign_out),
	.mem_size(mem_size_out),
	.status(status_out)
);






endmodule
//3 3 0 1 3 1 2 3 2 0 
//3 2 3 2 3 2 3 1 1 3 
//1 0 0 1 3 0 0 0 2 2 
//0 2 3 0 2 0 0 1 3 3 
//3 3 1 3 3 3 3 1 0 3 
//0 2 0 2 0 0 2 3 3 3 
//3 2 0 0 0 1 2 1 3 1 
//3 3 3 3 3 2 3 2 2 0  
//0 3 1 3 2 1 0 0 2 3 
//2 2 0 3 0 3 3 3 2 2 1
//len = 101, x = 0, min_intv = 1, mem_n = 0
// curr[0].x0,1,2,info = 5670416243,633867291,1,15
// curr[1].x0,1,2,info = 5670416242,1955378465,2,14
// curr[2].x0,1,2,info = 5670416237,690477599,22,13
// curr[3].x0,1,2,info = 5670416205,2172577543,54,12
// curr[4].x0,1,2,info = 5670416128,1476325292,188,11
// curr[5].x0,1,2,info = 5670415655,4844371900,661,10
// curr[6].x0,1,2,info = 5670415655,1986321214,5464,9
// curr[7].x0,1,2,info = 5670408300,790963567,17312,8
// curr[8].x0,1,2,info = 5670362957,2599266954,62655,7
// curr[9].x0,1,2,info = 5669615812,3365854682,1317418,6
// curr[10].x0,1,2,info = 5668014094,1239655253,7254384,5
// curr[11].x0,1,2,info = 5653090440,4073662037,22178038,4
// curr[12].x0,1,2,info = 5613103804,4392051081,126564395,3
// curr[13].x0,1,2,info = 5613103804,1,590505675,2
// curr[14].x0,1,2,info = 4392051081,1,1811558398,1
//curr->n = 15
//mem_out[0].x0,1,2,info = 5670416243,633867291,1,15