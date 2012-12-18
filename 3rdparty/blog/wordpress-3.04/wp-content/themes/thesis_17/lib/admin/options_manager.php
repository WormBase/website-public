<?php
/**
 * class thesis_options_manager
 *
 * @package Thesis
 * @since 1.7
 */
class thesis_options_manager {
	function add_js() {
		wp_enqueue_script('confirm-restore', THESIS_SCRIPTS_FOLDER . '/confirm.js'); #wp
	}

	function manage_options() {
		if (isset($_GET['download'])) {
			if ($_GET['download'] == 'site') {
				header("Cache-Control: public, must-revalidate");
				header("Pragma: hack");
				header("Content-Type: text/plain");
				header('Content-Disposition: attachment; filename="thesis-site-options-' . date("Ymd") . '.dat"');

				$site_options = new thesis_site_options;
				$site_options->get_options();

				echo serialize($site_options);
				exit();
			}
			elseif ($_GET['download'] == 'design') {
				header("Cache-Control: public, must-revalidate");
				header("Pragma: hack");
				header("Content-Type: text/plain");
				header('Content-Disposition: attachment; filename="thesis-design-options-' . date("Ymd") . '.dat"');

				$design_options = new thesis_design_options;
				$design_options->get_options();

				echo serialize($design_options);
				exit();
			}
			elseif ($_GET['download'] == 'pages') {
				header("Cache-Control: public, must-revalidate");
				header("Pragma: hack");
				header("Content-Type: text/plain");
				header('Content-Disposition: attachment; filename="thesis-page-options-' . date("Ymd") . '.dat"');

				$page_options = new thesis_page_options;
				$page_options->get_options();

				echo serialize($page_options);
				exit();
			}
			elseif ($_GET['download'] == 'all') {
				header("Cache-Control: public, must-revalidate");
				header("Pragma: hack");
				header("Content-Type: text/plain");
				header('Content-Disposition: attachment; filename="thesis-all-options-' . date("Ymd") . '.dat"');

				$site_options = new thesis_site_options;
				$site_options->get_options();
				$design_options = new thesis_design_options;
				$design_options->get_options();
				$page_options = new thesis_page_options;
				$page_options->get_options();

				echo (serialize(array('site_options' => $site_options, 'design_options' => $design_options, 'page_options' => $page_options)));
				exit();
			}
		}
		elseif (isset($_GET['restore'])) {
			if ($_GET['restore'] == 'site') {
				$default_site_options = new thesis_site_options;
				$default_site_options->default_options();

				update_option('thesis_options', $default_site_options); #wp
				wp_redirect(admin_url('admin.php?page=options-manager&restored=true&type=Site')); #wp
			}
			elseif ($_GET['restore'] == 'design') {
				$default_design_options = new thesis_design_options;
				$default_design_options->default_options();

				update_option('thesis_design_options', $default_design_options); #wp
				thesis_generate_css();
				wp_redirect(admin_url('admin.php?page=options-manager&restored=true&type=Design')); #wp
			}
			elseif ($_GET['restore'] == 'pages') {
				$default_page_options = new thesis_page_options;
				$default_page_options->default_options();

				update_option('thesis_pages', $default_page_options); #wp
				wp_redirect(admin_url('admin.php?page=options-manager&restored=true&type=Page')); #wp
			}
			elseif ($_GET['restore'] == 'all') {
				$default_site_options = new thesis_site_options;
				$default_site_options->default_options();
				$default_design_options = new thesis_design_options;
				$default_design_options->default_options();
				$default_page_options = new thesis_page_options;
				$default_page_options->default_options();

				update_option('thesis_options', $default_site_options); #wp
				update_option('thesis_design_options', $default_design_options); #wp
				update_option('thesis_pages', $default_page_options); #wp
				thesis_generate_css();
				wp_redirect(admin_url('admin.php?page=options-manager&restored=true&type=All')); #wp
			}
		}
		elseif (isset($_POST['upload'])) {
			if ($_POST['upload'] == 'site') {
				if (strpos($_FILES['file']['name'], 'thesis-site-options') === false)
					wp_redirect(admin_url('admin.php?page=options-manager&type=Site&error=wrongfile')); #wp
				elseif ($_FILES['file']['error'] > 0)
					wp_redirect(admin_url('admin.php?page=options-manager&type=Site&error=file')); #wp
				else {
					$raw_options = file_get_contents($_FILES['file']['tmp_name']);
					$site_options = new thesis_site_options;
					$site_options = unserialize($raw_options);

					if (is_object($site_options)) update_option('thesis_options', $site_options); #wp

					if (function_exists('wp_cache_clean_cache')) { #wp
						global $file_prefix;
						wp_cache_clean_cache($file_prefix);
					}

					wp_redirect(admin_url('admin.php?page=options-manager&imported=true&type=Site')); #wp
				}
			}
			elseif ($_POST['upload'] == 'design') {
				if (strpos($_FILES['file']['name'], 'thesis-design-options') === false)
					wp_redirect(admin_url('admin.php?page=options-manager&type=Design&error=wrongfile')); #wp
				elseif ($_FILES['file']['error'] > 0)
					wp_redirect(admin_url('admin.php?page=options-manager&type=Design&error=file')); #wp
				else {
					$raw_options = file_get_contents($_FILES['file']['tmp_name']);
					$design_options = new thesis_design_options;
					$design_options = unserialize($raw_options);

					if (is_object($design_options)) update_option('thesis_design_options', $design_options); #wp

					if (function_exists('wp_cache_clean_cache')) { #wp
						global $file_prefix;
						wp_cache_clean_cache($file_prefix);
					}

					thesis_generate_css();
					wp_redirect(admin_url('admin.php?page=options-manager&imported=true&type=Design')); #wp
				}
			}
			elseif ($_POST['upload'] == 'pages') {
				if (strpos($_FILES['file']['name'], 'thesis-page-options') === false)
					wp_redirect(admin_url('admin.php?page=options-manager&type=Page&error=wrongfile')); #wp
				elseif ($_FILES['file']['error'] > 0)
					wp_redirect(admin_url('admin.php?page=options-manager&type=Page&error=file')); #wp
				else {
					$raw_options = file_get_contents($_FILES['file']['tmp_name']);
					$page_options = new thesis_page_options;
					$page_options = unserialize($raw_options);

					if (is_object($page_options)) update_option('thesis_pages', $page_options); #wp

					if (function_exists('wp_cache_clean_cache')) { #wp
						global $file_prefix;
						wp_cache_clean_cache($file_prefix);
					}

					thesis_generate_css();
					wp_redirect(admin_url('admin.php?page=options-manager&imported=true&type=Page')); #wp
				}
			}
			elseif ($_POST['upload'] == 'all') {
				if (strpos($_FILES['file']['name'], 'thesis-all-options') === false)
					wp_redirect(admin_url('admin.php?page=options-manager&type=All&error=wrongfile')); #wp
				elseif ($_FILES['file']['error'] > 0)
					wp_redirect(admin_url('admin.php?page=options-manager&type=All&error=file')); #wp
				else {
					$raw_options = file_get_contents($_FILES['file']['tmp_name']);
					$all_options = unserialize($raw_options);
					$site_options = new thesis_site_options;
					$design_options = new thesis_design_options;
					$page_options = new thesis_page_options;
					$site_options = $all_options['site_options'];
					$design_options = $all_options['design_options'];
					$page_options = $all_options['page_options'];

					if (is_object($site_options)) update_option('thesis_options', $site_options); #wp
					if (is_object($design_options)) update_option('thesis_design_options', $design_options); #wp
					if (is_object($page_options)) update_option('thesis_pages', $page_options); #wp

					if (function_exists('wp_cache_clean_cache')) { #wp
						global $file_prefix;
						wp_cache_clean_cache($file_prefix); #wp
					}

					thesis_generate_css();
					wp_redirect(admin_url('admin.php?page=options-manager&imported=true&type=All')); #wp
				}
			}
		}
	}
	
	function status_check() {
		if ($_GET['error'] == 'file') {
			echo "\t\t<div id=\"updated\" class=\"warning\">\n";
			echo "\t\t\t<p>" . sprintf(__('<strong>Oh noez!</strong> There was an error with the file upload. Please try it again, or else download a new, valid %s Options file.', 'thesis'), $_GET['type']) . "</p>\n";
			echo "\t\t</div>\n";
		}
		elseif ($_GET['error'] == 'wrongfile') {
			echo "\t\t<div id=\"updated\" class=\"warning\">\n";
			echo "\t\t\t<p>" . sprintf(__('<strong>Whoops!</strong> The file you attempted to upload is not a valid %1$s Options file. Please try uploading the file again, or else download a new, valid %1$s Options file.', 'thesis'), $_GET['type']) . "</p>\n";
			echo "\t\t</div>\n";
		}
		elseif ($_GET['restored']) {
			$options = ($_GET['type'] == 'All') ? 'All default Thesis options' : 'Default ' . $_GET['type'] . ' Options';
			echo "\t\t<div id=\"updated\" class=\"updated fade\">\n";
			echo "\t\t\t<p>" . sprintf(__('%1$s restored! <a href="%2$s">Check out your site &rarr;</a>', 'thesis'), $options, get_bloginfo('url')) . "</p>\n"; #wp
			echo "\t\t</div>\n";
		}
		elseif ($_GET['imported']) {
			echo "\t\t<div id=\"updated\" class=\"updated fade\">\n";
			echo "\t\t\t<p>" . sprintf(__('%1$s Options imported! <a href="%2$s">Check out your site &rarr;</a>', 'thesis'), $_GET['type'], get_bloginfo('url')) . "</p>\n"; #wp
			echo "\t\t</div>\n";
		}
	}

	function options_page() {
		$rtl = (get_bloginfo('text_direction') == 'rtl') ? ' rtl' : ''; #wp
		echo "<div id=\"thesis_options\" class=\"wrap$rtl\">\n";

		thesis_version_indicator();
		thesis_options_title(__('Thesis Options Manager', 'thesis'), false);
		thesis_options_nav();
		thesis_options_status_check();
		
		thesis_options_manager::status_check();
?>
	<div class="options_column">
		<div class="options_module positive" id="download-thesis-options">
			<h3><?php _e('Download Options', 'thesis'); ?></h3>
			<div class="module_subsection">
				<h4><?php _e('Site Options', 'thesis'); ?></h4>
				<p class="add_extra_margin"><a class="action_button" href="<?php echo admin_url('admin.php?page=options-manager&amp;download=site'); ?>">Download Site Options</a></p>
			</div>
			<div class="module_subsection">
				<h4><?php _e('Design Options', 'thesis'); ?></h4>
				<p class="add_extra_margin"><a class="action_button" href="<?php echo admin_url('admin.php?page=options-manager&amp;download=design'); ?>">Download Design Options</a></p>
			</div>
			<div class="module_subsection">
				<h4><?php _e('Page Options', 'thesis'); ?></h4>
				<p class="add_extra_margin"><a class="action_button" href="<?php echo admin_url('admin.php?page=options-manager&amp;download=pages'); ?>">Download Page Options</a></p>
			</div>
			<div class="module_subsection">
				<h4><?php _e('All Options', 'thesis'); ?></h4>
				<p><a class="action_button" href="<?php echo admin_url('admin.php?page=options-manager&amp;download=all'); ?>">Download All Options</a></p>
			</div>
		</div>
	</div>
	<div class="options_column">
		<div class="options_module positive" id="upload-thesis-options">
			<h3><?php _e('Upload Options', 'thesis'); ?></h3>
			<div class="module_subsection">
				<h4><?php _e('Site Options', 'thesis'); ?></h4>
				<form method="post" enctype="multipart/form-data">
					<input type="hidden" name="upload" value="site" />
					<p class="form_input">
						<input type="file" class="text_input" name="file" id="options-file" />
						<label for="file">upload <strong>Thesis Site Options</strong> file</label>
					</p>
					<p class="upload_button"><input type="submit" value="Upload" onclick="return confirm_choice('upload', 'Site');" /></p>
				</form>
			</div>
			<div class="module_subsection">
				<h4><?php _e('Design Options', 'thesis'); ?></h4>
				<form method="post" enctype="multipart/form-data">
					<input type="hidden" name="upload" value="design" />
					<p class="form_input">
						<input type="file" class="text_input" name="file" id="design-options-file" />
						<label for="file">upload <strong>Thesis Design Options</strong> file</label>
					</p>
					<p class="upload_button"><input type="submit" value="Upload" onclick="return confirm_choice('upload', 'Design');" /></p>
				</form>
			</div>
			<div class="module_subsection">
				<h4><?php _e('Page Options', 'thesis'); ?></h4>
				<form method="post" enctype="multipart/form-data">
					<input type="hidden" name="upload" value="pages" />
					<p class="form_input">
						<input type="file" class="text_input" name="file" id="page-options-file" />
						<label for="file">upload <strong>Thesis Page Options</strong> file</label>
					</p>
					<p class="upload_button"><input type="submit" value="Upload" onclick="return confirm_choice('upload', 'Page');" /></p>
				</form>
			</div>
			<div class="module_subsection">
				<h4><?php _e('All Options', 'thesis'); ?></h4>
				<form method="post" enctype="multipart/form-data">
					<input type="hidden" name="upload" value="all" />
					<p class="form_input">
						<input type="file" class="text_input" name="file" id="all-options-file" />
						<label for="file">upload <strong>Thesis All Options</strong> file</label>
					</p>
					<p class="upload_button"><input type="submit" value="Upload" onclick="return confirm_choice('upload', 'All');" /></p>
				</form>
			</div>
		</div>
	</div>
	<div class="options_column">
		<div class="options_module negative" id="default-thesis-options">
			<h3><?php _e('Restore Default Options', 'thesis'); ?></h3>
			<div class="module_subsection">
				<h4><?php _e('Site Options', 'thesis'); ?></h4>
				<p class="add_extra_margin"><a class="action_button" href="<?php echo admin_url('admin.php?page=options-manager&amp;restore=site'); ?>" onclick="return confirm_choice('default', 'Site');">Restore Default Site Options</a></p>
			</div>
			<div class="module_subsection">
				<h4><?php _e('Design Options', 'thesis'); ?></h4>
				<p class="add_extra_margin"><a class="action_button" href="<?php echo admin_url('admin.php?page=options-manager&amp;restore=design'); ?>" onclick="return confirm_choice('default', 'Design');">Restore Default Design Options</a></p>
			</div>
			<div class="module_subsection">
				<h4><?php _e('Page Options', 'thesis'); ?></h4>
				<p class="add_extra_margin"><a class="action_button" href="<?php echo admin_url('admin.php?page=options-manager&amp;restore=pages'); ?>" onclick="return confirm_choice('default', 'Page');">Restore Default Page Options</a></p>
			</div>
			<div class="module_subsection">
				<h4><?php _e('All Options', 'thesis'); ?></h4>
				<p><a class="action_button" href="<?php echo admin_url('admin.php?page=options-manager&amp;restore=all'); ?>" onclick="return confirm_choice('default', 'All');">Restore All Default Options</a></p>
			</div>
		</div>
	</div>
<?php		
		echo "</div>\n";
	}
}