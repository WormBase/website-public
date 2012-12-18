<?php
/**
 * Outputs the Thesis Custom File Editor
 *
 * @package Thesis-Admin
 * @since 1.6
 */
?>

<div id="thesis_options" class="wrap<?php if (get_bloginfo('text_direction') == 'rtl') { echo ' rtl'; } ?>">
	<span id="thesis_version"><?php printf(__('You are rocking Thesis version <strong>%s</strong>', 'thesis'), thesis_version()); ?></span>
	<h2><?php _e('Thesis Custom File Editor', 'thesis'); ?></h2>
	<ul id="thesis_links">
		<li><a href="http://diythemes.com/answers/">DIYthemes Answers</a></li>
		<li><a href="http://diythemes.com/forums/">Support Forums</a></li>
		<li><a href="http://diythemes.com/thesis/rtfm/">User&#8217;s Guide</a></li>
		<li><a href="https://diythemes.com/affiliate-program/">Sell Thesis, Earn Cash!</a></li>
		<li><a href="http://diythemes.com/dev/">Thesis Dev Blog</a></li>
	</ul>

<?php 
	if ($_GET['updated']) {
?>
	<div id="updated" class="updated fade">
		<p><?php echo __('Custom file updated!', 'thesis') . ' <a href="' . get_bloginfo('url') . '/">' . __('Check out your site &rarr;', 'thesis') . '</a>'; ?></p>
	</div>

<?php 
	}
	elseif ($_GET['upgraded']) {
?>
	<div id="updated" class="updated fade">
		<p><?php echo __('Nicely done&#8212;Thesis <strong>' . thesis_version() . '</strong> is ready to rock. Take a moment to browse around the options panels and check out the new awesomeness, or simply <a href="' . get_bloginfo('url') . '/">check out your site now</a>.', 'thesis'); ?></p>
	</div>
<?php
	}

	global $thesis;
	
	if (version_compare($thesis['version'], thesis_version()) != 0) {
?>
	<form id="upgrade_needed" action="<?php echo admin_url('admin-post.php?action=thesis_upgrade'); ?>" method="post">
		<h3><?php _e('Oooh, Exciting!', 'thesis'); ?></h3>
		<p><?php _e('It&#8217;s time to upgrade your Thesis, which means there&#8217;s new awesomeness in your immediate future. Click the button below to fast-track your way to the awesomeness!', 'thesis'); ?></p>
		<p><input type="submit" class="upgrade_button" id="teh_upgrade" name="upgrade" value="<?php _e('Upgrade Thesis', 'thesis'); ?>" /></p>
	</form>
<?php
	}
	elseif (file_exists(THESIS_CUSTOM)) {
		// Determine which file we're editing. Default to something harmless, like custom.css.
		$file = ($_GET['file']) ? $_GET['file'] : 'custom.css';
		$extension = substr($file, strrpos($file, '.'));

		// Determine if the custom file exists and is writable. Otherwise, this page is useless.
		$error = thesis_is_custom_file_writable($file);

		if ($error)
			echo $error;
		else {
			// Get contents of custom.css
			if (filesize(THESIS_CUSTOM . '/' . $file) > 0) {
				$content = fopen(THESIS_CUSTOM . '/' . $file, 'r');
				$content = fread($content, filesize(THESIS_CUSTOM . '/' . $file));
				$content = htmlspecialchars($content);
			}
			else
				$content = '';
		}

		// Highlighting for which language?
		$lang = (function_exists('codepress_get_lang')) ? codepress_get_lang($file) : '';

		// Get list of available files
		$files = thesis_get_custom_files();
?>
	<div class="one_col">
		<form method="post" id="file-jump" name="file-jump" action="<?php echo admin_url('admin-post.php?action=thesis_file_editor'); ?>">
			<h3><?php printf(__('Currently editing: <code>%s</code>', 'thesis'), 'custom/' . $file); ?></h3>
<?php
		if (function_exists('use_codepress')) {
			if (use_codepress())
				echo "\t\t\t" . '<a class="syntax" id="codepress-off" href="admin.php?page=thesis-file-editor&amp;codepress=off&amp;file=' . $file . '">' . __('Disable syntax highlighting', 'thesis') . '</a>' . "\n";
			else
				echo "\t\t\t" . '<a class="syntax" id="codepress-on" href="admin.php?page=thesis-file-editor&amp;codepress=on&amp;file=' . $file . '">' . __('Enable syntax highlighting', 'thesis') . '</a></p>' . "\n";
		}
?>
			<p>
				<select id="custom_files" name="custom_files">
					<option value="<?php echo $file; ?>"><?php echo $file; ?></option>
<?php
		foreach ($files as $f) // An option for each available file
			if ($f != $file) echo "\t\t\t\t\t" . '<option value="' . $f . '">' . $f . '</option>' . "\n";
?>
				</select>
				<input type="submit" id="custom_file_jump" name="custom_file_jump" value="<?php _e('Edit selected file', 'thesis'); ?>" />
			</p>
<?php
		if ($extension == '.php')
			echo "\t\t\t" . '<p class="alert">' . __('<strong>Note:</strong> If you make a mistake in your code while modifying a <acronym title="PHP: Hypertext Preprocessor">PHP</acronym> file, saving this page <em>may</em> result your site becoming temporarily unusable. Prior to editing such files, be sure to have access to the file via <acronym title="File Transfer Protocol">FTP</acronym> or other means so that you can correct the error.', 'thesis') . '</p>' . "\n";
?>
		</form>
		<form class="file_editor" method="post" id="template" name="template" action="<?php echo admin_url('admin-post.php?action=thesis_file_editor'); ?>">
			<input type="hidden" id="file" name="file" value="<?php echo $file; ?>" />
			<p><textarea id="newcontent" name="newcontent" rows="25" cols="50" class="large-text codepress <?php echo $lang; ?>"><?php echo $content; ?></textarea></p>
			<p><input type="submit" class="save_button" id="custom_file_submit" name="custom_file_submit" value="<?php thesis_save_button_text(true); ?>" /></p>
		</form>
	</div>
<?php
	}
	else
		echo '<div class="warning">' . "\n\t" . '<p><strong>' . __('Attention!', 'thesis') . '</strong> ' . __('In order to edit your custom files, you&#8217;ll need to change the name of your <code>custom-sample</code> folder to <code>custom</code>.', 'thesis') . '</p>' . "\n" . '</div>' . "\n";
?>
</div>