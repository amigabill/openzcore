/*
 * File:        pippo_pipectrl.v
 * Project:     pippo
 * Designer:    kiss@pwrsemi
 * Mainteiner:  kiss@pwrsemi
 * Checker:
 * Assigner:    
 * Description:
 *      ��ˮ�߿����źţ���Ҫ����
 *          pc_freeze������PC�Ĵ��������浱ǰֵ
 *          if_freeze����ʾIF���޷������²���
 *          id_freeze����ʾID���޷������²���
 *          ex_freeze����ʾEXE���޷������²���
 *          wb_freeze������д�ز���������Ŀǰ��������ˮ��ƣ�wb_freeze��ͬ��ex_freeze
 *      �Կ�����ˮ�߼Ĵ�������Ҫ��xx_cia��xx_inst�ȣ���Ϊ��
 * Specification
    1. ������ˮ��
        ����ˮ�������������Σ��������ˮ��ʩ�ӿ����Ա�ָ֤����˳��ִ�в���ɡ�
        ��1��	ĳЩָ��������Ҫ������ˮ������ô�ָ��������MA��ˮ��
        ��2��	ĳ��ˮ�����ڸ���ԭ����Ҫ����������ʱ���縴����������ָ��
        ��3��	ָ��ִ��ʧ�ܣ���ô�ָ���������жϣ���Ҫ��ָֹ������
        ��4��   ���϶������ͬʱ�������ô�ָ����ʻ��浫miss�� 
        ����ˮ�׶�������stall�������£�
            IF�Σ�ȡ��ָ��ĵȴ����ڣ���ifģ���if_stall����
            ID�Σ��ޣ������⵽��ָ֧���idģ���bp_stall����
            EX�Σ�������ִ�в������ô�͸�����������ָ�����lsu_stall��multicycle_stall����
        ���ۺ�������ˮ��״̬��stall����֮�󣬲���freeze�źſ�����ˮ���ƽ�����������������Bubble��NOP��KCS����
        ����ˮ�ζ��ᣨfreeze�����򣺵��ֽ׶β���stall����ǰһ����ˮ���붳�ᣬ�Ա���overlapping
            ����һ����ˮ(IF)����stall����ʱ��IF�ζ���
                [ͬһ������IF miss I$���ô�ָ��hit D$�����]
        �����ź�Ӧ�ù������£�ÿһ������ˮ�Ĵ���ά����ǰ��������ˮ�ߵ�freeze�źſ��ơ�
            ��ǰ�˶���������ʱ������NOP��
            ��ǰ�˶����˶���ʱ�����ֵ�ǰ״̬��
            ��ǰ�������������ʱ�������ƽ�
            ǰ��������˶�������������freeze�źŲ�������
    2. ˢ����ˮ��
        ����freeze�źſ����⣬��ˮ���������������Ҫˢ����ˮ�ߣ��ſ�����ָ�����ȡָ
        ��1���жϴ���ģ�������flush_except��ˢ����ˮ��
        ��2����֧����ģ�����ڷ�֧Ԥ����������flush_branch��ˢ����ˮ��
    3. PCά���͸���
        PCά���͸��������������Ҫ�ֿ�����
        ��1����ˮ�߶���ʱ����������ȡָ��ַPC���������������ȡָ
        ��2����ˮ��ˢ��ʱ����Ҫ��������PC����ˢ����ɺ�ֱ�ʹ��npc_xxx����ȡָ
        pc_freeze�ڴ���Ч״̬�ָ�ʱ��
 * List2do: 
 *      [TBV] timing relationship between flushpipe and freeze.
 *
 */

// synopsys translate_off
`include "timescale.v"
// synopsys translate_on
`include "def_pippo.v"

module pippo_pipectrl(

	flush_except, flush_branch, flushpipe, 

	if_stall, lsu_stall, multicycle_cnt, asyn_stall, 

	pc_freeze, if_freeze, id_freeze, ex_freeze, wb_freeze
);

//
// I/O
//

// stall request from pipeline stages
input				if_stall;                       
input				lsu_stall;      
input               asyn_stall;
input   [1:0]	    multicycle_cnt; 

// freeze command to pipeline stages
output				pc_freeze;
output				if_freeze;
output				id_freeze;
output				ex_freeze;
output				wb_freeze;

// flush control
input				flush_except;
input               flush_branch;
output              flushpipe; 

//
// Internal wires and regs
//
wire			multicycle_stall;

//
// flush pipelining 
//  at the last cycle of flushpipe assertion, new fetch address will send to pc register
//  1. when flush is raised by except processing, assert for two cycles.
//  2. when flush is raised by branch processing, assert for one cycle.
//
assign flushpipe = flush_except | flush_branch; 

//
// PC freeze signal
//
// pc_freeze is just for dis-asserting fetch request
assign pc_freeze = flushpipe;

//
// Pipeline freeze generation:
//

assign multicycle_stall = |multicycle_cnt;

// notes for asyn_stall: see except module
assign if_freeze = if_stall | id_freeze;
assign id_freeze = ex_freeze;
assign ex_freeze = wb_freeze | asyn_stall; 
assign wb_freeze = lsu_stall | multicycle_stall;

/*
Implementation: Memory access instructions with update, under 3r1w rf design

a. Load with update instructions
    pipectrl.v
        ע�⣺multicycle_stall����Ҳ��仯����wb_twice��Чʱ����һ��ָ������multicycle_stall��������
    rf.v
      we & (~wb_freeze | wb_at_fze)  //write enable logic  
    wb_twice come from rfwbop, and more to do:
        1. logic for write address and source
        2. write order of EA and loaded data?
        3. wb_atfze��Чʱ��ֻ��һ��    
b. Store with update instructions
    ע����Ҫͬ��store����ɺ�update��дEA��RA�������

Logic.a: ����д��ʱ������wb��д��һ�Σ��ٽⶳ��ɵڶ���д�أ�
  pipectrl.v
    //wb_atfze means: wb_freeze is asserted by wb_twice only, at this case, write-back can go.
    assign wb_freeze_a = lsu_stall | multicycle_stall;
    assign wb_freeze = wb_freeze_a | wb_atfze;

    always @(posedge clk or posedge rst) begin
    	if (rst)
    		wb_atfze <= #1 1'b0;
    	else if(wb_freeze_a)         
    		wb_atfze <= #1 rfwb_uops[0] & rfwb_uops[1];
        else
            wb_atfze <= #1 1'b0;
    end

  reg_gprs.v
    assign rf_we = (~flushpipe) & ((wea & ~wb_freeze) |(wea & wb_atfze) | (web & ~wb_freeze)) ;
    assign rf_addrw = wea & (!web | wb_atfze) ? addrwa : web ? addrwb : 5'd0;
    assign rf_dataw = wea & (!web | wb_atfze) ? datawa : web ? datawb : 32'd0;
  
  operandmux.v/wbmux.v
    ���ʹ��ת���߼�����wra��wrb��ת����Ҫ������Ч�߼����ƻ�ʵ����wbmuxģ��
        (gpr_addr_rda == ex_gpr_addr_wra) && (ex_rfwb_uops[0] & !ex_rfwb_uops[1])
        (gpr_addr_rda == ex_gpr_addr_wrb) && (ex_rfwb_uops[1] & !wb_atfze)
  
Logic.b: ��д��һ�Σ��ٶ���wb����ɵڶ���д�أ��������⣺
    1����һ��ָ���Ѿ�����exe�Σ�����Ƕ�����ָ����ᵼ��wb_atfze������Ч
    2����Ҫ�Ĵ�addr_wr��ea��
assign wb_freeze_a = lsu_stall | multicycle_stall;
assign wb_freeze = wb_freeze_a | wb_atfze;

always @(posedge clk or posedge rst) begin
	if (rst)
		wb_atfze <= #1 1'b0;
	else if(!wb_freeze_a)         
		wb_atfze <= #1 rfwb_uops[0] & rfwb_uops[1];
end


*/

endmodule
