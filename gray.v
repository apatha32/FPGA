module gray(
	input clk,				
	input rst_n,		 	
	input [15:0]din, 		
	input din_vld, 		
	input din_sop, 	
	input din_eop, 
	output reg [7:0]dout,
	output reg dout_vld, 
	output reg dout_sop, 		
	output reg dout_eop 		
);


reg dout_vld_ff0;
reg dout_sop_ff0;
reg dout_eop_ff0;

reg [7:0]gray_r;
reg [7:0]gray_g;
reg [7:0]gray_b;

// read rgb data from din
always@(posedge clk or negedge rst_n)begin
	if(!rst_n)begin
		gray_r<=0;
		gray_g<=0;
		gray_b<=0;
	end
	else begin
		if(din_vld)begin
			gray_r={din[15:11],3'b000};
			gray_g={din[10:5],2'b00};
			gray_b={din[4:0],3'b000};
		end
	end
end

//dout calculate the gray level based on RGB
always@(posedge clk or negedge rst_n)begin
	if(!rst_n)
		dout<=0;
	else if(din_vld)
		dout<=(gray_r*76 + gray_g*150+ gray_b*30)/256;
end

//dout_vld
always@(posedge clk or negedge rst_n)begin
	if(!rst_n)begin
		dout_vld<=0;
		dout_vld_ff0<=0;
	end
	else begin
		dout_vld_ff0<=din_vld;
		dout_vld<=dout_vld_ff0;
	end
end



//dout_sop
always@(posedge clk or negedge rst_n)begin
	if(!rst_n)begin
		dout_sop<=0;
		dout_sop_ff0<=0;
	end
	else begin
		dout_sop_ff0<=din_sop;
		dout_sop<=dout_sop_ff0;
	end
end

//dout_eop
always@(posedge clk or negedge rst_n)begin
	if(!rst_n)begin
		dout_eop<=0;
		dout_eop_ff0<=0;
	end
	else begin
		dout_eop_ff0<=din_eop;
		dout_eop<=dout_eop_ff0;
	end
end

endmodule 