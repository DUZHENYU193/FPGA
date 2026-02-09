`include "defines.v"
module ex(
	//from id_ex
	input wire[31:0]  inst_i,
	input wire[31:0]  inst_addr_i,
	input wire[31:0]  op1_i,
	input wire[31:0]  op2_i,
	input wire[4:0]   rd_addr_i,
	input wire	      rd_wen_i,
	//to regs
	output reg[4:0]   rd_addr_o,
	output reg[31:0]  rd_data_o,
	output reg        rd_wen_o,

	//to ctrl
	output reg[31:0]  jump_addr_o,
	output reg        jump_en_o,
	output reg        hold_flag_o
);

	wire [6:0] opcode;
	wire [4:0] rd;
	wire [2:0] func3;
	wire [4:0] rs1;
	wire [4:0] rs2;
	wire [6:0] func7;
	wire [11:0] imm;
	wire [31:0] jump_imm;
	wire 		op1_i_op2_i_equal;
	
	assign opcode = inst_i[6:0];	
	assign rd     = inst_i[11:7];
	assign func3  = inst_i[14:12];	
	assign rs1    = inst_i[19:15];	
	assign rs2    = inst_i[24:20];	
	assign func7  = inst_i[31:25];	
	assign imm    = inst_i[31:20];	
	//jump_imm的计算
	assign jump_imm = {{19{inst_i[31]}},inst_i[7],inst_i[30:25],inst_i[11:8],1'b0};
	assign op1_i_op2_i_equal = (op1_i == op2_i)? 1'b1 : 1'b0;

	always @(*)begin
		case(opcode)
			`INST_TYPE_I:begin//I型立即数指令
				jump_addr_o = 32'b0;
				jump_en_o = 1'b0;
				hold_flag_o = 1'b0;
				case(func3)
					`INST_ADDI:begin//加法指令
						rd_data_o = op1_i + op2_i;
						rd_addr_o = rd_addr_i;
						rd_wen_o  = 1'b1;
					end
					default:begin
						rd_data_o = 32'b0;
						rd_addr_o = 5'b0;
						rd_wen_o  = 1'b0;
					end
				endcase
			end
			`INST_TYPE_R_M:begin//R型操作数指令
				jump_addr_o = 32'b0;
				jump_en_o = 1'b0;
				hold_flag_o = 1'b0;
				case(func3)
					`INST_ADD_SUB:begin//减法指令
						if(func7 == 7'b000_0000)begin
							rd_data_o = op1_i + op2_i;
							rd_addr_o = rd_addr_i;
							rd_wen_o  = 1'b1;
						end
						else begin
							rd_data_o = op2_i - op1_i;
							rd_addr_o = rd_addr_i;
							rd_wen_o  = 1'b1;
						end
					end
					default:begin
						rd_data_o = 32'b0;
						rd_addr_o = 5'b0;
						rd_wen_o  = 1'b0;
					end
				endcase
			end
			`INST_TYPE_B:begin
				rd_data_o = 32'b0;
				rd_addr_o = 5'b0;
				rd_wen_o  = 1'b0;				
				case(func3)
					`INST_BNE:begin
						jump_addr_o = inst_addr_i + jump_imm & {32{(op1_i_op2_i_equal)}};
						jump_en_o = ~op1_i_op2_i_equal;
						hold_flag_o = 1'b0;
					end
					default:begin
						jump_addr_o = 32'b0;
						jump_en_o = 1'b0;
						hold_flag_o = 1'b0;
					end					
				endcase
			end				
			default:begin
				rd_data_o = 32'b0;
				rd_addr_o = 5'b0;
				rd_wen_o  = 1'b0;
				jump_addr_o = 32'b0;
				jump_en_o = 1'b0;
				hold_flag_o = 1'b0;
			end
		endcase
	end


endmodule

