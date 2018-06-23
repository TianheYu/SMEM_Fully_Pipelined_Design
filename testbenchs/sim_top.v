`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/27/2017 10:52:41 AM
// Design Name: 
// Module Name: sim_top
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

`define PER_H 2.5

module sim_top();

	reg Clk_32UI;
	reg reset_BWT_extend;
	reg stall;
	
	//RAM for reads
	reg load_valid;
	reg [511:0] load_data;
	reg [8:0] batch_size;
	
	//output memory requests
	wire DRAM_valid;
	wire [31:0] addr_k, addr_l;
	
	//input memory responses
	reg DRAM_get;
	reg [31:0] cnt_a0,cnt_a1,cnt_a2,cnt_a3;
	reg [63:0] cnt_b0,cnt_b1,cnt_b2,cnt_b3;
	reg [31:0] cntl_a0,cntl_a1,cntl_a2,cntl_a3;
	reg [63:0] cntl_b0,cntl_b1,cntl_b2,cntl_b3;
	
	wire curr_we_1;
	wire [255:0] curr_data_1;
	wire [6:0] curr_addr_1;	
	wire curr_we_2;
	wire [255:0] curr_data_2;
	wire [6:0] curr_addr_2;	
	
	
	Top uut(
		.Clk_32UI(Clk_32UI),
		.reset_BWT_extend(reset_BWT_extend),
		.stall(stall),
		
		.load_valid(load_valid),
		.load_data(load_data),
		.batch_size(batch_size),
		
		//output memory requests
		.DRAM_valid(DRAM_valid),
		.addr_k(addr_k), .addr_l(addr_l),
		
		//.memory responses
		.DRAM_get(DRAM_get),
		.cnt_a0(cnt_a0),.cnt_a1(cnt_a1),.cnt_a2(cnt_a2),.cnt_a3(cnt_a3),
		.cnt_b0(cnt_b0),.cnt_b1(cnt_b1),.cnt_b2(cnt_b2),.cnt_b3(cnt_b3),
		.cntl_a0(cntl_a0),.cntl_a1(cntl_a1),.cntl_a2(cntl_a2),.cntl_a3(cntl_a3),
		.cntl_b0(cntl_b0),.cntl_b1(cntl_b1),.cntl_b2(cntl_b2),.cntl_b3(cntl_b3),
		
		// curr mem		
		.curr_we_1(curr_we_1),
		.curr_data_1(curr_data_1),
		.curr_addr_1(curr_addr_1),	
		.curr_we_2(curr_we_2),
		.curr_data_2(curr_data_2),
		.curr_addr_2(curr_addr_2)	
	);

	initial forever #`PER_H Clk_32UI=!Clk_32UI; 
	
	initial begin
		Clk_32UI = 1;
		reset_BWT_extend = 0;
		stall = 0;
		
		load_valid = 0;
		load_data = 0;
		batch_size = 0;
		
		DRAM_get = 0;
		cnt_a0 	= 0;
		cnt_a1 	= 0;
		cnt_a2 	= 0;
		cnt_a3 	= 0;
		cnt_b0 	= 0;
		cnt_b1 	= 0;
		cnt_b2 	= 0;
		cnt_b3 	= 0;
		cntl_a0 = 0;
		cntl_a1 = 0;
		cntl_a2 = 0;
		cntl_a3 = 0;
		cntl_b0 = 0;
		cntl_b1 = 0;
		cntl_b2 = 0;
		cntl_b3 = 0;
		
		#0.1;
		
		#`PER_H;	#`PER_H;
		#`PER_H;	#`PER_H;
		
		reset_BWT_extend = 1;
		
		#`PER_H;	#`PER_H;
		#`PER_H;	#`PER_H;
		
		//test part 1
		
		load_valid = 1;
		batch_size = 3;
		
		load_data = 512'h00000203030303020000020002000300010303030301030303030100000200030200020200000003010000010301010302030203020300020302010301000303;#`PER_H;#`PER_H;
		load_data = 512'h00000000000000000000000000000000000000000000000000000001020203030300030002020302000001020301030000020203020303030303010301020100;#`PER_H;#`PER_H;
		load_data = 512'h00000000000000000000000000000000000000000000000000000000000000000000000000000000000000009d383ea000000000000000010000000000000000;#`PER_H;#`PER_H;
		load_data = 512'h0000000105c9618800000000b8e1c8c3000000006bfa2ffe00000000000000000000000000000001000000006bfa2ffe00000000000000010000000105c96189;#`PER_H;#`PER_H;
		
		load_data = 512'h00000301010100000301010100000301010100000301010100000301010100000301010100000301010100000301010100000301010100000301010100000300;#`PER_H;#`PER_H;
		load_data = 512'h00000000000000000000000000000000000000000000000000000001000003000101000003010101000103010101000003020101000003010101000003020101;#`PER_H;#`PER_H;
		load_data = 512'h00000000000000000000000000000000000000000000000000000000000000000000000000000000000000009d383ea000000000000000010000000000000000;#`PER_H;#`PER_H;
		load_data = 512'h0000000105c9618800000000b8e1c8c3000000006bfa2ffe00000000000000000000000000000001000000006bfa2ffe0000000105c961890000000000000001;#`PER_H;#`PER_H;
		
		load_data = 512'h03020203000000020202000302020202000300020202000303020202000303020202000000020202000302020202020303020202000300020202000303020300;#`PER_H;#`PER_H;
		load_data = 512'h00000000000000000000000000000000000000000000000000000000010202020003030202020000030002020003000202000003030202020003010202020003;#`PER_H;#`PER_H;
		load_data = 512'h00000000000000000000000000000000000000000000000000000000000000000000000000000000000000009d383ea000000000000000010000000000000000;#`PER_H;#`PER_H;
		load_data = 512'h0000000105c9618800000000b8e1c8c3000000006bfa2ffe00000000000000000000000000000001000000006bfa2ffe0000000105c961890000000000000001;#`PER_H;#`PER_H;		
		load_valid = 0;
		#300;

		//-----------------------------------
		
		//-----------------------------------
		#`PER_H;	#`PER_H;
		//1st memory responses for first read
		
		DRAM_get = 1;
		cnt_a0 	= 32'h0000_0000;
		cnt_a1 	= 32'h0000_0000;
		cnt_a2 	= 32'h0000_0000;
		cnt_a3 	= 32'h0000_0000;
		cnt_b0 	= 64'h4000_0000_9000_4000;
		cnt_b1 	= 64'h0001_0301_0400_4000;
		cnt_b2 	= 64'h0040_0000_0000_0000;
		cnt_b3 	= 64'h4000_3001_0000_4003;
		cntl_a0 = 32'h2332_667f;
		cntl_a1 = 32'h1a8f_72c7;
		cntl_a2 = 32'h1608_a04a;
		cntl_a3 = 32'h182f_b5f0;
		cntl_b0 = 64'h003c_8001_8a04_2c80;
		cntl_b1 = 64'h04c8_3c98_8f01_c00c;
		cntl_b2 = 64'h0220_4340_00ca_20e2;
		cntl_b3 = 64'hc810_c003_0e0a_8ec6;
		
		stall = 1;
		//-----------------------------------
		#`PER_H;	#`PER_H;
		//1st memory responses for 2nd read
		
		DRAM_get = 1;
		cnt_a0 	= 32'h4fd3_521c;
		cnt_a1 	= 32'h3340_e8a7;
		cnt_a2 	= 32'h39ed_5d8c;
		cnt_a3 	= 32'h48c7_c931;
		cnt_b0 	= 64'hcc46_5579_9bae_6e75;
		cnt_b1 	= 64'h5956_5d95_7956_7455;
		cnt_b2 	= 64'h55fa_d515_51e6_4196;
		cnt_b3 	= 64'ha9ed_5556_571b_b57d;
		cntl_a0 = 32'h6bfa_2ffd;
		cntl_a1 = 32'h4ce7_98c5;
		cntl_a2 = 32'h4ce7_98c5;
		cntl_a3 = 32'h6bfa_2ff9;
		cntl_b0 = 64'h6bfa_2ffe_ffc0_0000;
		cntl_b1 = 64'h4ce7_98c5_0000_0000;
		cntl_b2 = 64'h4ce7_98c5_0000_0000;
		cntl_b3 = 64'h6bfa_2ffe_0000_0000;
		

		
		//-----------------------------------
		#`PER_H;	#`PER_H;
		//1st memory responses for 3rd read
		
		DRAM_get = 1;
		cnt_a0 	= 32'h4fd3_521c;
		cnt_a1 	= 32'h3340_e8a7;
		cnt_a2 	= 32'h39ed_5d8c;
		cnt_a3 	= 32'h48c7_c931;
		cnt_b0 	= 64'hcc46_5579_9bae_6e75;
		cnt_b1 	= 64'h5956_5d95_7956_7455;
		cnt_b2 	= 64'h55fa_d515_51e6_4196;
		cnt_b3 	= 64'ha9ed_5556_571b_b57d;
		cntl_a0 = 32'h6bfa_2ffd;
		cntl_a1 = 32'h4ce7_98c5;
		cntl_a2 = 32'h4ce7_98c5;
		cntl_a3 = 32'h6bfa_2ff9;
		cntl_b0 = 64'h6bfa_2ffe_ffc0_0000;
		cntl_b1 = 64'h4ce7_98c5_0000_0000;
		cntl_b2 = 64'h4ce7_98c5_0000_0000;
		cntl_b3 = 64'h6bfa_2ffe_0000_0000;

		
		//-----------------------------------
		#`PER_H;	#`PER_H;
		//no memory responses, no more read
		
		DRAM_get = 0;
		cnt_a0 	= 0;
		cnt_a1 	= 0;
		cnt_a2 	= 0;
		cnt_a3 	= 0;
		cnt_b0 	= 0;
		cnt_b1 	= 0;
		cnt_b2 	= 0;
		cnt_b3 	= 0;
		cntl_a0 = 0;
		cntl_a1 = 0;
		cntl_a2 = 0;
		cntl_a3 = 0;
		cntl_b0 = 0;
		cntl_b1 = 0;
		cntl_b2 = 0;
		cntl_b3 = 0;

		
		//no memory responses, no more read
		#`PER_H;	#`PER_H;
		#`PER_H;	#`PER_H;
		#`PER_H;	#`PER_H;
		#`PER_H;	#`PER_H;
		#`PER_H;	#`PER_H;
		
		#`PER_H;	#`PER_H;
		#`PER_H;	#`PER_H;
		#`PER_H;	#`PER_H;
		#`PER_H;	#`PER_H;
		#`PER_H;	#`PER_H;
		#`PER_H;	#`PER_H;
		stall = 0;
		#`PER_H;	#`PER_H;
		#`PER_H;	#`PER_H;
		#`PER_H;	#`PER_H;
		#`PER_H;	#`PER_H;
		#`PER_H;	#`PER_H;
		#`PER_H;	#`PER_H;
		#`PER_H;	#`PER_H;
		#`PER_H;	#`PER_H;
		#`PER_H;	#`PER_H;
		#`PER_H;	#`PER_H;
		#`PER_H;	#`PER_H;
		#`PER_H;	#`PER_H;
		#`PER_H;	#`PER_H;
		#`PER_H;	#`PER_H;
		
		//-----------------------------------
		#`PER_H;	#`PER_H;
		//2nd memory responses for 1st read
		
		DRAM_get = 1;
		cnt_a0 	= 32'h0000_0000;
		cnt_a1 	= 32'h0000_0000;
		cnt_a2 	= 32'h0000_0000;
		cnt_a3 	= 32'h0000_0000;
		cnt_b0 	= 64'h4000_0000_9000_4000;
		cnt_b1 	= 64'h0001_0301_0400_4000;
		cnt_b2 	= 64'h0040_0000_0000_0000;
		cnt_b3 	= 64'h4000_3001_0000_4003;
		cntl_a0 = 32'h0d90_bdbf;
		cntl_a1 = 32'h06e9_6251;
		cntl_a2 = 32'h072d_0e63;
		cntl_a3 = 32'h078b_380d;
		cntl_b0 = 64'hb3f9_3ffc_dda9_fbee;
		cntl_b1 = 64'h88e3_269e_22c9_2f30;
		cntl_b2 = 64'h6975_d17b_dfcc_ea59;
		cntl_b3 = 64'h550e_ff5f_f77d_b437;
		

		
		//-----------------------------------
		#`PER_H;	#`PER_H;
		//2nd memory responses for 2nd read
		
		DRAM_get = 1;
		cnt_a0 	= 32'h1a3d_b452;
		cnt_a1 	= 32'h13d8_aa3c;
		cnt_a2 	= 32'h1108_779b;
		cnt_a3 	= 32'h10b4_7bd7;
		cnt_b0 	= 64'h70ec_d315_00af_bcdf;
		cnt_b1 	= 64'hc045_6434_6113_3438;
		cnt_b2 	= 64'h081c_05d5_c047_4105;
		cnt_b3 	= 64'h0412_571d_5c55_4102;
		cntl_a0 = 32'h2332_667f;
		cntl_a1 = 32'h1a8f_72c7;
		cntl_a2 = 32'h1608_a04a;
		cntl_a3 = 32'h182f_b5f0;
		cntl_b0 = 64'h003c_8001_8a04_2c80;
		cntl_b1 = 64'h04c8_3c98_8f01_c00c;
		cntl_b2 = 64'h0220_4340_00ca_20e2;
		cntl_b3 = 64'hc810_c003_0e0a_8ec6;
		
		
		//-----------------------------------
		#`PER_H;	#`PER_H;
		//2nd memory responses for 3rd read
		
		DRAM_get = 1;
		cnt_a0 	= 32'h1a3d_b452;
		cnt_a1 	= 32'h13d8_aa3c;
		cnt_a2 	= 32'h1108_779b;
		cnt_a3 	= 32'h10b4_7bd7;
		cnt_b0 	= 64'h70ec_d315_00af_bcdf;
		cnt_b1 	= 64'hc045_6434_6113_3438;
		cnt_b2 	= 64'h081c_05d5_c047_4105;
		cnt_b3 	= 64'h0412_571d_5c55_4102;
		cntl_a0 = 32'h2332_667f;
		cntl_a1 = 32'h1a8f_72c7;
		cntl_a2 = 32'h1608_a04a;
		cntl_a3 = 32'h182f_b5f0;
		cntl_b0 = 64'h003c_8001_8a04_2c80;
		cntl_b1 = 64'h04c8_3c98_8f01_c00c;
		cntl_b2 = 64'h0220_4340_00ca_20e2;
		cntl_b3 = 64'hc810_c003_0e0a_8ec6;
		
		
		//-----------------------------------
		#`PER_H;	#`PER_H;
		//no memory responses, no more read
		
		DRAM_get = 0;
		cnt_a0 	= 0;
		cnt_a1 	= 0;
		cnt_a2 	= 0;
		cnt_a3 	= 0;
		cnt_b0 	= 0;
		cnt_b1 	= 0;
		cnt_b2 	= 0;
		cnt_b3 	= 0;
		cntl_a0 = 0;
		cntl_a1 = 0;
		cntl_a2 = 0;
		cntl_a3 = 0;
		cntl_b0 = 0;
		cntl_b1 = 0;
		cntl_b2 = 0;
		cntl_b3 = 0;
		
		
		//no memory responses, no more read
		#`PER_H;	#`PER_H;
		#`PER_H;	#`PER_H;
		#`PER_H;	#`PER_H;
		#`PER_H;	#`PER_H;
		#`PER_H;	#`PER_H;
		#`PER_H;	#`PER_H;
		#`PER_H;	#`PER_H;
		#`PER_H;	#`PER_H;
		#`PER_H;	#`PER_H;
		#`PER_H;	#`PER_H;
		#`PER_H;	#`PER_H;
		#`PER_H;	#`PER_H;
		#`PER_H;	#`PER_H;
		#`PER_H;	#`PER_H;
		#`PER_H;	#`PER_H;
		#`PER_H;	#`PER_H;
		#`PER_H;	#`PER_H;
		#`PER_H;	#`PER_H;
		#`PER_H;	#`PER_H;
		#`PER_H;	#`PER_H;
		#`PER_H;	#`PER_H;
		#`PER_H;	#`PER_H;
		#`PER_H;	#`PER_H;
		#`PER_H;	#`PER_H;
		#`PER_H;	#`PER_H;
		
		//-----------------------------------
		#`PER_H;	#`PER_H;
		//3rd memory responses for 1st read
		
		DRAM_get = 1;
		cnt_a0 	= 32'h4fd3_521c;
		cnt_a1 	= 32'h3340_e8a7;
		cnt_a2 	= 32'h39ed_5d8c;
		cnt_a3 	= 32'h48c7_c931;
		cnt_b0 	= 64'hcc46_5579_9bae_6e75;
		cnt_b1 	= 64'h5956_5d95_7956_7455;
		cnt_b2 	= 64'h55fa_d515_51e6_4196;
		cnt_b3 	= 64'ha9ed_5556_571b_b57d;
		cntl_a0 = 32'h5239_69ac;
		cntl_a1 = 32'h34b1_7a61;
		cntl_a2 = 32'h3b3f_c685;
		cntl_a3 = 32'h4b29_eeee;
		cntl_b0 = 64'h05f1_5dfe_5d5d_571f;
		cntl_b1 = 64'h5401_75d5_37d7_5772;
		cntl_b2 = 64'h1145_110c_5475_4154;
		cntl_b3 = 64'h1157_157d_7400_1530;
		
		
		//-----------------------------------
		#`PER_H;	#`PER_H;
		//3rd memory responses for 2nd read
		
		DRAM_get = 1;
		cnt_a0 	= 32'h54d3_c289;
		cnt_a1 	= 32'h36c1_252f;
		cnt_a2 	= 32'h3cfc_0ba2;
		cnt_a3 	= 32'h4dec_e9a6;
		cnt_b0 	= 64'h5d15_77fd_cbbb_a5cf;
		cnt_b1 	= 64'h4cb5_234e_44f1_b04f;
		cnt_b2 	= 64'hcb87_87fd_136d_8161;
		cnt_b3 	= 64'h7197_7925_9a8b_cd45;
		cntl_a0 = 32'h574e_8c39;
		cntl_a1 = 32'h3819_6f4f;
		cntl_a2 = 32'h3e3e_1a9f;
		cntl_a3 = 32'h5053_0159;
		cntl_b0 = 64'h5555_5575_cbd3_e515;
		cntl_b1 = 64'h5555_5555_5555_5555;
		cntl_b2 = 64'h4555_5555_5555_55d5;
		cntl_b3 = 64'h5555_5551_5555_5555;
		
		//-----------------------------------
		#`PER_H;	#`PER_H;
		//3rd memory responses for 3rd read
		
		DRAM_get = 1;
		cnt_a0 	= 32'h2896_e246;
		cnt_a1 	= 32'h1fae_8a53;
		cnt_a2 	= 32'h1a1f_80c9;
		cnt_a3 	= 32'h1d6d_ec9e;
		cnt_b0 	= 64'h7156_fcf1_9780_7740;
		cnt_b1 	= 64'h632c_24b4_5c8c_d924;
		cnt_b2 	= 64'hf53f_775e_f5fc_7dff;
		cnt_b3 	= 64'h17fc_efd5_5ffd_dbbe;
		cntl_a0 = 32'h2a86_c281;
		cntl_a1 = 32'h214c_e72e;
		cntl_a2 = 32'h1b64_c345;
		cntl_a3 = 32'h1f51_358c;
		cntl_b0 = 64'hcfa0_c0d9_8d6a_071e;
		cntl_b1 = 64'h339d_3fa6_962f_efe1;
		cntl_b2 = 64'h03df_f27b_c00d_1763;
		cntl_b3 = 64'h3b37_3318_cc38_0169;
		
		//-----------------------------------
		#`PER_H;	#`PER_H;
		//no memory responses, no more read
		
		DRAM_get = 0;
		cnt_a0 	= 0;
		cnt_a1 	= 0;
		cnt_a2 	= 0;
		cnt_a3 	= 0;
		cnt_b0 	= 0;
		cnt_b1 	= 0;
		cnt_b2 	= 0;
		cnt_b3 	= 0;
		cntl_a0 = 0;
		cntl_a1 = 0;
		cntl_a2 = 0;
		cntl_a3 = 0;
		cntl_b0 = 0;
		cntl_b1 = 0;
		cntl_b2 = 0;
		cntl_b3 = 0;
		
		//no memory responses, no more read
		#`PER_H;	#`PER_H;
		#`PER_H;	#`PER_H;
		#`PER_H;	#`PER_H;
		#`PER_H;	#`PER_H;
		#`PER_H;	#`PER_H;
		#`PER_H;	#`PER_H;
		#`PER_H;	#`PER_H;
		#`PER_H;	#`PER_H;
		#`PER_H;	#`PER_H;
		#`PER_H;	#`PER_H;
		#`PER_H;	#`PER_H;
		#`PER_H;	#`PER_H;
		#`PER_H;	#`PER_H;
		#`PER_H;	#`PER_H;
		#`PER_H;	#`PER_H;
		#`PER_H;	#`PER_H;
		#`PER_H;	#`PER_H;
		#`PER_H;	#`PER_H;
		#`PER_H;	#`PER_H;
		#`PER_H;	#`PER_H;
		#`PER_H;	#`PER_H;
		#`PER_H;	#`PER_H;
		#`PER_H;	#`PER_H;
		#`PER_H;	#`PER_H;
		#`PER_H;	#`PER_H;
		#`PER_H;	#`PER_H;
		#`PER_H;	#`PER_H;
		#`PER_H;	#`PER_H;
		#`PER_H;	#`PER_H;
		#`PER_H;	#`PER_H;
		#`PER_H;	#`PER_H;
		#`PER_H;	#`PER_H;
		#`PER_H;	#`PER_H;
		#`PER_H;	#`PER_H;
		#`PER_H;	#`PER_H;
		#`PER_H;	#`PER_H;
		#`PER_H;	#`PER_H;
		#`PER_H;	#`PER_H;
		#`PER_H;	#`PER_H;
		#`PER_H;	#`PER_H;
		#`PER_H;	#`PER_H;
		#`PER_H;	#`PER_H;
		#`PER_H;	#`PER_H;
		#`PER_H;	#`PER_H;
		#`PER_H;	#`PER_H;
		#`PER_H;	#`PER_H;
		#`PER_H;	#`PER_H;
		#`PER_H;	#`PER_H;
		#`PER_H;	#`PER_H;
		#`PER_H;	#`PER_H;
		
		$finish; 
		
	end
endmodule
