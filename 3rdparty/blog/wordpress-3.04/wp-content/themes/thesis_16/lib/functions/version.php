<?php

function thesis_upgrade() {
	global $thesis;
	global $thesis_design;

	if (version_compare($thesis['version'], thesis_version(), '<')) {
		thesis_upgrade_options();
		thesis_upgrade_design_options();
		thesis_generate_css();
	}
	elseif (!isset($thesis_design['nav']['link']['parent'])) {
		thesis_upgrade_design_options();
		thesis_generate_css();
	}

	wp_redirect(admin_url('admin.php?page=thesis-options&upgraded=true'));
}

function thesis_version() {
	$theme_data = get_theme_data(TEMPLATEPATH . '/style.css');
	$version = trim($theme_data['Version']);
	return $version;
}

function thesis_wp_version_check() {
	global $wp_version;
	$new_admin_version = '2.7';
	$installed_version = $wp_version;
	
	if (version_compare($installed_version, $new_admin_version, '<'))
		return false;
	else
		return true;
}

function thesis_logout_url() {
	if (!thesis_wp_version_check())
		return get_option('siteurl') . '/wp-login.php?action=logout';
	else
		return wp_logout_url(get_permalink());
}