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
	echo '	<div id="footer">' . "\n";
	thesis_hook_footer();
	thesis_admin_link();
	wp_footer();
	echo '	</div>' . "\n";
}

/**
 * Display default Thesis attribution.
 */
function thesis_attribution() {
	echo '		<p>' . __('Get smart with the <a href="http://diythemes.com/thesis/">Thesis WordPress Theme</a> from DIYthemes.', 'thesis') . '</p>' . "\n";
}