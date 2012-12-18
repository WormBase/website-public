<?php

// Internationalization
load_theme_textdomain('thesis', THESIS_LIB . '/languages');

// Add Thesis Options and Design Options pages to the WordPress Dashboard
if (is_admin()) thesis_admin_setup();

// Register sidebars and widgets
thesis_register_sidebars();
thesis_register_widgets();

$thesis_site = new thesis_site_options;
$thesis_design = new thesis_design_options;
$thesis_pages = new thesis_page_options;
$thesis_site->get_options();
$thesis_design->get_options();
$thesis_pages->get_options();

if ($_GET['activated'])
	thesis_upgrade();

// Deconstruct the WordPress header to make way for Thesis pwnage
remove_action('wp_head', 'wp_generator');
remove_action('wp_head', 'start_post_rel_link');
remove_action('wp_head', 'index_rel_link');
remove_action('wp_head', 'adjacent_posts_rel_link');
remove_action('wp_head', 'next_post_rel_link');
remove_action('wp_head', 'prev_post_rel_link');
remove_action('wp_head', 'parent_post_rel_link');
remove_action('wp_head', 'rel_canonical');

// Handy 301 redirect option for posts and pages
add_action('template_redirect', 'thesis_redirect');

// WP process filters
add_filter('the_content', 'thesis_add_image_to_feed');
add_filter('thesis_comment_text', 'wptexturize');
add_filter('thesis_comment_text', 'convert_chars');
add_filter('thesis_comment_text', 'make_clickable', 9);
add_filter('thesis_comment_text', 'force_balance_tags', 25);
add_filter('thesis_comment_text', 'convert_smilies', 20);
add_filter('thesis_comment_text', 'wpautop', 30);

// Skin filters
add_filter('thesis_comments_link', 'default_skin_comments_link');
add_filter('thesis_edit_comment_link', 'default_skin_edit_comment_link');

// Construct the Thesis header
add_action('thesis_hook_before_header', 'thesis_nav_menu');
add_action('thesis_hook_header', 'thesis_default_header');

// Post hooks
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

// 404 page hooks
add_action('thesis_hook_404_title', 'thesis_404_title');
add_action('thesis_hook_404_content', 'thesis_404_content');

thesis_plugin_compatibility();
thesis_ie8_compatibility();