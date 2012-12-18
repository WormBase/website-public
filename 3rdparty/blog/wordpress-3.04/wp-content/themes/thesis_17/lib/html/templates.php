<?php

function thesis_archives_template() {
	echo "\t\t\t\t\t<h3 class=\"top\">" . __('By Month:', 'thesis') . "</h3>\n";
	echo "\t\t\t\t\t<ul>\n";
	wp_get_archives('type=monthly');
	echo "\t\t\t\t\t</ul>\n";
	echo "\t\t\t\t\t<h3>" . __('By Category:', 'thesis') . "</h3>\n";
	echo "\t\t\t\t\t<ul>\n";
	wp_list_categories('title_li=0');
	echo "\t\t\t\t\t</ul>\n";
}

function thesis_custom_template_sample() {
	thesis_columns();
}