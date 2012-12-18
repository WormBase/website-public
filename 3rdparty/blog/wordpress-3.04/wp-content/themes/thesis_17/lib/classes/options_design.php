<?php
/**
 * class thesis_design_options (formerly called Design)
 *
 * This class consists of variables used to manipulate different facets of
 * the Thesis layout. To set your design options, open up your WordPress
 * dashboard, and visit the following: Thesis -> Design Options
 * Or, if you prefer, you can visit /wp-admin/admin.php?page=thesis-design
 *
 * @package Thesis
 * @since 1.1
 */

class thesis_design_options {
	function default_options() {
		// Font variables
		$this->fonts = array(
			'families' => array(
				'body' => 'georgia',
				'nav_menu' => false,
				'header' => false,
				'tagline' => false,
				'headlines' => false,
				'subheads' => false,
				'bylines' => false,
				'code' => 'consolas',
				'multimedia_box' => false,
				'sidebars' => false,
				'sidebar_headings' => false,
				'footer' => false
			),
			'sizes' => array(
				'content' => 14,
				'nav_menu' => 11,
				'header' => 36,
				'tagline' => 14,
				'headlines' => 22,
				'bylines' => 10,
				'code' => 12,
				'multimedia_box' => 13,
				'sidebars' => 13,
				'sidebar_headings' => 13,
				'footer' => 12
			)
		);
		
		// Layout colors
		$this->colors = array(
			'background' => 'fff',
			'text' => '111',
			'shadow' => false,
			'page' => 'fff',
			'link' => '2361a1',
			'header' => '111',
			'tagline' => '888',
			'headlines' => '111',
			'subheads' => '111',
			'bylines'=> '888',
			'code' => '111',
			'sidebars' => '111',
			'sidebar_headings' => '555',
			'footer' => '888'
		);
		
		$this->borders = array(
			'show' => true,
			'color' => 'ddd'
		);

		$this->nav = array(
			'link' => array(
				'color' => '111',
				'hover' => '111',
				'current' => '111',
				'parent' => '111'
			),
			'background' => array(
				'link' => 'efefef',
				'hover' => 'ddd',
				'current' => 'fff',
				'parent' => 'f0eec2'
			),
			'border' => array(
				'width' => 1,
				'color' => 'ddd'
			),
			'submenu_width' => 150
		);

		// HTML layout
		$this->layout = array(
			'columns' => 3,
			'widths' => array(
				'content' => 480,
				'sidebar_1' => 195,
				'sidebar_2' => 195
			),
			'order' => 'normal',
			'framework' => 'page',
			'page_padding' => 1,
			'custom' => true
		);

		// JavaScript
		$this->javascript = array(
			'libs' => array(
				'jquery' => false,
				'jquery_ui' => false,
				'prototype' => false,
				'scriptaculous' => false,
				'mootools' => false,
				'dojo' => false,
				'swfobject' => false,
				'yui' => false,
				'ext' => false,
				'chrome' => false
			),
			'scripts' => false
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

		// Comments
		$this->comments = array(
			'comments' => array(
				'show' => true,
				'title' => __('comments', 'thesis'),
				'options' => array(
					'meta' => array(
						'avatar' => array(
							'show' => true,
							'title' => __('avatar', 'thesis'),
							'options' => array(
								'size' => 44
							)
						),
						'number' => array(
							'show' => false,
							'title' => __('comment numbers', 'thesis')
						),
						'author' => array(
							'show' => true,
							'title' => __('comment author', 'thesis')
						),
						'date' => array(
							'show' => true,
							'title' => __('comment date', 'thesis'),
							'options' => array(
								'time' => true,
								'date_format' => 'F j, Y'
							)
						),
						'edit' => array(
							'show' => true,
							'title' => __('edit comment link', 'thesis')
						)
					),
					'body' => array(
						'text' => array(
							'show' => true,
							'title' => __('comment text', 'thesis')
						),
						'reply' => array(
							'show' => true,
							'title' => __('comment reply link', 'thesis')
						)
					)
				)
			),
			'form' => array(
				'show' => true,
				'title' => __('comment form', 'thesis'),
				'options' => false
			),
			'trackbacks' => array(
				'show' => true,
				'title' => __('trackbacks', 'thesis'),
				'options' => array(
					'date' => false,
					'date_format' => 'F j, Y'
				)
			)
		);

		$this->teasers = array(
			'options' => array(
				'headline' => array(
					'name' => __('post title', 'thesis'),
					'show' => true
				),
				'author' => array(
					'name' => __('author name', 'thesis'),
					'show' => false
				),
				'date' => array(
					'name' => __('date', 'thesis'),
					'show' => true
				),
				'edit' => array(
					'name' => __('edit post link', 'thesis'),
					'show' => true
				),
				'category' => array(
					'name' => __('primary category', 'thesis'),
					'show' => false
				),
				'excerpt' => array(
					'name' => __('post excerpt', 'thesis'),
					'show' => true
				),
				'tags' => array(
					'name' => __('tags', 'thesis'),
					'show' => false
				),
				'comments' => array(
					'name' => __('number of comments link', 'thesis'),
					'show' => false
				),
				'link' => array(
					'name' => __('link to full article', 'thesis'),
					'show' => true
				)
			),
			'date' => array(
				'format' => 'standard',
				'custom' => 'F j, Y'
			),
			'font_sizes' => array(
				'headline' => 16,
				'author' => 10,
				'date' => 10,
				'category' => 10,
				'excerpt' => 12,
				'tags' => 11,
				'comments' => 10,
				'link' => 12
			),
			'link_text' => false,
		);
		
		// Feature box variables
		$this->feature_box = array(
			'position' => false,
			'status' => false,
			'after_post' => false,
			'content' => false
		);
		
		// Multimedia box
		$this->multimedia_box = array(
			'status' => 'image',
			'alt_tags' => false,
			'link_urls' => false,
			'video' => false,
			'code' => false,
			'color' => '111',
			'background' => array(
				'image' => 'eee',
				'video' => '000',
				'code' => 'eee'
			)
		);
	}

	function get_options() {
		$saved_options = maybe_unserialize(get_option('thesis_design_options'));
		
		if (!empty($saved_options) && is_object($saved_options)) {
			foreach ($saved_options as $option_name => $value)
				$this->$option_name = $value;
		}
	}

	function update_options() {
		// Fonts
		$fonts = $_POST['fonts'];
		foreach ($fonts['families'] as $area => $family)
			$this->fonts['families'][$area] = ($family) ? $family : false;
		foreach ($fonts['sizes'] as $area => $size)
			$this->fonts['sizes'][$area] = $size;
			
		// Layout colors
		$colors = $_POST['colors'];
		$this->colors['background'] = (strlen($colors['background']) == 3 || strlen($colors['background']) == 6) ? $colors['background'] : 'fff';
		$this->colors['shadow'] = (bool) $colors['shadow'];
		$this->colors['text'] = (strlen($colors['text']) == 3 || strlen($colors['text']) == 6) ? $colors['text'] : '111';
		$this->colors['page'] = (strlen($colors['page']) == 3 || strlen($colors['page']) == 6) ? $colors['page'] : 'fff';
		$this->colors['link'] = (strlen($colors['link']) == 3 || strlen($colors['link']) == 6) ? $colors['link'] : '2361a1';
		$this->colors['header'] = (strlen($colors['header']) == 3 || strlen($colors['header']) == 6) ? $colors['header'] : $this->colors['text'];
		$this->colors['tagline'] = (strlen($colors['tagline']) == 3 || strlen($colors['tagline']) == 6) ? $colors['tagline'] : $this->colors['text'];
		$this->colors['headlines'] = (strlen($colors['headlines']) == 3 || strlen($colors['headlines']) == 6) ? $colors['headlines'] : $this->colors['text'];
		$this->colors['subheads'] = (strlen($colors['subheads']) == 3 || strlen($colors['subheads']) == 6) ? $colors['subheads'] : $this->colors['text'];
		$this->colors['bylines'] = (strlen($colors['bylines']) == 3 || strlen($colors['bylines']) == 6) ? $colors['bylines'] : $this->colors['text'];
		$this->colors['code'] = (strlen($colors['code']) == 3 || strlen($colors['code']) == 6) ? $colors['code'] : $this->colors['text'];
		$this->colors['multimedia_box'] = (strlen($colors['multimedia_box']) == 3 || strlen($colors['multimedia_box']) == 6) ? $colors['multimedia_box'] : $this->colors['text'];
		$this->colors['sidebars'] = (strlen($colors['sidebars']) == 3 || strlen($colors['sidebars']) == 6) ? $colors['sidebars'] : $this->colors['text'];
		$this->colors['sidebar_headings'] = (strlen($colors['sidebar_headings']) == 3 || strlen($colors['sidebar_headings']) == 6) ? $colors['sidebar_headings'] : $this->colors['sidebars'];
		$this->colors['footer'] = (strlen($colors['footer']) == 3 || strlen($colors['footer']) == 6) ? $colors['footer'] : $this->colors['text'];
		
		// Borders
		$borders = $_POST['borders'];
		$this->borders['show'] = (bool) $borders['show'];
		$this->borders['color'] = (strlen($borders['color']) == 3 || strlen($borders['color']) == 6) ? $borders['color'] : 'ddd';

		// Layout
		$layout = $_POST['layout'];
		$this->layout['columns'] = ($layout['columns']) ? $layout['columns'] : 3;
		$this->layout['widths']['content'] = (300 <= $layout['widths']['content'] && $layout['widths']['content'] <= 934) ? $layout['widths']['content'] : 480;
		$this->layout['widths']['sidebar_1'] = (60 <= $layout['widths']['sidebar_1'] && $layout['widths']['sidebar_1'] <= 500) ? $layout['widths']['sidebar_1'] : 195;
		$this->layout['widths']['sidebar_2'] = (60 <= $layout['widths']['sidebar_2'] && $layout['widths']['sidebar_2'] <= 500) ? $layout['widths']['sidebar_2'] : 195;
		$this->layout['order'] = $layout['order'];
		$this->layout['framework'] = ($layout['framework']) ? $layout['framework'] : 'page';
		$this->layout['page_padding'] = $layout['page_padding'];
		$this->layout['custom'] = (bool) $layout['custom'];

		// JavaScript
		$thesis_javascript = new thesis_javascript;
		$javascript = $_POST['javascript'];
		foreach ($thesis_javascript->libs as $lib_name => $lib)
			$this->javascript['libs'][$lib_name] = (bool) $javascript['libs'][$lib_name];
		$this->javascript['scripts'] = ($javascript['scripts']) ? $javascript['scripts'] : false;

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

		// Comment options
		$comments = $_POST['comments'];
		$comment_meta = $comments['comments']['options']['meta'];
		$comment_body = $comments['comments']['options']['body'];
		$this->comments = $comments;
		foreach ($comments as $element_name => $element) $this->comments[$element_name]['show'] = (bool) $element['show'];
		foreach ($comment_meta as $element_name => $element) $this->comments['comments']['options']['meta'][$element_name]['show'] = (bool) $element['show'];
		$this->comments['comments']['options']['meta']['date']['options']['time'] = (bool) $comment_meta['date']['options']['time'];
		$this->comments['comments']['options']['meta']['date']['options']['date_format'] = ($comment_meta['date']['options']['date_format']) ? $comment_meta['date']['options']['date_format'] : 'F j, Y';
		$this->comments['comments']['options']['meta']['avatar']['options']['size'] = (is_numeric($comment_meta['avatar']['options']['size']) && $comment_meta['avatar']['options']['size'] > 0 && $comment_meta['avatar']['options']['size'] <= 96) ? $comment_meta['avatar']['options']['size'] : 44;
		foreach ($comment_body as $element_name => $element) $this->comments['comments']['options']['body'][$element_name]['show'] = (bool) $element['show'];
		$this->comments['trackbacks']['options']['date'] = (bool) $comments['trackbacks']['options']['date'];
		$this->comments['trackbacks']['options']['date_format'] = ($comments['trackbacks']['options']['date_format']) ? $comments['trackbacks']['options']['date_format'] : 'F j, Y';

		// Nav menu
		$nav = $_POST['nav'];
		$this->nav['link']['color'] = (strlen($nav['link']['color']) == 3 || strlen($nav['link']['color']) == 6) ? $nav['link']['color'] : '111';
		$this->nav['link']['hover'] = (strlen($nav['link']['hover']) == 3 || strlen($nav['link']['hover']) == 6) ? $nav['link']['hover'] : '111';
		$this->nav['link']['current'] = (strlen($nav['link']['current']) == 3 || strlen($nav['link']['current']) == 6) ? $nav['link']['current'] : '111';
		$this->nav['link']['parent'] = (strlen($nav['link']['parent']) == 3 || strlen($nav['link']['parent']) == 6) ? $nav['link']['parent'] : '111';
		$this->nav['background']['link'] = (strlen($nav['background']['link']) == 3 || strlen($nav['background']['link']) == 6) ? $nav['background']['link'] : 'efefef';
		$this->nav['background']['hover'] = (strlen($nav['background']['hover']) == 3 || strlen($nav['background']['hover']) == 6) ? $nav['background']['hover'] : 'ddd';
		$this->nav['background']['current'] = (strlen($nav['background']['current']) == 3 || strlen($nav['background']['current']) == 6) ? $nav['background']['current'] : 'fff';
		$this->nav['background']['parent'] = (strlen($nav['background']['parent']) == 3 || strlen($nav['background']['parent']) == 6) ? $nav['background']['parent'] : 'fff';
		$this->nav['border']['width'] = ($nav['border']['width'] >= 0 && $nav['border']['width'] <= 20) ? $nav['border']['width'] : 1;
		$this->nav['border']['color'] = (strlen($nav['border']['color']) == 3 || strlen($nav['border']['color']) == 6) ? $nav['border']['color'] : 'ddd';
		$this->nav['submenu_width'] = ($nav['submenu_width'] >= 30 && $nav['submenu_width'] <= 600) ? $nav['submenu_width'] : 150;
		
		// Teasers
		$teasers = $_POST['teasers'];
		$this->teasers['options'] = $teasers['options'];
		foreach ($teasers['options'] as $teaser_item => $teaser)
			$this->teasers['options'][$teaser_item]['show'] = (bool) $teaser['show'];
		$this->teasers['date']['format'] = ($teasers['date']['format']) ? $teasers['date']['format'] : 'standard';
		$this->teasers['date']['custom'] = ($teasers['date']['custom']) ? $teasers['date']['custom'] : 'F j, Y';
		foreach ($teasers['font_sizes'] as $teaser_item => $size)
			$this->teasers['font_sizes'][$teaser_item] = $size;
		$this->teasers['link_text'] = ($teasers['link_text']) ? urlencode(strip_tags(stripslashes($teasers['link_text']))) : false;
			
		// Feature box
		$feature_box = $_POST['feature_box'];
		$this->feature_box['position'] = ($feature_box['position']) ? $feature_box['position'] : false;
		$this->feature_box['status'] = ($feature_box['status']) ? $feature_box['status'] : false;
		$this->feature_box['after_post'] = ($feature_box['after_post']) ? $feature_box['after_post'] : false;
		$this->feature_box['content'] = ($feature_box['content']) ? $feature_box['content'] : false;

		// Multimedia box
		$multimedia_box = $_POST['multimedia_box'];
		$this->multimedia_box['status'] = ($multimedia_box['status']) ? $multimedia_box['status'] : false;
		if ($this->multimedia_box['status'] == 'image') {
			if (is_array($multimedia_box['alt_tags'])) {
				foreach ($multimedia_box['alt_tags'] as $image_name => $value)
					$this->multimedia_box['alt_tags'][$image_name] = $value;
			}
			if (is_array($multimedia_box['link_urls'])) {
				foreach ($multimedia_box['link_urls'] as $image_name => $url)
					$this->multimedia_box['link_urls'][$image_name] = $url;
			}
		}
		$this->multimedia_box['video'] = ($multimedia_box['video']) ? $multimedia_box['video'] : false;
		$this->multimedia_box['code'] = ($multimedia_box['code']) ? $multimedia_box['code'] : false;
		$this->multimedia_box['color'] = (strlen($multimedia_box['color']) == 3 || strlen($multimedia_box['color']) == 6) ? $multimedia_box['color'] : '111';
		$this->multimedia_box['background']['image'] = (strlen($multimedia_box['background']['image']) == 3 || strlen($multimedia_box['background']['image']) == 6) ? $multimedia_box['background']['image'] : 'eee';
		$this->multimedia_box['background']['video'] = (strlen($multimedia_box['background']['video']) == 3 || strlen($multimedia_box['background']['video']) == 6) ? $multimedia_box['background']['video'] : '000';
		$this->multimedia_box['background']['code'] = (strlen($multimedia_box['background']['code']) == 3 || strlen($multimedia_box['background']['code']) == 6) ? $multimedia_box['background']['code'] : 'eee';
	}
	
	function save_options() {
		if (!current_user_can('edit_themes'))
			wp_die(__('Easy there, homey. You don&#8217;t have admin privileges to access theme options.', 'thesis'));

		if (isset($_POST['submit'])) {
			$design_options = new thesis_design_options;
			$design_options->get_options();
			$design_options->update_options();
			update_option('thesis_design_options', $design_options);
		}

		thesis_generate_css();
		wp_redirect(admin_url('admin.php?page=thesis-design-options&updated=true'));
	}

	function upgrade_options() {
		// Retrieve Design Options and Design Options defaults
		$design_options = new thesis_design_options;
		$design_options->get_options();

		$default_design_options = new thesis_design_options;
		$default_design_options->default_options();

		// Retrieve Thesis Options and Thesis Options defaults
		$thesis_options = new thesis_site_options;
		$thesis_options->get_options();

		$default_options = new thesis_site_options;
		$default_options->default_options();

		if (isset($design_options->teasers) && !is_array($design_options->teasers))
			unset($design_options->teasers);
		if (isset($design_options->feature_box_condition)) {
			$feature_box = $design_options->feature_box;
			unset($design_options->feature_box);
		}
		if (isset($thesis_options->multimedia_box))
			$multimedia_box = $thesis_options->multimedia_box;

		// Ubiquitous options upgrade code
		foreach ($default_design_options as $option_name => $value) {
			if (!isset($design_options->$option_name))
				$design_options->$option_name = $value;
		}

		// 1.7 upgrade
		if (isset($design_options->style))
			$design_options->layout['custom'] = (bool) $design_options->style['custom'];

		// 1.6b niceness
		if (!isset($design_options->nav['link']['parent']))
			$design_options->nav['link']['parent'] = $default_design_options->nav['link']['parent'];
		if (!isset($design_options->nav['background']['parent']))
			$design_options->nav['background']['parent'] = $default_design_options->nav['background']['parent'];

		// Version-specific upgrade code
		if (isset($design_options->font_sizes)) {
			foreach ($design_options->fonts as $area => $family)
				$design_options->fonts['families'][$area] = ($family) ? $family : false;
			foreach ($design_options->font_sizes as $area => $size)
				$design_options->fonts['sizes'][$area] = $size;
		}

		if (isset($design_options->num_columns))
			$design_options->layout['columns'] = $design_options->num_columns;
		if (isset($design_options->widths)) {
			$design_options->layout['widths']['content'] = ($design_options->widths['content']) ? $design_options->widths['content'] : 480;
			$design_options->layout['widths']['sidebar_1'] = ($design_options->widths['sidebar_1']) ? $design_options->widths['sidebar_1'] : 195;
			$design_options->layout['widths']['sidebar_2'] = ($design_options->widths['sidebar_2']) ? $design_options->widths['sidebar_2'] : 195;
		}
		if (isset($design_options->column_order))
			$design_options->layout['order'] = $design_options->column_order;
		if (isset($design_options->html_framework))
			$design_options->layout['framework'] = ($design_options->html_framework) ? $design_options->html_framework : 'page';
		if (isset($design_options->page_padding))
			$design_options->layout['page_padding'] = $design_options->page_padding;

		if (isset($design_options->teaser_options) && isset($design_options->teaser_content)) {
			foreach ($design_options->teaser_content as $teaser_area) {
				$new_teaser_options[$teaser_area]['name'] = $design_options->teasers['options'][$teaser_area]['name'];
				$new_teaser_options[$teaser_area]['show'] = (bool) $design_options->teaser_options[$teaser_area];
			}
			if ($new_teaser_options)
				$design_options->teasers['options'] = $new_teaser_options;
		}
		if (isset($design_options->teaser_date))
			$design_options->teasers['date']['format'] = ($design_options->teaser_date) ? $design_options->teaser_date : 'standard';
		if (isset($design_options->teaser_date_custom))
			$design_options->teasers['date']['custom'] = ($design_options->teaser_date_custom) ? $design_options->teaser_date_custom : 'F j, Y';
		if (isset($design_options->teaser_font_sizes)) {
			foreach ($design_options->teaser_font_sizes as $teaser_area => $size)
				$design_options->teasers['font_sizes'][$teaser_area] = $size;
		}
		if (isset($design_options->teaser_link_text))
			$design_options->teasers['link_text'] = ($design_options->teaser_link_text) ? $design_options->teaser_link_text : false;

		if (isset($feature_box)) {
			$design_options->feature_box['position'] = $feature_box;
			if (isset($design_options->feature_box_condition))
				$design_options->feature_box['status'] = $design_options->feature_box_condition;
			if (isset($design_options->feature_box_after_post))
				$design_options->feature_box['after_post'] = $design_options->feature_box_after_post;
		}

		// Multimedia box
		if (isset($multimedia_box) && is_array($multimedia_box)) {
			foreach ($multimedia_box as $item => $value)
				$design_options->multimedia_box[$item] = $value;
		}
		elseif (isset($multimedia_box)) {
			$design_options->multimedia_box['status'] = $multimedia_box;
			unset($thesis_options->multimedia_box);

			if ($thesis_options->image_alt_tags) {
				foreach ($thesis_options->image_alt_tags as $image_name => $alt_text) {
					if ($alt_text != '')
						$design_options->multimedia_box['alt_tags'][$image_name] = $alt_text;
				}
				unset($thesis_options->image_alt_tags);
			}
			if ($thesis_options->image_link_urls) {
				foreach ($thesis_options->image_link_urls as $image_name => $link_url) {
					if ($link_url != '')
						$design_options->multimedia_box['link_urls'][$image_name] = $link_url;
				}
				unset($thesis_options->image_link_urls);
			}
			if ($thesis_options->video_code) {
				$design_options->multimedia_box['video'] = $thesis_options->video_code;
				unset($thesis_options->video_code);
			}
			if ($thesis_options->custom_code) {
				$design_options->multimedia_box['code'] = $thesis_options->custom_code;
				unset($thesis_options->custom_code);
			}
		}

		// 1.6 Multimedia box style upgrades
		if (!isset($multimedia_box['color']))
			$design_options->multimedia_box['color'] = $default_design_options->multimedia_box['color'];
		if (!isset($multimedia_box['background'])) {
			$design_options->multimedia_box['background']['image'] = $default_design_options->multimedia_box['background']['image'];
			$design_options->multimedia_box['background']['video'] = $default_design_options->multimedia_box['background']['video'];
			$design_options->multimedia_box['background']['code'] = $default_design_options->multimedia_box['background']['code'];
		}

		// Post images and thumbnails
		if (isset($design_options->post_image_horizontal))
			$thesis_options->image['post']['x'] = $design_options->post_image_horizontal;
		if (isset($design_options->post_image_vertical))
			$thesis_options->image['post']['y'] = $design_options->post_image_vertical;
		if (isset($design_options->post_image_frame))
			$thesis_options->image['post']['frame'] = $design_options->post_image_frame;
		if (isset($design_options->post_image_single))
			$thesis_options->image['post']['single'] = $design_options->post_image_single;
		if (isset($design_options->post_image_archives))
			$thesis_options->image['post']['archives'] = $design_options->post_image_archives;
		if (isset($design_options->thumb_horizontal))
			$thesis_options->image['thumb']['x'] = $design_options->thumb_horizontal;
		if (isset($design_options->thumb_vertical))
			$thesis_options->image['thumb']['y'] = $design_options->thumb_vertical;
		if (isset($design_options->thumb_frame))
			$thesis_options->image['thumb']['frame'] = $design_options->thumb_frame;
		if (isset($design_options->thumb_size)) {
			$thesis_options->image['thumb']['width'] = $design_options->thumb_size['width'];
			$thesis_options->image['thumb']['height'] = $design_options->thumb_size['height'];
		}

		// Preserve old font variables
		if ($design_options->font_body)
			$design_options->fonts['families']['body'] = $design_options->font_body;
		if ($design_options->font_content_subheads_family)
			$design_options->fonts['families']['subheads'] = $design_options->font_content_subheads_family;
		if ($design_options->font_nav_family)
			$design_options->fonts['families']['nav_menu'] = $design_options->font_nav_family;
		if ($design_options->font_header_family)
			$design_options->fonts['families']['header'] = $design_options->font_header_family;
		if ($design_options->font_header_tagline_family)
			$design_options->fonts['families']['tagline'] = $design_options->font_header_tagline_family;
		if ($design_options->font_headlines_family)
			$design_options->fonts['families']['headlines'] = $design_options->font_headlines_family;
		if ($design_options->font_bylines_family)
			$design_options->fonts['families']['bylines'] = $design_options->font_bylines_family;
		if ($design_options->font_multimedia_family)
			$design_options->fonts['families']['multimedia_box'] = $design_options->font_multimedia_family;
		if ($design_options->font_sidebars_family)
			$design_options->fonts['families']['sidebars'] = $design_options->font_sidebars_family;
		if ($design_options->font_sidebars_headings_family)
			$design_options->fonts['families']['sidebar_headings'] = $design_options->font_sidebars_headings_family;
		if ($design_options->font_footer_family)
			$design_options->fonts['families']['footer'] = $design_options->font_footer_family;

		// Preserve old font size variables
		if ($design_options->font_content_size)
			$design_options->fonts['sizes']['content'] = $design_options->font_content_size;
		if ($design_options->font_nav_size)
			$design_options->fonts['sizes']['nav_menu'] = $design_options->font_nav_size;
		if ($design_options->font_header_size)
			$design_options->fonts['sizes']['header'] = $design_options->font_header_size;
		if ($design_options->font_headlines_size)
			$design_options->fonts['sizes']['headlines'] = $design_options->font_headlines_size;
		if ($design_options->font_bylines_size)
			$design_options->fonts['sizes']['bylines'] = $design_options->font_bylines_size;
		if ($design_options->font_multimedia_size)
			$design_options->fonts['sizes']['multimedia_box'] = $design_options->font_multimedia_size;
		if ($design_options->font_sidebars_size)
			$design_options->fonts['sizes']['sidebars'] = $design_options->font_sidebars_size;
		if ($design_options->font_footer_size)
			$design_options->fonts['sizes']['footer'] = $design_options->font_footer_size;

		// Preserve old width settings
		if (($design_options->num_columns == 3) && $design_options->width_content_3)
			$design_options->layout['widths']['content'] = $design_options->width_content_3;
		elseif (($design_options->num_columns == 2) && $design_options->width_content_2) {
			$design_options->layout['widths']['content'] = $design_options->width_content_2;
			$design_options->layout['widths']['sidebar_1'] = $design_options->width_sidebar;
		}
		elseif (($design_options->num_columns == 3) && $design_options->width_content_1)
			$design_options->layout['widths']['content'] = $design_options->width_content_1;

		// Clean up the $design_options->fonts array from 1.5b r3 to 1.5
		foreach ($design_options->fonts as $type => $value) {
			if ($type == 'families' || $type == 'sizes')
				$new_fonts_array[$type] = $value;
		}
		$design_options->fonts = $new_fonts_array;

		foreach ($design_options as $option_name => $value) {
			if (!isset($default_design_options->$option_name))
				unset($design_options->$option_name); // Has this option been nuked? If so, kill it!
		}

		update_option('thesis_design_options', $design_options); // Save upgraded options
		update_option('thesis_options', $thesis_options);
		thesis_generate_css();
	}
	
	function options_page() {
		global $thesis_site, $thesis_design, $thesis_pages;
		$fonts = $thesis_design->fonts;
		$colors = $thesis_design->colors;
		$borders = $thesis_design->borders;
		$nav = $thesis_design->nav;
		$layout = $thesis_design->layout;
		$image = $thesis_design->image;
		$comments = $thesis_design->comments;
		$teasers = $thesis_design->teasers;
		$feature_box = $thesis_design->feature_box;
		$multimedia_box = $thesis_design->multimedia_box;
		$javascript = $thesis_design->javascript;
		$font_stacks = thesis_get_fonts();
?>

<div id="thesis_options" class="wrap<?php if (get_bloginfo('text_direction') == 'rtl') { echo ' rtl'; } ?>">
<?php
	thesis_version_indicator();
	thesis_options_title(__('Thesis Design Options', 'thesis'));
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

	<form class="thesis" action="<?php echo admin_url('admin-post.php?action=thesis_design_options'); ?>" method="post">
		<div class="options_column">
			<div class="options_module" id="font-selector">
				<h3><?php _e('Fonts, Colors, and More!', 'thesis'); ?></h3>
				<div class="module_subsection">
					<h4 class="module_switch"><a href="" title="<?php _e('Show/hide additional information', 'thesis'); ?>"><span class="pos">+</span><span class="neg">&#8211;</span></a><?php _e('Body (and Content Area)', 'thesis'); ?></h4>
					<div class="more_info">
						<p><?php _e('The font you select here will be the main font on your site. You can tweak individual fonts and sizes below.', 'thesis'); ?></p>
						<p class="form_input add_margin">
							<select id="fonts[families][body]" name="fonts[families][body]" size="1">
<?php
						foreach ($font_stacks as $font_key => $font) {
							$selected = ($fonts['families']['body'] == $font_key) ? ' selected="selected"' : '';
							$web_safe = ($font['web_safe']) ? ' *' : '';
							echo "<option$selected value=\"$font_key\">" . $font['name'] . "$web_safe</option>\n";
						}
?>
							</select>
						</p>
						<p class="tip add_margin"><?php _e('Asterisks (*) denote web-safe fonts.', 'thesis'); ?></p>
						<p><?php _e('<strong class="new">New!</strong> Add some personal flair to your design by using the controls below. This is only a taste of what you can expect in Thesis 2.0, but it should give you a nice start nonetheless. Also, don&#8217;t miss the new color controls that you&#8217;ll find in the other options below!', 'thesis'); ?></p>
						<p class="form_input add_margin">
							<input class="short color" type="text" id="colors[background]" name="colors[background]" value="<?php echo $colors['background']; ?>" maxlength="6" />
							<label class="inline" for="colors[background]"><?php _e('site background color', 'thesis'); ?></label>
						</p>
						<p class="form_input add_margin">
							<input class="short color" type="text" id="colors[page]" name="colors[page]" value="<?php echo $colors['page']; ?>" maxlength="6" />
							<label class="inline" for="colors[page]"><?php _e('page background color', 'thesis'); ?></label>
						</p>
						<p class="form_input add_margin">
							<input class="short color" type="text" id="colors[text]" name="colors[text]" value="<?php echo $colors['text']; ?>" maxlength="6" />
							<label class="inline" for="colors[text]"><?php _e('primary text color', 'thesis'); ?></label>
						</p>
						<p class="form_input add_margin">
							<input class="short color" type="text" id="colors[link]" name="colors[link]" value="<?php echo $colors['link']; ?>" maxlength="6" />
							<label class="inline" for="colors[link]"><?php _e('primary link color', 'thesis'); ?></label>
						</p>
						<p>
						<ul>
							<li><input type="checkbox" id="colors[shadow]" name="colors[shadow]" value="1" <?php if ($colors['shadow']) echo 'checked="checked" '; ?>/><label for="colors[shadow]"><?php _e('Add a cool shadow effect to your layout', 'thesis'); ?></label></li>
							<li><input type="checkbox" id="borders[show]" name="borders[show]" value="1" <?php if ($borders['show']) echo 'checked="checked" '; ?>/><label for="borders[show]"><?php _e('Show interior layout borders', 'thesis'); ?></label></li>
						</ul>
					</div>
				</div>
<?php
			$layout_areas = thesis_layout_areas();

			foreach ($layout_areas as $area_key => $area) {
?>
				<div class="module_subsection">
					<h4 class="module_switch"><a href="" title="<?php _e('Show/hide additional information', 'thesis'); ?>"><span class="pos">+</span><span class="neg">&#8211;</span></a><?php echo $area['name']; ?></h4>
					<div class="more_info">
						<p><?php echo $area['intro_text']; ?></p>
<?php
				if ($area['define_font']) {
?>
						<p class="form_input add_margin">
							<select id="fonts[families][<?php echo $area_key; ?>]" name="fonts[families][<?php echo $area_key; ?>]" size="1">
<?php
						$selected = (!$fonts['families'][$area_key]) ? ' selected="selected"' : '';
						echo "<option$selected value=\"\">Inherited from Body</option>\n";

						foreach ($font_stacks as $font_key => $font) {
							$selected = ($fonts['families'][$area_key] == $font_key) ? ' selected="selected"' : '';
							$web_safe = ($font['web_safe']) ? ' *' : '';

							if ($area_key == 'code') {
								if ($font['monospace'])
									echo "<option$selected value=\"$font_key\">" . $font['name'] . "$web_safe</option>\n";
							}
							else
								echo "<option$selected value=\"$font_key\">" . $font['name'] . "$web_safe</option>\n";
						}
?>
							</select>
						</p>
<?php
				}
?>
						<p class="form_input add_margin">
							<select id="fonts[sizes][<?php echo $area_key; ?>]" name="fonts[sizes][<?php echo $area_key; ?>]" size="1">
<?php
						foreach ($area['font_sizes'] as $size) {
							$selected = ($fonts['sizes'][$area_key] == $size) ? ' selected="selected"' : '';
							echo "<option$selected value=\"$size\">$size pt.</option>\n";
						}
?>
							</select>
						</p>
<?php
				$has_secondary = ($area['secondary_font']) ? ' add_margin' : '';

				if ($area_key != 'content' && $area_key != 'nav_menu' && $area_key != 'multimedia_box')
					echo "<p class=\"form_input$has_secondary\">\n\t<input class=\"short color\" type=\"text\" id=\"colors[$area_key]\" name=\"colors[$area_key]\" value=\"" . $colors[$area_key] . "\" />\n\t<label class=\"inline\" for=\"colors[$area_key]\">" . $area['name'] . ' ' . __('text color', 'thesis') . "</label>\n</p>\n";

				if ($area_key == 'nav_menu') {
?>
						<p class="form_input add_margin">
							<input class="short color" type="text" id="nav[link][color]" name="nav[link][color]" value="<?php echo $nav['link']['color']; ?>" maxlength="6" />
							<label class="inline" for="nav[link][color]"><?php _e('link text color', 'thesis'); ?></label>
						</p>
						<p class="form_input add_margin">
							<input class="short color" type="text" id="nav[link][hover]" name="nav[link][hover]" value="<?php echo $nav['link']['hover']; ?>" maxlength="6" />
							<label class="inline" for="nav[link][hover]"><?php _e('link text hover color', 'thesis'); ?></label>
						</p>
						<p class="form_input add_margin">
							<input class="short color" type="text" id="nav[link][current]" name="nav[link][current]" value="<?php echo $nav['link']['current']; ?>" maxlength="6" />
							<label class="inline" for="nav[link][current]"><?php _e('current link text color', 'thesis'); ?></label>
						</p>
						<p class="form_input add_margin">
							<input class="short color" type="text" id="nav[link][parent]" name="nav[link][parent]" value="<?php echo $nav['link']['parent']; ?>" maxlength="6" />
							<label class="inline" for="nav[link][parent]"><?php _e('current parent link text color', 'thesis'); ?></label>
						</p>
						<p class="form_input add_margin">
							<input class="short color" type="text" id="nav[background][link]" name="nav[background][link]" value="<?php echo $nav['background']['link']; ?>" maxlength="6" />
							<label class="inline" for="nav[background][link]"><?php _e('link background color', 'thesis'); ?></label>
						</p>
						<p class="form_input add_margin">
							<input class="short color" type="text" id="nav[background][hover]" name="nav[background][hover]" value="<?php echo $nav['background']['hover']; ?>" maxlength="6" />
							<label class="inline" for="nav[background][hover]"><?php _e('hover background color', 'thesis'); ?></label>
						</p>
						<p class="form_input add_margin">
							<input class="short color" type="text" id="nav[background][current]" name="nav[background][current]" value="<?php echo $nav['background']['current']; ?>" maxlength="6" />
							<label class="inline" for="nav[background][current]"><?php _e('current background color', 'thesis'); ?></label>
						</p>
						<p class="form_input add_margin">
							<input class="short color" type="text" id="nav[background][parent]" name="nav[background][parent]" value="<?php echo $nav['background']['parent']; ?>" maxlength="6" />
							<label class="inline" for="nav[background][parent]"><?php _e('current parent background color', 'thesis'); ?></label>
						</p>
						<p class="form_input add_margin">
							<input class="short" type="text" id="nav[border][width]" name="nav[border][width]" value="<?php echo $nav['border']['width']; ?>" />
							<label class="inline" for="nav[border][width]"><?php _e('nav border width (px)', 'thesis'); ?></label>
						</p>
						<p class="form_input add_margin">
							<input class="short color" type="text" id="nav[border][color]" name="nav[border][color]" value="<?php echo $nav['border']['color']; ?>" maxlength="6" />
							<label class="inline" for="nav[border][color]"><?php _e('nav border color', 'thesis'); ?></label>
						</p>
						<p class="form_input">
							<input class="short" type="text" id="nav[submenu_width]" name="nav[submenu_width]" value="<?php echo $nav['submenu_width']; ?>" />
							<label class="inline" for="nav[submenu_width]"><?php _e('submenu width (px)', 'thesis'); ?></label>
						</p>
<?php
				}
				elseif ($area_key == 'multimedia_box') {
?>
						<p class="form_input add_margin">
							<input class="short color" type="text" id="multimedia_box[color]" name="multimedia_box[color]" value="<?php echo $multimedia_box['color']; ?>" maxlength="6" />
							<label class="inline" for="multimedia_box[color]"><?php _e('text color', 'thesis'); ?></label>
						</p>
						<p class="form_input add_margin">
							<input class="short color" type="text" id="multimedia_box[background][image]" name="multimedia_box[background][image]" value="<?php echo $multimedia_box['background']['image']; ?>" maxlength="6" />
							<label class="inline" for="multimedia_box[background][image]"><?php _e('image box background color', 'thesis'); ?></label>
						</p>
						<p class="form_input add_margin">
							<input class="short color" type="text" id="multimedia_box[background][video]" name="multimedia_box[background][video]" value="<?php echo $multimedia_box['background']['video']; ?>" maxlength="6" />
							<label class="inline" for="multimedia_box[background][video]"><?php _e('video box background color', 'thesis'); ?></label>
						</p>
						<p class="form_input">
							<input class="short color" type="text" id="multimedia_box[background][code]" name="multimedia_box[background][code]" value="<?php echo $multimedia_box['background']['code']; ?>" maxlength="6" />
							<label class="inline" for="multimedia_box[background][code]"><?php _e('custom box background color', ' thesis'); ?></label>
						</p>
<?php	
				}

				if ($area['secondary_font']) {
?>
						<p class="label_note"><?php echo $area['secondary_font']['item_name']; ?></p>
						<p><?php echo $area['secondary_font']['item_intro']; ?></p>
						<p class="form_input add_margin">
							<select id="fonts[families][<?php echo $area['secondary_font']['item_reference']; ?>]" name="fonts[families][<?php echo $area['secondary_font']['item_reference']; ?>]" size="1">
<?php
						$selected = (!$fonts['families'][$area['secondary_font']['item_reference']]) ? ' selected="selected"' : '';
						echo "<option$selected value=\"\">Inherited from " . $area['name'] . "</option>\n";

						foreach ($font_stacks as $font_key => $font) {
							$selected = ($fonts['families'][$area['secondary_font']['item_reference']] == $font_key) ? ' selected="selected"' : '';
							$web_safe = ($font['web_safe']) ? ' *' : '';

							echo "<option$selected value=\"$font_key\">" . $font['name'] . "$web_safe</option>\n";
						}
?>
							</select>
						</p>
<?php
					if ($area['secondary_font']['item_sizes']) {
?>
						<p class="form_input add_margin">
							<select id="fonts[sizes][<?php echo $area['secondary_font']['item_reference']; ?>]" name="fonts[sizes][<?php echo $area['secondary_font']['item_reference']; ?>]" size="1">
<?php
						foreach ($area['secondary_font']['item_sizes'] as $size) {
							$selected = ($fonts['sizes'][$area['secondary_font']['item_reference']] == $size) ? ' selected="selected"' : '';
							echo "<option$selected value=\"$size\">$size pt.</option>\n";
						}
?>
							</select>
						</p>
<?php
					}

					echo "<p class=\"form_input\">\n\t<input class=\"short color\" type=\"text\" id=\"colors[" . $area['secondary_font']['item_reference'] . ']" name="colors[' . $area['secondary_font']['item_reference'] . ']" value="' . $colors[$area['secondary_font']['item_reference']] . "\" />\n\t<label class=\"inline\" for=\"colors[" . $area['secondary_font']['item_reference'] . ']">' . $area['secondary_font']['item_name'] . ' ' . __('text color', 'thesis') . "</label>\n</p>\n";
				}
?>
					</div>
				</div>
<?php
			}
?>
			</div>
			<div class="options_module" id="javascript-options">
				<h3><?php _e('JavaScript', 'thesis'); ?></h3>
				<div class="module_subsection" id="javascript-libs">
					<h4 class="module_switch"><a href="" title="<?php _e('Show/hide additional information', 'thesis'); ?>"><span class="pos">+</span><span class="neg">&#8211;</span></a><?php _e('Included <acronym title="JavaScript">JS</acronym> Libraries', 'thesis'); ?></h4>
					<div class="more_info">
						<p><?php printf(__('Include cached versions of the most popular <acronym title="JavaScript">JS</acronym> libraries by selecting from the list below. These libraries will be served sitewide, but you can fine-tune your <acronym title="JavaScript">JS</acronym> libraries on any post or page and on <a href="%s">category and tag pages</a>.', 'thesis'), get_bloginfo('wpurl') . '/wp-admin/admin.php?page=thesis-pages'); ?></p>
						<ul>
<?php
						$thesis_javascript = new thesis_javascript;
						foreach ($thesis_javascript->libs as $lib_name => $lib) {
							$checked = ($javascript['libs'][$lib_name]) ? ' checked="checked" ' : '';
							echo "\t\t\t\t\t\t\t" . '<li><input type="checkbox" id="javascript[libs][' . $lib_name . ']" name="javascript[libs][' . $lib_name . ']" value="1"' . $checked . '/><label>' . sprintf(__('%1$s <a href="%2$s" target="_blank">[?]</a>', 'thesis'), $lib['name'], $lib['info_url']) . "</label></li>\n";
						}
?>
						</ul>
					</div>
				</div>
				<div class="module_subsection" id="javascript-scripts">
					<h4 class="module_switch"><a href="" title="<?php _e('Show/hide additional information', 'thesis'); ?>"><span class="pos">+</span><span class="neg">&#8211;</span></a><?php _e('Embedded Scripts', 'thesis'); ?></h4>
					<div class="more_info">
						<p><?php _e('The scripts you add here will be served after the <acronym title="HyperText Markup Language">HTML</acronym> on <em>every page of your site</em>. This is the preferred position because it prevents the scripts from interrupting the page load.', 'thesis'); ?></p>
						<p class="form_input">
							<label for="javascript[scripts]"><?php _e('JavaScripts (include <code>&lt;script&gt;</code> tags!)', 'thesis'); ?></label>
							<textarea class="scripts" id="javascript[scripts]" name="javascript[scripts]"><?php if ($javascript['scripts']) thesis_massage_code($javascript['scripts']); ?></textarea>
						</p>
					</div>
				</div>
			</div>
		</div>

		<div class="options_column">
			<div class="options_module" id="layout-constructor">
				<h3><?php _e('Site Layout', 'thesis'); ?></h3>
				<div class="module_subsection" id="html-framework">
					<h4 class="module_switch"><a href="" title="<?php _e('Show/hide additional information', 'thesis'); ?>"><span class="pos">+</span><span class="neg">&#8211;</span></a><?php _e('<acronym title="HyperText Markup Language">HTML</acronym> Framework', 'thesis'); ?></h4>
					<div class="more_info">
						<p><?php _e('If you&#8217;re customizing your Thesis design, you may wish to employ a different <acronym title="HyperText Markup Language">HTML</acronym> framework in order to better suit your design needs. There are two primary types of frameworks that should accommodate just about any type of design&#8212;<strong>page</strong> and <strong>full-width</strong>. By default, Thesis uses the page framework, but you can change that below.', 'thesis'); ?></p>
						<ul>
							<li><input type="radio" name="layout[framework]" value="page" <?php if ($layout['framework'] != 'full-width') echo 'checked="checked" '; ?>/><label><?php _e('Page framework', 'thesis'); ?></label></li>
							<li><input type="radio" name="layout[framework]" value="full-width" <?php if ($layout['framework'] == 'full-width') echo 'checked="checked" '; ?>/><label><?php _e('Full-width framework', 'thesis'); ?></label></li>
						</ul>
					</div>
				</div>
				<div class="module_subsection">
					<h4 class="module_switch"><a href="" title="<?php _e('Show/hide additional information', 'thesis'); ?>"><span class="pos">+</span><span class="neg">&#8211;</span></a><?php _e('Outer Page Padding', 'thesis'); ?></h4>
					<div class="more_info">
						<p><?php _e('By default, Thesis adds whitespace around your layout for styling purposes. One unit of whitespace is equal to the line height of the text in your content area, and by default, Thesis adds one unit of whitespace around your layout. How many units of whitespace would you like around your layout?', 'thesis'); ?></p>
						<p class="form_input">
							<select id="layout[page_padding]" name="layout[page_padding]" size="1">
<?php
						for ($k = 0; $k <= 8; $k++) {
							$padding = $k / 2;
							$selected = ($layout['page_padding'] == $padding) ? ' selected="selected"' : '';
							echo "\t\t\t\t\t\t\t\t<option value=\"$padding\"$selected>" . number_format($padding, 1) . "</option>\n";
						}
?>
							</select>
						</p>
					</div>
				</div>
				<div class="module_subsection">
					<h4 class="module_switch"><a href="" title="<?php _e('Show/hide additional information', 'thesis'); ?>"><span class="pos">+</span><span class="neg">&#8211;</span></a><?php _e('Columns', 'thesis'); ?></h4>
					<div class="more_info">
						<p><?php _e('Select the number of columns you want in your layout:', 'thesis'); ?></p>
						<p class="form_input add_margin" id="num_columns">
							<select id="layout[columns]" name="layout[columns]" size="1">
								<option value="3"<?php if ($layout['columns'] == 3) echo ' selected="selected"'; ?>><?php _e('3 columns', 'thesis'); ?></option>
								<option value="2"<?php if ($layout['columns'] == 2) echo ' selected="selected"'; ?>><?php _e('2 columns', 'thesis'); ?></option>
								<option value="1"<?php if ($layout['columns'] == 1) echo ' selected="selected"'; ?>><?php _e('1 column', 'thesis'); ?></option>
							</select>
						</p>
						<p><?php _e('Enter a width between 300 and 934 pixels for your <strong>content column</strong>:', 'thesis'); ?></p>
						<p id="width_content" class="form_input">
							<input type="text" class="short" id="layout[widths][content]" name="layout[widths][content]" value="<?php echo $layout['widths']['content']; ?>" />
							<label for="layout[widths][content]" class="inline"><?php _e('px', 'thesis'); ?></label>
						</p>
						<div id="width_sidebar_1">
							<p><?php _e('Enter a width between 60 and 500 pixels for <strong>sidebar 1</strong>:', 'thesis'); ?></p>
							<p class="form_input add_margin">
								<input type="text" class="short" id="layout[widths][sidebar_1]" name="layout[widths][sidebar_1]" value="<?php echo $layout['widths']['sidebar_1']; ?>" />
								<label for="layout[widths][sidebars_1]" class="inline"><?php _e('px (default is 195)', 'thesis'); ?></label>
							</p>
						</div>
						<div id="width_sidebar_2">
							<p><?php _e('Enter a width between 60 and 500 pixels for <strong>sidebar 2</strong>:', 'thesis'); ?></p>
							<p class="form_input add_margin">
								<input type="text" class="short" id="layout[widths][sidebar_2]" name="layout[widths][sidebar_2]" value="<?php echo $layout['widths']['sidebar_2']; ?>" />
								<label for="layout[widths][sidebar_2]" class="inline"><?php _e('px (default is 195)', 'thesis'); ?></label>
							</p>
						</div>
					</div>
				</div>
				<div class="module_subsection" id="column_order">
					<h4 class="module_switch"><a href="" title="<?php _e('Show/hide additional information', 'thesis'); ?>"><span class="pos">+</span><span class="neg">&#8211;</span></a><?php _e('Column Order', 'thesis'); ?></h4>
					<div class="more_info">
						<ul class="column_structure" id="order_3_col">
							<li>
								<input type="radio" name="layout[order]" value="normal" <?php if ($layout['order'] == 'normal' && $layout['columns'] == 3) echo 'checked="checked" '; ?>/><label><?php _e('Content, Sidebar 1, Sidebar 2 <span>&darr;</span>', 'thesis'); ?></label>
								<p><span class="col_content">Content</span><span class="col_sidebar">S1</span><span class="col_sidebar no_margin">S2</span></p>
							</li>
							<li>
								<input type="radio" name="layout[order]" value="invert" <?php if ($layout['order'] == 'invert') echo 'checked="checked" '; ?>/><label><?php _e('Sidebar 1, Content, Sidebar 2 <span>&darr;</span>', 'thesis'); ?></label>
								<p><span class="col_sidebar">S1</span><span class="col_content">Content</span><span class="col_sidebar no_margin">S2</span></p>
							</li>
							<li>
								<input type="radio" name="layout[order]" value="0" <?php if (!$layout['order'] && $layout['columns'] == 3) echo 'checked="checked" '; ?>/><label><?php _e('Sidebar 1, Sidebar 2, Content <span>&darr;</span>', 'thesis'); ?></label>
								<p><span class="col_sidebar">S1</span><span class="col_sidebar">S2</span><span class="col_content no_margin">Content</span></p>
							</li>
						</ul>
						<ul class="column_structure" id="order_2_col">
							<li>
								<input type="radio" name="layout[order]" value="normal" <?php if ($layout['order'] == 'normal' && $layout['columns'] == 2) echo 'checked="checked" '; ?>/><label><?php _e('Content, Sidebar 1 <span>&darr;</span>', 'thesis'); ?></label>
								<p><span class="col_content">Content</span><span class="col_sidebar">S1</span></p>
							</li>
							<li>
								<input type="radio" name="layout[order]" value="0" <?php if (!$layout['order'] && $layout['columns'] == 2) echo 'checked="checked" '; ?>/><label><?php _e('Sidebar 1, Content <span>&darr;</span>', 'thesis'); ?></label>
								<p><span class="col_sidebar">S1</span><span class="col_content no_margin">Content</span></p>
							</li>
						</ul>
					</div>
				</div>
				<div class="module_subsection">
					<h4 class="module_switch"><a href="" title="<?php _e('Show/hide additional information', 'thesis'); ?>"><span class="pos">+</span><span class="neg">&#8211;</span></a><?php _e('Custom Stylesheet', 'thesis'); ?></h4>
					<div class="more_info">
						<p><?php _e('If you want to make stylistic changes with <acronym title="Cascading Style Sheet">CSS</acronym>, you should use the Thesis custom stylesheet to do so.', 'thesis'); ?></p>
<?php
						if (!file_exists(THESIS_CUSTOM))
							echo '<p class="tip add_margin">' . __('Your custom stylesheet <strong>will not work</strong> until you rename your <code>/custom-sample</code> folder to <code>/custom</code>.', 'thesis') . "</p>\n";
?>
						<ul>
							<li><input type="checkbox" id="layout[custom]" name="layout[custom]" value="1" <?php if ($layout['custom']) echo 'checked="checked" '; ?>/><label for="layout[custom]"><?php _e('Use custom stylesheet', 'thesis'); ?></label></li>
						</ul>
					</div>
				</div>
			</div>
			<div class="options_module" id="post-image-options">
				<h3><?php _e('Post Images and Thumbnails', 'thesis'); ?></h3>
				<div class="module_subsection" id="post-images">
					<h4 class="module_switch"><a href="" title="<?php _e('Show/hide additional information', 'thesis'); ?>"><span class="pos">+</span><span class="neg">&#8211;</span></a><?php _e('Default Post Image Settings', 'thesis'); ?></h4>
					<div class="more_info">
						<p><?php _e('Post images are a perfect way to add more visual punch to your site. To use them, simply specify a post image in the appropriate field on the post editing screen. During the normal stream of content, post images will display full-size, and by default, they will be automatically cropped into smaller thumbnail images for use in other areas (like teasers and excerpts).', 'thesis'); ?></p>
						<p><?php _e('Don&#8217;t want Thesis to auto-crop your thumbnails? No worries&#8212;you can override this by uploading your own thumbnail image on <em>any</em> post or page. Also, it&#8217;s worth noting that you can override <em>all</em> of the settings below on the post editing screen.', 'thesis'); ?></p>
						<p class="label_note"><?php _e('Horizontal position', 'thesis'); ?></p>
						<ul class="add_margin">
							<li><input type="radio" name="image[post][x]" value="flush" <?php if ($image['post']['x'] == 'flush') echo 'checked="checked" '; ?>/><label><?php _e('Flush left with no text wrap', 'thesis'); ?></label></li>
							<li><input type="radio" name="image[post][x]" value="left" <?php if ($image['post']['x'] == 'left') echo 'checked="checked" '; ?>/><label><?php _e('Left with text wrap', 'thesis'); ?></label></li>
							<li><input type="radio" name="image[post][x]" value="right" <?php if ($image['post']['x'] == 'right') echo 'checked="checked" '; ?>/><label><?php _e('Right with text wrap', 'thesis'); ?></label></li>
							<li><input type="radio" name="image[post][x]" value="center" <?php if ($image['post']['x'] == 'center') echo 'checked="checked" '; ?>/><label><?php _e('Centered (no wrap)', 'thesis'); ?></label></li>
						</ul>
						<p class="label_note"><?php _e('Vertical position', 'thesis'); ?></p>
						<ul class="add_margin">
							<li><input type="radio" name="image[post][y]" value="before-headline" <?php if ($image['post']['y'] == 'before-headline') echo 'checked="checked" '; ?>/><label><?php _e('Above headline', 'thesis'); ?></label></li>
							<li><input type="radio" name="image[post][y]" value="after-headline" <?php if ($image['post']['y'] == 'after-headline') echo 'checked="checked" '; ?>/><label><?php _e('Below headline', 'thesis'); ?></label></li>
							<li><input type="radio" name="image[post][y]" value="before-post" <?php if ($image['post']['y'] == 'before-post') echo 'checked="checked" '; ?>/><label><?php _e('Before post/page content', 'thesis'); ?></label></li>
						</ul>
						<ul>
							<li><input type="checkbox" id="image[post][frame]" name="image[post][frame]" value="1" <?php if ($image['post']['frame'] == 'on') echo 'checked="checked" '; ?>/><label for="image[post][frame]"><?php _e('Add a frame to post images', 'thesis'); ?></label></li>
							<li><input type="checkbox" id="image[post][single]" name="image[post][single]" value="1" <?php if ($image['post']['single']) echo 'checked="checked" '; ?>/><label for="image[post][single]"><?php _e('Show images on single entry pages', 'thesis'); ?></label></li>
							<li><input type="checkbox" id="image[post][archives]" name="image[post][archives]" value="1" <?php if ($image['post']['archives']) echo 'checked="checked" '; ?>/><label for="image[post][archives]"><?php _e('Show images on archives pages', 'thesis'); ?></label></li>
						</ul>
					</div>
				</div>
				<div class="module_subsection" id="thumbnail-images">
					<h4 class="module_switch"><a href="" title="<?php _e('Show/hide additional information', 'thesis'); ?>"><span class="pos">+</span><span class="neg">&#8211;</span></a><?php _e('Default Thumbnail Settings', 'thesis'); ?></h4>
					<div class="more_info">
						<p class="label_note"><?php _e('Horizontal position', 'thesis'); ?></p>
						<ul class="add_margin">
							<li><input type="radio" name="image[thumb][x]" value="flush" <?php if ($image['thumb']['x'] == 'flush') echo 'checked="checked" '; ?>/><label><?php _e('Flush left with no text wrap', 'thesis'); ?></label></li>
							<li><input type="radio" name="image[thumb][x]" value="left" <?php if ($image['thumb']['x'] == 'left') echo 'checked="checked" '; ?>/><label><?php _e('Left with text wrap', 'thesis'); ?></label></li>
							<li><input type="radio" name="image[thumb][x]" value="right" <?php if ($image['thumb']['x'] == 'right') echo 'checked="checked" '; ?>/><label><?php _e('Right with text wrap', 'thesis'); ?></label></li>
							<li><input type="radio" name="image[thumb][x]" value="center" <?php if ($image['thumb']['x'] == 'center') echo 'checked="checked" '; ?>/><label><?php _e('Centered (no wrap)', 'thesis'); ?></label></li>
						</ul>
						<p class="label_note"><?php _e('Vertical position', 'thesis'); ?></p>
						<ul class="add_margin">
							<li><input type="radio" name="image[thumb][y]" value="before-headline" <?php if ($image['thumb']['y'] == 'before-headline') echo 'checked="checked" '; ?>/><label><?php _e('Above headline', 'thesis'); ?></label></li>
							<li><input type="radio" name="image[thumb][y]" value="after-headline" <?php if ($image['thumb']['y'] == 'after-headline') echo 'checked="checked" '; ?>/><label><?php _e('Below headline', 'thesis'); ?></label></li>
							<li><input type="radio" name="image[thumb][y]" value="before-post" <?php if ($image['thumb']['y'] == 'before-post') echo 'checked="checked" '; ?>/><label><?php _e('Before post/page content', 'thesis'); ?></label></li>
						</ul>
						<ul class="add_margin">
							<li><input type="checkbox" id="image[thumb][frame]" name="image[thumb][frame]" value="1" <?php if ($image['thumb']['frame'] == 'on') echo 'checked="checked" '; ?>/><label for="image[thumb][frame]"><?php _e('Add a frame to thumbnail images', 'thesis'); ?></label></li>
						</ul>
						<p><?php _e('If you do not supply a thumbnail image on a particular post (in addition to or in place of a post image), the post image that you upload will be auto-cropped to these dimensions and re-saved for use as a thumbnail:', 'thesis'); ?></p>
						<p class="form_input add_margin">
							<input type="text" class="short" id="image[thumb][width]" name="image[thumb][width]" value="<?php if ($image['thumb']['width']) echo $image['thumb']['width']; ?>" />
							<label for="image[thumb][width]" class="inline"><?php _e('default thumbnail width', 'thesis'); ?></label>
						</p>
						<p class="form_input">
							<input type="text" class="short" id="image[thumb][height]" name="image[thumb][height]" value="<?php if ($image['thumb']['height']) echo $image['thumb']['height']; ?>" />
							<label for="image[thumb][height]" class="inline"><?php _e('default thumbnail height', 'thesis'); ?></label>
						</p>
					</div>
				</div>
			</div>
			<div class="options_module" id="teaser-options">
				<h3><?php _e('Teasers', 'thesis'); ?></h3>
				<div class="module_subsection">
					<h4 class="module_switch"><a href="" title="<?php _e('Show/hide additional information', 'thesis'); ?>"><span class="pos">+</span><span class="neg">&#8211;</span></a><?php _e('Teaser Display Options'); ?></h4>
					<div class="more_info">
						<p><?php _e('Pick and choose what you want your teasers to display! Drag and drop the elements to change the order in which they appear on your site.', 'thesis'); ?></p>
						<ul id="teaser_content" class="sortable">
<?php
						foreach ($teasers['options'] as $teaser_item => $teaser) {
							$checked = ($teaser['show']) ? ' checked="checked"' : '';

							if ($teaser_item == 'date')
								$id = 'teasers_date_show';
							elseif ($teaser_item == 'link')
								$id = 'teasers_link_show';
							else
								$id = "teasers[options][$teaser_item][show]";

							echo "\t\t\t\t\t\t\t\t<li><input type=\"checkbox\" class=\"checkbox\" id=\"$id\" name=\"teasers[options][$teaser_item][show]\" value=\"1\"$checked /> " . $teaser['name'] . "<input type=\"hidden\" name=\"teasers[options][$teaser_item][name]\" value=\"" . $teaser['name'] . "\" /></li>\n";
						}
?>
						</ul>
					</div>
				</div>
				<div class="module_subsection" id="teaser_date_format">
					<h4 class="module_switch"><a href="" title="<?php _e('Show/hide additional information', 'thesis'); ?>"><span class="pos">+</span><span class="neg">&#8211;</span></a><?php _e('Teaser Date Format', 'thesis'); ?></h4>
					<ul class="more_info">
						<li><input type="radio" name="teasers[date][format]" value="standard" <?php if ($teasers['date']['format'] == 'standard') echo 'checked="checked" '; ?>/><label><?php echo(date('F j, Y')); ?></label></li>
						<li><input type="radio" name="teasers[date][format]" value="no_comma" <?php if ($teasers['date']['format'] == 'no_comma') echo 'checked="checked" '; ?>/><label><?php echo(date('j F Y')); ?></label></li>
						<li><input type="radio" name="teasers[date][format]" value="numeric" <?php if ($teasers['date']['format'] == 'numeric') echo 'checked="checked" '; ?>/><label><?php echo(date('m.d.Y')); ?></label></li>
						<li><input type="radio" name="teasers[date][format]" value="reversed" <?php if ($teasers['date']['format'] == 'reversed') echo 'checked="checked" '; ?>/><label><?php echo(date('d.m.Y')); ?></label></li>
						<li><input type="radio" name="teasers[date][format]" value="custom" <?php if ($teasers['date']['format'] == 'custom') echo 'checked="checked" '; ?>/><label><?php _e('Custom: ', 'thesis'); ?> <input type="text" class="date_entry" name="teasers[date][custom]" value="<?php echo $teasers['date']['custom']; ?>" /> <a href="http://us.php.net/manual/en/function.date.php" target="_blank" title="See the full list of PHP date formats">[?]</a></label></li>
					</ul>
				</div>
				<div class="module_subsection" id="teaser_link">
					<h4 class="module_switch"><a href="" title="<?php _e('Show/hide additional information', 'thesis'); ?>"><span class="pos">+</span><span class="neg">&#8211;</span></a><?php _e('Link to Full Article', 'thesis'); ?></h4>
					<p class="more_info form_input">
						<input type="text" id="teasers[link_text]" name="teasers[link_text]" value="<?php echo urldecode($teasers['link_text']); ?>" />
						<label for="teasers[link_text]"><?php _e('link display text', 'thesis'); ?></label>
					</p>
				</div>
				<div class="module_subsection" id="teaser_fonts">
					<h4 class="module_switch"><a href="" title="<?php _e('Show/hide additional information', 'thesis'); ?>"><span class="pos">+</span><span class="neg">&#8211;</span></a><?php _e('Teaser Font Sizes', 'thesis'); ?></h4>
					<div class="more_info">
						<p><?php _e('Use the controls below to fine-tune the font sizes of your teaser elements.', 'thesis'); ?></p>
<?php
					$teaser_areas = thesis_teaser_areas();
					$area_count = 1;

					foreach ($teaser_areas as $teaser_area => $available_sizes) {
						$add_margin = ($area_count == count($teaser_areas)) ? '' : ' add_margin';
?>
						<p class="form_input<?php echo $add_margin; ?>">
							<select id="teasers[font_sizes][<?php echo $teaser_area; ?>]" name="teasers[font_sizes][<?php echo $teaser_area; ?>]" size="1">
<?php
						foreach ($available_sizes as $available_size) {
							$selected = ($teasers['font_sizes'][$teaser_area] == $available_size) ? ' selected="selected"' : '';
							echo "\t\t\t\t\t\t\t\t\t<option value=\"$available_size\"$selected>$available_size pt.</option>\n";
						}
?>
							</select>
							<label for="teasers[font_sizes][<?php echo $teaser_area; ?>]"><?php _e($teasers['options'][$teaser_area]['name'] . ' font size', 'thesis'); ?></label>
						</p>
<?php
						$area_count++;
					}
?>
					</div>
				</div>
			</div>
		</div>

		<div class="options_column">
			<div class="options_module button_module">
				<input type="submit" class="save_button" id="design_submit" name="submit" value="<?php thesis_save_button_text(); ?>" />
			</div>
			<div class="options_module" id="comment-options">
				<h3><?php _e('Comment Options', 'thesis'); ?></h3>
				<div class="module_subsection">
					<h4 class="module_switch"><a href="" title="<?php _e('Show/hide additional information', 'thesis'); ?>"><span class="pos">+</span><span class="neg">&#8211;</span></a><?php _e('Display Settings', 'thesis'); ?></h4>
					<div class="more_info">
						<p><?php _e('Select the elements that you&#8217;d like to display, and then drag and drop them into the order that you want!', 'thesis'); ?></p>
						<ul id="comment_elements" class="sortable">
<?php
						foreach ($comments as $element_name => $element) {
							$checked = ($element['show']) ? ' checked="checked"' : '';
							echo "\t\t\t\t\t\t\t\t<li><input type=\"checkbox\" class=\"checkbox\" id=\"comments[$element_name][show]\" name=\"comments[$element_name][show]\" value=\"1\"$checked /> " . $element['title'] . "<input type=\"hidden\" name=\"comments[$element_name][title]\" value=\"" . $element['title'] . "\" /></li>\n";
						}
?>
						</ul>
					</div>
				</div>
				<div class="module_subsection">
					<h4 class="module_switch"><a href="" title="<?php _e('Show/hide additional information', 'thesis'); ?>"><span class="pos">+</span><span class="neg">&#8211;</span></a><?php _e('Comments', 'thesis'); ?></h4>
					<div class="more_info">
						<div class="mini_module indented_module" id="comment_meta_module">
							<h5 class="module_switch"><a href="" title="<?php _e('Show/hide additional information', 'thesis'); ?>"><span class="pos">+</span><span class="neg">&#8211;</span></a><?php _e('Comment Meta', 'thesis'); ?></h5>
							<div class="more_info">
								<ul id="comment_meta_elements" class="sortable add_margin">
<?php
								foreach ($comments['comments']['options']['meta'] as $element_name => $element) {
									$checked = ($element['show']) ? ' checked="checked"' : '';
									echo "\t\t\t\t\t\t\t\t<li><input type=\"checkbox\" class=\"checkbox\" id=\"comments[comments][options][meta][$element_name][show]\" name=\"comments[comments][options][meta][$element_name][show]\" value=\"1\"$checked /> " . $element['title'] . "<input type=\"hidden\" name=\"comments[comments][options][meta][$element_name][title]\" value=\"" . $element['title'] . "\" /></li>\n";
								}
?>
								</ul>
								<p class="form_input add_margin">
									<input type="text" class="short" id="comments[comments][options][meta][avatar][options][size]" name="comments[comments][options][meta][avatar][options][size]" value="<?php echo $comments['comments']['options']['meta']['avatar']['options']['size']; ?>" />
									<label for="comments[comments][options][meta][avatar][options][size]"><?php _e('Set your avatar size (between 1 and 96 px)', 'thesis'); ?></label>
								</p>
								<ul class="add_margin">
									<li><input type="checkbox" id="comments[comments][options][meta][date][options][time]" name="comments[comments][options][meta][date][options][time]" value="1" <?php if ($comments['comments']['options']['meta']['date']['options']['time']) echo 'checked="checked" '; ?>/><label for="comments[comments][options][meta][date][options][time]"><?php _e('Show comment time', 'thesis'); ?></label></li></li>
								</ul>
								<p class="form_input">
									<input type="text" class="short" id="comments[comments][options][meta][date][options][date_format]" name="comments[comments][options][meta][date][options][date_format]" value="<?php echo $comments['comments']['options']['meta']['date']['options']['date_format']; ?>" />
									<label for="comments[comments][options][meta][date][options][date_format]"><?php _e('Comment date format', 'thesis'); ?> <a href="http://us.php.net/manual/en/function.date.php" target="_blank" title="See the full list of PHP date formats">[?]</a></label>
								</p>
							</div>
						</div>
						<div class="mini_module indented_module" id="comment_body_module">
							<h5 class="module_switch"><a href="" title="<?php _e('Show/hide additional information', 'thesis'); ?>"><span class="pos">+</span><span class="neg">&#8211;</span></a><?php _e('Comment Body', 'thesis'); ?></h5>
							<div class="more_info">
								<ul id="comment_body_elements" class="sortable">
<?php
								foreach ($comments['comments']['options']['body'] as $element_name => $element) {
									$checked = ($element['show']) ? ' checked="checked"' : '';
									echo "\t\t\t\t\t\t\t\t<li><input type=\"checkbox\" class=\"checkbox\" id=\"comments[comments][options][body][$element_name][show]\" name=\"comments[comments][options][body][$element_name][show]\" value=\"1\"$checked /> " . $element['title'] . "<input type=\"hidden\" name=\"comments[comments][options][body][$element_name][title]\" value=\"" . $element['title'] . "\" /></li>\n";
								}
?>
								</ul>
							</div>
						</div>
					</div>
				</div>
				<div class="module_subsection">
					<h4 class="module_switch"><a href="" title="<?php _e('Show/hide additional information', 'thesis'); ?>"><span class="pos">+</span><span class="neg">&#8211;</span></a><?php _e('Trackbacks', 'thesis'); ?></h4>
					<div class="control_box more_info">
						<ul class="control">
							<li><input type="checkbox" id="comments[trackbacks][options][date]" name="comments[trackbacks][options][date]" value="1" <?php if ($comments['trackbacks']['options']['date']) echo 'checked="checked" '; ?>/><label for="comments[trackbacks][options][date]"><?php _e('Show trackback date', 'thesis'); ?></label></li>
						</ul>
						<div class="dependent">
							<p class="form_input">
								<input type="text" class="short" id="comments[trackbacks][options][date_format]" name="comments[trackbacks][options][date_format]" value="<?php echo $comments['trackbacks']['options']['date_format']; ?>" />
								<label for="comments[trackbacks][options][date_format]"><?php _e('Trackback date format', 'thesis'); ?> <a href="http://us.php.net/manual/en/function.date.php" target="_blank" title="See the full list of PHP date formats">[?]</a></label>
							</p>
						</div>
					</div>
				</div>
			</div>
			<div class="options_module" id="thesis-multimedia-box">
				<h3><?php _e('Multimedia Box', 'thesis'); ?></h3>
				<div class="module_subsection">
					<h4 class="module_switch"><a href="" title="<?php _e('Show/hide additional information', 'thesis'); ?>"><span class="pos">+</span><span class="neg">&#8211;</span></a><?php _e('Default Settings', 'thesis'); ?></h4>
					<div class="more_info">
						<p><?php _e('The default multimedia box setting applies to your home page, archive pages (category, tag, date-based, and author-based), search pages, and 404 pages. You can override the default setting on any individual post or page by utilizing the multimedia box controls on the post editing screen.', 'thesis'); ?></p>
						<p class="form_input" id="multimedia_select">
							<select id="multimedia_box[status]" name="multimedia_box[status]" size="1">
								<option value="0"<?php if (!$multimedia_box['status']) echo ' selected="selected"'; ?>><?php _e('Do not show box', 'thesis'); ?></option>
								<option value="image"<?php if ($multimedia_box['status'] == 'image') echo ' selected="selected"'; ?>><?php _e('Rotating images', 'thesis'); ?></option>
								<option value="video"<?php if ($multimedia_box['status'] == 'video') echo ' selected="selected"'; ?>><?php _e('Embed a video', 'thesis'); ?></option>
								<option value="custom"<?php if ($multimedia_box['status'] == 'custom') echo ' selected="selected"'; ?>><?php _e('Custom code', 'thesis'); ?></option>
							</select>
						</p>
						<p class="tip" id="no_box_tip"><?php _e('Remember, even though you&#8217;ve disabled the multimedia box here, you can activate it on single posts or pages by using the multimedia box options on the post editing screen.', 'thesis'); ?></p>
						<p class="tip" id="image_tip"><?php printf(__('Any images you upload to your <a href="%s">rotator folder</a> will automatically appear in the list below.', 'thesis'), THESIS_ROTATOR_FOLDER); ?></p>
						<div class="mini_module" id="image_alt_module">
							<h5><?php _e('Define Image Alt Tags and Links', 'thesis'); ?></h5>
							<p><?php _e('It&#8217;s a good practice to add descriptive alt tags to every image you place on your site. Use the input fields below to add customized alt tags to your rotating images.', 'thesis'); ?></p>
	<?php
						$rotator_dir = opendir(THESIS_ROTATOR);	
						while (($file = readdir($rotator_dir)) !== false) {
							if (strpos($file, '.jpg') || strpos($file, '.jpeg') || strpos($file, '.png') || strpos($file, '.gif'))
								$images[$file] = THESIS_ROTATOR_FOLDER . '/' . $file;
						}

						$image_count = 1;

						if ($images) {
							foreach ($images as $image => $image_url) {
	?>
							<div class="toggle_box">
								<p class="form_input add_margin">
									<input type="text" class="text_input" id="multimedia_box[alt_tags][<?php echo $image; ?>]" name="multimedia_box[alt_tags][<?php echo $image; ?>]" value="<?php if ($multimedia_box['alt_tags'][$image]) echo stripslashes($multimedia_box['alt_tags'][$image]); ?>" />
									<label for="multimedia_box[alt_tags][<?php echo $image; ?>]"><?php _e('alt text for ' . $image . ' &nbsp; <a href="' . $image_url . '" target="_blank">view</a>', 'thesis'); ?> &nbsp; <a class="switch" href=""><?php _e('[+] add link', 'thesis'); ?></a></label>
								</p>
								<p class="form_input dependent indented<?php if ($image_count < count($images)) echo ' add_margin'; ?>">
									<input type="text" class="text_input" id="multimedia_box[link_urls][<?php echo $image; ?>]" name="multimedia_box[link_urls][<?php echo $image; ?>]" value="<?php if ($multimedia_box['link_urls'][$image]) echo $multimedia_box['link_urls'][$image]; ?>" />
									<label for="multimedia_box[link_urls][<?php echo $image; ?>]"><?php _e('link <acronym title="Uniform Resource Locator">URL</acronym> for ' . $image . ' (including &#8216;http://&#8217;)', 'thesis'); ?></label>
								</p>
							</div>
	<?php
								$image_count++;
							}
						}
						else {
	?>
							<p class="form_input"><?php printf(__('You don&#8217;t have any images to rotate! Try adding some images to your <a href="%s">rotator folder</a>, and then come back here to edit your alt tags.', 'thesis'), THESIS_ROTATOR_FOLDER); ?></p>
	<?php
						}
	?>
						</div>
						<div class="mini_module" id="video_code_module">
							<h5><?php _e('Embedded Video Code', 'thesis'); ?></h5>
							<p><?php _e('Place your video embed code in the box below, and it will appear in the multimedia box by default.', 'thesis'); ?></p>
							<p class="form_input">
								<label for="multimedia_box[video]"><?php _e('Video embed code', 'thesis'); ?></label>
								<textarea id="multimedia_box[video]" name="multimedia_box[video]"><?php if ($multimedia_box['video']) thesis_massage_code($multimedia_box['video']); ?></textarea>
							</p>
						</div>
						<div class="mini_module" id="custom_code_module">
							<h5><?php _e('Custom Multimedia Box Code', 'thesis'); ?></h5>
							<p><?php _e('You&#8217;ve now activated the special multimedia box hook, <code>thesis_hook_multimedia_box</code>, and you can use this to make the multimedia box do just about anything via your custom functions file, <code>custom_functions.php</code>.', 'thesis'); ?></p>
							<p><?php _e('If you like, you can override this hook by placing your own custom <acronym title="HyperText Markup Language">HTML</acronym> in the box below. Even if you do this, you can still access the hook on any post or page by selecting the &#8220;Access the Multimedia Box Hook&#8221; checkbox on the post editing screen.', 'thesis'); ?></p>
							<p class="form_input">
								<label for="multimedia_box[code]"><?php _e('Custom multimedia box code', 'thesis'); ?></label>
								<textarea id="multimedia_box[code]" name="multimedia_box[code]"><?php if ($multimedia_box['code']) thesis_massage_code($multimedia_box['code']); ?></textarea>
							</p>
						</div>
					</div>
				</div>
			</div>
			<div class="options_module" id="feature-box">
				<h3><?php _e('Feature Box', 'thesis'); ?></h3>
				<div class="module_subsection">
					<h4 class="module_switch"><a href="" title="<?php _e('Show/hide additional information', 'thesis'); ?>"><span class="pos">+</span><span class="neg">&#8211;</span></a><?php _e('Placement', 'thesis'); ?></h4>
					<div class="more_info">
						<p><?php _e('Select a placement setting below, and then depending on your site&#8217;s configuration, you&#8217;ll be presented with different options for managing your feature box.', 'thesis'); ?></p>
						<p class="form_input" id="feature_select">
							<select id="feature_box[position]" name="feature_box[position]" size="1">
								<option value="0"<?php if (!$feature_box['position']) echo ' selected="selected"'; ?>><?php _e('Do not use feature box', 'thesis'); ?></option>
								<option value="content"<?php if ($feature_box['position'] == 'content') echo ' selected="selected"'; ?>><?php _e('In your content column', 'thesis'); ?></option>
								<option value="full-content"<?php if ($feature_box['position'] == 'full-content') echo ' selected="selected"'; ?>><?php _e('Full-width above content and sidebars', 'thesis'); ?></option>
								<option value="full-header"<?php if ($feature_box['position'] == 'full-header') echo ' selected="selected"'; ?>><?php _e('Full-width above header area', 'thesis'); ?></option>
							</select>
						</p>
						<div id="feature_box_radio">
							<p class="label_note"><?php _e('Show feature box&hellip;', 'thesis'); ?></p>
							<ul>
<?php
					if (get_option('show_on_front') == 'page') {
?>
								<li><input type="radio" name="feature_box[status]" value="front" <?php if ($feature_box['status'] == 'front') echo 'checked="checked" '; ?>/><label><?php _e('on front page <em>only</em>', 'thesis'); ?></label></li>
								<li><input type="radio" name="feature_box[status]" value="0" <?php if (!$feature_box['status']) echo 'checked="checked" '; ?>/><label><?php _e('on blog page <em>only</em>', 'thesis'); ?></label></li>
								<li><input type="radio" name="feature_box[status]" value="front-and-blog" <?php if ($feature_box['status'] == 'front-and-blog') echo 'checked="checked" '; ?>/><label><?php _e('on front page and blog page', 'thesis'); ?></label></li>
<?php
					}
					else {
?>
								<li><input type="radio" name="feature_box[status]" value="0" <?php if (!$feature_box['status']) echo 'checked="checked" '; ?>/><label><?php _e('on home page <em>only</em>', 'thesis'); ?></label></li>
<?php
					}
?>
								<li><input type="radio" name="feature_box[status]" value="sitewide" <?php if ($feature_box['status'] == 'sitewide') echo 'checked="checked" '; ?>/><label><?php _e('sitewide', 'thesis'); ?></label></li>
							</ul>
						</div>
						<div id="feature_box_content_position">
							<p class="label_note"><?php _e('Display feature box after post&hellip;', 'thesis'); ?></p>
							<p class="form_input">
								<select id="feature_box[after_post]" name="feature_box[after_post]" size="1">
									<option value="0"<?php if (!$feature_box['after_post']) echo ' selected="selected"'; ?>><?php _e('Above all posts'); ?></option>
<?php
						$available_posts = $thesis_pages->home['body']['content']['features'];
						for ($j = 1; $j <= $available_posts; $j++) {
							$selected = ($feature_box['after_post'] == $j) ? ' selected="selected"' : '';
							echo "\t\t\t\t\t\t\t\t<option value=\"$j\"$selected>$j</option>\n";
						}
?>
								</select>
							</p>
						</div>
					</div>
				</div>
				<div class="module_subsection" id="feature_box_display">
					<h4 class="module_switch"><a href="" title="<?php _e('Show/hide additional information', 'thesis'); ?>"><span class="pos">+</span><span class="neg">&#8211;</span></a><?php _e('Display Options', 'thesis'); ?></h4>
					<p class="more_info"><?php _e('Right now, the only thing you can do with your shiny new feature box is access a hook, <code>thesis_hook_feature_box</code>. Expect your display options to improve dramatically in a future release!', 'thesis'); ?></p>
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

function thesis_layout_areas() {
	$layout_areas = array(
		'content' => array(
			'name' => __('Content Area', 'thesis'),
			'intro_text' => __('The size you select will be the <em>primary</em> font size used in your post and comment areas. <strong>Note:</strong> The font used in this area is inherited from the body.', 'thesis'),
			'define_font' => false,
			'font_sizes' => array(11, 12, 13, 14, 15, 16),
			'secondary_font' => false
		),
		'nav_menu' => array(
			'name' => __('Nav Menu', 'thesis'),
			'intro_text' => __('The font and size you select will be used in your nav menu items:', 'thesis'),
			'define_font' => true,
			'font_sizes' => array(10, 11, 12, 13, 14),
			'secondary_font' => false
		),
		'header' => array(
			'name' => __('Header', 'thesis'),
			'intro_text' => __('The font and size you select will be used in your site title:', 'thesis'),
			'define_font' => true,
			'font_sizes' => array(32, 34, 36, 38, 40, 42, 44, 46),
			'secondary_font' => array(
				'item_reference' => 'tagline',
				'item_name' => __('Tagline', 'thesis'),
				'item_intro' => __('By default, your tagline will be rendered in the same font as your site title. If you like, you can change your tagline font here:', 'thesis'),
				'item_sizes' => array(10, 11, 12, 13, 14, 15, 16)
			)
		), 
		'headlines' => array(
			'name' => __('Headlines', 'thesis'),
			'intro_text' => __('The font and size you select will be used in your post and page headlines:', 'thesis'),
			'define_font' => true,
			'font_sizes' => array(20, 22, 24, 26, 28, 30),
			'secondary_font' => array(
				'item_reference' => 'subheads',
				'item_name' => __('Sub-headlines', 'thesis'),
				'item_intro' => __('By default, sub-headlines (<code>&lt;h2&gt;</code> or <code>&lt;h3&gt;</code>) inside your content are rendered in the same font as your headlines. If you like, you can change your sub-headline font here:', 'thesis'),
				'item_sizes' => false
			)
		),
		'bylines' => array(
			'name' => __('Bylines and Post Meta Data', 'thesis'),
			'intro_text' => __('The font and size you select will be used in your bylines:', 'thesis'),
			'define_font' => true,
			'font_sizes' => array(10, 11, 12, 13, 14),
			'secondary_font' => false
		),
		'code' => array(
			'name' => __('Code', 'thesis'),
			'intro_text' => __('The font you select will be used to render both <code>&lt;code&gt;</code> and <code>&lt;pre&gt;</code> within your posts. The size you select will be used for preformatted code (<code>&lt;pre&gt;</code>):', 'thesis'),
			'define_font' => true,
			'font_sizes' => array(10, 11, 12, 13, 14, 15, 16),
			'secondary_font' => false
		),	
		'multimedia_box' => array(
			'name' => __('Multimedia Box', 'thesis'),
			'intro_text' => __('The font and size you select will be used in your multimedia box:', 'thesis'),
			'define_font' => true,
			'font_sizes' => array(10, 11, 12, 13, 14, 15),
			'secondary_font' => false
		),
		'sidebars' => array(
			'name' => __('Sidebars', 'thesis'),
			'intro_text' => __('The font and size you select will be the <em>primary</em> font and size used in your sidebars:', 'thesis'),
			'define_font' => true,
			'font_sizes' => array(10, 11, 12, 13, 14, 15),
			'secondary_font' => array(
				'item_reference' => 'sidebar_headings',
				'item_name' => __('Sidebar Headings', 'thesis'),
				'item_intro' => __('By default, sidebar headings are rendered in the same font as the sidebars. If you like, you can change your sidebar heading font here:', 'thesis'),
				'item_sizes' => array(10, 11, 12, 13, 14, 15, 16, 17, 18)
			)
		),
		'footer' => array(
			'name' => __('Footer', 'thesis'),
			'intro_text' => __('The font and size you select will be used in your footer:', 'thesis'),
			'define_font' => true,
			'font_sizes' => array(10, 11, 12, 13, 14, 15),
			'secondary_font' => false
		)
	);
	
	return $layout_areas;
}

function thesis_teaser_areas() {
	$teaser_areas = array(
		'headline' => array(12, 14, 16, 18, 20),
		'author' => array(10, 11, 12, 13, 14),
		'date' => array(10, 11, 12, 13, 14),
		'category' => array(10, 11, 12, 13, 14),
		'excerpt' => array(10, 11, 12, 13, 14, 15, 16),
		'tags' => array(10, 11, 12, 13, 14),
		'comments' => array(10, 11, 12, 13, 14),
		'link' => array(10, 11, 12, 13, 14, 15, 16)
	);
	
	return $teaser_areas;
}