jQuery(document).ready(function() {
	// Initialize form controls
	jQuery('.control_box .control input:checkbox').parents('.control').siblings('.dependent').hide();
	jQuery('.control_box .control input:checkbox:checked').parents('.control').addClass('add_margin');
	jQuery('.control_box .control input:checkbox:checked').parents('.control').siblings('.dependent').show();

	jQuery('#master_switch').children('.neg').hide();
	jQuery('.options_module h4 a').children('.neg').hide();
	jQuery('.module_subsection h4 a').parents('h4').siblings('.more_info').hide();

	jQuery('.toggle_box .dependent').hide();

	jQuery('#no_box_tip').hide();
	jQuery('#image_tip').hide();
	jQuery('#image_alt_module').hide();
	jQuery('#video_code_module').hide();
	jQuery('#custom_code_module').hide();
	
	jQuery('#teasers_layout').hide();
	jQuery('#magazine_layout').hide();
	jQuery('#teaser_date_format').hide();
	jQuery('#teaser_link').hide();
	
	jQuery('#feature_box_radio').hide();
	jQuery('#feature_box_content_position').hide();
	jQuery('#feature_box_display').hide();

	jQuery('.multi_control').each(function() {
		jQuery(this).children('.dependent').hide();
		var conditional_controls = jQuery(this).children('.control').children(':checkbox').length;
		var triggered = jQuery(this).children('.control').children(':checkbox:checked').length;
		if (conditional_controls == triggered) {
			jQuery(this).children('.dependent').show();
		}
	});

	if (jQuery('#multimedia_select option[value="image"]').is(':selected')) {
		jQuery('#multimedia_select').addClass('add_margin');
		jQuery('#image_tip').show();
		jQuery('#image_alt_module').show();
	}
	else if (jQuery('#multimedia_select option[value="video"]').is(':selected')) {
		jQuery('#video_code_module').show();
	}
	else if (jQuery('#multimedia_select option[value="custom"]').is(':selected')) {
		jQuery('#custom_code_module').show();
	}
	else if (jQuery('#multimedia_select option[value="0"]').is(':selected')) {
		jQuery('#multimedia_select').addClass('add_margin');
		jQuery('#no_box_tip').show();
	}
	
	if (jQuery('#num_columns option[value="3"]').is(':selected')) {
		jQuery('#width_content').addClass('add_margin');
		jQuery('#width_sidebar_1').show();
		jQuery('#width_sidebar_1 p.form_input').addClass('add_margin');
		jQuery('#width_sidebar_2').show();
		jQuery('#column_order').show();
		jQuery('#order_3_col').show();
		jQuery('#order_2_col').hide();
	}
	else if (jQuery('#num_columns option[value="2"]').is(':selected')) {
		jQuery('#width_content').addClass('add_margin');
		jQuery('#width_sidebar_1').show();
		jQuery('#width_sidebar_1 p.form_input').removeClass('add_margin');
		jQuery('#width_sidebar_2').hide();
		jQuery('#column_order').show();
		jQuery('#order_3_col').hide();
		jQuery('#order_2_col').show();
	}
	else if (jQuery('#num_columns option[value="1"]').is(':selected')) {
		jQuery('#width_sidebar_1').hide();
		jQuery('#width_sidebar_2').hide();
		jQuery('#column_order').hide();
	}
	
	if (jQuery('#teasers_date_show').is(':checked')) {
		jQuery('#teaser_date_format').show();
	}
	
	if (jQuery('#teasers_link_show').is(':checked')) {
		jQuery('#teaser_link').show();
	}
	
	// Feature box controls
	if (jQuery('#feature_select option[value="content"]').is(':selected')) {
		jQuery('#feature_select').addClass('add_margin');
		jQuery('#feature_box_radio').show();
		jQuery('#feature_box_radio ul').addClass('add_margin');
		jQuery('#feature_box_content_position').show();
		jQuery('#feature_box_display').show();
	}
	else if (jQuery('#feature_select option[value="full-content"]').is(':selected')) {
		jQuery('#feature_select').addClass('add_margin');
		jQuery('#feature_box_radio').show();
		jQuery('#feature_box_radio ul').removeClass('add_margin');
		jQuery('#feature_box_content_position').hide();
		jQuery('#feature_box_display').show();
	}
	else if (jQuery('#feature_select option[value="full-header"]').is(':selected')) {
		jQuery('#feature_select').addClass('add_margin');
		jQuery('#feature_box_radio').show();
		jQuery('#feature_box_radio ul').removeClass('add_margin');
		jQuery('#feature_box_content_position').hide();
		jQuery('#feature_box_display').show();
	}
	
	// Checkbox-dependent behaviors
	jQuery('.control_box .control input:checkbox').change(function() {
		jQuery(this).parents('.control').toggleClass('add_margin');
		jQuery(this).parents('.control').siblings('.dependent').toggle();
	});
	
	// Toggle-only behaviors
	jQuery('.toggle_box .switch').click(function() {
		jQuery(this).parents('p').siblings('.dependent').toggle();
		return false;
	});

	// Multi-control behaviors
	jQuery('.multi_control .control input:checkbox').change(function() {
		var maybe_switches = jQuery(this).parents('.control').length;
		var switches = jQuery(this).parents('.control').children(':checkbox').length + jQuery(this).parents('.control').siblings('.control').children(':checkbox').length;
		var tripped = jQuery(this).parents('.control').children(':checkbox:checked').length + jQuery(this).parents('.control').siblings('.control').children(':checkbox:checked').length;
		if (switches == tripped) {
			jQuery(this).parents('.control').siblings('.dependent').show();
		}
		else {
			jQuery(this).parents('.control').siblings('.dependent').hide();
		}
	});
	
	jQuery('#master_switch').click(function() {
		jQuery(this).toggleClass('active');
		jQuery(this).children('.pos').toggle();
		jQuery(this).children('.neg').toggle();
		jQuery('h4 a').toggleClass('active');
		jQuery('h4 a').children('.pos').toggle();
		jQuery('h4 a').children('.neg').toggle();
		jQuery('.more_info').toggle();
		return false;
	});
	
	jQuery('.module_subsection h4 a').click(function() {
		jQuery(this).children('.pos').toggle();
		jQuery(this).children('.neg').toggle();
		jQuery(this).toggleClass('active');
		jQuery(this).parents('h4').siblings('.more_info:first').toggle();
		return false;
	});
	
	// Sortable behaviors
	jQuery(function() {
		jQuery('#nav_pages').sortable({});
		jQuery('#teaser_content').sortable({});
	});

	// Select-dependent behaviors
	jQuery('#multimedia_select select').change(function() {
		if (jQuery('#multimedia_select option[value="image"]').is(':selected')) {
			jQuery('#multimedia_select').addClass('add_margin');
			jQuery('#image_tip').show();
			jQuery('#image_alt_module').show();
			jQuery('#no_box_tip').hide();
			jQuery('#video_code_module').hide();
			jQuery('#custom_code_module').hide();
		}
		else if (jQuery('#multimedia_select option[value="video"]').is(':selected')) {
			jQuery('#video_code_module').show();
			jQuery('#no_box_tip').hide();
			jQuery('#image_tip').hide();
			jQuery('#image_alt_module').hide();
			jQuery('#custom_code_module').hide();
		}
		else if (jQuery('#multimedia_select option[value="custom"]').is(':selected')) {
			jQuery('#custom_code_module').show();
			jQuery('#no_box_tip').hide();
			jQuery('#image_tip').hide();
			jQuery('#image_alt_module').hide();
			jQuery('#video_code_module').hide();
		}
		else if (jQuery('#multimedia_select option[value="0"]').is(':selected')) {
			jQuery('#multimedia_select').addClass('add_margin');
			jQuery('#no_box_tip').show();
			jQuery('#image_tip').hide();
			jQuery('#image_alt_module').hide();
			jQuery('#video_code_module').hide();
			jQuery('#custom_code_module').hide();
		}
	});
	
	jQuery('#num_columns').change(function() {
		if (jQuery('#num_columns option[value="3"]').is(':selected')) {
			jQuery('#width_content').addClass('add_margin');
			jQuery('#width_sidebar_1').show();
			jQuery('#width_sidebar_1 p.form_input').addClass('add_margin');
			jQuery('#width_sidebar_2').show();
			jQuery('#column_order').show();
			jQuery('#order_3_col').show();
			jQuery('#order_2_col').hide();
		}
		else if (jQuery('#num_columns option[value="2"]').is(':selected')) {
			jQuery('#width_content').addClass('add_margin');
			jQuery('#width_sidebar_1 p.form_input').removeClass('add_margin');
			jQuery('#width_sidebar_1').show();
			jQuery('#width_sidebar_2').hide();
			jQuery('#column_order').show();
			jQuery('#order_3_col').hide();
			jQuery('#order_2_col').show();
		}
		else if (jQuery('#num_columns option[value="1"]').is(':selected')) {
			jQuery('#width_content').removeClass('add_margin');
			jQuery('#width_sidebar_1').hide();
			jQuery('#width_sidebar_1 p.form_input').removeClass('add_margin');
			jQuery('#width_sidebar_2').hide();
			jQuery('#column_order').hide();
			jQuery('#order_3_col').hide();
			jQuery('#order_2_col').hide();
		}
	});
	
	jQuery('#teasers_date_show').change(function() {
		if (jQuery('#teasers_date_show').is(':checked')) {
			jQuery('#teaser_date_format').show();
		}
		else {
			jQuery('#teaser_date_format').hide();
		}
	});
	
	jQuery('#teasers_link_show').change(function() {
		if (jQuery('#teasers_link_show').is(':checked')) {
			jQuery('#teaser_link').show();
		}
		else {
			jQuery('#teaser_link').hide();
		}
	});
	
	jQuery('#feature_select select').change(function() {
		if (jQuery('#feature_select option[value="content"]').is(':selected')) {
			jQuery('#feature_select').addClass('add_margin');
			jQuery('#feature_box_radio').show();
			jQuery('#feature_box_radio ul').addClass('add_margin');
			jQuery('#feature_box_content_position').show();
			jQuery('#feature_box_display').show();
		}
		else if (jQuery('#feature_select option[value="full-header"]').is(':selected')) {
			jQuery('#feature_select').addClass('add_margin');
			jQuery('#feature_box_radio').show();
			jQuery('#feature_box_radio ul').removeClass('add_margin');
			jQuery('#feature_box_content_position').hide();
			jQuery('#feature_box_display').show();
		}
		else if (jQuery('#feature_select option[value="full-content"]').is(':selected')) {
			jQuery('#feature_select').addClass('add_margin');
			jQuery('#feature_box_radio').show();
			jQuery('#feature_box_radio ul').removeClass('add_margin');
			jQuery('#feature_box_content_position').hide();
			jQuery('#feature_box_display').show();
		}
		else if (jQuery('#feature_select option[value="0"]').is(':selected')) {
			jQuery('#feature_select').removeClass('add_margin');
			jQuery('#feature_box_radio').hide();
			jQuery('#feature_box_content_position').hide();
			jQuery('#feature_box_display').hide();
		}
	});
	
	// Show/hide behaviors for post editing screen
	jQuery('.thesis-post-control .description').hide();
	
	jQuery('.thesis-post-control .switch').click(function() {
		jQuery(this).parents('div p').siblings('.description').toggle();
		return false;
	});
});