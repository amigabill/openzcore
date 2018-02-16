/*
 * File:        imx_cbu.v
 * Project:     pippo
 * Designer:    kiss@pwrsemi
 * Mainteiner:  kiss@pwrsemi
 * Checker:
 * Assigner:    
 * Description: Core Bridge Unit - �Ž�core��imx��Ƭ�ϻ���Э��
 *  IMX��WB����ͬ
        1��IMX����slaveʹ��rty�źţ�master��slaveû�з���ackǰ��������
        2��IMX��Ҫ���ص�ǰ�����addr�ź�
        3��IMX��Ψһ����ź�Ϊack��err��ackΪ��Чʱֵ��������
 * Task.I:        
        verification environment for complex imx-cbu-wb interaction
            1, IMX�����������
            2, ��ͬ����ʱ��ȡ��IMX����������ȡ����ָ���Ч����������Ч�����
            3, �Ƿ����IMX����һֱ��Ч������ַ�����仯��������������ں�Ӧ�ò�����֣�����ȡ��ʱ������һ�Ŀ���
 * Task.II:
        ��ʱ����֧��
        Burst����֧��
 */
 
// synopsys translate_off
`include "timescale.v"
// synopsys translate_on
`include "def_pippo.v"

module imx_cbu(

    clk, rst, 
    
    wb_cyc_o, wb_adr_o, wb_stb_o, wb_we_o, wb_sel_o, wb_dat_o, wb_cti_o, wb_bte_o,
    wb_ack_i, wb_err_i, wb_rty_i, wb_dat_i,

    cbu_dat_i, cbu_adr_i, cbu_rqt_i, cbu_we_i, cbu_sel_i,
    cbu_ack_o, cbu_dat_o, cbu_err_o, cbu_adr_o
);

parameter dw = 32;
parameter aw = 32;

// currently no burst support
`define WB_CTI  3'b000
`define WB_BTE  2'b00

//
// core clock, reset and clock control
//
input				clk;		// core clock
input				rst;		// core reset

//
// core-bridge unit interface
//
input [aw-1:0] 		cbu_adr_i;	// core request address
input [dw-1:0] 		cbu_dat_i;	// core request data 
input				cbu_rqt_i;	// core request valid
input				cbu_we_i;	// core request w/r flag
input [3:0] 		cbu_sel_i;	// core request byte selects

output              cbu_ack_o;	// bus response valid(ack)
output              cbu_err_o;  // bus response error
output  [dw-1:0]    cbu_dat_o;	// bus response data
output  [aw-1:0]    cbu_adr_o;  // bus response address

//
// WISHBONE interface
//
input				wb_ack_i;	// normal termination
input				wb_err_i;	// termination with error
input				wb_rty_i;	// termination with retry
input   [dw-1:0]    wb_dat_i;	// data input 
output              wb_cyc_o;	// cycle valid output
output [aw-1:0] 	wb_adr_o;	// address output 
output				wb_stb_o;	// strobe output
output				wb_we_o;	// indicates write/read transfer
output [3:0] 		wb_sel_o;	// byte select output 
output [dw-1:0] 	wb_dat_o;	// data output 
output [2:0] 	    wb_cti_o;	// cycle type identifier
output [1:0] 	    wb_bte_o;	// burst type extension

//
// reg & wires
//
reg                 wb_cyc_o;	
reg [aw-1:0] 	    wb_adr_o;	
reg				    wb_stb_o;	
reg                 wb_we_o;	
reg [3:0] 		    wb_sel_o;	
reg [dw-1:0] 	    wb_dat_o;	
reg [2:0] 	        wb_cti_o;	
reg [1:0] 	        wb_bte_o;	

reg  [dw-1:0]       cbu_dat_o;
reg                 cbu_ack_o;
reg                 cbu_err_o;
reg  [aw-1:0]       cbu_adr_o;

//
// logic implementation
//

// registered request 
always @(posedge clk or posedge rst) begin
    if (rst) begin
        wb_cyc_o <= #1 1'b0;
        wb_stb_o <= #1 1'b0;
        wb_dat_o <= #1 32'd0;
        wb_adr_o <= #1 32'd0;
        wb_sel_o <= #1 4'd0;
        wb_we_o <= #1 1'd0;
        wb_cti_o <= #1 3'd0;
        wb_bte_o <= #1 2'd0;
    end
    else begin
        if (cbu_rqt_i)
        begin
            wb_cyc_o <= #1 cbu_rqt_i;
            wb_stb_o <= #1 cbu_rqt_i;
            wb_dat_o <= #1 cbu_dat_i;
            wb_adr_o <= #1 cbu_adr_i;
            wb_sel_o <= #1 cbu_sel_i;
            wb_we_o <= #1 cbu_we_i;    
            wb_cti_o <= #1 `WB_CTI;
            wb_bte_o <= #1 `WB_BTE;
        end
        else begin              // when core cancel bus request
            wb_cyc_o <= #1 1'b0;
            wb_stb_o <= #1 1'b0;
            wb_dat_o <= #1 32'd0;
            wb_adr_o <= #1 32'd0;
            wb_sel_o <= #1 4'd0;
            wb_we_o <= #1 1'd0;
            wb_cti_o <= #1 3'd0;
            wb_bte_o <= #1 2'd0;
        end
    end
end

// registered request 
always @(posedge clk or posedge rst) begin
    if (rst) begin
        cbu_ack_o <= #1 1'b0;
        cbu_err_o <= #1 1'b0;
    end
    else begin
        if (cbu_rqt_i)
        begin
            cbu_ack_o <= #1 wb_ack_i;
            cbu_err_o <= #1 wb_err_i;
        end
        else begin
            cbu_ack_o <= #1 1'b0;
            cbu_err_o <= #1 1'b0;
        end
    end
end
// special case for IMX
always @(posedge clk or posedge rst) begin
    if (rst) begin
        cbu_dat_o <= #1 32'd0;
    end
    else begin
        cbu_dat_o <= #1 wb_dat_i;
    end
end


// special case for IMX
always @(posedge clk or posedge rst) begin
    if (rst) begin
        cbu_adr_o <= #1 32'd0;
    end
    else begin
        cbu_adr_o <= #1 cbu_adr_i;      
    end
end

endmodule
