`define CL 512
`define MAX_READ 1024
`define READ_NUM_WIDTH 10

module RAM_read(
	input reset_n,
	input clk,
	input stall,
	
	// part 1: load all reads
	input load_valid,
	input [`CL -1:0] load_data,
	input [`READ_NUM_WIDTH+1 -1:0] batch_size,
	output reg load_done,
	
	// part 2: provide new read to pipeline
	input new_read, //indicate RAM to update new_read
	
	//output reg new_read_valid,
	output new_read_valid,
	
	output [`READ_NUM_WIDTH - 1:0] new_read_num, //equal to read_num
	output [63:0] new_ik_x0, new_ik_x1, new_ik_x2, new_ik_info,
	output [6:0] new_forward_i, //[important] forward_i points to the position already processed
	output [6:0] new_min_intv,
	
	//part 3: provide new query to queue
	input [5:0] status_query_RAM_read,
	input [6:0] query_position_RAM_read,
	input [`READ_NUM_WIDTH - 1:0] query_read_num_RAM_read,
	output reg [7:0] new_read_query_RAM_read,
	
	//part 4: provide primary,  L2
	output [63:0] primary,
	output [63:0] L2_0, L2_1, L2_2, L2_3
);
	parameter Len = 101;
	
	parameter F_init = 	6'b00_0001; // F_init will disable the forward pipeline
	parameter F_run =  	6'b00_0010;
	parameter F_break = 6'b00_0100;
	parameter BCK_INI = 6'b00_1000;	//100
	parameter BCK_RUN = 6'b01_0000;	//101
	parameter BCK_END = 6'b10_0000;	//110
	parameter BUBBLE = 	6'b00_0000;
	
	reg [`CL - 1:0] RAM_read_1[`MAX_READ - 1:0];
	reg [`CL - 1:0] RAM_read_2[`MAX_READ - 1:0];
	reg [`CL - 1:0] RAM_param[`MAX_READ - 1:0];
	reg [`CL - 1:0] RAM_ik[`MAX_READ - 1:0];
	
	reg [`READ_NUM_WIDTH+1 -1:0] curr_position;	
	reg [1:0] arbiter;
	
	wire [`CL-1:0] compress_load_data;
	//part 1: load all reads
	always@(posedge clk) begin
		if(!reset_n) begin
			curr_position <= 0;
			arbiter <= 0;
			load_done <= 0;
		end
		else begin
			if (load_valid) begin
				arbiter <= arbiter + 1;
				case(arbiter) 
					2'b00: RAM_read_1[curr_position] <= compress_load_data;
					2'b01: RAM_read_2[curr_position] <= compress_load_data;
					2'b10: RAM_param[curr_position] <= load_data;
					2'b11: begin 
						RAM_ik[curr_position] <= load_data;
						curr_position <= curr_position + 1;
					end				
				endcase			
			end
			
			if (curr_position == batch_size && curr_position > 0) load_done <= 1;
		end
	end
	
	assign primary = RAM_param[0][191:128];
	assign L2_0 = RAM_ik[0][319:256];
	assign L2_1 = RAM_ik[0][383:320];
	assign L2_2 = RAM_ik[0][447:384];
	assign L2_3 = RAM_ik[0][511:448];
	
	//part 2: provide new reads to pipeline
	reg [`READ_NUM_WIDTH-1 + 1:0] new_read_ptr;	
	
	assign new_read_num = new_read_ptr;
	
	assign new_ik_x0[32:0]   = RAM_ik[new_read_ptr][32:0];
	assign new_ik_x1[32:0]   = RAM_ik[new_read_ptr][96:64];
	assign new_ik_x2[32:0]   = RAM_ik[new_read_ptr][160:128];
	assign new_ik_info[6:0] = RAM_ik[new_read_ptr][198:192];
	assign new_ik_info[38:32] = RAM_ik[new_read_ptr][230:224];
	assign new_forward_i = RAM_param[new_read_ptr][6:0];
	assign new_min_intv = RAM_param[new_read_ptr][70:64];
	
	assign new_ik_x0[63:33] = 0;
	assign new_ik_x1[63:33] = 0;
	assign new_ik_x2[63:33] = 0;
	assign new_ik_info[63:39] = 0;
	assign new_ik_info[31:7] = 0;
						
	assign new_read_valid = reset_n & load_done & (new_read_ptr < curr_position) ;
	always@(posedge clk) begin
		if(!reset_n) begin
			new_read_ptr <= 0;
			// new_read_valid <= 0;			
		end
		else if(!stall) begin
			if (load_done) begin		
				if(new_read_ptr < curr_position) begin
					// new_read_valid <= 1;
					
					if(new_read) begin
						new_read_ptr <= new_read_ptr + 1;
					end
					else begin
						new_read_ptr <= new_read_ptr;
					end
				end
				else begin
					// new_read_valid <= 0;
					new_read_ptr <= new_read_ptr;
				end
			end
		
			else begin
				// new_read_valid <= 0;
				new_read_ptr <= new_read_ptr;		
			end
		end
	end
	
	//part 3: provide new query to queue	
	
	reg [255:0] select_L1; //contain 32 querys
	reg [63:0] select_L2;
	
	reg [6:0] query_position_L1, query_position_q;
	reg [6:0] query_position_L2;
	
	reg [5:0] status_L1;
	reg [5:0] status_L2;
	
	//first level extraction 101 -> 32
	
	wire [`CL-1:0] compress_RAM_read_1_query;
	wire [`CL-1:0] compress_RAM_read_2_query;
	reg [`CL-1:0] compress_RAM_read_1_query_q;
	reg [`CL-1:0] compress_RAM_read_2_query_q;
	
	//add one pipeline stage
	always@(posedge clk) begin
		if(!stall) begin
			compress_RAM_read_1_query_q <= compress_RAM_read_1_query;
			compress_RAM_read_2_query_q <= compress_RAM_read_2_query;
			query_position_q <= query_position_RAM_read;
		end
	end
	
	always@(posedge clk) begin
		if(!reset_n) begin
			query_position_L1 <= 0;
			select_L1 <= 0;
			status_L1 <= BUBBLE;
		end
		else if(!stall) begin
				case (query_position_q[6:5])
					2'b00: begin
						select_L1 <= compress_RAM_read_1_query_q[255:0];
					end
					2'b01: begin
						select_L1 <= compress_RAM_read_1_query_q[511:256];
					end
					2'b10: begin
						select_L1 <= compress_RAM_read_2_query_q[255:0];
					end
					2'b11: begin
						select_L1 <= compress_RAM_read_2_query_q[511:256];
					end
				endcase
				
				query_position_L1 <= query_position_q;

		end
	end
	
	//second level extraction 32 -> 8
	always@(posedge clk) begin
		if(!reset_n) begin
			query_position_L2 <= 0;
			select_L2 <= 0;
			status_L2 <= BUBBLE;
		end
		else if(!stall) begin
				case(query_position_L1[4:3])
					2'b00: begin
						select_L2 <= select_L1[63:0];
					end
					2'b01: begin
						select_L2 <= select_L1[127:64];
					end
					2'b10: begin
						select_L2 <= select_L1[191:128];
					end
					2'b11: begin
						select_L2 <= select_L1[255:192];
					end
				endcase
				
				query_position_L2 <= query_position_L1;

		end
	end
	
	//third level extraction 8 -> 1
	always@(posedge clk) begin
		if(!reset_n) begin
			new_read_query_RAM_read <= 8'b1111_1111;	
		end
		else if(!stall) begin
				case(query_position_L2[2:0])
					3'b000: begin
						new_read_query_RAM_read <= select_L2[7:0];
					end
					3'b001: begin
						new_read_query_RAM_read <= select_L2[15:8];
					end
					3'b010: begin
						new_read_query_RAM_read <= select_L2[23:16];
					end
					3'b011: begin
						new_read_query_RAM_read <= select_L2[31:24];
					end
					3'b100: begin
						new_read_query_RAM_read <= select_L2[39:32];
					end
					3'b101: begin
						new_read_query_RAM_read <= select_L2[47:40];
					end
					3'b110: begin
						new_read_query_RAM_read <= select_L2[55:48];
					end
					3'b111: begin
						new_read_query_RAM_read <= select_L2[63:56];
					end
					
					default: new_read_query_RAM_read <= 8'bxxxx_xxxx;
				endcase

		end
	end
	
	assign compress_load_data = {
		6'bxxxxxx,load_data[505:504],
		6'bxxxxxx,load_data[497:496],
		6'bxxxxxx,load_data[489:488],
		6'bxxxxxx,load_data[481:480],
		6'bxxxxxx,load_data[473:472],
		6'bxxxxxx,load_data[465:464],
		6'bxxxxxx,load_data[457:456],
		6'bxxxxxx,load_data[449:448],
		6'bxxxxxx,load_data[441:440],
		6'bxxxxxx,load_data[433:432],
		6'bxxxxxx,load_data[425:424],
		6'bxxxxxx,load_data[417:416],
		6'bxxxxxx,load_data[409:408],
		6'bxxxxxx,load_data[401:400],
		6'bxxxxxx,load_data[393:392],
		6'bxxxxxx,load_data[385:384],
		6'bxxxxxx,load_data[377:376],
		6'bxxxxxx,load_data[369:368],
		6'bxxxxxx,load_data[361:360],
		6'bxxxxxx,load_data[353:352],
		6'bxxxxxx,load_data[345:344],
		6'bxxxxxx,load_data[337:336],
		6'bxxxxxx,load_data[329:328],
		6'bxxxxxx,load_data[321:320],
		6'bxxxxxx,load_data[313:312],
		6'bxxxxxx,load_data[305:304],
		6'bxxxxxx,load_data[297:296],
		6'bxxxxxx,load_data[289:288],
		6'bxxxxxx,load_data[281:280],
		6'bxxxxxx,load_data[273:272],
		6'bxxxxxx,load_data[265:264],
		6'bxxxxxx,load_data[257:256],
		6'bxxxxxx,load_data[249:248],
		6'bxxxxxx,load_data[241:240],
		6'bxxxxxx,load_data[233:232],
		6'bxxxxxx,load_data[225:224],
		6'bxxxxxx,load_data[217:216],
		6'bxxxxxx,load_data[209:208],
		6'bxxxxxx,load_data[201:200],
		6'bxxxxxx,load_data[193:192],
		6'bxxxxxx,load_data[185:184],
		6'bxxxxxx,load_data[177:176],
		6'bxxxxxx,load_data[169:168],
		6'bxxxxxx,load_data[161:160],
		6'bxxxxxx,load_data[153:152],
		6'bxxxxxx,load_data[145:144],
		6'bxxxxxx,load_data[137:136],
		6'bxxxxxx,load_data[129:128],
		6'bxxxxxx,load_data[121:120],
		6'bxxxxxx,load_data[113:112],
		6'bxxxxxx,load_data[105:104],
		6'bxxxxxx,load_data[97:96],
		6'bxxxxxx,load_data[89:88],
		6'bxxxxxx,load_data[81:80],
		6'bxxxxxx,load_data[73:72],
		6'bxxxxxx,load_data[65:64],
		6'bxxxxxx,load_data[57:56],
		6'bxxxxxx,load_data[49:48],
		6'bxxxxxx,load_data[41:40],
		6'bxxxxxx,load_data[33:32],
		6'bxxxxxx,load_data[25:24],
		6'bxxxxxx,load_data[17:16],
		6'bxxxxxx,load_data[9:8],
		6'bxxxxxx,load_data[1:0]
	};
	
	assign compress_RAM_read_1_query = {
		6'b000000,RAM_read_1[query_read_num_RAM_read][505:504],
		6'b000000,RAM_read_1[query_read_num_RAM_read][497:496],
		6'b000000,RAM_read_1[query_read_num_RAM_read][489:488],
		6'b000000,RAM_read_1[query_read_num_RAM_read][481:480],
		6'b000000,RAM_read_1[query_read_num_RAM_read][473:472],
		6'b000000,RAM_read_1[query_read_num_RAM_read][465:464],
		6'b000000,RAM_read_1[query_read_num_RAM_read][457:456],
		6'b000000,RAM_read_1[query_read_num_RAM_read][449:448],
		6'b000000,RAM_read_1[query_read_num_RAM_read][441:440],
		6'b000000,RAM_read_1[query_read_num_RAM_read][433:432],
		6'b000000,RAM_read_1[query_read_num_RAM_read][425:424],
		6'b000000,RAM_read_1[query_read_num_RAM_read][417:416],
		6'b000000,RAM_read_1[query_read_num_RAM_read][409:408],
		6'b000000,RAM_read_1[query_read_num_RAM_read][401:400],
		6'b000000,RAM_read_1[query_read_num_RAM_read][393:392],
		6'b000000,RAM_read_1[query_read_num_RAM_read][385:384],
		6'b000000,RAM_read_1[query_read_num_RAM_read][377:376],
		6'b000000,RAM_read_1[query_read_num_RAM_read][369:368],
		6'b000000,RAM_read_1[query_read_num_RAM_read][361:360],
		6'b000000,RAM_read_1[query_read_num_RAM_read][353:352],
		6'b000000,RAM_read_1[query_read_num_RAM_read][345:344],
		6'b000000,RAM_read_1[query_read_num_RAM_read][337:336],
		6'b000000,RAM_read_1[query_read_num_RAM_read][329:328],
		6'b000000,RAM_read_1[query_read_num_RAM_read][321:320],
		6'b000000,RAM_read_1[query_read_num_RAM_read][313:312],
		6'b000000,RAM_read_1[query_read_num_RAM_read][305:304],
		6'b000000,RAM_read_1[query_read_num_RAM_read][297:296],
		6'b000000,RAM_read_1[query_read_num_RAM_read][289:288],
		6'b000000,RAM_read_1[query_read_num_RAM_read][281:280],
		6'b000000,RAM_read_1[query_read_num_RAM_read][273:272],
		6'b000000,RAM_read_1[query_read_num_RAM_read][265:264],
		6'b000000,RAM_read_1[query_read_num_RAM_read][257:256],
		6'b000000,RAM_read_1[query_read_num_RAM_read][249:248],
		6'b000000,RAM_read_1[query_read_num_RAM_read][241:240],
		6'b000000,RAM_read_1[query_read_num_RAM_read][233:232],
		6'b000000,RAM_read_1[query_read_num_RAM_read][225:224],
		6'b000000,RAM_read_1[query_read_num_RAM_read][217:216],
		6'b000000,RAM_read_1[query_read_num_RAM_read][209:208],
		6'b000000,RAM_read_1[query_read_num_RAM_read][201:200],
		6'b000000,RAM_read_1[query_read_num_RAM_read][193:192],
		6'b000000,RAM_read_1[query_read_num_RAM_read][185:184],
		6'b000000,RAM_read_1[query_read_num_RAM_read][177:176],
		6'b000000,RAM_read_1[query_read_num_RAM_read][169:168],
		6'b000000,RAM_read_1[query_read_num_RAM_read][161:160],
		6'b000000,RAM_read_1[query_read_num_RAM_read][153:152],
		6'b000000,RAM_read_1[query_read_num_RAM_read][145:144],
		6'b000000,RAM_read_1[query_read_num_RAM_read][137:136],
		6'b000000,RAM_read_1[query_read_num_RAM_read][129:128],
		6'b000000,RAM_read_1[query_read_num_RAM_read][121:120],
		6'b000000,RAM_read_1[query_read_num_RAM_read][113:112],
		6'b000000,RAM_read_1[query_read_num_RAM_read][105:104],
		6'b000000,RAM_read_1[query_read_num_RAM_read][97:96],
		6'b000000,RAM_read_1[query_read_num_RAM_read][89:88],
		6'b000000,RAM_read_1[query_read_num_RAM_read][81:80],
		6'b000000,RAM_read_1[query_read_num_RAM_read][73:72],
		6'b000000,RAM_read_1[query_read_num_RAM_read][65:64],
		6'b000000,RAM_read_1[query_read_num_RAM_read][57:56],
		6'b000000,RAM_read_1[query_read_num_RAM_read][49:48],
		6'b000000,RAM_read_1[query_read_num_RAM_read][41:40],
		6'b000000,RAM_read_1[query_read_num_RAM_read][33:32],
		6'b000000,RAM_read_1[query_read_num_RAM_read][25:24],
		6'b000000,RAM_read_1[query_read_num_RAM_read][17:16],
		6'b000000,RAM_read_1[query_read_num_RAM_read][9:8],
		6'b000000,RAM_read_1[query_read_num_RAM_read][1:0]	
	};

	assign compress_RAM_read_2_query = {
		6'b000000,RAM_read_2[query_read_num_RAM_read][505:504],
		6'b000000,RAM_read_2[query_read_num_RAM_read][497:496],
		6'b000000,RAM_read_2[query_read_num_RAM_read][489:488],
		6'b000000,RAM_read_2[query_read_num_RAM_read][481:480],
		6'b000000,RAM_read_2[query_read_num_RAM_read][473:472],
		6'b000000,RAM_read_2[query_read_num_RAM_read][465:464],
		6'b000000,RAM_read_2[query_read_num_RAM_read][457:456],
		6'b000000,RAM_read_2[query_read_num_RAM_read][449:448],
		6'b000000,RAM_read_2[query_read_num_RAM_read][441:440],
		6'b000000,RAM_read_2[query_read_num_RAM_read][433:432],
		6'b000000,RAM_read_2[query_read_num_RAM_read][425:424],
		6'b000000,RAM_read_2[query_read_num_RAM_read][417:416],
		6'b000000,RAM_read_2[query_read_num_RAM_read][409:408],
		6'b000000,RAM_read_2[query_read_num_RAM_read][401:400],
		6'b000000,RAM_read_2[query_read_num_RAM_read][393:392],
		6'b000000,RAM_read_2[query_read_num_RAM_read][385:384],
		6'b000000,RAM_read_2[query_read_num_RAM_read][377:376],
		6'b000000,RAM_read_2[query_read_num_RAM_read][369:368],
		6'b000000,RAM_read_2[query_read_num_RAM_read][361:360],
		6'b000000,RAM_read_2[query_read_num_RAM_read][353:352],
		6'b000000,RAM_read_2[query_read_num_RAM_read][345:344],
		6'b000000,RAM_read_2[query_read_num_RAM_read][337:336],
		6'b000000,RAM_read_2[query_read_num_RAM_read][329:328],
		6'b000000,RAM_read_2[query_read_num_RAM_read][321:320],
		6'b000000,RAM_read_2[query_read_num_RAM_read][313:312],
		6'b000000,RAM_read_2[query_read_num_RAM_read][305:304],
		6'b000000,RAM_read_2[query_read_num_RAM_read][297:296],
		6'b000000,RAM_read_2[query_read_num_RAM_read][289:288],
		6'b000000,RAM_read_2[query_read_num_RAM_read][281:280],
		6'b000000,RAM_read_2[query_read_num_RAM_read][273:272],
		6'b000000,RAM_read_2[query_read_num_RAM_read][265:264],
		6'b000000,RAM_read_2[query_read_num_RAM_read][257:256],
		6'b000000,RAM_read_2[query_read_num_RAM_read][249:248],
		6'b000000,RAM_read_2[query_read_num_RAM_read][241:240],
		6'b000000,RAM_read_2[query_read_num_RAM_read][233:232],
		6'b000000,RAM_read_2[query_read_num_RAM_read][225:224],
		6'b000000,RAM_read_2[query_read_num_RAM_read][217:216],
		6'b000000,RAM_read_2[query_read_num_RAM_read][209:208],
		6'b000000,RAM_read_2[query_read_num_RAM_read][201:200],
		6'b000000,RAM_read_2[query_read_num_RAM_read][193:192],
		6'b000000,RAM_read_2[query_read_num_RAM_read][185:184],
		6'b000000,RAM_read_2[query_read_num_RAM_read][177:176],
		6'b000000,RAM_read_2[query_read_num_RAM_read][169:168],
		6'b000000,RAM_read_2[query_read_num_RAM_read][161:160],
		6'b000000,RAM_read_2[query_read_num_RAM_read][153:152],
		6'b000000,RAM_read_2[query_read_num_RAM_read][145:144],
		6'b000000,RAM_read_2[query_read_num_RAM_read][137:136],
		6'b000000,RAM_read_2[query_read_num_RAM_read][129:128],
		6'b000000,RAM_read_2[query_read_num_RAM_read][121:120],
		6'b000000,RAM_read_2[query_read_num_RAM_read][113:112],
		6'b000000,RAM_read_2[query_read_num_RAM_read][105:104],
		6'b000000,RAM_read_2[query_read_num_RAM_read][97:96],
		6'b000000,RAM_read_2[query_read_num_RAM_read][89:88],
		6'b000000,RAM_read_2[query_read_num_RAM_read][81:80],
		6'b000000,RAM_read_2[query_read_num_RAM_read][73:72],
		6'b000000,RAM_read_2[query_read_num_RAM_read][65:64],
		6'b000000,RAM_read_2[query_read_num_RAM_read][57:56],
		6'b000000,RAM_read_2[query_read_num_RAM_read][49:48],
		6'b000000,RAM_read_2[query_read_num_RAM_read][41:40],
		6'b000000,RAM_read_2[query_read_num_RAM_read][33:32],
		6'b000000,RAM_read_2[query_read_num_RAM_read][25:24],
		6'b000000,RAM_read_2[query_read_num_RAM_read][17:16],
		6'b000000,RAM_read_2[query_read_num_RAM_read][9:8],
		6'b000000,RAM_read_2[query_read_num_RAM_read][1:0]
	
	};
endmodule
