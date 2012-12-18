<?php
// These are needed for upgrades, which is a real pisser.
class Options { }
class Design { }

function thesis_upgrade() {
	global $thesis_site, $thesis_design, $thesis_pages;

	if (version_compare($thesis_site->version, thesis_version(), '<')) {
		$thesis_site->upgrade_options();
		$thesis_design->upgrade_options();
		$thesis_pages->upgrade_options();
		thesis_generate_css();
	}

	wp_redirect(admin_url('admin.php?page=thesis-options&upgraded=true')); #wp
}

function thesis_version() {
	$theme_data = get_theme_data(TEMPLATEPATH . '/style.css'); #wp
	$version = trim($theme_data['Version']);
	return $version;
}

function thesis_wp_version_check() {
	global $wp_version; #wp
	$new_admin_version = '2.7';
	$installed_version = $wp_version; #wp
	return (version_compare($installed_version, $new_admin_version, '<')) ? false : true;
}

function thesis_logout_url() {
	return (!thesis_wp_version_check()) ? get_option('siteurl') . '/wp-login.php?action=logout' : wp_logout_url(get_permalink()); #wp
}