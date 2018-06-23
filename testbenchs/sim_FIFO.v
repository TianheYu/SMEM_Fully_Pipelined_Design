
module sim_aFIFO_2w_1r
 #(parameter    DATA_WIDTH    = 8,
                 ADDRESS_WIDTH = 4,
                 FIFO_DEPTH    = (1 << ADDRESS_WIDTH))();

	wire  [DATA_WIDTH-1:0]       Data_out; 
	wire  						 Data_valid;
	wire                         Empty_out;
	reg                          ReadEn_in;
	reg                          RClk;        
	//Writing port.	 
	reg  [DATA_WIDTH-1:0]        Data_in_1;
	reg  [DATA_WIDTH-1:0]        Data_in_2;
	wire		                 Full_out;
	// input wire                          WriteEn_in_1;
	reg                          WriteEn_in_2;
	reg                          WClk;

	reg                          Clear_in;
	
	
	aFIFO_2w_1r  #(.DATA_WIDTH(DATA_WIDTH), .ADDRESS_WIDTH(ADDRESS_WIDTH)) uut(
		.Data_out(Data_out), 
		.Data_valid(Data_valid),
		.Empty_out(Empty_out),
		.ReadEn_in(ReadEn_in),
		.RClk(RClk),        
		//Writing port.	 
		.Data_in_1(Data_in_1),
		.Data_in_2(Data_in_2),
		.Full_out(Full_out),
		// input wire                          WriteEn_in_1,
		.WriteEn_in_2(WriteEn_in_2),
		.WClk(WClk),

		.Clear_in(Clear_in)
	);
	
	always #2.5 RClk = ~RClk;
	always #5	WClk = ~WClk;
	
	initial begin

		ReadEn_in = 0;
		RClk = 1;        
		//Writing port.	 
		Data_in_1 = 0;
		Data_in_2 = 0;

		// input wire                          WriteEn_in_1;
		WriteEn_in_2 = 0;
		WClk = 1;

		Clear_in = 1;
		
		#20;
		
		Clear_in = 0;
		ReadEn_in = 1;
		
		#20;
	
		WriteEn_in_2 = 1;
		Data_in_1 = 1;
		Data_in_2 = 2;
				
		#10
		
		Data_in_1 = 3;
		Data_in_2 = 4;
		
				#10
		
		Data_in_1 = 5;
		Data_in_2 = 6;
		
				#10
		
		Data_in_1 = 7;
		Data_in_2 = 8;
		
				#10
		
		Data_in_1 = 9;
		Data_in_2 = 10;
		
		#10
		
		Data_in_1 = 11;
		Data_in_2 = 12;
		
		#10
		
		Data_in_1 = 13;
		Data_in_2 = 14;
		
		#10
		
		Data_in_1 = 15;
		Data_in_2 = 16;
		
		#10
		
		Data_in_1 = 17;
		Data_in_2 = 18;
		
		#10
		
		Data_in_1 = 19;
		Data_in_2 = 20;
		
		#10
		
		Data_in_1 = 19;
		Data_in_2 = 20;
		
		#10
		
		Data_in_1 = 19;
		Data_in_2 = 20;
		
		#10
		
		Data_in_1 = 19;
		Data_in_2 = 20;
		
		#10
		
		Data_in_1 = 19;
		Data_in_2 = 20;
		
		#10
		
		Data_in_1 = 19;
		Data_in_2 = 20;
		
		#10
		
		Data_in_1 = 19;
		Data_in_2 = 20;
		
		#10
		
		Data_in_1 = 19;
		Data_in_2 = 20;
		
		#10
		
		Data_in_1 = 19;
		Data_in_2 = 20;
		
		#10
		
		Data_in_1 = 19;
		Data_in_2 = 20;
		
		#10
		
		Data_in_1 = 19;
		Data_in_2 = 20;
		
		#10
		
		Data_in_1 = 19;
		Data_in_2 = 20;
		
		#10
		
		Data_in_1 = 19;
		Data_in_2 = 20;
		
		#10
		
		Data_in_1 = 19;
		Data_in_2 = 20;
		
		#10
		
		Data_in_1 = 19;
		Data_in_2 = 20;
		
		#10
		
		Data_in_1 = 19;
		Data_in_2 = 20;
		
		#10
		
		Data_in_1 = 19;
		Data_in_2 = 20;
		
		#10
		
		Data_in_1 = 19;
		Data_in_2 = 20;
		
		#10
		
		Data_in_1 = 19;
		Data_in_2 = 20;
		
		#10
		
		Data_in_1 = 19;
		Data_in_2 = 20;
		
		#10
		
		Data_in_1 = 19;
		Data_in_2 = 20;
		
		#10
		
		Data_in_1 = 19;
		Data_in_2 = 20;
		
		#10
		
		Data_in_1 = 19;
		Data_in_2 = 20;
		
		#10
		
		Data_in_1 = 19;
		Data_in_2 = 20;
		
		#10
		
		Data_in_1 = 19;
		Data_in_2 = 20;
		
		#10
		
		Data_in_1 = 19;
		Data_in_2 = 20;
		
		#10
		
		Data_in_1 = 19;
		Data_in_2 = 20;
		
		#10
		
		Data_in_1 = 19;
		Data_in_2 = 20;
		
		#10
		
		Data_in_1 = 19;
		Data_in_2 = 20;
		
		#10
		
		Data_in_1 = 19;
		Data_in_2 = 20;
		
		#10
		
		Data_in_1 = 19;
		Data_in_2 = 20;
		
		#10
		
		Data_in_1 = 19;
		Data_in_2 = 20;
		
		#10
		
		Data_in_1 = 19;
		Data_in_2 = 20;
		
		#10
		
		Data_in_1 = 19;
		Data_in_2 = 20;
		
		#10
		
		Data_in_1 = 19;
		Data_in_2 = 20;
		
		#10
		
		Data_in_1 = 19;
		Data_in_2 = 20;
		
		#10
		
		Data_in_1 = 19;
		Data_in_2 = 20;
		
		#10
		
		Data_in_1 = 19;
		Data_in_2 = 20;
		
		#10
		
		Data_in_1 = 19;
		Data_in_2 = 20;
		
		#10
		
		Data_in_1 = 19;
		Data_in_2 = 20;
		
		#10
		
		Data_in_1 = 19;
		Data_in_2 = 20;
		
		#10
		
		Data_in_1 = 19;
		Data_in_2 = 20;
		
		#10
		
		Data_in_1 = 19;
		Data_in_2 = 20;
		
		#10
		
		Data_in_1 = 19;
		Data_in_2 = 20;
		
		#10
		
		Data_in_1 = 19;
		Data_in_2 = 20;
		
		#10
		
		Data_in_1 = 19;
		Data_in_2 = 20;
		
		#10
		
		Data_in_1 = 19;
		Data_in_2 = 20;
		
		#10
		
		Data_in_1 = 19;
		Data_in_2 = 20;
		
		#10
		
		Data_in_1 = 19;
		Data_in_2 = 20;
		
		#10
		
		Data_in_1 = 19;
		Data_in_2 = 20;
		
		#10
		
		Data_in_1 = 19;
		Data_in_2 = 20;
		
		#10
		
		Data_in_1 = 19;
		Data_in_2 = 20;
		
		#10
		
		Data_in_1 = 19;
		Data_in_2 = 20;
		
		#10
		
		Data_in_1 = 19;
		Data_in_2 = 20;
		
		#10
		
		Data_in_1 = 19;
		Data_in_2 = 20;
		
		#10
		
		Data_in_1 = 19;
		Data_in_2 = 20;
		
		#10
		
		Data_in_1 = 19;
		Data_in_2 = 20;
		
		#10
		
		Data_in_1 = 19;
		Data_in_2 = 20;
		
		#10
		
		Data_in_1 = 19;
		Data_in_2 = 20;
		
		#10
		
		Data_in_1 = 19;
		Data_in_2 = 20;
		
		#10
		
		Data_in_1 = 19;
		Data_in_2 = 20;
		
		#10
		
		Data_in_1 = 19;
		Data_in_2 = 20;
		
		#10
		
		Data_in_1 = 19;
		Data_in_2 = 20;
		
		#10
		
		Data_in_1 = 19;
		Data_in_2 = 20;
		
		#10
		
		Data_in_1 = 19;
		Data_in_2 = 20;
		
		#10
		
		Data_in_1 = 19;
		Data_in_2 = 20;
		
		#10
		
		Data_in_1 = 19;
		Data_in_2 = 20;
		
		#10
		
		Data_in_1 = 19;
		Data_in_2 = 20;
		
		#10
		
		Data_in_1 = 19;
		Data_in_2 = 20;
		
		#10
		
		Data_in_1 = 19;
		Data_in_2 = 20;
		
		#10
		
		Data_in_1 = 19;
		Data_in_2 = 20;
		
		#10
		
		Data_in_1 = 19;
		Data_in_2 = 20;
		
		#10
		
		Data_in_1 = 19;
		Data_in_2 = 20;
		
		#10
		
		Data_in_1 = 19;
		Data_in_2 = 20;
		
		#10
		
		Data_in_1 = 19;
		Data_in_2 = 20;
		
		#10
		
		Data_in_1 = 19;
		Data_in_2 = 20;
		
		#10
		
		Data_in_1 = 19;
		Data_in_2 = 20;
		
		#10
		
		Data_in_1 = 19;
		Data_in_2 = 20;
		
		#10
		
		Data_in_1 = 19;
		Data_in_2 = 20;
		
		#10
		
		Data_in_1 = 19;
		Data_in_2 = 20;
		
		#10
		
		Data_in_1 = 19;
		Data_in_2 = 20;
		
		#10
		
		Data_in_1 = 19;
		Data_in_2 = 20;
		
		#10
		
		Data_in_1 = 19;
		Data_in_2 = 20;
		
		#10
		
		Data_in_1 = 19;
		Data_in_2 = 20;
		
		#10
		
		Data_in_1 = 19;
		Data_in_2 = 20;
		
		#10
		
		Data_in_1 = 19;
		Data_in_2 = 20;
		
		#10
		
		Data_in_1 = 19;
		Data_in_2 = 20;
		
		#10
		
		Data_in_1 = 19;
		Data_in_2 = 20;
		
		#10
		
		Data_in_1 = 19;
		Data_in_2 = 20;
		
		#10
		
		Data_in_1 = 19;
		Data_in_2 = 20;
		
		#10
		
		Data_in_1 = 19;
		Data_in_2 = 20;
		
		#10
		
		Data_in_1 = 19;
		Data_in_2 = 20;
		
		#10
		
		Data_in_1 = 19;
		Data_in_2 = 20;
		
		#10
		
		Data_in_1 = 19;
		Data_in_2 = 20;
		
		#10
		
		Data_in_1 = 19;
		Data_in_2 = 20;
		
		#10
		
		Data_in_1 = 19;
		Data_in_2 = 20;
		
		#10
		
		Data_in_1 = 19;
		Data_in_2 = 20;
		
		#10
		
		Data_in_1 = 19;
		Data_in_2 = 20;
		
		#10
		
		Data_in_1 = 19;
		Data_in_2 = 20;
		
		#10
		
		Data_in_1 = 19;
		Data_in_2 = 20;
		
		#10
		
		Data_in_1 = 19;
		Data_in_2 = 20;
		
		#10
		
		Data_in_1 = 19;
		Data_in_2 = 20;
		
		#10
		
		Data_in_1 = 19;
		Data_in_2 = 20;
		
		#10
		
		Data_in_1 = 19;
		Data_in_2 = 20;
		
		#10
		
		Data_in_1 = 19;
		Data_in_2 = 20;
		
		#10
		
		Data_in_1 = 19;
		Data_in_2 = 20;
		
		#10
		
		Data_in_1 = 19;
		Data_in_2 = 20;
		
		#10
		
		Data_in_1 = 19;
		Data_in_2 = 20;
		
		#10
		
		Data_in_1 = 19;
		Data_in_2 = 20;
		
		#10
		
		Data_in_1 = 19;
		Data_in_2 = 20;
		
		#10
		
		Data_in_1 = 19;
		Data_in_2 = 20;
		
		#10
		
		Data_in_1 = 19;
		Data_in_2 = 20;
		
		#10
		
		Data_in_1 = 19;
		Data_in_2 = 20;
		
		#10
		
		Data_in_1 = 19;
		Data_in_2 = 20;
		
		#10
		
		Data_in_1 = 19;
		Data_in_2 = 20;
		
		#10
		
		Data_in_1 = 19;
		Data_in_2 = 20;
		
		#10
		
		Data_in_1 = 19;
		Data_in_2 = 20;
		
		#10
		
		Data_in_1 = 19;
		Data_in_2 = 20;
		
		#10
		
		Data_in_1 = 19;
		Data_in_2 = 20;
		
		#10
		
		Data_in_1 = 19;
		Data_in_2 = 20;
		
		#10
		
		Data_in_1 = 19;
		Data_in_2 = 20;
		
		#10
		
		Data_in_1 = 19;
		Data_in_2 = 20;
		
		#10
		
		Data_in_1 = 19;
		Data_in_2 = 20;
		
		#10
		
		Data_in_1 = 19;
		Data_in_2 = 20;
		
		
		#10
		
		WriteEn_in_2 = 0;
			
		#20;
		
		$finish;
	end
endmodule
	