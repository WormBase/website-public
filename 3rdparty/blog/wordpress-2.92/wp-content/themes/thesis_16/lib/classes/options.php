<?php
/**
 * class Options
 *
 * The Options class consists of functions used to set and retrieve the different options
 * available on the Thesis theme. Thankfully, the WordPress API saves everything to your
 * database, but the rest of the magic occurs in functions native to this class. To set 
 * your options, enter your WordPress dashboard and visit:
 * Design -> Thesis Options
 * Or, if you prefer, you can visit /wp-admin/admin.php?page=thesis-options
 *
 * @package Thesis
 * @since 1.0
 */

class Options {
	/**
	 * default_options() — Sets Options variables to their defaults.
	 *
	 * @since 1.0
	 */
	function default_options() {
		// Document head
		$this->head = array(
			'title' => array(
				'title' => true,
				'tagline' => true,
				'tagline_first'=> false,
				'branded' => false,
				'separator' => false
			),
			'noindex' => array(
				'category' => false,
				'tag' => true,
				'author' => true,
				'day' => true,
				'month' => true,
				'year' => true
			),
			'canonical' => true,
			'version' => true
		);
		
		// Syndication/feed
		$this->feed = array(
			'url' => false
		);
		
		// Header and footer scripts
		$this->scripts = array(
			'header' => false,
			'footer' => false
		);
		
		// Home Page options
		$this->home = array(
			'meta' => array(
				'description' => false,
				'keywords' => false
			),
			'features' => 2
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
			'comments' => array(
				'numbers' => false,
				'allowed_tags' => false,
				'disable_pages' => false,
				'avatar_size' => 44
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
		
		// Post images and thumbnails
		$this->image = array(
			'post' => array(
				'x' => 'flush',
				'y' => 'before-headline',
				'frame' => 'off',
				'single' => true,
				'archives' => true
			),
			'thumb' => array(
				'x' => 'left',
				'y' => 'before-post',
				'frame' => 'off',
				'width' => 66,
				'height' => 66
			),
			'fopen' => true
		);
		
		// Save button text
		$this->save_button_text = false;
		
		// Thesis version
		$this->version = thesis_version();
	}
	
	/**
	 * thesis_get_options() — Retrieves saved options from the WP database
	 *
	 * @since 1.0
	 */
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
		$this->head['title']['title'] = (bool) $head['title']['title'];
		$this->head['title']['tagline'] = (bool) $head['title']['tagline'];
		$this->head['title']['tagline_first'] = (bool) $head['title']['tagline_first'];
		$this->head['title']['branded'] = (bool) $head['title']['branded'];
		$this->head['title']['separator'] = ($head['title']['separator']) ? urlencode($head['title']['separator']) : false;
		$this->head['noindex']['category'] = (bool) $head['noindex']['category'];
		$this->head['noindex']['tag'] = (bool) $head['noindex']['tag'];
		$this->head['noindex']['author'] = (bool) $head['noindex']['author'];
		$this->head['noindex']['day'] = (bool) $head['noindex']['day'];
		$this->head['noindex']['month'] = (bool) $head['noindex']['month'];
		$this->head['noindex']['year'] = (bool) $head['noindex']['year'];
		$this->head['canonical'] = (bool) $head['canonical'];
		$this->head['version'] = (bool) $head['version'];
		
		// Syndication
		$feed = $_POST['feed'];
		$this->feed['url'] = ($feed['url']) ? $feed['url'] : false;
		
		// Header and footer scripts
		$scripts = $_POST['scripts'];
		$this->scripts['header'] = ($scripts['header']) ? $scripts['header'] : false;
		$this->scripts['footer'] = ($scripts['footer']) ? $scripts['footer'] : false;
		
		// Home Page options
		$home = $_POST['home'];
		$this->home['meta']['description'] = ($home['meta']['description']) ? $home['meta']['description'] : false;
		$this->home['meta']['keywords'] = ($home['meta']['keywords']) ? $home['meta']['keywords'] : false;
		$this->home['features'] = $home['features'];

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
		$this->display['posts']['read_more_text'] = ($display['posts']['read_more_text']) ? urlencode($display['posts']['read_more_text']) : false;
		$this->display['posts']['nav'] = (bool) $display['posts']['nav'];
		$this->display['archives']['style'] = ($display['archives']['style']) ? $display['archives']['style'] : 'titles';
		$this->display['tags']['single'] = (bool) $display['tags']['single'];
		$this->display['tags']['index'] = (bool) $display['tags']['index'];
		$this->display['tags']['nofollow'] = (bool) $display['tags']['nofollow'];
		$this->display['comments']['numbers'] = (bool) $display['comments']['numbers'];
		$this->display['comments']['allowed_tags'] = (bool) $display['comments']['allowed_tags'];
		$this->display['comments']['disable_pages'] = (bool) $display['comments']['disable_pages'];
		$this->display['comments']['avatar_size'] = (is_numeric($display['comments']['avatar_size']) && $display['comments']['avatar_size'] > 0 && $display['comments']['avatar_size'] <= 96) ? $display['comments']['avatar_size'] : 44;
		$this->display['sidebars']['default_widgets'] = (bool) $display['sidebars']['default_widgets'];
		$this->display['admin']['edit_post'] = (bool) $display['admin']['edit_post'];
		$this->display['admin']['edit_comment'] = (bool) $display['admin']['edit_comment'];
		$this->display['admin']['link'] = (bool) $display['admin']['link'];
		
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
		$this->nav['home']['text'] = ($nav['home']['text']) ? $nav['home']['text'] : false;
		$this->nav['home']['nofollow'] = (bool) $nav['home']['nofollow'];
		$this->nav['feed']['show'] = (bool) $nav['feed']['show'];
		$this->nav['feed']['text'] = ($nav['feed']['text']) ? $nav['feed']['text'] : false;
		$this->nav['feed']['nofollow'] = (bool) $nav['feed']['nofollow'];
		
		// Post images and thumbnails
		$image = $_POST['image'];
		$this->image['post']['x'] = ($image['post']['x']) ? $image['post']['x'] : 'flush';
		$this->image['post']['y'] = ($image['post']['y']) ? $image['post']['y'] : 'before-headline';
		$this->image['post']['frame'] = ($image['post']['frame']) ? 'on' : 'off';
		$this->image['post']['single'] = (bool) $image['post']['single'];
		$this->image['post']['archives'] = (bool) $image['post']['archives'];
		$this->image['thumb']['x'] = ($image['thumb']['x']) ? $image['thumb']['x'] : 'left';
		$this->image['thumb']['y'] = ($image['thumb']['y']) ? $image['thumb']['y'] : 'before-post';
		$this->image['thumb']['frame'] = ($image['thumb']['frame']) ? 'on' : 'off';
		$this->image['thumb']['width'] = ($image['thumb']['width']) ? $image['thumb']['width'] : 66;
		$this->image['thumb']['height'] = ($image['thumb']['height']) ? $image['thumb']['height'] : 66;
		$this->image['fopen'] = (bool) ini_get('allow_url_fopen');
		
		// Misc. options
		$this->save_button_text = ($_POST['save_button_text']) ? $_POST['save_button_text'] : false;
	}
}

function thesis_save_options() {
	if (!current_user_can('edit_themes'))
		wp_die(__('Easy there, homey. You don&#8217;t have admin privileges to access theme options.', 'thesis'));
	
	if (isset($_POST['submit'])) {
		$thesis_options = new Options;
		$thesis_options->get_options();
		$thesis_options->update_options();
		update_option('thesis_options', $thesis_options);
	}

	wp_redirect(admin_url('admin.php?page=thesis-options&updated=true'));
}

function thesis_upgrade_options() {
	// Retrieve Thesis Options and Thesis Options defaults
	$thesis_options = new Options;
	$thesis_options->get_options();
	
	$default_options = new Options;
	$default_options->default_options();
	
	// Retrieve Design Options and Design Options defaults
	$design_options = new Design;
	$design_options->get_design_options();

	$default_design_options = new Design;
	$default_design_options->default_design_options();
	
	// Begin code to upgrade all Thesis Options to the newest data structures
	if (isset($thesis_options->multimedia_box))
		$multimedia_box = $thesis_options->multimedia_box;
	if (isset($design_options->home_layout)) {
		if ($design_options->home_layout) {
			$features = $design_options->teasers;
			unset($design_options->teasers);
		}
		else
			$features = get_option('posts_per_page');
	}
	
	foreach ($default_options as $option_name => $value) {
		if (!isset($thesis_options->$option_name)) 
			$thesis_options->$option_name = $default_options->$option_name;
	}

	// Document head
	if (isset($thesis_options->title_home_name))
		$thesis_options->head['title']['title'] = (bool) $thesis_options->title_home_name;
	if (isset($thesis_options->title_home_tagline))
		$thesis_options->head['title']['tagline'] = (bool) $thesis_options->title_home_tagline;
	if (isset($thesis_options->title_tagline_first))
		$thesis_options->head['title']['tagline_first'] = (bool) $thesis_options->title_tagline_first;
	if (isset($thesis_options->title_branded))
		$thesis_options->head['title']['branded'] = (bool) $thesis_options->title_branded;
	if (isset($thesis_options->title_separator))
		$thesis_options->head['title']['separator'] = $thesis_options->title_separator;
	if (isset($thesis_options->show_version))
		$thesis_options->head['version'] = $thesis_options->show_version;
	elseif (isset($thesis_options->head['meta']['version']))
		$thesis_options->head['version'] = (bool) $thesis_options->head['meta']['version'];
	if (isset($thesis_options->tags_noindex))
		$thesis_options->head['noindex']['tag'] = (bool) $thesis_options->tags_noindex;
	elseif (is_array($thesis_options->head['meta']['noindex']))
		$thesis_options->head['noindex'] = $thesis_options->head['meta']['noindex'];
	
	// Home Page options
	if (isset($thesis_options->meta_description))
		$thesis_options->home['meta']['description'] = $thesis_options->meta_description;
	elseif (isset($thesis_options->head['meta']['description']))
		$thesis_options->home['meta']['description'] = $thesis_options->head['meta']['description'];
	if (isset($thesis_options->meta_keywords))
		$thesis_options->home['meta']['keywords'] = $thesis_options->meta_keywords;
	elseif (isset($thesis_options->head['meta']['keywords']))
		$thesis_options->home['meta']['keywords'] = $thesis_options->head['meta']['keywords'];
	if (isset($design_options->layout['home'])) {
		if ($design_options->layout['home'] == 'teasers') {
			$thesis_options->home['features'] = ($design_options->teasers['features']) ? $design_options->teasers['features'] : 2;
			unset ($design_options->teasers['features']);
		}
		else
			$thesis_options->home['features'] = get_option('posts_per_page');

		foreach ($design_options->layout as $layout_var => $value) {
			if ($layout_var != 'home')
				$new_layout[$layout_var] = $value;
		}
		
		if ($new_layout)
			$design_options->layout = $new_layout;
	}
	elseif (isset($features))
		$thesis_options->home['features'] = $features;
		
	// New $head array
	if (isset($thesis_options->head['meta'])) {
		$new_head['title'] = $thesis_options->head['title'];
		$new_head['noindex'] = $thesis_options->head['noindex'];
		$new_head['canonical'] = $thesis_options->head['canonical'];
		$new_head['version'] = $thesis_options->head['version'];
		$thesis_options->head = $new_head;
	}
	
	// Display options
	if (isset($thesis_options->show_title))
		$thesis_options->display['header']['title'] = (bool) $thesis_options->show_title;
	if (isset($thesis_options->show_tagline))
		$thesis_options->display['header']['tagline'] = (bool) $thesis_options->show_tagline;
	if (isset($thesis_options->show_author))
		$thesis_options->display['byline']['author']['show'] = (bool) $thesis_options->show_author;
	if (isset($thesis_options->link_author_names))
		$thesis_options->display['byline']['author']['link'] = (bool) $thesis_options->link_author_names;
	if (isset($thesis_options->author_nofollow))
		$thesis_options->display['byline']['author']['nofollow'] = (bool) $thesis_options->author_nofollow;
	if (isset($thesis_options->show_date))
		$thesis_options->display['byline']['date']['show'] = (bool) $thesis_options->show_date;
	if (isset($thesis_options->show_author_on_pages))
		$thesis_options->display['byline']['page']['author'] = (bool) $thesis_options->show_author_on_pages;
	if (isset($thesis_options->show_date_on_pages))
		$thesis_options->display['byline']['page']['date'] = (bool) $thesis_options->show_date_on_pages;
	if (isset($thesis_options->show_num_comments))
		$thesis_options->display['byline']['num_comments']['show'] = (bool) $thesis_options->show_num_comments;
	if (isset($thesis_options->show_categories))
		$thesis_options->display['byline']['categories']['show'] = (bool) $thesis_options->show_categories;
	if (isset($thesis_options->read_more_text))
		$thesis_options->display['posts']['read_more_text'] = $thesis_options->read_more_text;
	elseif (isset($thesis_options->display['read_more_text'])) {
		$thesis_options->display['posts']['read_more_text'] = $thesis_options->display['read_more_text'];
		unset($thesis_options->display['read_more_text']);
	}
	if (isset($thesis_options->show_post_nav))
		$thesis_options->display['posts']['nav'] = (bool) $thesis_options->show_post_nav;
	elseif (isset($thesis_options->display['navigation'])) {
		$thesis_options->display['posts']['nav'] = (bool) $thesis_options->display['navigation'];
		unset($thesis_options->display['navigation']);
	}
	if (isset($thesis_options->archive_style))
		$thesis_options->display['archives']['style'] = $thesis_options->archive_style;
	if (isset($thesis_options->tags_single))
		$thesis_options->display['tags']['single'] = (bool) $thesis_options->tags_single;
	if (isset($thesis_options->tags_index))
		$thesis_options->display['tags']['index'] = (bool) $thesis_options->tags_index;
	if (isset($thesis_options->tags_nofollow))
		$thesis_options->display['tags']['nofollow'] = (bool) $thesis_options->tags_nofollow;
	if (isset($thesis_options->show_comment_numbers))
		$thesis_options->display['comments']['numbers'] = (bool) $thesis_options->show_comment_numbers;
	if (isset($thesis_options->show_allowed_tags))
		$thesis_options->display['comments']['allowed_tags'] = (bool) $thesis_options->show_allowed_tags;
	if (isset($thesis_options->disable_comments))
		$thesis_options->display['comments']['disable_pages'] = (bool) $thesis_options->disable_comments;
	if (isset($thesis_options->avatar_size))
		$thesis_options->display['comments']['avatar_size'] = $thesis_options->avatar_size;
	if (isset($thesis_options->show_default_widgets))
		$thesis_options->display['sidebars']['default_widgets'] = (bool) $thesis_options->show_default_widgets;
	if (isset($thesis_options->edit_post_link))
		$thesis_options->display['admin']['edit_post'] = (bool) $thesis_options->edit_post_link;
	if (isset($thesis_options->edit_comment_link))
		$thesis_options->display['admin']['edit_comment'] = (bool) $thesis_options->edit_comment_link;
	if (isset($thesis_options->admin_link))
		$thesis_options->display['admin']['link'] = ($thesis_options->admin_link == 'always') ? true : false;
	
	// Syndication
	if (isset($thesis_options->feed_url))
		$thesis_options->feed['url'] = $thesis_options->feed_url;

	// Nav menu
	if (isset($thesis_options->nav_menu_pages)) {
		$nav_menu_pages = explode(',', $thesis_options->nav_menu_pages);
		foreach ($nav_menu_pages as $nav_page) {
			if ($nav_page)
				$thesis_options->nav['pages'][$nav_page]['show'] = true;
		}
	}
	if (isset($thesis_options->nav_category_pages))
		$thesis_options->nav['categories'] = $thesis_options->nav_category_pages;
	if (isset($thesis_options->nav_link_category))
		$thesis_options->nav['links'] = $thesis_options->nav_link_category;
	if (isset($thesis_options->nav_home_text))
		$thesis_options->nav['home']['text'] = $thesis_options->nav_home_text;
	if (isset($thesis_options->show_feed_link))
		$thesis_options->nav['feed']['show'] = (bool) $thesis_options->show_feed_link;
	if (isset($thesis_options->feed_link_text))
		$thesis_options->nav['feed']['text'] = $thesis_options->feed_link_text;
	unset($thesis_options->nav['style']); // Remove support for old-style WP menu

	// Post images and thumbnails
	if (isset($design_options->post_image_horizontal)) {
		$thesis_options->image['post']['x'] = $design_options->post_image_horizontal;
		unset($design_options->post_image_horizontal);
	}
	if (isset($design_options->post_image_vertical)) {
		$thesis_options->image['post']['y'] = $design_options->post_image_vertical;
		unset($design_options->post_image_vertical);
	}
	if (isset($design_options->post_image_frame)) {
		$thesis_options->image['post']['frame'] = ($design_options->post_image_frame) ? 'on' : 'off';
		unset($design_options->post_image_frame);
	}
	if (isset($design_options->post_image_single)) {
		$thesis_options->image['post']['single'] = $design_options->post_image_single;
		unset($design_options->post_image_single);
	}
	if (isset($design_options->post_image_archives)) {
		$thesis_options->image['post']['archives'] = $design_options->post_image_archives;
		unset($design_options->post_image_archives);
	}
	if (isset($design_options->thumb_horizontal)) {
		$thesis_options->image['thumb']['x'] = $design_options->thumb_horizontal;
		unset($design_options->thumb_horizontal);
	}
	if (isset($design_options->thumb_vertical)) {
		$thesis_options->image['thumb']['y'] = $design_options->thumb_vertical;
		unset($design_options->thumb_vertical);
	}
	if (isset($design_options->thumb_frame)) {
		$thesis_options->image['thumb']['frame'] = ($design_options->thumb_frame) ? 'on' : 'off';
		unset($design_options->thumb_frame);
	}
	if (isset($design_options->thumb_size)) {
		$thesis_options->image['thumb']['width'] = $design_options->thumb_size['width'];
		$thesis_options->image['thumb']['height'] = $design_options->thumb_size['height'];
		unset($design_options->thumb_size);
	}

	// Multimedia box
	if (isset($multimedia_box) && is_array($multimedia_box)) {
		foreach ($multimedia_box as $item => $value)
			$design_options->multimedia_box[$item] = $value;
	}
	elseif (isset($multimedia_box)) {
		$design_options->multimedia_box['status'] = $multimedia_box;

		if ($thesis_options->image_alt_tags) {
			foreach ($thesis_options->image_alt_tags as $image_name => $alt_text) {
				if ($alt_text != '')
					$design_options->multimedia_box['alt_tags'][$image_name] = $alt_text;
			}
		}
		if ($thesis_options->image_link_urls) {
			foreach ($thesis_options->image_link_urls as $image_name => $link_url) {
				if ($link_url != '')
					$design_options->multimedia_box['link_urls'][$image_name] = $link_url;
			}
		}
		if ($thesis_options->video_code)
			$design_options->multimedia_box['video'] = $thesis_options->video_code;
		if ($thesis_options->custom_code)
			$design_options->multimedia_box['code'] = $thesis_options->custom_code;
	}
	
	// Loop back through all existing Thesis Options and make changes as necessary
	foreach ($thesis_options as $option_name => $value) {
		if ($option_name == 'mint' || $option_name == 'header_scripts') {
			$thesis_options->scripts['header'] = $value;
			unset($thesis_options->$option_name);
		}
		elseif ($option_name == 'analytics' || $option_name == 'footer_scripts') {
			$thesis_options->scripts['footer'] = $value;
			unset($thesis_options->$option_name);
		}

		if (!isset($default_options->$option_name))
			unset($thesis_options->$option_name); // Has this option been nuked? If so, kill it!
	}

	if (version_compare($thesis_options->version, thesis_version(), '<'))
		$thesis_options->version = thesis_version();
	
	update_option('thesis_options', $thesis_options); // Save upgraded Thesis Options
	update_option('thesis_design_options', $design_options); // Save upgraded Design Options
}

function thesis_get_option($option_name) {
	$thesis_options = new Options;
	$thesis_options->get_options();
	return $thesis_options->$option_name;
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