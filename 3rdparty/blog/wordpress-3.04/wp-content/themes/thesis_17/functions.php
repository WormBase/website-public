<?php
/**
 * Defines the necessary constants and includes the necessary files for Thesis’ operation.
 *
 * Many WordPress customization tutorials suggest editing a theme’s functions.php file. With 
 * Thesis, you should edit the included custom/custom_functions.php file if you wish
 * to make modifications.
 *
 * @package Thesis
 */

// Define directory constants
define('THESIS_LIB', TEMPLATEPATH . '/lib');
define('THESIS_ADMIN', THESIS_LIB . '/admin');
define('THESIS_CLASSES', THESIS_LIB . '/classes');
define('THESIS_FUNCTIONS', THESIS_LIB . '/functions');
define('THESIS_CSS', THESIS_LIB . '/css');
define('THESIS_HTML', THESIS_LIB . '/html');
define('THESIS_SCRIPTS', THESIS_LIB . '/scripts');
define('THESIS_IMAGES', THESIS_LIB . '/images');
define('THESIS_CUSTOM', TEMPLATEPATH . '/custom');

// Define folder constants
define('THESIS_CSS_FOLDER', get_bloginfo('template_url') . '/lib/css'); #wp
define('THESIS_SCRIPTS_FOLDER', get_bloginfo('template_url') . '/lib/scripts'); #wp
define('THESIS_IMAGES_FOLDER', get_bloginfo('template_url') . '/lib/images'); #wp

if (file_exists(THESIS_CUSTOM)) {
	define('THESIS_CUSTOM_FOLDER', get_bloginfo('template_url') . '/custom'); #wp
	define('THESIS_LAYOUT_CSS', THESIS_CUSTOM . '/layout.css');
	define('THESIS_ROTATOR', THESIS_CUSTOM . '/rotator');
	define('THESIS_ROTATOR_FOLDER', THESIS_CUSTOM_FOLDER . '/rotator');
}
elseif (file_exists(TEMPLATEPATH . '/custom-sample')) {
	define('THESIS_SAMPLE_FOLDER', get_bloginfo('template_url') . '/custom-sample'); #wp
	define('THESIS_LAYOUT_CSS', TEMPLATEPATH . '/custom-sample/layout.css');
	define('THESIS_ROTATOR', TEMPLATEPATH . '/custom-sample/rotator');
	define('THESIS_ROTATOR_FOLDER', THESIS_SAMPLE_FOLDER . '/rotator');
}

// Load classes
require_once(THESIS_CLASSES . '/comments.php');
require_once(THESIS_CLASSES . '/css.php');
require_once(THESIS_CLASSES . '/fonts.php');
require_once(THESIS_CLASSES . '/head.php');
require_once(THESIS_CLASSES . '/javascript.php');
require_once(THESIS_CLASSES . '/options_design.php');
require_once(THESIS_CLASSES . '/options_page.php');
require_once(THESIS_CLASSES . '/options_site.php');

// Admin stuff
if (is_admin()) { #wp
	require_once(THESIS_ADMIN . '/admin.php');
	require_once(THESIS_ADMIN . '/file_editor.php');
	require_once(THESIS_ADMIN . '/options_manager.php');
	require_once(THESIS_ADMIN . '/options_post.php');
}

// Load template-based function files
require_once(THESIS_FUNCTIONS . '/comments.php');
require_once(THESIS_FUNCTIONS . '/compatibility.php');
require_once(THESIS_FUNCTIONS . '/content.php');
require_once(THESIS_FUNCTIONS . '/document.php');
require_once(THESIS_FUNCTIONS . '/feature_box.php');
require_once(THESIS_FUNCTIONS . '/loop.php');
require_once(THESIS_FUNCTIONS . '/multimedia_box.php');
require_once(THESIS_FUNCTIONS . '/nav_menu.php');
require_once(THESIS_FUNCTIONS . '/post_images.php');
require_once(THESIS_FUNCTIONS . '/teasers.php');
require_once(THESIS_FUNCTIONS . '/version.php');
require_once(THESIS_FUNCTIONS . '/widgets.php');

// Load HTML frameworks
require_once(THESIS_HTML . '/content_box.php');
require_once(THESIS_HTML . '/footer.php');
require_once(THESIS_HTML . '/frameworks.php');
require_once(THESIS_HTML . '/header.php');
require_once(THESIS_HTML . '/hooks.php');
require_once(THESIS_HTML . '/sidebars.php');
require_once(THESIS_HTML . '/templates.php');

// Launch Thesis within WordPress
require_once(THESIS_FUNCTIONS . '/launch.php');

// Include the user's custom_functions file, but only if it exists
if (file_exists(THESIS_CUSTOM . '/custom_functions.php'))
	include(THESIS_CUSTOM . '/custom_functions.php');