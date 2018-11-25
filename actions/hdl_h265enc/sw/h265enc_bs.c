#include "h265enc_bs.h"

static uint32_t endianFix( uint32_t x ){
	return (x<<24) + ((x<<8)&0xff0000) + ((x>>8)&0xff00) + (x>>24);
}

static void encodeAdd03(bs_t *s, uint8_t byte[4], uint32_t byteCnt){

	uint32_t i = 0;
	uint32_t zeroCnt = !*(s->pCur-1) ;
		   zeroCnt = zeroCnt ? !*(s->pCur-2) + 1:0;   

	for(i=0; i<byteCnt; i++){
		if( 2 == zeroCnt && byte[i] <= 0x03){
			*(s->pCur++) = 0x03;
			zeroCnt =0;
			s->byteCnt++;
		}
	   
		if( 0 == byte[i]){
			zeroCnt++;
		}
		else{
			zeroCnt = 0;
		}
		*s->pCur = byte[i];
		printf("%x\n", *s->pCur);
		s->pCur++;
		s->byteCnt++;
	}
}

static void bsFlush( bs_t *s ){

	uint32_t byteCnt = WORD_SIZE - s->bitsLeft / 8;
	uint8_t byteA[4] = {0};
	void* byte = byteA;


	*(uint32_t*)byte = endianFix( s->bitsCur << s->bitsLeft );
	encodeAdd03(s, byteA, byteCnt);
	s->bitsLeft = WORD_SIZE*8;
}

static void bsWrite( bs_t *s, uint32_t i_count, uint32_t i_bits ){

	uint32_t i_bits_cache = 0;
	uint32_t byteCnt = 4;
	uint8_t byteA[4] = {0};
	void* byte = byteA;

	if( i_count < s->bitsLeft ){
		s->bitsCur = (s->bitsCur << i_count) | i_bits;
		s->bitsLeft -= i_count;
	}
	else{
		i_bits_cache = 0;        //added for CABAC coding
		if(i_count == s->bitsLeft)
			i_bits_cache = 0;
		else
			i_bits_cache = ( i_bits << (32-(i_count-s->bitsLeft)) ) >> (32-(i_count-s->bitsLeft));
		i_count -= s->bitsLeft;
		s->bitsCur= (s->bitsCur << s->bitsLeft) | (i_bits >> i_count);
		*(uint32_t* )byte = endianFix( s->bitsCur );
		encodeAdd03(s, byteA, byteCnt);

		if( TRUE )
			s->bitsCur = i_bits_cache;
		else 
			s->bitsCur = i_bits;
		s->bitsLeft = 32 - i_count;
	}
}

static void bsWrite1Bit( bs_t *s, uint32_t i_bit ){

	uint32_t byteCnt = 4;
	uint8_t byteA[4] = {0};
	void* byte = byteA;

	s->bitsCur <<= 1;
	s->bitsCur |= i_bit;
	s->bitsLeft--;
	if( s->bitsLeft == WORD_SIZE*8-32 ){
		*(uint32_t* )byte = endianFix( s->bitsCur );
		encodeAdd03(s, byteA, byteCnt);
		s->bitsLeft = WORD_SIZE*8;
	}
}

/*static void bsWrite32Bit( bs_t *s, uint32_t i_bits ){

	bsWrite( s, 16, i_bits >> 16 );
	bsWrite( s, 16, i_bits );

}*/

static void bsAlign1( bs_t *s ){
	if( s->bitsLeft&7 ){
		s->bitsCur <<= s->bitsLeft&7;
		s->bitsCur |= (1 << (s->bitsLeft&7)) - 1;
		s->bitsLeft &= ~7;
	}
	bsFlush( s );
}

static void bsAlign0( bs_t *s ){
	if( s->bitsLeft&7 ){
		s->bitsCur <<= s->bitsLeft&7;
		s->bitsLeft &= ~7;
	}
	bsFlush( s );
}

static void bsUvlc( bs_t *s, uint32_t val ){

	uint32_t length = 1;
	uint32_t temp = ++val;

	while( 1 != temp ){
	  temp >>= 1;
	  length += 2;
	}

	bsWrite( s, length >> 1, 0);
	bsWrite( s, (length+1) >> 1, val);
}

static void bsSvlc( bs_t *s, int val ){

	uint32_t u_val;
	u_val = (val<=0) ? (-val<<1) : ((val<<1)-1);
	bsUvlc(s, u_val);
}

static void vpsInit(vps_t *vps, param_t param){
	vps->video_parameter_set_id                     = 0;
	vps->vps_temporal_id_nesting_flag               = TRUE;
	vps->vps_reserved_three_2bits                   = 3;
	vps->vps_reserved_zero_2bits                    = 0;
	vps->vps_reserved_zero_6bits                    = 0;
	vps->vps_max_sub_layers_minus1                  = 0;
	vps->vps_reserved_ffff_16bits                   = 0xffff;
	vps->vps_reserved_zero_12bits                   = 0;
	vps->vps_sub_layer_ordering_info_present_flag   = TRUE;
	if(param.gop_length==1)
		vps->vps_max_dec_pic_buffering[0]           = 0;
	else                                           
		vps->vps_max_dec_pic_buffering[0]           = 1;
	vps->vps_num_reorder_pics[0]                    = 0;
	vps->vps_max_latency_increase[0]                = 0;
	vps->vps_num_hrd_parameters                     = 0;
	vps->vps_max_nuh_reserved_zero_layer_id         = 0;
	vps->op_layer_id_included_flag[0][0]            = 0;
	vps->vps_num_hrd_parameters                     = 0;
	vps->vps_extension_flag                         = 0;

	//ptl,profile tier
	vps->ptl.general_level_idc                      = 0;
	vps->ptl.sub_layer_profile_present_flag         = 0;
	vps->ptl.sub_layer_level_present_flag           = 0;
	vps->ptl.sub_layer_level_idc                    = 0;
	vps->ptl.profile_space                          = 0;
	vps->ptl.tier_flag                              = FALSE;
	vps->ptl.profile_idc                            = 0;
	vps->ptl.profile_compatibility_flag             = TRUE;
	vps->ptl.reserved_zero_16bits                   = 0;
	vps->ptl.general_progressive_source_flag        = 0;
	vps->ptl.general_interlaced_source_flag         = 0;
	vps->ptl.general_non_packed_constraint_flag     = 0;
	vps->ptl.general_frame_only_constraint_flag     = 0;

	//bit rate info
	vps->bit_rate_info_present_flag[0]              = FALSE;
	vps->pic_rate_info_present_flag[0]              = FALSE;
	vps->avg_bit_rate[0]                            = 0;
	vps->max_bit_rate[0]                            = 0;
	vps->constant_pic_rate_idc[0]                   = 0;
	vps->avg_pic_rate[0]                            = 0;
	vps->vps_max_op_sets_minus1                     = 0;
	vps->vps_timing_info_present_flag               = 0;
	vps->vps_num_units_in_tick                      = 1001;
	vps->vps_time_scale                             = 60000;
	vps->vps_poc_proportional_to_timing_flag        = 0;
	vps->vps_num_ticks_poc_diff_one_minus1          = 0;
}

static void spsInit(sps_t *sps, param_t param){

	sps->video_parameter_set_id                         = 0;
	sps->sps_max_sub_layers_minus1                      = 0;
	sps->sps_temporal_id_nesting_flag                   = TRUE;
	
	//ptl,profile tier
	sps->ptl.general_level_idc                          = 0;
	sps->ptl.sub_layer_profile_present_flag             = 0;
	sps->ptl.sub_layer_level_present_flag               = 0;
	sps->ptl.sub_layer_level_idc                        = 0;
	sps->ptl.profile_space                              = 0;
	sps->ptl.tier_flag                                  = FALSE;
	sps->ptl.profile_idc                                = 0;
	sps->ptl.profile_compatibility_flag                 = TRUE;
	sps->ptl.reserved_zero_44bits                       = 0;
	sps->ptl.general_progressive_source_flag            = 0;
	sps->ptl.general_interlaced_source_flag             = 0;
	sps->ptl.general_non_packed_constraint_flag         = 0;
	sps->ptl.general_frame_only_constraint_flag         = 0;

	sps->sps_reserved_zero_bit                          = 0;
	sps->seq_parameter_set_id                           = 0;
	sps->chroma_format_idc                              = 1;
	sps->separate_colour_plane_flag                     = 0;
	sps->pic_width_in_luma_samples                      = param.mb_x_total*f_LCU_SIZE;
	sps->pic_height_in_luma_samples                     = param.mb_y_total*f_LCU_SIZE;

	sps->pic_cropping_flag                              = TRUE;
	sps->crop.pic_crop_left_offset                      = 0;
	sps->crop.pic_crop_right_offset                     = 0;
	sps->crop.pic_crop_top_offset                       = 0;
	sps->crop.pic_crop_bottom_offset                    = 0;

	sps->bit_depth_luma_minus8                          = 0;
	sps->bit_depth_chroma_minus8                        = 0;
	sps->pcm_enabled_flag                               = 0;
	sps->pcm_bit_depth_luma_minus1                      = 0;
	sps->pcm_bit_depth_chroma_minus1                    = 0;
	sps->log2_max_pic_order_cnt_lsb_minus4              = 4;
	sps->sps_sub_layer_ordering_info_present_flag       = 1;
	if(param.gop_length==1)                             
		sps->max_dec_pic_buffering[0]                   = 0;
	else                                                
		sps->max_dec_pic_buffering[0]                   = 1;
	sps->num_reorder_pics[0]                            = 0;
	sps->max_latency_increase[0]                        = 0;
	sps->restricted_ref_pic_lists_flag                  = 0;
	sps->lists_modification_present_flag                = 0;
	sps->log2_min_coding_block_size_minus3              = 0;
	sps->log2_diff_max_min_coding_block_size            = 3;
	sps->log2_min_transform_block_size_minus2           = 0;
	sps->log2_diff_max_min_transform_block_size         = 3;
	sps->log2_min_pcm_coding_block_size_minus3          = 0;
	sps->log2_diff_max_min_pcm_coding_block_size        = 0;
	sps->max_transform_hierarchy_depth_inter            = 2;
	sps->max_transform_hierarchy_depth_intra            = 2;
	sps->scaling_list_enabled_flag                      = FALSE;
	sps->sps_scaling_list_data_present_flag             = 0;
	sps->asymmetric_motion_partitions_enabled_flag      = TRUE;
#ifdef  SAO_OPEN
	sps->sample_adaptive_offset_enabled_flag            = TRUE;
#else
	sps->sample_adaptive_offset_enabled_flag            = FALSE;
#endif
	sps->pcm_enabled_flag                               = FALSE;
	sps->pcm_loop_filter_disable_flag                   = 0;
	sps->pcm_sample_bit_depth_luma_minus1               = 7;
	sps->pcm_sample_bit_depth_chroma_minus1             = 7;
	sps->log2_min_pcm_luma_coding_block_size_minus3     = 0;
	sps->log2_diff_max_min_pcm_luma_coding_block_size   = 2;
	sps->pcm_loop_filter_disable_flag                   = 0;
	sps->temporal_id_nesting_flag                       = 0;
	sps->num_short_term_ref_pic_sets                    = 1;
	sps->inter_ref_pic_set_prediction_flag              = FALSE;
	if(param.gop_length==1)                             
		sps->num_negative_pics = 0;                     
	else                                                
		sps->num_negative_pics                          = 1;
	sps->num_positive_pics                              = 0;
	sps->delta_poc_s0_minus1                            = -1;
	sps->used_by_curr_pic_s0_flag                       = 1;
	sps->delta_poc_s1_minus1                            = -1;
	sps->used_by_curr_pic_s1_flag                       = 1;

	sps->long_term_ref_pics_present_flag                = FALSE;
	sps->num_long_term_ref_pic_sps                      = 0;
	sps->lt_ref_pic_poc_lsb_sps                         = 0;
	sps->used_by_curr_pic_lt_sps_flag                   = 0;
	sps->sps_temporal_mvp_enable_flag                   = TRUE;
	sps->sps_strong_intra_smoothing_enable_flag         = FALSE;
	sps->vui_parameters_present_flag                    = FALSE;
	sps->sps_extension_flag                             = 0;

	//vui
	sps->vui.aspect_ratio_info_present_flag             = 0;
	sps->vui.aspect_ratio_idc                           = 0;
	sps->vui.sar_width                                  = 0;
	sps->vui.sar_height                                 = 0;
	sps->vui.overscan_info_present_flag                 = 0;
	sps->vui.overscan_appropriate_flag                  = 0;
	sps->vui.video_signal_type_present_flag             = 0;
	sps->vui.video_format                               = 0;
	sps->vui.video_full_range_flag                      = 0;
	sps->vui.colour_description_present_flag            = 0;
	sps->vui.colour_primaries                           = 0;
	sps->vui.transfer_characteristics                   = 0;
	sps->vui.matrix_coefficients                        = 0;
	sps->vui.chroma_loc_info_present_flag               = 0;
	sps->vui.chroma_sample_loc_type_top_field           = 0;
	sps->vui.chroma_sample_loc_type_bottom_field        = 0;
	sps->vui.neutral_chroma_indication_flag             = 0;
	sps->vui.field_seq_flag                             = 0;
	sps->vui.default_display_window_flag                = 0;
	sps->vui.pic_struct_present_flag                    = 0;
	sps->vui.hrd_parameters_present_flag                = 0;
	sps->vui.timing_info_present_flag                   = 0;
	sps->vui.num_units_in_tick                          = 0;
	sps->vui.time_scale                                 = 0;
	sps->vui.nal_hrd_parameters_present_flag            = 0;
	sps->vui.vcl_hrd_parameters_present_flag            = 0;
	sps->vui.sub_pic_cpb_params_present_flag            = 0;
	sps->vui.tick_divisor_minus2                        = 0;
	sps->vui.du_cpb_removal_delay_length_minus1         = 0;
	sps->vui.bit_rate_scale                             = 0;
	sps->vui.cpb_size_scale                             = 0;
	sps->vui.du_cpb_size_scale                          = 0;
	sps->vui.initial_cpb_removal_delay_length_minus1    = 0;
	sps->vui.cpb_removal_delay_length_minus1            = 0;
	sps->vui.dpb_output_delay_length_minus1             = 0;
	sps->vui.fixed_pic_rate_flag                        = 0;
	sps->vui.pic_duration_in_tc_minus1                  = 0;
	sps->vui.low_delay_hrd_flag                         = 0;
	sps->vui.cpb_cnt_minus1                             = 0;
	sps->vui.bit_size_value_minus1                      = 0;
	sps->vui.cpb_size_value_minus1                      = 0;
	sps->vui.du_cpb_size_value_minus1                   = 0;
	sps->vui.cbr_flag                                   = 0;
	sps->vui.poc_proportional_to_timing_flag            = 0;
	sps->vui.num_ticks_poc_diff_one_minus1              = 0;
	sps->vui.bitstream_restriction_flag                 = 0;
	sps->vui.tiles_fixed_structure_flag                 = 0;
	sps->vui.motion_vectors_over_pic_boundaries_flag    = 0;
	sps->vui.restricted_ref_pic_lists_flag              = 0;
	sps->vui.min_spatial_segmentation_idc               = 0;
	sps->vui.max_bytes_per_pic_denom                    = 0;
	sps->vui.max_bits_per_mincu_denom                   = 0;
	sps->vui.log2_max_mv_length_horizontal              = 0;
	sps->vui.log2_max_mv_length_vertical                = 0;

}

static void ppsInit(pps_t *pps, param_t param){

	pps->pic_parameter_set_id                           = 0;
	pps->seq_parameter_set_id                           = 0;
	pps->dependent_slice_enabled_flag                   = FALSE;
	pps->sign_data_hiding_flag                          = 0;
	pps->cabac_init_present_flag                        = TRUE;
	if(param.gop_length==1){
		pps->num_ref_idx_l0_default_active_minus1       = 3;
		pps->num_ref_idx_l1_default_active_minus1       = 3;
	}
	else{
		pps->num_ref_idx_l0_default_active_minus1       = 0;
		pps->num_ref_idx_l1_default_active_minus1       = 0;
	}
	pps->pic_init_qp_minus26                            = 0;
	pps->constrained_intra_pred_flag                    = FALSE;
	pps->transform_skip_enabled_flag                    = TRUE;
	pps->cu_qp_delta_enabled_flag                       = TRUE;
	pps->diff_cu_qp_delta_depth                         = 0;
	pps->cb_qp_offset                                   = 0;
	pps->cr_qp_offset                                   = 0;
#ifdef SAO_OPEN
	if( param.qp<23)
		pps->slicelevel_chroma_qp_flag = TRUE;
	else if(param.qp>22 && param.qp<30) //25-27:true/false  
		pps->slicelevel_chroma_qp_flag = FALSE;
	else if(param.qp>29)//30-33:true else true/false 
		pps->slicelevel_chroma_qp_flag = TRUE;
	else 
		pps->slicelevel_chroma_qp_flag = FALSE;
#else 
	if(param.qp>=0 && param.qp<=10)
		pps->slicelevel_chroma_qp_flag = FALSE;
	else if(param.qp>=11 && param.qp<=18)
		pps->slicelevel_chroma_qp_flag = TRUE;
	else if(param.qp>=19 && param.qp<=25)
		pps->slicelevel_chroma_qp_flag = FALSE;
	else if(param.qp==26)
		pps->slicelevel_chroma_qp_flag = TRUE;
	else if(param.qp>=27 && param.qp<=33)
		pps->slicelevel_chroma_qp_flag = FALSE;
	else if(param.qp>=34 && param.qp<=41)
		pps->slicelevel_chroma_qp_flag = TRUE;
	else if(param.qp>=42 && param.qp<=51)
		pps->slicelevel_chroma_qp_flag = FALSE;
	else 
		pps->slicelevel_chroma_qp_flag = FALSE;
#endif 

	pps->weighted_pred_flag                             = FALSE;
	pps->weighted_bipred_flag                           = FALSE;
	pps->output_flag_present_flag                       = FALSE;
	pps->transquant_bypass_enable_flag                  = FALSE;
	pps->tiles_enabled_flag                             = FALSE;
	pps->entropy_coding_sync_enabled_flag               = FALSE;
	pps->entropy_slice_enabled_flag                     = 0;
	pps->num_tile_columns_minus1                        = 0;
	pps->num_tile_rows_minus1                           = 0;
	pps->uniform_spacing_flag                           = 0;
	pps->column_width_minus1                            = 0;
	pps->row_height_minus1                              = 0;
	pps->loop_filter_across_tiles_enabled_flag          = 0;
	pps->loop_filter_across_slices_enabled_flag         = FALSE;
	pps->deblocking_filter_control_present_flag         = TRUE;
	pps->deblocking_filter_override_enabled_flag        = 0;
#ifdef  DB_OPEN
	pps->pic_disable_deblocking_filter_flag             = 0;
#else 
	pps->pic_disable_deblocking_filter_flag             = 1;
#endif 
	pps->pps_beta_offset_div2                           = 0;
	pps->pps_tc_offset_div2                             = 0;
	pps->pps_scaling_list_data_present_flag             = FALSE;
	pps->scaling_list_pred_mode_flag                    = 0;
	pps->scaling_list_pred_matrix_id_delta              = 0;
	pps->scaling_list_dc_coef_minus8                    = 0;
	pps->scaling_list_delta_coef                        = 0;
	pps->lists_modification_present_flag                = FALSE;
	pps->log2_parallel_merge_level_minus2               = 0;
	pps->num_extra_slice_header_bits                    = 0;
	pps->slice_header_extension_present_flag            = FALSE;
	pps->pps_extension_flag                             = 0;

}

static void sliceHeaderInit(sliceHeader_t* sh, param_t param){

	sh->first_slice_in_pic_flag                          = 1;
	sh->no_output_of_prior_pics_flag                     = 0;
	sh->pic_parameter_set_id                             = 0;
	sh->dependent_slice_flag                             = 0;
	sh->slice_address                                    = 0;
	sh->dependent_slice_flag                             = 0;
	sh->slice_reserved_undetermined_flag[0]              = 0;
	sh->slice_type                                       = param.type;
	sh->pic_output_flag                                  = 1;
	sh->pic_order_cnt_lsb                                = 0;
	sh->short_term_ref_pic_set_sps_flag                  = 0;
	sh->short_term_ref_pic_set_sps_flag                  = 0;
	sh->short_term_ref_pic_set_idx                       = 0;
	sh->num_long_term_sps                                = 0;
	sh->num_long_term_pics                               = 0;
	sh->lt_idx_sps[0]                                    = 0;
	sh->poc_lsb_lt                                       = 0;
	sh->used_by_curr_pic_lt_flag                         = 0;
	sh->delta_poc_msb_present_flag                       = 0;
	sh->delta_poc_msb_cycle_lt[0]                        = 0;
	sh->slice_sao_luma_flag                              = TRUE;
	sh->slice_sao_chroma_flag                            = TRUE;
	sh->enable_temporal_mvp_flag                         = 0;
	sh->num_ref_idx_active_override_flag                 = 0;
	sh->num_ref_idx_l0_active_minus1                     = 0;
	sh->num_ref_idx_l1_active_minus1                     = 0;
	sh->ref_pic_list_modification_flag_l0                = 0;
	sh->list_entry_l0                                    = 0;
	sh->ref_pic_list_modification_flag_l1                = 0;
	sh->list_entry_l1                                    = 0;
	sh->mvd_l1_zero_flag                                 = 0;
	sh->cabac_init_flag                                  = 0;
	sh->collocated_from_l0_flag                          = 1;
	sh->collocated_ref_idx                               = 0;
	sh->five_minus_max_num_merge_cand                    = 0;
	sh->slice_qp_delta                                   = 6;
	sh->slice_qp_delta_cb                                = 0;
	sh->slice_qp_delta_cr                                = 0;
	sh->deblocking_filter_override_flag                  = 0;
	sh->slice_disable_deblocking_filter_flag             = 1;
	sh->beta_offset_div2                                 = 0;
	sh->tc_offset_div2                                   = 0;
	sh->slice_loop_filter_across_slices_enabled_flag     = FALSE;
	sh->slice_header_extension_length                    = 0;
}

static void vpsEncode(vps_t* vps, bs_t *s){

	int i=0;
	int j=0;
	bsWrite ( s, 4, vps->video_parameter_set_id );
	bsWrite ( s, 2, vps->vps_reserved_three_2bits );
	bsWrite ( s, 6, vps->vps_reserved_zero_6bits );
	bsWrite ( s, 3, vps->vps_max_sub_layers_minus1 );
	bsWrite1Bit( s, vps->vps_temporal_id_nesting_flag );
	bsWrite ( s, 16, vps->vps_reserved_ffff_16bits );

	//code ptl
	bsWrite ( s, 2, vps->ptl.profile_space );
	bsWrite1Bit( s, vps->ptl.tier_flag );
	bsWrite ( s, 5, vps->ptl.profile_idc );
	bsWrite1Bit( s, vps->ptl.profile_compatibility_flag );
	for(i=0; i<31; i++)
		bsWrite1Bit( s, !(vps->ptl.profile_compatibility_flag) );
	bsWrite1Bit( s, vps->ptl.general_progressive_source_flag);
	bsWrite1Bit( s, vps->ptl.general_interlaced_source_flag );
	bsWrite1Bit( s, vps->ptl.general_non_packed_constraint_flag );
	bsWrite1Bit( s, vps->ptl.general_frame_only_constraint_flag );
	bsWrite( s, 44, vps->ptl.reserved_zero_16bits );    //XXX_reserved_zero_44bits
	bsWrite ( s, 8, vps->ptl.general_level_idc );
	for(i=0; i<vps->vps_max_sub_layers_minus1; i++){
		bsWrite1Bit( s, vps->ptl.sub_layer_profile_present_flag );
		bsWrite1Bit( s, vps->ptl.sub_layer_level_present_flag );
	}
	if(vps->vps_max_sub_layers_minus1>0){
		for(i=vps->vps_max_sub_layers_minus1; i<8; i++)
			bsWrite( s, 2, 0 );
	}
	for(i=0; vps->vps_max_sub_layers_minus1; i++){
		//codeProfileTier
	}

	//bit rate and pic rate info
	for(i=0; i<=vps->vps_max_sub_layers_minus1; i++){
		bsWrite1Bit( s, (uint32_t)(vps->bit_rate_info_present_flag[0]) );
		bsWrite1Bit( s, (uint32_t)(vps->pic_rate_info_present_flag[0]) );
		if(vps->bit_rate_info_present_flag[0]) {
			bsWrite( s, 16, (uint32_t)(vps->avg_bit_rate[0]) );
			bsWrite( s, 16, (uint32_t)(vps->max_bit_rate[0]) );
		}
		if(vps->pic_rate_info_present_flag[0]) {
			bsWrite( s, 2,  (uint32_t)(vps->constant_pic_rate_idc[0]) );
			bsWrite( s, 16, (uint32_t)(vps->avg_pic_rate[0]) );
		}
	}

	bsWrite1Bit( s, vps->vps_sub_layer_ordering_info_present_flag );
	for(i=0; i<=vps->vps_max_sub_layers_minus1; i++){
		bsUvlc( s, vps->vps_max_dec_pic_buffering[0] );
		bsUvlc( s, vps->vps_num_reorder_pics[0] );
		bsUvlc( s, vps->vps_max_latency_increase[0] );
	}
	//bsUvlc( s, vps->vps_num_hrd_parameters );
	bsWrite( s, 6, vps->vps_max_nuh_reserved_zero_layer_id );
	bsUvlc( s, vps->vps_max_op_sets_minus1 );         //0
	for(j=1; j<vps->vps_max_op_sets_minus1; j++){
		for(i=0; i<=vps->vps_max_nuh_reserved_zero_layer_id; i++ ){
			bsWrite1Bit( s, vps->op_layer_id_included_flag[j][i] );
		}
	}

	bsWrite1Bit( s, vps->vps_timing_info_present_flag );    //false
	if(vps->vps_timing_info_present_flag)
	{
		bsWrite( s, 32, vps->vps_num_units_in_tick );    //1001
		bsWrite( s, 32, vps->vps_time_scale );           //60000
		bsWrite1Bit( s, vps->vps_poc_proportional_to_timing_flag );   //false
		if(vps->vps_poc_proportional_to_timing_flag)
			bsUvlc( s, vps->vps_num_ticks_poc_diff_one_minus1 );   //0
		bsUvlc( s, vps->vps_num_hrd_parameters );
		for(i=0; i<vps->vps_num_hrd_parameters; i++){
			//codeHrdParameters
		}
	}

	bsWrite1Bit( s, vps->vps_extension_flag );

	//rbsp trailing bits
	bsWrite ( s, 1, 1 );
	bsAlign0( s );

}

static void spsEncode(sps_t* sps, bs_t *s){

	int i=0;
	int j=0;
	int nal_or_vcl=0;

	bsWrite ( s, 4, sps->video_parameter_set_id );
	bsWrite ( s, 3, sps->sps_max_sub_layers_minus1 );
	bsWrite1Bit( s, sps->sps_temporal_id_nesting_flag );

	//code ptl
	bsWrite ( s, 2, sps->ptl.profile_space);
	bsWrite1Bit( s, sps->ptl.tier_flag );
	bsWrite ( s, 5, sps->ptl.profile_idc );
	bsWrite1Bit( s, sps->ptl.profile_compatibility_flag );
	for(i=0; i<31; i++)
		bsWrite1Bit( s, !(sps->ptl.profile_compatibility_flag) );
	bsWrite1Bit( s, sps->ptl.general_progressive_source_flag    );   //0
	bsWrite1Bit( s, sps->ptl.general_interlaced_source_flag     );   //0
	bsWrite1Bit( s, sps->ptl.general_non_packed_constraint_flag );   //0
	bsWrite1Bit( s, sps->ptl.general_frame_only_constraint_flag );   //0

	bsWrite ( s, 44, sps->ptl.reserved_zero_44bits );
	bsWrite ( s, 8, sps->ptl.general_level_idc );
	for(i=0; i<sps->sps_max_sub_layers_minus1; i++){
		bsWrite1Bit( s, sps->ptl.sub_layer_profile_present_flag );
		bsWrite1Bit( s, sps->ptl.sub_layer_level_present_flag );
		if(sps->sps_max_sub_layers_minus1>0){
			for(j=sps->sps_max_sub_layers_minus1; j<8; j++)
				bsWrite( s, 2, 0 );
		}
		for(j=0; j<sps->sps_max_sub_layers_minus1; j++){
			//codeProfileTier
		}
	}

	bsUvlc( s, sps->seq_parameter_set_id );
	bsUvlc( s, sps->chroma_format_idc );
	if(sps->chroma_format_idc==3)
		bsWrite1Bit( s, sps->separate_colour_plane_flag );
	bsUvlc( s, sps->pic_width_in_luma_samples );
	bsUvlc( s, sps->pic_height_in_luma_samples );

	//crop
	bsWrite1Bit( s, sps->pic_cropping_flag );
	if(sps->pic_cropping_flag){
		bsUvlc( s, sps->crop.pic_crop_left_offset );
		bsUvlc( s, sps->crop.pic_crop_right_offset );
		bsUvlc( s, sps->crop.pic_crop_top_offset );
		bsUvlc( s, sps->crop.pic_crop_bottom_offset );
	}

	bsUvlc( s, sps->bit_depth_luma_minus8 );
	bsUvlc( s, sps->bit_depth_chroma_minus8 );
	bsUvlc( s, sps->log2_max_pic_order_cnt_lsb_minus4 );
	bsWrite1Bit( s, sps->sps_sub_layer_ordering_info_present_flag );
	for(i=0; i<=sps->sps_max_sub_layers_minus1; i++){
		bsUvlc( s, sps->max_dec_pic_buffering[0] );
		bsUvlc( s, sps->num_reorder_pics[0] );
		bsUvlc( s, sps->max_latency_increase[0] );
	}
	bsUvlc( s, sps->log2_min_coding_block_size_minus3 );
	bsUvlc( s, sps->log2_diff_max_min_coding_block_size );
	bsUvlc( s, sps->log2_min_transform_block_size_minus2 );
	bsUvlc( s, sps->log2_diff_max_min_transform_block_size );
	bsUvlc( s, sps->max_transform_hierarchy_depth_inter );
	bsUvlc( s, sps->max_transform_hierarchy_depth_intra );
	bsWrite1Bit( s, sps->scaling_list_enabled_flag );
	if(sps->scaling_list_enabled_flag){
		bsWrite1Bit( s, sps->sps_scaling_list_data_present_flag );
		if(sps->sps_scaling_list_data_present_flag){
			//coding scaling list
		}
	}
	bsWrite1Bit( s, sps->asymmetric_motion_partitions_enabled_flag );
	bsWrite1Bit( s, sps->sample_adaptive_offset_enabled_flag );
	bsWrite1Bit( s, sps->pcm_enabled_flag );
	if(sps->pcm_enabled_flag){
		bsWrite( s, 4, sps->pcm_bit_depth_luma_minus1 );
		bsWrite( s, 4, sps->pcm_bit_depth_chroma_minus1 );
		bsUvlc ( s, sps->log2_min_pcm_luma_coding_block_size_minus3 );
		bsUvlc ( s, sps->log2_diff_max_min_pcm_luma_coding_block_size );
		bsWrite1Bit( s, sps->pcm_loop_filter_disable_flag);
	}
	//short term ref pic set
	bsUvlc( s, sps->num_short_term_ref_pic_sets );
	for(i=0; i<sps->num_short_term_ref_pic_sets; i++){
		if(i>0)
			 bsWrite1Bit( s, sps->inter_ref_pic_set_prediction_flag );
		if(sps->inter_ref_pic_set_prediction_flag){
			j = 0;
			bsWrite( s, 1,  (j>=0 ? 0 : 1) );
			bsUvlc	( s, abs(j)-1 );
		}
		else{
			bsUvlc( s, sps->num_negative_pics );
			bsUvlc( s, sps->num_positive_pics );
			j = 0;
			for( i=0; i<sps->num_negative_pics; i++){
				bsUvlc( s, j-(sps->delta_poc_s0_minus1)-1 );
				j = sps->delta_poc_s0_minus1;
				bsWrite1Bit( s, sps->used_by_curr_pic_s0_flag );
			}
			j = 0;
			for(i=sps->num_negative_pics; i<(sps->num_negative_pics+sps->num_positive_pics); i++){
				bsUvlc( s, sps->delta_poc_s1_minus1-j-1 );
				j = sps->delta_poc_s1_minus1;
				bsWrite1Bit( s, sps->used_by_curr_pic_s1_flag );
			}
		}
	}
	
	bsWrite1Bit( s, sps->long_term_ref_pics_present_flag ? 1 :0 );
	if(sps->long_term_ref_pics_present_flag){
		bsUvlc( s, sps->num_long_term_ref_pic_sps );
		for(i=0; i<sps->num_long_term_ref_pic_sps; i++){
			//bsWrite( s, sps->lt_ref_pic_poc_lsb_sps );
		}
	}
	bsWrite1Bit( s, sps->sps_temporal_mvp_enable_flag );
	bsWrite1Bit( s, sps->sps_strong_intra_smoothing_enable_flag );
	bsWrite1Bit( s, sps->vui_parameters_present_flag );
	
	//vui
	if(sps->vui_parameters_present_flag){
		bsWrite1Bit( s, sps->vui.aspect_ratio_info_present_flag );
		if(sps->vui.aspect_ratio_info_present_flag){
			bsWrite( s, 8, sps->vui.aspect_ratio_idc );
			if(sps->vui.aspect_ratio_idc==255){
				bsWrite( s, 16, sps->vui.sar_width );
				bsWrite( s, 16, sps->vui.sar_height );
			}
		}
	
		bsWrite1Bit( s, sps->vui.overscan_info_present_flag );
		if(sps->vui.overscan_info_present_flag)
			bsWrite1Bit( s, sps->vui.overscan_appropriate_flag );
		bsWrite1Bit( s, sps->vui.video_signal_type_present_flag );
		if(sps->vui.video_signal_type_present_flag){
			bsWrite ( s, 3, sps->vui.video_format );
			bsWrite1Bit( s, sps->vui.video_full_range_flag );
			bsWrite1Bit( s, sps->vui.colour_description_present_flag );
			if(sps->vui.colour_description_present_flag){
				bsWrite( s, 8, sps->vui.colour_primaries );
				bsWrite( s, 8, sps->vui.transfer_characteristics );
				bsWrite( s, 8, sps->vui.matrix_coefficients );
			}
		}
		bsWrite1Bit( s, sps->vui.chroma_loc_info_present_flag );
		if(sps->vui.chroma_loc_info_present_flag){
			bsUvlc( s, sps->vui.chroma_sample_loc_type_top_field );
			bsUvlc( s, sps->vui.chroma_sample_loc_type_bottom_field );
		}
		bsWrite1Bit( s, sps->vui.neutral_chroma_indication_flag );
		bsWrite1Bit( s, sps->vui.field_seq_flag );
		bsWrite1Bit( s, sps->vui.default_display_window_flag );
		bsWrite1Bit( s, sps->vui.pic_struct_present_flag );
		bsWrite1Bit( s, sps->vui.hrd_parameters_present_flag );
		if(sps->vui.hrd_parameters_present_flag){
			bsWrite1Bit( s, sps->vui.timing_info_present_flag );
			if(sps->vui.timing_info_present_flag){
				bsWrite( s, 32, sps->vui.num_units_in_tick );
				bsWrite( s, 32, sps->vui.time_scale );
			}
			bsWrite1Bit( s, sps->vui.nal_hrd_parameters_present_flag );
			bsWrite1Bit( s, sps->vui.vcl_hrd_parameters_present_flag );
			if(sps->vui.nal_hrd_parameters_present_flag || sps->vui.vcl_hrd_parameters_present_flag)
			{
				bsWrite1Bit( s, sps->vui.sub_pic_cpb_params_present_flag );
				if(sps->vui.sub_pic_cpb_params_present_flag)
				{
					bsWrite( s, 8, sps->vui.tick_divisor_minus2 );
					bsWrite( s, 5, sps->vui.du_cpb_removal_delay_length_minus1 );
				}
				bsWrite( s, 4, sps->vui.bit_rate_scale );
				bsWrite( s, 4, sps->vui.cpb_size_scale );
				if(sps->vui.cpb_size_scale)
					bsWrite( s, 4, sps->vui.du_cpb_size_scale );
				bsWrite( s, 5, sps->vui.initial_cpb_removal_delay_length_minus1 );
				bsWrite( s, 5, sps->vui.cpb_removal_delay_length_minus1 );
				bsWrite( s, 5, sps->vui.dpb_output_delay_length_minus1 );
			}
			for(i=0; i<sps->sps_max_sub_layers_minus1+1; i++)
			{
				bsWrite1Bit( s, sps->vui.fixed_pic_rate_flag );
				if(sps->vui.fixed_pic_rate_flag)
					bsUvlc( s, sps->vui.pic_duration_in_tc_minus1 );
				bsWrite1Bit( s, sps->vui.low_delay_hrd_flag );
				bsUvlc( s, sps->vui.cpb_cnt_minus1 );
				for(nal_or_vcl=0; nal_or_vcl<2; nal_or_vcl++){
					if(((nal_or_vcl==0) && (sps->vui.nal_hrd_parameters_present_flag)) || ((nal_or_vcl==1) && (sps->vui.vcl_hrd_parameters_present_flag))){
						for(j=0; j<sps->vui.cpb_cnt_minus1; j++){
							bsUvlc( s, sps->vui.bit_size_value_minus1 );
							bsUvlc( s, sps->vui.cpb_size_value_minus1 );
							if(sps->vui.sub_pic_cpb_params_present_flag)
								bsUvlc( s, sps->vui.du_cpb_size_value_minus1 );
							bsWrite1Bit( s, sps->vui.cbr_flag );
						}
					}
				}
			}
		}
	}

	bsWrite1Bit( s, sps->sps_extension_flag );

	//rbsp_trailing_bits
	bsWrite( s, 1, 1 );
	bsAlign0( s );

}

static void ppsEncode(pps_t* pps, bs_t *s){

	int i =0;
	int j =0;
	bsUvlc  ( s, pps->pic_parameter_set_id );
	bsUvlc  ( s, pps->seq_parameter_set_id );
	bsWrite1Bit( s, pps->dependent_slice_enabled_flag );
	bsWrite1Bit( s, pps->output_flag_present_flag );
	bsWrite ( s, 3, pps->num_extra_slice_header_bits );
	bsWrite1Bit( s, pps->sign_data_hiding_flag );
	bsWrite1Bit( s, pps->cabac_init_present_flag );
	bsUvlc  ( s, pps->num_ref_idx_l0_default_active_minus1 );
	bsUvlc  ( s, pps->num_ref_idx_l1_default_active_minus1 );
	bsSvlc  ( s, pps->pic_init_qp_minus26 );
	bsWrite1Bit( s, pps->constrained_intra_pred_flag ? 1 : 0 );
	bsWrite1Bit( s, pps->transform_skip_enabled_flag ? 1 : 0 );
	bsWrite1Bit( s, pps->cu_qp_delta_enabled_flag ? 1 : 0 );
	if(pps->cu_qp_delta_enabled_flag)
		bsUvlc( s, pps->diff_cu_qp_delta_depth );
	bsSvlc ( s, pps->cb_qp_offset );
	bsSvlc ( s, pps->cr_qp_offset );
	bsWrite1Bit( s, pps->slicelevel_chroma_qp_flag ? 1 : 0 );
	bsWrite1Bit( s, pps->weighted_pred_flag ? 1 : 0 );
	bsWrite1Bit( s, pps->weighted_bipred_flag ? 1 : 0 );
	bsWrite1Bit( s, pps->transquant_bypass_enable_flag ? 1 : 0 );

	bsWrite1Bit( s, pps->tiles_enabled_flag ? 1 : 0 );
	bsWrite1Bit( s, pps->entropy_coding_sync_enabled_flag ? 1 : 0 );
	if(pps->tiles_enabled_flag){
		bsUvlc( s, pps->num_tile_columns_minus1 );
		bsUvlc( s, pps->num_tile_rows_minus1 );
		bsWrite1Bit( s, pps->uniform_spacing_flag );
		if(pps->uniform_spacing_flag==0){
			for(i=0; i<pps->num_tile_columns_minus1; i++)
				bsUvlc( s, pps->column_width_minus1 );
			for(i=0; i<pps->num_tile_rows_minus1; i++)
				bsUvlc( s, pps->row_height_minus1 );
		}
		if((pps->num_tile_columns_minus1!=0) ||(pps->num_tile_rows_minus1!=0))
			bsWrite1Bit( s, pps->loop_filter_across_tiles_enabled_flag ? 1 : 0 );
	}

	bsWrite1Bit( s, pps->loop_filter_across_slices_enabled_flag ? 1 : 0 );
	bsWrite1Bit( s, pps->deblocking_filter_control_present_flag ? 1 : 0 );
	if(pps->deblocking_filter_control_present_flag){
		bsWrite1Bit( s, pps->deblocking_filter_override_enabled_flag ? 1 : 0 );
		bsWrite1Bit( s, pps->pic_disable_deblocking_filter_flag );
		if(!pps->pic_disable_deblocking_filter_flag){
			bsSvlc( s, pps->pps_beta_offset_div2 );
			bsSvlc( s, pps->pps_tc_offset_div2 );
		}
	}

	//scaling list
	bsWrite1Bit( s, pps->pps_scaling_list_data_present_flag ? 1 : 0 );
	if(pps->pps_scaling_list_data_present_flag)
	{
		for(i=0; i<4; i++){
			for(j=0; j<4; j++){
				bsWrite1Bit( s, pps->scaling_list_pred_mode_flag );
			}
			if(!pps->scaling_list_pred_mode_flag)
				bsUvlc( s, pps->scaling_list_pred_matrix_id_delta );
			else {
				//xCodeScalingList
			}
		}
	}
	
	bsWrite1Bit( s, pps->lists_modification_present_flag );
	bsUvlc ( s, pps->log2_parallel_merge_level_minus2 );
	bsWrite1Bit( s, pps->slice_header_extension_present_flag );
	bsWrite1Bit( s, pps->pps_extension_flag );
	
	//rbsp trailing bits
	bsWrite( s, 1, 1 );
	bsAlign0( s );
}

static void sliceHeaderEncode(sliceHeader_t *sh, bs_t *s, param_t param){

	int idr_pic_flag = FALSE;
	int tmvp_flag_enable = TRUE;
	int address = 0;
	int slice_address = 0;
	int i = 0 ;
	int j = 0 ;
	int getrpc = 0;
	int enc_cabac_table_idx =0;
	int sao_enable = 0;
	int dbf_enable = 0;

	bsWrite1Bit( s, sh->first_slice_in_pic_flag );
	if(param.frame_num==0)
		bsWrite1Bit( s, sh->no_output_of_prior_pics_flag );
	bsUvlc( s, sh->pic_parameter_set_id );
	
	address = 0;
	slice_address = 0;
	if(sh->pps.dependent_slice_enabled_flag && (address!=0))
		bsWrite1Bit( s, sh->dependent_slice_flag );
	if(address>0)
		bsWrite( s, address, 5 );
	
	if(!sh->pps.dependent_slice_enabled_flag){
		for(i=0; i<sh->pps.num_extra_slice_header_bits; i++)
			bsWrite1Bit( s, 0 );
		bsUvlc( s, sh->slice_type );
		if(sh->pps.output_flag_present_flag)
			bsWrite1Bit( s, sh->pic_output_flag ? 1 : 0 );
		

		if(param.frame_num==0)
			idr_pic_flag = TRUE;
		if(!idr_pic_flag){
			bsWrite( s, (sh->sps.log2_max_pic_order_cnt_lsb_minus4+4), ((param.frame_num+0)%(1<<(sh->sps.log2_max_pic_order_cnt_lsb_minus4+4))) );           //pic_order_cnt_lsb
			getrpc = 0;
			if(getrpc<0){
				bsWrite1Bit( s, sh->short_term_ref_pic_set_sps_flag );
				//codeShortTermRefPicSet
			}
			else{
				bsWrite1Bit( s, !sh->short_term_ref_pic_set_sps_flag );
			}
			if(sh->sps.long_term_ref_pics_present_flag){
				//long term pic
			}
			if(sh->sps.sps_temporal_mvp_enable_flag)
				bsWrite1Bit( s, sh->enable_temporal_mvp_flag );
		}
		
		
		if(sh->sps.sample_adaptive_offset_enabled_flag){
			bsWrite1Bit( s, sh->slice_sao_luma_flag );
			bsWrite1Bit( s, sh->slice_sao_chroma_flag );
		}
		
		if(!(sh->slice_type==SLICE_TYPE_I)){
			bsWrite1Bit( s, sh->num_ref_idx_active_override_flag );
			if(sh->num_ref_idx_active_override_flag){
				bsUvlc( s, sh->num_ref_idx_l0_active_minus1 );
				if(sh->slice_type==SLICE_TYPE_B)
					bsUvlc( s, sh->num_ref_idx_l1_active_minus1 );
			}
		}
		
		if(sh->pps.lists_modification_present_flag && (0>1)){
			if(!(sh->slice_type==SLICE_TYPE_I)){
				bsWrite1Bit( s, sh->ref_pic_list_modification_flag_l0 ? 1 : 0 );
				if(sh->ref_pic_list_modification_flag_l0){
					;//
				}
			}
		
			if(sh->slice_type==SLICE_TYPE_B){
				bsWrite1Bit( s, sh->ref_pic_list_modification_flag_l1 );
				if(sh->ref_pic_list_modification_flag_l1){
					//
				}
			}
		}
		if(sh->slice_type==SLICE_TYPE_B)
			bsWrite1Bit( s, sh->mvd_l1_zero_flag );
		
		if(!(sh->slice_type==SLICE_TYPE_I)){
			if(sh->pps.cabac_init_present_flag){
				enc_cabac_table_idx = param.type;
				sh->cabac_init_flag = (param.type!=enc_cabac_table_idx && enc_cabac_table_idx!=SLICE_TYPE_I) ? TRUE : FALSE;
				bsWrite1Bit( s, sh->cabac_init_flag ? 1 : 0 );
			}
		}
		
		tmvp_flag_enable = TRUE;
		i = 0;
		j = 0;
		if(sh->enable_temporal_mvp_flag){
			if(sh->slice_type==SLICE_TYPE_B)
				bsWrite1Bit( s, sh->collocated_from_l0_flag );
			if(sh->slice_type!=SLICE_TYPE_I && ( (sh->collocated_from_l0_flag==1 && i>1) || (sh->collocated_from_l0_flag==0 && j>1)))
				bsUvlc( s, sh->collocated_ref_idx );
		}
		if((sh->pps.weighted_pred_flag && sh->slice_type==SLICE_TYPE_P) || (sh->pps.weighted_bipred_flag && sh->slice_type==SLICE_TYPE_B)){
			//xCodePredHeight
		}
		if(!(sh->slice_type==SLICE_TYPE_I))
			bsUvlc( s, sh->five_minus_max_num_merge_cand );
		
		//qp
		i = param.qp - (sh->pps.pic_init_qp_minus26 + 26);
		bsSvlc( s, i );
		if(sh->pps.slicelevel_chroma_qp_flag){
			//cr,cb qp_delta
			bsSvlc( s, sh->slice_qp_delta_cb );
			bsSvlc( s, sh->slice_qp_delta_cr );
		}
		
		if(sh->pps.deblocking_filter_control_present_flag){
			if(sh->pps.deblocking_filter_override_enabled_flag)
				bsWrite1Bit( s, sh->deblocking_filter_override_flag );
			if(sh->deblocking_filter_override_flag){
				bsWrite1Bit( s, sh->slice_disable_deblocking_filter_flag );
				if(!sh->slice_disable_deblocking_filter_flag){
					bsSvlc( s, sh->beta_offset_div2 );
					bsSvlc( s, sh->tc_offset_div2 );
				}
			}
		}
		sao_enable = (!sh->sps.sample_adaptive_offset_enabled_flag) ? FALSE : (sh->slice_sao_luma_flag || sh->slice_sao_chroma_flag);
		dbf_enable = (!sh->slice_disable_deblocking_filter_flag);
		if(sh->pps.loop_filter_across_slices_enabled_flag && (sao_enable || dbf_enable))
			bsWrite1Bit( s, sh->slice_loop_filter_across_slices_enabled_flag );
	}

	if(sh->pps.slice_header_extension_present_flag)
		bsUvlc( s, sh->slice_header_extension_length );

	bsAlign1(s);
}

static void nalHeaderEncode(bs_t *s, uint32_t nalType){

	*s->pCur = (0x00<<7) | (nalType<<1);
	s->pCur++;
	*s->pCur = 1;
	s->pCur++;
	s->byteCnt += 2;
}

void vpsWrite(bs_t *s, param_t param){
	vps_t vps;
	vpsInit(&vps, param);
	nalHeaderEncode(s, NAL_UNIT_VPS);
	vpsEncode(&vps, s);
}

void spsWrite(sps_t* sps, bs_t *s, param_t param){

	spsInit(sps, param);
	nalHeaderEncode(s, NAL_UNIT_SPS);
	spsEncode(sps, s);
}

void ppsWrite( pps_t* pps,bs_t *s, param_t param){

	ppsInit(pps, param);
	nalHeaderEncode(s, NAL_UNIT_PPS);
	ppsEncode(pps, s);
}

void sliceHeaderWrite(sliceHeader_t* sh, bs_t *s, param_t param){

	uint32_t nalType;

	if(param.frame_num==0){
		nalType = NAL_UNIT_CODED_SLICE_IDR;
		param.type = SLICE_TYPE_I;
	}
	else if(param.frame_num % param.gop_length){
		nalType = NAL_UNIT_CODED_SLICE_TRAIL_R;
		param.type = SLICE_TYPE_P;
	}
	else{
		nalType = NAL_UNIT_CODED_SLICE_TRAIL_N;
		param.type = SLICE_TYPE_I;
	}

	sliceHeaderInit(sh, param);
	nalHeaderEncode(s, nalType);
	sliceHeaderEncode(sh, s, param);    
}