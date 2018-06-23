`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/23/2017 05:51:12 PM
// Design Name: 
// Module Name: sim_BWT_extend
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 001 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

`define PER_H 2.5

module sim_BWT_extend();

    reg [5:0] status;
	reg Clk_32UI;
	reg reset_BWT_extend;
	reg forward_all_done; //whether it is forward or backward
	reg CNT_flag;
	reg [63:0] CNT_data;
	reg [7:0]  CNT_addr;
	reg trigger;
	reg [63:0] primary; // fix value
	reg [63:0] k,l;
	reg [31:0] cnt_a0,cnt_a1,cnt_a2,cnt_a3;
	reg [63:0] cnt_b0,cnt_b1,cnt_b2,cnt_b3;
	reg [31:0] cntl_a0,cntl_a1,cntl_a2,cntl_a3;
	reg [63:0] cntl_b0,cntl_b1,cntl_b2,cntl_b3;
	reg [63:0] L2_0, L2_1, L2_2, L2_3; //fix value
	reg [63:0] ik_x0, ik_x1, ik_x2;

	wire BWT_extend_done;
	wire [63:0] ok0_x0, ok0_x1, ok0_x2;
	wire [63:0] ok1_x0, ok1_x1, ok1_x2;
	wire [63:0] ok2_x0, ok2_x1, ok2_x2;
	wire [63:0] ok3_x0, ok3_x1, ok3_x2;
	
	wire [5:0] status_L00;

	BWT_extend uut(
		.status(status),
		
		.Clk_32UI(Clk_32UI),
		.reset_BWT_extend(reset_BWT_extend),
		.forward_all_done(forward_all_done), //whether it is forward or backward
		.CNT_flag(CNT_flag),
		.CNT_data(CNT_data),
		.CNT_addr(CNT_addr),
		.trigger(trigger),
		.primary(primary), // fix value
		.k(k),
		.l(l),
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
		.ik_x0(ik_x0), 
		.ik_x1(ik_x1), 
		.ik_x2(ik_x2),

		.BWT_extend_done(),
		.ok0_x0(ok0_x0), 
		.ok0_x1(ok0_x1), 
		.ok0_x2(ok0_x2),
		.ok1_x0(ok1_x0), 
		.ok1_x1(ok1_x1), 
		.ok1_x2(ok1_x2),
		.ok2_x0(ok2_x0), 
		.ok2_x1(ok2_x1), 
		.ok2_x2(ok2_x2),
		.ok3_x0(ok3_x0), 
		.ok3_x1(ok3_x1), 
		.ok3_x2(ok3_x2),
		
		.status_L00(status_L00)
	);

	initial forever #`PER_H Clk_32UI=!Clk_32UI;
	
	initial begin
		status = 0;
		Clk_32UI = 1;
		reset_BWT_extend = 0;
		forward_all_done = 0; //whether it is forward or backward
		CNT_flag = 0;
		CNT_data = 0;
		CNT_addr = 0;
		trigger = 0;
		primary = 0; // fix value
		k = 0;
		l = 0;
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
		L2_0 = 0; 
		L2_1 = 0; 
		L2_2 = 0; 
		L2_3 = 0; //fix value
		ik_x0 = 0; 
		ik_x1 = 0; 
		ik_x2 = 0;
		
		#`PER_H;	#`PER_H;

		#`PER_H;	#`PER_H;
		reset_BWT_extend = 1;
		#`PER_H;	#`PER_H;
		#`PER_H;	#`PER_H;
		#`PER_H;	#`PER_H;
		
		//1-------------------------------------------
		#`PER_H;	#`PER_H;
		#0.1;
		
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
		forward_all_done = 0; //whether it is forward or backward
		ik_x0 	= 64'h0000_0001_05c9_6189; 
		ik_x1 	= 64'h0000_0000_0000_0001; 
		ik_x2 	= 64'h0000_0000_6bfa_2ffe;
		k 		= 64'h0000_0000_0000_0000;
		l 		= 64'h0000_0000_6bfa_2ffe;
		primary = 64'h0000_0000_9d38_3ea0; // fix value
		reset_BWT_extend = 1;
		status 	= 1;

		
		//2-------------------------------------------
		#`PER_H;	#`PER_H;
		
		L2_0 	= 64'h0000_0000_0000_0000; 
		L2_1 	= 64'h0000_0000_6bfa_2ffe; 
		L2_2 	= 64'h0000_0000_b8e1_c8c3; 
		L2_3 	= 64'h0000_0001_05c9_6188; //fix value
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
		forward_all_done = 0; //whether it is forward or backward
		ik_x0 	= 64'h0000_0001_4e91_2abc; 
		ik_x1 	= 64'h0000_0000_0000_0001; 
		ik_x2 	= 64'h0000_0000_2332_66cb;
		k 		= 64'h0000_0000_0000_0000;
		l 		= 64'h0000_0000_2332_66cb;
		primary = 64'h0000_0000_9d38_3ea0; // fix value
		reset_BWT_extend = 1;
		status 	= 1;

		
		//3-------------------------------------------
		#`PER_H;	#`PER_H;
		
		L2_0   	= 64'h0000_0000_0000_0000; 
		L2_1   	= 64'h0000_0000_6bfa_2ffe; 
		L2_2   	= 64'h0000_0000_b8e1_c8c3; 
		L2_3   	= 64'h0000_0001_05c9_6188; //fix value
		cnt_a0 	= 32'h63fe_d591;
		cnt_a1 	= 32'h4648_c1ea;
		cnt_a2 	= 32'h47fc_fe07;
		cnt_a3 	= 32'h5fb7_18fe;
		cnt_b0 	= 64'hba53_79d8_fbc3_c511;
		cnt_b1 	= 64'ha6aa_9aa7_b722_aaaa;
		cnt_b2 	= 64'h07e7_7ef4_b147_0c20;
		cnt_b3 	= 64'h3c85_5c87_f43c_93b3;
		cntl_a0 = 32'h63fe_d5d7;
		cntl_a1 = 32'h4648_c223;
		cntl_a2 = 32'h47fc_fe3a;
		cntl_a3 = 32'h5fb7_194c;
		cntl_b0 = 64'h3881_04c7_702d_a1b3;
		cntl_b1 = 64'h2efd_f3dd_4ca4_5271;
		cntl_b2 = 64'h5c75_d47a_c7dd_ace5;
		cntl_b3 = 64'he839_335e_af56_bf78;
		forward_all_done = 1; //whether it is forward or backward
		ik_x0 	= 64'h0000_0001_51fb_af00; 
		ik_x1 	= 64'h0000_0000_57fe_efac; 
		ik_x2 	= 64'h0000_0000_0000_00bc;
		k 		= 64'h0000_0001_51fb_aefe;
		l 		= 64'h0000_0001_51fb_afba;
		primary = 64'h0000_0000_9d38_3ea0; // fix value
		reset_BWT_extend = 1;
		status 	= 1;

		
		//4-------------------------------------------
		#`PER_H;	#`PER_H;
		
		L2_0 	= 64'h0000_0000_0000_0000; 
		L2_1 	= 64'h0000_0000_6bfa_2ffe; 
		L2_2 	= 64'h0000_0000_b8e1_c8c3; 
		L2_3 	= 64'h0000_0001_05c9_6188; //fix value
		cnt_a0 	= 32'h63fe_d540;
		cnt_a1 	= 32'h4648_c18e;
		cnt_a2 	= 32'h47fc_fdca;
		cnt_a3 	= 32'h5fb7_1868;
		cnt_b0 	= 64'hf761_507f_c932_4ce8;
		cnt_b1 	= 64'h9ecf_07fd_cd2e_0733;
		cnt_b2 	= 64'hf633_74f3_5d1f_e371;
		cnt_b3 	= 64'hc606_d976_a0cd_0767;
		cntl_a0 = 32'h63fe_d975;
		cntl_a1 = 32'h4648_c419;
		cntl_a2 = 32'h47fd_04f3;
		cntl_a3 = 32'h5fb7_1f7f;
		cntl_b0 = 64'h593c_72e8_d9c1_0fe7;
		cntl_b1 = 64'hfcdf_0df6_fb48_fa7f;
		cntl_b2 = 64'h000c_82fc_3ceb_8000;
		cntl_b3 = 64'hcdef_55fb_78bf_32b3;
		forward_all_done = 1; //whether it is forward or backward
		ik_x0 	= 64'h0000_0001_51fb_ad27; 
		ik_x1 	= 64'h0000_0000_7664_db3e; 
		ik_x2 	= 64'h0000_0000_0000_1558;
		k 		= 64'h0000_0000_51fb_ad25;
		l 		= 64'h0000_0000_51fb_c27d;
		primary = 64'h0000_0000_9d38_3ea0; // fix value
		reset_BWT_extend = 1;
		status 	= 1;
		
		//3-------------------------------------------
		#`PER_H;	#`PER_H;
		
		L2_0   	= 64'h0000_0000_0000_0000; 
		L2_1   	= 64'h0000_0000_6bfa_2ffe; 
		L2_2   	= 64'h0000_0000_b8e1_c8c3; 
		L2_3   	= 64'h0000_0001_05c9_6188; //fix value
		cnt_a0 	= 32'h63fe_d591;
		cnt_a1 	= 32'h4648_c1ea;
		cnt_a2 	= 32'h47fc_fe07;
		cnt_a3 	= 32'h5fb7_18fe;
		cnt_b0 	= 64'hba53_79d8_fbc3_c511;
		cnt_b1 	= 64'ha6aa_9aa7_b722_aaaa;
		cnt_b2 	= 64'h07e7_7ef4_b147_0c20;
		cnt_b3 	= 64'h3c85_5c87_f43c_93b3;
		cntl_a0 = 32'h63fe_d5d7;
		cntl_a1 = 32'h4648_c223;
		cntl_a2 = 32'h47fc_fe3a;
		cntl_a3 = 32'h5fb7_194c;
		cntl_b0 = 64'h3881_04c7_702d_a1b3;
		cntl_b1 = 64'h2efd_f3dd_4ca4_5271;
		cntl_b2 = 64'h5c75_d47a_c7dd_ace5;
		cntl_b3 = 64'he839_335e_af56_bf78;
		forward_all_done = 1; //whether it is forward or backward
		ik_x0 	= 64'h0000_0001_51fb_af00; 
		ik_x1 	= 64'h0000_0000_57fe_efac; 
		ik_x2 	= 64'h0000_0000_0000_00bc;
		k 		= 64'h0000_0001_51fb_aefe;
		l 		= 64'h0000_0001_51fb_afba;
		primary = 64'h0000_0000_9d38_3ea0; // fix value
		reset_BWT_extend = 1;
		status 	= 1;

		
		//4-------------------------------------------
		#`PER_H;	#`PER_H;
		
		L2_0 	= 64'h0000_0000_0000_0000; 
		L2_1 	= 64'h0000_0000_6bfa_2ffe; 
		L2_2 	= 64'h0000_0000_b8e1_c8c3; 
		L2_3 	= 64'h0000_0001_05c9_6188; //fix value
		cnt_a0 	= 32'h63fe_d540;
		cnt_a1 	= 32'h4648_c18e;
		cnt_a2 	= 32'h47fc_fdca;
		cnt_a3 	= 32'h5fb7_1868;
		cnt_b0 	= 64'hf761_507f_c932_4ce8;
		cnt_b1 	= 64'h9ecf_07fd_cd2e_0733;
		cnt_b2 	= 64'hf633_74f3_5d1f_e371;
		cnt_b3 	= 64'hc606_d976_a0cd_0767;
		cntl_a0 = 32'h63fe_d975;
		cntl_a1 = 32'h4648_c419;
		cntl_a2 = 32'h47fd_04f3;
		cntl_a3 = 32'h5fb7_1f7f;
		cntl_b0 = 64'h593c_72e8_d9c1_0fe7;
		cntl_b1 = 64'hfcdf_0df6_fb48_fa7f;
		cntl_b2 = 64'h000c_82fc_3ceb_8000;
		cntl_b3 = 64'hcdef_55fb_78bf_32b3;
		forward_all_done = 1; //whether it is forward or backward
		ik_x0 	= 64'h0000_0001_51fb_ad27; 
		ik_x1 	= 64'h0000_0000_7664_db3e; 
		ik_x2 	= 64'h0000_0000_0000_1558;
		k 		= 64'h0000_0000_51fb_ad25;
		l 		= 64'h0000_0000_51fb_c27d;
		primary = 64'h0000_0000_9d38_3ea0; // fix value
		reset_BWT_extend = 1;
		status 	= 1;
		
		//3-------------------------------------------
		#`PER_H;	#`PER_H;
		
		L2_0   	= 64'h0000_0000_0000_0000; 
		L2_1   	= 64'h0000_0000_6bfa_2ffe; 
		L2_2   	= 64'h0000_0000_b8e1_c8c3; 
		L2_3   	= 64'h0000_0001_05c9_6188; //fix value
		cnt_a0 	= 32'h63fe_d591;
		cnt_a1 	= 32'h4648_c1ea;
		cnt_a2 	= 32'h47fc_fe07;
		cnt_a3 	= 32'h5fb7_18fe;
		cnt_b0 	= 64'hba53_79d8_fbc3_c511;
		cnt_b1 	= 64'ha6aa_9aa7_b722_aaaa;
		cnt_b2 	= 64'h07e7_7ef4_b147_0c20;
		cnt_b3 	= 64'h3c85_5c87_f43c_93b3;
		cntl_a0 = 32'h63fe_d5d7;
		cntl_a1 = 32'h4648_c223;
		cntl_a2 = 32'h47fc_fe3a;
		cntl_a3 = 32'h5fb7_194c;
		cntl_b0 = 64'h3881_04c7_702d_a1b3;
		cntl_b1 = 64'h2efd_f3dd_4ca4_5271;
		cntl_b2 = 64'h5c75_d47a_c7dd_ace5;
		cntl_b3 = 64'he839_335e_af56_bf78;
		forward_all_done = 1; //whether it is forward or backward
		ik_x0 	= 64'h0000_0001_51fb_af00; 
		ik_x1 	= 64'h0000_0000_57fe_efac; 
		ik_x2 	= 64'h0000_0000_0000_00bc;
		k 		= 64'h0000_0001_51fb_aefe;
		l 		= 64'h0000_0001_51fb_afba;
		primary = 64'h0000_0000_9d38_3ea0; // fix value
		reset_BWT_extend = 1;
		status 	= 1;

		
		//4-------------------------------------------
		#`PER_H;	#`PER_H;
		
		L2_0 	= 64'h0000_0000_0000_0000; 
		L2_1 	= 64'h0000_0000_6bfa_2ffe; 
		L2_2 	= 64'h0000_0000_b8e1_c8c3; 
		L2_3 	= 64'h0000_0001_05c9_6188; //fix value
		cnt_a0 	= 32'h63fe_d540;
		cnt_a1 	= 32'h4648_c18e;
		cnt_a2 	= 32'h47fc_fdca;
		cnt_a3 	= 32'h5fb7_1868;
		cnt_b0 	= 64'hf761_507f_c932_4ce8;
		cnt_b1 	= 64'h9ecf_07fd_cd2e_0733;
		cnt_b2 	= 64'hf633_74f3_5d1f_e371;
		cnt_b3 	= 64'hc606_d976_a0cd_0767;
		cntl_a0 = 32'h63fe_d975;
		cntl_a1 = 32'h4648_c419;
		cntl_a2 = 32'h47fd_04f3;
		cntl_a3 = 32'h5fb7_1f7f;
		cntl_b0 = 64'h593c_72e8_d9c1_0fe7;
		cntl_b1 = 64'hfcdf_0df6_fb48_fa7f;
		cntl_b2 = 64'h000c_82fc_3ceb_8000;
		cntl_b3 = 64'hcdef_55fb_78bf_32b3;
		forward_all_done = 1; //whether it is forward or backward
		ik_x0 	= 64'h0000_0001_51fb_ad27; 
		ik_x1 	= 64'h0000_0000_7664_db3e; 
		ik_x2 	= 64'h0000_0000_0000_1558;
		k 		= 64'h0000_0000_51fb_ad25;
		l 		= 64'h0000_0000_51fb_c27d;
		primary = 64'h0000_0000_9d38_3ea0; // fix value
		reset_BWT_extend = 1;
		status 	= 1;
		
		//3-------------------------------------------
		#`PER_H;	#`PER_H;
		
		L2_0   	= 64'h0000_0000_0000_0000; 
		L2_1   	= 64'h0000_0000_6bfa_2ffe; 
		L2_2   	= 64'h0000_0000_b8e1_c8c3; 
		L2_3   	= 64'h0000_0001_05c9_6188; //fix value
		cnt_a0 	= 32'h63fe_d591;
		cnt_a1 	= 32'h4648_c1ea;
		cnt_a2 	= 32'h47fc_fe07;
		cnt_a3 	= 32'h5fb7_18fe;
		cnt_b0 	= 64'hba53_79d8_fbc3_c511;
		cnt_b1 	= 64'ha6aa_9aa7_b722_aaaa;
		cnt_b2 	= 64'h07e7_7ef4_b147_0c20;
		cnt_b3 	= 64'h3c85_5c87_f43c_93b3;
		cntl_a0 = 32'h63fe_d5d7;
		cntl_a1 = 32'h4648_c223;
		cntl_a2 = 32'h47fc_fe3a;
		cntl_a3 = 32'h5fb7_194c;
		cntl_b0 = 64'h3881_04c7_702d_a1b3;
		cntl_b1 = 64'h2efd_f3dd_4ca4_5271;
		cntl_b2 = 64'h5c75_d47a_c7dd_ace5;
		cntl_b3 = 64'he839_335e_af56_bf78;
		forward_all_done = 1; //whether it is forward or backward
		ik_x0 	= 64'h0000_0001_51fb_af00; 
		ik_x1 	= 64'h0000_0000_57fe_efac; 
		ik_x2 	= 64'h0000_0000_0000_00bc;
		k 		= 64'h0000_0001_51fb_aefe;
		l 		= 64'h0000_0001_51fb_afba;
		primary = 64'h0000_0000_9d38_3ea0; // fix value
		reset_BWT_extend = 1;
		status 	= 1;

		
		//4-------------------------------------------
		#`PER_H;	#`PER_H;
		
		L2_0 	= 64'h0000_0000_0000_0000; 
		L2_1 	= 64'h0000_0000_6bfa_2ffe; 
		L2_2 	= 64'h0000_0000_b8e1_c8c3; 
		L2_3 	= 64'h0000_0001_05c9_6188; //fix value
		cnt_a0 	= 32'h63fe_d540;
		cnt_a1 	= 32'h4648_c18e;
		cnt_a2 	= 32'h47fc_fdca;
		cnt_a3 	= 32'h5fb7_1868;
		cnt_b0 	= 64'hf761_507f_c932_4ce8;
		cnt_b1 	= 64'h9ecf_07fd_cd2e_0733;
		cnt_b2 	= 64'hf633_74f3_5d1f_e371;
		cnt_b3 	= 64'hc606_d976_a0cd_0767;
		cntl_a0 = 32'h63fe_d975;
		cntl_a1 = 32'h4648_c419;
		cntl_a2 = 32'h47fd_04f3;
		cntl_a3 = 32'h5fb7_1f7f;
		cntl_b0 = 64'h593c_72e8_d9c1_0fe7;
		cntl_b1 = 64'hfcdf_0df6_fb48_fa7f;
		cntl_b2 = 64'h000c_82fc_3ceb_8000;
		cntl_b3 = 64'hcdef_55fb_78bf_32b3;
		forward_all_done = 1; //whether it is forward or backward
		ik_x0 	= 64'h0000_0001_51fb_ad27; 
		ik_x1 	= 64'h0000_0000_7664_db3e; 
		ik_x2 	= 64'h0000_0000_0000_1558;
		k 		= 64'h0000_0000_51fb_ad25;
		l 		= 64'h0000_0000_51fb_c27d;
		primary = 64'h0000_0000_9d38_3ea0; // fix value
		reset_BWT_extend = 1;
		status 	= 1;
		
		//5-------------------------------------------
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
		forward_all_done = 0; //whether it is forward or backward
		ik_x0 	= 64'h0000_0001_05c9_6189; 
		ik_x1 	= 64'h0000_0000_0000_0001; 
		ik_x2 	= 64'h0000_0000_6bfa_2ffe;
		k 		= 64'h0000_0000_0000_0000;
		l 		= 64'h0000_0000_6bfa_2ffe;
		primary = 64'h0000_0000_9d38_3ea0; // fix value
		reset_BWT_extend = 1;
		status 	= 1;

		
		//6-------------------------------------------
		#`PER_H;	#`PER_H;
		
		L2_0 	= 64'h0000_0000_0000_0000; 
		L2_1 	= 64'h0000_0000_6bfa_2ffe; 
		L2_2 	= 64'h0000_0000_b8e1_c8c3; 
		L2_3 	= 64'h0000_0001_05c9_6188; //fix value
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
		forward_all_done = 0; //whether it is forward or backward
		ik_x0 	= 64'h0000_0001_4e91_2abc; 
		ik_x1 	= 64'h0000_0000_0000_0001; 
		ik_x2 	= 64'h0000_0000_2332_66cb;
		k 		= 64'h0000_0000_0000_0000;
		l 		= 64'h0000_0000_2332_66cb;
		primary = 64'h0000_0000_9d38_3ea0; // fix value
		reset_BWT_extend = 1;
		status 	= 1;
		
		//7-------------------------------------------
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
		forward_all_done = 0; //whether it is forward or backward
		ik_x0 	= 64'h0000_0001_05c9_6189; 
		ik_x1 	= 64'h0000_0000_0000_0001; 
		ik_x2 	= 64'h0000_0000_6bfa_2ffe;
		k 		= 64'h0000_0000_0000_0000;
		l 		= 64'h0000_0000_6bfa_2ffe;
		primary = 64'h0000_0000_9d38_3ea0; // fix value
		reset_BWT_extend = 1;
		status 	= 1;

		
		//8-------------------------------------------
		#`PER_H;	#`PER_H;
		
		L2_0 	= 64'h0000_0000_0000_0000; 
		L2_1 	= 64'h0000_0000_6bfa_2ffe; 
		L2_2 	= 64'h0000_0000_b8e1_c8c3; 
		L2_3 	= 64'h0000_0001_05c9_6188; //fix value
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
		forward_all_done = 0; //whether it is forward or backward
		ik_x0 	= 64'h0000_0001_4e91_2abc; 
		ik_x1 	= 64'h0000_0000_0000_0001; 
		ik_x2 	= 64'h0000_0000_2332_66cb;
		k 		= 64'h0000_0000_0000_0000;
		l 		= 64'h0000_0000_2332_66cb;
		primary = 64'h0000_0000_9d38_3ea0; // fix value
		reset_BWT_extend = 1;
		status 	= 1;
		
		//9-------------------------------------------
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
		forward_all_done = 0; //whether it is forward or backward
		ik_x0 	= 64'h0000_0001_05c9_6189; 
		ik_x1 	= 64'h0000_0000_0000_0001; 
		ik_x2 	= 64'h0000_0000_6bfa_2ffe;
		k 		= 64'h0000_0000_0000_0000;
		l 		= 64'h0000_0000_6bfa_2ffe;
		primary = 64'h0000_0000_9d38_3ea0; // fix value
		reset_BWT_extend = 1;
		status 	= 1;

		
		//10-------------------------------------------
		#`PER_H;	#`PER_H;
		
		L2_0 	= 64'h0000_0000_0000_0000; 
		L2_1 	= 64'h0000_0000_6bfa_2ffe; 
		L2_2 	= 64'h0000_0000_b8e1_c8c3; 
		L2_3 	= 64'h0000_0001_05c9_6188; //fix value
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
		forward_all_done = 0; //whether it is forward or backward
		ik_x0 	= 64'h0000_0001_4e91_2abc; 
		ik_x1 	= 64'h0000_0000_0000_0001; 
		ik_x2 	= 64'h0000_0000_2332_66cb;
		k 		= 64'h0000_0000_0000_0000;
		l 		= 64'h0000_0000_2332_66cb;
		primary = 64'h0000_0000_9d38_3ea0; // fix value
		reset_BWT_extend = 1;
		status 	= 1;
		
		//11-------------------------------------------
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
		forward_all_done = 0; //whether it is forward or backward
		ik_x0 	= 64'h0000_0001_05c9_6189; 
		ik_x1 	= 64'h0000_0000_0000_0001; 
		ik_x2 	= 64'h0000_0000_6bfa_2ffe;
		k 		= 64'h0000_0000_0000_0000;
		l 		= 64'h0000_0000_6bfa_2ffe;
		primary = 64'h0000_0000_9d38_3ea0; // fix value
		reset_BWT_extend = 1;
		status 	= 1;

		
		//12-------------------------------------------
		#`PER_H;	#`PER_H;
		
		L2_0 	= 64'h0000_0000_0000_0000; 
		L2_1 	= 64'h0000_0000_6bfa_2ffe; 
		L2_2 	= 64'h0000_0000_b8e1_c8c3; 
		L2_3 	= 64'h0000_0001_05c9_6188; //fix value
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
		forward_all_done = 0; //whether it is forward or backward
		ik_x0 	= 64'h0000_0001_4e91_2abc; 
		ik_x1 	= 64'h0000_0000_0000_0001; 
		ik_x2 	= 64'h0000_0000_2332_66cb;
		k 		= 64'h0000_0000_0000_0000;
		l 		= 64'h0000_0000_2332_66cb;
		primary = 64'h0000_0000_9d38_3ea0; // fix value
		reset_BWT_extend = 1;
		status 	= 1;
		
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
