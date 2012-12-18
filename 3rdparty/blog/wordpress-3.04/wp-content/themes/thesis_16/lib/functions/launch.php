<?php

// Internationalization
load_theme_textdomain('thesis', THESIS_LIB . '/languages');

// Add Thesis Options and Design Options pages to the WordPress Dashboard
if (is_admin()) thesis_admin_setup();

// Register sidebars and widgets
thesis_register_sidebars();
thesis_register_widgets();

$thesis = array(
	'head' => thesis_get_option('head'),
	'feed' => thesis_get_option('feed'),
	'scripts' => thesis_get_option('scripts'),
	'home' => thesis_get_option('home'),
	'display' => thesis_get_option('display'),
	'nav' => thesis_get_option('nav'),
	'image' => thesis_get_option('image'),
	'save_button_text' => thesis_get_option('save_button_text'),
	'version' => thesis_get_option('version')
);

$thesis_design = array(
	'fonts' => thesis_get_design_option('fonts'),
	'colors' => thesis_get_design_option('colors'),
	'borders' => thesis_get_design_option('borders'),
	'nav' => thesis_get_design_option('nav'),
	'style' => thesis_get_design_option('style'),
	'layout' => thesis_get_design_option('layout'),
	'teasers' => thesis_get_design_option('teasers'),
	'feature_box' => thesis_get_design_option('feature_box'),
	'multimedia_box' => thesis_get_design_option('multimedia_box')
);

if ($_GET['activated'])
	thesis_upgrade();

// Construct the WordPress header
add_action('wp_head', array('Head', 'build'));
remove_action('wp_head', 'wp_generator');
remove_action('wp_head', 'start_post_rel_link');
remove_action('wp_head', 'index_rel_link');
remove_action('wp_head', 'adjacent_posts_rel_link');
remove_action('wp_head', 'next_post_rel_link');
remove_action('wp_head', 'prev_post_rel_link');
remove_action('wp_head', 'parent_post_rel_link');

// Add post images to RSS feed
add_filter('the_content', 'thesis_add_image_to_feed');

// Construct the Thesis header
add_action('thesis_hook_before_header', 'thesis_nav_menu');
add_action('thesis_hook_header', 'thesis_default_header');

// Post hooks
add_action('thesis_hook_after_post', 'thesis_trackback_rdf', 1);
add_action('thesis_hook_after_post', 'thesis_post_tags');
add_action('thesis_hook_after_post', 'thesis_comments_link');

// Content hooks
add_action('thesis_hook_after_content', 'thesis_post_navigation');
add_action('thesis_hook_after_content', 'thesis_prev_next_posts');

// Use our image captioning
remove_shortcode('wp_caption');
remove_shortcode('caption');
add_shortcode('wp_caption', 'thesis_img_caption_shortcode');
add_shortcode('caption', 'thesis_img_caption_shortcode');

// Archive info hook
add_action('thesis_hook_archive_info', 'thesis_default_archive_info');

// Archives page template hook
add_action('thesis_hook_archives_template', 'thesis_archives_template');

// Custom page template sample
add_action('thesis_hook_custom_template', 'thesis_custom_template_sample');

// Footer hooks
add_action('thesis_hook_footer', 'thesis_attribution');

// Hook unseen items (like tracking codes) at the end of the document's HTML
add_action('thesis_hook_after_html', 'thesis_ie_clear');
thesis_add_footer_scripts();

// 404 page hooks
add_action('thesis_hook_404_title', 'thesis_404_title');
add_action('thesis_hook_404_content', 'thesis_404_content');

// Plugin compatibility functions
thesis_subscribe_to_comments_compatibility();

// Handle IE8 compatibility.
thesis_ie8_compatibility();