<?php

function thesis_header_area() {
	thesis_hook_before_header();
	thesis_header();
	thesis_hook_after_header();
}

function thesis_header() {
	echo "\t<div id=\"header\">\n";
	thesis_hook_header();
	echo "\t</div>\n";
}

function thesis_default_header() {
	thesis_hook_before_title();
	thesis_title_and_tagline();
	thesis_hook_after_title();
}