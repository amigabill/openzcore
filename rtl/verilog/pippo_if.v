/*
 * File:        pippo_if.v
 * Project:     pippo
 * Designer:    kiss@pwrsemi
 * Mainteiner:  kiss@pwrsemi
 * Checker: 
 * Assigner:
 * Description:
    һ��IF�ε���Ҫ��������
        1��	������ˮ�ߺ�i-side IMX����������ȡָ��ַ��ȡ��ָ���ȡ��ָ���ָ���ַ������ˮ�߼Ĵ�����
        2��	���º�ά��PCֵ
        3��	���������ˮ�߷�������ת����
        4��	���IF����exception����������������ź����������ˮ�ȴ�exceptģ��ͳһ����
    ������ƹ淶
    NPC����Դ���ࣺ
        1��	˳��ȡָ��PC+4
        2��	��֧��ת��npc_branch���Է�֧����ģ��(����EXE��ִ�н������תĿ���ַ��SNIA��ѡ��)
        3��	�жϴ���npc_except�����жϴ���ģ�飬Ϊ�жϴ��������ڵ�ַ
        4��	����ָ��ִ�У�rfi/rfci�ȣ���npc_inst����srr0/srr2�Ĵ�����λ��exceptģ�飩��
        5�� ͬ��ָ��ִ�У�����ָ��isync/eieio/sync��mtmsr������ָ���npc_sync����ͬ��ָ���SNIA��
    PCά���͸��£�
        1�� ���������˳��ָ������ʹ��NPC����PC�Ĵ���
        2�� ˳��ָ����ˮ�߶���ʱ����������PCֵ���ȴ������������ȡָ            
        3�� ָ�����任
            1���жϴ���EXE�Σ��жϴ���ʼ������rfi/rfci��������flush_except�źţ��ȴ�npc_except��Ч�����PC��ȡָ
            2����ָ֧����ֲ���a����
                a�����þ�̬��֧Ԥ�⼼�������з�ָ֧�Ԥ��ΪNT������EXE�λ�ȡ��֧���ΪTakenʱ������flush_branch�źţ�
                   Ȼ��ȴ�npc_branch��Ч�����PC��ȡָ����Ԥ����ȷʱ����������˳��ָ������������
                b��ID�η��ַ�ָ֧�����bp_stall�źţ���ʱ��һ��ָ���ȡָ��δ��ɣ����������ˮ�ߣ���
                   ����EXE�ν����
                        branch_taken    ��ת��ʹ��npc_branch����pc��ȡָ
                        branch_nt       ����ת��ʹ����pcȡָ 
            ע��flushpipe�ź�Ϊ��������������ۺϣ���pipectrlģ�����
    IMX�ӿڴ����������ӵķֲ�ʽЭͬ
        ȡָ����ķ��ͣ����ݴ�������ˮ��״̬��IMX���ص�״̬��ͬ������ȡָ�����ȡָ��ַ��PC��
            rqt_valid�߼���ȡ������ˮ��״̬
            PC�����߼���ȡ������ˮ��״̬��IMX����״̬
        ȡָ��Ӧ�Ľ��գ�ͬ����Ҫ���ݴ�������ˮ��״̬��IMX���ص�״̬�������Ƿ�Ĵ浱ǰ��Ӧ������ˮ��
            ȡָ�����ȡ���ͱ任����Ĵ���
            ��Ч���ز���һ���������ˮ��
    ����IF/ID��ˮ�Ĵ����߼�-��ˮ�������id_valid, id_inst, id_cia, id_snia����ˮά���͸��²��Բο�pipectrlģ�飬�������£�
        1�� ���������ȡָ�ɹ�������ˮ���������Ĵ沢�ͳ�ȡ��ָ��
        2�� �жϴ���ʼ��exceptģ�鷢��flushpipe�ź���ˢ����ˮ�ߣ�����NOP������id_validΪ��Ч
        3�� ����ˮ�߶��ᣨif_freeze��id_freeze��Ч��ʱ��IF/ID����NOP��KCS bubble
            �����ȴ�������Ӧ��ack_i/err_i��Ч����if_stall��������������ʱ��
 * Task.I:
        [TBD]imxЭ����֤�͸Ľ�
            Ŀǰi-imx���÷���ĵ�ַ������tsc���䣬��֧��һ��pipeling��ʽ��
                Ŀǰrqt_valid������Ч������ˮ��ˢ��(flushpipe)�Ͷ���(id_freeze)ʱ��
                ��slave���ص�ַ��Ӧ(!rty_i)��PC���£������µĵ�ַ���󣭼�ӱ�֤�����ظ��ͳ�֮ǰ�ĵ�ַ����
                ����ڵ�ַ��Ӧ��������Ӧ֮�����ȴ�����(��!rty_i��ack_i֮��)��slave�뱣֤�����������������˳��
            ����imc���ص�addrλ������[1:0]Ҳ����Ҫ��
            ��ַ�������Ӧ��rqt->!rty_i���߼���·��ģ��֮�䶼������߼���fetcher��biu/imc��������ע������ʱ��
            ��λ�������֤��slave����ͬ��������ȡ�ظ�λ֮ǰ��������ݣ�
            IMX�µ�ַ�׶κ����ݽ׶�ͬʱ���������������(!rty)��ackͬʱ��Ч
            ��wbv4�淶����ͬ
                �Ƿ�����tsc_busyλ��ʾ���ߴ�������У�
                ���Ƚ�wb�淶��!rty_i��ʱ�����⣭��ack_i�Ĺ�ϵ��
        [TBV]ȡָ�߼���ȡָ���ᣬ��ˮ��ˢ�£�if_stall�͵�ǰȡָ�����׶εȸ����������µĴ���������֤
            ��PC��ά��������NPC�߼�����rqt_valid��ͬ�����±��뱣֤
                1��������ȷ��ȡָ���󣭸��ݵ�ǰ��ˮ��״̬��
                2�����Ĵ�һ��ָ�������ˮ�ߣ�
                3�����ᷢ���ظ�ȡָ�Ͳ��ᶪʧȡ�ص�ָ�
        [TBD]����ˮ�߷���ȡָ����err_i��ʱ����Ӧexcept������EXE�ν��õ�����cia������ˮ�ߣ���id_validΪ0��
            err_iȡ�ص�������ʲô��������ˮ�߻���id�β���������Ϊ��
            ���ǲ���NOP�Ա���������ݵĸ����ã�����id_valid������id�����Ϊ��Ч��
        [TBV] imx, pipelining and PC bahavior
            1. npc_branch, npc_except can't assert simultaneously
            2. after recover from freezing, first fetch request from previous pc/npc?
            3. the case of canceling fetch request(cache miss, and inst transfer event happened)
                processing by imx protocol: diassert rqt, then diassert ack.
            4. check id_snia timing
            5. coding style of pipelining register
        [TBD]make "itlb, immu" logic conditional
 * Task.II:
 *      full synthesis & verification
 *      rtl performance refactor-improve speed, reduce power and area.
 *      to improve fetch performance, add buffer to register fetched instruction and address at some case
 */

// synopsys translate_off
`include "timescale.v"
// synopsys translate_on
`include "def_pippo.v"

module pippo_if(

	clk, rst,

	iimx_adr_o, iimx_rqt_o, iimx_rty_i, 
	iimx_ack_i, iimx_err_i, iimx_dat_i, iimx_adr_i, 

	npc_branch, npc_except, npc_branch_valid, npc_except_valid, 
	
	pc_freeze, if_stall, if_freeze, id_freeze, flushpipe, 
	
	id_inst, id_cia, id_valid, id_snia,
	
	id_sig_ibuserr
);

input				clk;
input				rst;

// IMX I/F to fetch instructions (from cache/ocm/memory controller)
input	[31:0]		iimx_dat_i;
input				iimx_ack_i;
input				iimx_err_i;
input	[31:0]		iimx_adr_i;
input				iimx_rty_i;
output	[31:0]		iimx_adr_o;
output				iimx_rqt_o;

// inst. flow transfer
input   [29:0]      npc_branch;         
input               npc_branch_valid;   
input   [31:0]      npc_except;         // keep least two address bits to code ISR entrance easily.
input               npc_except_valid;   

// pipeline control
input               pc_freeze;          
input				if_freeze;        
input				id_freeze;          
input				flushpipe;
output				if_stall;           

// pipeling register
output              id_valid;           
output	[31:0]		id_inst;            
output	[29:0]		id_cia;             
output	[29:0]		id_snia;            

// exception request
output				id_sig_ibuserr;     

//
// 
//
reg                 id_valid;
reg     [31:0]		id_inst;
reg     [29:0]		id_cia;
reg     [29:0]		id_snia;
reg                 id_sig_ibuserr;

reg     [31:0]      npc_value; 
reg                 if_valid;
reg     [31:0]      if_inst;          
reg     [29:0]      if_cia;
reg                 if_sig_ibuserr; 
reg	    [31:0]		pc;
wire                if_rqt_valid; 
wire    [32:0]      pcadd4;             
wire                except_ibuserr;

//
// send fetch rqt to I-IMX
//
assign iimx_adr_o = pc; 
assign iimx_rqt_o = if_rqt_valid; 

// stall request, waiting for I-IMX response 
assign if_stall = ~iimx_ack_i; 

//
// PC Register logic
//

// NPC source
assign pcadd4={(pc[31:2]+31'd1), 2'b00};

// 
assign fetch_lost = id_freeze & iimx_ack_i;

always @(npc_branch_valid or npc_except_valid or id_freeze or iimx_adr_i or
        fetch_lost or npc_branch or npc_except or pc or pcadd4) begin
	casex ({npc_branch_valid, npc_except_valid, id_freeze, fetch_lost})	// synopsys parallel_case
	    4'b0000: begin
	        npc_value = pcadd4[31:0];
	    end
		4'b0100: begin
			npc_value = npc_except;
		end
		4'b1000: begin
			npc_value = {npc_branch, 2'b00};
		end
		4'b0010: begin                   // if pipeline(if_freeze & id_freeze) is freezon, keep current pc
			npc_value = pc;
		end		
		4'b0011: begin
		    npc_value = iimx_adr_i;     // fetch current fetched instruction again
        end
        
		default: begin     
			npc_value = pc;
		end		
    endcase
end

//
// PC update policy
//
//  1. after hard reset, keep RESET_VECTOR (pcadd4[32]) to avoid overflow
//  2. update pc when 
//      a) flushpipe: flush pipeline, fetch with npc
//      b) !iimx_rty_i: current transaction is complete
//      c) fetch lost
always @(posedge clk or posedge rst) begin
    if (rst)
        pc <= #1 `pippo_RESET_VECTOR;
    else if (pcadd4[32] & !flushpipe)   // !flushpipe: keep normal when fetched first branch inst
        pc <= #1 `pippo_RESET_VECTOR;
    else if (flushpipe | (!iimx_rty_i) | fetch_lost) 
        pc <= #1 npc_value;
end

//
// inst. fetch request logic: if_rqt_valid signal
//  1. when flushpipe assert(pc_freeze asserts), if_rqt_valid disassert
//  2. when pipeline freeze(id_freeze freeze), if_rqt_valid disassert to reduce memory access
//          NOT use if_freeze signal to exclude if_stall deadlock, or additional logic is needed for biu
//          deadloack: if_freeze assert at wait state, if you diassert this request, system stop forever.
//  3. hard-reset case: if_rqt_valid assert until RESET_VECTOR's ack(!iimx_rty_i) come, then keep disassertion.
//  At normal state, always send fetch request - if_rqt_valid keep assert, when address ack(!iimx_rty_i) assert
//     or disassert. including case that if_stall asserts, to avoid deadlock: no new fetch send out
//          deadlock: (if_stall raised -> if_freeze assert -> rqt_valid disassert forever)

// after hard reset, to avoid fetch reset vector many times, 
//      "!flushpipe" logic is to reduce one cycle delay after reset vector's branch
reg rst_rqt_done;
always @(posedge clk or posedge rst) begin
    if (rst)
        rst_rqt_done <= #1 1'b0;
    else if (flushpipe)
        rst_rqt_done <= #1 1'b0;    
    else if (pcadd4[32] & !iimx_rty_i)
        rst_rqt_done <= #1 1'b1;     
end

// to check the timing of rqt_valid signal - rqt_valid must have budget for addr_ack logic, i.e.:
// at IMX address phase(cycle 1):
//      Master send out if_rqt_valid, slave check address and give back addr_ack;
//      Addr_ack(!iimx_rty_i) signal must satisfy the setup time, when inputting to master;
// [TBD] register out if_rqt_valid signal to improve timing, add a pipeline bubble under some case
//      note: keep pace with pc update
assign if_rqt_valid = !(pc_freeze | id_freeze | (pcadd4[32] & rst_rqt_done));

//
// IF/ID pipelining logic
//
always @(iimx_ack_i or if_freeze or id_freeze or flushpipe or
        if_valid or if_inst or if_cia or 
        id_valid or id_inst or id_cia or 
        iimx_dat_i or iimx_adr_i or 
        except_ibuserr or id_sig_ibuserr) begin
	casex ({iimx_ack_i, if_freeze, id_freeze, flushpipe})	// synopsys parallel_case
		4'b1000: begin       // Normal pipelining. I-IMX returns valid value
            if_valid = 1'b1; 
            if_inst = iimx_dat_i;
            if_cia = iimx_adr_i[31:2];
            if_sig_ibuserr = except_ibuserr;
		end
		4'bxxx1: begin       // flushpipe is asserted, insert NOP bubble
            if_valid = 1'b0; 
            if_inst = `pippo_PWR_NOP;
            if_cia = id_cia;
            if_sig_ibuserr = 1'b0;
		end
		4'bx100: begin       // if_freeze is asserted, id_freeze is disasserted, insert NOP bubble
            if_valid = 1'b0; 
            if_inst = `pippo_PWR_NOP;
            if_cia = id_cia;
            if_sig_ibuserr = 1'b0;
		end
		4'bx110: begin       // if_freeze/id_freeze is asserted, insert KCS bubble
            if_valid = id_valid; 
            if_inst = id_inst;
            if_cia = id_cia;
            if_sig_ibuserr = id_sig_ibuserr;
		end
		default: begin      // [TBV]iimx_err_i is asserted
            if_valid = 1'b0;     
            if_inst = `pippo_PWR_NOP;
            if_cia = id_cia;
            if_sig_ibuserr = except_ibuserr;
		end		
    endcase
end

always @(posedge clk or posedge rst) begin
    if(rst) begin
        id_valid <= #1 1'b0;
        id_inst <= #1 `pippo_PWR_NOP;
        id_cia <= #1 30'd0;
        id_snia <= #1 30'd0; 
        id_sig_ibuserr = 1'b0;
    end
    else begin
        id_valid <= #1 if_valid;
        id_inst <= #1 if_inst;
        id_cia <= #1 if_cia;
        id_snia <= #1 pcadd4[31:2]; 
        id_sig_ibuserr = if_sig_ibuserr;
        `ifdef pippo_VERBOSE
        // synopsys translate_off
            $display("%t: id_valid <= %h", $time, id_valid);
            $display("%t: id_inst <= %h", $time, id_inst);
            $display("%t: id_cia <= %h", $time, id_cia);
            $display("%t: id_snia <= %h", $time, id_snia);
        // synopsys translate_on
        `endif
    end
end

//
// except request from IF stage
//
assign except_ibuserr = iimx_err_i & iimx_ack_i;    // err valid only when ack assert

endmodule


