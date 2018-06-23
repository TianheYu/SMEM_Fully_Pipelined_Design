//==========================================
// Function : Asynchronous FIFO (w/ 2 asynchronous clocks).
// Coder    : Alex Claros F.
// Date     : 15/May/2005.
// Notes    : This implementation is based on the article 
//            'Asynchronous FIFO in Virtex-II FPGAs'
//            writen by Peter Alfke. This TechXclusive 
//            article can be downloaded from the
//            Xilinx website. It has some minor modifications.
//=========================================

`define CL 512
`define MAX_READ 1024
`define READ_NUM_WIDTH 10

module aFIFO
  #(parameter    DATA_WIDTH    = 65,
                 ADDRESS_WIDTH = 2,
                 FIFO_DEPTH    = (1 << ADDRESS_WIDTH))
     //Reading port
    (output reg  [DATA_WIDTH-1:0]        Data_out, 
	 output reg  						 Data_valid,
     output                          Empty_out,
     input wire                          ReadEn_in,
     input wire                          RClk,        
     //Writing port.	 
     input wire  [DATA_WIDTH-1:0]        Data_in,  
     output reg                          Full_out,
     input wire                          WriteEn_in,
     input wire                          WClk,
	 
     input wire                          Clear_in);

    /////Internal connections & variables//////
    (* ramstyle = "logic" *) reg   [DATA_WIDTH-1:0]              Mem [FIFO_DEPTH-1:0];
    wire  [ADDRESS_WIDTH-1:0]           pNextWordToWrite, pNextWordToRead;
    wire                                EqualAddresses;
    wire                                NextWriteAddressEn, NextReadAddressEn;
    wire                                Set_Status, Rst_Status;
    reg                                 Status;
    wire                                PresetFull, PresetEmpty;
    // reg                                PresetFull_q, PresetEmpty_q;
	
	// always@(posedge )
    //////////////Code///////////////
    //Data ports logic:
    //(Uses a dual-port RAM).
    //'Data_out' logic:
    always @ (posedge RClk) begin
		if(Clear_in) begin
			Data_valid <= 0;
		
		end
		else begin
			Data_out <= Mem[pNextWordToRead];
			if (ReadEn_in & !Empty_out) begin
				Data_valid <= 1;
			end
			else begin
				Data_valid <= 0;
			end
		end
	end
			//'Data_in' logic:
    always @ (posedge WClk)
        if (WriteEn_in)
            Mem[pNextWordToWrite] <= Data_in;

    //Fifo addresses support logic: 
    //'Next Addresses' enable logic:
    assign NextWriteAddressEn = WriteEn_in;
    assign NextReadAddressEn  = ReadEn_in  & ~Empty_out;
           
    //Addreses (Gray counters) logic:
    GrayCounter #(.COUNTER_WIDTH(ADDRESS_WIDTH)) GrayCounter_pWr
       (.GrayCount_out(pNextWordToWrite),
       
        .Enable_in(NextWriteAddressEn),
        .Clear_in(Clear_in),
        
        .Clk(WClk)
       );
       
    GrayCounter #(.COUNTER_WIDTH(ADDRESS_WIDTH))GrayCounter_pRd
       (.GrayCount_out(pNextWordToRead),
        .Enable_in(NextReadAddressEn),
        .Clear_in(Clear_in),
        .Clk(RClk)
       );
     

    //'EqualAddresses' logic:
    assign EqualAddresses = (pNextWordToWrite == pNextWordToRead);
            
    //'Full_out' logic for the writing port:
    assign PresetFull = EqualAddresses;  //'Full' Fifo.
	    
	// always @ (posedge WClk  or posedge PresetFull) begin  
	// [licheng] never use full out
	always @(posedge WClk) begin
		if(Clear_in) begin
			Full_out <= 0;
		end
    end       
	
    //'Empty_out' logic for the reading port:

	assign Empty_out = EqualAddresses;
	


            
endmodule

module aFIFO_output
  #(parameter    DATA_WIDTH    = 65,
                 ADDRESS_WIDTH = 2,
                 FIFO_DEPTH    = (1 << ADDRESS_WIDTH))
     //Reading port
    (input stall,
	 output reg  [DATA_WIDTH-1:0]        Data_out, 
	 output reg  						 Data_valid,
     output                          Empty_out,
     input wire                          ReadEn_in,
     input wire                          RClk,        
     //Writing port.	 
     input wire  [DATA_WIDTH-1:0]        Data_in,  
     output reg                          Full_out,
     input wire                          WriteEn_in,
     input wire                          WClk,
	 
     input wire                          Clear_in);

    /////Internal connections & variables//////
    (* ramstyle = "logic" *) reg   [DATA_WIDTH-1:0]              Mem [FIFO_DEPTH-1:0];
    wire  [ADDRESS_WIDTH-1:0]           pNextWordToWrite, pNextWordToRead;
    wire                                EqualAddresses;
    wire                                NextWriteAddressEn, NextReadAddressEn;
    wire                                Set_Status, Rst_Status;
    reg                                 Status;
    wire                                PresetFull, PresetEmpty;
    // reg                                PresetFull_q, PresetEmpty_q;
	
	// always@(posedge )
    //////////////Code///////////////
    //Data ports logic:
    //(Uses a dual-port RAM).
    //'Data_out' logic:
    always @ (posedge RClk) begin
		if(Clear_in) begin
			Data_valid <= 0;
		
		end
		else begin
			Data_out <= Mem[pNextWordToRead];
			if ((!stall) & (!Empty_out)) begin
				Data_valid <= 1;
			end
			else begin
				Data_valid <= 0;
			end
		end
	end
			//'Data_in' logic:
    always @ (posedge WClk)
        if (WriteEn_in)
            Mem[pNextWordToWrite] <= Data_in;

    //Fifo addresses support logic: 
    //'Next Addresses' enable logic:
    assign NextWriteAddressEn = (!stall)  & WriteEn_in;
    assign NextReadAddressEn  = (!stall)  & (~Empty_out);
           
    //Addreses (Gray counters) logic:
    GrayCounter #(.COUNTER_WIDTH(ADDRESS_WIDTH)) GrayCounter_pWr
       (.GrayCount_out(pNextWordToWrite),
       
        .Enable_in(NextWriteAddressEn),
        .Clear_in(Clear_in),
        
        .Clk(WClk)
       );
       
    GrayCounter #(.COUNTER_WIDTH(ADDRESS_WIDTH)) GrayCounter_pRd
       (.GrayCount_out(pNextWordToRead),
        .Enable_in(NextReadAddressEn),
        .Clear_in(Clear_in),
        .Clk(RClk)
       );
     

    //'EqualAddresses' logic:
    assign EqualAddresses = (pNextWordToWrite == pNextWordToRead);
            
    //'Full_out' logic for the writing port:
    assign PresetFull = EqualAddresses;  //'Full' Fifo.
	    
	// always @ (posedge WClk  or posedge PresetFull) begin  
	// [licheng] never use full out
	always @(posedge WClk) begin
		if(Clear_in) begin
			Full_out <= 0;
		end
    end       
	
    //'Empty_out' logic for the reading port:

	assign Empty_out = EqualAddresses;
	


            
endmodule


//write 2 entries at a time
module aFIFO_2w_1r
  #(parameter    DATA_WIDTH    = 65,
                 ADDRESS_WIDTH = 2,
                 FIFO_DEPTH    = (1 << ADDRESS_WIDTH))
     //Reading port
    (input stall,
	 output reg  [DATA_WIDTH-1:0]        Data_out, 
	 output reg  						 Data_valid,
     output                           	 Empty_out,
     input wire                          ReadEn_in,
     input wire                          RClk,        
     //Writing port.	 
     input wire  [DATA_WIDTH-1:0]        Data_in_1,
	 input wire  [DATA_WIDTH-1:0]        Data_in_2,
     output		                         Full_out,
     // input wire                          WriteEn_in_1,
	 input wire                          WriteEn_in_2,
     input wire                          WClk,
	 
     input wire                          Clear_in);

    /////Internal connections & variables//////
    (* ramstyle = "logic" *) reg   [DATA_WIDTH-1:0]              Mem [FIFO_DEPTH-1:0];
    wire  [ADDRESS_WIDTH-1:0]           pNextWordToWrite_1, pNextWordToWrite_2, pNextWordToRead;
    wire                                EqualAddresses;
    wire                                NextWriteAddressEn_2, NextReadAddressEn;
    wire                                Set_Status, Rst_Status;
    reg                                 Status;
    wire                                PresetFull, PresetEmpty;
    // reg                                PresetFull_q, PresetEmpty_q;
	
	// always@(posedge )
    //////////////Code///////////////
    //Data ports logic:
    //(Uses a dual-port RAM).
    //'Data_out' logic:
    always @ (posedge RClk) begin
		if(Clear_in) begin
			Data_valid <= 0;
		
		end
		else begin
			Data_out <= Mem[pNextWordToRead];
			if ((!stall) & (!Empty_out)) begin
				Data_valid <= 1;
			end
			else begin
				Data_valid <= 0;
			end
		end
	end
			//'Data_in' logic:
    always @ (posedge WClk) begin
		if (WriteEn_in_2) begin
			Mem[pNextWordToWrite_1] <= Data_in_1;
			Mem[pNextWordToWrite_2] <= Data_in_2;	
		end
	end	
	
    //Fifo addresses support logic: 
    //'Next Addresses' enable logic:
	assign NextWriteAddressEn_2 = (!stall)  & WriteEn_in_2;
    assign NextReadAddressEn  = (!stall)  & (~Empty_out);
           
    //Addreses (Gray counters) logic:
    GrayCounter_2port #(.COUNTER_WIDTH(ADDRESS_WIDTH)) GrayCounter_pWr_2port
       (.GrayCount_out_1(pNextWordToWrite_1),
		.GrayCount_out_2(pNextWordToWrite_2), //always provides the next two wr addresses
		
		.Enable_in_2(NextWriteAddressEn_2),
		
        .Clear_in(Clear_in),
        .Clk(WClk)
       );
       
    GrayCounter #(.COUNTER_WIDTH(ADDRESS_WIDTH)) GrayCounter_pRd
       (.GrayCount_out(pNextWordToRead),
        .Enable_in(NextReadAddressEn),
        .Clear_in(Clear_in),
        .Clk(RClk)
       );
     

    //'EqualAddresses' logic:
    assign EqualAddresses = (pNextWordToWrite_1 == pNextWordToRead);

            
    //'Full_out' logic for the writing port:
	assign Full_out = 1'b0;  
	
    //'Empty_out' logic for the reading port:
	assign Empty_out = EqualAddresses;
	
            
endmodule

module GrayCounter_2port
	#(parameter   COUNTER_WIDTH = 4)(
	
	output reg  [COUNTER_WIDTH-1:0]    GrayCount_out_1,  //'Gray' code count output.
	output reg  [COUNTER_WIDTH-1:0]    GrayCount_out_2,  //'Gray' code count output.
	input wire                         Enable_in_2,  //Count enable.
	input wire                         Clear_in,   //Count reset.

	input wire                         Clk
);

    /////////Internal connections & variables///////
    reg    [COUNTER_WIDTH-1:0]         BinaryCount, BinaryCount_add1;
    /////////Code///////////////////////
    
    always @ (posedge Clk) begin
        if (Clear_in) begin
            BinaryCount   <= 2;  //Gray count begins @ '1' with
			BinaryCount_add1 <= 3;
            GrayCount_out_1 <= 0;      // first 'Enable_in'.
			GrayCount_out_2 <= 1;
        end
        else if (Enable_in_2) begin
            BinaryCount   <= BinaryCount + 2;
			BinaryCount_add1   <= BinaryCount_add1 + 2;
			
            GrayCount_out_1 <= BinaryCount;
			GrayCount_out_2 <= BinaryCount_add1;				
        end
    end
endmodule


//==========================================
// Function : Code Gray counter.
// Coder    : Alex Claros F.
// Date     : 15/May/2005.
//=======================================

module GrayCounter
   #(parameter   COUNTER_WIDTH = 4)
   
    (output reg  [COUNTER_WIDTH-1:0]    GrayCount_out,  //'Gray' code count output.
    
     input wire                         Enable_in,  //Count enable.
     input wire                         Clear_in,   //Count reset.
    
     input wire                         Clk);

    /////////Internal connections & variables///////
    reg    [COUNTER_WIDTH-1:0]         BinaryCount;

    /////////Code///////////////////////
    
    always @ (posedge Clk)
        if (Clear_in) begin
            BinaryCount   <= 1;  //Gray count begins @ '1' with
            GrayCount_out <= 0;      // first 'Enable_in'.
        end
        else if (Enable_in) begin
            BinaryCount   <= BinaryCount + 1;
            GrayCount_out <= BinaryCount;
        end
    
endmodule