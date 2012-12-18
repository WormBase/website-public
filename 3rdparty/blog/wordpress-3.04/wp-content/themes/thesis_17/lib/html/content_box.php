<?php

/**
 * Display primary HTML structure for content.
 */
function thesis_content_area() {
	if (is_page()) {
		global $post;
		$page_template = get_post_meta($post->ID, '_wp_page_template', true);
	}

	$add_class = ($page_template == 'no_sidebars.php') ? ' class="no_sidebars"' : '';

	thesis_hook_before_content_box(); #hook
	echo "\t<div id=\"content_box\"$add_class>\n";
	thesis_hook_content_box_top(); #hook

	if ($page_template == 'no_sidebars.php')
		thesis_content_column();
	elseif ($page_template == 'custom_template.php')
		thesis_hook_custom_template(); #hook
	else
		thesis_columns();

	thesis_hook_content_box_bottom(); #hook
	echo "\t</div>\n";
	thesis_hook_after_content_box(); #hook
}

/**
 * Determine basic columnar display.
 */
function thesis_columns() {
	global $thesis_design;

	if ($thesis_design->layout['columns'] == 3 && $thesis_design->layout['order'] == 'invert')
		thesis_wrap_columns();
	else
		thesis_content_column();
	
	thesis_sidebars();
}

/**
 * Display first sidebar and content column for three-column layouts.
 */
function thesis_wrap_columns() {
	echo "\t\t<div id=\"column_wrap\">\n";
	thesis_content_column();
	thesis_get_sidebar();
	echo "\t\t</div>\n";
}

/**
 * Display content column and the loop.
 */
function thesis_content_column() {
	echo "\t\t<div id=\"content\"" . thesis_content_classes() . ">\n\n";
	thesis_hook_before_content(); #hook
	thesis_loop_posts();
	thesis_hook_after_content(); #hook
	echo "\t\t</div>\n\n";
}