<?php

/**
 * Display primary HTML structure for content.
 */
function thesis_content() {
	thesis_hook_before_content_box();
	
	if (is_page()) {
		global $post;
		$page_template = get_post_meta($post->ID, '_wp_page_template', true);
	}
	
	if ($page_template == 'no_sidebars.php') {
		echo '	<div id="content_box" class="no_sidebars">' . "\n";
		thesis_content_column();
		echo '	</div>' . "\n";
	}
	else {
		echo '	<div id="content_box">' . "\n";

		if ($page_template == 'custom_template.php')
			thesis_hook_custom_template();
		else
			thesis_columns();
			
		echo '	</div>' . "\n";
	}
	
	thesis_hook_after_content_box();
}

/**
 * Determine basic columnar display.
 */
function thesis_columns() {
	global $thesis_design;

	if ($thesis_design['layout']['columns'] == 3 && $thesis_design['layout']['order'] == 'invert')
		thesis_wrap_columns();
	else
		thesis_content_column();
	
	thesis_sidebars();
}

/**
 * Display first sidebar and content column for three-column layouts.
 */
function thesis_wrap_columns() {
	echo '		<div id="column_wrap">' . "\n";
	thesis_content_column();
	thesis_get_sidebar();
	echo '		</div>' . "\n";
}

/**
 * Display content column and the loop.
 */
function thesis_content_column() {
?>
		<div id="content"<?php thesis_content_classes(); ?>>

<?php
		thesis_hook_before_content();
		thesis_loop_posts();
		thesis_hook_after_content();
?>
		</div>

<?php	
}