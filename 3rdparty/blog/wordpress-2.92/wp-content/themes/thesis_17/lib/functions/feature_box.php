<?php

/**
 * function thesis_add_feature_box()
 *
 * If we need a feature box, we get a feature box, applied liberally to the appropriate hook.
 *
 * @since 1.4
 */
function thesis_add_feature_box() {
	global $thesis_design;

	if (thesis_show_feature_box($thesis_design->feature_box)) {
		if ($thesis_design->feature_box['position'] == 'content') {
			if ($thesis_design->feature_box['after_post'])
				add_action('thesis_hook_after_post_box', 'thesis_feature_box');
			else
				add_action('thesis_hook_before_content', 'thesis_feature_box');
		}
		elseif ($thesis_design->feature_box['position'] == 'full-header')
			add_action('thesis_hook_before_header', 'thesis_feature_box');
		elseif ($thesis_design->feature_box['position'] == 'full-content')
			add_action('thesis_hook_before_content_box', 'thesis_feature_box');
	}
}

/**
 * function thesis_show_feature_box()
 *
 * Determine whether or not Thesis should display the feature box
 *
 * @since 1.4
 */
function thesis_show_feature_box($feature_box) {
	return (($feature_box['status'] == 'sitewide') || ($feature_box['status'] == 'front' && is_front_page()) || ($feature_box['status'] == 'front-and-blog' && (is_front_page() || is_home())) || (!$feature_box['status'] && is_home())) ? true : false;
}

/**
 * function thesis_feature_box()
 *
 * Fancy wrapper for thesis_feature_box_content() that fires at the appropriate place.
 *
 * @since 1.4
 */
function thesis_feature_box($post_count = false) {
	global $thesis_design;
	
	if ($post_count) { // If the user wants the box to be shown in the stream of posts, $post_count will have a value
		if ($post_count == $thesis_design->feature_box['after_post'])
			thesis_feature_box_content($thesis_design->feature_box);
	}
	else
		thesis_feature_box_content($thesis_design->feature_box);
}

function thesis_feature_box_content($feature_box = false) {
	if ($feature_box) {
		echo "<div id=\"feature_box\">\n";
		thesis_hook_feature_box();
		echo "</div>\n";
	}
}