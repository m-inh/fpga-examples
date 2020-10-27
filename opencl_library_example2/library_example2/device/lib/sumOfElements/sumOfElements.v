// (C) 1992-2015 Altera Corporation. All rights reserved.                         
// Your use of Altera Corporation's design tools, logic functions and other       
// software and tools, and its AMPP partner logic functions, and any output       
// files any of the foregoing (including device programming or simulation         
// files), and any associated documentation or information are expressly subject  
// to the terms and conditions of the Altera Program License Subscription         
// Agreement, Altera MegaCore Function License Agreement, or other applicable     
// license agreement, including, without limitation, that your use is for the     
// sole purpose of programming logic devices manufactured by Altera and sold by   
// Altera or its authorized distributors.  Please refer to the applicable         
// agreement for further details.                                                 
    

//////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////

// altera message_off 10036
// altera message_off 10230
// altera message_off 10858
module sumOfElements_basic_block_0
	(
		input 		clock,
		input 		resetn,
		input [63:0] 		input_sum,
		input [31:0] 		input_global_size_0,
		input 		valid_in,
		output 		stall_out,
		input [31:0] 		input_global_id_0,
		input [31:0] 		input_acl_hw_wg_id,
		output 		valid_out,
		input 		stall_in,
		output [63:0] 		lvb_bb0_arrayidx3,
		output [31:0] 		lvb_bb0_ld_arrayidx3_promoted,
		output [31:0] 		lvb_input_global_id_0,
		output [31:0] 		lvb_input_acl_hw_wg_id,
		input [31:0] 		workgroup_size,
		input 		start,
		output 		avm_local_bb0_ld_arrayidx3_promoted_enable,
		input [511:0] 		avm_local_bb0_ld_arrayidx3_promoted_readdata,
		input 		avm_local_bb0_ld_arrayidx3_promoted_readdatavalid,
		input 		avm_local_bb0_ld_arrayidx3_promoted_waitrequest,
		output [27:0] 		avm_local_bb0_ld_arrayidx3_promoted_address,
		output 		avm_local_bb0_ld_arrayidx3_promoted_read,
		output 		avm_local_bb0_ld_arrayidx3_promoted_write,
		input 		avm_local_bb0_ld_arrayidx3_promoted_writeack,
		output [511:0] 		avm_local_bb0_ld_arrayidx3_promoted_writedata,
		output [63:0] 		avm_local_bb0_ld_arrayidx3_promoted_byteenable,
		output [5:0] 		avm_local_bb0_ld_arrayidx3_promoted_burstcount,
		output 		local_bb0_ld_arrayidx3_promoted_active,
		input 		clock2x
	);


// Values used for debugging.  These are swept away by synthesis.
wire _entry;
wire _exit;
 reg [31:0] _num_entry_NO_SHIFT_REG;
 reg [31:0] _num_exit_NO_SHIFT_REG;
wire [31:0] _num_live;

assign _entry = ((&valid_in) & ~((|stall_out)));
assign _exit = ((&valid_out) & ~((|stall_in)));
assign _num_live = (_num_entry_NO_SHIFT_REG - _num_exit_NO_SHIFT_REG);

always @(posedge clock or negedge resetn)
begin
	if (~(resetn))
	begin
		_num_entry_NO_SHIFT_REG <= 32'h0;
		_num_exit_NO_SHIFT_REG <= 32'h0;
	end
	else
	begin
		if (_entry)
		begin
			_num_entry_NO_SHIFT_REG <= (_num_entry_NO_SHIFT_REG + 2'h1);
		end
		if (_exit)
		begin
			_num_exit_NO_SHIFT_REG <= (_num_exit_NO_SHIFT_REG + 2'h1);
		end
	end
end



// This section defines the behaviour of the MERGE node
wire merge_node_stall_in_0;
 reg merge_node_valid_out_0_NO_SHIFT_REG;
wire merge_node_stall_in_1;
 reg merge_node_valid_out_1_NO_SHIFT_REG;
wire merge_stalled_by_successors;
 reg merge_block_selector_NO_SHIFT_REG;
 reg merge_node_valid_in_staging_reg_NO_SHIFT_REG;
 reg [31:0] input_global_id_0_staging_reg_NO_SHIFT_REG;
 reg [31:0] input_acl_hw_wg_id_staging_reg_NO_SHIFT_REG;
 reg [31:0] local_lvm_input_global_id_0_NO_SHIFT_REG;
 reg [31:0] local_lvm_input_acl_hw_wg_id_NO_SHIFT_REG;
 reg is_merge_data_to_local_regs_valid_NO_SHIFT_REG;
 reg invariant_valid_NO_SHIFT_REG;

assign merge_stalled_by_successors = ((merge_node_stall_in_0 & merge_node_valid_out_0_NO_SHIFT_REG) | (merge_node_stall_in_1 & merge_node_valid_out_1_NO_SHIFT_REG));
assign stall_out = merge_node_valid_in_staging_reg_NO_SHIFT_REG;

always @(*)
begin
	if ((merge_node_valid_in_staging_reg_NO_SHIFT_REG | valid_in))
	begin
		merge_block_selector_NO_SHIFT_REG = 1'b0;
		is_merge_data_to_local_regs_valid_NO_SHIFT_REG = 1'b1;
	end
	else
	begin
		merge_block_selector_NO_SHIFT_REG = 1'b0;
		is_merge_data_to_local_regs_valid_NO_SHIFT_REG = 1'b0;
	end
end

always @(posedge clock or negedge resetn)
begin
	if (~(resetn))
	begin
		input_global_id_0_staging_reg_NO_SHIFT_REG <= 'x;
		input_acl_hw_wg_id_staging_reg_NO_SHIFT_REG <= 'x;
		merge_node_valid_in_staging_reg_NO_SHIFT_REG <= 1'b0;
	end
	else
	begin
		if (((merge_block_selector_NO_SHIFT_REG != 1'b0) | merge_stalled_by_successors))
		begin
			if (~(merge_node_valid_in_staging_reg_NO_SHIFT_REG))
			begin
				input_global_id_0_staging_reg_NO_SHIFT_REG <= input_global_id_0;
				input_acl_hw_wg_id_staging_reg_NO_SHIFT_REG <= input_acl_hw_wg_id;
				merge_node_valid_in_staging_reg_NO_SHIFT_REG <= valid_in;
			end
		end
		else
		begin
			merge_node_valid_in_staging_reg_NO_SHIFT_REG <= 1'b0;
		end
	end
end

always @(posedge clock)
begin
	if (~(merge_stalled_by_successors))
	begin
		case (merge_block_selector_NO_SHIFT_REG)
			1'b0:
			begin
				if (merge_node_valid_in_staging_reg_NO_SHIFT_REG)
				begin
					local_lvm_input_global_id_0_NO_SHIFT_REG <= input_global_id_0_staging_reg_NO_SHIFT_REG;
					local_lvm_input_acl_hw_wg_id_NO_SHIFT_REG <= input_acl_hw_wg_id_staging_reg_NO_SHIFT_REG;
				end
				else
				begin
					local_lvm_input_global_id_0_NO_SHIFT_REG <= input_global_id_0;
					local_lvm_input_acl_hw_wg_id_NO_SHIFT_REG <= input_acl_hw_wg_id;
				end
			end

			default:
			begin
			end

		endcase
	end
end

always @(posedge clock or negedge resetn)
begin
	if (~(resetn))
	begin
		merge_node_valid_out_0_NO_SHIFT_REG <= 1'b0;
		merge_node_valid_out_1_NO_SHIFT_REG <= 1'b0;
	end
	else
	begin
		if (~(merge_stalled_by_successors))
		begin
			merge_node_valid_out_0_NO_SHIFT_REG <= is_merge_data_to_local_regs_valid_NO_SHIFT_REG;
			merge_node_valid_out_1_NO_SHIFT_REG <= is_merge_data_to_local_regs_valid_NO_SHIFT_REG;
		end
		else
		begin
			if (~(merge_node_stall_in_0))
			begin
				merge_node_valid_out_0_NO_SHIFT_REG <= 1'b0;
			end
			if (~(merge_node_stall_in_1))
			begin
				merge_node_valid_out_1_NO_SHIFT_REG <= 1'b0;
			end
		end
	end
end

always @(posedge clock or negedge resetn)
begin
	if (~(resetn))
	begin
		invariant_valid_NO_SHIFT_REG <= 1'b0;
	end
	else
	begin
		invariant_valid_NO_SHIFT_REG <= (~(start) & (invariant_valid_NO_SHIFT_REG | is_merge_data_to_local_regs_valid_NO_SHIFT_REG));
	end
end


// This section implements an unregistered operation.
// 
wire local_bb0_idxprom2_stall_local;
wire [63:0] local_bb0_idxprom2;
wire [63:0] rci_rcnode_1to4_rc1_input_global_id_0_0_reg_1;

assign local_bb0_idxprom2[63:32] = 32'h0;
assign local_bb0_idxprom2[31:0] = local_lvm_input_global_id_0_NO_SHIFT_REG;
assign rci_rcnode_1to4_rc1_input_global_id_0_0_reg_1[31:0] = local_lvm_input_global_id_0_NO_SHIFT_REG;
assign rci_rcnode_1to4_rc1_input_global_id_0_0_reg_1[63:32] = local_lvm_input_acl_hw_wg_id_NO_SHIFT_REG;

// Register node:
//  * latency = 3
//  * capacity = 3
 logic rcnode_1to4_rc1_input_global_id_0_0_valid_out_NO_SHIFT_REG;
 logic rcnode_1to4_rc1_input_global_id_0_0_stall_in_NO_SHIFT_REG;
 logic [63:0] rcnode_1to4_rc1_input_global_id_0_0_NO_SHIFT_REG;
 logic rcnode_1to4_rc1_input_global_id_0_0_reg_4_inputs_ready_NO_SHIFT_REG;
 logic [63:0] rcnode_1to4_rc1_input_global_id_0_0_reg_4_NO_SHIFT_REG;
 logic rcnode_1to4_rc1_input_global_id_0_0_valid_out_reg_4_NO_SHIFT_REG;
 logic rcnode_1to4_rc1_input_global_id_0_0_stall_in_reg_4_NO_SHIFT_REG;
 logic rcnode_1to4_rc1_input_global_id_0_0_stall_out_reg_4_IP_NO_SHIFT_REG;
 logic rcnode_1to4_rc1_input_global_id_0_0_stall_out_reg_4_NO_SHIFT_REG;

acl_data_fifo rcnode_1to4_rc1_input_global_id_0_0_reg_4_fifo (
	.clock(clock),
	.resetn(resetn),
	.valid_in(rcnode_1to4_rc1_input_global_id_0_0_reg_4_inputs_ready_NO_SHIFT_REG),
	.stall_in(rcnode_1to4_rc1_input_global_id_0_0_stall_in_reg_4_NO_SHIFT_REG),
	.valid_out(rcnode_1to4_rc1_input_global_id_0_0_valid_out_reg_4_NO_SHIFT_REG),
	.stall_out(rcnode_1to4_rc1_input_global_id_0_0_stall_out_reg_4_IP_NO_SHIFT_REG),
	.data_in(rci_rcnode_1to4_rc1_input_global_id_0_0_reg_1),
	.data_out(rcnode_1to4_rc1_input_global_id_0_0_reg_4_NO_SHIFT_REG)
);

defparam rcnode_1to4_rc1_input_global_id_0_0_reg_4_fifo.DEPTH = 4;
defparam rcnode_1to4_rc1_input_global_id_0_0_reg_4_fifo.DATA_WIDTH = 64;
defparam rcnode_1to4_rc1_input_global_id_0_0_reg_4_fifo.ALLOW_FULL_WRITE = 0;
defparam rcnode_1to4_rc1_input_global_id_0_0_reg_4_fifo.IMPL = "ll_reg";

assign rcnode_1to4_rc1_input_global_id_0_0_reg_4_inputs_ready_NO_SHIFT_REG = merge_node_valid_out_1_NO_SHIFT_REG;
assign rcnode_1to4_rc1_input_global_id_0_0_stall_out_reg_4_NO_SHIFT_REG = (~(rcnode_1to4_rc1_input_global_id_0_0_reg_4_inputs_ready_NO_SHIFT_REG) | rcnode_1to4_rc1_input_global_id_0_0_stall_out_reg_4_IP_NO_SHIFT_REG);
assign merge_node_stall_in_1 = rcnode_1to4_rc1_input_global_id_0_0_stall_out_reg_4_NO_SHIFT_REG;
assign rcnode_1to4_rc1_input_global_id_0_0_NO_SHIFT_REG = rcnode_1to4_rc1_input_global_id_0_0_reg_4_NO_SHIFT_REG;
assign rcnode_1to4_rc1_input_global_id_0_0_stall_in_reg_4_NO_SHIFT_REG = rcnode_1to4_rc1_input_global_id_0_0_stall_in_NO_SHIFT_REG;
assign rcnode_1to4_rc1_input_global_id_0_0_valid_out_NO_SHIFT_REG = rcnode_1to4_rc1_input_global_id_0_0_valid_out_reg_4_NO_SHIFT_REG;

// This section implements an unregistered operation.
// 
wire local_bb0_arrayidx3_valid_out;
wire local_bb0_arrayidx3_stall_in;
wire local_bb0_arrayidx3_inputs_ready;
wire local_bb0_arrayidx3_stall_local;
wire [63:0] local_bb0_arrayidx3;

assign local_bb0_arrayidx3_inputs_ready = merge_node_valid_out_0_NO_SHIFT_REG;
assign local_bb0_arrayidx3 = ((input_sum & 64'hFFFFFFFFFFFFFC00) + ((local_bb0_idxprom2 & 64'hFFFFFFFF) << 6'h2));
assign local_bb0_arrayidx3_valid_out = local_bb0_arrayidx3_inputs_ready;
assign local_bb0_arrayidx3_stall_local = local_bb0_arrayidx3_stall_in;
assign merge_node_stall_in_0 = (|local_bb0_arrayidx3_stall_local);

// Register node:
//  * latency = 1
//  * capacity = 1
 logic rnode_1to2_bb0_arrayidx3_0_valid_out_0_NO_SHIFT_REG;
 logic rnode_1to2_bb0_arrayidx3_0_stall_in_0_NO_SHIFT_REG;
 logic [63:0] rnode_1to2_bb0_arrayidx3_0_NO_SHIFT_REG;
 logic rnode_1to2_bb0_arrayidx3_0_valid_out_1_NO_SHIFT_REG;
 logic rnode_1to2_bb0_arrayidx3_0_stall_in_1_NO_SHIFT_REG;
 logic [63:0] rnode_1to2_bb0_arrayidx3_1_NO_SHIFT_REG;
 logic rnode_1to2_bb0_arrayidx3_0_reg_2_inputs_ready_NO_SHIFT_REG;
 logic [63:0] rnode_1to2_bb0_arrayidx3_0_reg_2_NO_SHIFT_REG;
 logic rnode_1to2_bb0_arrayidx3_0_valid_out_0_reg_2_NO_SHIFT_REG;
 logic rnode_1to2_bb0_arrayidx3_0_stall_in_0_reg_2_NO_SHIFT_REG;
 logic rnode_1to2_bb0_arrayidx3_0_stall_out_reg_2_NO_SHIFT_REG;
 reg rnode_1to2_bb0_arrayidx3_0_consumed_0_NO_SHIFT_REG;
 reg rnode_1to2_bb0_arrayidx3_0_consumed_1_NO_SHIFT_REG;

acl_data_fifo rnode_1to2_bb0_arrayidx3_0_reg_2_fifo (
	.clock(clock),
	.resetn(resetn),
	.valid_in(rnode_1to2_bb0_arrayidx3_0_reg_2_inputs_ready_NO_SHIFT_REG),
	.stall_in(rnode_1to2_bb0_arrayidx3_0_stall_in_0_reg_2_NO_SHIFT_REG),
	.valid_out(rnode_1to2_bb0_arrayidx3_0_valid_out_0_reg_2_NO_SHIFT_REG),
	.stall_out(rnode_1to2_bb0_arrayidx3_0_stall_out_reg_2_NO_SHIFT_REG),
	.data_in((local_bb0_arrayidx3 & 64'hFFFFFFFFFFFFFFFC)),
	.data_out(rnode_1to2_bb0_arrayidx3_0_reg_2_NO_SHIFT_REG)
);

defparam rnode_1to2_bb0_arrayidx3_0_reg_2_fifo.DEPTH = 2;
defparam rnode_1to2_bb0_arrayidx3_0_reg_2_fifo.DATA_WIDTH = 64;
defparam rnode_1to2_bb0_arrayidx3_0_reg_2_fifo.ALLOW_FULL_WRITE = 0;
defparam rnode_1to2_bb0_arrayidx3_0_reg_2_fifo.IMPL = "ll_reg";

assign rnode_1to2_bb0_arrayidx3_0_reg_2_inputs_ready_NO_SHIFT_REG = local_bb0_arrayidx3_valid_out;
assign local_bb0_arrayidx3_stall_in = rnode_1to2_bb0_arrayidx3_0_stall_out_reg_2_NO_SHIFT_REG;
assign rnode_1to2_bb0_arrayidx3_0_stall_in_0_reg_2_NO_SHIFT_REG = ((rnode_1to2_bb0_arrayidx3_0_stall_in_0_NO_SHIFT_REG & ~(rnode_1to2_bb0_arrayidx3_0_consumed_0_NO_SHIFT_REG)) | (rnode_1to2_bb0_arrayidx3_0_stall_in_1_NO_SHIFT_REG & ~(rnode_1to2_bb0_arrayidx3_0_consumed_1_NO_SHIFT_REG)));
assign rnode_1to2_bb0_arrayidx3_0_valid_out_0_NO_SHIFT_REG = (rnode_1to2_bb0_arrayidx3_0_valid_out_0_reg_2_NO_SHIFT_REG & ~(rnode_1to2_bb0_arrayidx3_0_consumed_0_NO_SHIFT_REG));
assign rnode_1to2_bb0_arrayidx3_0_valid_out_1_NO_SHIFT_REG = (rnode_1to2_bb0_arrayidx3_0_valid_out_0_reg_2_NO_SHIFT_REG & ~(rnode_1to2_bb0_arrayidx3_0_consumed_1_NO_SHIFT_REG));
assign rnode_1to2_bb0_arrayidx3_0_NO_SHIFT_REG = rnode_1to2_bb0_arrayidx3_0_reg_2_NO_SHIFT_REG;
assign rnode_1to2_bb0_arrayidx3_1_NO_SHIFT_REG = rnode_1to2_bb0_arrayidx3_0_reg_2_NO_SHIFT_REG;

always @(posedge clock or negedge resetn)
begin
	if (~(resetn))
	begin
		rnode_1to2_bb0_arrayidx3_0_consumed_0_NO_SHIFT_REG <= 1'b0;
		rnode_1to2_bb0_arrayidx3_0_consumed_1_NO_SHIFT_REG <= 1'b0;
	end
	else
	begin
		rnode_1to2_bb0_arrayidx3_0_consumed_0_NO_SHIFT_REG <= (rnode_1to2_bb0_arrayidx3_0_valid_out_0_reg_2_NO_SHIFT_REG & (rnode_1to2_bb0_arrayidx3_0_consumed_0_NO_SHIFT_REG | ~(rnode_1to2_bb0_arrayidx3_0_stall_in_0_NO_SHIFT_REG)) & rnode_1to2_bb0_arrayidx3_0_stall_in_0_reg_2_NO_SHIFT_REG);
		rnode_1to2_bb0_arrayidx3_0_consumed_1_NO_SHIFT_REG <= (rnode_1to2_bb0_arrayidx3_0_valid_out_0_reg_2_NO_SHIFT_REG & (rnode_1to2_bb0_arrayidx3_0_consumed_1_NO_SHIFT_REG | ~(rnode_1to2_bb0_arrayidx3_0_stall_in_1_NO_SHIFT_REG)) & rnode_1to2_bb0_arrayidx3_0_stall_in_0_reg_2_NO_SHIFT_REG);
	end
end


// This section implements a registered operation.
// 
wire local_bb0_ld_arrayidx3_promoted_inputs_ready;
 reg local_bb0_ld_arrayidx3_promoted_valid_out_NO_SHIFT_REG;
wire local_bb0_ld_arrayidx3_promoted_stall_in;
wire local_bb0_ld_arrayidx3_promoted_output_regs_ready;
wire local_bb0_ld_arrayidx3_promoted_fu_stall_out;
wire local_bb0_ld_arrayidx3_promoted_fu_valid_out;
wire [31:0] local_bb0_ld_arrayidx3_promoted_lsu_dataout;
 reg [31:0] local_bb0_ld_arrayidx3_promoted_NO_SHIFT_REG;
wire local_bb0_ld_arrayidx3_promoted_causedstall;

lsu_top lsu_local_bb0_ld_arrayidx3_promoted (
	.clock(clock),
	.clock2x(clock2x),
	.resetn(resetn),
	.flush(start),
	.stream_base_addr((rnode_1to2_bb0_arrayidx3_0_NO_SHIFT_REG & 64'hFFFFFFFFFFFFFFFC)),
	.stream_size(input_global_size_0),
	.stream_reset(valid_in),
	.o_stall(local_bb0_ld_arrayidx3_promoted_fu_stall_out),
	.i_valid(local_bb0_ld_arrayidx3_promoted_inputs_ready),
	.i_address((rnode_1to2_bb0_arrayidx3_0_NO_SHIFT_REG & 64'hFFFFFFFFFFFFFFFC)),
	.i_writedata(),
	.i_cmpdata(),
	.i_predicate(1'b0),
	.i_bitwiseor(64'h0),
	.i_byteenable(),
	.i_stall(~(local_bb0_ld_arrayidx3_promoted_output_regs_ready)),
	.o_valid(local_bb0_ld_arrayidx3_promoted_fu_valid_out),
	.o_readdata(local_bb0_ld_arrayidx3_promoted_lsu_dataout),
	.o_input_fifo_depth(),
	.o_writeack(),
	.i_atomic_op(3'h0),
	.o_active(local_bb0_ld_arrayidx3_promoted_active),
	.avm_address(avm_local_bb0_ld_arrayidx3_promoted_address),
	.avm_read(avm_local_bb0_ld_arrayidx3_promoted_read),
	.avm_enable(avm_local_bb0_ld_arrayidx3_promoted_enable),
	.avm_readdata(avm_local_bb0_ld_arrayidx3_promoted_readdata),
	.avm_write(avm_local_bb0_ld_arrayidx3_promoted_write),
	.avm_writeack(avm_local_bb0_ld_arrayidx3_promoted_writeack),
	.avm_burstcount(avm_local_bb0_ld_arrayidx3_promoted_burstcount),
	.avm_writedata(avm_local_bb0_ld_arrayidx3_promoted_writedata),
	.avm_byteenable(avm_local_bb0_ld_arrayidx3_promoted_byteenable),
	.avm_waitrequest(avm_local_bb0_ld_arrayidx3_promoted_waitrequest),
	.avm_readdatavalid(avm_local_bb0_ld_arrayidx3_promoted_readdatavalid),
	.profile_bw(),
	.profile_bw_incr(),
	.profile_total_ivalid(),
	.profile_total_req(),
	.profile_i_stall_count(),
	.profile_o_stall_count(),
	.profile_avm_readwrite_count(),
	.profile_avm_burstcount_total(),
	.profile_avm_burstcount_total_incr(),
	.profile_req_cache_hit_count(),
	.profile_extra_unaligned_reqs(),
	.profile_avm_stall()
);

defparam lsu_local_bb0_ld_arrayidx3_promoted.AWIDTH = 28;
defparam lsu_local_bb0_ld_arrayidx3_promoted.WIDTH_BYTES = 4;
defparam lsu_local_bb0_ld_arrayidx3_promoted.MWIDTH_BYTES = 64;
defparam lsu_local_bb0_ld_arrayidx3_promoted.WRITEDATAWIDTH_BYTES = 64;
defparam lsu_local_bb0_ld_arrayidx3_promoted.ALIGNMENT_BYTES = 4;
defparam lsu_local_bb0_ld_arrayidx3_promoted.READ = 1;
defparam lsu_local_bb0_ld_arrayidx3_promoted.ATOMIC = 0;
defparam lsu_local_bb0_ld_arrayidx3_promoted.WIDTH = 32;
defparam lsu_local_bb0_ld_arrayidx3_promoted.MWIDTH = 512;
defparam lsu_local_bb0_ld_arrayidx3_promoted.ATOMIC_WIDTH = 3;
defparam lsu_local_bb0_ld_arrayidx3_promoted.BURSTCOUNT_WIDTH = 6;
defparam lsu_local_bb0_ld_arrayidx3_promoted.KERNEL_SIDE_MEM_LATENCY = 2;
defparam lsu_local_bb0_ld_arrayidx3_promoted.MEMORY_SIDE_MEM_LATENCY = 131;
defparam lsu_local_bb0_ld_arrayidx3_promoted.USE_WRITE_ACK = 0;
defparam lsu_local_bb0_ld_arrayidx3_promoted.ENABLE_BANKED_MEMORY = 0;
defparam lsu_local_bb0_ld_arrayidx3_promoted.ABITS_PER_LMEM_BANK = 0;
defparam lsu_local_bb0_ld_arrayidx3_promoted.NUMBER_BANKS = 1;
defparam lsu_local_bb0_ld_arrayidx3_promoted.LMEM_ADDR_PERMUTATION_STYLE = 0;
defparam lsu_local_bb0_ld_arrayidx3_promoted.INTENDED_DEVICE_FAMILY = "Stratix V";
defparam lsu_local_bb0_ld_arrayidx3_promoted.USEINPUTFIFO = 0;
defparam lsu_local_bb0_ld_arrayidx3_promoted.USECACHING = 0;
defparam lsu_local_bb0_ld_arrayidx3_promoted.USEOUTPUTFIFO = 1;
defparam lsu_local_bb0_ld_arrayidx3_promoted.FORCE_NOP_SUPPORT = 0;
defparam lsu_local_bb0_ld_arrayidx3_promoted.HIGH_FMAX = 1;
defparam lsu_local_bb0_ld_arrayidx3_promoted.ADDRSPACE = 1;
defparam lsu_local_bb0_ld_arrayidx3_promoted.STYLE = "STREAMING";

assign local_bb0_ld_arrayidx3_promoted_inputs_ready = rnode_1to2_bb0_arrayidx3_0_valid_out_0_NO_SHIFT_REG;
assign local_bb0_ld_arrayidx3_promoted_output_regs_ready = (&(~(local_bb0_ld_arrayidx3_promoted_valid_out_NO_SHIFT_REG) | ~(local_bb0_ld_arrayidx3_promoted_stall_in)));
assign rnode_1to2_bb0_arrayidx3_0_stall_in_0_NO_SHIFT_REG = (local_bb0_ld_arrayidx3_promoted_fu_stall_out | ~(local_bb0_ld_arrayidx3_promoted_inputs_ready));
assign local_bb0_ld_arrayidx3_promoted_causedstall = (local_bb0_ld_arrayidx3_promoted_inputs_ready && (local_bb0_ld_arrayidx3_promoted_fu_stall_out && !(~(local_bb0_ld_arrayidx3_promoted_output_regs_ready))));

always @(posedge clock or negedge resetn)
begin
	if (~(resetn))
	begin
		local_bb0_ld_arrayidx3_promoted_NO_SHIFT_REG <= 'x;
		local_bb0_ld_arrayidx3_promoted_valid_out_NO_SHIFT_REG <= 1'b0;
	end
	else
	begin
		if (local_bb0_ld_arrayidx3_promoted_output_regs_ready)
		begin
			local_bb0_ld_arrayidx3_promoted_NO_SHIFT_REG <= local_bb0_ld_arrayidx3_promoted_lsu_dataout;
			local_bb0_ld_arrayidx3_promoted_valid_out_NO_SHIFT_REG <= local_bb0_ld_arrayidx3_promoted_fu_valid_out;
		end
		else
		begin
			if (~(local_bb0_ld_arrayidx3_promoted_stall_in))
			begin
				local_bb0_ld_arrayidx3_promoted_valid_out_NO_SHIFT_REG <= 1'b0;
			end
		end
	end
end


// Register node:
//  * latency = 2
//  * capacity = 2
 logic rnode_2to4_bb0_arrayidx3_0_valid_out_NO_SHIFT_REG;
 logic rnode_2to4_bb0_arrayidx3_0_stall_in_NO_SHIFT_REG;
 logic [63:0] rnode_2to4_bb0_arrayidx3_0_NO_SHIFT_REG;
 logic rnode_2to4_bb0_arrayidx3_0_reg_4_inputs_ready_NO_SHIFT_REG;
 logic [63:0] rnode_2to4_bb0_arrayidx3_0_reg_4_NO_SHIFT_REG;
 logic rnode_2to4_bb0_arrayidx3_0_valid_out_reg_4_NO_SHIFT_REG;
 logic rnode_2to4_bb0_arrayidx3_0_stall_in_reg_4_NO_SHIFT_REG;
 logic rnode_2to4_bb0_arrayidx3_0_stall_out_reg_4_NO_SHIFT_REG;

acl_data_fifo rnode_2to4_bb0_arrayidx3_0_reg_4_fifo (
	.clock(clock),
	.resetn(resetn),
	.valid_in(rnode_2to4_bb0_arrayidx3_0_reg_4_inputs_ready_NO_SHIFT_REG),
	.stall_in(rnode_2to4_bb0_arrayidx3_0_stall_in_reg_4_NO_SHIFT_REG),
	.valid_out(rnode_2to4_bb0_arrayidx3_0_valid_out_reg_4_NO_SHIFT_REG),
	.stall_out(rnode_2to4_bb0_arrayidx3_0_stall_out_reg_4_NO_SHIFT_REG),
	.data_in((rnode_1to2_bb0_arrayidx3_1_NO_SHIFT_REG & 64'hFFFFFFFFFFFFFFFC)),
	.data_out(rnode_2to4_bb0_arrayidx3_0_reg_4_NO_SHIFT_REG)
);

defparam rnode_2to4_bb0_arrayidx3_0_reg_4_fifo.DEPTH = 3;
defparam rnode_2to4_bb0_arrayidx3_0_reg_4_fifo.DATA_WIDTH = 64;
defparam rnode_2to4_bb0_arrayidx3_0_reg_4_fifo.ALLOW_FULL_WRITE = 0;
defparam rnode_2to4_bb0_arrayidx3_0_reg_4_fifo.IMPL = "ll_reg";

assign rnode_2to4_bb0_arrayidx3_0_reg_4_inputs_ready_NO_SHIFT_REG = rnode_1to2_bb0_arrayidx3_0_valid_out_1_NO_SHIFT_REG;
assign rnode_1to2_bb0_arrayidx3_0_stall_in_1_NO_SHIFT_REG = rnode_2to4_bb0_arrayidx3_0_stall_out_reg_4_NO_SHIFT_REG;
assign rnode_2to4_bb0_arrayidx3_0_NO_SHIFT_REG = rnode_2to4_bb0_arrayidx3_0_reg_4_NO_SHIFT_REG;
assign rnode_2to4_bb0_arrayidx3_0_stall_in_reg_4_NO_SHIFT_REG = rnode_2to4_bb0_arrayidx3_0_stall_in_NO_SHIFT_REG;
assign rnode_2to4_bb0_arrayidx3_0_valid_out_NO_SHIFT_REG = rnode_2to4_bb0_arrayidx3_0_valid_out_reg_4_NO_SHIFT_REG;

// This section implements a staging register.
// 
wire rstag_4to4_bb0_ld_arrayidx3_promoted_valid_out;
wire rstag_4to4_bb0_ld_arrayidx3_promoted_stall_in;
wire rstag_4to4_bb0_ld_arrayidx3_promoted_inputs_ready;
wire rstag_4to4_bb0_ld_arrayidx3_promoted_stall_local;
 reg rstag_4to4_bb0_ld_arrayidx3_promoted_staging_valid_NO_SHIFT_REG;
wire rstag_4to4_bb0_ld_arrayidx3_promoted_combined_valid;
 reg [31:0] rstag_4to4_bb0_ld_arrayidx3_promoted_staging_reg_NO_SHIFT_REG;
wire [31:0] rstag_4to4_bb0_ld_arrayidx3_promoted;

assign rstag_4to4_bb0_ld_arrayidx3_promoted_inputs_ready = local_bb0_ld_arrayidx3_promoted_valid_out_NO_SHIFT_REG;
assign rstag_4to4_bb0_ld_arrayidx3_promoted = (rstag_4to4_bb0_ld_arrayidx3_promoted_staging_valid_NO_SHIFT_REG ? rstag_4to4_bb0_ld_arrayidx3_promoted_staging_reg_NO_SHIFT_REG : local_bb0_ld_arrayidx3_promoted_NO_SHIFT_REG);
assign rstag_4to4_bb0_ld_arrayidx3_promoted_combined_valid = (rstag_4to4_bb0_ld_arrayidx3_promoted_staging_valid_NO_SHIFT_REG | rstag_4to4_bb0_ld_arrayidx3_promoted_inputs_ready);
assign rstag_4to4_bb0_ld_arrayidx3_promoted_valid_out = rstag_4to4_bb0_ld_arrayidx3_promoted_combined_valid;
assign rstag_4to4_bb0_ld_arrayidx3_promoted_stall_local = rstag_4to4_bb0_ld_arrayidx3_promoted_stall_in;
assign local_bb0_ld_arrayidx3_promoted_stall_in = (|rstag_4to4_bb0_ld_arrayidx3_promoted_staging_valid_NO_SHIFT_REG);

always @(posedge clock or negedge resetn)
begin
	if (~(resetn))
	begin
		rstag_4to4_bb0_ld_arrayidx3_promoted_staging_valid_NO_SHIFT_REG <= 1'b0;
		rstag_4to4_bb0_ld_arrayidx3_promoted_staging_reg_NO_SHIFT_REG <= 'x;
	end
	else
	begin
		if (rstag_4to4_bb0_ld_arrayidx3_promoted_stall_local)
		begin
			if (~(rstag_4to4_bb0_ld_arrayidx3_promoted_staging_valid_NO_SHIFT_REG))
			begin
				rstag_4to4_bb0_ld_arrayidx3_promoted_staging_valid_NO_SHIFT_REG <= rstag_4to4_bb0_ld_arrayidx3_promoted_inputs_ready;
			end
		end
		else
		begin
			rstag_4to4_bb0_ld_arrayidx3_promoted_staging_valid_NO_SHIFT_REG <= 1'b0;
		end
		if (~(rstag_4to4_bb0_ld_arrayidx3_promoted_staging_valid_NO_SHIFT_REG))
		begin
			rstag_4to4_bb0_ld_arrayidx3_promoted_staging_reg_NO_SHIFT_REG <= local_bb0_ld_arrayidx3_promoted_NO_SHIFT_REG;
		end
	end
end


// This section describes the behaviour of the BRANCH node.
wire branch_var__inputs_ready;
 reg branch_node_valid_out_NO_SHIFT_REG;
wire branch_var__output_regs_ready;
wire combined_branch_stall_in_signal;
 reg [63:0] lvb_bb0_arrayidx3_reg_NO_SHIFT_REG;
 reg [31:0] lvb_bb0_ld_arrayidx3_promoted_reg_NO_SHIFT_REG;
 reg [31:0] lvb_input_global_id_0_reg_NO_SHIFT_REG;
 reg [31:0] lvb_input_acl_hw_wg_id_reg_NO_SHIFT_REG;

assign branch_var__inputs_ready = (rnode_2to4_bb0_arrayidx3_0_valid_out_NO_SHIFT_REG & rcnode_1to4_rc1_input_global_id_0_0_valid_out_NO_SHIFT_REG & rstag_4to4_bb0_ld_arrayidx3_promoted_valid_out);
assign branch_var__output_regs_ready = (~(stall_in) | ~(branch_node_valid_out_NO_SHIFT_REG));
assign rnode_2to4_bb0_arrayidx3_0_stall_in_NO_SHIFT_REG = (~(branch_var__output_regs_ready) | ~(branch_var__inputs_ready));
assign rcnode_1to4_rc1_input_global_id_0_0_stall_in_NO_SHIFT_REG = (~(branch_var__output_regs_ready) | ~(branch_var__inputs_ready));
assign rstag_4to4_bb0_ld_arrayidx3_promoted_stall_in = (~(branch_var__output_regs_ready) | ~(branch_var__inputs_ready));
assign lvb_bb0_arrayidx3 = lvb_bb0_arrayidx3_reg_NO_SHIFT_REG;
assign lvb_bb0_ld_arrayidx3_promoted = lvb_bb0_ld_arrayidx3_promoted_reg_NO_SHIFT_REG;
assign lvb_input_global_id_0 = lvb_input_global_id_0_reg_NO_SHIFT_REG;
assign lvb_input_acl_hw_wg_id = lvb_input_acl_hw_wg_id_reg_NO_SHIFT_REG;
assign combined_branch_stall_in_signal = stall_in;
assign valid_out = branch_node_valid_out_NO_SHIFT_REG;

always @(posedge clock or negedge resetn)
begin
	if (~(resetn))
	begin
		branch_node_valid_out_NO_SHIFT_REG <= 1'b0;
		lvb_bb0_arrayidx3_reg_NO_SHIFT_REG <= 'x;
		lvb_bb0_ld_arrayidx3_promoted_reg_NO_SHIFT_REG <= 'x;
		lvb_input_global_id_0_reg_NO_SHIFT_REG <= 'x;
		lvb_input_acl_hw_wg_id_reg_NO_SHIFT_REG <= 'x;
	end
	else
	begin
		if (branch_var__output_regs_ready)
		begin
			branch_node_valid_out_NO_SHIFT_REG <= branch_var__inputs_ready;
			lvb_bb0_arrayidx3_reg_NO_SHIFT_REG <= (rnode_2to4_bb0_arrayidx3_0_NO_SHIFT_REG & 64'hFFFFFFFFFFFFFFFC);
			lvb_bb0_ld_arrayidx3_promoted_reg_NO_SHIFT_REG <= rstag_4to4_bb0_ld_arrayidx3_promoted;
			lvb_input_global_id_0_reg_NO_SHIFT_REG <= rcnode_1to4_rc1_input_global_id_0_0_NO_SHIFT_REG[31:0];
			lvb_input_acl_hw_wg_id_reg_NO_SHIFT_REG <= rcnode_1to4_rc1_input_global_id_0_0_NO_SHIFT_REG[63:32];
		end
		else
		begin
			if (~(combined_branch_stall_in_signal))
			begin
				branch_node_valid_out_NO_SHIFT_REG <= 1'b0;
			end
		end
	end
end


endmodule

//////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////

// altera message_off 10036
// altera message_off 10230
// altera message_off 10858
module sumOfElements_basic_block_1
	(
		input 		clock,
		input 		resetn,
		input [63:0] 		input_A,
		input [31:0] 		input_N,
		input 		valid_in_0,
		output 		stall_out_0,
		input [63:0] 		input_arrayidx3_0,
		input [31:0] 		input_add3_0,
		input [31:0] 		input_i_02_0,
		input [31:0] 		input_global_id_0_0,
		input [31:0] 		input_acl_hw_wg_id_0,
		input 		valid_in_1,
		output 		stall_out_1,
		input [63:0] 		input_arrayidx3_1,
		input [31:0] 		input_add3_1,
		input [31:0] 		input_i_02_1,
		input [31:0] 		input_global_id_0_1,
		input [31:0] 		input_acl_hw_wg_id_1,
		output 		valid_out_0,
		input 		stall_in_0,
		output [63:0] 		lvb_arrayidx3_0,
		output 		lvb_bb1_cmp1_NEG_RM_0,
		output [31:0] 		lvb_bb1_add_0,
		output [31:0] 		lvb_bb1_inc_0,
		output [31:0] 		lvb_input_global_id_0_0,
		output [31:0] 		lvb_input_acl_hw_wg_id_0,
		output 		valid_out_1,
		input 		stall_in_1,
		output [63:0] 		lvb_arrayidx3_1,
		output 		lvb_bb1_cmp1_NEG_RM_1,
		output [31:0] 		lvb_bb1_add_1,
		output [31:0] 		lvb_bb1_inc_1,
		output [31:0] 		lvb_input_global_id_0_1,
		output [31:0] 		lvb_input_acl_hw_wg_id_1,
		input [31:0] 		workgroup_size,
		input 		start,
		output 		avm_local_bb1_ld__enable,
		input [511:0] 		avm_local_bb1_ld__readdata,
		input 		avm_local_bb1_ld__readdatavalid,
		input 		avm_local_bb1_ld__waitrequest,
		output [27:0] 		avm_local_bb1_ld__address,
		output 		avm_local_bb1_ld__read,
		output 		avm_local_bb1_ld__write,
		input 		avm_local_bb1_ld__writeack,
		output [511:0] 		avm_local_bb1_ld__writedata,
		output [63:0] 		avm_local_bb1_ld__byteenable,
		output [5:0] 		avm_local_bb1_ld__burstcount,
		output 		local_bb1_ld__active,
		input 		clock2x
	);


// Values used for debugging.  These are swept away by synthesis.
wire _entry;
wire _exit;
 reg [31:0] _num_entry_NO_SHIFT_REG;
 reg [31:0] _num_exit_NO_SHIFT_REG;
wire [31:0] _num_live;

assign _entry = ((valid_in_0 & valid_in_1) & ~((stall_out_0 | stall_out_1)));
assign _exit = ((valid_out_0 & valid_out_1) & ~((stall_in_0 | stall_in_1)));
assign _num_live = (_num_entry_NO_SHIFT_REG - _num_exit_NO_SHIFT_REG);

always @(posedge clock or negedge resetn)
begin
	if (~(resetn))
	begin
		_num_entry_NO_SHIFT_REG <= 32'h0;
		_num_exit_NO_SHIFT_REG <= 32'h0;
	end
	else
	begin
		if (_entry)
		begin
			_num_entry_NO_SHIFT_REG <= (_num_entry_NO_SHIFT_REG + 2'h1);
		end
		if (_exit)
		begin
			_num_exit_NO_SHIFT_REG <= (_num_exit_NO_SHIFT_REG + 2'h1);
		end
	end
end



// This section defines the behaviour of the MERGE node
wire merge_node_stall_in_0;
 reg merge_node_valid_out_0_NO_SHIFT_REG;
wire merge_node_stall_in_1;
 reg merge_node_valid_out_1_NO_SHIFT_REG;
wire merge_node_stall_in_2;
 reg merge_node_valid_out_2_NO_SHIFT_REG;
wire merge_node_stall_in_3;
 reg merge_node_valid_out_3_NO_SHIFT_REG;
wire merge_node_stall_in_4;
 reg merge_node_valid_out_4_NO_SHIFT_REG;
wire merge_stalled_by_successors;
 reg merge_block_selector_NO_SHIFT_REG;
 reg merge_node_valid_in_0_staging_reg_NO_SHIFT_REG;
 reg [63:0] input_arrayidx3_0_staging_reg_NO_SHIFT_REG;
 reg [31:0] input_add3_0_staging_reg_NO_SHIFT_REG;
 reg [31:0] input_i_02_0_staging_reg_NO_SHIFT_REG;
 reg [31:0] input_global_id_0_0_staging_reg_NO_SHIFT_REG;
 reg [31:0] input_acl_hw_wg_id_0_staging_reg_NO_SHIFT_REG;
 reg [63:0] local_lvm_arrayidx3_NO_SHIFT_REG;
 reg [31:0] local_lvm_add3_NO_SHIFT_REG;
 reg [31:0] local_lvm_i_02_NO_SHIFT_REG;
 reg [31:0] local_lvm_input_global_id_0_NO_SHIFT_REG;
 reg [31:0] local_lvm_input_acl_hw_wg_id_NO_SHIFT_REG;
 reg merge_node_valid_in_1_staging_reg_NO_SHIFT_REG;
 reg [63:0] input_arrayidx3_1_staging_reg_NO_SHIFT_REG;
 reg [31:0] input_add3_1_staging_reg_NO_SHIFT_REG;
 reg [31:0] input_i_02_1_staging_reg_NO_SHIFT_REG;
 reg [31:0] input_global_id_0_1_staging_reg_NO_SHIFT_REG;
 reg [31:0] input_acl_hw_wg_id_1_staging_reg_NO_SHIFT_REG;
 reg is_merge_data_to_local_regs_valid_NO_SHIFT_REG;
 reg invariant_valid_NO_SHIFT_REG;

assign merge_stalled_by_successors = ((merge_node_stall_in_0 & merge_node_valid_out_0_NO_SHIFT_REG) | (merge_node_stall_in_1 & merge_node_valid_out_1_NO_SHIFT_REG) | (merge_node_stall_in_2 & merge_node_valid_out_2_NO_SHIFT_REG) | (merge_node_stall_in_3 & merge_node_valid_out_3_NO_SHIFT_REG) | (merge_node_stall_in_4 & merge_node_valid_out_4_NO_SHIFT_REG));
assign stall_out_0 = merge_node_valid_in_0_staging_reg_NO_SHIFT_REG;
assign stall_out_1 = merge_node_valid_in_1_staging_reg_NO_SHIFT_REG;

always @(*)
begin
	if ((merge_node_valid_in_0_staging_reg_NO_SHIFT_REG | valid_in_0))
	begin
		merge_block_selector_NO_SHIFT_REG = 1'b0;
		is_merge_data_to_local_regs_valid_NO_SHIFT_REG = 1'b1;
	end
	else
	begin
		if ((merge_node_valid_in_1_staging_reg_NO_SHIFT_REG | valid_in_1))
		begin
			merge_block_selector_NO_SHIFT_REG = 1'b1;
			is_merge_data_to_local_regs_valid_NO_SHIFT_REG = 1'b1;
		end
		else
		begin
			merge_block_selector_NO_SHIFT_REG = 1'b0;
			is_merge_data_to_local_regs_valid_NO_SHIFT_REG = 1'b0;
		end
	end
end

always @(posedge clock or negedge resetn)
begin
	if (~(resetn))
	begin
		input_arrayidx3_0_staging_reg_NO_SHIFT_REG <= 'x;
		input_add3_0_staging_reg_NO_SHIFT_REG <= 'x;
		input_i_02_0_staging_reg_NO_SHIFT_REG <= 'x;
		input_global_id_0_0_staging_reg_NO_SHIFT_REG <= 'x;
		input_acl_hw_wg_id_0_staging_reg_NO_SHIFT_REG <= 'x;
		merge_node_valid_in_0_staging_reg_NO_SHIFT_REG <= 1'b0;
		input_arrayidx3_1_staging_reg_NO_SHIFT_REG <= 'x;
		input_add3_1_staging_reg_NO_SHIFT_REG <= 'x;
		input_i_02_1_staging_reg_NO_SHIFT_REG <= 'x;
		input_global_id_0_1_staging_reg_NO_SHIFT_REG <= 'x;
		input_acl_hw_wg_id_1_staging_reg_NO_SHIFT_REG <= 'x;
		merge_node_valid_in_1_staging_reg_NO_SHIFT_REG <= 1'b0;
	end
	else
	begin
		if (((merge_block_selector_NO_SHIFT_REG != 1'b0) | merge_stalled_by_successors))
		begin
			if (~(merge_node_valid_in_0_staging_reg_NO_SHIFT_REG))
			begin
				input_arrayidx3_0_staging_reg_NO_SHIFT_REG <= input_arrayidx3_0;
				input_add3_0_staging_reg_NO_SHIFT_REG <= input_add3_0;
				input_i_02_0_staging_reg_NO_SHIFT_REG <= input_i_02_0;
				input_global_id_0_0_staging_reg_NO_SHIFT_REG <= input_global_id_0_0;
				input_acl_hw_wg_id_0_staging_reg_NO_SHIFT_REG <= input_acl_hw_wg_id_0;
				merge_node_valid_in_0_staging_reg_NO_SHIFT_REG <= valid_in_0;
			end
		end
		else
		begin
			merge_node_valid_in_0_staging_reg_NO_SHIFT_REG <= 1'b0;
		end
		if (((merge_block_selector_NO_SHIFT_REG != 1'b1) | merge_stalled_by_successors))
		begin
			if (~(merge_node_valid_in_1_staging_reg_NO_SHIFT_REG))
			begin
				input_arrayidx3_1_staging_reg_NO_SHIFT_REG <= input_arrayidx3_1;
				input_add3_1_staging_reg_NO_SHIFT_REG <= input_add3_1;
				input_i_02_1_staging_reg_NO_SHIFT_REG <= input_i_02_1;
				input_global_id_0_1_staging_reg_NO_SHIFT_REG <= input_global_id_0_1;
				input_acl_hw_wg_id_1_staging_reg_NO_SHIFT_REG <= input_acl_hw_wg_id_1;
				merge_node_valid_in_1_staging_reg_NO_SHIFT_REG <= valid_in_1;
			end
		end
		else
		begin
			merge_node_valid_in_1_staging_reg_NO_SHIFT_REG <= 1'b0;
		end
	end
end

always @(posedge clock)
begin
	if (~(merge_stalled_by_successors))
	begin
		case (merge_block_selector_NO_SHIFT_REG)
			1'b0:
			begin
				if (merge_node_valid_in_0_staging_reg_NO_SHIFT_REG)
				begin
					local_lvm_arrayidx3_NO_SHIFT_REG <= input_arrayidx3_0_staging_reg_NO_SHIFT_REG;
					local_lvm_add3_NO_SHIFT_REG <= input_add3_0_staging_reg_NO_SHIFT_REG;
					local_lvm_i_02_NO_SHIFT_REG <= input_i_02_0_staging_reg_NO_SHIFT_REG;
					local_lvm_input_global_id_0_NO_SHIFT_REG <= input_global_id_0_0_staging_reg_NO_SHIFT_REG;
					local_lvm_input_acl_hw_wg_id_NO_SHIFT_REG <= input_acl_hw_wg_id_0_staging_reg_NO_SHIFT_REG;
				end
				else
				begin
					local_lvm_arrayidx3_NO_SHIFT_REG <= input_arrayidx3_0;
					local_lvm_add3_NO_SHIFT_REG <= input_add3_0;
					local_lvm_i_02_NO_SHIFT_REG <= input_i_02_0;
					local_lvm_input_global_id_0_NO_SHIFT_REG <= input_global_id_0_0;
					local_lvm_input_acl_hw_wg_id_NO_SHIFT_REG <= input_acl_hw_wg_id_0;
				end
			end

			1'b1:
			begin
				if (merge_node_valid_in_1_staging_reg_NO_SHIFT_REG)
				begin
					local_lvm_arrayidx3_NO_SHIFT_REG <= input_arrayidx3_1_staging_reg_NO_SHIFT_REG;
					local_lvm_add3_NO_SHIFT_REG <= input_add3_1_staging_reg_NO_SHIFT_REG;
					local_lvm_i_02_NO_SHIFT_REG <= input_i_02_1_staging_reg_NO_SHIFT_REG;
					local_lvm_input_global_id_0_NO_SHIFT_REG <= input_global_id_0_1_staging_reg_NO_SHIFT_REG;
					local_lvm_input_acl_hw_wg_id_NO_SHIFT_REG <= input_acl_hw_wg_id_1_staging_reg_NO_SHIFT_REG;
				end
				else
				begin
					local_lvm_arrayidx3_NO_SHIFT_REG <= input_arrayidx3_1;
					local_lvm_add3_NO_SHIFT_REG <= input_add3_1;
					local_lvm_i_02_NO_SHIFT_REG <= input_i_02_1;
					local_lvm_input_global_id_0_NO_SHIFT_REG <= input_global_id_0_1;
					local_lvm_input_acl_hw_wg_id_NO_SHIFT_REG <= input_acl_hw_wg_id_1;
				end
			end

			default:
			begin
			end

		endcase
	end
end

always @(posedge clock or negedge resetn)
begin
	if (~(resetn))
	begin
		merge_node_valid_out_0_NO_SHIFT_REG <= 1'b0;
		merge_node_valid_out_1_NO_SHIFT_REG <= 1'b0;
		merge_node_valid_out_2_NO_SHIFT_REG <= 1'b0;
		merge_node_valid_out_3_NO_SHIFT_REG <= 1'b0;
		merge_node_valid_out_4_NO_SHIFT_REG <= 1'b0;
	end
	else
	begin
		if (~(merge_stalled_by_successors))
		begin
			merge_node_valid_out_0_NO_SHIFT_REG <= is_merge_data_to_local_regs_valid_NO_SHIFT_REG;
			merge_node_valid_out_1_NO_SHIFT_REG <= is_merge_data_to_local_regs_valid_NO_SHIFT_REG;
			merge_node_valid_out_2_NO_SHIFT_REG <= is_merge_data_to_local_regs_valid_NO_SHIFT_REG;
			merge_node_valid_out_3_NO_SHIFT_REG <= is_merge_data_to_local_regs_valid_NO_SHIFT_REG;
			merge_node_valid_out_4_NO_SHIFT_REG <= is_merge_data_to_local_regs_valid_NO_SHIFT_REG;
		end
		else
		begin
			if (~(merge_node_stall_in_0))
			begin
				merge_node_valid_out_0_NO_SHIFT_REG <= 1'b0;
			end
			if (~(merge_node_stall_in_1))
			begin
				merge_node_valid_out_1_NO_SHIFT_REG <= 1'b0;
			end
			if (~(merge_node_stall_in_2))
			begin
				merge_node_valid_out_2_NO_SHIFT_REG <= 1'b0;
			end
			if (~(merge_node_stall_in_3))
			begin
				merge_node_valid_out_3_NO_SHIFT_REG <= 1'b0;
			end
			if (~(merge_node_stall_in_4))
			begin
				merge_node_valid_out_4_NO_SHIFT_REG <= 1'b0;
			end
		end
	end
end

always @(posedge clock or negedge resetn)
begin
	if (~(resetn))
	begin
		invariant_valid_NO_SHIFT_REG <= 1'b0;
	end
	else
	begin
		invariant_valid_NO_SHIFT_REG <= (~(start) & (invariant_valid_NO_SHIFT_REG | is_merge_data_to_local_regs_valid_NO_SHIFT_REG));
	end
end


// This section implements an unregistered operation.
// 
wire local_bb1_idxprom_stall_local;
wire [63:0] local_bb1_idxprom;

assign local_bb1_idxprom[63:32] = 32'h0;
assign local_bb1_idxprom[31:0] = local_lvm_i_02_NO_SHIFT_REG;

// This section implements an unregistered operation.
// 
wire local_bb1_cmp1_NEG_RM_valid_out;
wire local_bb1_cmp1_NEG_RM_stall_in;
wire local_bb1_cmp1_NEG_RM_inputs_ready;
wire local_bb1_cmp1_NEG_RM_stall_local;
wire local_bb1_cmp1_NEG_RM;

assign local_bb1_cmp1_NEG_RM_inputs_ready = merge_node_valid_out_1_NO_SHIFT_REG;
assign local_bb1_cmp1_NEG_RM = (local_lvm_input_global_id_0_NO_SHIFT_REG >= input_N);
assign local_bb1_cmp1_NEG_RM_valid_out = local_bb1_cmp1_NEG_RM_inputs_ready;
assign local_bb1_cmp1_NEG_RM_stall_local = local_bb1_cmp1_NEG_RM_stall_in;
assign merge_node_stall_in_1 = (|local_bb1_cmp1_NEG_RM_stall_local);

// This section implements an unregistered operation.
// 
wire local_bb1_inc_valid_out;
wire local_bb1_inc_stall_in;
wire local_bb1_inc_inputs_ready;
wire local_bb1_inc_stall_local;
wire [31:0] local_bb1_inc;

assign local_bb1_inc_inputs_ready = merge_node_valid_out_2_NO_SHIFT_REG;
assign local_bb1_inc = (local_lvm_i_02_NO_SHIFT_REG + 32'h1);
assign local_bb1_inc_valid_out = local_bb1_inc_inputs_ready;
assign local_bb1_inc_stall_local = local_bb1_inc_stall_in;
assign merge_node_stall_in_2 = (|local_bb1_inc_stall_local);

// Register node:
//  * latency = 160
//  * capacity = 160
 logic rnode_1to161_add3_0_valid_out_NO_SHIFT_REG;
 logic rnode_1to161_add3_0_stall_in_NO_SHIFT_REG;
 logic [31:0] rnode_1to161_add3_0_NO_SHIFT_REG;
 logic rnode_1to161_add3_0_reg_161_inputs_ready_NO_SHIFT_REG;
 logic [31:0] rnode_1to161_add3_0_reg_161_NO_SHIFT_REG;
 logic rnode_1to161_add3_0_valid_out_reg_161_NO_SHIFT_REG;
 logic rnode_1to161_add3_0_stall_in_reg_161_NO_SHIFT_REG;
 logic rnode_1to161_add3_0_stall_out_reg_161_NO_SHIFT_REG;
wire [127:0] rci_rcnode_1to161_rc4_arrayidx3_0_reg_1;

acl_data_fifo rnode_1to161_add3_0_reg_161_fifo (
	.clock(clock),
	.resetn(resetn),
	.valid_in(rnode_1to161_add3_0_reg_161_inputs_ready_NO_SHIFT_REG),
	.stall_in(rnode_1to161_add3_0_stall_in_reg_161_NO_SHIFT_REG),
	.valid_out(rnode_1to161_add3_0_valid_out_reg_161_NO_SHIFT_REG),
	.stall_out(rnode_1to161_add3_0_stall_out_reg_161_NO_SHIFT_REG),
	.data_in(local_lvm_add3_NO_SHIFT_REG),
	.data_out(rnode_1to161_add3_0_reg_161_NO_SHIFT_REG)
);

defparam rnode_1to161_add3_0_reg_161_fifo.DEPTH = 161;
defparam rnode_1to161_add3_0_reg_161_fifo.DATA_WIDTH = 32;
defparam rnode_1to161_add3_0_reg_161_fifo.ALLOW_FULL_WRITE = 0;
defparam rnode_1to161_add3_0_reg_161_fifo.IMPL = "ram";

assign rnode_1to161_add3_0_reg_161_inputs_ready_NO_SHIFT_REG = merge_node_valid_out_3_NO_SHIFT_REG;
assign merge_node_stall_in_3 = rnode_1to161_add3_0_stall_out_reg_161_NO_SHIFT_REG;
assign rnode_1to161_add3_0_NO_SHIFT_REG = rnode_1to161_add3_0_reg_161_NO_SHIFT_REG;
assign rnode_1to161_add3_0_stall_in_reg_161_NO_SHIFT_REG = rnode_1to161_add3_0_stall_in_NO_SHIFT_REG;
assign rnode_1to161_add3_0_valid_out_NO_SHIFT_REG = rnode_1to161_add3_0_valid_out_reg_161_NO_SHIFT_REG;
assign rci_rcnode_1to161_rc4_arrayidx3_0_reg_1[63:0] = (local_lvm_arrayidx3_NO_SHIFT_REG & 64'hFFFFFFFFFFFFFFFC);
assign rci_rcnode_1to161_rc4_arrayidx3_0_reg_1[95:64] = local_lvm_input_global_id_0_NO_SHIFT_REG;
assign rci_rcnode_1to161_rc4_arrayidx3_0_reg_1[127:96] = local_lvm_input_acl_hw_wg_id_NO_SHIFT_REG;

// Register node:
//  * latency = 160
//  * capacity = 160
 logic rcnode_1to161_rc4_arrayidx3_0_valid_out_NO_SHIFT_REG;
 logic rcnode_1to161_rc4_arrayidx3_0_stall_in_NO_SHIFT_REG;
 logic [127:0] rcnode_1to161_rc4_arrayidx3_0_NO_SHIFT_REG;
 logic rcnode_1to161_rc4_arrayidx3_0_reg_161_inputs_ready_NO_SHIFT_REG;
 logic [127:0] rcnode_1to161_rc4_arrayidx3_0_reg_161_NO_SHIFT_REG;
 logic rcnode_1to161_rc4_arrayidx3_0_valid_out_reg_161_NO_SHIFT_REG;
 logic rcnode_1to161_rc4_arrayidx3_0_stall_in_reg_161_NO_SHIFT_REG;
 logic rcnode_1to161_rc4_arrayidx3_0_stall_out_reg_161_IP_NO_SHIFT_REG;
 logic rcnode_1to161_rc4_arrayidx3_0_stall_out_reg_161_NO_SHIFT_REG;

acl_data_fifo rcnode_1to161_rc4_arrayidx3_0_reg_161_fifo (
	.clock(clock),
	.resetn(resetn),
	.valid_in(rcnode_1to161_rc4_arrayidx3_0_reg_161_inputs_ready_NO_SHIFT_REG),
	.stall_in(rcnode_1to161_rc4_arrayidx3_0_stall_in_reg_161_NO_SHIFT_REG),
	.valid_out(rcnode_1to161_rc4_arrayidx3_0_valid_out_reg_161_NO_SHIFT_REG),
	.stall_out(rcnode_1to161_rc4_arrayidx3_0_stall_out_reg_161_IP_NO_SHIFT_REG),
	.data_in(rci_rcnode_1to161_rc4_arrayidx3_0_reg_1),
	.data_out(rcnode_1to161_rc4_arrayidx3_0_reg_161_NO_SHIFT_REG)
);

defparam rcnode_1to161_rc4_arrayidx3_0_reg_161_fifo.DEPTH = 161;
defparam rcnode_1to161_rc4_arrayidx3_0_reg_161_fifo.DATA_WIDTH = 128;
defparam rcnode_1to161_rc4_arrayidx3_0_reg_161_fifo.ALLOW_FULL_WRITE = 0;
defparam rcnode_1to161_rc4_arrayidx3_0_reg_161_fifo.IMPL = "ram";

assign rcnode_1to161_rc4_arrayidx3_0_reg_161_inputs_ready_NO_SHIFT_REG = merge_node_valid_out_4_NO_SHIFT_REG;
assign rcnode_1to161_rc4_arrayidx3_0_stall_out_reg_161_NO_SHIFT_REG = (~(rcnode_1to161_rc4_arrayidx3_0_reg_161_inputs_ready_NO_SHIFT_REG) | rcnode_1to161_rc4_arrayidx3_0_stall_out_reg_161_IP_NO_SHIFT_REG);
assign merge_node_stall_in_4 = rcnode_1to161_rc4_arrayidx3_0_stall_out_reg_161_NO_SHIFT_REG;
assign rcnode_1to161_rc4_arrayidx3_0_NO_SHIFT_REG = rcnode_1to161_rc4_arrayidx3_0_reg_161_NO_SHIFT_REG;
assign rcnode_1to161_rc4_arrayidx3_0_stall_in_reg_161_NO_SHIFT_REG = rcnode_1to161_rc4_arrayidx3_0_stall_in_NO_SHIFT_REG;
assign rcnode_1to161_rc4_arrayidx3_0_valid_out_NO_SHIFT_REG = rcnode_1to161_rc4_arrayidx3_0_valid_out_reg_161_NO_SHIFT_REG;

// This section implements an unregistered operation.
// 
wire local_bb1_arrayidx_valid_out;
wire local_bb1_arrayidx_stall_in;
wire local_bb1_arrayidx_inputs_ready;
wire local_bb1_arrayidx_stall_local;
wire [63:0] local_bb1_arrayidx;

assign local_bb1_arrayidx_inputs_ready = merge_node_valid_out_0_NO_SHIFT_REG;
assign local_bb1_arrayidx = ((input_A & 64'hFFFFFFFFFFFFFC00) + ((local_bb1_idxprom & 64'hFFFFFFFF) << 6'h2));
assign local_bb1_arrayidx_valid_out = local_bb1_arrayidx_inputs_ready;
assign local_bb1_arrayidx_stall_local = local_bb1_arrayidx_stall_in;
assign merge_node_stall_in_0 = (|local_bb1_arrayidx_stall_local);

// Register node:
//  * latency = 1
//  * capacity = 1
 logic rnode_1to2_bb1_cmp1_NEG_RM_0_valid_out_0_NO_SHIFT_REG;
 logic rnode_1to2_bb1_cmp1_NEG_RM_0_stall_in_0_NO_SHIFT_REG;
 logic rnode_1to2_bb1_cmp1_NEG_RM_0_NO_SHIFT_REG;
 logic rnode_1to2_bb1_cmp1_NEG_RM_0_valid_out_1_NO_SHIFT_REG;
 logic rnode_1to2_bb1_cmp1_NEG_RM_0_stall_in_1_NO_SHIFT_REG;
 logic rnode_1to2_bb1_cmp1_NEG_RM_1_NO_SHIFT_REG;
 logic rnode_1to2_bb1_cmp1_NEG_RM_0_reg_2_inputs_ready_NO_SHIFT_REG;
 logic rnode_1to2_bb1_cmp1_NEG_RM_0_reg_2_NO_SHIFT_REG;
 logic rnode_1to2_bb1_cmp1_NEG_RM_0_valid_out_0_reg_2_NO_SHIFT_REG;
 logic rnode_1to2_bb1_cmp1_NEG_RM_0_stall_in_0_reg_2_NO_SHIFT_REG;
 logic rnode_1to2_bb1_cmp1_NEG_RM_0_stall_out_reg_2_NO_SHIFT_REG;
 reg rnode_1to2_bb1_cmp1_NEG_RM_0_consumed_0_NO_SHIFT_REG;
 reg rnode_1to2_bb1_cmp1_NEG_RM_0_consumed_1_NO_SHIFT_REG;

acl_data_fifo rnode_1to2_bb1_cmp1_NEG_RM_0_reg_2_fifo (
	.clock(clock),
	.resetn(resetn),
	.valid_in(rnode_1to2_bb1_cmp1_NEG_RM_0_reg_2_inputs_ready_NO_SHIFT_REG),
	.stall_in(rnode_1to2_bb1_cmp1_NEG_RM_0_stall_in_0_reg_2_NO_SHIFT_REG),
	.valid_out(rnode_1to2_bb1_cmp1_NEG_RM_0_valid_out_0_reg_2_NO_SHIFT_REG),
	.stall_out(rnode_1to2_bb1_cmp1_NEG_RM_0_stall_out_reg_2_NO_SHIFT_REG),
	.data_in(local_bb1_cmp1_NEG_RM),
	.data_out(rnode_1to2_bb1_cmp1_NEG_RM_0_reg_2_NO_SHIFT_REG)
);

defparam rnode_1to2_bb1_cmp1_NEG_RM_0_reg_2_fifo.DEPTH = 2;
defparam rnode_1to2_bb1_cmp1_NEG_RM_0_reg_2_fifo.DATA_WIDTH = 1;
defparam rnode_1to2_bb1_cmp1_NEG_RM_0_reg_2_fifo.ALLOW_FULL_WRITE = 0;
defparam rnode_1to2_bb1_cmp1_NEG_RM_0_reg_2_fifo.IMPL = "ll_reg";

assign rnode_1to2_bb1_cmp1_NEG_RM_0_reg_2_inputs_ready_NO_SHIFT_REG = local_bb1_cmp1_NEG_RM_valid_out;
assign local_bb1_cmp1_NEG_RM_stall_in = rnode_1to2_bb1_cmp1_NEG_RM_0_stall_out_reg_2_NO_SHIFT_REG;
assign rnode_1to2_bb1_cmp1_NEG_RM_0_stall_in_0_reg_2_NO_SHIFT_REG = ((rnode_1to2_bb1_cmp1_NEG_RM_0_stall_in_0_NO_SHIFT_REG & ~(rnode_1to2_bb1_cmp1_NEG_RM_0_consumed_0_NO_SHIFT_REG)) | (rnode_1to2_bb1_cmp1_NEG_RM_0_stall_in_1_NO_SHIFT_REG & ~(rnode_1to2_bb1_cmp1_NEG_RM_0_consumed_1_NO_SHIFT_REG)));
assign rnode_1to2_bb1_cmp1_NEG_RM_0_valid_out_0_NO_SHIFT_REG = (rnode_1to2_bb1_cmp1_NEG_RM_0_valid_out_0_reg_2_NO_SHIFT_REG & ~(rnode_1to2_bb1_cmp1_NEG_RM_0_consumed_0_NO_SHIFT_REG));
assign rnode_1to2_bb1_cmp1_NEG_RM_0_valid_out_1_NO_SHIFT_REG = (rnode_1to2_bb1_cmp1_NEG_RM_0_valid_out_0_reg_2_NO_SHIFT_REG & ~(rnode_1to2_bb1_cmp1_NEG_RM_0_consumed_1_NO_SHIFT_REG));
assign rnode_1to2_bb1_cmp1_NEG_RM_0_NO_SHIFT_REG = rnode_1to2_bb1_cmp1_NEG_RM_0_reg_2_NO_SHIFT_REG;
assign rnode_1to2_bb1_cmp1_NEG_RM_1_NO_SHIFT_REG = rnode_1to2_bb1_cmp1_NEG_RM_0_reg_2_NO_SHIFT_REG;

always @(posedge clock or negedge resetn)
begin
	if (~(resetn))
	begin
		rnode_1to2_bb1_cmp1_NEG_RM_0_consumed_0_NO_SHIFT_REG <= 1'b0;
		rnode_1to2_bb1_cmp1_NEG_RM_0_consumed_1_NO_SHIFT_REG <= 1'b0;
	end
	else
	begin
		rnode_1to2_bb1_cmp1_NEG_RM_0_consumed_0_NO_SHIFT_REG <= (rnode_1to2_bb1_cmp1_NEG_RM_0_valid_out_0_reg_2_NO_SHIFT_REG & (rnode_1to2_bb1_cmp1_NEG_RM_0_consumed_0_NO_SHIFT_REG | ~(rnode_1to2_bb1_cmp1_NEG_RM_0_stall_in_0_NO_SHIFT_REG)) & rnode_1to2_bb1_cmp1_NEG_RM_0_stall_in_0_reg_2_NO_SHIFT_REG);
		rnode_1to2_bb1_cmp1_NEG_RM_0_consumed_1_NO_SHIFT_REG <= (rnode_1to2_bb1_cmp1_NEG_RM_0_valid_out_0_reg_2_NO_SHIFT_REG & (rnode_1to2_bb1_cmp1_NEG_RM_0_consumed_1_NO_SHIFT_REG | ~(rnode_1to2_bb1_cmp1_NEG_RM_0_stall_in_1_NO_SHIFT_REG)) & rnode_1to2_bb1_cmp1_NEG_RM_0_stall_in_0_reg_2_NO_SHIFT_REG);
	end
end


// Register node:
//  * latency = 159
//  * capacity = 159
 logic rnode_1to160_bb1_inc_0_valid_out_NO_SHIFT_REG;
 logic rnode_1to160_bb1_inc_0_stall_in_NO_SHIFT_REG;
 logic [31:0] rnode_1to160_bb1_inc_0_NO_SHIFT_REG;
 logic rnode_1to160_bb1_inc_0_reg_160_inputs_ready_NO_SHIFT_REG;
 logic [31:0] rnode_1to160_bb1_inc_0_reg_160_NO_SHIFT_REG;
 logic rnode_1to160_bb1_inc_0_valid_out_reg_160_NO_SHIFT_REG;
 logic rnode_1to160_bb1_inc_0_stall_in_reg_160_NO_SHIFT_REG;
 logic rnode_1to160_bb1_inc_0_stall_out_reg_160_NO_SHIFT_REG;

acl_data_fifo rnode_1to160_bb1_inc_0_reg_160_fifo (
	.clock(clock),
	.resetn(resetn),
	.valid_in(rnode_1to160_bb1_inc_0_reg_160_inputs_ready_NO_SHIFT_REG),
	.stall_in(rnode_1to160_bb1_inc_0_stall_in_reg_160_NO_SHIFT_REG),
	.valid_out(rnode_1to160_bb1_inc_0_valid_out_reg_160_NO_SHIFT_REG),
	.stall_out(rnode_1to160_bb1_inc_0_stall_out_reg_160_NO_SHIFT_REG),
	.data_in(local_bb1_inc),
	.data_out(rnode_1to160_bb1_inc_0_reg_160_NO_SHIFT_REG)
);

defparam rnode_1to160_bb1_inc_0_reg_160_fifo.DEPTH = 160;
defparam rnode_1to160_bb1_inc_0_reg_160_fifo.DATA_WIDTH = 32;
defparam rnode_1to160_bb1_inc_0_reg_160_fifo.ALLOW_FULL_WRITE = 0;
defparam rnode_1to160_bb1_inc_0_reg_160_fifo.IMPL = "ram";

assign rnode_1to160_bb1_inc_0_reg_160_inputs_ready_NO_SHIFT_REG = local_bb1_inc_valid_out;
assign local_bb1_inc_stall_in = rnode_1to160_bb1_inc_0_stall_out_reg_160_NO_SHIFT_REG;
assign rnode_1to160_bb1_inc_0_NO_SHIFT_REG = rnode_1to160_bb1_inc_0_reg_160_NO_SHIFT_REG;
assign rnode_1to160_bb1_inc_0_stall_in_reg_160_NO_SHIFT_REG = rnode_1to160_bb1_inc_0_stall_in_NO_SHIFT_REG;
assign rnode_1to160_bb1_inc_0_valid_out_NO_SHIFT_REG = rnode_1to160_bb1_inc_0_valid_out_reg_160_NO_SHIFT_REG;

// Register node:
//  * latency = 1
//  * capacity = 1
 logic rnode_161to162_add3_0_valid_out_NO_SHIFT_REG;
 logic rnode_161to162_add3_0_stall_in_NO_SHIFT_REG;
 logic [31:0] rnode_161to162_add3_0_NO_SHIFT_REG;
 logic rnode_161to162_add3_0_reg_162_inputs_ready_NO_SHIFT_REG;
 logic [31:0] rnode_161to162_add3_0_reg_162_NO_SHIFT_REG;
 logic rnode_161to162_add3_0_valid_out_reg_162_NO_SHIFT_REG;
 logic rnode_161to162_add3_0_stall_in_reg_162_NO_SHIFT_REG;
 logic rnode_161to162_add3_0_stall_out_reg_162_NO_SHIFT_REG;

acl_data_fifo rnode_161to162_add3_0_reg_162_fifo (
	.clock(clock),
	.resetn(resetn),
	.valid_in(rnode_161to162_add3_0_reg_162_inputs_ready_NO_SHIFT_REG),
	.stall_in(rnode_161to162_add3_0_stall_in_reg_162_NO_SHIFT_REG),
	.valid_out(rnode_161to162_add3_0_valid_out_reg_162_NO_SHIFT_REG),
	.stall_out(rnode_161to162_add3_0_stall_out_reg_162_NO_SHIFT_REG),
	.data_in(rnode_1to161_add3_0_NO_SHIFT_REG),
	.data_out(rnode_161to162_add3_0_reg_162_NO_SHIFT_REG)
);

defparam rnode_161to162_add3_0_reg_162_fifo.DEPTH = 1;
defparam rnode_161to162_add3_0_reg_162_fifo.DATA_WIDTH = 32;
defparam rnode_161to162_add3_0_reg_162_fifo.ALLOW_FULL_WRITE = 1;
defparam rnode_161to162_add3_0_reg_162_fifo.IMPL = "ll_reg";

assign rnode_161to162_add3_0_reg_162_inputs_ready_NO_SHIFT_REG = rnode_1to161_add3_0_valid_out_NO_SHIFT_REG;
assign rnode_1to161_add3_0_stall_in_NO_SHIFT_REG = rnode_161to162_add3_0_stall_out_reg_162_NO_SHIFT_REG;
assign rnode_161to162_add3_0_NO_SHIFT_REG = rnode_161to162_add3_0_reg_162_NO_SHIFT_REG;
assign rnode_161to162_add3_0_stall_in_reg_162_NO_SHIFT_REG = rnode_161to162_add3_0_stall_in_NO_SHIFT_REG;
assign rnode_161to162_add3_0_valid_out_NO_SHIFT_REG = rnode_161to162_add3_0_valid_out_reg_162_NO_SHIFT_REG;

// Register node:
//  * latency = 1
//  * capacity = 1
 logic rnode_1to2_bb1_arrayidx_0_valid_out_NO_SHIFT_REG;
 logic rnode_1to2_bb1_arrayidx_0_stall_in_NO_SHIFT_REG;
 logic [63:0] rnode_1to2_bb1_arrayidx_0_NO_SHIFT_REG;
 logic rnode_1to2_bb1_arrayidx_0_reg_2_inputs_ready_NO_SHIFT_REG;
 logic [63:0] rnode_1to2_bb1_arrayidx_0_reg_2_NO_SHIFT_REG;
 logic rnode_1to2_bb1_arrayidx_0_valid_out_reg_2_NO_SHIFT_REG;
 logic rnode_1to2_bb1_arrayidx_0_stall_in_reg_2_NO_SHIFT_REG;
 logic rnode_1to2_bb1_arrayidx_0_stall_out_reg_2_NO_SHIFT_REG;

acl_data_fifo rnode_1to2_bb1_arrayidx_0_reg_2_fifo (
	.clock(clock),
	.resetn(resetn),
	.valid_in(rnode_1to2_bb1_arrayidx_0_reg_2_inputs_ready_NO_SHIFT_REG),
	.stall_in(rnode_1to2_bb1_arrayidx_0_stall_in_reg_2_NO_SHIFT_REG),
	.valid_out(rnode_1to2_bb1_arrayidx_0_valid_out_reg_2_NO_SHIFT_REG),
	.stall_out(rnode_1to2_bb1_arrayidx_0_stall_out_reg_2_NO_SHIFT_REG),
	.data_in((local_bb1_arrayidx & 64'hFFFFFFFFFFFFFFFC)),
	.data_out(rnode_1to2_bb1_arrayidx_0_reg_2_NO_SHIFT_REG)
);

defparam rnode_1to2_bb1_arrayidx_0_reg_2_fifo.DEPTH = 2;
defparam rnode_1to2_bb1_arrayidx_0_reg_2_fifo.DATA_WIDTH = 64;
defparam rnode_1to2_bb1_arrayidx_0_reg_2_fifo.ALLOW_FULL_WRITE = 0;
defparam rnode_1to2_bb1_arrayidx_0_reg_2_fifo.IMPL = "ll_reg";

assign rnode_1to2_bb1_arrayidx_0_reg_2_inputs_ready_NO_SHIFT_REG = local_bb1_arrayidx_valid_out;
assign local_bb1_arrayidx_stall_in = rnode_1to2_bb1_arrayidx_0_stall_out_reg_2_NO_SHIFT_REG;
assign rnode_1to2_bb1_arrayidx_0_NO_SHIFT_REG = rnode_1to2_bb1_arrayidx_0_reg_2_NO_SHIFT_REG;
assign rnode_1to2_bb1_arrayidx_0_stall_in_reg_2_NO_SHIFT_REG = rnode_1to2_bb1_arrayidx_0_stall_in_NO_SHIFT_REG;
assign rnode_1to2_bb1_arrayidx_0_valid_out_NO_SHIFT_REG = rnode_1to2_bb1_arrayidx_0_valid_out_reg_2_NO_SHIFT_REG;

// Register node:
//  * latency = 159
//  * capacity = 159
 logic rnode_2to161_bb1_cmp1_NEG_RM_0_valid_out_NO_SHIFT_REG;
 logic rnode_2to161_bb1_cmp1_NEG_RM_0_stall_in_NO_SHIFT_REG;
 logic rnode_2to161_bb1_cmp1_NEG_RM_0_NO_SHIFT_REG;
 logic rnode_2to161_bb1_cmp1_NEG_RM_0_reg_161_inputs_ready_NO_SHIFT_REG;
 logic rnode_2to161_bb1_cmp1_NEG_RM_0_reg_161_NO_SHIFT_REG;
 logic rnode_2to161_bb1_cmp1_NEG_RM_0_valid_out_reg_161_NO_SHIFT_REG;
 logic rnode_2to161_bb1_cmp1_NEG_RM_0_stall_in_reg_161_NO_SHIFT_REG;
 logic rnode_2to161_bb1_cmp1_NEG_RM_0_stall_out_reg_161_NO_SHIFT_REG;

acl_data_fifo rnode_2to161_bb1_cmp1_NEG_RM_0_reg_161_fifo (
	.clock(clock),
	.resetn(resetn),
	.valid_in(rnode_2to161_bb1_cmp1_NEG_RM_0_reg_161_inputs_ready_NO_SHIFT_REG),
	.stall_in(rnode_2to161_bb1_cmp1_NEG_RM_0_stall_in_reg_161_NO_SHIFT_REG),
	.valid_out(rnode_2to161_bb1_cmp1_NEG_RM_0_valid_out_reg_161_NO_SHIFT_REG),
	.stall_out(rnode_2to161_bb1_cmp1_NEG_RM_0_stall_out_reg_161_NO_SHIFT_REG),
	.data_in(rnode_1to2_bb1_cmp1_NEG_RM_1_NO_SHIFT_REG),
	.data_out(rnode_2to161_bb1_cmp1_NEG_RM_0_reg_161_NO_SHIFT_REG)
);

defparam rnode_2to161_bb1_cmp1_NEG_RM_0_reg_161_fifo.DEPTH = 160;
defparam rnode_2to161_bb1_cmp1_NEG_RM_0_reg_161_fifo.DATA_WIDTH = 1;
defparam rnode_2to161_bb1_cmp1_NEG_RM_0_reg_161_fifo.ALLOW_FULL_WRITE = 0;
defparam rnode_2to161_bb1_cmp1_NEG_RM_0_reg_161_fifo.IMPL = "ram";

assign rnode_2to161_bb1_cmp1_NEG_RM_0_reg_161_inputs_ready_NO_SHIFT_REG = rnode_1to2_bb1_cmp1_NEG_RM_0_valid_out_1_NO_SHIFT_REG;
assign rnode_1to2_bb1_cmp1_NEG_RM_0_stall_in_1_NO_SHIFT_REG = rnode_2to161_bb1_cmp1_NEG_RM_0_stall_out_reg_161_NO_SHIFT_REG;
assign rnode_2to161_bb1_cmp1_NEG_RM_0_NO_SHIFT_REG = rnode_2to161_bb1_cmp1_NEG_RM_0_reg_161_NO_SHIFT_REG;
assign rnode_2to161_bb1_cmp1_NEG_RM_0_stall_in_reg_161_NO_SHIFT_REG = rnode_2to161_bb1_cmp1_NEG_RM_0_stall_in_NO_SHIFT_REG;
assign rnode_2to161_bb1_cmp1_NEG_RM_0_valid_out_NO_SHIFT_REG = rnode_2to161_bb1_cmp1_NEG_RM_0_valid_out_reg_161_NO_SHIFT_REG;

// Register node:
//  * latency = 1
//  * capacity = 1
 logic rnode_160to161_bb1_inc_0_valid_out_0_NO_SHIFT_REG;
 logic rnode_160to161_bb1_inc_0_stall_in_0_NO_SHIFT_REG;
 logic [31:0] rnode_160to161_bb1_inc_0_NO_SHIFT_REG;
 logic rnode_160to161_bb1_inc_0_valid_out_1_NO_SHIFT_REG;
 logic rnode_160to161_bb1_inc_0_stall_in_1_NO_SHIFT_REG;
 logic [31:0] rnode_160to161_bb1_inc_1_NO_SHIFT_REG;
 logic rnode_160to161_bb1_inc_0_reg_161_inputs_ready_NO_SHIFT_REG;
 logic [31:0] rnode_160to161_bb1_inc_0_reg_161_NO_SHIFT_REG;
 logic rnode_160to161_bb1_inc_0_valid_out_0_reg_161_NO_SHIFT_REG;
 logic rnode_160to161_bb1_inc_0_stall_in_0_reg_161_NO_SHIFT_REG;
 logic rnode_160to161_bb1_inc_0_stall_out_reg_161_NO_SHIFT_REG;
 reg rnode_160to161_bb1_inc_0_consumed_0_NO_SHIFT_REG;
 reg rnode_160to161_bb1_inc_0_consumed_1_NO_SHIFT_REG;

acl_data_fifo rnode_160to161_bb1_inc_0_reg_161_fifo (
	.clock(clock),
	.resetn(resetn),
	.valid_in(rnode_160to161_bb1_inc_0_reg_161_inputs_ready_NO_SHIFT_REG),
	.stall_in(rnode_160to161_bb1_inc_0_stall_in_0_reg_161_NO_SHIFT_REG),
	.valid_out(rnode_160to161_bb1_inc_0_valid_out_0_reg_161_NO_SHIFT_REG),
	.stall_out(rnode_160to161_bb1_inc_0_stall_out_reg_161_NO_SHIFT_REG),
	.data_in(rnode_1to160_bb1_inc_0_NO_SHIFT_REG),
	.data_out(rnode_160to161_bb1_inc_0_reg_161_NO_SHIFT_REG)
);

defparam rnode_160to161_bb1_inc_0_reg_161_fifo.DEPTH = 1;
defparam rnode_160to161_bb1_inc_0_reg_161_fifo.DATA_WIDTH = 32;
defparam rnode_160to161_bb1_inc_0_reg_161_fifo.ALLOW_FULL_WRITE = 1;
defparam rnode_160to161_bb1_inc_0_reg_161_fifo.IMPL = "ll_reg";

assign rnode_160to161_bb1_inc_0_reg_161_inputs_ready_NO_SHIFT_REG = rnode_1to160_bb1_inc_0_valid_out_NO_SHIFT_REG;
assign rnode_1to160_bb1_inc_0_stall_in_NO_SHIFT_REG = rnode_160to161_bb1_inc_0_stall_out_reg_161_NO_SHIFT_REG;
assign rnode_160to161_bb1_inc_0_stall_in_0_reg_161_NO_SHIFT_REG = ((rnode_160to161_bb1_inc_0_stall_in_0_NO_SHIFT_REG & ~(rnode_160to161_bb1_inc_0_consumed_0_NO_SHIFT_REG)) | (rnode_160to161_bb1_inc_0_stall_in_1_NO_SHIFT_REG & ~(rnode_160to161_bb1_inc_0_consumed_1_NO_SHIFT_REG)));
assign rnode_160to161_bb1_inc_0_valid_out_0_NO_SHIFT_REG = (rnode_160to161_bb1_inc_0_valid_out_0_reg_161_NO_SHIFT_REG & ~(rnode_160to161_bb1_inc_0_consumed_0_NO_SHIFT_REG));
assign rnode_160to161_bb1_inc_0_valid_out_1_NO_SHIFT_REG = (rnode_160to161_bb1_inc_0_valid_out_0_reg_161_NO_SHIFT_REG & ~(rnode_160to161_bb1_inc_0_consumed_1_NO_SHIFT_REG));
assign rnode_160to161_bb1_inc_0_NO_SHIFT_REG = rnode_160to161_bb1_inc_0_reg_161_NO_SHIFT_REG;
assign rnode_160to161_bb1_inc_1_NO_SHIFT_REG = rnode_160to161_bb1_inc_0_reg_161_NO_SHIFT_REG;

always @(posedge clock or negedge resetn)
begin
	if (~(resetn))
	begin
		rnode_160to161_bb1_inc_0_consumed_0_NO_SHIFT_REG <= 1'b0;
		rnode_160to161_bb1_inc_0_consumed_1_NO_SHIFT_REG <= 1'b0;
	end
	else
	begin
		rnode_160to161_bb1_inc_0_consumed_0_NO_SHIFT_REG <= (rnode_160to161_bb1_inc_0_valid_out_0_reg_161_NO_SHIFT_REG & (rnode_160to161_bb1_inc_0_consumed_0_NO_SHIFT_REG | ~(rnode_160to161_bb1_inc_0_stall_in_0_NO_SHIFT_REG)) & rnode_160to161_bb1_inc_0_stall_in_0_reg_161_NO_SHIFT_REG);
		rnode_160to161_bb1_inc_0_consumed_1_NO_SHIFT_REG <= (rnode_160to161_bb1_inc_0_valid_out_0_reg_161_NO_SHIFT_REG & (rnode_160to161_bb1_inc_0_consumed_1_NO_SHIFT_REG | ~(rnode_160to161_bb1_inc_0_stall_in_1_NO_SHIFT_REG)) & rnode_160to161_bb1_inc_0_stall_in_0_reg_161_NO_SHIFT_REG);
	end
end


// This section implements a registered operation.
// 
wire local_bb1_ld__inputs_ready;
 reg local_bb1_ld__valid_out_NO_SHIFT_REG;
wire local_bb1_ld__stall_in;
wire local_bb1_ld__output_regs_ready;
wire local_bb1_ld__fu_stall_out;
wire local_bb1_ld__fu_valid_out;
wire [31:0] local_bb1_ld__lsu_dataout;
 reg [31:0] local_bb1_ld__NO_SHIFT_REG;
wire local_bb1_ld__causedstall;

lsu_top lsu_local_bb1_ld_ (
	.clock(clock),
	.clock2x(clock2x),
	.resetn(resetn),
	.flush(start),
	.stream_base_addr(),
	.stream_size(),
	.stream_reset(),
	.o_stall(local_bb1_ld__fu_stall_out),
	.i_valid(local_bb1_ld__inputs_ready),
	.i_address((rnode_1to2_bb1_arrayidx_0_NO_SHIFT_REG & 64'hFFFFFFFFFFFFFFFC)),
	.i_writedata(),
	.i_cmpdata(),
	.i_predicate(rnode_1to2_bb1_cmp1_NEG_RM_0_NO_SHIFT_REG),
	.i_bitwiseor(64'h0),
	.i_byteenable(),
	.i_stall(~(local_bb1_ld__output_regs_ready)),
	.o_valid(local_bb1_ld__fu_valid_out),
	.o_readdata(local_bb1_ld__lsu_dataout),
	.o_input_fifo_depth(),
	.o_writeack(),
	.i_atomic_op(3'h0),
	.o_active(local_bb1_ld__active),
	.avm_address(avm_local_bb1_ld__address),
	.avm_read(avm_local_bb1_ld__read),
	.avm_enable(avm_local_bb1_ld__enable),
	.avm_readdata(avm_local_bb1_ld__readdata),
	.avm_write(avm_local_bb1_ld__write),
	.avm_writeack(avm_local_bb1_ld__writeack),
	.avm_burstcount(avm_local_bb1_ld__burstcount),
	.avm_writedata(avm_local_bb1_ld__writedata),
	.avm_byteenable(avm_local_bb1_ld__byteenable),
	.avm_waitrequest(avm_local_bb1_ld__waitrequest),
	.avm_readdatavalid(avm_local_bb1_ld__readdatavalid),
	.profile_bw(),
	.profile_bw_incr(),
	.profile_total_ivalid(),
	.profile_total_req(),
	.profile_i_stall_count(),
	.profile_o_stall_count(),
	.profile_avm_readwrite_count(),
	.profile_avm_burstcount_total(),
	.profile_avm_burstcount_total_incr(),
	.profile_req_cache_hit_count(),
	.profile_extra_unaligned_reqs(),
	.profile_avm_stall()
);

defparam lsu_local_bb1_ld_.AWIDTH = 28;
defparam lsu_local_bb1_ld_.WIDTH_BYTES = 4;
defparam lsu_local_bb1_ld_.MWIDTH_BYTES = 64;
defparam lsu_local_bb1_ld_.WRITEDATAWIDTH_BYTES = 64;
defparam lsu_local_bb1_ld_.ALIGNMENT_BYTES = 4;
defparam lsu_local_bb1_ld_.READ = 1;
defparam lsu_local_bb1_ld_.ATOMIC = 0;
defparam lsu_local_bb1_ld_.WIDTH = 32;
defparam lsu_local_bb1_ld_.MWIDTH = 512;
defparam lsu_local_bb1_ld_.ATOMIC_WIDTH = 3;
defparam lsu_local_bb1_ld_.BURSTCOUNT_WIDTH = 6;
defparam lsu_local_bb1_ld_.KERNEL_SIDE_MEM_LATENCY = 160;
defparam lsu_local_bb1_ld_.MEMORY_SIDE_MEM_LATENCY = 131;
defparam lsu_local_bb1_ld_.USE_WRITE_ACK = 0;
defparam lsu_local_bb1_ld_.ENABLE_BANKED_MEMORY = 0;
defparam lsu_local_bb1_ld_.ABITS_PER_LMEM_BANK = 0;
defparam lsu_local_bb1_ld_.NUMBER_BANKS = 1;
defparam lsu_local_bb1_ld_.LMEM_ADDR_PERMUTATION_STYLE = 0;
defparam lsu_local_bb1_ld_.INTENDED_DEVICE_FAMILY = "Stratix V";
defparam lsu_local_bb1_ld_.USEINPUTFIFO = 0;
defparam lsu_local_bb1_ld_.USECACHING = 0;
defparam lsu_local_bb1_ld_.USEOUTPUTFIFO = 1;
defparam lsu_local_bb1_ld_.FORCE_NOP_SUPPORT = 0;
defparam lsu_local_bb1_ld_.HIGH_FMAX = 1;
defparam lsu_local_bb1_ld_.ADDRSPACE = 1;
defparam lsu_local_bb1_ld_.STYLE = "BURST-COALESCED";

assign local_bb1_ld__inputs_ready = (rnode_1to2_bb1_arrayidx_0_valid_out_NO_SHIFT_REG & rnode_1to2_bb1_cmp1_NEG_RM_0_valid_out_0_NO_SHIFT_REG);
assign local_bb1_ld__output_regs_ready = (&(~(local_bb1_ld__valid_out_NO_SHIFT_REG) | ~(local_bb1_ld__stall_in)));
assign rnode_1to2_bb1_arrayidx_0_stall_in_NO_SHIFT_REG = (local_bb1_ld__fu_stall_out | ~(local_bb1_ld__inputs_ready));
assign rnode_1to2_bb1_cmp1_NEG_RM_0_stall_in_0_NO_SHIFT_REG = (local_bb1_ld__fu_stall_out | ~(local_bb1_ld__inputs_ready));
assign local_bb1_ld__causedstall = (local_bb1_ld__inputs_ready && (local_bb1_ld__fu_stall_out && !(~(local_bb1_ld__output_regs_ready))));

always @(posedge clock or negedge resetn)
begin
	if (~(resetn))
	begin
		local_bb1_ld__NO_SHIFT_REG <= 'x;
		local_bb1_ld__valid_out_NO_SHIFT_REG <= 1'b0;
	end
	else
	begin
		if (local_bb1_ld__output_regs_ready)
		begin
			local_bb1_ld__NO_SHIFT_REG <= local_bb1_ld__lsu_dataout;
			local_bb1_ld__valid_out_NO_SHIFT_REG <= local_bb1_ld__fu_valid_out;
		end
		else
		begin
			if (~(local_bb1_ld__stall_in))
			begin
				local_bb1_ld__valid_out_NO_SHIFT_REG <= 1'b0;
			end
		end
	end
end


// This section implements an unregistered operation.
// 
wire local_bb1_exitcond_valid_out;
wire local_bb1_exitcond_stall_in;
wire local_bb1_exitcond_inputs_ready;
wire local_bb1_exitcond_stall_local;
wire local_bb1_exitcond;
wire [160:0] rci_rcnode_161to162_rc1_bb1_inc_0_reg_161;

assign local_bb1_exitcond_inputs_ready = rnode_160to161_bb1_inc_0_valid_out_0_NO_SHIFT_REG;
assign local_bb1_exitcond = (rnode_160to161_bb1_inc_0_NO_SHIFT_REG == input_N);
assign local_bb1_exitcond_valid_out = local_bb1_exitcond_inputs_ready;
assign local_bb1_exitcond_stall_local = local_bb1_exitcond_stall_in;
assign rnode_160to161_bb1_inc_0_stall_in_0_NO_SHIFT_REG = (|local_bb1_exitcond_stall_local);
assign rci_rcnode_161to162_rc1_bb1_inc_0_reg_161[31:0] = rnode_160to161_bb1_inc_1_NO_SHIFT_REG;
assign rci_rcnode_161to162_rc1_bb1_inc_0_reg_161[95:32] = (rcnode_1to161_rc4_arrayidx3_0_NO_SHIFT_REG[63:0] & 64'hFFFFFFFFFFFFFFFC);
assign rci_rcnode_161to162_rc1_bb1_inc_0_reg_161[127:96] = rcnode_1to161_rc4_arrayidx3_0_NO_SHIFT_REG[95:64];
assign rci_rcnode_161to162_rc1_bb1_inc_0_reg_161[159:128] = rcnode_1to161_rc4_arrayidx3_0_NO_SHIFT_REG[127:96];
assign rci_rcnode_161to162_rc1_bb1_inc_0_reg_161[160] = rnode_2to161_bb1_cmp1_NEG_RM_0_NO_SHIFT_REG;

// Register node:
//  * latency = 1
//  * capacity = 1
 logic rcnode_161to162_rc1_bb1_inc_0_valid_out_0_NO_SHIFT_REG;
 logic rcnode_161to162_rc1_bb1_inc_0_stall_in_0_NO_SHIFT_REG;
 logic [160:0] rcnode_161to162_rc1_bb1_inc_0_NO_SHIFT_REG;
 logic rcnode_161to162_rc1_bb1_inc_0_valid_out_1_NO_SHIFT_REG;
 logic rcnode_161to162_rc1_bb1_inc_0_stall_in_1_NO_SHIFT_REG;
 logic [160:0] rcnode_161to162_rc1_bb1_inc_1_NO_SHIFT_REG;
 logic rcnode_161to162_rc1_bb1_inc_0_reg_162_inputs_ready_NO_SHIFT_REG;
 logic [160:0] rcnode_161to162_rc1_bb1_inc_0_reg_162_NO_SHIFT_REG;
 logic rcnode_161to162_rc1_bb1_inc_0_valid_out_0_reg_162_NO_SHIFT_REG;
 logic rcnode_161to162_rc1_bb1_inc_0_stall_in_0_reg_162_NO_SHIFT_REG;
 logic rcnode_161to162_rc1_bb1_inc_0_stall_out_0_reg_162_IP_NO_SHIFT_REG;
 logic rcnode_161to162_rc1_bb1_inc_0_stall_out_0_reg_162_NO_SHIFT_REG;

acl_data_fifo rcnode_161to162_rc1_bb1_inc_0_reg_162_fifo (
	.clock(clock),
	.resetn(resetn),
	.valid_in(rcnode_161to162_rc1_bb1_inc_0_reg_162_inputs_ready_NO_SHIFT_REG),
	.stall_in(rcnode_161to162_rc1_bb1_inc_0_stall_in_0_reg_162_NO_SHIFT_REG),
	.valid_out(rcnode_161to162_rc1_bb1_inc_0_valid_out_0_reg_162_NO_SHIFT_REG),
	.stall_out(rcnode_161to162_rc1_bb1_inc_0_stall_out_0_reg_162_IP_NO_SHIFT_REG),
	.data_in(rci_rcnode_161to162_rc1_bb1_inc_0_reg_161),
	.data_out(rcnode_161to162_rc1_bb1_inc_0_reg_162_NO_SHIFT_REG)
);

defparam rcnode_161to162_rc1_bb1_inc_0_reg_162_fifo.DEPTH = 1;
defparam rcnode_161to162_rc1_bb1_inc_0_reg_162_fifo.DATA_WIDTH = 161;
defparam rcnode_161to162_rc1_bb1_inc_0_reg_162_fifo.ALLOW_FULL_WRITE = 1;
defparam rcnode_161to162_rc1_bb1_inc_0_reg_162_fifo.IMPL = "ll_reg";

assign rcnode_161to162_rc1_bb1_inc_0_reg_162_inputs_ready_NO_SHIFT_REG = (rnode_160to161_bb1_inc_0_valid_out_1_NO_SHIFT_REG & rnode_2to161_bb1_cmp1_NEG_RM_0_valid_out_NO_SHIFT_REG & rcnode_1to161_rc4_arrayidx3_0_valid_out_NO_SHIFT_REG);
assign rcnode_161to162_rc1_bb1_inc_0_stall_out_0_reg_162_NO_SHIFT_REG = (~(rcnode_161to162_rc1_bb1_inc_0_reg_162_inputs_ready_NO_SHIFT_REG) | rcnode_161to162_rc1_bb1_inc_0_stall_out_0_reg_162_IP_NO_SHIFT_REG);
assign rnode_160to161_bb1_inc_0_stall_in_1_NO_SHIFT_REG = rcnode_161to162_rc1_bb1_inc_0_stall_out_0_reg_162_NO_SHIFT_REG;
assign rnode_2to161_bb1_cmp1_NEG_RM_0_stall_in_NO_SHIFT_REG = rcnode_161to162_rc1_bb1_inc_0_stall_out_0_reg_162_NO_SHIFT_REG;
assign rcnode_1to161_rc4_arrayidx3_0_stall_in_NO_SHIFT_REG = rcnode_161to162_rc1_bb1_inc_0_stall_out_0_reg_162_NO_SHIFT_REG;
assign rcnode_161to162_rc1_bb1_inc_0_stall_in_0_reg_162_NO_SHIFT_REG = (rcnode_161to162_rc1_bb1_inc_0_stall_in_0_NO_SHIFT_REG | rcnode_161to162_rc1_bb1_inc_0_stall_in_1_NO_SHIFT_REG);
assign rcnode_161to162_rc1_bb1_inc_0_valid_out_0_NO_SHIFT_REG = rcnode_161to162_rc1_bb1_inc_0_valid_out_0_reg_162_NO_SHIFT_REG;
assign rcnode_161to162_rc1_bb1_inc_0_valid_out_1_NO_SHIFT_REG = rcnode_161to162_rc1_bb1_inc_0_valid_out_0_reg_162_NO_SHIFT_REG;
assign rcnode_161to162_rc1_bb1_inc_0_NO_SHIFT_REG = rcnode_161to162_rc1_bb1_inc_0_reg_162_NO_SHIFT_REG;
assign rcnode_161to162_rc1_bb1_inc_1_NO_SHIFT_REG = rcnode_161to162_rc1_bb1_inc_0_reg_162_NO_SHIFT_REG;

// This section implements a staging register.
// 
wire rstag_162to162_bb1_ld__valid_out;
wire rstag_162to162_bb1_ld__stall_in;
wire rstag_162to162_bb1_ld__inputs_ready;
wire rstag_162to162_bb1_ld__stall_local;
 reg rstag_162to162_bb1_ld__staging_valid_NO_SHIFT_REG;
wire rstag_162to162_bb1_ld__combined_valid;
 reg [31:0] rstag_162to162_bb1_ld__staging_reg_NO_SHIFT_REG;
wire [31:0] rstag_162to162_bb1_ld_;

assign rstag_162to162_bb1_ld__inputs_ready = local_bb1_ld__valid_out_NO_SHIFT_REG;
assign rstag_162to162_bb1_ld_ = (rstag_162to162_bb1_ld__staging_valid_NO_SHIFT_REG ? rstag_162to162_bb1_ld__staging_reg_NO_SHIFT_REG : local_bb1_ld__NO_SHIFT_REG);
assign rstag_162to162_bb1_ld__combined_valid = (rstag_162to162_bb1_ld__staging_valid_NO_SHIFT_REG | rstag_162to162_bb1_ld__inputs_ready);
assign rstag_162to162_bb1_ld__valid_out = rstag_162to162_bb1_ld__combined_valid;
assign rstag_162to162_bb1_ld__stall_local = rstag_162to162_bb1_ld__stall_in;
assign local_bb1_ld__stall_in = (|rstag_162to162_bb1_ld__staging_valid_NO_SHIFT_REG);

always @(posedge clock or negedge resetn)
begin
	if (~(resetn))
	begin
		rstag_162to162_bb1_ld__staging_valid_NO_SHIFT_REG <= 1'b0;
		rstag_162to162_bb1_ld__staging_reg_NO_SHIFT_REG <= 'x;
	end
	else
	begin
		if (rstag_162to162_bb1_ld__stall_local)
		begin
			if (~(rstag_162to162_bb1_ld__staging_valid_NO_SHIFT_REG))
			begin
				rstag_162to162_bb1_ld__staging_valid_NO_SHIFT_REG <= rstag_162to162_bb1_ld__inputs_ready;
			end
		end
		else
		begin
			rstag_162to162_bb1_ld__staging_valid_NO_SHIFT_REG <= 1'b0;
		end
		if (~(rstag_162to162_bb1_ld__staging_valid_NO_SHIFT_REG))
		begin
			rstag_162to162_bb1_ld__staging_reg_NO_SHIFT_REG <= local_bb1_ld__NO_SHIFT_REG;
		end
	end
end


// Register node:
//  * latency = 1
//  * capacity = 1
 logic rnode_161to162_bb1_exitcond_0_valid_out_NO_SHIFT_REG;
 logic rnode_161to162_bb1_exitcond_0_stall_in_NO_SHIFT_REG;
 logic rnode_161to162_bb1_exitcond_0_NO_SHIFT_REG;
 logic rnode_161to162_bb1_exitcond_0_reg_162_inputs_ready_NO_SHIFT_REG;
 logic rnode_161to162_bb1_exitcond_0_reg_162_NO_SHIFT_REG;
 logic rnode_161to162_bb1_exitcond_0_valid_out_reg_162_NO_SHIFT_REG;
 logic rnode_161to162_bb1_exitcond_0_stall_in_reg_162_NO_SHIFT_REG;
 logic rnode_161to162_bb1_exitcond_0_stall_out_reg_162_NO_SHIFT_REG;

acl_data_fifo rnode_161to162_bb1_exitcond_0_reg_162_fifo (
	.clock(clock),
	.resetn(resetn),
	.valid_in(rnode_161to162_bb1_exitcond_0_reg_162_inputs_ready_NO_SHIFT_REG),
	.stall_in(rnode_161to162_bb1_exitcond_0_stall_in_reg_162_NO_SHIFT_REG),
	.valid_out(rnode_161to162_bb1_exitcond_0_valid_out_reg_162_NO_SHIFT_REG),
	.stall_out(rnode_161to162_bb1_exitcond_0_stall_out_reg_162_NO_SHIFT_REG),
	.data_in(local_bb1_exitcond),
	.data_out(rnode_161to162_bb1_exitcond_0_reg_162_NO_SHIFT_REG)
);

defparam rnode_161to162_bb1_exitcond_0_reg_162_fifo.DEPTH = 1;
defparam rnode_161to162_bb1_exitcond_0_reg_162_fifo.DATA_WIDTH = 1;
defparam rnode_161to162_bb1_exitcond_0_reg_162_fifo.ALLOW_FULL_WRITE = 1;
defparam rnode_161to162_bb1_exitcond_0_reg_162_fifo.IMPL = "ll_reg";

assign rnode_161to162_bb1_exitcond_0_reg_162_inputs_ready_NO_SHIFT_REG = local_bb1_exitcond_valid_out;
assign local_bb1_exitcond_stall_in = rnode_161to162_bb1_exitcond_0_stall_out_reg_162_NO_SHIFT_REG;
assign rnode_161to162_bb1_exitcond_0_NO_SHIFT_REG = rnode_161to162_bb1_exitcond_0_reg_162_NO_SHIFT_REG;
assign rnode_161to162_bb1_exitcond_0_stall_in_reg_162_NO_SHIFT_REG = rnode_161to162_bb1_exitcond_0_stall_in_NO_SHIFT_REG;
assign rnode_161to162_bb1_exitcond_0_valid_out_NO_SHIFT_REG = rnode_161to162_bb1_exitcond_0_valid_out_reg_162_NO_SHIFT_REG;

// This section implements an unregistered operation.
// 
wire local_bb1_add_valid_out;
wire local_bb1_add_stall_in;
wire local_bb1_add_inputs_ready;
wire local_bb1_add_stall_local;
wire [31:0] local_bb1_add;

assign local_bb1_add_inputs_ready = (rnode_161to162_add3_0_valid_out_NO_SHIFT_REG & rstag_162to162_bb1_ld__valid_out);
assign local_bb1_add = (rnode_161to162_add3_0_NO_SHIFT_REG + rstag_162to162_bb1_ld_);
assign local_bb1_add_valid_out = local_bb1_add_inputs_ready;
assign local_bb1_add_stall_local = local_bb1_add_stall_in;
assign rnode_161to162_add3_0_stall_in_NO_SHIFT_REG = (local_bb1_add_stall_local | ~(local_bb1_add_inputs_ready));
assign rstag_162to162_bb1_ld__stall_in = (local_bb1_add_stall_local | ~(local_bb1_add_inputs_ready));

// This section implements an unregistered operation.
// 
wire local_bb1_exitcond_GUARD_valid_out;
wire local_bb1_exitcond_GUARD_stall_in;
wire local_bb1_exitcond_GUARD_inputs_ready;
wire local_bb1_exitcond_GUARD_stall_local;
wire local_bb1_exitcond_GUARD;

assign local_bb1_exitcond_GUARD_inputs_ready = (rnode_161to162_bb1_exitcond_0_valid_out_NO_SHIFT_REG & rcnode_161to162_rc1_bb1_inc_0_valid_out_1_NO_SHIFT_REG);
assign local_bb1_exitcond_GUARD = (rnode_161to162_bb1_exitcond_0_NO_SHIFT_REG | rcnode_161to162_rc1_bb1_inc_0_NO_SHIFT_REG[160]);
assign local_bb1_exitcond_GUARD_valid_out = local_bb1_exitcond_GUARD_inputs_ready;
assign local_bb1_exitcond_GUARD_stall_local = local_bb1_exitcond_GUARD_stall_in;
assign rnode_161to162_bb1_exitcond_0_stall_in_NO_SHIFT_REG = (local_bb1_exitcond_GUARD_stall_local | ~(local_bb1_exitcond_GUARD_inputs_ready));
assign rcnode_161to162_rc1_bb1_inc_0_stall_in_1_NO_SHIFT_REG = (local_bb1_exitcond_GUARD_stall_local | ~(local_bb1_exitcond_GUARD_inputs_ready));

// This section describes the behaviour of the BRANCH node.
wire branch_var__inputs_ready;
 reg branch_node_valid_out_0_NO_SHIFT_REG;
 reg branch_compare_result_NO_SHIFT_REG;
wire branch_var__output_regs_ready;
wire combined_branch_stall_in_signal;
 reg [63:0] lvb_arrayidx3_0_reg_NO_SHIFT_REG;
 reg lvb_bb1_cmp1_NEG_RM_0_reg_NO_SHIFT_REG;
 reg [31:0] lvb_bb1_add_0_reg_NO_SHIFT_REG;
 reg [31:0] lvb_bb1_inc_0_reg_NO_SHIFT_REG;
 reg [31:0] lvb_input_global_id_0_0_reg_NO_SHIFT_REG;
 reg [31:0] lvb_input_acl_hw_wg_id_0_reg_NO_SHIFT_REG;

assign branch_var__inputs_ready = (local_bb1_exitcond_GUARD_valid_out & local_bb1_add_valid_out & rcnode_161to162_rc1_bb1_inc_0_valid_out_0_NO_SHIFT_REG);
assign branch_var__output_regs_ready = (~(branch_node_valid_out_0_NO_SHIFT_REG) | (((branch_compare_result_NO_SHIFT_REG != 1'b1) & ~(stall_in_1)) | (~((branch_compare_result_NO_SHIFT_REG != 1'b1)) & ~(stall_in_0))));
assign local_bb1_exitcond_GUARD_stall_in = (~(branch_var__output_regs_ready) | ~(branch_var__inputs_ready));
assign local_bb1_add_stall_in = (~(branch_var__output_regs_ready) | ~(branch_var__inputs_ready));
assign rcnode_161to162_rc1_bb1_inc_0_stall_in_0_NO_SHIFT_REG = (~(branch_var__output_regs_ready) | ~(branch_var__inputs_ready));
assign lvb_arrayidx3_0 = lvb_arrayidx3_0_reg_NO_SHIFT_REG;
assign lvb_arrayidx3_1 = lvb_arrayidx3_0_reg_NO_SHIFT_REG;
assign lvb_bb1_cmp1_NEG_RM_0 = lvb_bb1_cmp1_NEG_RM_0_reg_NO_SHIFT_REG;
assign lvb_bb1_cmp1_NEG_RM_1 = lvb_bb1_cmp1_NEG_RM_0_reg_NO_SHIFT_REG;
assign lvb_bb1_add_0 = lvb_bb1_add_0_reg_NO_SHIFT_REG;
assign lvb_bb1_add_1 = lvb_bb1_add_0_reg_NO_SHIFT_REG;
assign lvb_bb1_inc_0 = lvb_bb1_inc_0_reg_NO_SHIFT_REG;
assign lvb_bb1_inc_1 = lvb_bb1_inc_0_reg_NO_SHIFT_REG;
assign lvb_input_global_id_0_0 = lvb_input_global_id_0_0_reg_NO_SHIFT_REG;
assign lvb_input_global_id_0_1 = lvb_input_global_id_0_0_reg_NO_SHIFT_REG;
assign lvb_input_acl_hw_wg_id_0 = lvb_input_acl_hw_wg_id_0_reg_NO_SHIFT_REG;
assign lvb_input_acl_hw_wg_id_1 = lvb_input_acl_hw_wg_id_0_reg_NO_SHIFT_REG;
assign valid_out_0 = (~((branch_compare_result_NO_SHIFT_REG != 1'b1)) & branch_node_valid_out_0_NO_SHIFT_REG);
assign valid_out_1 = ((branch_compare_result_NO_SHIFT_REG != 1'b1) & branch_node_valid_out_0_NO_SHIFT_REG);
assign combined_branch_stall_in_signal = ((((branch_compare_result_NO_SHIFT_REG != 1'b1) & branch_node_valid_out_0_NO_SHIFT_REG) & stall_in_1) | ((~((branch_compare_result_NO_SHIFT_REG != 1'b1)) & branch_node_valid_out_0_NO_SHIFT_REG) & stall_in_0));

always @(posedge clock or negedge resetn)
begin
	if (~(resetn))
	begin
		branch_node_valid_out_0_NO_SHIFT_REG <= 1'b0;
		lvb_arrayidx3_0_reg_NO_SHIFT_REG <= 'x;
		lvb_bb1_cmp1_NEG_RM_0_reg_NO_SHIFT_REG <= 'x;
		lvb_bb1_add_0_reg_NO_SHIFT_REG <= 'x;
		lvb_bb1_inc_0_reg_NO_SHIFT_REG <= 'x;
		lvb_input_global_id_0_0_reg_NO_SHIFT_REG <= 'x;
		lvb_input_acl_hw_wg_id_0_reg_NO_SHIFT_REG <= 'x;
		branch_compare_result_NO_SHIFT_REG <= 'x;
	end
	else
	begin
		if (branch_var__output_regs_ready)
		begin
			branch_node_valid_out_0_NO_SHIFT_REG <= branch_var__inputs_ready;
			lvb_arrayidx3_0_reg_NO_SHIFT_REG <= (rcnode_161to162_rc1_bb1_inc_0_NO_SHIFT_REG[95:32] & 64'hFFFFFFFFFFFFFFFC);
			lvb_bb1_cmp1_NEG_RM_0_reg_NO_SHIFT_REG <= rcnode_161to162_rc1_bb1_inc_0_NO_SHIFT_REG[160];
			lvb_bb1_add_0_reg_NO_SHIFT_REG <= local_bb1_add;
			lvb_bb1_inc_0_reg_NO_SHIFT_REG <= rcnode_161to162_rc1_bb1_inc_0_NO_SHIFT_REG[31:0];
			lvb_input_global_id_0_0_reg_NO_SHIFT_REG <= rcnode_161to162_rc1_bb1_inc_0_NO_SHIFT_REG[127:96];
			lvb_input_acl_hw_wg_id_0_reg_NO_SHIFT_REG <= rcnode_161to162_rc1_bb1_inc_0_NO_SHIFT_REG[159:128];
			branch_compare_result_NO_SHIFT_REG <= local_bb1_exitcond_GUARD;
		end
		else
		begin
			if (~(combined_branch_stall_in_signal))
			begin
				branch_node_valid_out_0_NO_SHIFT_REG <= 1'b0;
			end
		end
	end
end


endmodule

//////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////

// altera message_off 10036
// altera message_off 10230
// altera message_off 10858
module sumOfElements_basic_block_2
	(
		input 		clock,
		input 		resetn,
		input 		valid_in,
		output 		stall_out,
		input [63:0] 		input_arrayidx3,
		input 		input_cmp1_NEG_RM,
		input [31:0] 		input_add,
		input [31:0] 		input_acl_hw_wg_id,
		output 		valid_out,
		input 		stall_in,
		output [31:0] 		lvb_input_acl_hw_wg_id,
		input [31:0] 		workgroup_size,
		input 		start,
		output 		avm_local_bb2_st_add_enable,
		input [511:0] 		avm_local_bb2_st_add_readdata,
		input 		avm_local_bb2_st_add_readdatavalid,
		input 		avm_local_bb2_st_add_waitrequest,
		output [27:0] 		avm_local_bb2_st_add_address,
		output 		avm_local_bb2_st_add_read,
		output 		avm_local_bb2_st_add_write,
		input 		avm_local_bb2_st_add_writeack,
		output [511:0] 		avm_local_bb2_st_add_writedata,
		output [63:0] 		avm_local_bb2_st_add_byteenable,
		output [5:0] 		avm_local_bb2_st_add_burstcount,
		output 		local_bb2_st_add_active,
		input 		clock2x
	);


// Values used for debugging.  These are swept away by synthesis.
wire _entry;
wire _exit;
 reg [31:0] _num_entry_NO_SHIFT_REG;
 reg [31:0] _num_exit_NO_SHIFT_REG;
wire [31:0] _num_live;

assign _entry = ((&valid_in) & ~((|stall_out)));
assign _exit = ((&valid_out) & ~((|stall_in)));
assign _num_live = (_num_entry_NO_SHIFT_REG - _num_exit_NO_SHIFT_REG);

always @(posedge clock or negedge resetn)
begin
	if (~(resetn))
	begin
		_num_entry_NO_SHIFT_REG <= 32'h0;
		_num_exit_NO_SHIFT_REG <= 32'h0;
	end
	else
	begin
		if (_entry)
		begin
			_num_entry_NO_SHIFT_REG <= (_num_entry_NO_SHIFT_REG + 2'h1);
		end
		if (_exit)
		begin
			_num_exit_NO_SHIFT_REG <= (_num_exit_NO_SHIFT_REG + 2'h1);
		end
	end
end



// This section defines the behaviour of the MERGE node
wire merge_node_stall_in_0;
 reg merge_node_valid_out_0_NO_SHIFT_REG;
wire merge_node_stall_in_1;
 reg merge_node_valid_out_1_NO_SHIFT_REG;
wire merge_stalled_by_successors;
 reg merge_block_selector_NO_SHIFT_REG;
 reg merge_node_valid_in_staging_reg_NO_SHIFT_REG;
 reg [63:0] input_arrayidx3_staging_reg_NO_SHIFT_REG;
 reg input_cmp1_NEG_RM_staging_reg_NO_SHIFT_REG;
 reg [31:0] input_add_staging_reg_NO_SHIFT_REG;
 reg [31:0] input_acl_hw_wg_id_staging_reg_NO_SHIFT_REG;
 reg [63:0] local_lvm_arrayidx3_NO_SHIFT_REG;
 reg local_lvm_cmp1_NEG_RM_NO_SHIFT_REG;
 reg [31:0] local_lvm_add_NO_SHIFT_REG;
 reg [31:0] local_lvm_input_acl_hw_wg_id_NO_SHIFT_REG;
 reg is_merge_data_to_local_regs_valid_NO_SHIFT_REG;
 reg invariant_valid_NO_SHIFT_REG;

assign merge_stalled_by_successors = ((merge_node_stall_in_0 & merge_node_valid_out_0_NO_SHIFT_REG) | (merge_node_stall_in_1 & merge_node_valid_out_1_NO_SHIFT_REG));
assign stall_out = merge_node_valid_in_staging_reg_NO_SHIFT_REG;

always @(*)
begin
	if ((merge_node_valid_in_staging_reg_NO_SHIFT_REG | valid_in))
	begin
		merge_block_selector_NO_SHIFT_REG = 1'b0;
		is_merge_data_to_local_regs_valid_NO_SHIFT_REG = 1'b1;
	end
	else
	begin
		merge_block_selector_NO_SHIFT_REG = 1'b0;
		is_merge_data_to_local_regs_valid_NO_SHIFT_REG = 1'b0;
	end
end

always @(posedge clock or negedge resetn)
begin
	if (~(resetn))
	begin
		input_arrayidx3_staging_reg_NO_SHIFT_REG <= 'x;
		input_cmp1_NEG_RM_staging_reg_NO_SHIFT_REG <= 'x;
		input_add_staging_reg_NO_SHIFT_REG <= 'x;
		input_acl_hw_wg_id_staging_reg_NO_SHIFT_REG <= 'x;
		merge_node_valid_in_staging_reg_NO_SHIFT_REG <= 1'b0;
	end
	else
	begin
		if (((merge_block_selector_NO_SHIFT_REG != 1'b0) | merge_stalled_by_successors))
		begin
			if (~(merge_node_valid_in_staging_reg_NO_SHIFT_REG))
			begin
				input_arrayidx3_staging_reg_NO_SHIFT_REG <= input_arrayidx3;
				input_cmp1_NEG_RM_staging_reg_NO_SHIFT_REG <= input_cmp1_NEG_RM;
				input_add_staging_reg_NO_SHIFT_REG <= input_add;
				input_acl_hw_wg_id_staging_reg_NO_SHIFT_REG <= input_acl_hw_wg_id;
				merge_node_valid_in_staging_reg_NO_SHIFT_REG <= valid_in;
			end
		end
		else
		begin
			merge_node_valid_in_staging_reg_NO_SHIFT_REG <= 1'b0;
		end
	end
end

always @(posedge clock)
begin
	if (~(merge_stalled_by_successors))
	begin
		case (merge_block_selector_NO_SHIFT_REG)
			1'b0:
			begin
				if (merge_node_valid_in_staging_reg_NO_SHIFT_REG)
				begin
					local_lvm_arrayidx3_NO_SHIFT_REG <= input_arrayidx3_staging_reg_NO_SHIFT_REG;
					local_lvm_cmp1_NEG_RM_NO_SHIFT_REG <= input_cmp1_NEG_RM_staging_reg_NO_SHIFT_REG;
					local_lvm_add_NO_SHIFT_REG <= input_add_staging_reg_NO_SHIFT_REG;
					local_lvm_input_acl_hw_wg_id_NO_SHIFT_REG <= input_acl_hw_wg_id_staging_reg_NO_SHIFT_REG;
				end
				else
				begin
					local_lvm_arrayidx3_NO_SHIFT_REG <= input_arrayidx3;
					local_lvm_cmp1_NEG_RM_NO_SHIFT_REG <= input_cmp1_NEG_RM;
					local_lvm_add_NO_SHIFT_REG <= input_add;
					local_lvm_input_acl_hw_wg_id_NO_SHIFT_REG <= input_acl_hw_wg_id;
				end
			end

			default:
			begin
			end

		endcase
	end
end

always @(posedge clock or negedge resetn)
begin
	if (~(resetn))
	begin
		merge_node_valid_out_0_NO_SHIFT_REG <= 1'b0;
		merge_node_valid_out_1_NO_SHIFT_REG <= 1'b0;
	end
	else
	begin
		if (~(merge_stalled_by_successors))
		begin
			merge_node_valid_out_0_NO_SHIFT_REG <= is_merge_data_to_local_regs_valid_NO_SHIFT_REG;
			merge_node_valid_out_1_NO_SHIFT_REG <= is_merge_data_to_local_regs_valid_NO_SHIFT_REG;
		end
		else
		begin
			if (~(merge_node_stall_in_0))
			begin
				merge_node_valid_out_0_NO_SHIFT_REG <= 1'b0;
			end
			if (~(merge_node_stall_in_1))
			begin
				merge_node_valid_out_1_NO_SHIFT_REG <= 1'b0;
			end
		end
	end
end

always @(posedge clock or negedge resetn)
begin
	if (~(resetn))
	begin
		invariant_valid_NO_SHIFT_REG <= 1'b0;
	end
	else
	begin
		invariant_valid_NO_SHIFT_REG <= (~(start) & (invariant_valid_NO_SHIFT_REG | is_merge_data_to_local_regs_valid_NO_SHIFT_REG));
	end
end


// This section implements a registered operation.
// 
wire local_bb2_st_add_inputs_ready;
 reg local_bb2_st_add_valid_out_NO_SHIFT_REG;
wire local_bb2_st_add_stall_in;
wire local_bb2_st_add_output_regs_ready;
wire local_bb2_st_add_fu_stall_out;
wire local_bb2_st_add_fu_valid_out;
wire local_bb2_st_add_causedstall;

lsu_top lsu_local_bb2_st_add (
	.clock(clock),
	.clock2x(clock2x),
	.resetn(resetn),
	.flush(start),
	.stream_base_addr(),
	.stream_size(),
	.stream_reset(),
	.o_stall(local_bb2_st_add_fu_stall_out),
	.i_valid(local_bb2_st_add_inputs_ready),
	.i_address((local_lvm_arrayidx3_NO_SHIFT_REG & 64'hFFFFFFFFFFFFFFFC)),
	.i_writedata(local_lvm_add_NO_SHIFT_REG),
	.i_cmpdata(),
	.i_predicate(local_lvm_cmp1_NEG_RM_NO_SHIFT_REG),
	.i_bitwiseor(64'h0),
	.i_byteenable(),
	.i_stall(~(local_bb2_st_add_output_regs_ready)),
	.o_valid(local_bb2_st_add_fu_valid_out),
	.o_readdata(),
	.o_input_fifo_depth(),
	.o_writeack(),
	.i_atomic_op(3'h0),
	.o_active(local_bb2_st_add_active),
	.avm_address(avm_local_bb2_st_add_address),
	.avm_read(avm_local_bb2_st_add_read),
	.avm_enable(avm_local_bb2_st_add_enable),
	.avm_readdata(avm_local_bb2_st_add_readdata),
	.avm_write(avm_local_bb2_st_add_write),
	.avm_writeack(avm_local_bb2_st_add_writeack),
	.avm_burstcount(avm_local_bb2_st_add_burstcount),
	.avm_writedata(avm_local_bb2_st_add_writedata),
	.avm_byteenable(avm_local_bb2_st_add_byteenable),
	.avm_waitrequest(avm_local_bb2_st_add_waitrequest),
	.avm_readdatavalid(avm_local_bb2_st_add_readdatavalid),
	.profile_bw(),
	.profile_bw_incr(),
	.profile_total_ivalid(),
	.profile_total_req(),
	.profile_i_stall_count(),
	.profile_o_stall_count(),
	.profile_avm_readwrite_count(),
	.profile_avm_burstcount_total(),
	.profile_avm_burstcount_total_incr(),
	.profile_req_cache_hit_count(),
	.profile_extra_unaligned_reqs(),
	.profile_avm_stall()
);

defparam lsu_local_bb2_st_add.AWIDTH = 28;
defparam lsu_local_bb2_st_add.WIDTH_BYTES = 4;
defparam lsu_local_bb2_st_add.MWIDTH_BYTES = 64;
defparam lsu_local_bb2_st_add.WRITEDATAWIDTH_BYTES = 64;
defparam lsu_local_bb2_st_add.ALIGNMENT_BYTES = 4;
defparam lsu_local_bb2_st_add.READ = 0;
defparam lsu_local_bb2_st_add.ATOMIC = 0;
defparam lsu_local_bb2_st_add.WIDTH = 32;
defparam lsu_local_bb2_st_add.MWIDTH = 512;
defparam lsu_local_bb2_st_add.ATOMIC_WIDTH = 3;
defparam lsu_local_bb2_st_add.BURSTCOUNT_WIDTH = 6;
defparam lsu_local_bb2_st_add.KERNEL_SIDE_MEM_LATENCY = 4;
defparam lsu_local_bb2_st_add.MEMORY_SIDE_MEM_LATENCY = 8;
defparam lsu_local_bb2_st_add.USE_WRITE_ACK = 0;
defparam lsu_local_bb2_st_add.ENABLE_BANKED_MEMORY = 0;
defparam lsu_local_bb2_st_add.ABITS_PER_LMEM_BANK = 0;
defparam lsu_local_bb2_st_add.NUMBER_BANKS = 1;
defparam lsu_local_bb2_st_add.LMEM_ADDR_PERMUTATION_STYLE = 0;
defparam lsu_local_bb2_st_add.INTENDED_DEVICE_FAMILY = "Stratix V";
defparam lsu_local_bb2_st_add.USEINPUTFIFO = 0;
defparam lsu_local_bb2_st_add.USECACHING = 0;
defparam lsu_local_bb2_st_add.USEOUTPUTFIFO = 1;
defparam lsu_local_bb2_st_add.FORCE_NOP_SUPPORT = 0;
defparam lsu_local_bb2_st_add.HIGH_FMAX = 1;
defparam lsu_local_bb2_st_add.ADDRSPACE = 1;
defparam lsu_local_bb2_st_add.STYLE = "BURST-COALESCED";
defparam lsu_local_bb2_st_add.USE_BYTE_EN = 0;

assign local_bb2_st_add_inputs_ready = merge_node_valid_out_0_NO_SHIFT_REG;
assign local_bb2_st_add_output_regs_ready = (&(~(local_bb2_st_add_valid_out_NO_SHIFT_REG) | ~(local_bb2_st_add_stall_in)));
assign merge_node_stall_in_0 = (local_bb2_st_add_fu_stall_out | ~(local_bb2_st_add_inputs_ready));
assign local_bb2_st_add_causedstall = (local_bb2_st_add_inputs_ready && (local_bb2_st_add_fu_stall_out && !(~(local_bb2_st_add_output_regs_ready))));

always @(posedge clock or negedge resetn)
begin
	if (~(resetn))
	begin
		local_bb2_st_add_valid_out_NO_SHIFT_REG <= 1'b0;
	end
	else
	begin
		if (local_bb2_st_add_output_regs_ready)
		begin
			local_bb2_st_add_valid_out_NO_SHIFT_REG <= local_bb2_st_add_fu_valid_out;
		end
		else
		begin
			if (~(local_bb2_st_add_stall_in))
			begin
				local_bb2_st_add_valid_out_NO_SHIFT_REG <= 1'b0;
			end
		end
	end
end


// Register node:
//  * latency = 4
//  * capacity = 4
 logic rnode_1to5_input_acl_hw_wg_id_0_valid_out_NO_SHIFT_REG;
 logic rnode_1to5_input_acl_hw_wg_id_0_stall_in_NO_SHIFT_REG;
 logic [31:0] rnode_1to5_input_acl_hw_wg_id_0_NO_SHIFT_REG;
 logic rnode_1to5_input_acl_hw_wg_id_0_reg_5_inputs_ready_NO_SHIFT_REG;
 logic [31:0] rnode_1to5_input_acl_hw_wg_id_0_reg_5_NO_SHIFT_REG;
 logic rnode_1to5_input_acl_hw_wg_id_0_valid_out_reg_5_NO_SHIFT_REG;
 logic rnode_1to5_input_acl_hw_wg_id_0_stall_in_reg_5_NO_SHIFT_REG;
 logic rnode_1to5_input_acl_hw_wg_id_0_stall_out_reg_5_NO_SHIFT_REG;

acl_data_fifo rnode_1to5_input_acl_hw_wg_id_0_reg_5_fifo (
	.clock(clock),
	.resetn(resetn),
	.valid_in(rnode_1to5_input_acl_hw_wg_id_0_reg_5_inputs_ready_NO_SHIFT_REG),
	.stall_in(rnode_1to5_input_acl_hw_wg_id_0_stall_in_reg_5_NO_SHIFT_REG),
	.valid_out(rnode_1to5_input_acl_hw_wg_id_0_valid_out_reg_5_NO_SHIFT_REG),
	.stall_out(rnode_1to5_input_acl_hw_wg_id_0_stall_out_reg_5_NO_SHIFT_REG),
	.data_in(local_lvm_input_acl_hw_wg_id_NO_SHIFT_REG),
	.data_out(rnode_1to5_input_acl_hw_wg_id_0_reg_5_NO_SHIFT_REG)
);

defparam rnode_1to5_input_acl_hw_wg_id_0_reg_5_fifo.DEPTH = 5;
defparam rnode_1to5_input_acl_hw_wg_id_0_reg_5_fifo.DATA_WIDTH = 32;
defparam rnode_1to5_input_acl_hw_wg_id_0_reg_5_fifo.ALLOW_FULL_WRITE = 0;
defparam rnode_1to5_input_acl_hw_wg_id_0_reg_5_fifo.IMPL = "ll_reg";

assign rnode_1to5_input_acl_hw_wg_id_0_reg_5_inputs_ready_NO_SHIFT_REG = merge_node_valid_out_1_NO_SHIFT_REG;
assign merge_node_stall_in_1 = rnode_1to5_input_acl_hw_wg_id_0_stall_out_reg_5_NO_SHIFT_REG;
assign rnode_1to5_input_acl_hw_wg_id_0_NO_SHIFT_REG = rnode_1to5_input_acl_hw_wg_id_0_reg_5_NO_SHIFT_REG;
assign rnode_1to5_input_acl_hw_wg_id_0_stall_in_reg_5_NO_SHIFT_REG = rnode_1to5_input_acl_hw_wg_id_0_stall_in_NO_SHIFT_REG;
assign rnode_1to5_input_acl_hw_wg_id_0_valid_out_NO_SHIFT_REG = rnode_1to5_input_acl_hw_wg_id_0_valid_out_reg_5_NO_SHIFT_REG;

// This section implements a staging register.
// 
wire rstag_5to5_bb2_st_add_valid_out;
wire rstag_5to5_bb2_st_add_stall_in;
wire rstag_5to5_bb2_st_add_inputs_ready;
wire rstag_5to5_bb2_st_add_stall_local;
 reg rstag_5to5_bb2_st_add_staging_valid_NO_SHIFT_REG;
wire rstag_5to5_bb2_st_add_combined_valid;

assign rstag_5to5_bb2_st_add_inputs_ready = local_bb2_st_add_valid_out_NO_SHIFT_REG;
assign rstag_5to5_bb2_st_add_combined_valid = (rstag_5to5_bb2_st_add_staging_valid_NO_SHIFT_REG | rstag_5to5_bb2_st_add_inputs_ready);
assign rstag_5to5_bb2_st_add_valid_out = rstag_5to5_bb2_st_add_combined_valid;
assign rstag_5to5_bb2_st_add_stall_local = rstag_5to5_bb2_st_add_stall_in;
assign local_bb2_st_add_stall_in = (|rstag_5to5_bb2_st_add_staging_valid_NO_SHIFT_REG);

always @(posedge clock or negedge resetn)
begin
	if (~(resetn))
	begin
		rstag_5to5_bb2_st_add_staging_valid_NO_SHIFT_REG <= 1'b0;
	end
	else
	begin
		if (rstag_5to5_bb2_st_add_stall_local)
		begin
			if (~(rstag_5to5_bb2_st_add_staging_valid_NO_SHIFT_REG))
			begin
				rstag_5to5_bb2_st_add_staging_valid_NO_SHIFT_REG <= rstag_5to5_bb2_st_add_inputs_ready;
			end
		end
		else
		begin
			rstag_5to5_bb2_st_add_staging_valid_NO_SHIFT_REG <= 1'b0;
		end
	end
end


// This section describes the behaviour of the BRANCH node.
wire branch_var__inputs_ready;
wire branch_var__output_regs_ready;

assign branch_var__inputs_ready = (rnode_1to5_input_acl_hw_wg_id_0_valid_out_NO_SHIFT_REG & rstag_5to5_bb2_st_add_valid_out);
assign branch_var__output_regs_ready = ~(stall_in);
assign rnode_1to5_input_acl_hw_wg_id_0_stall_in_NO_SHIFT_REG = (~(branch_var__output_regs_ready) | ~(branch_var__inputs_ready));
assign rstag_5to5_bb2_st_add_stall_in = (~(branch_var__output_regs_ready) | ~(branch_var__inputs_ready));
assign valid_out = branch_var__inputs_ready;
assign lvb_input_acl_hw_wg_id = rnode_1to5_input_acl_hw_wg_id_0_NO_SHIFT_REG;

endmodule

//////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////

module shiftSignal3( clock, resetn, valid_in, ready_out, din, dout );

   parameter WIDTH=32;
   parameter CYCLES=6;

   input clock;
   input resetn;
   input valid_in;
   input ready_out;
   input [WIDTH-1:0] din;
   output [WIDTH-1:0] dout;

   integer t;

   reg [WIDTH-1:0] my_shift_reg[0:CYCLES-1];

   assign dout = my_shift_reg[CYCLES-1];

   always@(posedge clock or negedge resetn)
     begin
        if (!resetn) begin
           my_shift_reg[0] <= {WIDTH{1'b0}};
        end
        else if(valid_in && ready_out) begin
           my_shift_reg[0] <= din;
        end
        else if(ready_out) begin
           my_shift_reg[0] <= {WIDTH{1'b0}};
        end
     end
   
   always@(posedge clock or negedge resetn)
     begin
        for (t=1; t<CYCLES; t=t+1) begin
           if (!resetn) begin
              my_shift_reg[t] <= {WIDTH{1'b0}};
           end
           else if(ready_out) begin
              my_shift_reg[t] <= my_shift_reg[t-1];
           end
        end
     end
endmodule 


// altera message_off 10036
// altera message_off 10230
// altera message_off 10858
module sumOfElements_function
	(
		input 		clock,
		input 		resetn,
		input [31:0] 		m_input_global_id_0,
		input [31:0] 		m_input_acl_hw_wg_id,
		output 		m_ready_out,
		input 		m_valid_in,
		output [31:0] 		m_output_0,
		output 		m_valid_out,
		input 		m_ready_in,
		input [31:0] 		m_workgroup_size,
		output 		avm_local_bb0_ld_arrayidx3_promoted_enable,
		input [511:0] 		avm_local_bb0_ld_arrayidx3_promoted_readdata,
		input 		avm_local_bb0_ld_arrayidx3_promoted_readdatavalid,
		input 		avm_local_bb0_ld_arrayidx3_promoted_waitrequest,
		output [27:0] 		avm_local_bb0_ld_arrayidx3_promoted_address,
		output 		avm_local_bb0_ld_arrayidx3_promoted_read,
		output 		avm_local_bb0_ld_arrayidx3_promoted_write,
		input 		avm_local_bb0_ld_arrayidx3_promoted_writeack,
		output [511:0] 		avm_local_bb0_ld_arrayidx3_promoted_writedata,
		output [63:0] 		avm_local_bb0_ld_arrayidx3_promoted_byteenable,
		output [5:0] 		avm_local_bb0_ld_arrayidx3_promoted_burstcount,
		output 		avm_local_bb1_ld__enable,
		input [511:0] 		avm_local_bb1_ld__readdata,
		input 		avm_local_bb1_ld__readdatavalid,
		input 		avm_local_bb1_ld__waitrequest,
		output [27:0] 		avm_local_bb1_ld__address,
		output 		avm_local_bb1_ld__read,
		output 		avm_local_bb1_ld__write,
		input 		avm_local_bb1_ld__writeack,
		output [511:0] 		avm_local_bb1_ld__writedata,
		output [63:0] 		avm_local_bb1_ld__byteenable,
		output [5:0] 		avm_local_bb1_ld__burstcount,
		output 		avm_local_bb2_st_add_enable,
		input [511:0] 		avm_local_bb2_st_add_readdata,
		input 		avm_local_bb2_st_add_readdatavalid,
		input 		avm_local_bb2_st_add_waitrequest,
		output [27:0] 		avm_local_bb2_st_add_address,
		output 		avm_local_bb2_st_add_read,
		output 		avm_local_bb2_st_add_write,
		input 		avm_local_bb2_st_add_writeack,
		output [511:0] 		avm_local_bb2_st_add_writedata,
		output [63:0] 		avm_local_bb2_st_add_byteenable,
		output [5:0] 		avm_local_bb2_st_add_burstcount,
		input 		clock2x,
		input 		m_start,
		input [63:0] 		m_input_sum,
		input [31:0] 		m_input_global_size_0,
		input [63:0] 		m_input_A,
		input [31:0] 		m_input_N,
		output reg 		has_a_write_pending,
		output reg 		has_a_lsu_active
	);


wire [31:0] cur_cycle;
wire bb_0_stall_out;
wire bb_0_valid_out;
wire [63:0] bb_0_lvb_bb0_arrayidx3;
wire [31:0] bb_0_lvb_bb0_ld_arrayidx3_promoted;
wire [31:0] bb_0_lvb_input_global_id_0;
wire [31:0] bb_0_lvb_input_acl_hw_wg_id;
wire bb_0_local_bb0_ld_arrayidx3_promoted_active;
wire bb_1_stall_out_0;
wire bb_1_stall_out_1;
wire bb_1_valid_out_0;
wire [63:0] bb_1_lvb_arrayidx3_0;
wire bb_1_lvb_bb1_cmp1_NEG_RM_0;
wire [31:0] bb_1_lvb_bb1_add_0;
wire [31:0] bb_1_lvb_bb1_inc_0;
wire [31:0] bb_1_lvb_input_global_id_0_0;
wire [31:0] bb_1_lvb_input_acl_hw_wg_id_0;
wire bb_1_valid_out_1;
wire [63:0] bb_1_lvb_arrayidx3_1;
wire bb_1_lvb_bb1_cmp1_NEG_RM_1;
wire [31:0] bb_1_lvb_bb1_add_1;
wire [31:0] bb_1_lvb_bb1_inc_1;
wire [31:0] bb_1_lvb_input_global_id_0_1;
wire [31:0] bb_1_lvb_input_acl_hw_wg_id_1;
wire bb_1_local_bb1_ld__active;
wire bb_2_stall_out;
wire bb_2_valid_out;
wire [31:0] bb_2_lvb_input_acl_hw_wg_id;
wire bb_2_local_bb2_st_add_active;
wire loop_limiter_0_stall_out;
wire loop_limiter_0_valid_out;
wire writes_pending;
wire [2:0] lsus_active;

   // utku:
wire start;
reg [3:0] r_start;
wire stall_out;
wire stall_in;
wire valid_in;
wire valid_out;
wire [31:0] output_0;
wire [31:0] input_global_id_0;
wire [31:0] input_acl_hw_wg_id;
wire [31:0] input_global_size_0;
wire [31:0] workgroup_size;
wire [63:0] input_A;
wire [63:0] input_sum;
wire [31:0] input_N;
assign m_output_0 = output_0;   
assign start = (r_start == 4'b0100 || r_start == 4'b0010);   
assign m_ready_out  = ~stall_out;
assign stall_in = ~m_ready_in;   
assign m_valid_out = valid_out;   
always_ff@(posedge clock or negedge resetn)
  if ( !resetn)
    r_start <= 4'b0001;
  else if( m_valid_in && r_start != 4'b1000)
    r_start <= (r_start << 1);
   shiftSignal3 shiftValidIn(clock, resetn, m_valid_in, m_ready_out, m_valid_in, valid_in);
   defparam shiftValidIn.WIDTH = 1;
   shiftSignal3 shiftGlobalId(clock, resetn, m_valid_in, m_ready_out, m_input_global_id_0, input_global_id_0);
   defparam shiftGlobalId.WIDTH = 32;
   shiftSignal3 shiftLocalId3(clock, resetn, m_valid_in, m_ready_out, m_input_acl_hw_wg_id, input_acl_hw_wg_id);
   defparam shiftLocalId3.WIDTH = 32;
   //shiftSignal3 shiftWorkGroupSize(clock, resetn, m_valid_in, m_ready_out, m_workgroup_size, workgroup_size);
   //defparam shiftWorkGroupSize.WIDTH = 32;
   assign workgroup_size = m_workgroup_size;
   //shiftSignal3 shiftGlobalSize(clock, resetn, m_valid_in, m_ready_out, m_input_global_size_0, input_global_size_0);
   //defparam shiftGlobalId.WIDTH = 32;
   assign input_global_size_0 = m_input_global_size_0;
   assign input_A = m_input_A;
   assign input_sum = m_input_sum;
   assign input_N = m_input_N;
acl_loop_limiter loop_limiter_0 (
	.clock(clock),
	.resetn(resetn),
	.i_valid(bb_0_valid_out),
	.i_stall(bb_1_stall_out_1),
	.i_valid_exit(bb_1_valid_out_0),
	.i_stall_exit(bb_2_stall_out),
	.o_valid(loop_limiter_0_valid_out),
	.o_stall(loop_limiter_0_stall_out)
);

defparam loop_limiter_0.ENTRY_WIDTH = 1;
defparam loop_limiter_0.EXIT_WIDTH = 1;
defparam loop_limiter_0.THRESHOLD = 163;

sumOfElements_basic_block_0 sumOfElements_basic_block_0 (
	.clock(clock),
	.resetn(resetn),
	.input_sum(input_sum),
	.input_global_size_0(input_global_size_0),
	.valid_in(valid_in),
	.stall_out(bb_0_stall_out),
	.input_global_id_0(input_global_id_0),
	.input_acl_hw_wg_id(input_acl_hw_wg_id),
	.valid_out(bb_0_valid_out),
	.stall_in(loop_limiter_0_stall_out),
	.lvb_bb0_arrayidx3(bb_0_lvb_bb0_arrayidx3),
	.lvb_bb0_ld_arrayidx3_promoted(bb_0_lvb_bb0_ld_arrayidx3_promoted),
	.lvb_input_global_id_0(bb_0_lvb_input_global_id_0),
	.lvb_input_acl_hw_wg_id(bb_0_lvb_input_acl_hw_wg_id),
	.workgroup_size(workgroup_size),
	.start(start),
	.avm_local_bb0_ld_arrayidx3_promoted_enable(avm_local_bb0_ld_arrayidx3_promoted_enable),
	.avm_local_bb0_ld_arrayidx3_promoted_readdata(avm_local_bb0_ld_arrayidx3_promoted_readdata),
	.avm_local_bb0_ld_arrayidx3_promoted_readdatavalid(avm_local_bb0_ld_arrayidx3_promoted_readdatavalid),
	.avm_local_bb0_ld_arrayidx3_promoted_waitrequest(avm_local_bb0_ld_arrayidx3_promoted_waitrequest),
	.avm_local_bb0_ld_arrayidx3_promoted_address(avm_local_bb0_ld_arrayidx3_promoted_address),
	.avm_local_bb0_ld_arrayidx3_promoted_read(avm_local_bb0_ld_arrayidx3_promoted_read),
	.avm_local_bb0_ld_arrayidx3_promoted_write(avm_local_bb0_ld_arrayidx3_promoted_write),
	.avm_local_bb0_ld_arrayidx3_promoted_writeack(avm_local_bb0_ld_arrayidx3_promoted_writeack),
	.avm_local_bb0_ld_arrayidx3_promoted_writedata(avm_local_bb0_ld_arrayidx3_promoted_writedata),
	.avm_local_bb0_ld_arrayidx3_promoted_byteenable(avm_local_bb0_ld_arrayidx3_promoted_byteenable),
	.avm_local_bb0_ld_arrayidx3_promoted_burstcount(avm_local_bb0_ld_arrayidx3_promoted_burstcount),
	.local_bb0_ld_arrayidx3_promoted_active(bb_0_local_bb0_ld_arrayidx3_promoted_active),
	.clock2x(clock2x)
);


sumOfElements_basic_block_1 sumOfElements_basic_block_1 (
	.clock(clock),
	.resetn(resetn),
	.input_A(input_A),
	.input_N(input_N),
	.valid_in_0(bb_1_valid_out_1),
	.stall_out_0(bb_1_stall_out_0),
	.input_arrayidx3_0(bb_1_lvb_arrayidx3_1),
	.input_add3_0(bb_1_lvb_bb1_add_1),
	.input_i_02_0(bb_1_lvb_bb1_inc_1),
	.input_global_id_0_0(bb_1_lvb_input_global_id_0_1),
	.input_acl_hw_wg_id_0(bb_1_lvb_input_acl_hw_wg_id_1),
	.valid_in_1(loop_limiter_0_valid_out),
	.stall_out_1(bb_1_stall_out_1),
	.input_arrayidx3_1(bb_0_lvb_bb0_arrayidx3),
	.input_add3_1(bb_0_lvb_bb0_ld_arrayidx3_promoted),
	.input_i_02_1(bb_0_lvb_input_global_id_0),
	.input_global_id_0_1(bb_0_lvb_input_global_id_0),
	.input_acl_hw_wg_id_1(bb_0_lvb_input_acl_hw_wg_id),
	.valid_out_0(bb_1_valid_out_0),
	.stall_in_0(bb_2_stall_out),
	.lvb_arrayidx3_0(bb_1_lvb_arrayidx3_0),
	.lvb_bb1_cmp1_NEG_RM_0(bb_1_lvb_bb1_cmp1_NEG_RM_0),
	.lvb_bb1_add_0(bb_1_lvb_bb1_add_0),
	.lvb_bb1_inc_0(bb_1_lvb_bb1_inc_0),
	.lvb_input_global_id_0_0(bb_1_lvb_input_global_id_0_0),
	.lvb_input_acl_hw_wg_id_0(bb_1_lvb_input_acl_hw_wg_id_0),
	.valid_out_1(bb_1_valid_out_1),
	.stall_in_1(bb_1_stall_out_0),
	.lvb_arrayidx3_1(bb_1_lvb_arrayidx3_1),
	.lvb_bb1_cmp1_NEG_RM_1(bb_1_lvb_bb1_cmp1_NEG_RM_1),
	.lvb_bb1_add_1(bb_1_lvb_bb1_add_1),
	.lvb_bb1_inc_1(bb_1_lvb_bb1_inc_1),
	.lvb_input_global_id_0_1(bb_1_lvb_input_global_id_0_1),
	.lvb_input_acl_hw_wg_id_1(bb_1_lvb_input_acl_hw_wg_id_1),
	.workgroup_size(workgroup_size),
	.start(start),
	.avm_local_bb1_ld__enable(avm_local_bb1_ld__enable),
	.avm_local_bb1_ld__readdata(avm_local_bb1_ld__readdata),
	.avm_local_bb1_ld__readdatavalid(avm_local_bb1_ld__readdatavalid),
	.avm_local_bb1_ld__waitrequest(avm_local_bb1_ld__waitrequest),
	.avm_local_bb1_ld__address(avm_local_bb1_ld__address),
	.avm_local_bb1_ld__read(avm_local_bb1_ld__read),
	.avm_local_bb1_ld__write(avm_local_bb1_ld__write),
	.avm_local_bb1_ld__writeack(avm_local_bb1_ld__writeack),
	.avm_local_bb1_ld__writedata(avm_local_bb1_ld__writedata),
	.avm_local_bb1_ld__byteenable(avm_local_bb1_ld__byteenable),
	.avm_local_bb1_ld__burstcount(avm_local_bb1_ld__burstcount),
	.local_bb1_ld__active(bb_1_local_bb1_ld__active),
	.clock2x(clock2x)
);


sumOfElements_basic_block_2 sumOfElements_basic_block_2 (
	.clock(clock),
	.resetn(resetn),
	.valid_in(bb_1_valid_out_0),
	.stall_out(bb_2_stall_out),
	.input_arrayidx3(bb_1_lvb_arrayidx3_0),
	.input_cmp1_NEG_RM(bb_1_lvb_bb1_cmp1_NEG_RM_0),
	.input_add(bb_1_lvb_bb1_add_0),
	.input_acl_hw_wg_id(bb_1_lvb_input_acl_hw_wg_id_0),
	.valid_out(bb_2_valid_out),
	.stall_in(stall_in),
	.lvb_input_acl_hw_wg_id(bb_2_lvb_input_acl_hw_wg_id),
	.workgroup_size(workgroup_size),
	.start(start),
	.avm_local_bb2_st_add_enable(avm_local_bb2_st_add_enable),
	.avm_local_bb2_st_add_readdata(avm_local_bb2_st_add_readdata),
	.avm_local_bb2_st_add_readdatavalid(avm_local_bb2_st_add_readdatavalid),
	.avm_local_bb2_st_add_waitrequest(avm_local_bb2_st_add_waitrequest),
	.avm_local_bb2_st_add_address(avm_local_bb2_st_add_address),
	.avm_local_bb2_st_add_read(avm_local_bb2_st_add_read),
	.avm_local_bb2_st_add_write(avm_local_bb2_st_add_write),
	.avm_local_bb2_st_add_writeack(avm_local_bb2_st_add_writeack),
	.avm_local_bb2_st_add_writedata(avm_local_bb2_st_add_writedata),
	.avm_local_bb2_st_add_byteenable(avm_local_bb2_st_add_byteenable),
	.avm_local_bb2_st_add_burstcount(avm_local_bb2_st_add_burstcount),
	.local_bb2_st_add_active(bb_2_local_bb2_st_add_active),
	.clock2x(clock2x)
);


sumOfElements_sys_cycle_time system_cycle_time_module (
	.clock(clock),
	.resetn(resetn),
	.cur_cycle(cur_cycle)
);


assign valid_out = bb_2_valid_out;
assign output_0 = bb_2_lvb_input_acl_hw_wg_id;
assign stall_out = bb_0_stall_out;
assign writes_pending = bb_2_local_bb2_st_add_active;
assign lsus_active[0] = bb_0_local_bb0_ld_arrayidx3_promoted_active;
assign lsus_active[1] = bb_1_local_bb1_ld__active;
assign lsus_active[2] = bb_2_local_bb2_st_add_active;

always @(posedge clock or negedge resetn)
begin
	if (~(resetn))
	begin
		has_a_write_pending <= 1'b0;
		has_a_lsu_active <= 1'b0;
	end
	else
	begin
		has_a_write_pending <= (|writes_pending);
		has_a_lsu_active <= (|lsus_active);
	end
end

endmodule

//////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////

// altera message_off 10036
// altera message_off 10230
// altera message_off 10858
module sumOfElements_function_wrapper
	(
		input 		clock,
		input 		resetn,
		input 		clock2x,
		input 		local_router_hang,
		input 		avs_cra_enable,
		input 		avs_cra_read,
		input 		avs_cra_write,
		input [3:0] 		avs_cra_address,
		input [63:0] 		avs_cra_writedata,
		input [7:0] 		avs_cra_byteenable,
		output reg [63:0] 		avs_cra_readdata,
		output reg 		avs_cra_readdatavalid,
		output 		cra_irq,
		output 		avm_local_bb0_ld_arrayidx3_promoted_inst0_enable,
		input [511:0] 		avm_local_bb0_ld_arrayidx3_promoted_inst0_readdata,
		input 		avm_local_bb0_ld_arrayidx3_promoted_inst0_readdatavalid,
		input 		avm_local_bb0_ld_arrayidx3_promoted_inst0_waitrequest,
		output [27:0] 		avm_local_bb0_ld_arrayidx3_promoted_inst0_address,
		output 		avm_local_bb0_ld_arrayidx3_promoted_inst0_read,
		output 		avm_local_bb0_ld_arrayidx3_promoted_inst0_write,
		input 		avm_local_bb0_ld_arrayidx3_promoted_inst0_writeack,
		output [511:0] 		avm_local_bb0_ld_arrayidx3_promoted_inst0_writedata,
		output [63:0] 		avm_local_bb0_ld_arrayidx3_promoted_inst0_byteenable,
		output [5:0] 		avm_local_bb0_ld_arrayidx3_promoted_inst0_burstcount,
		output 		avm_local_bb1_ld__inst0_enable,
		input [511:0] 		avm_local_bb1_ld__inst0_readdata,
		input 		avm_local_bb1_ld__inst0_readdatavalid,
		input 		avm_local_bb1_ld__inst0_waitrequest,
		output [27:0] 		avm_local_bb1_ld__inst0_address,
		output 		avm_local_bb1_ld__inst0_read,
		output 		avm_local_bb1_ld__inst0_write,
		input 		avm_local_bb1_ld__inst0_writeack,
		output [511:0] 		avm_local_bb1_ld__inst0_writedata,
		output [63:0] 		avm_local_bb1_ld__inst0_byteenable,
		output [5:0] 		avm_local_bb1_ld__inst0_burstcount,
		output 		avm_local_bb2_st_add_inst0_enable,
		input [511:0] 		avm_local_bb2_st_add_inst0_readdata,
		input 		avm_local_bb2_st_add_inst0_readdatavalid,
		input 		avm_local_bb2_st_add_inst0_waitrequest,
		output [27:0] 		avm_local_bb2_st_add_inst0_address,
		output 		avm_local_bb2_st_add_inst0_read,
		output 		avm_local_bb2_st_add_inst0_write,
		input 		avm_local_bb2_st_add_inst0_writeack,
		output [511:0] 		avm_local_bb2_st_add_inst0_writedata,
		output [63:0] 		avm_local_bb2_st_add_inst0_byteenable,
		output [5:0] 		avm_local_bb2_st_add_inst0_burstcount
	);

// Responsible for interfacing a kernel with the outside world. It comprises a
// slave interface to specify the kernel arguments and retain kernel status. 

// This section of the wrapper implements the slave interface.
// twoXclock_consumer uses clock2x, even if nobody inside the kernel does. Keeps interface to acl_iface consistent for all kernels.
 reg start_NO_SHIFT_REG;
 reg started_NO_SHIFT_REG;
wire finish;
 reg [31:0] status_NO_SHIFT_REG;
wire has_a_write_pending;
wire has_a_lsu_active;
 reg [159:0] kernel_arguments_NO_SHIFT_REG;
 reg twoXclock_consumer_NO_SHIFT_REG /* synthesis  preserve  noprune  */;
 reg [31:0] workgroup_size_NO_SHIFT_REG;
 reg [31:0] global_size_NO_SHIFT_REG[2:0];
 reg [31:0] num_groups_NO_SHIFT_REG[2:0];
 reg [31:0] local_size_NO_SHIFT_REG[2:0];
 reg [31:0] work_dim_NO_SHIFT_REG;
 reg [31:0] global_offset_NO_SHIFT_REG[2:0];
 reg [63:0] profile_data_NO_SHIFT_REG;
 reg [31:0] profile_ctrl_NO_SHIFT_REG;
 reg [63:0] profile_start_cycle_NO_SHIFT_REG;
 reg [63:0] profile_stop_cycle_NO_SHIFT_REG;
wire dispatched_all_groups;
wire [31:0] group_id_tmp[2:0];
wire [31:0] global_id_base_out[2:0];
wire start_out;
wire [31:0] local_id[0:0][2:0];
wire [31:0] global_id[0:0][2:0];
wire [31:0] group_id[0:0][2:0];
wire iter_valid_in;
wire iter_stall_out;
wire stall_in;
wire stall_out;
wire valid_in;
wire valid_out;

always @(posedge clock2x or negedge resetn)
begin
	if (~(resetn))
	begin
		twoXclock_consumer_NO_SHIFT_REG <= 1'b0;
	end
	else
	begin
		twoXclock_consumer_NO_SHIFT_REG <= 1'b1;
	end
end



// Work group dispatcher is responsible for issuing work-groups to id iterator(s)
acl_work_group_dispatcher group_dispatcher (
	.clock(clock),
	.resetn(resetn),
	.start(start_NO_SHIFT_REG),
	.num_groups(num_groups_NO_SHIFT_REG),
	.local_size(local_size_NO_SHIFT_REG),
	.stall_in(iter_stall_out),
	.valid_out(iter_valid_in),
	.group_id_out(group_id_tmp),
	.global_id_base_out(global_id_base_out),
	.start_out(start_out),
	.dispatched_all_groups(dispatched_all_groups)
);

defparam group_dispatcher.NUM_COPIES = 1;
defparam group_dispatcher.RUN_FOREVER = 0;


// This section of the wrapper implements an Avalon Slave Interface used to configure a kernel invocation.
// The few words words contain the status and the workgroup size registers.
// The remaining addressable space is reserved for kernel arguments.
 reg [63:0] cra_readdata_st1_NO_SHIFT_REG;
 reg [3:0] cra_addr_st1_NO_SHIFT_REG;
 reg cra_read_st1_NO_SHIFT_REG;
wire [63:0] bitenable;

assign bitenable[7:0] = (avs_cra_byteenable[0] ? 8'hFF : 8'h0);
assign bitenable[15:8] = (avs_cra_byteenable[1] ? 8'hFF : 8'h0);
assign bitenable[23:16] = (avs_cra_byteenable[2] ? 8'hFF : 8'h0);
assign bitenable[31:24] = (avs_cra_byteenable[3] ? 8'hFF : 8'h0);
assign bitenable[39:32] = (avs_cra_byteenable[4] ? 8'hFF : 8'h0);
assign bitenable[47:40] = (avs_cra_byteenable[5] ? 8'hFF : 8'h0);
assign bitenable[55:48] = (avs_cra_byteenable[6] ? 8'hFF : 8'h0);
assign bitenable[63:56] = (avs_cra_byteenable[7] ? 8'hFF : 8'h0);
assign cra_irq = (status_NO_SHIFT_REG[1] | status_NO_SHIFT_REG[3]);

always @(posedge clock or negedge resetn)
begin
	if (~(resetn))
	begin
		start_NO_SHIFT_REG <= 1'b0;
		started_NO_SHIFT_REG <= 1'b0;
		kernel_arguments_NO_SHIFT_REG <= 160'h0;
		status_NO_SHIFT_REG <= 32'h30000;
		profile_ctrl_NO_SHIFT_REG <= 32'h4;
		profile_start_cycle_NO_SHIFT_REG <= 64'h0;
		profile_stop_cycle_NO_SHIFT_REG <= 64'hFFFFFFFFFFFFFFFF;
		work_dim_NO_SHIFT_REG <= 32'h0;
		workgroup_size_NO_SHIFT_REG <= 32'h0;
		global_size_NO_SHIFT_REG[0] <= 32'h0;
		global_size_NO_SHIFT_REG[1] <= 32'h0;
		global_size_NO_SHIFT_REG[2] <= 32'h0;
		num_groups_NO_SHIFT_REG[0] <= 32'h0;
		num_groups_NO_SHIFT_REG[1] <= 32'h0;
		num_groups_NO_SHIFT_REG[2] <= 32'h0;
		local_size_NO_SHIFT_REG[0] <= 32'h0;
		local_size_NO_SHIFT_REG[1] <= 32'h0;
		local_size_NO_SHIFT_REG[2] <= 32'h0;
		global_offset_NO_SHIFT_REG[0] <= 32'h0;
		global_offset_NO_SHIFT_REG[1] <= 32'h0;
		global_offset_NO_SHIFT_REG[2] <= 32'h0;
	end
	else
	begin
		if (avs_cra_write)
		begin
			case (avs_cra_address)
				4'h0:
				begin
					status_NO_SHIFT_REG[31:16] <= 16'h3;
					status_NO_SHIFT_REG[15:0] <= ((status_NO_SHIFT_REG[15:0] & ~(bitenable[15:0])) | (avs_cra_writedata[15:0] & bitenable[15:0]));
				end

				4'h1:
				begin
					profile_ctrl_NO_SHIFT_REG <= ((profile_ctrl_NO_SHIFT_REG & ~(bitenable[63:32])) | (avs_cra_writedata[63:32] & bitenable[63:32]));
				end

				4'h3:
				begin
					profile_start_cycle_NO_SHIFT_REG[31:0] <= ((profile_start_cycle_NO_SHIFT_REG[31:0] & ~(bitenable[31:0])) | (avs_cra_writedata[31:0] & bitenable[31:0]));
					profile_start_cycle_NO_SHIFT_REG[63:32] <= ((profile_start_cycle_NO_SHIFT_REG[63:32] & ~(bitenable[63:32])) | (avs_cra_writedata[63:32] & bitenable[63:32]));
				end

				4'h4:
				begin
					profile_stop_cycle_NO_SHIFT_REG[31:0] <= ((profile_stop_cycle_NO_SHIFT_REG[31:0] & ~(bitenable[31:0])) | (avs_cra_writedata[31:0] & bitenable[31:0]));
					profile_stop_cycle_NO_SHIFT_REG[63:32] <= ((profile_stop_cycle_NO_SHIFT_REG[63:32] & ~(bitenable[63:32])) | (avs_cra_writedata[63:32] & bitenable[63:32]));
				end

				4'h5:
				begin
					work_dim_NO_SHIFT_REG <= ((work_dim_NO_SHIFT_REG & ~(bitenable[31:0])) | (avs_cra_writedata[31:0] & bitenable[31:0]));
					workgroup_size_NO_SHIFT_REG <= ((workgroup_size_NO_SHIFT_REG & ~(bitenable[63:32])) | (avs_cra_writedata[63:32] & bitenable[63:32]));
				end

				4'h6:
				begin
					global_size_NO_SHIFT_REG[0] <= ((global_size_NO_SHIFT_REG[0] & ~(bitenable[31:0])) | (avs_cra_writedata[31:0] & bitenable[31:0]));
					global_size_NO_SHIFT_REG[1] <= ((global_size_NO_SHIFT_REG[1] & ~(bitenable[63:32])) | (avs_cra_writedata[63:32] & bitenable[63:32]));
				end

				4'h7:
				begin
					global_size_NO_SHIFT_REG[2] <= ((global_size_NO_SHIFT_REG[2] & ~(bitenable[31:0])) | (avs_cra_writedata[31:0] & bitenable[31:0]));
					num_groups_NO_SHIFT_REG[0] <= ((num_groups_NO_SHIFT_REG[0] & ~(bitenable[63:32])) | (avs_cra_writedata[63:32] & bitenable[63:32]));
				end

				4'h8:
				begin
					num_groups_NO_SHIFT_REG[1] <= ((num_groups_NO_SHIFT_REG[1] & ~(bitenable[31:0])) | (avs_cra_writedata[31:0] & bitenable[31:0]));
					num_groups_NO_SHIFT_REG[2] <= ((num_groups_NO_SHIFT_REG[2] & ~(bitenable[63:32])) | (avs_cra_writedata[63:32] & bitenable[63:32]));
				end

				4'h9:
				begin
					local_size_NO_SHIFT_REG[0] <= ((local_size_NO_SHIFT_REG[0] & ~(bitenable[31:0])) | (avs_cra_writedata[31:0] & bitenable[31:0]));
					local_size_NO_SHIFT_REG[1] <= ((local_size_NO_SHIFT_REG[1] & ~(bitenable[63:32])) | (avs_cra_writedata[63:32] & bitenable[63:32]));
				end

				4'hA:
				begin
					local_size_NO_SHIFT_REG[2] <= ((local_size_NO_SHIFT_REG[2] & ~(bitenable[31:0])) | (avs_cra_writedata[31:0] & bitenable[31:0]));
					global_offset_NO_SHIFT_REG[0] <= ((global_offset_NO_SHIFT_REG[0] & ~(bitenable[63:32])) | (avs_cra_writedata[63:32] & bitenable[63:32]));
				end

				4'hB:
				begin
					global_offset_NO_SHIFT_REG[1] <= ((global_offset_NO_SHIFT_REG[1] & ~(bitenable[31:0])) | (avs_cra_writedata[31:0] & bitenable[31:0]));
					global_offset_NO_SHIFT_REG[2] <= ((global_offset_NO_SHIFT_REG[2] & ~(bitenable[63:32])) | (avs_cra_writedata[63:32] & bitenable[63:32]));
				end

				4'hC:
				begin
					kernel_arguments_NO_SHIFT_REG[31:0] <= ((kernel_arguments_NO_SHIFT_REG[31:0] & ~(bitenable[31:0])) | (avs_cra_writedata[31:0] & bitenable[31:0]));
					kernel_arguments_NO_SHIFT_REG[63:32] <= ((kernel_arguments_NO_SHIFT_REG[63:32] & ~(bitenable[63:32])) | (avs_cra_writedata[63:32] & bitenable[63:32]));
				end

				4'hD:
				begin
					kernel_arguments_NO_SHIFT_REG[95:64] <= ((kernel_arguments_NO_SHIFT_REG[95:64] & ~(bitenable[31:0])) | (avs_cra_writedata[31:0] & bitenable[31:0]));
					kernel_arguments_NO_SHIFT_REG[127:96] <= ((kernel_arguments_NO_SHIFT_REG[127:96] & ~(bitenable[63:32])) | (avs_cra_writedata[63:32] & bitenable[63:32]));
				end

				4'hE:
				begin
					kernel_arguments_NO_SHIFT_REG[159:128] <= ((kernel_arguments_NO_SHIFT_REG[159:128] & ~(bitenable[31:0])) | (avs_cra_writedata[31:0] & bitenable[31:0]));
				end

				default:
				begin
				end

			endcase
		end
		else
		begin
			if (status_NO_SHIFT_REG[0])
			begin
				start_NO_SHIFT_REG <= 1'b1;
			end
			if (start_NO_SHIFT_REG)
			begin
				status_NO_SHIFT_REG[0] <= 1'b0;
				started_NO_SHIFT_REG <= 1'b1;
			end
			if (started_NO_SHIFT_REG)
			begin
				start_NO_SHIFT_REG <= 1'b0;
			end
			if (finish)
			begin
				status_NO_SHIFT_REG[1] <= 1'b1;
				started_NO_SHIFT_REG <= 1'b0;
			end
		end
		status_NO_SHIFT_REG[11] <= 1'b0;
		status_NO_SHIFT_REG[12] <= (|has_a_lsu_active);
		status_NO_SHIFT_REG[13] <= (|has_a_write_pending);
		status_NO_SHIFT_REG[14] <= (|valid_in);
		status_NO_SHIFT_REG[15] <= started_NO_SHIFT_REG;
	end
end

always @(posedge clock or negedge resetn)
begin
	if (~(resetn))
	begin
		cra_read_st1_NO_SHIFT_REG <= 1'b0;
		cra_addr_st1_NO_SHIFT_REG <= 4'h0;
		cra_readdata_st1_NO_SHIFT_REG <= 64'h0;
	end
	else
	begin
		cra_read_st1_NO_SHIFT_REG <= avs_cra_read;
		cra_addr_st1_NO_SHIFT_REG <= avs_cra_address;
		case (avs_cra_address)
			4'h0:
			begin
				cra_readdata_st1_NO_SHIFT_REG[31:0] <= status_NO_SHIFT_REG;
				cra_readdata_st1_NO_SHIFT_REG[63:32] <= 32'h0;
			end

			4'h1:
			begin
				cra_readdata_st1_NO_SHIFT_REG[31:0] <= 'x;
				cra_readdata_st1_NO_SHIFT_REG[63:32] <= 32'h0;
			end

			4'h2:
			begin
				cra_readdata_st1_NO_SHIFT_REG[63:0] <= 64'h0;
			end

			4'h3:
			begin
				cra_readdata_st1_NO_SHIFT_REG[63:0] <= 64'h0;
			end

			4'h4:
			begin
				cra_readdata_st1_NO_SHIFT_REG[63:0] <= 64'h0;
			end

			default:
			begin
				cra_readdata_st1_NO_SHIFT_REG <= status_NO_SHIFT_REG;
			end

		endcase
	end
end

always @(posedge clock or negedge resetn)
begin
	if (~(resetn))
	begin
		avs_cra_readdatavalid <= 1'b0;
		avs_cra_readdata <= 64'h0;
	end
	else
	begin
		avs_cra_readdatavalid <= cra_read_st1_NO_SHIFT_REG;
		case (cra_addr_st1_NO_SHIFT_REG)
			4'h2:
			begin
				avs_cra_readdata[63:0] <= profile_data_NO_SHIFT_REG;
			end

			default:
			begin
				avs_cra_readdata <= cra_readdata_st1_NO_SHIFT_REG;
			end

		endcase
	end
end


// Handshaking signals used to control data through the pipeline

// Determine when the kernel is finished.
acl_kernel_finish_detector kernel_finish_detector (
	.clock(clock),
	.resetn(resetn),
	.start(start_NO_SHIFT_REG),
	.wg_size(workgroup_size_NO_SHIFT_REG),
	.wg_dispatch_valid_out(iter_valid_in),
	.wg_dispatch_stall_in(iter_stall_out),
	.dispatched_all_groups(dispatched_all_groups),
	.kernel_copy_valid_out(valid_out),
	.kernel_copy_stall_in(stall_in),
	.pending_writes(has_a_write_pending),
	.finish(finish)
);

defparam kernel_finish_detector.TESSELLATION_SIZE = 0;
defparam kernel_finish_detector.NUM_COPIES = 1;
defparam kernel_finish_detector.WG_SIZE_W = 32;

assign stall_in = 1'b0;

// Creating ID iterator and kernel instance for every requested kernel copy

// ID iterator is responsible for iterating over all local ids for given work-groups
acl_id_iterator id_iter_inst0 (
	.clock(clock),
	.resetn(resetn),
	.start(start_out),
	.valid_in(iter_valid_in),
	.stall_out(iter_stall_out),
	.stall_in(stall_out),
	.valid_out(valid_in),
	.group_id_in(group_id_tmp),
	.global_id_base_in(global_id_base_out),
	.local_size(local_size_NO_SHIFT_REG),
	.global_size(global_size_NO_SHIFT_REG),
	.local_id(local_id[0]),
	.global_id(global_id[0]),
	.group_id(group_id[0])
);

defparam id_iter_inst0.LOCAL_WIDTH_X = 32;
defparam id_iter_inst0.LOCAL_WIDTH_Y = 32;
defparam id_iter_inst0.LOCAL_WIDTH_Z = 32;


// This section instantiates a kernel function block
sumOfElements_function sumOfElements_function_inst0 (
	.clock(clock),
	.resetn(resetn),
	.input_global_id_0(global_id[0][0]),
	.input_acl_hw_wg_id(),
	.stall_out(stall_out),
	.valid_in(valid_in),
	.output_0(),
	.valid_out(valid_out),
	.stall_in(stall_in),
	.workgroup_size(workgroup_size_NO_SHIFT_REG),
	.avm_local_bb0_ld_arrayidx3_promoted_enable(avm_local_bb0_ld_arrayidx3_promoted_inst0_enable),
	.avm_local_bb0_ld_arrayidx3_promoted_readdata(avm_local_bb0_ld_arrayidx3_promoted_inst0_readdata),
	.avm_local_bb0_ld_arrayidx3_promoted_readdatavalid(avm_local_bb0_ld_arrayidx3_promoted_inst0_readdatavalid),
	.avm_local_bb0_ld_arrayidx3_promoted_waitrequest(avm_local_bb0_ld_arrayidx3_promoted_inst0_waitrequest),
	.avm_local_bb0_ld_arrayidx3_promoted_address(avm_local_bb0_ld_arrayidx3_promoted_inst0_address),
	.avm_local_bb0_ld_arrayidx3_promoted_read(avm_local_bb0_ld_arrayidx3_promoted_inst0_read),
	.avm_local_bb0_ld_arrayidx3_promoted_write(avm_local_bb0_ld_arrayidx3_promoted_inst0_write),
	.avm_local_bb0_ld_arrayidx3_promoted_writeack(avm_local_bb0_ld_arrayidx3_promoted_inst0_writeack),
	.avm_local_bb0_ld_arrayidx3_promoted_writedata(avm_local_bb0_ld_arrayidx3_promoted_inst0_writedata),
	.avm_local_bb0_ld_arrayidx3_promoted_byteenable(avm_local_bb0_ld_arrayidx3_promoted_inst0_byteenable),
	.avm_local_bb0_ld_arrayidx3_promoted_burstcount(avm_local_bb0_ld_arrayidx3_promoted_inst0_burstcount),
	.avm_local_bb1_ld__enable(avm_local_bb1_ld__inst0_enable),
	.avm_local_bb1_ld__readdata(avm_local_bb1_ld__inst0_readdata),
	.avm_local_bb1_ld__readdatavalid(avm_local_bb1_ld__inst0_readdatavalid),
	.avm_local_bb1_ld__waitrequest(avm_local_bb1_ld__inst0_waitrequest),
	.avm_local_bb1_ld__address(avm_local_bb1_ld__inst0_address),
	.avm_local_bb1_ld__read(avm_local_bb1_ld__inst0_read),
	.avm_local_bb1_ld__write(avm_local_bb1_ld__inst0_write),
	.avm_local_bb1_ld__writeack(avm_local_bb1_ld__inst0_writeack),
	.avm_local_bb1_ld__writedata(avm_local_bb1_ld__inst0_writedata),
	.avm_local_bb1_ld__byteenable(avm_local_bb1_ld__inst0_byteenable),
	.avm_local_bb1_ld__burstcount(avm_local_bb1_ld__inst0_burstcount),
	.avm_local_bb2_st_add_enable(avm_local_bb2_st_add_inst0_enable),
	.avm_local_bb2_st_add_readdata(avm_local_bb2_st_add_inst0_readdata),
	.avm_local_bb2_st_add_readdatavalid(avm_local_bb2_st_add_inst0_readdatavalid),
	.avm_local_bb2_st_add_waitrequest(avm_local_bb2_st_add_inst0_waitrequest),
	.avm_local_bb2_st_add_address(avm_local_bb2_st_add_inst0_address),
	.avm_local_bb2_st_add_read(avm_local_bb2_st_add_inst0_read),
	.avm_local_bb2_st_add_write(avm_local_bb2_st_add_inst0_write),
	.avm_local_bb2_st_add_writeack(avm_local_bb2_st_add_inst0_writeack),
	.avm_local_bb2_st_add_writedata(avm_local_bb2_st_add_inst0_writedata),
	.avm_local_bb2_st_add_byteenable(avm_local_bb2_st_add_inst0_byteenable),
	.avm_local_bb2_st_add_burstcount(avm_local_bb2_st_add_inst0_burstcount),
	.clock2x(clock2x),
	.start(start_out),
	.input_sum(kernel_arguments_NO_SHIFT_REG[127:64]),
	.input_global_size_0(global_size_NO_SHIFT_REG[0]),
	.input_A(kernel_arguments_NO_SHIFT_REG[63:0]),
	.input_N(kernel_arguments_NO_SHIFT_REG[159:128]),
	.has_a_write_pending(has_a_write_pending),
	.has_a_lsu_active(has_a_lsu_active)
);



endmodule

//////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////

// altera message_off 10036
// altera message_off 10230
// altera message_off 10858
module sumOfElements_sys_cycle_time
	(
		input 		clock,
		input 		resetn,
		output [31:0] 		cur_cycle
	);


 reg [31:0] cur_count_NO_SHIFT_REG;

assign cur_cycle = cur_count_NO_SHIFT_REG;

always @(posedge clock or negedge resetn)
begin
	if (~(resetn))
	begin
		cur_count_NO_SHIFT_REG <= 32'h0;
	end
	else
	begin
		cur_count_NO_SHIFT_REG <= (cur_count_NO_SHIFT_REG + 32'h1);
	end
end

endmodule

