module sin_gen(
    input           clk,
    input           rst_n,
    input           en,
    input  [7:0]    freq_word, // 频率控制字
    output [15:0]   sin_out    // 16位正弦输出
);

    // 1. 相位累加器
    reg [7:0] phase_acc;
    always @(posedge clk or negedge rst_n) begin
        if(!rst_n)
            phase_acc <= 'd0;
        else if(en)
            phase_acc <= phase_acc + freq_word; // 扩展位宽以提高精度
    end

    // 2. CORDIC 实例化 (替代原本的 sinrom)
    // 这里假设目标是将 phase_acc 转换为 sin/cos
    // 输入为相位 z，输出为 y (sin)
    wire [15:0] cos_out; // 辅助输出
    
    cordic_core u_cordic (
        .clk     (clk),
        .rst_n   (rst_n),
        .phi     (phase_acc), // 输入当前相位
        .sin     (sin_out),   // 输出正弦值
        .cos     (cos_out)
    );

endmodule