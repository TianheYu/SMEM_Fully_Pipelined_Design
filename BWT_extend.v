// 10.31 aims to decrease BWT_extend cycles

////////////////////////////////////////////////////
// BWT_extend                                     //
////////////////////////////////////////////////////

// input cnt+cntl(cntk & cntl), cntk is the 4 consecutive value from p : p = bwt_occ_intv(bwt, k);

// cntb0,1,2,3 are 4 consecutive p value request from bwt. calculating b from bwt
// for (x = 0; p < end; ++p) x += __occ_aux4(bwt, *p)

// ik the values and boundarys: ik_x0/ik_x1(start), + ik_x2 (end). also used when calculting ok
//k and l are boundary, should just be ik_x0 & ik_x0+ik_x2

//the request should just be the position of p = bwt_occ_intv(bwt, k);
// each calculation calculates the position of bwt's k and bwt's l, 
//and request the value following 4*64(4*cnt_a0)  +  use another 8 consecutive 32 BITS value. so in total 1CLs for 1 request.
//memcpy(cnt, p, 4 * sizeof(bwtint_t)); 
//	p +=  8
//	end = p + 4;
//L2:cumulative count
//request k and l ????????/

//output: ok

`define CL 512
`define MAX_READ 1024
`define READ_NUM_WIDTH 10

module BWT_extend(
	input stall,
	
	input [5:0] status,
	
	input Clk_32UI,
	input reset_BWT_extend, //初始时reset一次
	input forward_all_done, 
	input CNT_flag,
	input [63:0] CNT_data,
	input [7:0]  CNT_addr,
	input trigger,
	input [63:0] primary, // fix value
	input [63:0] k,l,
	input [31:0] cnt_a0,cnt_a1,cnt_a2,cnt_a3,
	input [63:0] cnt_b0,cnt_b1,cnt_b2,cnt_b3,
	input [31:0] cntl_a0,cntl_a1,cntl_a2,cntl_a3,
	input [63:0] cntl_b0,cntl_b1,cntl_b2,cntl_b3,
	input [63:0] L2_0, L2_1, L2_2, L2_3, //fix value
	input [63:0] ik_x0, ik_x1, ik_x2,

	output reg BWT_extend_done,
	output reg [63:0] ok0_x0, ok0_x1, ok0_x2,
	output reg [63:0] ok1_x0, ok1_x1, ok1_x2,
	output reg [63:0] ok2_x0, ok2_x1, ok2_x2,
	output reg [63:0] ok3_x0, ok3_x1, ok3_x2,
	
	output reg [5:0] status_L00,
	
	input [7:0] query_L00_one_cycle_ahead,
	output reg [63:0] ok_target_x0, ok_target_x1, ok_target_x2
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

   
	BWT_OCC4 BWT_OCC4_k(
		.stall(stall),
		.reset_BWT_extend(reset_BWT_extend),
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

	BWT_OCC4 BWT_OCC4_l(
		.stall(stall),
		.reset_BWT_extend(reset_BWT_extend),
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
	
	//=================================================
	wire [63:0] ik_x0_L0, ik_x1_L0, ik_x2_L0;
	wire [63:0] ik_x0_L0_ik_x2_L0_A;
	wire [63:0] ik_x1_L0_ik_x2_L0_B;
	reg  [63:0] ik_x0_L1, ik_x1_L1, ik_x2_L1;
	
	wire forward_all_done_L0;
	reg forward_all_done_L1;
	reg forward_all_done_L2;
	reg forward_all_done_L3;
	reg forward_all_done_L4;
	
	wire [5:0] status_L0;
	reg  [5:0] status_L1, status_L2, status_L3, status_L4;
	
	Pipe pipe(
		.stall(stall),
		.Clk_32UI(Clk_32UI),
		
		.ik_x0(ik_x0),
		.ik_x1(ik_x1),
		.ik_x2(ik_x2),
		.forward_all_done(forward_all_done),
		.status(status),
		
		.ik_x0_pipe(ik_x0_L0),
		.ik_x1_pipe(ik_x1_L0),
		.ik_x2_pipe(ik_x2_L0),
		.ik_x0_L0_ik_x2_L0_A(ik_x0_L0_ik_x2_L0_A),
		.ik_x1_L0_ik_x2_L0_B(ik_x1_L0_ik_x2_L0_B),
		.forward_all_done_pipe(forward_all_done_L0),		
		.status_pipe(status_L0)
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
	
	wire [63:0] primary_add_1 = primary + 1;
	reg is_x1_add_A, is_x1_add_B, is_x0_add_C, is_x0_add_D;
	
	// L1
	always@(posedge Clk_32UI) begin
	if(!stall) begin
		ok0_x2_L1 <= cnt_tl_out0 - cnt_tk_out0;
		ok1_x2_L1 <= cnt_tl_out1 - cnt_tk_out1;
		ok2_x2_L1 <= cnt_tl_out2 - cnt_tk_out2;
		ok3_x2_L1 <= cnt_tl_out3 - cnt_tk_out3;   
		

			ok0_x1_L1 <= L2_0 + cnt_tk_out0 + 1;
			ok1_x1_L1 <= L2_1 + cnt_tk_out1 + 1;
			ok2_x1_L1 <= L2_2 + cnt_tk_out2 + 1;
			ok3_x1_L1 <= L2_3 + cnt_tk_out3 + 1;
			
			is_x0_add_C <= (ik_x1_L0 <= primary);
			is_x0_add_D <= (ik_x1_L0_ik_x2_L0_B - 1 >= primary);
		
		ik_x1_L1 <= ik_x1_L0;
		ik_x0_L1 <= ik_x0_L0;
		forward_all_done_L1 <= forward_all_done_L0;
		status_L1 <= status_L0;
	end
	end
	//L2
	always@(posedge Clk_32UI) begin
	if(!stall) begin

		
			ok3_x0_L2 <= ik_x0_L1 + (is_x0_add_C & is_x0_add_D);
			
			ok0_x1_L2 <= ok0_x1_L1;
			ok1_x1_L2 <= ok1_x1_L1;
			ok2_x1_L2 <= ok2_x1_L1;
			ok3_x1_L2 <= ok3_x1_L1;
		
		
		forward_all_done_L2 <= forward_all_done_L1;
		ok0_x2_L2 <= ok0_x2_L1;
		ok1_x2_L2 <= ok1_x2_L1;
		ok2_x2_L2 <= ok2_x2_L1;
		ok3_x2_L2 <= ok3_x2_L1;   
		status_L2 <= status_L1;
	end
	end
	
	//L3
	always@(posedge Clk_32UI) begin
	if(!stall) begin

			ok2_x0_L3 <= ok3_x0_L2 + ok3_x2_L2;
			
			ok3_x0_L3 <= ok3_x0_L2;
 			
			ok0_x1_L3 <= ok0_x1_L2;
			ok1_x1_L3 <= ok1_x1_L2;
			ok2_x1_L3 <= ok2_x1_L2;
			ok3_x1_L3 <= ok3_x1_L2;
		
		forward_all_done_L3 <= forward_all_done_L2;
		ok0_x2_L3 <= ok0_x2_L2;
		ok1_x2_L3 <= ok1_x2_L2;
		ok2_x2_L3 <= ok2_x2_L2;
		ok3_x2_L3 <= ok3_x2_L2;  
		status_L3 <= status_L2;		
	end
	end
	
	//L4
	always@(posedge Clk_32UI) begin
	if(!stall) begin

		
			ok1_x0_L4 <= ok2_x0_L3 + ok2_x2_L3;
			
			ok2_x0_L4 <= ok2_x0_L3;
			ok3_x0_L4 <= ok3_x0_L3;
			
			ok0_x1_L4 <= ok0_x1_L3;
			ok1_x1_L4 <= ok1_x1_L3;
			ok2_x1_L4 <= ok2_x1_L3;
			ok3_x1_L4 <= ok3_x1_L3;
		
		forward_all_done_L4 <= forward_all_done_L3;
		ok0_x2_L4 <= ok0_x2_L3;
		ok1_x2_L4 <= ok1_x2_L3;
		ok2_x2_L4 <= ok2_x2_L3;
		ok3_x2_L4 <= ok3_x2_L3;   
		status_L4 <= status_L3;
	end
	end
	//L5
	always@(posedge Clk_32UI) begin
	if(!stall) begin

		
			ok0_x0 <= ok1_x0_L4 + ok1_x2_L4;
			ok1_x0 <= ok1_x0_L4;
			ok2_x0 <= ok2_x0_L4;
			ok3_x0 <= ok3_x0_L4;
			
			ok0_x1 <= ok0_x1_L4;
			ok1_x1 <= ok1_x1_L4;
			ok2_x1 <= ok2_x1_L4;
			ok3_x1 <= ok3_x1_L4;
		
		ok0_x2 <= ok0_x2_L4;
		ok1_x2 <= ok1_x2_L4;
		ok2_x2 <= ok2_x2_L4;
		ok3_x2 <= ok3_x2_L4;   
		status_L00 <= status_L4;
		
		case(query_L00_one_cycle_ahead[1:0])
			0:begin
				ok_target_x0 <= ok3_x0_L4;
				ok_target_x1 <= ok3_x1_L4;
				ok_target_x2 <= ok3_x2_L4;
			end
			
			1:begin
				ok_target_x0 <= ok2_x0_L4;
				ok_target_x1 <= ok2_x1_L4;
				ok_target_x2 <= ok2_x2_L4;
;
			end
			
			2:begin
				ok_target_x0 <= ok1_x0_L4;
				ok_target_x1 <= ok1_x1_L4;
				ok_target_x2 <= ok1_x2_L4;
			end
			
			3:begin
				ok_target_x0 <= ok1_x0_L4 + ok1_x2_L4;
				ok_target_x1 <= ok0_x1_L4;
				ok_target_x2 <= ok0_x2_L4;
			end
		endcase
	end
	end
endmodule

///////////////////////////////////////////////////////////////////////////////////
//true_dpram_sclk is for CNT table
//push_mem is to store result, mem_out
//quary queue should be the read?
///////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////
// BWT_OCC4                                       //
////////////////////////////////////////////////////

//output is the the output of bwt_occ4: cnt[4]

module BWT_OCC4(
	input stall,
	input reset_BWT_extend,
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
	reg[31:0] tmp, tmp_q;
	
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
	
	always@(posedge Clk_32UI) begin
	if(!stall) begin
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
	
	//L2
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
	if(!stall) begin
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
	
	reg [63:0] k_L3;
	reg [31:0] cnt_a0_L3,cnt_a1_L3,cnt_a2_L3,cnt_a3_L3;
	
	//L3
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
	if(!stall) begin
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
	
	reg [31:0] total_12, total_34, total_56, total_78;
	reg [31:0] total_12_q, total_34_q, total_56_q, total_78_q;
	
	reg [31:0] total_1, total_5, total_123, total_567, total_1234, total_5678;
	reg [31:0] total_1_q, total_5_q, total_123_q, total_567_q, total_1234_q, total_5678_q;
	
	reg [31:0] total_12_qq, total_56_qq;
	
	reg [63:0] k_L4;
	reg [31:0] cnt_a0_L4,cnt_a1_L4,cnt_a2_L4,cnt_a3_L4;
	
	//L4
	always@(*) begin
		total_12 = sum1_q + sum2_q;
		total_34 = sum3_q + sum4_q;
		total_56 = sum5_q + sum6_q;
		total_78 = sum7_q + sum8_q;	
	end
	
	always@(posedge Clk_32UI) begin
	if(!stall) begin
		total_12_q <= total_12;
		total_34_q <= total_34;
		total_56_q <= total_56;
		total_78_q <= total_78;
		
		sum1_qq <= sum1_q;
		// /*sum2_qq <= sum2_q;
		sum3_qq <= sum3_q;
		// sum4_qq <= sum4_q;*/
		sum5_qq <= sum5_q;
		// /*sum6_qq <= sum6_q;
		sum7_qq <= sum7_q;
		// sum8_qq <= sum8_q;*/
		
		k_L4 <= k_L3;
		cnt_a0_L4 <= cnt_a0_L3;
		cnt_a1_L4 <= cnt_a1_L3; 
		cnt_a2_L4 <= cnt_a2_L3; 
		cnt_a3_L4 <= cnt_a3_L3;
	end
	end
	//------------------------------------------------
    reg [63:0] k_L5;
	reg [31:0] cnt_a0_L5,cnt_a1_L5,cnt_a2_L5,cnt_a3_L5;
	
	//L5
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
	if(!stall) begin
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
	reg [63:0] k_L6;
	reg [31:0] cnt_a0_L6,cnt_a1_L6,cnt_a2_L6,cnt_a3_L6;
	
	//L6
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
	if(!stall) begin
		x_licheng_q <= x_licheng;
		
		k_L6 <= k_L5;
		cnt_a0_L6 <= cnt_a0_L5;
		cnt_a1_L6 <= cnt_a1_L5; 
		cnt_a2_L6 <= cnt_a2_L5; 
		cnt_a3_L6 <= cnt_a3_L5;
	end
	end
	//=================================================
   
   //L7
   assign x_new_reg = x_licheng_q - (~k_L6 & 15); 
   
   always @(posedge Clk_32UI) begin
   if(!stall) begin
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


module Pipe(
	input stall,
	input Clk_32UI,
	input [63:0] ik_x0, ik_x1, ik_x2,
	input forward_all_done,
	input [5:0] status,
	
	output reg [63:0] ik_x0_pipe, ik_x1_pipe, ik_x2_pipe,
	output reg [63:0] ik_x0_L0_ik_x2_L0_A,
	output reg [63:0] ik_x1_L0_ik_x2_L0_B,
	output reg [5:0] status_pipe,
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
	
	reg [5:0] status_L0, status_L1, status_L2, status_L3, status_L4, status_L5, status_L6;

	always @ (posedge Clk_32UI) begin
	if(!stall) begin
		ik_x0_L1 <= ik_x0;
		ik_x1_L1 <= ik_x1;
		ik_x2_L1 <= ik_x2;
		forward_all_done_L1 <= forward_all_done;
		status_L1 <= status;
	end
	end
	
	always @ (posedge Clk_32UI) begin
	if(!stall) begin
		ik_x0_L2 <= ik_x0_L1;
		ik_x1_L2 <= ik_x1_L1;
		ik_x2_L2 <= ik_x2_L1;
		forward_all_done_L2 <= forward_all_done_L1;
		status_L2 <= status_L1;
	end
	end
	
	always @ (posedge Clk_32UI) begin
	if(!stall) begin
		ik_x0_L3 <= ik_x0_L2;
		ik_x1_L3 <= ik_x1_L2;
		ik_x2_L3 <= ik_x2_L2;
		forward_all_done_L3 <= forward_all_done_L2;
		status_L3 <= status_L2;

	end
	end
	
	always @ (posedge Clk_32UI) begin
		if(!stall) begin
		ik_x0_L4 <= ik_x0_L3;
		ik_x1_L4 <= ik_x1_L3;
		ik_x2_L4 <= ik_x2_L3;
		forward_all_done_L4 <= forward_all_done_L3;
		status_L4 <= status_L3;

		end
	end
	always @ (posedge Clk_32UI) begin
	if(!stall) begin
		ik_x0_L5 <= ik_x0_L4;
		ik_x1_L5 <= ik_x1_L4;
		ik_x2_L5 <= ik_x2_L4;
		forward_all_done_L5 <= forward_all_done_L4;
		status_L5 <= status_L4;

		end
	end
	always @ (posedge Clk_32UI) begin
	if(!stall) begin
		ik_x0_L6 <= ik_x0_L5;
		ik_x1_L6 <= ik_x1_L5;
		ik_x2_L6 <= ik_x2_L5;
		forward_all_done_L6 <= forward_all_done_L5;
		status_L6 <= status_L5;

		end
	end
	always @ (posedge Clk_32UI) begin
	if(!stall) begin
		ik_x0_pipe <= ik_x0_L6;
		ik_x1_pipe <= ik_x1_L6;
		ik_x2_pipe <= ik_x2_L6;
		forward_all_done_pipe <= forward_all_done_L6;
		status_pipe <= status_L6;
		
		ik_x0_L0_ik_x2_L0_A <= ik_x0_L6 + ik_x2_L6;
		ik_x1_L0_ik_x2_L0_B <= ik_x1_L6 + ik_x2_L6;
	end
	end
endmodule
