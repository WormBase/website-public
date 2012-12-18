<?php

function thesis_sidebars() {
	echo '		<div id="sidebars">' . "\n";
	thesis_hook_before_sidebars();
	thesis_build_sidebars();
	thesis_hook_after_sidebars();
	echo '		</div>' . "\n";
}

function thesis_build_sidebars() {
	global $thesis_design;

	if (thesis_show_multimedia_box())
		thesis_multimedia_box();

	if ($thesis_design['layout']['columns'] == 3 && $thesis_design['layout']['order'] == 'invert')
		thesis_get_sidebar(2);
	elseif ($thesis_design['layout']['columns'] == 3 || $thesis_design['layout']['columns'] == 1 || $_GET['template']) {
		thesis_get_sidebar();
		thesis_get_sidebar(2);
	}
	else
		thesis_get_sidebar();
}

function thesis_get_sidebar($sidebar = 1) {
	echo '			<div id="sidebar_' . $sidebar . '" class="sidebar">' . "\n";
	echo '				<ul class="sidebar_list">' . "\n";
	
	if ($sidebar == 1)
		thesis_sidebar_1();
	elseif ($sidebar == 2)
		thesis_sidebar_2();
		
	echo '				</ul>' . "\n";
	echo '			</div>' . "\n";
}

function thesis_sidebar_1() {
	thesis_hook_before_sidebar_1();
	thesis_default_widget();
	thesis_hook_after_sidebar_1();
}

function thesis_sidebar_2() {
	thesis_hook_before_sidebar_2();
	thesis_default_widget(2);
	thesis_hook_after_sidebar_2();
}