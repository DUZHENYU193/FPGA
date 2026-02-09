module crc5_chk(
    input           rst_n,      
    input           clk,
    input   [7:0]   in_data,    
    input           crc_start,  
    output  [4:0]   crc,        
    output  reg     crc_busy,   
    output  reg     crc_calc_done 
);

    reg [4:0] crc_reg;
    reg [2:0] bit_cnt;   // 用于计数 8 位数据
    reg [7:0] data_tmp;  // 锁存输入数据用于移位

    assign crc = crc_reg;

    // 串行 CRC 逻辑实现
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            crc_reg       <= 5'b0;
            crc_busy      <= 1'b0;
            crc_calc_done <= 1'b0;
            bit_cnt       <= 3'b0;
            data_tmp      <= 8'b0;
        end else begin
            if (crc_start && !crc_busy) begin
                // 开始计算，初始化
                crc_busy      <= 1'b1;
                crc_calc_done <= 1'b0;
                crc_reg       <= 5'b0;    // 根据题目“初值为0”
                data_tmp      <= in_data; // 锁存数据
                bit_cnt       <= 3'd0;
            end else if (crc_busy) begin
                // 执行串行计算（按照原理图逻辑）
                // 反馈项 = D4 ^ in_data[i]
                // D0_next = 反馈项
                // D1_next = D0
                // D2_next = D1 ^ 反馈项
                // D3_next = D2
                // D4_next = D3 ^ 反馈项
                
                crc_reg[0] <= crc_reg[4] ^ data_tmp[7];
                crc_reg[1] <= crc_reg[0];
                crc_reg[2] <= crc_reg[1] ^ (crc_reg[4] ^ data_tmp[7]);
                crc_reg[3] <= crc_reg[2];
                crc_reg[4] <= crc_reg[3] ^ (crc_reg[4] ^ data_tmp[7]);

                data_tmp <= {data_tmp[6:0], 1'b0}; // 移位处理下一位
                bit_cnt  <= bit_cnt + 1'b1;

                // 计数到 7 说明当前正在处理最后一位（第 8 位）
                if (bit_cnt == 3'd7) begin
                    crc_busy      <= 1'b0;
                    crc_calc_done <= 1'b1;
                end
            end else begin
                crc_calc_done <= 1'b0;
            end
        end
    end

endmodule