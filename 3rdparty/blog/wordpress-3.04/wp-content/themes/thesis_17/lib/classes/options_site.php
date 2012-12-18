<?php
/**
 * class thesis_site_options (formerly called Options)
 *
 * This class consists of functions used to set and retrieve the different site options
 * available on the Thesis Theme. The WordPress API saves everything to your database,
 * but the rest of the magic occurs in functions native to this class. To set your
 * options, enter your WordPress dashboard and visit: Thesis -> Thesis Options
 * Or, if you prefer, you can visit /wp-admin/admin.php?page=thesis-options
 *
 * @package Thesis
 * @since 1.0
 */

class thesis_site_options {
	function default_options() {
		// Document head
		$this->head = array(
			'title' => array(
				'branded' => false,
				'separator' => false
			),
			'meta' => array(
				'robots' => array(
					'noindex' => array(
						'sub' => true,
						'category' => false,
						'tag' => true,
						'author' => true,
						'day' => true,
						'month' => true,
						'year' => true
					),
					'nofollow' => array(
						'sub' => false,
						'category' => false,
						'tag' => true,
						'author' => true,
						'day' => true,
						'month' => true,
						'year' => true
					),
					'noarchive' => array(
						'sub' => false,
						'category' => false,
						'tag' => false,
						'author' => false,
						'day' => false,
						'month' => false,
						'year' => false
					),
					'noodp' => true,
					'noydir' => true
				)
			),
			'links' => array(
				'canonical' => true
			),
			'feed' => array(
				'url' => false
			),
			'scripts' => false
		);

		$this->javascript = array(
			'scripts' => false
		);

		// Nav menu
		$this->nav = array(
			'submenu_width' => 150,
			'border' => 1,
			'pages' => false,
			'categories' => false,
			'links' => false,
			'home' => array(
				'show' => true,
				'text' => false,
				'nofollow' => false
			),
			'feed' => array(
				'show' => true,
				'text' => false,
				'nofollow' => true
			)
		);

		// Comments
		$this->comments = array(
			'disable_pages' => false,
			'show_closed' => true
		);

		// Display options
		$this->display = array(
		 	'header' => array(
				'title' => true,
				'tagline' => true
			),
			'byline' => array(
				'author' => array(
					'show' => true,
					'link' => false,
					'nofollow' => false
				),
				'date' => array(
					'show' => true
				),
				'num_comments' => array(
					'show' => false
				),
				'categories' => array(
					'show' => false
				),
				'page' => array(
					'author' => false,
					'date' => false
				)
			),
			'posts' => array(
				'excerpts' => false,
				'read_more_text' => false,
				'nav' => true
			),
			'archives' => array(
				'style' => 'titles'
			),
			'tags' => array(
				'single' => true,
				'index' => false,
				'nofollow' => true
			),
			'sidebars' => array(
				'default_widgets' => true
			),
			'admin' => array(
				'edit_post' => true,
				'edit_comment' => true,
				'link' => true
			)
		);

		// Save button text
		$this->save_button_text = false;

		// Thesis version
		$this->version = thesis_version();
	}

	function get_options() {
		$saved_options = maybe_unserialize(get_option('thesis_options'));

		if (!empty($saved_options) && is_object($saved_options)) {
			foreach ($saved_options as $option_name => $value)
				$this->$option_name = $value;
		}
	}
	
	function update_options() {
		// Document head
		$head = $_POST['head'];
		$this->head['title']['branded'] = (bool) $head['title']['branded'];
		$this->head['title']['separator'] = ($head['title']['separator']) ? urlencode(strip_tags(stripslashes($head['title']['separator']))) : false;
		$meta_types = array('noindex', 'nofollow', 'noarchive');
		$page_types = array('sub', 'category', 'tag', 'author', 'day', 'month', 'year');
		foreach ($meta_types as $meta_type) {
			foreach ($page_types as $page_type)
				$this->head['meta']['robots'][$meta_type][$page_type] = (bool) $head['meta']['robots'][$meta_type][$page_type];
		}
		$this->head['meta']['robots']['noodp'] = (bool) $head['meta']['robots']['noodp'];
		$this->head['meta']['robots']['noydir'] = (bool) $head['meta']['robots']['noydir'];
		$this->head['links']['canonical'] = (bool) $head['links']['canonical'];
		$this->head['feed']['url'] = ($head['feed']['url']) ? strip_tags(stripslashes($head['feed']['url'])) : false;
		$this->head['scripts'] = ($head['scripts']) ? $head['scripts'] : false;

		// JavaScript
		$javascript = $_POST['javascript'];
		$this->javascript['scripts'] = ($javascript['scripts']) ? $javascript['scripts'] : false;

		// Nav menu
		$nav = $_POST['nav'];
		if ($nav['pages']) {
			$this->nav['pages'] = $nav['pages'];
			foreach ($nav['pages'] as $id => $nav_page) {
				$this->nav['pages'][$id]['show'] = (bool) $nav_page['show'];
				$this->nav['pages'][$id]['text'] = ($nav_page['text'] != '') ? stripslashes($nav_page['text']) : false;
			}
		}
		$this->nav['style'] = (bool) $nav['style'];
		$this->nav['categories'] = ($nav['categories']) ? implode(',', $nav['categories']) : false;
		$this->nav['links'] = ($nav['links']) ? $nav['links'] : false;
		$this->nav['home']['show'] = (bool) $nav['home']['show'];
		$this->nav['home']['text'] = ($nav['home']['text']) ? stripslashes($nav['home']['text']) : false;
		$this->nav['home']['nofollow'] = (bool) $nav['home']['nofollow'];
		$this->nav['feed']['show'] = (bool) $nav['feed']['show'];
		$this->nav['feed']['text'] = ($nav['feed']['text']) ? stripslashes($nav['feed']['text']) : false;
		$this->nav['feed']['nofollow'] = (bool) $nav['feed']['nofollow'];

		// Comment options
		$comments = $_POST['comments'];
		$this->comments['disable_pages'] = (bool) $comments['disable_pages'];
		$this->comments['show_closed'] = (bool) $comments['show_closed'];

		// Display options
		$display = $_POST['display'];
		$this->display['header']['title'] = (bool) $display['header']['title'];
		$this->display['header']['tagline'] = (bool) $display['header']['tagline'];
		$this->display['byline']['author']['show'] = (bool) $display['byline']['author']['show'];
		$this->display['byline']['author']['link'] = (bool) $display['byline']['author']['link'];
		$this->display['byline']['author']['nofollow'] = (bool) $display['byline']['author']['nofollow'];
		$this->display['byline']['date']['show'] = (bool) $display['byline']['date']['show'];
		$this->display['byline']['page']['author'] = (bool) $display['byline']['page']['author'];
		$this->display['byline']['page']['date'] = (bool) $display['byline']['page']['date'];
		$this->display['byline']['num_comments']['show'] = (bool) $display['byline']['num_comments']['show'];
		$this->display['byline']['categories']['show'] = (bool) $display['byline']['categories']['show'];
		$this->display['posts']['excerpts'] = (bool) $display['posts']['excerpts'];
		$this->display['posts']['read_more_text'] = ($display['posts']['read_more_text']) ? urlencode(stripslashes($display['posts']['read_more_text'])) : false;
		$this->display['posts']['nav'] = (bool) $display['posts']['nav'];
		$this->display['archives']['style'] = ($display['archives']['style']) ? $display['archives']['style'] : 'titles';
		$this->display['tags']['single'] = (bool) $display['tags']['single'];
		$this->display['tags']['index'] = (bool) $display['tags']['index'];
		$this->display['tags']['nofollow'] = (bool) $display['tags']['nofollow'];
		$this->display['sidebars']['default_widgets'] = (bool) $display['sidebars']['default_widgets'];
		$this->display['admin']['edit_post'] = (bool) $display['admin']['edit_post'];
		$this->display['admin']['edit_comment'] = (bool) $display['admin']['edit_comment'];
		$this->display['admin']['link'] = (bool) $display['admin']['link'];

		// Misc. options
		$this->save_button_text = ($_POST['save_button_text']) ? strip_tags(stripslashes($_POST['save_button_text'])) : false;
	}
	
	function save_options() {
		if (!current_user_can('edit_themes'))
			wp_die(__('Easy there, homey. You don&#8217;t have admin privileges to access theme options.', 'thesis'));

		if (isset($_POST['submit'])) {
			$site_options = new thesis_site_options;
			$site_options->get_options();
			$site_options->update_options();
			update_option('thesis_options', $site_options);
		}

		wp_redirect(admin_url('admin.php?page=thesis-options&updated=true'));
	}
	
	function upgrade_options() {
		$site_options = new thesis_site_options;
		$site_options->get_options();

		$default_site_options = new thesis_site_options;
		$default_site_options->default_options();

		$design_options = new thesis_design_options;
		$design_options->get_options();

		$default_design_options = new thesis_design_options;
		$default_design_options->default_options();

		// This is necessary for the 1.7 upgrade
		$page_options = new thesis_page_options;
		$page_options->default_options();

		// Begin code to upgrade all Thesis Options to the newest data structures
		if (isset($site_options->multimedia_box))
			$multimedia_box = $site_options->multimedia_box;
		if (isset($design_options->home_layout)) {
			if ($design_options->home_layout) {
				$features = $design_options->teasers;
				unset($design_options->teasers);
			}
			else
				$features = get_option('posts_per_page');
		}

		// If any new data structures have been introduced, incorporate them now
		foreach ($default_site_options as $option_name => $value) {
			if (!isset($site_options->$option_name)) 
				$site_options->$option_name = $default_site_options->$option_name;
		}

		foreach ($default_design_options as $option_name => $value) {
			if (!isset($design_options->$option_name))
				$design_options->$option_name = $value;
		}

		// Home page options 1.7 upgrade
		if (isset($site_options->home)) {
			if (isset($site_options->home['meta']['description']))
				$page_options->home['head']['meta']['description'] = $site_options->home['meta']['description'];
			elseif (isset($site_options->head['meta']['description']))
				$page_options->home['head']['meta']['description'] = $site_options->head['meta']['description'];
			if (isset($site_options->home['meta']['keywords']))
				$page_options->home['head']['meta']['keywords'] = $site_options->home['meta']['keywords'];
			elseif (isset($site_options->head['meta']['keywords']))
				$page_options->home['head']['meta']['keywords'] = $site_options->head['meta']['keywords'];
			if (isset($site_options->home['features']))
				$page_options->home['body']['content']['features'] = $site_options->home['features'];

			update_option('thesis_pages', $page_options); // Save upgraded page options
		}
		else {
			if (isset($site_options->meta_description)) {
				$page_options->home['head']['meta']['description'] = $site_options->meta_description;
				update_option('thesis_pages', $page_options);
			}
			if (isset($site_options->meta_keywords)) {
				$page_options->home['head']['meta']['keywords'] = $site_options->meta_keywords;
				update_option('thesis_pages', $page_options);
			}
		}

		if (isset($design_options->layout['home'])) {
			if ($design_options->layout['home'] == 'teasers') {
				$page_options->home['body']['content']['features'] = ($design_options->teasers['features']) ? $design_options->teasers['features'] : 2;
				unset ($design_options->teasers['features']);
			}
			else
				$page_options->home['body']['content']['features'] = get_option('posts_per_page');

			foreach ($design_options->layout as $layout_var => $value) {
				if ($layout_var != 'home')
					$new_layout[$layout_var] = $value;
			}

			if ($new_layout)
				$design_options->layout = $new_layout;

			update_option('thesis_pages', $page_options); // Save upgraded page options
		}
		elseif (isset($features)) {
			$page_options->home['body']['content']['features'] = $features;
			update_option('thesis_pages', $page_options); // Save upgraded page options
		}

		// Updated $head array for 1.7
		if (isset($site_options->head['title']['title']) || isset($site_options->head['title']['tagline'])) {
			$separator = ($site_options->head['title']['separator']) ? urldecode($site_options->head['title']['separator']) : '&#8212;';

			if ($site_options->head['title']['title'] && $site_options->head['title']['tagline'])
				$title = ($site_options->head['title']['tagline_first']) ? get_bloginfo('description') . " $separator " . get_bloginfo('name') : get_bloginfo('name') . " $separator " . get_bloginfo('description');
			elseif ($site_options->head['title']['title'])
				$title = get_bloginfo('name');
			else
				$title = get_bloginfo('description');

			$page_options->home['head']['title'] = urlencode($title);
			update_option('thesis_pages', $page_options); // Save upgraded page options
			unset($site_options->head['title']['title'], $site_options->head['title']['tagline'], $site_options->head['title']['tagline_first']);
		}
		if (isset($site_options->head['noindex'])) {
			$site_options->head['meta']['robots']['noindex'] = $site_options->head['meta']['robots']['nofollow'] = $site_options->head['noindex'];
			$site_options->head['meta']['robots']['noindex']['sub'] = true;
			unset($site_options->head['noindex']);
		}
		if (!isset($site_options->head['meta']['robots']['nofollow']))
			$site_options->head['meta']['robots']['nofollow'] = $default_site_options->head['meta']['robots']['nofollow'];
		if (!isset($site_options->head['meta']['robots']['noarchive']))
			$site_options->head['meta']['robots']['noarchive'] = $default_site_options->head['meta']['robots']['noarchive'];
		if (!isset($site_options->head['meta']['robots']['noodp']))
			$site_options->head['meta']['robots']['noodp'] = $default_site_options->head['meta']['robots']['noodp'];
		if (!isset($site_options->head['meta']['robots']['noydir']))
			$site_options->head['meta']['robots']['noydir'] = $default_site_options->head['meta']['robots']['noydir'];
		if (isset($site_options->head['canonical'])) {
			$site_options->head['links']['canonical'] = $site_options->head['canonical'];
			unset($site_options->head['canonical']);
		}
		if (isset($site_options->head['version']))
			unset($site_options->head['version']);
		if ($site_options->feed['url'])
			$site_options->head['feed']['url'] = $site_options->feed['url'];
		elseif (isset($site_options->feed_url))
			$site_options->head['feed']['url'] = $site_options->feed_url;
		if (isset($site_options->scripts)) {
			$site_options->head['scripts'] = $site_options->scripts['header'];
			$site_options->javascript['scripts'] = $site_options->scripts['footer'];
		}
		if (isset($site_options->header_scripts))
			$site_options->head['scripts'] = $site_options->header_scripts;
		elseif (isset($site_options->mint))
			$site_options->head['scripts'] = $site_options->mint;
		if (isset($site_options->footer_scripts))
			$site_options->javascript['scripts'] = $site_options->footer_scripts;
		elseif (isset($site_options->analytics))
			$site_options->javascript['scripts'] = $site_options->analytics;
			
		// Move custom stylesheet option, if necessary
		if (isset($site_options->style))
			$design_options->layout['custom'] = (bool) $site_options->style['custom'];

		// Display options
		if (isset($site_options->show_title))
			$site_options->display['header']['title'] = (bool) $site_options->show_title;
		if (isset($site_options->show_tagline))
			$site_options->display['header']['tagline'] = (bool) $site_options->show_tagline;
		if (isset($site_options->show_author))
			$site_options->display['byline']['author']['show'] = (bool) $site_options->show_author;
		if (isset($site_options->link_author_names))
			$site_options->display['byline']['author']['link'] = (bool) $site_options->link_author_names;
		if (isset($site_options->author_nofollow))
			$site_options->display['byline']['author']['nofollow'] = (bool) $site_options->author_nofollow;
		if (isset($site_options->show_date))
			$site_options->display['byline']['date']['show'] = (bool) $site_options->show_date;
		if (isset($site_options->show_author_on_pages))
			$site_options->display['byline']['page']['author'] = (bool) $site_options->show_author_on_pages;
		if (isset($site_options->show_date_on_pages))
			$site_options->display['byline']['page']['date'] = (bool) $site_options->show_date_on_pages;
		if (isset($site_options->show_num_comments))
			$site_options->display['byline']['num_comments']['show'] = (bool) $site_options->show_num_comments;
		if (isset($site_options->show_categories))
			$site_options->display['byline']['categories']['show'] = (bool) $site_options->show_categories;
		if (isset($site_options->read_more_text))
			$site_options->display['posts']['read_more_text'] = $site_options->read_more_text;
		elseif (isset($site_options->display['read_more_text'])) {
			$site_options->display['posts']['read_more_text'] = $site_options->display['read_more_text'];
			unset($site_options->display['read_more_text']);
		}
		if (isset($site_options->show_post_nav))
			$site_options->display['posts']['nav'] = (bool) $site_options->show_post_nav;
		elseif (isset($site_options->display['navigation'])) {
			$site_options->display['posts']['nav'] = (bool) $site_options->display['navigation'];
			unset($site_options->display['navigation']);
		}
		if (isset($site_options->archive_style))
			$site_options->display['archives']['style'] = $site_options->archive_style;
		if (isset($site_options->tags_single))
			$site_options->display['tags']['single'] = (bool) $site_options->tags_single;
		if (isset($site_options->tags_index))
			$site_options->display['tags']['index'] = (bool) $site_options->tags_index;
		if (isset($site_options->tags_nofollow))
			$site_options->display['tags']['nofollow'] = (bool) $site_options->tags_nofollow;
		if (isset($site_options->show_default_widgets))
			$site_options->display['sidebars']['default_widgets'] = (bool) $site_options->show_default_widgets;
		if (isset($site_options->edit_post_link))
			$site_options->display['admin']['edit_post'] = (bool) $site_options->edit_post_link;
		if (isset($site_options->admin_link))
			$site_options->display['admin']['link'] = ($site_options->admin_link == 'always') ? true : false;
		if (isset($site_options->edit_comment_link))
			unset($site_options->edit_comment_link);
		if (isset($site_options->display['admin']['edit_comment']))
			unset ($site_options->display['admin']['edit_comment']);

		// Update old comment options for version 1.7
		if (isset($site_options->display['comments'])) {
			// Thesis Options
			$site_options->comments['disable_pages'] = (bool) $site_options->display['comments']['disable_pages'];
			// Design Options
			$design_options->comments['comments']['options']['meta']['number']['show'] = (bool) $site_options->display['comments']['numbers'];
			$design_options->comments['comments']['options']['meta']['avatar']['options']['size'] = $site_options->display['comments']['avatar_size'];
			unset($site_options->display['comments']);
		}
		if (isset($site_options->show_comment_numbers))
			$design_options->comments['comments']['options']['meta']['number']['show'] = (bool) $site_options->show_comment_numbers;
		if (isset($site_options->avatar_size))
			$design_options->comments['comments']['options']['meta']['avatar']['options']['size'] = $site_options->avatar_size;
		if (isset($site_options->disable_comments))
			$site_options->comments['disable_pages'] = (bool) $site_options->disable_comments;

		// Nav menu
		if (isset($site_options->nav_menu_pages)) {
			$nav_menu_pages = explode(',', $site_options->nav_menu_pages);
			foreach ($nav_menu_pages as $nav_page) {
				if ($nav_page)
					$site_options->nav['pages'][$nav_page]['show'] = true;
			}
		}
		if (isset($site_options->nav_category_pages))
			$site_options->nav['categories'] = $site_options->nav_category_pages;
		if (isset($site_options->nav_link_category))
			$site_options->nav['links'] = $site_options->nav_link_category;
		if (isset($site_options->nav_home_text))
			$site_options->nav['home']['text'] = $site_options->nav_home_text;
		if (isset($site_options->show_feed_link))
			$site_options->nav['feed']['show'] = (bool) $site_options->show_feed_link;
		if (isset($site_options->feed_link_text))
			$site_options->nav['feed']['text'] = $site_options->feed_link_text;
		unset($site_options->nav['style']); // Remove support for old-style WP menu

		// Post images and thumbnails
		if (isset($site_options->image)) // This is for 1.7
			$design_options->image = $site_options->image;
		else { // This is suuuuper legacy
			if (isset($design_options->post_image_horizontal))
				$design_options->image['post']['x'] = $design_options->post_image_horizontal;
			if (isset($design_options->post_image_vertical))
				$design_options->image['post']['y'] = $design_options->post_image_vertical;
			if (isset($design_options->post_image_frame))
				$design_options->image['post']['frame'] = ($design_options->post_image_frame) ? 'on' : 'off';
			if (isset($design_options->post_image_single))
				$design_options->image['post']['single'] = $design_options->post_image_single;
			if (isset($design_options->post_image_archives))
				$design_options->image['post']['archives'] = $design_options->post_image_archives;
			if (isset($design_options->thumb_horizontal))
				$design_options->image['thumb']['x'] = $design_options->thumb_horizontal;
			if (isset($design_options->thumb_vertical))
				$design_options->image['thumb']['y'] = $design_options->thumb_vertical;
			if (isset($design_options->thumb_frame))
				$design_options->image['thumb']['frame'] = ($design_options->thumb_frame) ? 'on' : 'off';
			if (isset($design_options->thumb_size)) {
				$design_options->image['thumb']['width'] = $design_options->thumb_size['width'];
				$design_options->image['thumb']['height'] = $design_options->thumb_size['height'];
			}
		}

		// Multimedia box
		if (isset($multimedia_box) && is_array($multimedia_box)) {
			foreach ($multimedia_box as $item => $value)
				$design_options->multimedia_box[$item] = $value;
		}
		elseif (isset($multimedia_box)) {
			$design_options->multimedia_box['status'] = $multimedia_box;

			if ($site_options->image_alt_tags) {
				foreach ($site_options->image_alt_tags as $image_name => $alt_text) {
					if ($alt_text != '')
						$design_options->multimedia_box['alt_tags'][$image_name] = $alt_text;
				}
			}
			if ($site_options->image_link_urls) {
				foreach ($site_options->image_link_urls as $image_name => $link_url) {
					if ($link_url != '')
						$design_options->multimedia_box['link_urls'][$image_name] = $link_url;
				}
			}
			if ($site_options->video_code)
				$design_options->multimedia_box['video'] = $site_options->video_code;
			if ($site_options->custom_code)
				$design_options->multimedia_box['code'] = $site_options->custom_code;
		}

		// Loop back through all existing Thesis Options and make changes as necessary
		foreach ($site_options as $option_name => $value) {
			if (!isset($default_site_options->$option_name))
				unset($site_options->$option_name); // Has this option been nuked? If so, kill it!
		}

		if (version_compare($site_options->version, thesis_version(), '<'))
			$site_options->version = thesis_version();

		update_option('thesis_options', $site_options); // Save upgraded Thesis Options
		update_option('thesis_design_options', $design_options); // Save upgraded Design Options
	}
	
	function options_page() {
		global $thesis_site, $thesis_design;

		$head = $thesis_site->head;
		$javascript = $thesis_site->javascript;
		$nav = $thesis_site->nav;
		$comments = $thesis_site->comments;
		$display = $thesis_site->display;
?>

<div id="thesis_options" class="wrap<?php if (get_bloginfo('text_direction') == 'rtl') { echo ' rtl'; } ?>">
<?php
	thesis_version_indicator();
	thesis_options_title(__('Thesis Site Options', 'thesis'));
	thesis_options_nav();
	thesis_options_status_check();

	if (version_compare($thesis_site->version, thesis_version()) != 0) {
?>
	<form id="upgrade_needed" action="<?php echo admin_url('admin-post.php?action=thesis_upgrade'); ?>" method="post">
		<h3><?php _e('Oooh, Exciting!', 'thesis'); ?></h3>
		<p><?php _e('It&#8217;s time to upgrade your Thesis, which means there&#8217;s new awesomeness in your immediate future. Click the button below to fast-track your way to the awesomeness!', 'thesis'); ?></p>
		<p><input type="submit" class="upgrade_button" id="teh_upgrade" name="upgrade" value="<?php _e('Upgrade Thesis', 'thesis'); ?>" /></p>
	</form>
<?php
	}
	else {
		thesis_is_css_writable();
?>

	<form class="thesis" action="<?php echo admin_url('admin-post.php?action=thesis_options'); ?>" method="post">
		<div class="options_column">
			<div class="options_module" id="document-head">
				<h3><?php _e('Document Head', 'thesis'); ?> <code>&lt;head&gt;</code></h3>
				<div class="module_subsection">
					<h4 class="module_switch"><a href="" title="<?php _e('Show/hide additional information', 'thesis'); ?>"><span class="pos">+</span><span class="neg">&#8211;</span></a><?php _e('Title Tag Settings', 'thesis'); ?> <code>&lt;title&gt;</code></h4>
					<div class="more_info">
						<p><?php _e('As far as <acronym title="Search Engine Optimization">SEO</acronym> is concerned, this is the single most important element on your site. For all pages except the home page, Thesis will construct your <code>&lt;title&gt;</code> tags automatically according to the settings below, but you can override these settings by adding a custom <code>&lt;title&gt;</code> to any post or page via the post editing screen.', 'thesis'); ?></p>
						<ul class="add_margin">
							<li><input type="checkbox" id="head[title][branded]" name="head[title][branded]" value="1" <?php if ($head['title']['branded']) echo 'checked="checked" '; ?>/><label for="head[title][branded]"><?php _e('Append site name to page titles', 'thesis'); ?></label></li>
						</ul>
						<p class="form_input add_margin">
							<input type="text" class="text_input short" id="head[title][separator]" name="head[title][separator]" value="<?php echo ($head['title']['separator']) ? urldecode($head['title']['separator']) : '&#8212;' ?>" />
							<label for="head[title][separator]"><?php _e('Character separator in titles', 'thesis'); ?></label>
						</p>
						<p class="tip"><?php printf(__('To set the <code>&lt;title&gt;</code> tags on your home page, category pages, or tag pages, visit the new <a href="%s">Page Options screen</a>.', 'thesis'), admin_url('admin.php?page=thesis-pages')); ?></p>
					</div>
				</div>
				<div class="module_subsection" id="robots-meta">
					<h4 class="module_switch"><a href="" title="<?php _e('Show/hide additional information', 'thesis'); ?>"><span class="pos">+</span><span class="neg">&#8211;</span></a><?php _e('Robots Meta Tags', 'thesis'); ?> <code>&lt;meta&gt;</code></h4>
					<div class="more_info">
						<div class="mini_module indented_module" id="robots-noindex">
							<h5 class="module_switch"><a href="" title="<?php _e('Show/hide additional information', 'thesis'); ?>"><span class="pos">+</span><span class="neg">&#8211;</span></a><?php _e('Noindex Tag', 'thesis'); ?> <code>noindex</code></h5>
							<div class="more_info">
								<p><?php _e('Adding the <code>noindex</code> robot meta tag is a great way to fine-tune your site&#8217;s <acronym title="Search Engine Optimization">SEO</acronym> by streamlining the amount of pages that get indexed by the search engines. The options below will help you prevent the indexing of &#8220;bloat&#8221; pages that do nothing but dilute your search results and keep you from ranking as well as you should.', 'thesis'); ?></p>
								<ul>
<?php
								foreach ($head['meta']['robots']['noindex'] as $page_type => $value) {
									$checked = ($value) ? 'checked="checked" ' : '';
									echo "\t\t\t\t\t\t\t\t\t" . '<li><input type="checkbox" id="head[meta][robots][noindex][' . $page_type . ']" name="head[meta][robots][noindex][' . $page_type . ']" value="1" ' . $checked . '/><label for="head[meta][robots][noindex][' . $page_type . ']">' . sprintf(__('Add <code>noindex</code> to %s pages', 'thesis'), $page_type) . '</label></li>' . "\n";
								}
?>
								</ul>
							</div>
						</div>
						<div class="mini_module indented_module" id="robots-nofollow">
							<h5 class="module_switch"><a href="" title="<?php _e('Show/hide additional information', 'thesis'); ?>"><span class="pos">+</span><span class="neg">&#8211;</span></a><?php _e('Nofollow Tag', 'thesis'); ?> <code>nofollow</code></h5>
							<div class="more_info">
								<p><?php _e('The <code>nofollow</code> robot meta tag is another useful tool for nailing down your site&#8217;s <acronym title="Search Engine Optimization">SEO</acronym>. Links from pages with the <code>nofollow</code> meta tag won&#8217;t pass any juice.', 'thesis'); ?></p>
								<ul>
<?php
								foreach ($head['meta']['robots']['nofollow'] as $page_type => $value) {
									$checked = ($value) ? 'checked="checked" ' : '';
									echo "\t\t\t\t\t\t\t\t\t" . '<li><input type="checkbox" id="head[meta][robots][nofollow][' . $page_type . ']" name="head[meta][robots][nofollow][' . $page_type . ']" value="1" ' . $checked . '/><label for="head[meta][robots][nofollow][' . $page_type . ']">' . sprintf(__('Add <code>nofollow</code> to %s pages', 'thesis'), $page_type) . '</label></li>' . "\n";
								}
?>
								</ul>
							</div>
						</div>
						<div class="mini_module indented_module" id="robots-noarchive">
							<h5 class="module_switch"><a href="" title="<?php _e('Show/hide additional information', 'thesis'); ?>"><span class="pos">+</span><span class="neg">&#8211;</span></a><?php _e('Noarchive Tag', 'thesis'); ?> <code>noarchive</code></h5>
							<div class="more_info">
								<p><?php _e('The <code>noarchive</code> robot meta tag prevents search engines and Internet archive services from saving cached versions of pages on your site. Generally, people use this to protect their privacy, but there are certainly times when having access to archived versions of your pages might prove useful.', 'thesis'); ?></p>
								<ul>
<?php
								foreach ($head['meta']['robots']['noarchive'] as $page_type => $value) {
									$checked = ($value) ? 'checked="checked" ' : '';
									echo "\t\t\t\t\t\t\t\t\t" . '<li><input type="checkbox" id="head[meta][robots][noarchive][' . $page_type . ']" name="head[meta][robots][noarchive][' . $page_type . ']" value="1" ' . $checked . '/><label for="head[meta][robots][noarchive][' . $page_type . ']">' . sprintf(__('Add <code>noarchive</code> to %s pages', 'thesis'), $page_type) . '</label></li>' . "\n";
								}
?>
								</ul>
							</div>
						</div>
						<div class="mini_module indented_module" id="robots-noodp">
							<h5 class="module_switch"><a href="" title="<?php _e('Show/hide additional information', 'thesis'); ?>"><span class="pos">+</span><span class="neg">&#8211;</span></a><?php _e('Directory Tags', 'thesis'); ?> <code>noodp</code> <code>noydir</code></h5>
							<div class="more_info">
								<p><?php _e('Using the <code>noodp</code> robot meta tag will prevent search engines from displaying Open Directory Project (DMOZ) listings in your meta descriptions. The <code>noydir</code> tag is pretty much the same, except that it only affects the Yahoo! Directory. Both of these options are sitewide.', 'thesis'); ?></p>
								<ul>
									<li><input type="checkbox" id="head[meta][robots][noodp]" name="head[meta][robots][noodp]" value="1" <?php if ($head['meta']['robots']['noodp']) echo 'checked="checked" '; ?>/><label for="head[meta][robots][noodp]"><?php _e('Add <code>noodp</code> to your site', 'thesis'); ?></label></li>
									<li><input type="checkbox" id="head[meta][robots][noydir]" name="head[meta][robots][noydir]" value="1" <?php if ($head['meta']['robots']['noydir']) echo 'checked="checked" '; ?>/><label for="head[meta][robots][noydir]"><?php _e('Add <code>noydir</code> to your site', 'thesis'); ?></label></li>
								</ul>
							</div>
						</div>
					</div>
				</div>
				<div class="module_subsection">
					<h4 class="module_switch"><a href="" title="<?php _e('Show/hide additional information', 'thesis'); ?>"><span class="pos">+</span><span class="neg">&#8211;</span></a><?php _e('Canonical <acronym title="Uniform Resource Locator">URL</acronym>s', 'thesis'); ?></h4>
					<ul class="more_info">
						<li><input type="checkbox" id="head[links][canonical]" name="head[links][canonical]" value="1" <?php if ($head['links']['canonical']) echo 'checked="checked" '; ?>/><label for="head[links][canonical]"><?php _e('Add canonical <acronym title="Uniform Resource Locator">URL</acronym>s to your site', 'thesis'); ?></label></li>
					</ul>
				</div>
				<div class="module_subsection" id="syndication">
					<h4 class="module_switch"><a href="" title="<?php _e('Show/hide additional information', 'thesis'); ?>"><span class="pos">+</span><span class="neg">&#8211;</span></a><?php _e('Syndication/Feed <acronym title="Uniform Resource Locator">URL</acronym>', 'thesis'); ?></h4>
					<div class="more_info">
						<p><?php printf(__('If you&#8217;re using a service like <a href="%s">Feedburner</a> to manage your <acronym title="Really Simple Syndication">RSS</acronym> feed, you should enter the <acronym title="Uniform Resource Locator">URL</acronym> of your feed in the box below. If you&#8217;d prefer to use the default WordPress feed, simply leave this box blank.', 'thesis'), 'http://www.feedburner.com/'); ?></p>
						<p class="form_input">
							<input type="text" class="text_input" id="head[feed][url]" name="head[feed][url]" value="<?php if ($head['feed']['url']) echo $head['feed']['url']; ?>" />
							<label for="head[feed][url]"><?php _e('Feed <acronym title="Uniform Resource Locator">URL</acronym> (including &#8216;http://&#8217;)', 'thesis'); ?></label>
						</p>
					</div>
				</div>
				<div class="module_subsection">
					<h4 class="module_switch"><a href="" title="<?php _e('Show/hide additional information', 'thesis'); ?>"><span class="pos">+</span><span class="neg">&#8211;</span></a><?php _e('Additional Scripts', 'thesis'); ?></h4>
					<div class="more_info">
						<p><?php printf(__('If you need to add scripts to your document <code>&lt;head&gt;</code>, you should enter them in the box below; however, if you&#8217;re adding stat-tracking code, you should add that to the <a href="%s">Stats and Scripts section below</a>.', 'thesis'), '#javascript-options'); ?></p>
						<p class="form_input">
							<label for="head[scripts]"><?php _e('Additional <code>&lt;head&gt;</code> scripts (code)', 'thesis'); ?></label>
							<textarea class="scripts" id="head[scripts]" name="head[scripts]"><?php if ($head['scripts']) thesis_massage_code($head['scripts']); ?></textarea>
						</p>
					</div>
				</div>
			</div>
			<div class="options_module" id="javascript-options">
				<h3><?php _e('Stats Software/Scripts', 'thesis'); ?></h3>
				<div class="module_subsection" id="javascript-scripts">
					<h4 class="module_switch"><a href="" title="<?php _e('Show/hide additional information', 'thesis'); ?>"><span class="pos">+</span><span class="neg">&#8211;</span></a><?php _e('Stat and Tracking Scripts', 'thesis'); ?></h4>
					<div class="more_info">
						<p><?php _e('If you&#8217;ve got a stat-tracking script (from, say, Mint or Google Analytics), you&#8217;ll want to place it here. Anything you add here will be served after the <acronym title="HyperText Markup Language">HTML</acronym> on <em>every page of your site</em>. This is the preferred position because it prevents the scripts from interrupting the page load.', 'thesis'); ?></p>
						<p class="form_input">
							<label for="javascript[scripts]"><?php _e('Tracking scripts (include <code>&lt;script&gt;</code> tags!)', 'thesis'); ?></label>
							<textarea class="scripts" id="javascript[scripts]" name="javascript[scripts]"><?php if ($javascript['scripts']) thesis_massage_code($javascript['scripts']); ?></textarea>
						</p>
					</div>
				</div>
			</div>
		</div>
		
		<div class="options_column">
			<div class="options_module" id="display-options">
				<h3><?php _e('Display Options', 'thesis'); ?></h3>
				<div class="module_subsection">
					<h4 class="module_switch"><a href="" title="<?php _e('Show/hide additional information', 'thesis'); ?>"><span class="pos">+</span><span class="neg">&#8211;</span></a><?php _e('Header', 'thesis'); ?></h4>
					<ul class="more_info">
						<li><input type="checkbox" id="display[header][title]" name="display[header][title]" value="1" <?php if ($display['header']['title']) echo 'checked="checked" '; ?>/><label for="display[header][title]"><?php _e('Show site name in header', 'thesis'); ?></label></li>
						<li><input type="checkbox" id="display[header][tagline]" name="display[header][tagline]" value="1" <?php if ($display['header']['tagline']) echo 'checked="checked" '; ?>/><label for="display[header][tagline]"><?php _e('Show site tagline in header', 'thesis'); ?></label></li>
					</ul>
				</div>
				<div class="module_subsection">
					<h4 class="module_switch"><a href="" title="<?php _e('Show/hide additional information', 'thesis'); ?>"><span class="pos">+</span><span class="neg">&#8211;</span></a><?php _e('Bylines', 'thesis'); ?></h4>
					<div class="more_info">
						<div class="control_box">
							<ul class="control no_margin">
								<li><input type="checkbox" id="display[byline][author][show]" name="display[byline][author][show]" value="1" <?php if ($display['byline']['author']['show']) echo 'checked="checked" '; ?>/><label for="display[byline][author][show]"><?php _e('Show author name in <strong>post</strong> byline', 'thesis'); ?></label></li>
							</ul>
							<ul class="dependent">
								<li><input type="checkbox" id="display[byline][author][link]" name="display[byline][author][link]" value="1" <?php if ($display['byline']['author']['link']) echo 'checked="checked" '; ?>/><label for="display[byline][author][link]"><?php _e('Link author names to archives', 'thesis'); ?></label></li>
								<li><input type="checkbox" id="display[byline][author][nofollow]" name="display[byline][author][nofollow]" value="1" <?php if ($display['byline']['author']['nofollow']) echo 'checked="checked" '; ?>/><label for="display[byline][author][nofollow]"><?php _e('Add <code>nofollow</code> to author links', 'thesis'); ?></label></li>
							</ul>
						</div>
						<ul>
							<li><input type="checkbox" id="display[byline][date][show]" name="display[byline][date][show]" value="1" <?php if ($display['byline']['date']['show']) echo 'checked="checked" '; ?>/><label for="display[byline][date][show]"><?php _e('Show published-on date in <strong>post</strong> byline', 'thesis'); ?></label></li>
							<li><input type="checkbox" id="display[byline][page][author]" name="display[byline][page][author]" value="1" <?php if ($display['byline']['page']['author']) echo 'checked="checked" '; ?>/><label for="display[byline][page][author]"><?php _e('Show author name in <strong>page</strong> byline', 'thesis'); ?></label></li>
							<li><input type="checkbox" id="display[byline][page][date]" name="display[byline][page][date]" value="1" <?php if ($display['byline']['page']['date']) echo 'checked="checked" '; ?>/><label for="display[byline][page][date]"><?php _e('Show published-on date in <strong>page</strong> byline', 'thesis'); ?></label></li>
							<li><input type="checkbox" id="display[byline][num_comments][show]" name="display[byline][num_comments][show]" value="1" <?php if ($display['byline']['num_comments']['show']) echo 'checked="checked" '; ?>/><label for="display[byline][num_comments][show]"><?php _e('Show number of comments in byline', 'thesis'); ?></label></li>
							<li><input type="checkbox" id="display[byline][categories][show]" name="display[byline][categories][show]" value="1" <?php if ($display['byline']['categories']['show']) echo 'checked="checked" '; ?>/><label for="display[byline][categories][show]"><?php _e('Show <strong>post</strong> categories', 'thesis'); ?></label></li>
						</ul>
					</div>
				</div>
				<div class="module_subsection">
					<h4 class="module_switch"><a href="" title="<?php _e('Show/hide additional information', 'thesis'); ?>"><span class="pos">+</span><span class="neg">&#8211;</span></a><?php _e('Posts', 'thesis'); ?></h4>
					<div class="more_info">
						<p><?php _e('The display setting you select below only affects your <strong>features</strong>; teasers (if you&#8217;re using them) are always displayed in excerpt format.', 'thesis'); ?></p>
						<ul class="add_margin">
							<li><input type="radio" name="display[posts][excerpts]" value="0" <?php if (!$display['posts']['excerpts']) echo 'checked="checked" '; ?>/><label><?php _e('Display full post content', 'thesis'); ?></label></li>
							<li><input type="radio" name="display[posts][excerpts]" value="1" <?php if ($display['posts']['excerpts']) echo 'checked="checked" '; ?>/><label><?php _e('Display post excerpts', 'thesis'); ?></label></li>
						</ul>
						<p class="label_note"><?php _e('&#8220;Read More&#8221; link', 'thesis'); ?></p>
						<p><?php _e('This is the clickthrough text on home and archive pages that appears on any post where you use the <code>&lt;!--more--&gt;</code> tag:', 'thesis'); ?></p>
						<p class="form_input add_margin">
							<input type="text" class="text_input" id="display[posts][read_more_text]" name="display[posts][read_more_text]" value="<?php echo thesis_read_more_text(); ?>" />
							<label for="display[posts][read_more_text]"><?php _e('clickthrough text', 'thesis'); ?></label>
						</p>
						<p class="label_note"><?php _e('Single entry pages', 'thesis'); ?></p>
						<ul>
							<li><input type="checkbox" id="display[posts][nav]" name="display[posts][nav]" value="1" <?php if ($display['posts']['nav']) echo 'checked="checked" '; ?>/><label for="display[posts][nav]"><?php _e('Show previous/next post links', 'thesis'); ?></label></li>
						</ul>
					</div>
				</div>
				<div class="module_subsection">
					<h4 class="module_switch"><a href="" title="<?php _e('Show/hide additional information', 'thesis'); ?>"><span class="pos">+</span><span class="neg">&#8211;</span></a><?php _e('Archives', 'thesis'); ?></h4>
					<div class="more_info">
						<p><?php _e('Select a display format for your archive pages:', 'thesis'); ?></p>
						<ul>
							<li><input type="radio" name="display[archives][style]" value="titles" <?php if ($display['archives']['style'] == 'titles') echo 'checked="checked" '; ?>/><label><?php _e('Titles only', 'thesis'); ?></label></li>
							<li><input type="radio" name="display[archives][style]" value="teasers" <?php if ($display['archives']['style'] == 'teasers') echo 'checked="checked" '; ?>/><label><?php _e('Everything&#8217;s a teaser!', 'thesis'); ?></label></li>
							<li><input type="radio" name="display[archives][style]" value="content" <?php if ($display['archives']['style'] == 'content') echo 'checked="checked" '; ?>/><label><?php _e('Same as your home page', 'thesis'); ?></label></li>
							<li><input type="radio" name="display[archives][style]" value="excerpts" <?php if ($display['archives']['style'] == 'excerpts') echo 'checked="checked" '; ?>/><label><?php _e('Post excerpts', 'thesis'); ?></label></li>
						</ul>
					</div>
				</div>
				<div class="module_subsection">
					<h4 class="module_switch"><a href="" title="<?php _e('Show/hide additional information', 'thesis'); ?>"><span class="pos">+</span><span class="neg">&#8211;</span></a><?php _e('Comments', 'thesis'); ?></h4>
					<div class="more_info">
						<ul>
							<li><input type="checkbox" id="comments[disable_pages]" name="comments[disable_pages]" value="1" <?php if ($comments['disable_pages']) echo 'checked="checked" '; ?>/><label for="comments[disable_pages]"><?php _e('Disable comments on all <strong>pages</strong>', 'thesis'); ?></label></li>
							<li><input type="checkbox" id="comments[show_closed]" name="comments[show_closed]" value="1" <?php if ($comments['show_closed']) echo 'checked="checked" '; ?>/><label for="comments[show_closed]"><?php _e('If comments are closed, display a message', 'thesis'); ?></label></li>
						</ul>
					</div>
				</div>
				<div class="module_subsection">
					<h4 class="module_switch"><a href="" title="<?php _e('Show/hide additional information', 'thesis'); ?>"><span class="pos">+</span><span class="neg">&#8211;</span></a><?php _e('Tagging', 'thesis'); ?></h4>
					<ul class="more_info">
						<li><input type="checkbox" id="display[tags][single]" name="display[tags][single]" value="1" <?php if ($display['tags']['single']) echo 'checked="checked" '; ?>/><label for="display[tags][single]"><?php _e('Show tags on single entry pages', 'thesis'); ?></label></li>
						<li><input type="checkbox" id="display[tags][index]" name="display[tags][index]" value="1" <?php if ($display['tags']['index']) echo 'checked="checked" '; ?>/><label for="display[tags][index]"><?php _e('Show tags on index and archives pages', 'thesis'); ?></label></li>
						<li><input type="checkbox" id="display[tags][nofollow]" name="display[tags][nofollow]" value="1" <?php if ($display['tags']['nofollow']) echo 'checked="checked" '; ?>/><label for="display[tags][nofollow]"><?php _e('Add <code>nofollow</code> to tag links', 'thesis'); ?></label></li>
					</ul>
				</div>
				<div class="module_subsection">
					<h4 class="module_switch"><a href="" title="<?php _e('Show/hide additional information', 'thesis'); ?>"><span class="pos">+</span><span class="neg">&#8211;</span></a><?php _e('Sidebars', 'thesis'); ?></h4>
					<ul class="more_info">
						<li><input type="checkbox" id="display[sidebars][default_widgets]" name="display[sidebars][default_widgets]" value="1" <?php if ($display['sidebars']['default_widgets']) echo 'checked="checked" '; ?>/><label for="display[sidebars][default_widgets]"><?php _e('Show default sidebar widgets', 'thesis'); ?></label></li>
					</ul>
				</div>
				<div class="module_subsection">
					<h4 class="module_switch"><a href="" title="<?php _e('Show/hide additional information', 'thesis'); ?>"><span class="pos">+</span><span class="neg">&#8211;</span></a><?php _e('Administration', 'thesis'); ?></h4>
					<div class="more_info">
						<ul>
							<li><input type="checkbox" id="display[admin][edit_post]" name="display[admin][edit_post]" value="1" <?php if ($display['admin']['edit_post']) echo 'checked="checked" '; ?>/><label for="display[admin][edit_post]"><?php _e('Show edit post links', 'thesis'); ?></label></li>
							<li><input type="checkbox" id="display[admin][link]" name="display[admin][link]" value="1" <?php if ($display['admin']['link']) echo 'checked="checked" '; ?>/><label><?php _e('Show admin link in footer', 'thesis'); ?></label></li>
						</ul>
					</div>
				</div>
			</div>
		</div>
		
		<div class="options_column">
			<div class="options_module button_module">
				<input type="submit" class="save_button" id="options_submit" name="submit" value="<?php thesis_save_button_text(); ?>" />
			</div>
			<div class="options_module" id="thesis-nav-menu">
				<h3><?php _e('Navigation Menu', 'thesis'); ?></h3>
				<div class="module_subsection">
					<h4 class="module_switch"><a href="" title="<?php _e('Show/hide additional information', 'thesis'); ?>"><span class="pos">+</span><span class="neg">&#8211;</span></a><?php _e('Pages', 'thesis') ?></h4>
					<div class="more_info">
						<p><?php _e('Start by selecting the pages you want to include in your nav menu. Next, drag and drop the pages to change their display order (topmost item displays first), and if you <em>really</em> want to get crazy, you can even edit the display text on each item. <strong>Try it!</strong>', 'thesis'); ?></p>
						<p><?php _e('Thesis features automatic dropdown menus, so if you have nested pages or categories, you&#8217;ll save space <em>and</em> gain style points with your slick new nav menu!', 'thesis'); ?></p>
						<ul id="nav_pages" class="sortable add_margin">
<?php
					$pages = &get_pages('sort_column=post_parent,menu_order');
					$active_pages = array();

					if ($nav['pages']) {
						foreach ($nav['pages'] as $id => $nav_page) {
							$active_page = get_page($id);
							if (post_exists($active_page->post_title)) {
								$checked = ($nav_page['show']) ? ' checked="checked"' : '';
								$link_text = ($nav['pages'][$id]['text'] != '') ? $nav['pages'][$id]['text'] : $active_page->post_title;
								echo "\t\t\t\t\t\t\t<li><input class=\"checkbox\" type=\"checkbox\" id=\"nav[pages][$id][show]\" name=\"nav[pages][$id][show]\" value=\"1\"$checked /><input type=\"text\" class=\"text_input\" id=\"nav[pages][$id][text]\" name=\"nav[pages][$id][text]\" value=\"$link_text\" /></li>\n";
								$active_pages[] = $id;
							}
						}
					}
					if ($pages) {
						foreach ($pages as $page) {
							if (!in_array($page->ID, $active_pages)) {
								$link_text = ($nav['pages'][$page->ID]['text'] != '') ? $nav['pages'][$page->ID]['text'] : $page->post_title;
								echo "\t\t\t\t\t\t\t<li><input class=\"checkbox\" type=\"checkbox\" id=\"nav[pages][$page->ID][show]\" name=\"nav[pages][$page->ID][show]\" value=\"1\" /><input type=\"text\" class=\"text_input\" id=\"nav[pages][$page->ID][text]\" name=\"nav[pages][$page->ID][text]\" value=\"$link_text\" /></li>\n";
							}
						}
					}

?>
						</ul>
					</div>
				</div>
				<div class="module_subsection">
					<h4 class="module_switch"><a href="" title="<?php _e('Show/hide additional information', 'thesis'); ?>"><span class="pos">+</span><span class="neg">&#8211;</span></a><?php _e('Categories', 'thesis') ?></h4>
					<div class="more_info">
						<p><?php _e('If you&#8217;d like to include category pages in your nav menu, simply select the appropriate categories from the list below (you can select more than one).', 'thesis'); ?></p>
						<p class="form_input">
							<select class="select_multiple" id="nav[categories]" name="nav[categories][]" multiple="multiple" size="1">
								<option value="0"><?php _e('No category page links', 'thesis'); ?></option>
<?php
					$categories = &get_categories('type=post&orderby=name&hide_empty=0');

					if ($categories) {
						$nav_category_pages = explode(',', $nav['categories']);
						foreach ($categories as $category) {
							$selected = (in_array($category->cat_ID, $nav_category_pages)) ? ' selected="selected"' : '';
							echo "\t\t\t\t\t\t\t\t<option value=\"$category->cat_ID\"$selected>$category->cat_name</option>\n";
						}
					}
?>
							</select>
						</p>
					</div>
				</div>
				<div class="module_subsection">
					<h4 class="module_switch"><a href="" title="<?php _e('Show/hide additional information', 'thesis'); ?>"><span class="pos">+</span><span class="neg">&#8211;</span></a><?php _e('Add More Links', 'thesis'); ?></h4>
					<div class="more_info">
						<p><?php printf(__('You can insert additional navigation links on the <a href="%1$s">Manage Links</a> page. To ensure that things go smoothly, you should first <a href="%2$s">create a link category</a> solely for your navigation menu, and then make sure you place your new links in that category. Once you&#8217;ve done that, you can select your category below to include it in your nav menu.', 'thesis'), get_bloginfo('wpurl') . '/wp-admin/link-manager.php', get_bloginfo('wpurl') . '/wp-admin/edit-link-categories.php#addcat'); ?></p>
						<p class="form_input">
							<select id="nav[links]" name="nav[links]" size="1">
								<option value="0"><?php _e('No additional links', 'thesis'); ?></option>
<?php
					$link_categories = &get_categories('type=link&hide_empty=0');
					
					if ($link_categories) {
						foreach ($link_categories as $link_category) {
							$selected = ($nav['links'] == $link_category->cat_ID) ? ' selected="selected"' : '';
							echo "\t\t\t\t\t\t\t\t<option value=\"$link_category->cat_ID\"$selected>$link_category->cat_name</option>\n";
						}
					}
?>
							</select>
						</p>
					</div>
				</div>
				<div class="module_subsection">
					<h4 class="module_switch"><a href="" title="<?php _e('Show/hide additional information', 'thesis'); ?>"><span class="pos">+</span><span class="neg">&#8211;</span></a><?php _e('Home Link', 'thesis'); ?></h4>
					<div class="control_box more_info">
						<ul class="control">
							<li><input type="checkbox" id="nav[home][show]" name="nav[home][show]" value="1" <?php if ($nav['home']['show']) echo 'checked="checked" '; ?>/><label for="nav[home][show]"><?php _e('Show home link in nav menu', 'thesis'); ?></label></li>
						</ul>
						<div class="dependent">
							<p class="form_input add_margin">
								<input type="text" id="nav[home][text]" name="nav[home][text]" value="<?php echo thesis_home_link_text(); ?>" />
								<label for="nav[home][text]"><?php _e('home link text', 'thesis'); ?></label>
							</p>
							<ul>
								<li><input type="checkbox" id="nav[home][nofollow]" name="nav[home][nofollow]" value="1" <?php if ($nav['home']['nofollow']) echo 'checked="checked" '; ?>/><label for="nav[home][nofollow]"><?php _e('Add <code>nofollow</code> to home link', 'thesis'); ?></label></li>
							</ul>
						</div>
					</div>
				</div>
				<div class="module_subsection">
					<h4 class="module_switch"><a href="" title="<?php _e('Show/hide additional information', 'thesis'); ?>"><span class="pos">+</span><span class="neg">&#8211;</span></a><?php _e('Feed Link in Nav Menu', 'thesis'); ?></h4>
					<div class="control_box more_info">
						<ul class="control">
							<li><input type="checkbox" id="nav[feed][show]" name="nav[feed][show]" value="1" <?php if ($nav['feed']['show']) echo 'checked="checked" '; ?>/><label for="nav[feed][show]"><?php _e('Show feed link in nav menu', 'thesis'); ?></label></li>
						</ul>
						<div class="dependent">
							<p class="form_input add_margin">
								<input type="text" class="text_input" id="nav[feed][text]" name="nav[feed][text]" value="<?php echo thesis_feed_link_text(); ?>" />
								<label for="nav[feed][text]"><?php _e('Change your feed link text', 'thesis'); ?></label>
							</p>
							<ul>
								<li><input type="checkbox" id="nav[feed][nofollow]" name="nav[feed][nofollow]" value="1" <?php if ($nav['feed']['nofollow']) echo 'checked="checked" '; ?>/><label for="nav[feed][nofollow]"><?php _e('Add <code>nofollow</code> to feed link', 'thesis'); ?></label></li>
							</ul>
						</div>
					</div>
				</div>
			</div>
			<div class="options_module" id="save_button_control">
				<div class="module_subsection">
					<h4 class="module_switch"><a href="" title="<?php _e('Show/hide additional information', 'thesis'); ?>"><span class="pos">+</span><span class="neg">&#8211;</span></a><?php _e('Change Save Button Text', 'thesis'); ?></h4>
					<p class="form_input more_info">
						<input type="text" id="save_button_text" name="save_button_text" value="<?php if ($thesis_site->save_button_text) echo $thesis_site->save_button_text; ?>" />
						<label for="save_button_text"><?php _e('not recommended (heh)', 'thesis'); ?></label>
					</p>
				</div>
			</div>
		</div>
	</form>
<?php
	}
?>
</div>
<?php
	}
}

function thesis_get_date_formats() {
	$date_formats = array(
		'standard' => 'F j, Y',
		'no_comma' => 'j F Y',
		'numeric' => 'm.d.Y',
		'reversed' => 'd.m.Y'
	);
	
	return $date_formats;
}