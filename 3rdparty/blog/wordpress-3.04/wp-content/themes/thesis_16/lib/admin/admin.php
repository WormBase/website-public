<?php
/**
 * Adds Thesis controls and embellishments to the WordPress administration panel.
 *
 * @package Thesis-Admin
 */

function thesis_admin_setup() {
	add_action('admin_menu', 'thesis_add_options_pages');
	add_action('admin_post_thesis_options', 'thesis_save_options');
	add_action('admin_post_thesis_design_options', 'thesis_save_design_options');
	add_action('admin_post_thesis_upgrade', 'thesis_upgrade');
	add_action('admin_post_thesis_file_editor', 'thesis_save_custom_file');
	add_action('admin_menu', 'thesis_add_meta_boxes');
	add_action('init', 'thesis_options_head');
}

function thesis_add_options_pages() {
	add_menu_page(__('Thesis Options', 'thesis'), __('Thesis Options', 'thesis'), 'edit_themes', 'thesis-options', 'thesis_options_admin', THESIS_IMAGES_FOLDER . '/icon-swatch.png', 'top');
	add_submenu_page('thesis-options', __('Thesis Options', 'thesis'), __('Thesis Options', 'thesis'), 'edit_themes', 'thesis-options', 'thesis_options_admin');
	add_submenu_page('thesis-options', __('Design Options', 'thesis'), __('Design Options', 'thesis'), 'edit_themes', 'thesis-design-options', 'thesis_design_options_admin');
	add_submenu_page('thesis-options',__('Custom File Editor', 'thesis'), __('Custom File Editor', 'thesis'), 'edit_themes', 'thesis-file-editor', 'thesis_file_editor_admin');
}

function thesis_options_admin() {
	include (THESIS_ADMIN . '/thesis_options.php');
}

function thesis_design_options_admin() {
	include (THESIS_ADMIN . '/design_options.php');
}

function thesis_file_editor_admin() {
	include (THESIS_ADMIN . '/file_editor.php');
}

function thesis_add_meta_boxes() {
	$meta_boxes = thesis_meta_boxes();
	
	foreach ($meta_boxes as $meta_box) {
		add_meta_box($meta_box['id'], $meta_box['title'], $meta_box['function'], 'post', 'normal', 'high');
		add_meta_box($meta_box['id'], $meta_box['title'], $meta_box['function'], 'page', 'normal', 'high');
	}
	
	add_action('save_post', 'thesis_save_meta');
}

function thesis_options_head() {
	wp_enqueue_style('thesis-options-stylesheet', THESIS_CSS_FOLDER . '/options.css');

	if ($_GET['page'] == 'thesis-file-editor') {
		require_once(ABSPATH . 'wp-admin/includes/misc.php');
		
		if (function_exists('use_codepress'))
			wp_enqueue_script('codepress');
			
		if (use_codepress()) add_action('admin_print_footer_scripts', 'codepress_footer_js');
	}
	else {
		wp_enqueue_script('jquery-ui-core');
		wp_enqueue_script('jquery-ui-sortable');
		wp_enqueue_script('jquery-ui-tabs');
		wp_enqueue_script('thesis-admin-js', THESIS_SCRIPTS_FOLDER . '/thesis.js');

		if ($_GET['page'] == 'thesis-design-options')
			wp_enqueue_script('color-picker', THESIS_SCRIPTS_FOLDER . '/jscolor/jscolor.js');
	}
}

/*---:[ random admin file functions that will probably have a new home at some point as the theme grows ]:---*/

function thesis_is_css_writable() {
	if (file_exists(THESIS_CUSTOM)) {
		$location = '/thesis/custom/layout.css';
		$folder = false;
	}
	elseif (file_exists(TEMPLATEPATH . '/custom-sample')) {
		$location = '/thesis/custom-sample/layout.css';
		$folder = '<div class="warning">' . "\n\t" . '<p>' . __('<strong>Attention!</strong> In order to take advantage of all the controls that Thesis offers, you need to change the name of your <code>custom-sample</code> folder to <code>custom</code>.', 'thesis') . "</p>\n</div>\n";
	}

	if (!is_writable(THESIS_LAYOUT_CSS)) {
		echo '<div class="warning">' . "\n";
		echo '	<p><strong>' . __('Attention!', 'thesis') . '</strong> ' . __('Your <code>' . $location . '</code> file is not writable by the server, and in order to work the full extent of its magic, Thesis needs to be able to write to this file. All you have to do is set your <code>layout.css</code> file permissions to 666, and you\'ll be good to go. After setting your file permissions, you should head to the <a href="' . get_bloginfo('wpurl') . '/wp-admin/admin.php?page=thesis-design-options">Design Options</a> page and hit the save button.', 'thesis') . '</p>' . "\n";
		echo '</div>' . "\n";
	}

	if ($folder) echo $folder;
}

function thesis_is_custom_file_writable($file) {
	$files = thesis_get_custom_files(); // Get list of custom files

	if (!in_array($file, $files))
		$error = '	<p><strong>' . __('Attention!', 'thesis') . '</strong> ' . __('For security reasons, the file you are attempting to edit cannot be modified via this screen.', 'thesis') . '</p>' . "\n";
	elseif (!file_exists(THESIS_CUSTOM)) // The custom/ directory does not exist
		$error = '	<p><strong>' . __('Attention!', 'thesis') . '</strong> ' . __('Your <code>custom/</code> directory does not appear to exist. Have you remembered to rename <code>/custom-sample</code>?', 'thesis') . '</p>' . "\n";
	elseif (!is_file(THESIS_CUSTOM . '/' . $file)) // The selected file does not exist
		$error = '	<p><strong>' . __('Attention!', 'thesis') . '</strong> ' . __('The file you are attempting does not appear to exist.', 'thesis') . '</p>' . "\n";
	elseif (!is_writable(THESIS_CUSTOM . '/custom.css')) // The selected file is not writable
		$error = '	<p><strong>' . __('Attention!', 'thesis') . '</strong> ' . sprintf(__('Your <code>/custom/%s</code> file is not writable by the server, and in order to modify the file via the admin panel, Thesis needs to be able to write to this file. All you have to do is set this file&#8217;s permissions to 666, and you&#8217;ll be good to go.', 'thesis'), $file) . '</p>' . "\n";

	if ($error) { // Return the error + markup, if required
		$error = '<div class="warning">' . "\n" . $error . '</div>' . "\n";
		return $error;
	}

	return false;
}

function thesis_massage_code($code) {
 	echo htmlentities(stripslashes($code), ENT_COMPAT);
}

function thesis_save_button_text($display = false) {
	global $thesis;
	$save_button_text = ($thesis['save_button_text']) ? strip_tags(stripslashes($thesis['save_button_text'])) : __('Big Ass Save Button', 'thesis');
	
	if ($display)
		echo $save_button_text;
	else
		return $save_button_text;
}

/**
 * function thesis_save_custom_file
 *
 * Handles saving of custom files edited in the Thesis file editor
 *
 * @since 1.6
 */
function thesis_save_custom_file() {
	if (!current_user_can('edit_themes'))
		wp_die(__('Easy there, homey. You don&#8217;t have admin privileges to access theme options.', 'thesis'));
	
	if (isset($_POST['custom_file_submit'])) {
		$contents = stripslashes($_POST['newcontent']); // Get new custom content
		$file = $_POST['file']; // Which file?
		$allowed_files = thesis_get_custom_files(); // Get list of allowed files

		if (!in_array($file, $allowed_files)) // Is the file allowed? If not, get outta here!
			wp_die(__('You have attempted to modify an ineligible file. Only files within the Thesis <code>/custom</code> folder may be modified via this interface. Thank you.', 'thesis'));

		$file_open = fopen(THESIS_CUSTOM . '/' . $file, 'w+'); // Open the file

		if ($file_open !== false) // If possible, write new custom file
			fwrite($file_open, $contents);

		fclose($file_open); // Close the file
		$updated = '&updated=true'; // Display updated message
	}

	if (isset($_POST['custom_file_jump'])) {
		$file = $_POST['custom_files'];
		$updated = '';
	}

	wp_redirect(admin_url('admin.php?page=thesis-file-editor' . $updated . '&file=' . $file));
}

/**
 * function thesis_get_custom_files()
 *
 * Returns an array of available files from within custom/.
 *
 * @since 1.6
 */
function thesis_get_custom_files() {
	$files = array();
	$directory = opendir(THESIS_CUSTOM); // Open the directory
	$exts = array('.php', '.css', '.js', '.txt', '.inc', '.htaccess', '.html', '.htm'); // What type of files do we want?

	while ($file = readdir($directory)) { // Read the files
		if ($file != '.' && $file != '..') { // Only list files within the _current_ directory
			$extension = substr($file, strrpos($file, '.')); // Get the extension of the file
		
			if ($extension && in_array($extension, $exts)) // Verify extension of the file; we can't edit images!
				$files[] = $file; // Add the file to the array
		}
	}

	closedir($directory); // Close the directory
	return $files; // Return the array of editable files
}