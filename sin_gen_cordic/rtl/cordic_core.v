module cordic_core (
    input                   clk,
    input                   rst_n,
    input  [7:0]            phi,    // 输入相位 0-255 对应 0-2pi [cite: 3]
    output reg signed [15:0] sin,
    output reg signed [15:0] cos
);

    // --- 1. 象限判断与相位映射 ---
    // 总延迟对齐：映射(1拍) + 初始赋值(1拍) + 迭代(16拍) = 18拍延迟
    reg signed [7:0]  phi_mapped;    // [cite: 4]
    reg [1:0]         quadrant_d [0:18]; 
    integer i;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            phi_mapped <= 8'd0;      // [cite: 6]
            quadrant_d[0] <= 2'b00;  // [cite: 7]
        end else begin
            quadrant_d[0] <= phi[7:6];  // 高两位提取象限 [cite: 7]
             case (phi[7:6])         // [cite: 8]
                2'b00: phi_mapped <= phi[5:0];           // 第1象限 [cite: 8]
                2'b01: phi_mapped <= 8'd64 - phi[5:0];   // 第2象限 [cite: 9]
                2'b10: phi_mapped <= phi[5:0];           // 第3象限 [cite: 9]
                2'b11: phi_mapped <= 8'd64 - phi[5:0];   // 第4象限 [cite: 9]
                default: phi_mapped <= 8'd0;             // [cite: 10]
            endcase
        end
    end

    // --- 2. CORDIC 迭代逻辑 (19位内部位宽) ---
    reg signed [18:0] x [0:16];      // [cite: 10]
    reg signed [18:0] y [0:16];      // [cite: 11]
    reg signed [7:0]  z [0:16];      // [cite: 11]

     // 8位量化下的 arctan 常数表 [cite: 12]
    wire [7:0] atan_table [0:15];
    assign atan_table[0]=8'd32; assign atan_table[1]=8'd19; assign atan_table[2]=8'd10; 
    assign atan_table[3]=8'd5;  assign atan_table[4]=8'd3;  assign atan_table[5]=8'd1;
    assign atan_table[6]=8'd1;  assign atan_table[7]=8'd0;  assign atan_table[8]=8'd0;
    assign atan_table[9]=8'd0;  assign atan_table[10]=8'd0; assign atan_table[11]=8'd0;
    assign atan_table[12]=8'd0; assign atan_table[13]=8'd0; assign atan_table[14]=8'd0;
    assign atan_table[15]=8'd0;  // [cite: 13]

    // 初始矢量赋值 (占用 1 拍)
    always @(posedge clk) begin
        x[0] <= {16'd19899, 3'b000};  // 增益补偿 0.60725 * 2^15 并左移对齐 [cite: 13]
        y[0] <= 19'd0;                // [cite: 14]
        z[0] <= phi_mapped;           // [cite: 14]
        
        // 象限信息随数据流同步移动
        for (i=1; i<=18; i=i+1) quadrant_d[i] <= quadrant_d[i-1];  // [cite: 14]
    end

     // 16 级流水线迭代 (占用 16 拍) [cite: 15]
    genvar k;
    generate
        for (k=0; k<16; k=k+1) begin : cordic_pipeline
            always @(posedge clk) begin
                if (z[k] >= 0) begin
                    x[k+1] <= x[k] - (y[k] >>> k);  // [cite: 15]
                    y[k+1] <= y[k] + (x[k] >>> k);  // [cite: 16]
                    z[k+1] <= z[k] - atan_table[k];  // [cite: 16]
                end else begin
                    x[k+1] <= x[k] + (y[k] >>> k);  // [cite: 17]
                    y[k+1] <= y[k] - (x[k] >>> k);  // [cite: 18]
                    z[k+1] <= z[k] + atan_table[k];  // [cite: 18]
                end
            end
        end
    endgenerate

    // --- 3. 结果输出与符号修正 (最终 1 拍) ---
    // 注意：这里的 quadrant_d 下标必须严格对应总延迟深度 18
    always @(posedge clk) begin
        case (quadrant_d[18])
             2'b00: begin sin <=  y[16][18:3]; cos <=  x[16][18:3]; end // Q1 [cite: 20]
             2'b01: begin sin <=  y[16][18:3]; cos <= -x[16][18:3]; end // Q2 [cite: 21]
             2'b10: begin sin <= -y[16][18:3]; cos <= -x[16][18:3]; end // Q3 [cite: 22]
             2'b11: begin sin <= -y[16][18:3]; cos <=  x[16][18:3]; end // Q4 [cite: 23]
            default: begin sin <= 16'd0; cos <= 16'd0; end
        endcase
    end
endmodule