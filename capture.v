module capture(
	input			clk,
	input			rst_n,
	input			en_capture,
	input			vsync,
	input			href,
	input	 [7:0]din,
	output reg[15:0]dout,
	output		dout_vld,
	output		dout_sop,
	output		dout_eop
);

reg [10:0]h_cnt;
wire add_h_cnt;
wire end_h_cnt;

reg [8:0]v_cnt;
wire add_v_cnt;
wire end_v_cnt;

reg flag_vsync;

//h_cnt
always@(posedge clk or negedge rst_n)begin
	if(!rst_n)
		h_cnt<=0;
	else if(add_h_cnt)begin
		if(end_h_cnt)
			h_cnt<=0;
		else
			h_cnt<=h_cnt+1;
	end
end

assign add_h_cnt=flag_vsync&&href==1;
assign end_h_cnt=add_h_cnt&&h_cnt==1280-1;

//v_cnt
always@(posedge clk or negedge rst_n)begin
	if(!rst_n)
		v_cnt<=0;
	else if(add_v_cnt)begin
		if(end_v_cnt)
			v_cnt<=0;
		else
			v_cnt<=v_cnt+1;
	end
end

assign add_v_cnt=end_h_cnt;
assign end_v_cnt=add_v_cnt&&v_cnt==480-1;

//flag_vsync,can we capture the image now.
always@(posedge clk or negedge rst_n)begin
	if(!rst_n)
		flag_vsync<=0;
	else begin
		if(vsync&&en_capture)
			flag_vsync<=1;
		else if(end_v_cnt)
			flag_vsync<=0;
	end
end

//dout
always@(posedge clk or negedge rst_n)begin
	if(!rst_n)
		dout<=0;
	else begin
		if(flag_vsync&&h_cnt%2==0)begin
			dout[15:11]<=din[7:3];//R
			dout[10:8]<=din[2:0];///G
		end
		else if(flag_vsync&&h_cnt%2==1)begin
			dout[7:5]<=din[7:5];//G
			dout[4:0]<=din[4:0];//B
		end
	end
end

assign dout_vld=flag_vsync&&h_cnt%2==0&&h_cnt!=0;

assign dout_sop=h_cnt==2&&v_cnt==0;

assign dout_eop=end_h_cnt&&end_v_cnt;

endmodule