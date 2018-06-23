`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/24/2017 07:57:04 PM
// Design Name: 
// Module Name: sim_datapath
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
module sim_datapath();

	reg Clk_32UI;
	reg reset_BWT_extend;
	reg [63:0] primary; // fix value
	reg [31:0] cnt_a0,cnt_a1,cnt_a2,cnt_a3;
	reg [63:0] cnt_b0,cnt_b1,cnt_b2,cnt_b3;
	reg [31:0] cntl_a0,cntl_a1,cntl_a2,cntl_a3;
	reg [63:0] cntl_b0,cntl_b1,cntl_b2,cntl_b3;
	reg [63:0] L2_0, L2_1, L2_2, L2_3; //fix value
	
	reg [6:0] forward_i;
	reg [6:0] min_intv;
	reg read_trigger;
	
	//---------------------
	reg [5:0] status;
	reg [7:0] query; //only send the current query into the pipeline
	reg [6:0] ptr_curr; // record the status of curr and mem queue
	reg [6:0] ptr_mem; //
	reg [9:0] read_num;
	reg [63:0] ik_x0, ik_x1, ik_x2, ik_info;
	
	wire[5:0] status_out;
	wire[6:0] ptr_curr_out; // record the status of curr and mem queue
	wire[6:0] ptr_mem_out; //	
	wire[9:0] read_num_out;
	wire[63:0] ik_x0_out, ik_x1_out, ik_x2_out, ik_info_out;
	wire[6:0] forward_i_out;
	wire[6:0] min_intv_out;
	//----------------------------
	
	wire curr_we_1;
	wire[255:0] curr_data_1;
	wire[6:0] curr_addr_1;	
	wire curr_we_2;
	wire[255:0] curr_data_2;
	wire[6:0] curr_addr_2;
	
	wire DRAM_valid;
	wire[31:0] addr_k, addr_l;
	
	wire error1;
	
	Datapath uut(
        // input of BWT_extend
        .Clk_32UI(Clk_32UI),
        .reset_BWT_extend(reset_BWT_extend),
        .primary(primary), // fix value
        .cnt_a0(cnt_a0),
        .cnt_a1(cnt_a1),
        .cnt_a2(cnt_a2),
        .cnt_a3(cnt_a3),
        .cnt_b0(cnt_b0),
        .cnt_b1(cnt_b1),
        .cnt_b2(cnt_b2),
        .cnt_b3(cnt_b3),
        .cntl_a0(cntl_a0),
        .cntl_a1(cntl_a1),
        .cntl_a2(cntl_a2),
        .cntl_a3(cntl_a3),
        .cntl_b0(cntl_b0),
        .cntl_b1(cntl_b1),
        .cntl_b2(cntl_b2),
        .cntl_b3(cntl_b3),
        .L2_0(L2_0),
        .L2_1(L2_1),
        .L2_2(L2_2),
        .L2_3(L2_3), //fix value
    
        .forward_i(forward_i),
        .min_intv(min_intv),
        .read_trigger(read_trigger), //signal that the read has been loaded in position.(.)
        //.DRAM_get(.DRAM_get),// signal that memory responses have arrived.(.)
        
        //-------------------------------------
        .status(status),
        .query(query), //only send the current query into the pipeline
        .ptr_curr(ptr_curr), // record the status of curr and mem queue
        .ptr_mem(ptr_mem), //
        .read_num(read_num),
        .ik_x0(ik_x0),
        .ik_x1(ik_x1),
        .ik_x2(ik_x2),
        .ik_info(ik_info),
        
        .status_out(status_out),
        .ptr_curr_out(ptr_curr_out), // record the status of curr and mem queue
        .ptr_mem_out(ptr_mem_out), //	
        .read_num_out(read_num_out),
        .ik_x0_out(ik_x0_out),
        .ik_x1_out(ik_x1_out),
        .ik_x2_out(ik_x2_out),
        .ik_info_out(ik_info_out),
        .forward_i_out(forward_i_out),
		.min_intv_out(min_intv_out),
        //----------------------------
        
        .curr_we_1(curr_we_1),
        .curr_data_1(curr_data_1),
        .curr_addr_1(curr_addr_1),	
        .curr_we_2(curr_we_2),
        .curr_data_2(curr_data_2),
        .curr_addr_2(curr_addr_2),
        
        .DRAM_valid(DRAM_valid),
        .addr_k(addr_k),
        .addr_l(addr_l),
        
        .error1(error1)
    );
    
    initial forever #`PER_H Clk_32UI=!Clk_32UI; 
	
	initial begin
	    Clk_32UI = 1;
		L2_0 = 0;
        L2_1 = 0;
        L2_2 = 0;
        L2_3 = 0; //fix value
        cnt_a0 = 0;
        cnt_a1 = 0;
        cnt_a2 = 0;
        cnt_a3 = 0;
        cnt_b0 = 0;
        cnt_b1 = 0;
        cnt_b2 = 0;
        cnt_b3 = 0;
        cntl_a0 = 0;
        cntl_a1 = 0;
        cntl_a2 = 0;
        cntl_a3 = 0;
        cntl_b0 = 0;
        cntl_b1 = 0;
        cntl_b2 = 0;
        cntl_b3 = 0;
        forward_i = 0;
        ik_info = 0;
        ik_x0 = 0;
        ik_x1 = 0;
        ik_x2 = 0;
        min_intv = 0;
        primary = 0; // fix value
        ptr_curr = 0; // record the status of curr and mem queue
        ptr_mem = 0; //
        query = 0; //only send the current query into the pipeline
        read_num = 0;
        read_trigger = 0; //signal that the read has been loaded in position()
        reset_BWT_extend = 0;
        status = 7;

		#`PER_H;	#`PER_H;
		#`PER_H;	#`PER_H;

		reset_BWT_extend = 1;
		read_trigger = 1;

		#`PER_H;	#`PER_H;
		#`PER_H;	#`PER_H;
		#`PER_H;	#`PER_H;
		#0.1;
		//1-------------------------------------------
		#`PER_H;	#`PER_H;
		

		L2_0   	= 64'h0000_0000_0000_0000; 
		L2_1   	= 64'h0000_0000_6bfa_2ffe; 
		L2_2   	= 64'h0000_0000_b8e1_c8c3; 
		L2_3   	= 64'h0000_0001_05c9_6188; //fix value
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
        forward_i = 1;
        ik_info = 1;
        ik_x0 	= 64'h0000_0001_05c9_6189; 
		ik_x1 	= 64'h0000_0000_0000_0001; 
		ik_x2 	= 64'h0000_0000_6bfa_2ffe;
        min_intv = 1;
        primary = 64'h0000_0000_9d38_3ea0;
        ptr_curr = 7'h00; // record the status of curr and mem queue
        query = 8'h03; //only send the current query into the pipeline
        read_num = 1;
        status = 1;
		
		//2-------------------------------------------
		#`PER_H;	#`PER_H;

		L2_0   	= 64'h0000_0000_0000_0000; 
		L2_1   	= 64'h0000_0000_6bfa_2ffe; 
		L2_2   	= 64'h0000_0000_b8e1_c8c3; 
		L2_3   	= 64'h0000_0001_05c9_6188; //fix value
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
        forward_i = 2;
        ik_info = 2;
        ik_x0 	= 64'h0000_0001_4e91_2abc; 
		ik_x1 	= 64'h0000_0000_0000_0001; 
		ik_x2 	= 64'h0000_0000_2332_66cb;
        min_intv = 1;
        primary = 64'h0000_0000_9d38_3ea0;
        ptr_curr = 7'h01; // record the status of curr and mem queue
        query = 8'h00; //only send the current query into the pipeline
        read_num = 2;
        status = 1;
		
		//3-------------------------------------------
		#`PER_H;	#`PER_H;

		L2_0   	= 64'h0000_0000_0000_0000; 
		L2_1   	= 64'h0000_0000_6bfa_2ffe; 
		L2_2   	= 64'h0000_0000_b8e1_c8c3; 
		L2_3   	= 64'h0000_0001_05c9_6188; //fix value
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
        forward_i = 3;
        ik_info = 3;
        ik_x0 	= 64'h0000_0001_4e91_2abc; 
		ik_x1 	= 64'h0000_0001_05c9_6189; 
		ik_x2 	= 64'h0000_0000_078b_382b;
        min_intv = 1;
        primary = 64'h0000_0000_9d38_3ea0;
        ptr_curr = 7'h02; // record the status of curr and mem queue
        query = 8'h01; //only send the current query into the pipeline
        read_num = 3;
        status = 1;
		
		//==========================================
		
		//1-------------------------------------------
		#`PER_H;	#`PER_H;
		

		L2_0   	= 64'h0000_0000_0000_0000; 
		L2_1   	= 64'h0000_0000_6bfa_2ffe; 
		L2_2   	= 64'h0000_0000_b8e1_c8c3; 
		L2_3   	= 64'h0000_0001_05c9_6188; //fix value
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
        forward_i = 1;
        ik_info = 1;
        ik_x0 	= 64'h0000_0001_05c9_6189; 
		ik_x1 	= 64'h0000_0000_0000_0001; 
		ik_x2 	= 64'h0000_0000_6bfa_2ffe;
        min_intv = 1;
        primary = 64'h0000_0000_9d38_3ea0;
        ptr_curr = 7'h00; // record the status of curr and mem queue
        query = 8'h03; //only send the current query into the pipeline
        read_num = 4;
        status = 1;
		
		//2-------------------------------------------
		#`PER_H;	#`PER_H;

		L2_0   	= 64'h0000_0000_0000_0000; 
		L2_1   	= 64'h0000_0000_6bfa_2ffe; 
		L2_2   	= 64'h0000_0000_b8e1_c8c3; 
		L2_3   	= 64'h0000_0001_05c9_6188; //fix value
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
        forward_i = 2;
        ik_info = 2;
        ik_x0 	= 64'h0000_0001_4e91_2abc; 
		ik_x1 	= 64'h0000_0000_0000_0001; 
		ik_x2 	= 64'h0000_0000_2332_66cb;
        min_intv = 1;
        primary = 64'h0000_0000_9d38_3ea0;
        ptr_curr = 7'h01; // record the status of curr and mem queue
        query = 8'h00; //only send the current query into the pipeline
        read_num = 5;
        status = 1;
		
		//3-------------------------------------------
		#`PER_H;	#`PER_H;

		L2_0   	= 64'h0000_0000_0000_0000; 
		L2_1   	= 64'h0000_0000_6bfa_2ffe; 
		L2_2   	= 64'h0000_0000_b8e1_c8c3; 
		L2_3   	= 64'h0000_0001_05c9_6188; //fix value
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
        forward_i = 3;
        ik_info = 3;
        ik_x0 	= 64'h0000_0001_4e91_2abc; 
		ik_x1 	= 64'h0000_0001_05c9_6189; 
		ik_x2 	= 64'h0000_0000_078b_382b;
        min_intv = 1;
        primary = 64'h0000_0000_9d38_3ea0;
        ptr_curr = 7'h02; // record the status of curr and mem queue
        query = 8'h01; //only send the current query into the pipeline
        read_num = 6;
        status = 1;
		
		//============================================
		
		//1-------------------------------------------
		#`PER_H;	#`PER_H;
		

		L2_0   	= 64'h0000_0000_0000_0000; 
		L2_1   	= 64'h0000_0000_6bfa_2ffe; 
		L2_2   	= 64'h0000_0000_b8e1_c8c3; 
		L2_3   	= 64'h0000_0001_05c9_6188; //fix value
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
        forward_i = 1;
        ik_info = 1;
        ik_x0 	= 64'h0000_0001_05c9_6189; 
		ik_x1 	= 64'h0000_0000_0000_0001; 
		ik_x2 	= 64'h0000_0000_6bfa_2ffe;
        min_intv = 1;
        primary = 64'h0000_0000_9d38_3ea0;
        ptr_curr = 7'h00; // record the status of curr and mem queue
        query = 8'h03; //only send the current query into the pipeline
        read_num = 7;
        status = 1;
		
		//2-------------------------------------------
		#`PER_H;	#`PER_H;

		L2_0   	= 64'h0000_0000_0000_0000; 
		L2_1   	= 64'h0000_0000_6bfa_2ffe; 
		L2_2   	= 64'h0000_0000_b8e1_c8c3; 
		L2_3   	= 64'h0000_0001_05c9_6188; //fix value
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
        forward_i = 2;
        ik_info = 2;
        ik_x0 	= 64'h0000_0001_4e91_2abc; 
		ik_x1 	= 64'h0000_0000_0000_0001; 
		ik_x2 	= 64'h0000_0000_2332_66cb;
        min_intv = 1;
        primary = 64'h0000_0000_9d38_3ea0;
        ptr_curr = 7'h01; // record the status of curr and mem queue
        query = 8'h00; //only send the current query into the pipeline
        read_num = 8;
        status = 1;
		
		//3-------------------------------------------
		#`PER_H;	#`PER_H;

		L2_0   	= 64'h0000_0000_0000_0000; 
		L2_1   	= 64'h0000_0000_6bfa_2ffe; 
		L2_2   	= 64'h0000_0000_b8e1_c8c3; 
		L2_3   	= 64'h0000_0001_05c9_6188; //fix value
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
        forward_i = 3;
        ik_info = 3;
        ik_x0 	= 64'h0000_0001_4e91_2abc; 
		ik_x1 	= 64'h0000_0001_05c9_6189; 
		ik_x2 	= 64'h0000_0000_078b_382b;
        min_intv = 1;
        primary = 64'h0000_0000_9d38_3ea0;
        ptr_curr = 7'h02; // record the status of curr and mem queue
        query = 8'h01; //only send the current query into the pipeline
        read_num = 9;
        status = 1;
		
		#`PER_H;	#`PER_H;
		//L2_0 = 0;
        //L2_1 = 0;
        //L2_2 = 0;
        //L2_3 = 0; //fix value
        cnt_a0 = 0;
        cnt_a1 = 0;
        cnt_a2 = 0;
        cnt_a3 = 0;
        cnt_b0 = 0;
        cnt_b1 = 0;
        cnt_b2 = 0;
        cnt_b3 = 0;
        cntl_a0 = 0;
        cntl_a1 = 0;
        cntl_a2 = 0;
        cntl_a3 = 0;
        cntl_b0 = 0;
        cntl_b1 = 0;
        cntl_b2 = 0;
        cntl_b3 = 0;
        forward_i = 0;
        ik_info = 0;
        ik_x0 = 0;
        ik_x1 = 0;
        ik_x2 = 0;
        //min_intv = 0;
        //primary = 0; // fix value
        ptr_curr = 0; // record the status of curr and mem queue
        ptr_mem = 0; //
        query = 0; //only send the current query into the pipeline
        read_num = 0;
        read_trigger = 0; //signal that the read has been loaded in position()
        reset_BWT_extend = 0;
        status = 7;
		
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