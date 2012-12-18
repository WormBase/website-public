<?php
/**
 * css.php — Handles font-related styling and information.
 *
 * @package Thesis
 * @since 1.5
 * @subpackage Styling
 */

/**
 * class Thesis_CSS
 *
 * Constructs the Thesis layout according to the options chosen in the Design Options panel (and the multimedia box settings)
 */
class Thesis_CSS {	
	function build() {
		$this->baselines();
		$this->widths();
		$this->content();
		$this->teasers();
		$this->colors();
		$this->borders();
	}

	function baselines() {
		$thesis_design = new thesis_design_options;
		$thesis_design->get_options();
		$this->base['num'] = 10;
		$this->fonts = $thesis_design->fonts;
		$this->colors = $thesis_design->colors;
		$this->borders = $thesis_design->borders;
		$this->nav = $thesis_design->nav;
		$this->layout = $thesis_design->layout;
		$this->teasers = $thesis_design->teasers;
		$this->feature_box = $thesis_design->feature_box;
		$this->multimedia_box = $thesis_design->multimedia_box;

		// Calculate line heights
		if (is_array($this->fonts['sizes'])) {
			foreach ($this->fonts['sizes'] as $area => $size) {
				if ($area == 'header' || $area == 'tagline' || $area == 'sidebars' || $area == 'code') {
					$line_height = $size + 6;

					if ($line_height % 2 == 1)
						$line_height = $line_height - 1;
				}
				elseif ($area == 'nav_menu') {
					$line_height = $size + 4;
				
					if ($line_height % 2 == 1)
						$line_height = $line_height - 1;
				}
				else {
					$line_height = $size + 8;

					if ($line_height % 2 == 1)
						$line_height = $line_height - 1;
				}

				$this->line_heights[$area] = $line_height;
			}
		}

		$this->base['horizontal'] = $this->line_heights['content'];
		$this->base['page_padding'] = ($this->layout['page_padding']) ? $this->line_heights['content'] * $this->layout['page_padding'] : 0;
	}

	function widths() {
		// Set baseline width elements (these are the basis for the horizontal cadence, if you will)
		$horizontal_spacing = array(
			'single' => $this->base['horizontal'],
			'half' => $this->base['horizontal'] / 2
		);

		// Thesis-specific width constants
		$widths['header_padding'] = $horizontal_spacing['half'];
		$widths['sidebar_padding'] = $horizontal_spacing['single'];
		$widths['teaser_margin'] = $horizontal_spacing['single'];
		$widths['mm_box_padding'] = $horizontal_spacing['single'];
		$widths['mm_image_padding'] = 1;
		$borders['mm_image'] = 1;
		$borders['nested'] = 1;
		$this->form_input = array(
			'border' => array(
				'top' => 1,
				'right' => 1,
				'bottom' => 1,
				'left' => 1
			),
			'padding' => 3
		);

		// Generate various style variables based upon specified structure.
		if ($this->layout['columns'] == 2 || $this->layout['columns'] == 3) {
			$borders['content'] = ($this->borders['show']) ? 1 : 0;
			
			if ($this->layout['order'] == 'normal') { // Content on the left
				$widths['post_box_margin_left'] = $widths['comment_padding'] = $widths['prev_next_padding_left'] = $horizontal_spacing['half'];
				$widths['comment_margin_left'] = 0;
				$floats['content'] = 'float: left; ';
				$floats['sidebars'] = 'float: right; ';
				$special_comment_css = 'margin-left: ' . round(($widths['post_box_margin_left'] / $this->base['num']), 1) . 'em;';

				if ($this->layout['columns'] == 2)
					$widths['post_box_margin_right'] = $widths['comment_margin_right'] = $widths['prev_next_padding_right'] = $horizontal_spacing['single'] + 1;
				else
					$widths['post_box_margin_right'] = $widths['comment_margin_right'] = $widths['prev_next_padding_right'] = $horizontal_spacing['single'];
			}
			elseif ($this->layout['order'] == 'invert') { // Content in the middle (3-column only)
				$widths['post_box_margin_left'] = $widths['post_box_margin_right'] = $widths['comment_padding'] = $widths['prev_next_padding_left'] = $widths['prev_next_padding_right'] = $horizontal_spacing['single'];
				$widths['comment_margin_left'] = $widths['comment_margin_right'] = 0;
				$floats['content'] = 'float: right; ';
				$floats['sidebars'] = 'float: right; ';
				$special_comment_css = 'margin-right: ' . round(($widths['post_box_margin_right'] / $this->base['num']), 1) . 'em; margin-left: ' . round(($widths['post_box_margin_left'] / $this->base['num']), 1) . 'em;';
			}
			else { // Content on the right
				$widths['post_box_margin_left'] = $widths['prev_next_padding_left'] = $horizontal_spacing['single'];
				$widths['comment_margin_left'] = $widths['comment_margin_right'] = $widths['comment_padding'] = $horizontal_spacing['half'];
				$floats['content'] = 'float: right; ';
				$floats['sidebars'] = 'float: left; ';
				$special_comment_css = 'margin-left: ' . round(($widths['comment_margin_left'] / $this->base['num']), 1) . 'em;';

				if ($this->layout['columns'] == 2)
					$widths['post_box_margin_right'] = $widths['prev_next_padding_right'] = $horizontal_spacing['half'] - 1;
				else
					$widths['post_box_margin_right'] = $widths['prev_next_padding_right'] = $horizontal_spacing['half'];
			}
			
			if ($this->layout['columns'] == 3) {
				$widths['content'] = $this->layout['widths']['content'] + $widths['post_box_margin_left'] + $widths['post_box_margin_right'] + $borders['content'];
				$borders['sidebar'] = ($this->borders['show']) ? 1 : 0;
				$widths['total_sidebars'] = $this->layout['widths']['sidebar_1'] + $this->layout['widths']['sidebar_2'] + (2 * $widths['sidebar_padding']) + $borders['sidebar'];
				$widths['multimedia_box'] = $widths['total_sidebars'] - (2 * $widths['mm_box_padding']);
				$widths['content_box'] = $widths['content'] + $widths['total_sidebars'];
				$widths['container'] = $widths['content_box'] + (2 * $this->base['page_padding']);

				if ($this->layout['order'] == 'invert') {
					$widths['sidebars_box'] = $this->layout['widths']['sidebar_2'] + $widths['sidebar_padding'];
					$widths['column_wrap'] = $widths['content_box_bg_position'] = $this->layout['widths']['content'] + $widths['post_box_margin_left'] + $widths['post_box_margin_right'] + $borders['content'] + $this->layout['widths']['sidebar_1'] + $widths['sidebar_padding'];
					$widths['column_wrap_bg_position'] = $this->layout['widths']['sidebar_1'] + $widths['sidebar_padding'];
					$widths['nested_padding'] = $widths['comment_padding'];
					$wrap_border = ($this->borders['show']) ? 'background: url(\'../lib/images/dot-ddd.gif\') ' . round(($widths['column_wrap_bg_position'] / $this->base['num']), 3) . 'em 0 repeat-y; ' : '';
					$column_wrap_css = '
			#column_wrap { width: ' . round(($widths['column_wrap'] / $this->base['num']), 1) . 'em; ' . $wrap_border . '}';
					$sidebar_css = '#sidebar_1 { width: ' . round((($this->layout['widths']['sidebar_1'] + $widths['sidebar_padding']) / $this->base['num']), 1) . 'em; border: 0; float: left; }
				#sidebar_2 { width: ' . round(((($this->layout['widths']['sidebar_2'] + $widths['sidebar_padding'])) / $this->base['num']), 1) . 'em; }';
					$special_sidebar_css = '';
				}
				else {
					$widths['sidebars_box'] = $widths['total_sidebars'];
					$widths['nested_padding'] = 2 * $widths['comment_padding'];
					$column_wrap_css = '';

					if (!$this->layout['order'])
						$widths['content_box_bg_position'] = $widths['sidebars_box'];
					else
						$widths['content_box_bg_position'] = $this->layout['widths']['content'] + $widths['post_box_margin_left'] + $widths['post_box_margin_right'];

					$sidebar_css = '#sidebar_1 { width: ' . round((($this->layout['widths']['sidebar_1'] + $widths['sidebar_padding']) / $this->base['num']), 1) . 'em; border-style: dotted; border-width: 0 ' . round(($borders['sidebar'] / $this->base['num']), 1) . 'em 0 0; float: left; clear: left; }
				#sidebar_2 { width: ' . round(((($this->layout['widths']['sidebar_2'] + $widths['sidebar_padding']) - 1) / $this->base['num']), 1) . 'em; float: left; }';	
					$special_sidebar_css = '	#sidebar_2 ul.sidebar_list { padding-right: ' . round(((($widths['sidebar_padding'] / 2) - 1) / $this->base['num']), 1) . 'em; }';
				}
			}
			else { // 2-column layout is in use
				$widths['sidebars_box'] = $this->layout['widths']['sidebar_1'] + $widths['sidebar_padding'];
				$widths['content_box'] = $this->layout['widths']['content'] + $widths['post_box_margin_left'] + $widths['post_box_margin_right'] + $borders['content'] + $widths['sidebars_box'];
				$widths['container'] = $widths['content_box'] + ($this->base['page_padding'] * 2);
				$widths['nested_padding'] = 2 * $widths['comment_padding'];

				if (!$this->layout['order'])
					$widths['content_box_bg_position'] = $widths['sidebars_box'];
				else
					$widths['content_box_bg_position'] = $this->layout['widths']['content'] + $widths['post_box_margin_left'] + $widths['post_box_margin_right'];

				$sidebar_css = '.sidebar { width: 100%; }
				#sidebar_1 { border: 0; }';
				$special_sidebar_css = '';
			}
			
			$content_border = ($this->borders['show']) ? 'background: url(\'../lib/images/dot-ddd.gif\') ' . round(($widths['content_box_bg_position'] / $this->base['num']), 1) . 'em 0 repeat-y; ' : '';
			$widths['multimedia_image'] = $widths['sidebars_box'] - $widths['mm_box_padding'] - (2 * $widths['mm_image_padding']) - (2 * $borders['mm_image']);
			$styles['content_box'] = '
		#content_box { width: 100%; ' . $content_border .'}
		.no_sidebars { background: none !important; }
			' . $column_wrap_css . '
			#content { width: ' . round((($this->layout['widths']['content'] + $widths['post_box_margin_left'] + $widths['post_box_margin_right']) / $this->base['num']), 1) . 'em; ' . $floats['content'] . '}
			.no_sidebars #content { width: 100%; }
				.post_box, .teasers_box, .full_width #content_box .page { margin: 0 ' . round(($widths['post_box_margin_right'] / $this->base['num']), 1) . 'em 0 ' . round(($widths['post_box_margin_left'] / $this->base['num']), 1) . 'em; }
					.full_width #content_box .page { width: auto; }
				.no_sidebars .post_box { margin: 0 ' . round(($widths['header_padding'] / $this->base['num']), 1) . 'em; }
				.teasers_box { width: ' . round(($this->layout['widths']['content'] / $this->base['num']), 1) . 'em; }
					.teaser { width: ' . round(((($this->layout['widths']['content'] - $widths['teaser_margin']) / 2) / $this->base['num']), 1) . 'em; }
				#archive_info, .prev_next { padding-right: ' . round(($widths['prev_next_padding_right'] / $this->base['num']), 1) . 'em; padding-left: ' . round(($widths['prev_next_padding_left'] / $this->base['num']), 1) . 'em; }
			#sidebars { width: ' . round(($widths['sidebars_box'] / $this->base['num']), 1) . 'em; border: 0; ' . $floats['sidebars'] . '}';
		}
		elseif ($this->layout['columns'] == 1) {
			$widths['post_box_margin_left'] = $widths['post_box_margin_right'] = $widths['comment_padding'] = $widths['prev_next_padding_left'] = $widths['prev_next_padding_right'] = $horizontal_spacing['half'];
			$widths['comment_margin_left'] = $widths['comment_margin_right'] = 0;
			$widths['content_float'] = 'left';
			$special_comment_css = 'margin-right: ' . round(($widths['post_box_margin_right'] / $this->base['num']), 1) . 'em; margin-left: ' . round(($widths['post_box_margin_left'] / $this->base['num']), 1) . 'em;';
			$widths['container'] = $this->layout['widths']['content'] + $widths['post_box_margin_left'] + $widths['post_box_margin_right'] + ($this->base['page_padding'] * 2);
			$widths['nested_padding'] = 2 * $widths['comment_padding'];
			$widths['sidebars_area'] = $this->layout['widths']['content'] + $widths['post_box_margin_left'] + $widths['post_box_margin_right'];
			$borders['sidebar_top'] = 3;
			$borders['sidebar'] = 1;
			$sidebar_top_border = ($this->borders['show']) ? 'border-style: solid; border-width: ' . round(($borders['sidebar_top'] / $this->base['num']), 1) . 'em 0 0 0; ' : '';
			$sidebar_border = ($this->borders['show']) ? 'border-style: dotted; border-width: 0 ' . round(($borders['sidebar'] / $this->base['num']), 1) . 'em 0 0; ' : '';
			$sidebar_css = '#sidebar_1 { width: ' . round((($widths['sidebars_area'] / 2) - 1) / $this->base['num'], 1) . 'em; ' . $sidebar_border . 'float: left; }
				#sidebar_2 { width: ' . round((($widths['sidebars_area'] / 2) - 1) / $this->base['num'], 1) . 'em; float: right; }';
			$special_sidebar_css = '';
			$widths['multimedia_image'] = $widths['sidebars_area'] - $widths['mm_box_padding'] - (2 * $widths['mm_image_padding']) - (2 * $borders['mm_image']);
			$styles['content_box'] .= '
		#content_box { width: 100%; }
			#content { width: 100%; }
				.post_box, .teasers_box { margin: 0 ' . round(($widths['post_box_margin_left'] / $this->base['num']), 1) . 'em; }
				.teasers_box { width: ' . round(($this->layout['widths']['content'] / $this->base['num']), 1) . 'em; }
					.teaser { width: ' . round(((($this->layout['widths']['content'] - $widths['teaser_margin']) / 2) / $this->base['num']), 1) . 'em; }
					#archive_info, .prev_next { padding-right: ' . round(($widths['prev_next_padding_right'] / $this->base['num']), 1) . 'em; padding-left: ' . round(($widths['prev_next_padding_left'] / $this->base['num']), 1) . 'em; }
			#sidebars { width: 100%; ' . $sidebar_top_border . 'clear: both; }';
		}
		
		// Set up supported image size ratios for the multimedia box image handler
		$height_4x3 = $widths['multimedia_image'] * (3 / 4);
		$height_3x4 = $widths['multimedia_image'] * (4 / 3);
		$height_3x2 = $widths['multimedia_image'] * (2 / 3);
		$height_2x3 = $widths['multimedia_image'] * (3 / 2);
		$height_5x4 = $widths['multimedia_image'] * (4 / 5);
		$height_4x5 = $widths['multimedia_image'] * (5 / 4);
		$height_16x9 = $widths['multimedia_image'] * (9 / 16);
		$height_9x16 = $widths['multimedia_image'] * (16 / 9);
		$height_2x1 = $widths['multimedia_image'] * (1 / 2);
		$height_1x2 = $widths['multimedia_image'] * 2;
		
		// "Build" the widths part of the stylesheet
		if ($this->layout['framework'] == 'full-width') {
			$styles['core'] = '/*---:[ core layout elements ]:---*/
.full_width { width: 100%; clear: both; }
	.full_width .page { width: ' . round((($widths['container'] - ($this->base['page_padding'] * 2)) / $this->base['num']), 1) . 'em; margin: 0 auto; padding-right: ' . round(($this->base['page_padding'] / $this->base['num']), 1) . 'em; padding-left: ' . round(($this->base['page_padding'] / $this->base['num']), 1) . 'em; }
	#header_area .page { padding-top: ' . round(($this->base['page_padding'] / $this->base['num']), 1) . 'em; }
	#footer_area .page { padding-bottom: ' . round(($this->base['page_padding'] / $this->base['num']), 1) . 'em; }';
		}
		else {
			$styles['core'] = '/*---:[ core layout elements ]:---*/
#container { width: ' . round(($widths['container'] / $this->base['num']), 1) . 'em; margin: 0 auto; }
	#page { padding: ' . round(($this->base['page_padding'] / $this->base['num']), 1) . 'em; }';
		}
		
		$styles['core'] .= '
		#header, #footer { padding-right: ' . round(($widths['header_padding'] / $this->base['num']), 1) . 'em; padding-left: ' . round(($widths['header_padding'] / $this->base['num']), 1) . 'em; }';

		// Nav constructor
		$this->nav['submenu_width'] = ($this->nav['submenu_width'] >= 30 && $this->nav['submenu_width'] <= 600) ? $this->nav['submenu_width'] : 150;

		if ($this->nav['border']['width'] > 0) {
			$this->nav_border = round(($this->nav['border']['width'] / $this->base['num']), 1) . 'em';
			$this->nav_position = '-' . $this->nav_border;
		}
		else {
			$this->nav_border = 0;
			$this->nav_position = 0;
		}

		$styles['nav'] = '
		
/*---:[ nav styles ]:---*/
.menu ul, .menu ul li { width: ' . round(($this->nav['submenu_width'] / $this->base['num']), 1) . 'em; }
.menu ul ul, .menu :hover ul :hover ul { left: ' . round((($this->nav['submenu_width'] - $this->nav['border']['width']) / $this->base['num']), 3) . 'em; }
.menu li:hover ul, .menu a:hover ul { left: ' . $this->nav_position . '; }
.menu { border-width: 0 0 ' . $this->nav_border . ' ' . $this->nav_border . '; }' . "\n";

		$styles['comments'] = '

/*---:[ comments area ]:---*/
#comments { margin-right: ' . round(($widths['comment_margin_right'] / $this->base['num']), 1) . 'em; margin-left: ' . round(($widths['comment_margin_left'] / $this->base['num']), 1) . 'em; }
	.comments_intro, #respond_intro { margin-left: ' . round(($widths['comment_padding'] / $this->base['num']), 1) . 'em; }
		dl#comment_list dt, #trackback_list { padding-right: ' . round(($widths['comment_padding'] / $this->base['num']), 1) . 'em; padding-left: ' . round(($widths['comment_padding'] / $this->base['num']), 1) . 'em; }
		dl#comment_list dd { padding-left: ' . round(($widths['comment_padding'] / $this->base['num']), 1) . 'em; }
			dl#comment_list dd .format_text, dl#comment_list dd #respond { padding-right: ' . round(($widths['comment_padding'] / $this->base['num']), 1) . 'em; }
		dl#comment_list dl dt { padding-left: ' . round(($widths['nested_padding'] / $this->base['num']), 1) . 'em; border-width: 0 0 0 ' . round(($borders['nested'] / $this->base['num']), 1) . 'em; }
		dl#comment_list dl dt.bypostauthor { padding-left: ' . round((($widths['nested_padding'] - 1) / $this->base['num']), 1) . 'em; border-width: 0 0 0 ' . round((($borders['nested'] + 1) / $this->base['num']), 1) . 'em; }
		dl#comment_list dl dd { padding-left: 0; }
		dl#comment_list dl dd .format_text { padding-left: ' . round(($widths['nested_padding'] / $this->fonts['sizes']['content']), 1) . 'em; border-width: 0 0 0 ' . round(($borders['nested'] / $this->fonts['sizes']['content']), 3) . 'em; }
		dl#comment_list dl dd.bypostauthor > .format_text { padding-left: ' . round((($widths['nested_padding'] - 1) / $this->fonts['sizes']['content']), 1) . 'em; border-width: 0 0 0 ' . round((($borders['nested'] + 1) / $this->fonts['sizes']['content']), 3) . 'em; }
		dl#comment_list dl dd dl { padding-left: ' . round(($widths['nested_padding'] / $this->base['num']), 1) . 'em; }
#commentform { padding-right: ' . round(($widths['post_box_margin_right'] / $this->base['num']), 1) . 'em; padding-left: ' . round(($widths['comment_padding'] / $this->base['num']), 1) . 'em; }
.comments_closed, .login_alert { ' . $special_comment_css . ' }';

		$styles['multimedia_image'] = '

/*---:[ multimedia box elements ]:---*/
#multimedia_box { padding: ' . round((($widths['mm_box_padding'] / 2) / $this->base['num']), 1) . 'em; }
	#image_box img { display: block; padding: ' . round(($widths['mm_image_padding'] / $this->base['num']), 1). 'em; border-width: ' . round(($borders['mm_image'] / $this->base['num']), 1) . 'em; }
	#image_box img.square { width: ' . round(($widths['multimedia_image'] / $this->base['num']), 1) . 'em; height: ' . round(($widths['multimedia_image'] / $this->base['num']), 1) . 'em; }
	#image_box img.four_by_three { width: ' . round(($widths['multimedia_image'] / $this->base['num']), 1) . 'em; height: ' . round(($height_4x3 / $this->base['num']), 1) . 'em; }
	#image_box img.three_by_four { width: ' . round(($widths['multimedia_image'] / $this->base['num']), 1) . 'em; height: ' . round(($height_3x4 / $this->base['num']), 1) . 'em; }
	#image_box img.three_by_two { width: ' . round(($widths['multimedia_image'] / $this->base['num']), 1) . 'em; height: ' . round(($height_3x2 / $this->base['num']), 1) . 'em; }
	#image_box img.two_by_three { width: ' . round(($widths['multimedia_image'] / $this->base['num']), 1) . 'em; height: ' . round(($height_2x3 / $this->base['num']), 1) . 'em; }
	#image_box img.five_by_four { width: ' . round(($widths['multimedia_image'] / $this->base['num']), 1) . 'em; height: ' . round(($height_5x4 / $this->base['num']), 1) . 'em; }
	#image_box img.four_by_five { width: ' . round(($widths['multimedia_image'] / $this->base['num']), 1) . 'em; height: ' . round(($height_4x5 / $this->base['num']), 1) . 'em; }
	#image_box img.sixteen_by_nine { width: ' . round(($widths['multimedia_image'] / $this->base['num']), 1) . 'em; height: ' . round(($height_16x9 / $this->base['num']), 1) . 'em; margin: 0 auto; }
	#image_box img.nine_by_sixteen { width: ' . round(($widths['multimedia_image'] / $this->base['num']), 1) . 'em; height: ' . round(($height_9x16 / $this->base['num']), 1) . 'em; margin: 0 auto; }
	#image_box img.two_by_one { width: ' . round(($widths['multimedia_image'] / $this->base['num']), 1) . 'em; height: ' . round(($height_2x1 / $this->base['num']), 1) . 'em; }
	#image_box img.one_by_two { width: ' . round(($widths['multimedia_image'] / $this->base['num']), 1) . 'em; height: ' . round(($height_1x2 / $this->base['num']), 1) . 'em; }';

		if ($this->feature_box['position']) { // Generate style for the feature box, if needed
			if ($this->feature_box['position'] == 'full-header' || $this->feature_box['position'] == 'full-content')
				$widths['feature_box_padding_left'] = $widths['feature_box_padding_right'] = $widths['header_padding'];
			elseif ($this->feature_box['position'] == 'content') {
				$widths['feature_box_padding_left'] = $widths['post_box_margin_left'];
				$widths['feature_box_padding_right'] = $widths['post_box_margin_right'];
			}
			else
				$widths['feature_box_padding_left'] = $widths['feature_box_padding_right'] = '';
			
			$styles['feature_box'] = '
			
/*---:[ feature box styles ]:---*/
#feature_box { padding-right: ' . round(($widths['feature_box_padding_right'] / $this->base['num']), 1) . 'em; padding-left: ' . round(($widths['feature_box_padding_right'] / $this->base['num']), 1) . 'em; }';
		}
		else
			$styles['feature_box'] = '';
		
		// Generate sidebar styling.
		$styles['sidebar'] = '
				' . $sidebar_css . '
					.sidebar ul.sidebar_list { padding-right: ' . round((($widths['sidebar_padding'] / 2) / $this->base['num']), 1) . 'em; padding-left: ' . round((($widths['sidebar_padding'] / 2) / $this->base['num']), 1) . 'em; }
				' . $special_sidebar_css;

		$this->css .= $styles['core'] . $styles['content_box'] . $styles['sidebar'] . $styles['nav'] . $styles['multimedia_image'] . $styles['feature_box'] . $styles['comments'];
	}

	function content() {
		// Calculate content element sizes
		$element_sizes['h2'] = $element_sizes['h3'] = $element_sizes['archive'] = $element_sizes['pullquotes'] = $this->fonts['sizes']['content'] + 4;
		$element_sizes['h4'] = $this->fonts['sizes']['content'];
		$element_sizes['prev_next'] = $element_sizes['archive_info'] = 10;
		$element_sizes['comment_author'] = $element_sizes['submit'] = $this->fonts['sizes']['content'] + 2;
		$element_sizes['respond'] = $this->fonts['sizes']['content'] + 3;
		$element_sizes['cancel'] = 11;

		if ($this->fonts['sizes']['content'] < 13) {
			$element_sizes['h5'] = $element_sizes['h6'] = $element_sizes['abbr'] = $element_sizes['acronym'] = $element_sizes['caption'] = 10;
			$element_sizes['tags'] = $element_sizes['to_comments'] = $this->fonts['sizes']['content'] - 1;
			$element_sizes['comment_byline'] = $element_sizes['comment_num'] = $element_sizes['trackback_timestamp'] = $element_sizes['allowed'] = 11;
			$element_sizes['code'] = $this->fonts['sizes']['content'];
		}
		else {
			$element_sizes['h5'] = $element_sizes['h6'] = $element_sizes['abbr'] = $element_sizes['acronym'] = $this->fonts['sizes']['content'] - 3;
			$element_sizes['tags'] = $element_sizes['to_comments'] = $element_sizes['comment_byline'] = $element_sizes['comment_num'] = $element_sizes['trackback_timestamp'] = $element_sizes['allowed'] = $element_sizes['caption'] = $this->fonts['sizes']['content'] - 2;
			$element_sizes['code'] = $this->fonts['sizes']['content'] - 1;
		}

		$nav_menu_padding = array('x' => $this->fonts['sizes']['nav_menu'] - 2, 'y' => $this->fonts['sizes']['nav_menu'] - 4);
		$nav_css = ($this->nav_border) ? '.menu table { bottom: -' . $this->nav_border . '; }' . "\n" . '.nav, .menu li ul { border-width: 0 0 ' . $this->nav_border . ' 0; }' . "\n" . '.menu li { margin-bottom: -' . $this->nav_border . '; }' . "\n\t" . '.menu li ul { margin-top: -' . $this->nav_border . '; }' . "\n\t" . '.menu ul ul { margin-top: 0; }' . "\n" : '.menu, .menu a, .menu li ul { border: none; }' . "\n" . '.menu table { bottom: 0; }' . "\n";
		$nav_tab_width = $this->nav['submenu_width'] - 2 * ($this->nav['border']['width'] + $nav_menu_padding['x']);

		// Calculate sidebar element sizes
		$sidebar_sizes['submit'] = $this->fonts['sizes']['sidebars'];
		$sidebar_sizes['calendar_line_height'] = 22;

		if ($this->fonts['sizes']['sidebars'] < 13) {
			$sidebar_sizes['abbr'] = $sidebar_sizes['acronym'] = 11;
			$sidebar_sizes['calendar_head'] = 11;
			$sidebar_sizes['code'] = $this->fonts['sizes']['sidebars'];
		}
		else {
			$sidebar_sizes['abbr'] = $sidebar_sizes['acronym'] = $this->fonts['sizes']['sidebars'] - 2;
			$sidebar_sizes['code'] = $this->fonts['sizes']['sidebars'] - 1;
			$sidebar_sizes['calendar_head'] = ($this->fonts['sizes']['sidebars'] == 13) ? 11 : 12;
		}

		// Retrieve user-selected fonts and set them up for use in CSS
		$font_stacks = thesis_get_fonts();

		foreach ($this->fonts['families'] as $area => $active_font) {
			if ($area == 'code' && !$active_font)
				$font_families[$area] = 'font-family: ' . $font_stacks[$this->fonts['families']['body']]['family'] . '; ';
			elseif ($area == 'tagline' && !$active_font)
				$font_families[$area] = ($this->fonts['families']['header']) ? 'font-family: ' . $font_stacks[$this->fonts['families']['header']]['family'] . '; ' : '';
			elseif ($area == 'subheads') {
				if ($active_font) $font_families[$area] = '.format_text h2, .format_text h3, .format_text h4, .format_text h5, .format_text h6 { font-family: ' . $font_stacks[$active_font]['family'] . '; }' . "\n";
				elseif ($this->fonts['families']['headlines']) $font_families[$area] = '.format_text h2, .format_text h3, .format_text h4, .format_text h5, .format_text h6 { font-family: ' . $font_stacks[$this->fonts['families']['headlines']]['family'] . '; }' . "\n";
				else $font_families[$area] = '';
			}
			elseif ($area == 'multimedia_box')
				$font_families['multimedia_box'] = ($active_font) ? '#multimedia_box { font-family: ' . $font_stacks[$this->fonts['families']['multimedia_box']]['family'] . "; }" : '';
			elseif ($active_font)
				$font_families[$area] = 'font-family: ' . $font_stacks[$active_font]['family'] . '; ';
		}

		// Set up relative sizes (for use in CSS calculations) based on the user-specified content font size
		for ($i = 1; $i <= 56; $i++)
			$relative[$i] = round(($i / $this->fonts['sizes']['content']), 3);

		$spacing['line_height'] = round(($this->line_heights['content'] / $this->base['num']), 1);
		$spacing['half'] = round((($this->line_heights['content'] / 2) / $this->base['num']), 1);
		$spacing['double'] = round((($this->line_heights['content'] * 2) / $this->base['num']), 1);
		$spacing['relative'] = $relative[$this->line_heights['content']];
		$spacing['relative_half'] = $relative[($this->line_heights['content'] / 2)];
		$spacing['pullquotes'] = round(($this->line_heights['content'] / $element_sizes['pullquotes']), 3);
		$spacing['to_comments'] = round(($this->line_heights['content'] / $element_sizes['to_comments']), 3);
		$spacing['tags'] = round(($this->line_heights['content'] / $element_sizes['tags']), 3);

		// Set up relative font sizes for sidebar styles
		for ($i = 1; $i <= 56; $i++)
			$sidebar[$i] = round(($i / $this->fonts['sizes']['sidebars']), 3);

		$sidebar_input_font = ($font_families['sidebars']) ? $font_families['sidebars'] : $font_families['body'];

		// Build CSS output.
		$this->css .= '

/*---:[ content elements ]:---*/
body { ' . $font_families['body'] . '}
	#header { padding-top: ' . $spacing['line_height'] . 'em; padding-bottom: ' . $spacing['line_height'] . 'em; }
		.post_box { padding-top: ' . $spacing['line_height'] . 'em; }
			.headline_area { margin-bottom: ' . $spacing['line_height'] . 'em; }
		.teasers_box { padding-top: ' . $spacing['line_height'] . 'em; padding-bottom: ' . $spacing['line_height'] . 'em; }
		#multimedia_box { margin-bottom: ' . $spacing['line_height'] . 'em; }
	#footer { ' . $font_families['footer'] . 'padding-top: ' . $spacing['half'] . 'em; padding-bottom: ' . $spacing['half'] . 'em; }

/*---:[ #header styles ]:---*/
#header #logo { font-size: ' . round(($this->fonts['sizes']['header'] / $this->base['num']), 1) . 'em; line-height: ' . round(($this->line_heights['header'] / $this->fonts['sizes']['header']), 3) . 'em; ' . $font_families['header'] . '}
#header #tagline { font-size: ' . round(($this->fonts['sizes']['tagline'] / $this->base['num']), 1) . 'em; line-height: ' . round((($this->fonts['sizes']['tagline'] + 6) / $this->fonts['sizes']['tagline']), 3) . 'em; ' . $font_families['tagline'] . '}

/*---:[ nav menu styles ]:---*/
' . $nav_css . '
.menu a { font-size: ' . round(($this->fonts['sizes']['nav_menu'] / $this->base['num']), 1) . 'em; ' . $font_families['nav_menu'] . 'line-height: ' . round(($this->line_heights['nav_menu'] / $this->fonts['sizes']['nav_menu']), 3) . 'em; padding: ' . round(($nav_menu_padding['y'] / $this->fonts['sizes']['nav_menu']), 3) . 'em ' . round(($nav_menu_padding['x'] / $this->fonts['sizes']['nav_menu']), 3) . 'em; border-width: ' . round(($this->nav['border']['width'] / $this->fonts['sizes']['nav_menu']), 3) . 'em; border-left-width: 0; }
.menu ul a { width: ' . round(($nav_tab_width / $this->fonts['sizes']['nav_menu']), 3) . 'em; border-left-width: ' . round(($this->nav['border']['width'] / $this->fonts['sizes']['nav_menu']), 3) . 'em; }

/*---:[ headlines ]:---*/
.headline_area h1, .headline_area h2 { font-size: ' . round(($this->fonts['sizes']['headlines'] / $this->base['num']), 1) . 'em; line-height: ' . round(($this->line_heights['headlines'] / $this->fonts['sizes']['headlines']), 3) . 'em; ' . $font_families['headlines'] . '}
' . $font_families['subheads'] . '.format_text h2, .format_text h3 { font-size: ' . round(($element_sizes['h2'] / $this->fonts['sizes']['content']), 3) . 'em; line-height: ' . round(($this->line_heights['content'] / $element_sizes['h2']), 3) . 'em; margin: ' . round((($this->line_heights['content'] * 1.5) / $element_sizes['h2']), 3) . 'em 0 ' . round((($this->line_heights['content'] / 2) / $element_sizes['h2']), 3) . 'em 0; }
.format_text h4 { font-size: ' . round(($element_sizes['h4'] / $this->fonts['sizes']['content']), 3) . 'em; }
.format_text h5 { font-size: ' . round(($element_sizes['h5'] / $this->fonts['sizes']['content']), 3) . 'em; }
.format_text h6 { font-size: ' . round(($element_sizes['h6'] / $this->fonts['sizes']['content']), 3) . 'em; }
.teaser h2 { ' . $font_families['headlines'] . '}
.sidebar h3 { font-size: ' . $sidebar[$this->fonts['sizes']['sidebar_headings']] . 'em; line-height: ' . round(($this->line_heights['sidebars'] / $this->fonts['sizes']['sidebar_headings']), 3) . 'em; ' . $font_families['sidebar_headings'] . 'margin-bottom: ' . round((($this->line_heights['sidebars'] / 2) / $this->fonts['sizes']['sidebar_headings']), 3) . 'em; }
#archive_info h1 { font-size: ' . round(($element_sizes['archive'] / $this->base['num']), 1) . 'em; line-height: 1em; }

/*---:[ bylines ]:---*/
.headline_meta { font-size: ' . round(($this->fonts['sizes']['bylines'] / $this->base['num']), 1) . 'em; line-height: ' . round(($this->line_heights['bylines'] / $this->fonts['sizes']['bylines']), 3) . 'em; ' . $font_families['bylines'] . '}
	.headline_meta .pad_left { padding-left: ' . round((($this->line_heights['bylines'] / 2) / $this->fonts['sizes']['bylines']), 3) . 'em; }

/*---:[ headline area (image thumbnails) ]:---*/
.headline_area img.alignleft { margin: 0 ' . $spacing['line_height'] . 'em ' . $spacing['line_height'] . 'em 0; }
.headline_area img.alignright { margin: 0 0 ' . $spacing['line_height'] . 'em ' . $spacing['line_height'] . 'em; }
.headline_area img.alignnone { margin: 0 auto ' . $spacing['line_height'] . 'em 0; }
.headline_area img.aligncenter { margin: 0 auto ' . $spacing['line_height'] . 'em auto; }
.headline_area img.frame { padding: ' . round(((($this->line_heights['content'] / 2) - 1) / $this->base['num']), 1) . 'em; border-width: ' . round((1 / $this->base['num']), 1) . 'em; }

/*---:[ post content area ]:---*/
.format_text { font-size: ' . round(($this->fonts['sizes']['content'] / $this->base['num']), 1) . 'em; line-height: ' . $spacing['relative'] . 'em; }
	.format_text p { margin-bottom: ' . $spacing['relative'] . 'em; }
		.format_text p.note, .format_text p.alert { padding: ' . $relative[(($this->line_heights['content'] / 2) - 3)] . 'em ' . $spacing['relative_half'] . 'em; }
	.format_text .drop_cap { font-size: ' . $relative[(($this->line_heights['content'] * 2) + 6)] . 'em; line-height: ' . round((($this->line_heights['content'] - 3) / ($this->line_heights['content'] + 3)), 3) . 'em; padding: ' . round((1 / ($this->line_heights['content'] + 3)), 3) . 'em ' . round((3 / ($this->line_heights['content'] + 3)), 3) . 'em 0 0; }
	.ie6 .format_text .drop_cap { padding-right: ' . round((1.5 / ($this->line_heights['content'] + 3)), 3) . 'em; }
	.format_text acronym, .format_text abbr { font-size: ' . $relative[$element_sizes['abbr']] . 'em; }
	.format_text code, .format_text pre { ' . $font_families['code'] . '}
	.format_text code { font-size: ' . $relative[$element_sizes['code']] . 'em; }
	.format_text pre { font-size: ' . $relative[$this->fonts['sizes']['code']] . 'em; line-height: ' . round(($this->line_heights['code'] / $this->fonts['sizes']['code']), 3) . 'em; margin-bottom: ' . round(($this->line_heights['content'] / $this->fonts['sizes']['code']), 3) . 'em; padding: ' . round(((($this->line_heights['content'] / 2) - 3) / $this->fonts['sizes']['code']), 3) . 'em ' . round((($this->line_heights['content'] / 2) / $this->fonts['sizes']['code']), 3) . 'em; }
	.format_text sub, .format_text sup { line-height: ' . $relative[($this->line_heights['content'] / 2)] . 'em }
	.format_text ul { margin: 0 0 ' . $spacing['relative'] . 'em ' . $spacing['relative'] . 'em; }
	.format_text ol { margin: 0 0 ' . $spacing['relative'] . 'em ' . $spacing['relative'] . 'em; }
		.format_text ul ul, .format_text ul ol, .format_text ol ul, .format_text ol ol { margin: 0 0 0 ' . $spacing['relative'] . 'em; }
	.format_text dl { margin-bottom: ' . $spacing['relative'] . 'em; }
		.format_text dd { margin-bottom: ' . $spacing['relative'] . 'em; }
	.format_text blockquote { margin: 0 0 ' . $spacing['relative'] . 'em ' . $spacing['relative_half'] . 'em; padding-left: ' . $spacing['relative_half'] . 'em; }
		/*---:[ pullquotes ]:---*/
		.format_text blockquote.right, .format_text blockquote.left { width: 45%; font-size: ' . $relative[$element_sizes['pullquotes']] . 'em; line-height: ' . $spacing['pullquotes'] . 'em; }
		.format_text blockquote.right { margin: 0 0 ' . $spacing['pullquotes'] . 'em ' . $spacing['pullquotes'] . 'em; }
		.format_text blockquote.left { margin: 0 ' . $spacing['pullquotes'] . 'em ' . $spacing['pullquotes'] . 'em 0; }
	/*---:[ image handling classes ]:---*/
	.format_text img.left, .format_text img.alignleft, .wp-caption.alignleft { margin: 0 ' . $spacing['relative'] . 'em ' . $spacing['relative'] . 'em 0; }
	.format_text img.right, .format_text img.alignright, .wp-caption.alignright { margin: 0 0 ' . $spacing['relative'] . 'em ' . $spacing['relative'] . 'em; }
	.format_text img.center, .format_text img.aligncenter, .wp-caption.aligncenter { margin: 0 auto ' . $spacing['relative'] . 'em auto; }
	.format_text img.block, .format_text img.alignnone, .wp-caption.alignnone { margin: 0 auto ' . $spacing['relative'] . 'em 0; }
	.format_text img[align="left"] { margin-right: ' . $spacing['relative'] . 'em; margin-bottom: ' . $spacing['relative'] . 'em; }
	.format_text img[align="right"] { margin-bottom: ' . $spacing['relative'] . 'em; margin-left: ' . $spacing['relative'] . 'em; }
	.format_text img[align="middle"] { margin-bottom: ' . $spacing['relative'] . 'em; }
	.format_text img.frame, .format_text .wp-caption { padding: ' . $relative[(($this->line_heights['content'] / 2) - 1)] . 'em; border-width: ' . $relative[1] . 'em; }
	.format_text img.stack { margin-left: ' . $spacing['relative'] . 'em; }
	.format_text .wp-caption p { font-size: ' . $relative[$element_sizes['caption']] . 'em; line-height: ' . round((($this->line_heights['content'] - 4) / $element_sizes['caption']), 3) . 'em; margin-bottom: 0; }
	/*---:[ ad and miscellaneous "block" classes ]:---*/
	.format_text .ad { margin-left: ' . $spacing['relative'] . 'em; }
	.format_text .ad_left { margin-right: ' . $spacing['relative'] . 'em; }

	/*---:[ after-post elements ]:---*/
	.format_text .to_comments { font-size: ' . $relative[$element_sizes['to_comments']] . 'em; line-height: ' . $spacing['to_comments'] . 'em; margin-bottom: ' . $spacing['to_comments'] . 'em; }
		.format_text .to_comments span { font-size: ' . $spacing['to_comments'] . 'em; }
	.format_text .post_tags { font-size: ' . $relative[$element_sizes['tags']] . 'em; line-height: ' . $spacing['tags'] . 'em; margin-bottom: ' . $spacing['tags'] . 'em; }

/*---:[ multimedia box ]:---*/
' . $font_families['multimedia_box'] . '
#custom_box { font-size: ' . round(($this->fonts['sizes']['multimedia_box'] / $this->base['num']), 3) . 'em; line-height: ' . round(($this->line_heights['multimedia_box'] / $this->fonts['sizes']['multimedia_box']), 3) . 'em; }

/*---:[ archive information block ]:---*/
#archive_info { padding-top: ' . $spacing['half'] . 'em; padding-bottom: ' . $spacing['half'] . 'em; }
	#archive_info p { font-size: ' . round(($element_sizes['archive_info'] / $this->base['num']), 1) . 'em; line-height: 1em; margin-bottom: ' . $spacing['half'] . 'em; }

/*---:[ previous and next links ]:---*/
.prev_next { padding-top: ' . $spacing['half'] . 'em; padding-bottom: ' . $spacing['half'] . 'em; }
	.prev_next p { font-size: ' . round(($element_sizes['prev_next'] / $this->base['num']), 1) . 'em; line-height: ' . round(($this->line_heights['content'] / $element_sizes['prev_next']), 3) . 'em; }
	.post_nav .previous { margin-bottom: ' . round((($this->line_heights['content'] / $element_sizes['prev_next']) / 4), 3) . 'em; }
	.post_nav a { font-size: ' . round(($this->fonts['sizes']['content'] / $element_sizes['prev_next']), 3) . 'em; line-height: ' . $spacing['relative'] . 'em; }

/*---:[ comment area ]:---*/
#comments { margin-top: ' . $spacing['double'] . 'em; }
.comments_intro { margin-bottom: ' . $spacing['half'] . 'em; }
	.comments_intro p { font-size: ' . round(($element_sizes['to_comments'] / $this->base['num']), 1) . 'em; line-height: ' . $spacing['to_comments'] . 'em; }
		.comments_intro span { font-size: ' . $spacing['to_comments'] . 'em; }
#comment_list, #trackback_list { margin-bottom: ' . $spacing['double'] . 'em; }
	dl#comment_list dt { padding-top: ' . round((($this->line_heights['content'] - 4) / $this->base['num']), 1) . 'em; }
		dl#comment_list dt span { font-size: ' . round(($element_sizes['comment_byline'] / $this->base['num']), 1) . 'em; line-height: ' . round(($this->line_heights['content'] / $element_sizes['comment_byline']), 3) . 'em; }
		dl#comment_list dt .comment_author { font-size: ' . round(($element_sizes['comment_author'] / $this->base['num']), 3) . 'em; line-height: ' . round(($this->line_heights['content'] / $element_sizes['comment_author']), 3) . 'em; padding-right: ' . round((($this->line_heights['content'] / 2) / $element_sizes['comment_author']), 3) . 'em; }
			.avatar img { margin-left: ' . round(($this->base['num'] / $element_sizes['comment_byline']), 3) . 'em; }
		.comment_time { padding-right: ' . round((($this->line_heights['content'] / 2) / $element_sizes['comment_byline']), 3) . 'em; }
		.comment_num { padding-left: ' . round(($this->base['num'] / $element_sizes['comment_byline']), 3) . 'em; }
			.comment_num a { font-size: ' . round(($element_sizes['comment_num'] / $element_sizes['comment_byline']), 3) . 'em; line-height: ' . round(($this->line_heights['content'] / $element_sizes['comment_num']), 3) . 'em; padding: ' . round((1 / $element_sizes['comment_num']), 3) . 'em ' . round((3 / $element_sizes['comment_num']), 3) . 'em; }
	dl#comment_list dd { padding-top: ' . $spacing['half'] . 'em; }
		dl#comment_list dd p.reply a { font-size: ' . round(($element_sizes['abbr'] / $this->fonts['sizes']['content']), 3) . 'em; line-height: ' . round(($this->line_heights['code'] / $element_sizes['abbr']), 3) . 'em; }
			dl#comment_list dl dd p.reply { margin-bottom: 0; }
	dl#comment_list dl dt, dl#comment_list dl dd { padding-top: 0; }
	dl#comment_list dl dd .format_text { margin-bottom: ' . $relative[$this->line_heights['content']] . 'em; }
#trackback_list { padding-top: ' . $spacing['half'] . 'em; list-style: none; }
	#trackback_list a { font-size: ' . round(($this->fonts['sizes']['content'] / $this->base['num']), 1) . 'em; line-height: ' . $spacing['relative'] . 'em; }
	#trackback_list span { font-size: ' . round(($element_sizes['trackback_timestamp'] / $this->base['num']), 1) . 'em; line-height: ' . round(($this->line_heights['content'] / $element_sizes['trackback_timestamp']), 3) . 'em; }
.comments_closed { margin-top: ' . $spacing['double'] . 'em; margin-bottom: ' . $spacing['line_height'] . 'em; }

/*---:[ comment form styles ]:---*/
#respond { margin-bottom: ' . $spacing['double'] . 'em; }
#respond_intro { margin-bottom: ' . $spacing['half'] . 'em; }
	#respond_intro p { font-size: ' . round(($element_sizes['respond'] / $this->base['num']), 1) . 'em; line-height: ' . round(($this->line_heights['content'] / $element_sizes['respond']), 3) . 'em; }
	#cancel-comment-reply-link { font-size: ' . round(($element_sizes['cancel'] / $this->base['num']), 1) . 'em; line-height: 1em; padding: ' . round(6 / $element_sizes['cancel'], 3) . 'em ' . round(8 / $element_sizes['cancel'], 3) . 'em; border-width: ' . round(2 / $element_sizes['cancel'], 3) . 'em; }
.login_alert { margin-top: ' . $spacing['double'] . 'em; margin-bottom: ' . $spacing['line_height'] . 'em; padding: ' . $spacing['half'] . 'em; }
#commentform { padding-top: ' . $spacing['half'] . 'em; }
	#commentform p, .login_alert p { font-size: ' . round(($this->fonts['sizes']['content'] / $this->base['num']), 1) . 'em; line-height: ' . $relative[$this->line_heights['content']] . 'em; }
	#commentform p.comment_box { line-height: ' . $spacing['relative_half'] . 'em; }
		#commentform label { padding-left: ' . $spacing['relative_half'] . 'em; }
		#commentform textarea { height: ' . round((($this->line_heights['content'] * 8) / $this->fonts['sizes']['content']), 3) . 'em; line-height: ' . $spacing['relative'] . 'em; }
		#commentform span.allowed { width: 97.3%; padding-top: ' . $relative[(($this->line_heights['code'] - 4) / 2)] . 'em; padding-bottom: ' . $relative[(($this->line_heights['code'] - 4) / 2)] . 'em; border-width: 0 ' . $relative[$this->form_input['border']['right']] . 'em ' . $relative[$this->form_input['border']['bottom']] . 'em ' . $relative[$this->form_input['border']['left']] . 'em; }
			#commentform span.allowed span { font-size: ' . $relative[$element_sizes['allowed']] . 'em; line-height: ' . round(($this->line_heights['content'] / $element_sizes['allowed']), 3) . 'em; padding: 0 ' . round(((($this->line_heights['code'] - 4) / 2) / $element_sizes['allowed']), 3) . 'em; }
	/* Support for the highly-recommended Subscribe to Comments Plugin */
	#commentform p.subscribe-to-comments { font-size: ' . round(($this->fonts['sizes']['content'] / $this->base['num']), 1) . 'em; }
		#commentform p.subscribe-to-comments label { font-size: 1em; }

/*---:[ sidebar styles ]:---*/
.sidebar { ' . $font_families['sidebars'] . '}
#column_wrap .sidebar ul.sidebar_list { padding-top: ' . $spacing['line_height'] . 'em; }
	li.widget { font-size: ' . round(($this->fonts['sizes']['sidebars'] / $this->base['num']), 1) . 'em; line-height: ' . $sidebar[$this->line_heights['sidebars']] . 'em; margin-bottom: ' . $sidebar[($this->line_heights['sidebars'] * 2)] . 'em; }
	li.tag_cloud { line-height: ' . $sidebar[($this->line_heights['sidebars'] + 4)] . 'em; }
		li.widget p { margin-bottom: ' . $sidebar[$this->line_heights['sidebars']] . 'em; }
		li.widget abbr, li.widget acronym { font-size: ' . $sidebar[$sidebar_sizes['abbr']] . 'em; }
		li.widget code { font-size: ' . $sidebar[$sidebar_sizes['code']] . 'em; }
			li.widget ul li { margin-bottom: ' . $sidebar[($this->fonts['sizes']['sidebars'] - 4)] . 'em; }
				li.widget li ul { margin: ' . $sidebar[($this->fonts['sizes']['sidebars'] - 4)] . 'em 0 0 ' . $sidebar[$this->line_heights['sidebars']] . 'em; }
	/*---:[ widget box styles ]:---*/
	li.widget .widget_box { padding: ' . $sidebar[($this->line_heights['sidebars'] / 2)] . 'em; border-width: ' . $sidebar[1] . 'em; }
	/*---:[ google custom search ]:---*/
	li.thesis_widget_google_cse form input[type="submit"] { font-size: ' . $sidebar[$sidebar_sizes['submit']] . 'em; ' . $font_families['sidebar'] . 'margin-top: ' . round((6 / $sidebar_sizes['submit']), 3) . 'em; padding: ' . round((2 / $sidebar_sizes['submit']), 3) . 'em ' . round((3 / $sidebar_sizes['submit']), 3) . 'em; }
	/*---:[ calendar widget ]:---*/
	#calendar_wrap a { padding: ' . $sidebar[1] . 'em; }
	#calendar_wrap a:hover { padding: ' . $sidebar[1] . 'em; }
		table#wp-calendar caption { font-size: ' . $sidebar[$sidebar_sizes['calendar_head']] . 'em; line-height: ' . round(($sidebar_sizes['calendar_line_height'] / $sidebar_sizes['calendar_head']), 3) . 'em; }
		table#wp-calendar th { font-size: ' . $sidebar[$sidebar_sizes['calendar_head']] . 'em; line-height: ' . round(($sidebar_sizes['calendar_line_height'] / $sidebar_sizes['calendar_head']), 3) . 'em; padding-top: ' . round((1 / $sidebar_sizes['calendar_head']), 3) . 'em; }
		table#wp-calendar td { line-height: ' . round(($sidebar_sizes['calendar_line_height'] / $this->fonts['sizes']['sidebars']), 3) . 'em; }
		table#wp-calendar td#next, table#wp-calendar td#prev { font-size: ' . $sidebar[$sidebar_sizes['calendar_head']] . 'em; line-height: ' . round(($sidebar_sizes['calendar_line_height'] / $sidebar_sizes['calendar_head']), 3) . 'em; }
		table#wp-calendar td#next { padding-right: ' . round((6 / $sidebar_sizes['calendar_head']), 3) . 'em; }
		table#wp-calendar td#prev { padding-left: ' . round((6 / $sidebar_sizes['calendar_head']), 3) . 'em; }

/*---:[ form inputs ]:---*/
input, textarea { ' . $font_families['body'] . '}
.format_text input, #commentform input, #commentform textarea { width: 45%; padding: ' . $relative[$this->form_input['padding']] . 'em; border-width: ' . $relative[$this->form_input['border']['top']] . 'em ' . $relative[$this->form_input['border']['right']] . 'em ' . $relative[$this->form_input['border']['bottom']] . 'em ' . $relative[$this->form_input['border']['left']] . 'em; }
#commentform textarea { width: 96%; }
.format_text input.form_submit, #commentform .form_submit { font-size: ' . $relative[$element_sizes['submit']] . 'em; padding: ' . round((5 / $element_sizes['submit']), 3) . 'em ' . round((4 / $element_sizes['submit']), 3) . 'em; }
.sidebar .text_input, .sidebar .form_submit { padding: ' . $sidebar[4] . 'em; ' . $sidebar_input_font . '}
.sidebar input[type="text"], .sidebar input[type="submit"] { padding: ' . $sidebar[4] . 'em; ' . $sidebar_input_font . '}

/*---:[ footer styles ]:---*/
#footer p { font-size: ' . round(($this->fonts['sizes']['footer'] / $this->base['num']), 1) . 'em; line-height: ' . round(($this->line_heights['footer'] / $this->fonts['sizes']['footer']), 3) . 'em; }';

		$this->css .= (!$this->multimedia_box['status']) ? "\n" . 'ul.sidebar_list { padding-top: ' . $spacing['line_height'] . 'em; }' : '';
	}

	function teasers() {
		$teaser_line_heights['excerpt'] = $this->teasers['font_sizes']['excerpt'] + 6;
		$teaser_line_heights['headline'] = $this->teasers['font_sizes']['headline'] + 6;

		if ($teaser_line_heights['excerpt'] % 2 == 1)
			$teaser_line_heights['excerpt'] = $teaser_line_heights['excerpt'] + 1;

		if ($teaser_line_heights['headline'] <= $teaser_line_heights['excerpt'])
			$teaser_line_heights['headline'] = $teaser_line_heights['excerpt'];
		
		$spacing['line_height'] = round(($teaser_line_heights['excerpt'] / $this->base['num']), 1);
		
		$font_stacks = thesis_get_fonts();
		$teaser_byline_font = ($this->fonts['families']['bylines']) ? 'font-family: ' . $font_stacks[$this->fonts['families']['bylines']]['family'] . '; ' : 'font-family: ' . $font_stacks[$this->fonts['families']['body']]['family'] . '; ';

		$this->css .= '

/*---:[ teaser styles ]:---*/
.teaser h2 { font-size: ' . round(($this->teasers['font_sizes']['headline'] / $this->base['num']), 1) . 'em; line-height: ' . round(($teaser_line_heights['headline'] / $this->teasers['font_sizes']['headline']), 3) . 'em; }
.teaser .format_teaser { font-size: ' . round(($this->teasers['font_sizes']['excerpt'] / $this->base['num']), 1) . 'em; line-height: ' . round(($teaser_line_heights['excerpt'] / $this->teasers['font_sizes']['excerpt']), 3) . 'em; margin-top: ' . round(($teaser_line_heights['excerpt'] / $this->teasers['font_sizes']['excerpt']), 3) . 'em; margin-bottom: ' . round(($teaser_line_heights['excerpt'] / $this->teasers['font_sizes']['excerpt']), 3) . 'em; }
.teaser .teaser_author, .teaser .teaser_category, .teaser .teaser_date, .teaser .teaser_comments, .teaser .edit_post { ' . $teaser_byline_font . '}
.teaser .teaser_author { font-size: ' . round(($this->teasers['font_sizes']['author'] / $this->base['num']), 1) . 'em; line-height: ' . round((($teaser_line_heights['excerpt'] - 2) / $this->teasers['font_sizes']['author']), 3) . 'em; }
.teaser .teaser_category { font-size: ' . round(($this->teasers['font_sizes']['category'] / $this->base['num']), 1) . 'em; line-height: ' . round((($teaser_line_heights['excerpt'] - 2) / $this->teasers['font_sizes']['category']), 3) . 'em; }
.teaser .teaser_date { font-size: ' . round(($this->teasers['font_sizes']['date'] / $this->base['num']), 1) . 'em; line-height: ' . round((($teaser_line_heights['excerpt'] - 2) / $this->teasers['font_sizes']['date']), 3) . 'em; }
.teaser .teaser_comments { font-size: ' . round(($this->teasers['font_sizes']['comments'] / $this->base['num']), 1) . 'em; line-height: ' . round((($teaser_line_heights['excerpt'] - 2) / $this->teasers['font_sizes']['comments']), 3) . 'em; }
.teaser .teaser_link { font-size: ' . round(($this->teasers['font_sizes']['link'] / $this->base['num']), 1) . 'em; line-height: ' . round(($teaser_line_heights['excerpt'] / $this->teasers['font_sizes']['link']), 3) . 'em; }
.teaser .post_tags { font-size: ' . round(($this->teasers['font_sizes']['tags'] / $this->base['num']), 1) . 'em; line-height: ' . round(($teaser_line_heights['excerpt'] / $this->teasers['font_sizes']['tags']), 3) . 'em; }
.teaser .edit_post { padding-left: ' . round((8 / $this->base['num']), 1) . 'em; }

/*---:[ thumbnails ]:---*/
.teaser .post_image_link img.alignleft { margin-right: ' . $spacing['line_height'] . 'em; margin-bottom: ' . $spacing['line_height'] . 'em; }
.teaser .post_image_link img.alignright { margin-left: ' . $spacing['line_height'] . 'em; margin-bottom: ' . $spacing['line_height'] . 'em; }
.teaser .post_image_link img.aligncenter { margin-bottom: ' . $spacing['line_height'] . 'em; }
.teaser .post_image_link img.alignnone { margin: 0 auto ' . $spacing['line_height'] . 'em 0; }
.teaser .post_image_link img.frame { padding: ' . round(((($teaser_line_heights['excerpt'] / 2) - 1) / $this->base['num']), 1) . 'em; border-width: ' . round((1 / $this->base['num']), 1) . 'em; }
.teaser .format_teaser .post_image_link img.alignleft { margin-right: ' . round((($teaser_line_heights['excerpt'] / 2) / $this->teasers['font_sizes']['excerpt']), 3) . 'em; margin-bottom: 0; }
.teaser .format_teaser .post_image_link img.alignright { margin-left: ' . round((($teaser_line_heights['excerpt'] / 2) / $this->teasers['font_sizes']['excerpt']), 3) . 'em; margin-bottom: 0; }
.teaser .format_teaser .post_image_link img.aligncenter { margin-bottom: ' . round(($teaser_line_heights['excerpt'] / $this->teasers['font_sizes']['excerpt']), 3) . 'em; }
.teaser .format_teaser .post_image_link img.frame { padding: ' . round(((round(($teaser_line_heights['excerpt'] / 2) / 2) - 1) / $this->teasers['font_sizes']['excerpt']), 3) . 'em; border-width: ' . round((1 / $this->teasers['font_sizes']['excerpt']), 3) . 'em; }';
	}

	function colors() {
		$this->css .= '

/*---:[ layout colors ]:---*/
';

		$this->css .= 'body { color: #' . $this->colors['text'] . '; background: #' . $this->colors['background'] . '; }' . "\n";
		
		if ($this->colors['shadow']) {
			if (strlen($this->colors['background']) == 6) {
				$rgb[0] = $this->colors['background'][0] . $this->colors['background'][1];
				$rgb[1] = $this->colors['background'][2] . $this->colors['background'][3];
				$rgb[2] = $this->colors['background'][4] . $this->colors['background'][5];
			}
			elseif (strlen($this->colors['background']) == 3) {
				$rgb[0] = $this->colors['background'][0] . $this->colors['background'][0];
				$rgb[1] = $this->colors['background'][1] . $this->colors['background'][1];
				$rgb[2] = $this->colors['background'][2] . $this->colors['background'][2];
			}

			foreach ($rgb as $key => $value) {
				$light[$key] = (hexdec($value) - 6 > 0) ? hexdec($value) - 6 : 0;
				$dark[$key] = (hexdec($value) - 18 > 0) ? hexdec($value) - 18 : 0;
				
				$light[$key] = ($light[$key] < 10) ? '0' . dechex($light[$key]) : dechex($light[$key]);
				$dark[$key] = ($dark[$key] < 10) ? '0' . dechex($dark[$key]) : dechex($dark[$key]);
			}
			
			$light_hex = $light[0] . $light[1] . $light[2];
			$dark_hex = $dark[0] . $dark[1] . $dark[2];
			
			$this->css .= '#container { padding: 0 0.3em; background: #' . $dark_hex . '; border: 0.4em solid #' . $light_hex . "; border-width: 0 0.4em; }\n";
		}
		
		if ($this->colors['page'])
			$this->css .= ($this->layout['framework'] == 'full-width') ? '.full_width > .page { background: #' . $this->colors['page'] . '; }' . "\n" : '#page { background: #' . $this->colors['page'] . "; }\n";
		elseif ($this->colors['background'] != 'fff' && $this->colors['background'] != 'ffffff')
			$this->css .= ($this->layout['framework'] == 'full-width') ? ".full_width > .page { background: #fff; }\n" : "#page { background: #fff; }\n";
		
		$this->css .= 'a, h2 a:hover, #logo a:hover { color: #' . $this->colors['link'] . "; }\n";
		$this->css .= ($this->colors['header']) ? '#logo, #logo a { color: #' . $this->colors['header'] . "; }\n" : '';
		$this->css .= ($this->colors['tagline'] && $this->colors['tagline'] != $this->colors['text']) ? '#tagline { color: #' . $this->colors['tagline'] . " }\n" : '';
		$this->css .= ($this->colors['headlines']) ? 'h1, h2, h2 a { color: #' . $this->colors['headlines'] . "; }\n" : '';
		$this->css .= ($this->colors['subheads'] && $this->colors['subheads'] != $this->colors['text']) ? '.format_text h2, .format_text h3, .format_text h4, .format_text h5, .format_text h6 { color: #' . $this->colors['subheads'] . "; }\n" : '';
		$this->css .= ($this->colors['bylines']) ? '.headline_meta, .headline_meta a, .teaser_author, .teaser_date, .teaser .edit_post, .teaser_author a, .teaser_comments, .teaser_category, .teaser .edit_post a { color: #' . $this->colors['bylines'] . "; }\n" . '.headline_meta a:hover, .teaser_author a:hover, .teaser_comments:hover, .teaser_category:hover, .teaser .edit_post a:hover { color: #' . $this->colors['text'] . "; }\n" : '';
		$this->css .= ($this->colors['code'] && $this->colors['code'] != $this->colors['text']) ? 'code, pre { color: #' . $this->colors['code'] . "; }\n" : '';
		$this->css .= ($this->colors['sidebars'] && $this->colors['sidebars'] != $this->colors['text']) ? '.sidebar { color: #' . $this->colors['sidebars'] . "; }\n" : '';
		$this->css .= ($this->colors['sidebar_headings'] && $this->colors['sidebar_headings'] != $this->colors['sidebars']) ? '.sidebar h3 { color: #' . $this->colors['sidebar_headings'] . "; }\n" : '';
		$this->css .= ($this->multimedia_box['color'] && $this->multimedia_box['color'] != $this->colors['text']) ? '#multimedia_box { color: #' . $this->multimedia_box['color'] . "; }\n" : '';
		$this->css .= '.image_box { background: #' . $this->multimedia_box['background']['image'] . "; }\n.video_box { background: #" . $this->multimedia_box['background']['video'] . "; }\n.custom_box { background: #" . $this->multimedia_box['background']['code'] . "; }\n";
		$this->css .= ($this->colors['footer']) ? '#footer, #footer a { color: #' . $this->colors['footer'] . "; }\n" . '#footer a:hover { color: #' . $this->colors['text'] . "; }\n" : '';

		$this->css .= "\n/*---:[ nav colors ]:---*/
.menu, .menu a, .menu li ul { border-color: #" . $this->nav['border']['color'] . "; }
.menu .current a, .menu .current-cat a { border-bottom-color: #" . $this->nav['background']['current'] . "; }
.menu ul .current a, .menu ul .current-cat a, .menu .current ul a, .menu .current-cat ul a { border-bottom-color: #" . $this->nav['border']['color'] . "; }
.menu a, .menu .current ul a, .menu .current-cat ul a { color: #" . $this->nav['link']['color'] . '; background: #' . $this->nav['background']['link'] . "; }
.menu a:hover, .menu .current ul a:hover, .menu .current-cat ul a:hover, .menu .current-parent a:hover { color: #" . $this->nav['link']['hover'] . '; background: #' . $this->nav['background']['hover'] . "; }
.menu .current a, .menu .current a:hover, .menu .current-cat a, .menu .current-cat a:hover { color: #" . $this->nav['link']['current'] . '; background: #' . $this->nav['background']['current'] . "; }
.menu .current-parent > a, .menu .current-cat-parent > a { color: #" . $this->nav['link']['parent'] . '; background: #' . $this->nav['background']['parent'] . "; }\n";
	}

	function borders() {
		$this->css .= ($this->borders['show']) ? "\n/*---:[ border package ]:---*/\n#header { border-width: 0 0 0.3em 0; }\n.post_box, .teasers_box { border-width: 0.1em 0 0 0; }\n#footer { border-width: 0.3em 0 0 0; }\n#feature_box, #archive_info, #comment_nav_2 { border-width: 0 0 0.2em 0; }\n.prev_next { border-width: 0.2em 0 0 0; }\n.image_box, .custom_box { border-width: 0 0 0.1em 0; }\n" : "\n\n/*---:[ border package ]:---*/\n#header, .post_box, .teasers_box, #footer, .image_box, .custom_box, #feature_box, #archive_info, .prev_next, #archive_info, .prev_next, #comment_nav_2 { border-width: 0; }\n";
	}
}

/**
 * function thesis_generate_css()
 *
 * Builds layout.css content then writes it to the file.
 *
 * @uses Thesis_CSS
 */
function thesis_generate_css() {
	if (is_writable(THESIS_LAYOUT_CSS)) {
		$thesis_css = new Thesis_CSS;
		$thesis_css->build();
		$lid = @fopen(THESIS_LAYOUT_CSS, 'w');
		@fwrite($lid, $thesis_css->css);
		@fclose($lid);
	}
}