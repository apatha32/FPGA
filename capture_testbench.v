`timescale 1ns/1ns

module capture_testbench();

//输入信号
reg		clk;
reg		rst_n;
reg		en_capture;
reg		vsync;
reg		href;
reg [7:0]din;
integer file;   // File handle

parameter CYCLE = 20;

//rst
parameter RST_TIME = 3;

wire [15:0]dout_capture;
wire		  dout_vld_capture;
wire		  dout_sop_capture;
wire		  dout_eop_capture;

wire [7:0]dout_gray;
wire   	  dout_vld_gray; 
wire   	  dout_sop_gray; 
wire   	  dout_eop_gray;	

wire  [7:0]dout_filter;
wire   	  dout_vld_filter; 
wire   	  dout_sop_filter; 
wire   	  dout_eop_filter;	

wire  	  dout_bin;
wire   	  dout_vld_bin; 
wire   	  dout_sop_bin; 
wire   	  dout_eop_bin;

wire  	  dout_sobel;
wire   	  dout_vld_sobel; 
wire   	  dout_sop_sobel; 
wire   	  dout_eop_sobel;


//待测试模块的例化
capture i1(
	.clk			(clk			),
	.rst_n			(rst_n		),
	.en_capture	(en_capture	),
	.vsync			(vsync		),
	.href			(href			),		
	.din			(din			),
	.dout			(dout_capture		),
	.dout_vld		(dout_vld_capture	),
	.dout_sop		(dout_sop_capture	),
	.dout_eop		(dout_eop_capture	)
);

gray i2(
	.clk			(clk		),				
	.rst_n			(rst_n	),		 	
	.din			(dout_capture		), 
	.din_vld		(dout_vld_capture	), 
	.din_sop		(dout_sop_capture	), 
	.din_eop		(dout_eop_capture	), 
	.dout			(dout_gray			),		
	.dout_vld		(dout_vld_gray		), 		
	.dout_sop		(dout_sop_gray		), 	
	.dout_eop		(dout_eop_gray		) 	
);

filter i3(
	.clk				(clk		),				
	.rst_n			(rst_n	),		 	
	.din				(dout_gray		), 
	.din_vld			(dout_vld_gray	), 
	.din_sop			(dout_sop_gray	), 
	.din_eop			(dout_eop_gray	), 
	.dout				(dout_filter			),		
	.dout_vld		(dout_vld_filter		), 		
	.dout_sop		(dout_sop_filter		), 	
	.dout_eop		(dout_eop_filter		) 	
);

bin i4( 
    .clk				(clk			),			//pclk
    .rst_n			(rst_n		),		//复位信号
    .gus_din		(dout_filter	),		//高斯滤波输入
    .gus_valid		(dout_vld_filter	),	//高斯滤波输入有效标志
    .gus_eop		(dout_eop_filter),
	 .gus_sop		(dout_sop_filter),
    .bin_dout		(dout_bin	),	//二值化输出
    .bin_valid 	(dout_vld_bin), 	//二值化输出有效标志
	 .bin_sop		(dout_sop_bin),
	 .bin_eop		(dout_eop_bin)
);	

sobel i5(
	.clk				(clk		),				
	.rst_n			(rst_n	),		 	
	.din				(dout_bin		), 
	.din_vld			(dout_vld_bin	), 
	.din_sop			(dout_sop_bin	), 
	.din_eop			(dout_eop_bin	), 
	.dout				(dout_sobel			),		
	.dout_vld		(dout_vld_sobel	), 		
	.dout_sop		(dout_sop_sobel	), 	
	.dout_eop		(dout_eop_sobel	) 	
);


//生成本地时钟：50M
initial begin
	clk=0;
	forever
	#(CYCLE/2)
	clk=~clk;
end

//生成复位信号
initial begin
	rst_n=1;
	#2;
	rst_n=0;
	#(CYCLE*RST_TIME);
	rst_n=1;
end

//生成en信号
initial begin
	en_capture=1;
	#2;
	en_capture=0;
	#(CYCLE*RST_TIME);
	#CYCLE
	en_capture=1;
end

//din
//initial begin
//	 #1
//	 din=0;
//	 #(CYCLE*RST_TIME);
//	 #(CYCLE*10);
//	 din=8'b00000001;
//	 repeat(307200) begin
//	 #CYCLE	 
//    din<= {$random()}%256;        
//    end
//    #100 $stop;
//end

initial begin
	#1;
	din=0;
	file = $fopen("D:/Myproject/ECE465/input.bin", "rb");
	if (file == 0) begin
		$display("Error: Could not open input.bin file");
		$finish;
	end
	#(CYCLE*RST_TIME);
	#(CYCLE*10);
	din=8'b00000001;
	// Read data from the file
	repeat (480) begin
	repeat (1280)begin
	#CYCLE
	$fread(din,file); // Read 8-bit data from the file
	end
	#(288*CYCLE);
	end
	// Close the file
	$fclose(file);

	// Stop simulation after reading all data
	#100 $stop;
end

//vsync
initial begin
	#1;
	//赋初值
	vsync = 0;
	#(CYCLE*RST_TIME);
	//开始赋值
	#(CYCLE*5);	
	vsync = 1;
	#(CYCLE);
	vsync = 0;
end

//href
initial begin
	#1;
	//赋初值
	href = 0;
	#(CYCLE*RST_TIME);
	//开始赋值
	#(CYCLE*9+1);		
	repeat(480) begin
	href = 1;
	#(1280*CYCLE);
	href = 0;
	#(288*CYCLE);
	end
end




integer output_cap; 
integer output_gray;
integer output_filter;
integer output_bin;
integer output_sobel;


initial output_cap = $fopen("D:/Myproject/ECE465/capture_out.txt");//win系统下文件保存路径示例
always@(posedge dout_vld_capture) begin//仅在valid_flag变化的情况下才将wr_txt写入文件
	$fwrite(output_cap,"%h\n",dout_capture);// %h 十六进制保存，\n：换行符
end

initial output_gray = $fopen("D:/Myproject/ECE465/gray_out.txt");
always@(posedge dout_vld_gray) begin
	$fwrite(output_gray,"%h\n",dout_gray);
end

initial output_filter = $fopen("D:/Myproject/ECE465/filter_out.txt");
always@(posedge dout_vld_filter) begin
	$fwrite(output_filter,"%h\n",dout_filter);
end

initial output_bin = $fopen("D:/Myproject/ECE465/bin_out.txt");
always@(posedge dout_vld_filter) begin
	$fwrite(output_bin,"%h\n",dout_bin);
end

initial output_sobel = $fopen("D:/Myproject/ECE465/sobel_out.txt");
always@(posedge dout_vld_filter) begin
	$fwrite(output_sobel,"%h\n",dout_sobel);
end

endmodule