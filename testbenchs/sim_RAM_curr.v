`define PER_H 2.5

module sim_RAM_curr();

	reg reset_n;
	reg clk;
	reg stall;
	reg [8:0] batch_size;
	
	// curr queue; port A
	reg [9:0] curr_read_num_1;
	reg curr_we_1;
	reg [255:0] curr_data_1; //[important]sequence: [ik_info; ik_x2; ik_x1; ik_x0]
	reg [6:0] curr_addr_1;
	wire [255:0] curr_q_1;
	
	//curr queue; port B
	reg [9:0] curr_read_num_2;
	reg curr_we_2;
	reg [255:0] curr_data_2;
	reg [6:0] curr_addr_2;
	wire [255:0] curr_q_2;
	
	//--------------------------------
	
	// mem queue; port A
	reg [9:0] mem_read_num_1;
	reg mem_we_1;
	reg [255:0] mem_data_1; //[important]sequence: [p_info, p_x2, p_x1, p_x0]
	reg [6:0] mem_addr_1;
	wire [255:0] mem_q_1;
	
	//mem queue; port B
	reg [9:0] mem_read_num_2;
	reg mem_we_2;
	reg [255:0] mem_data_2;
	reg [6:0] mem_addr_2;
	wire [255:0] mem_q_2;
	
	//---------------------------------
	
	//mem size
	reg mem_size_valid;
	reg[6:0] mem_size;
	reg[9:0] mem_size_read_num;
	
	//ret
	reg ret_valid;
	reg[31:0] ret;
	reg [9:0] ret_read_num;
	
	//---------------------------------
	
	//output module
	wire output_request;
	reg output_permit;
	wire [511:0] output_data;
	wire output_valid;
	wire output_finish;
	
	RAM_curr_mem uut(
		.reset_n(reset_n),
		.clk(clk),
		.stall(stall),
		.batch_size(batch_size),
		
		// curr queue, port A
		.curr_read_num_1(curr_read_num_1),
		.curr_we_1(curr_we_1),
		.curr_data_1(curr_data_1), //[important]sequence: [ik_info, ik_x2, ik_x1, ik_x0]
		.curr_addr_1(curr_addr_1),
		//.curr_q_1(curr_q_1),
		
		//curr queue, port B
		.curr_read_num_2(curr_read_num_2),
		.curr_addr_2(curr_addr_2),
		.curr_q_2(curr_q_2)
		
		//--------------------------------
		
//		// mem queue, port A
//		.mem_read_num_1(mem_read_num_1),
//		.mem_we_1(mem_we_1),
//		.mem_data_1(mem_data_1), //[important]sequence: [p_info, p_x2, p_x1, p_x0]
//		.mem_addr_1(mem_addr_1),
//		.mem_q_1(mem_q_1),
		
//		//mem queue, port B
//		.mem_read_num_2(mem_read_num_2),
//		.mem_we_2(mem_we_2),
//		.mem_data_2(mem_data_2),
//		.mem_addr_2(mem_addr_2),
//		.mem_q_2(mem_q_2),
		
//		//---------------------------------
		
//		//mem size
//		.mem_size_valid(mem_size_valid),
//		.mem_size(mem_size),
//		.mem_size_read_num(mem_size_read_num),
		
//		//ret
//		.ret_valid(ret_valid),
//		.ret(ret),
//		.ret_read_num(ret_read_num),
		
//		//---------------------------------
		
//		//output module
//		.output_request(output_request),
//		.output_permit(output_permit),
//		.output_data(output_data),
//		.output_valid(output_valid),
//		.output_finish(output_finish)

	);
	
	initial forever #`PER_H clk=!clk; 

	initial begin
		reset_n = 0;
		clk = 1;
		stall = 0;
		batch_size = 0;
		
		// curr queue = 0; port A
		curr_read_num_1 = 0;
		curr_we_1 = 0;
		curr_data_1 = 0; 
		curr_addr_1 = 0;
		
		//curr queue = 0; port B
		curr_read_num_2 = 0;
		curr_we_2 = 0;
		curr_data_2 = 0;
		curr_addr_2 = 0;
		
		//--------------------------------
		
		// mem queue = 0; port A
		mem_read_num_1 = 0;
		mem_we_1 = 0;
		mem_data_1 = 0; 
		mem_addr_1 = 0;
		
		//mem queue = 0; port B
		mem_read_num_2 = 0;
		mem_we_2 = 0;
		mem_data_2 = 0;
		mem_addr_2 = 0;
		
		//---------------------------------
		
		//mem size
		mem_size_valid = 0;
		mem_size = 0;
		mem_size_read_num = 0;
		
		//ret
		ret_valid = 0;
		ret = 0;
		ret_read_num = 0;
		
		//---------------------------------
		
		//output module
		output_permit = 0;
		
		#0.1
		#`PER_H;	#`PER_H;
		#`PER_H;	#`PER_H;
		
		reset_n = 1;
		batch_size = 3;
		#`PER_H;	#`PER_H;
		#`PER_H;	#`PER_H;
		
		//test push/pull for curr
		//write A
		curr_read_num_1 = 2;
		curr_we_1 = 1;
		curr_data_1[63:0] = 1; 
		curr_data_1[127:64] = 2; 
		curr_data_1[191:128] = 3; 
		curr_data_1[255:192] = 4; 
		curr_addr_1 = 7'h7a;
		//write B
//		curr_read_num_2 = 1;
//		curr_we_2 = 1;
//		curr_data_2[63:0] = 5; 
//		curr_data_2[127:64] = 6; 
//		curr_data_2[191:128] = 7; 
//		curr_data_2[255:192] = 8;
//		curr_addr_2 = 1;
		
		#`PER_H;	#`PER_H;
		//read A
		curr_read_num_1 = 0;
		curr_we_1 = 0;
		curr_data_1[63:0] = 0; 
		curr_data_1[127:64] = 0; 
		curr_data_1[191:128] = 0; 
		curr_data_1[255:192] = 0; 
		curr_addr_1 = 0;
		//read B
		

        curr_read_num_2 = 2;
		curr_addr_2 = 7'h7a;
		
		#`PER_H;	#`PER_H;
		
		// curr queue = 0; port A
		curr_read_num_1 = 0;
		curr_we_1 = 0;
		curr_data_1 = 0; 
		curr_addr_1 = 0;
		
		//curr queue = 0; port B
		curr_read_num_2 = 0;
		curr_we_2 = 0;
		curr_data_2 = 0;
		curr_addr_2 = 0;
		#`PER_H;	#`PER_H;
		
		//test mem queue and output module
		// mem queue = 0; port A
		mem_read_num_1 = 0;
		mem_we_1 = 1;
		mem_data_1[63:0] = 1; 
		mem_data_1[127:64] = 2; 
		mem_data_1[191:128] = 3; 
		mem_data_1[255:192] = 4;  
		mem_addr_1 = 0;
		
		#`PER_H;	#`PER_H;
		
		mem_read_num_1 = 1;
		mem_we_1 = 1;
		mem_data_1[63:0] = 5; 
		mem_data_1[127:64] = 6; 
		mem_data_1[191:128] = 7; 
		mem_data_1[255:192] = 8;  
		mem_addr_1 = 0;
		
		#`PER_H;	#`PER_H;
		
		mem_read_num_1 = 1;
		mem_we_1 = 1;
		mem_data_1[63:0] = 9; 
		mem_data_1[127:64] = 10; 
		mem_data_1[191:128] = 11; 
		mem_data_1[255:192] = 12;  
		mem_addr_1 = 1;
		
		#`PER_H;	#`PER_H;
		
		mem_read_num_1 = 2;
		mem_we_1 = 1;
		mem_data_1[63:0] = 13; 
		mem_data_1[127:64] = 14; 
		mem_data_1[191:128] = 15; 
		mem_data_1[255:192] = 16;  
		mem_addr_1 = 0;
		
		#`PER_H;	#`PER_H;
		
		mem_read_num_1 = 2;
		mem_we_1 = 1;
		mem_data_1[63:0] = 17; 
		mem_data_1[127:64] = 18; 
		mem_data_1[191:128] = 19; 
		mem_data_1[255:192] = 20;  
		mem_addr_1 = 1;
		
		#`PER_H;	#`PER_H;
		
		mem_read_num_1 = 2;
		mem_we_1 = 1;
		mem_data_1[63:0] = 21; 
		mem_data_1[127:64] = 22; 
		mem_data_1[191:128] = 23; 
		mem_data_1[255:192] = 24;  
		mem_addr_1 = 2;
		
		#`PER_H;	#`PER_H;
		
		mem_read_num_1 = 0;
		mem_we_1 = 0;
		mem_data_1 = 0; 
		mem_addr_1 = 0;
		
		#`PER_H;	#`PER_H;
		#`PER_H;	#`PER_H;
		#`PER_H;	#`PER_H;
		#`PER_H;	#`PER_H;
		
		ret_valid = 1;
		ret = 1;
		ret_read_num = 0;
		#`PER_H;	#`PER_H;
		
		ret_valid = 1;
		ret = 2;
		ret_read_num = 1;
		#`PER_H;	#`PER_H;
		
		ret_valid = 1;
		ret = 3;
		ret_read_num = 2;
		#`PER_H;	#`PER_H;
		
		ret_valid = 0;
		ret = 0;
		ret_read_num = 0;
		#`PER_H;	#`PER_H;
		#`PER_H;	#`PER_H;
		#`PER_H;	#`PER_H;
		#`PER_H;	#`PER_H;
		#`PER_H;	#`PER_H;
		
		
		mem_size_valid = 1;
		mem_size_read_num = 0;
		mem_size = 1;
		#`PER_H;	#`PER_H;
		
		mem_size_valid = 1;
		mem_size_read_num = 1;
		mem_size = 2;
		#`PER_H;	#`PER_H;
		
		mem_size_valid = 1;
		mem_size_read_num = 2;
		mem_size = 3;
		
		#`PER_H;	#`PER_H;
		#`PER_H;	#`PER_H;
		#`PER_H;	#`PER_H;
		#`PER_H;	#`PER_H;
		#`PER_H;	#`PER_H;
		#`PER_H;	#`PER_H;
		
		output_permit = 1;
		
		#`PER_H;	#`PER_H;
		#`PER_H;	#`PER_H;
		
		stall = 1;
		
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
		#`PER_H;	#`PER_H;
		#`PER_H;	#`PER_H;
		#`PER_H;	#`PER_H;
		#`PER_H;	#`PER_H;#`PER_H;	#`PER_H;
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