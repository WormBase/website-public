<?php
/**
 * class Design
 *
 * The Design class consists of variables used to manipulate different facets
 * of the Thesis layout. To set your design options, open up your WordPress
 * dashboard, and visit the following:
 * Design -> Thesis Design
 * Or, if you prefer, you can visit /wp-admin/admin.php?page=thesis-design
 *
 * @package Thesis
 * @since 1.1
 */

class Design {
	/**
	 * thesis_default_design_options() — Sets design options to their defaults
	 *
	 * @since 1.1
	 */
	function default_design_options() {
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
		
		$this->style = array(
			'custom' => true
		);
		
		$this->layout = array(
			'columns' => 3,
			'widths' => array(
				'content' => 480,
				'sidebar_1' => 195,
				'sidebar_2' => 195
			),
			'order' => 'normal',
			'framework' => 'page',
			'page_padding' => 1
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

	/**
	 * thesis_get_design_options() — Retrieves saved options from the WP database
	 *
	 * @since 1.1
	 */
	function get_design_options() {
		$saved_options = maybe_unserialize(get_option('thesis_design_options'));
		
		if (!empty($saved_options) && is_object($saved_options)) {
			foreach ($saved_options as $option_name => $value)
				$this->$option_name = $value;
		}
	}

	function update_design_options() {
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
		
		// Custom styles
		$style = $_POST['style'];
		$this->style['custom'] = (bool) $style['custom'];
		
		// Layout
		$layout = $_POST['layout'];
		$this->layout['columns'] = ($layout['columns']) ? $layout['columns'] : 3;
		$this->layout['widths']['content'] = (300 <= $layout['widths']['content'] && $layout['widths']['content'] <= 934) ? $layout['widths']['content'] : 480;
		$this->layout['widths']['sidebar_1'] = (60 <= $layout['widths']['sidebar_1'] && $layout['widths']['sidebar_1'] <= 500) ? $layout['widths']['sidebar_1'] : 195;
		$this->layout['widths']['sidebar_2'] = (60 <= $layout['widths']['sidebar_2'] && $layout['widths']['sidebar_2'] <= 500) ? $layout['widths']['sidebar_2'] : 195;
		$this->layout['order'] = $layout['order'];
		$this->layout['framework'] = ($layout['framework']) ? $layout['framework'] : 'page';
		$this->layout['page_padding'] = $layout['page_padding'];
		
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
		$this->teasers['link_text'] = ($teasers['link_text']) ? urlencode($teasers['link_text']) : false;
			
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
				foreach ($multimedia_box['alt_tags'] as $image_name => $value) {
					if ($value != '')
						$this->multimedia_box['alt_tags'][$image_name] = $value;
				}
			}
			if (is_array($multimedia_box['link_urls'])) {
				foreach ($multimedia_box['link_urls'] as $image_name => $url) {
					if ($url != '')
						$this->multimedia_box['link_urls'][$image_name] = $url;
				}
			}
		}
		$this->multimedia_box['video'] = ($multimedia_box['video']) ? $multimedia_box['video'] : false;
		$this->multimedia_box['code'] = ($multimedia_box['code']) ? $multimedia_box['code'] : false;
		$this->multimedia_box['color'] = (strlen($multimedia_box['color']) == 3 || strlen($multimedia_box['color']) == 6) ? $multimedia_box['color'] : '111';
		$this->multimedia_box['background']['image'] = (strlen($multimedia_box['background']['image']) == 3 || strlen($multimedia_box['background']['image']) == 6) ? $multimedia_box['background']['image'] : 'eee';
		$this->multimedia_box['background']['video'] = (strlen($multimedia_box['background']['video']) == 3 || strlen($multimedia_box['background']['video']) == 6) ? $multimedia_box['background']['video'] : '000';
		$this->multimedia_box['background']['code'] = (strlen($multimedia_box['background']['code']) == 3 || strlen($multimedia_box['background']['code']) == 6) ? $multimedia_box['background']['code'] : 'eee';
	}
}

function thesis_save_design_options() {
	if (!current_user_can('edit_themes'))
		wp_die(__('Easy there, homey. You don&#8217;t have admin privileges to access theme options.', 'thesis'));
	
	if (isset($_POST['submit'])) {
		$design_options = new Design;
		$design_options->get_design_options();
		$design_options->update_design_options();
		update_option('thesis_design_options', $design_options);
	}
	
	thesis_generate_css();
	wp_redirect(admin_url('admin.php?page=thesis-design-options&updated=true'));
}

function thesis_upgrade_design_options() {
	// Retrieve Design Options and Design Options defaults
	$design_options = new Design;
	$design_options->get_design_options();

	$default_design_options = new Design;
	$default_design_options->default_design_options();
	
	// Retrieve Thesis Options and Thesis Options defaults
	$thesis_options = new Options;
	$thesis_options->get_options();
	
	$default_options = new Options;
	$default_options->default_options();

	if (isset($design_options->teasers) && !is_array($design_options->teasers)) {
		unset($design_options->teasers);
	}
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

function thesis_get_design_option($option_name, $display = false) {
	$design_options = new Design;
	$design_options->get_design_options();
	
	if (!empty($saved_options) && is_object($saved_options)) {
		foreach ($saved_options as $option_name => $value)
			$design_options->$option_name = $value;
	}

	if ($display)
		echo $design_options->$option_name;
	else
		return $design_options->$option_name;
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