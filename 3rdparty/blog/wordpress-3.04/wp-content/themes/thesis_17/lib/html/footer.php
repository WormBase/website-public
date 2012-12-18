<?php

/**
 * Call footer elements.
 */
function thesis_footer_area() {
	thesis_hook_before_footer();
	thesis_footer();
	thesis_hook_after_footer();
}

/**
 * Display primary footer content.
 */
function thesis_footer() {
	echo "\t<div id=\"footer\">\n";
	thesis_hook_footer();
	thesis_admin_link();
	wp_footer();
	echo "\t</div>\n";
}

/**
 * Display default Thesis attribution.
 */
function thesis_attribution() {
	echo "\t\t<p>" . sprintf(__('Get smart with the <a href="%s">Thesis WordPress Theme</a> from DIYthemes.', 'thesis'), 'http://diythemes.com/thesis/') . "</p>\n";
}