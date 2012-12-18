<?php

function thesis_sidebars() {
	echo "\t\t<div id=\"sidebars\">\n";
	thesis_hook_before_sidebars(); #hook
	thesis_build_sidebars();
	thesis_hook_after_sidebars(); #hook
	echo "\t\t</div>\n";
}

function thesis_build_sidebars() {
	global $thesis_design;

	if (thesis_show_multimedia_box())
		thesis_multimedia_box();

	if ($thesis_design->layout['columns'] == 3 && $thesis_design->layout['order'] == 'invert')
		thesis_get_sidebar(2);
	elseif ($thesis_design->layout['columns'] == 3 || $thesis_design->layout['columns'] == 1 || $_GET['template']) {
		thesis_get_sidebar();
		thesis_get_sidebar(2);
	}
	else
		thesis_get_sidebar();
}

function thesis_get_sidebar($sidebar = 1) {
	echo "\t\t\t<div id=\"sidebar_$sidebar\" class=\"sidebar\">\n";
	echo "\t\t\t\t<ul class=\"sidebar_list\">\n";

	if ($sidebar == 1)
		thesis_sidebar_1();
	elseif ($sidebar == 2)
		thesis_sidebar_2();

	echo "\t\t\t\t</ul>\n";
	echo "\t\t\t</div>\n";
}

function thesis_sidebar_1() {
	thesis_hook_before_sidebar_1(); #hook
	thesis_default_widget();
	thesis_hook_after_sidebar_1(); #hook
}

function thesis_sidebar_2() {
	thesis_hook_before_sidebar_2(); #hook
	thesis_default_widget(2);
	thesis_hook_after_sidebar_2(); #hook
}