<?php

function thesis_ie8_compatibility() {
	$browser = $_SERVER['HTTP_USER_AGENT'];
	
	if (preg_match("/MSIE 8.0/", $browser) && !is_admin())
		header('X-UA-Compatible: IE=EmulateIE7');
}

// Thesis legacy compatibility begins beneath this line!
function thesis_custom_field_keys() {
	$custom_field_keys = array(
		'image' => 'image',
		'video' => 'video',
		'html' => 'custom',
		'thumbnail' => 'thumb',
		'meta' => 'meta',
		'keywords' => 'keywords',
		'slug' => 'slug'
	);
	
	return apply_filters('thesis_custom_field_keys', $custom_field_keys);
}

function thesis_get_custom_field_key($field_name) {
	$custom_field_keys = thesis_custom_field_keys();

	foreach ($custom_field_keys as $field => $key) {
		if (($field == $field_name) && $key)
			return $key;
		elseif ($field == $field_name)
			return $field;
	}
}

// Plugin compatibility begins beneath this line!
function thesis_subscribe_to_comments_compatibility() {
	if (function_exists('show_subscription_checkbox'))
		add_action('thesis_hook_comment_form', 'show_subscription_checkbox');
}