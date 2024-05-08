module filter(
	input clk, 			//time clock 25M
	input rst_n, 		//rst_signal
	input [7:0]din,	//input gray scale signal
	input din_vld, 	//if the input data is valid
	input din_sop, 	//first input pixel
	input din_eop, 	//last input pixel
	output [7:0]dout, //output data
	output reg dout_vld, 	//check if the data is valid
	output reg dout_sop, 	//first output pixel
	output reg dout_eop 	//first input pixel
);	

wire [7:0]shiftout;
wire [7:0]row1;
wire [7:0]row2;
wire [7:0]row3;

reg [7:0]matrix11;
reg [7:0]matrix12;
reg [7:0]matrix13;

reg [7:0]matrix21;
reg [7:0]matrix22;
reg [7:0]matrix23;

reg [7:0]matrix31;
reg [7:0]matrix32;
reg [7:0]matrix33;

wire [15:0]gs_1;
wire [15:0]gs_2;
wire [15:0]gs_3;

reg dout_vld_ff0;
reg dout_sop_ff0;
reg dout_eop_ff0;

shift_ram my_shift_ram(
	.clken			(din_vld),
	.clock			(clk),
	.shiftin			(din),
	.shiftout		(shiftout),
	.taps0x			(row3),
	.taps1x			(row2),
	.taps2x			(row1)
);

always@(posedge clk or negedge rst_n)begin
	if(!rst_n) begin
		matrix11<=0;
		matrix12<=0;
		matrix13<=0;
		
		matrix21<=0;
		matrix22<=0;
		matrix23<=0;
		
		matrix31<=0;
		matrix32<=0;
		matrix33<=0;
	end
	else begin
		if(din_vld)begin
			matrix11<=matrix12;
			matrix12<=matrix13;
			matrix13<=row1;
			
			matrix21<=matrix22;
			matrix22<=matrix23;
			matrix23<=row2;
			
			matrix31<=matrix32;
			matrix32<=matrix33;
			matrix33<=row3;
		end
	end
end

//computation
assign gs_1=matrix11*1+matrix12*2+matrix13*1;
assign gs_2=matrix21*2+matrix22*4+matrix23*2;
assign gs_3=matrix31*1+matrix32*2+matrix33*1;
assign dout=(gs_1+gs_2+gs_3)/16;

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