<?php

function thesis_archives_template() {
?>
					<h3 class="top"><?php _e('By Month:', 'thesis'); ?></h3>
					<ul>
						<?php wp_get_archives('type=monthly'); ?>
					</ul>
					<h3><?php _e('By Category:', 'thesis'); ?></h3>
					<ul>
						<?php wp_list_categories('title_li=0'); ?>
					</ul>
<?php
}

function thesis_custom_template_sample() {
	thesis_columns();
}

function thesis_faux_admin() {
	global $thesis_design;
	
	get_header(apply_filters('thesis_get_header', $name));
	
	if ($thesis_design['layout']['framework'] == 'page' || !$thesis_design['layout']['framework']) {
		echo '<div id="container">' . "\n";
		echo '<div id="page">' . "\n";
		thesis_header_area();
		thesis_faux_admin_content_area();
		thesis_footer_area();
		echo '</div>' . "\n";
		echo '</div>' . "\n";
	}
	elseif ($thesis_design['layout']['framework'] == 'full-width') {
		thesis_wrap_header();
		echo '<div id="content_area" class="full_width">' . "\n";
		echo '<div class="page">' . "\n";
		thesis_faux_admin_content_area();
		echo '</div>' . "\n";
		echo '</div>' . "\n";
		thesis_wrap_footer();
	}
		
	get_footer(apply_filters('thesis_get_footer', $name));
}

function thesis_faux_admin_content_area() {
	global $thesis_design;

	echo '	<div id="content_box">' . "\n";
		
	if ($thesis_design['layout']['columns'] == 3 && $thesis_design['layout']['order'] == 'invert') {
		echo '		<div id="column_wrap">' . "\n";
		thesis_hook_faux_admin();
		thesis_get_sidebar();
		echo '		</div>' . "\n";
	}
	else
		thesis_hook_faux_admin();

	thesis_sidebars();
	echo '	</div>' . "\n";
}