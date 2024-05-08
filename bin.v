module bin( 
    input				clk,			//clk
    input				rst_n,		//reset 
    input		[7:0]	gus_din,		//8bits from gaussian filter
    input		      gus_valid,	//is the input valid?
	 input				gus_sop, // first input
	 input				gus_eop,// last input
    output	         bin_dout,	//binary output
    output	   reg   bin_valid,  	//is the output valid?
	 output		reg   bin_sop, // fist output
	 output		reg   bin_eop //last output
);		

parameter bin_threshold=7'd127;// the threshold 


reg dout_vld_ff0;
reg dout_sop_ff0;
reg dout_eop_ff0;
    //bin_dout:二值化输出
assign bin_dout = (gus_din > bin_threshold)?1'b1:1'b0;


//dout_vld
always@(posedge clk or negedge rst_n)begin
	if(!rst_n)begin
		bin_valid<=0;
		dout_vld_ff0<=0;
	end
	else begin
		dout_vld_ff0<=gus_valid;
		bin_valid<=dout_vld_ff0;
	end
end

//dout_sop
always@(posedge clk or negedge rst_n)begin
	if(!rst_n)begin
		bin_sop<=0;
		dout_sop_ff0<=0;
	end
	else begin
		dout_sop_ff0<=gus_sop;
		bin_sop<=dout_sop_ff0;
	end
end

//dout_eop
always@(posedge clk or negedge rst_n)begin
	if(!rst_n)begin
		bin_eop<=0;
		dout_eop_ff0<=0;
	end
	else begin
		dout_eop_ff0<=gus_eop;
		bin_eop<=dout_eop_ff0;
	end
end
                        
endmodule
