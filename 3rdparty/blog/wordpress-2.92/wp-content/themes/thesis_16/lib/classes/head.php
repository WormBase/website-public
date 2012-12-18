<?php
/**
 * class Head (formerly called Document)
 *
 * @package Thesis
 * @since 1.2
 */
class Head {
	function build() {
		$head = new Head;
		$head->meta();
		$head->conditional_styles();
		$head->stylesheets();
		$head->scripts();
		$head->rss_xml();
		$head->user_scripts();
		$head->output();
		$head->add_ons();
	}

	/**
	 * Compile various meta tags.
	 */
	function meta() {
		global $thesis;

		// Public blogs need to give robots a little direction.
		if (get_option('blog_public') != 0) {
			$current_page = get_query_var('paged');

			// Should robots be allowed to index the content?
			if (is_page() || is_single()) {
				global $post;
				if (get_post_meta($post->ID, 'thesis_noindex', true))
					$meta['robots'] = '<meta name="robots" content="noindex, nofollow" />';
			}
			elseif (is_search() || is_404() || (is_category() && $thesis['head']['noindex']['category']) || (is_tag() && $thesis['head']['noindex']['tag']) || (is_author() && $thesis['head']['noindex']['author']) || (is_day() && $thesis['head']['noindex']['day']) || (is_month() && $thesis['head']['noindex']['month']) || (is_year() && $thesis['head']['noindex']['year']) || $current_page > 1)
				$meta['robots'] = '<meta name="robots" content="noindex, nofollow" />';
		}
		
		// Canonical URL
		if (!function_exists('yoast_canonical_link') && $thesis['head']['canonical'] && !is_404()) {
			if (is_single() || is_page()) {
				global $post;				
				$url = (is_page() && get_option('show_on_front') == 'page' && get_option('page_on_front') == $post->ID) ? trailingslashit(get_permalink()) : get_permalink();
			}
			elseif (is_author()) {
				$author = get_userdata(get_query_var('author'));
				$url = get_author_link(false, $author->ID, $author->user_nicename);
			}
			elseif (is_category())
				$url = get_category_link(get_query_var('cat'));
			elseif (is_tag()) {
				$tag = get_term_by('slug', get_query_var('tag'), 'post_tag');
				
				if (!empty($tag->term_id))
					$url = get_tag_link($tag->term_id);
			}
			elseif (is_day())
				$url = get_day_link(get_query_var('year'), get_query_var('monthnum'), get_query_var('day'));
			elseif (is_month())
				$url = get_month_link(get_query_var('year'), get_query_var('monthnum'));
			elseif (is_year())
				$url = get_year_link(get_query_var('year'));
			elseif (is_home())
				$url = (get_option('show_on_front') == 'page') ? trailingslashit(get_permalink(get_option('page_for_posts'))) : trailingslashit(get_option('home'));

			$meta['canonical'] = '<link rel="canonical" href="' . $url . '" />';
		}

		// Is All-in-One SEO installed? If so, defer to it for SEO meta handling.
		if (!class_exists('All_in_One_SEO_Pack')) {
			if (is_single() || is_page()) {
				global $post;

				$custom_description = get_post_meta($post->ID, 'thesis_description', true);
				$deprecated_custom_meta = get_post_meta($post->ID, thesis_get_custom_field_key('meta'), true);
				$excerpt = trim(strip_tags(wp_specialchars($post->post_excerpt)));

				$custom_keywords = get_post_meta($post->ID, 'thesis_keywords', true);
				$deprecated_custom_keywords = get_post_meta($post->ID, thesis_get_custom_field_key('keywords'), true);

				if (strlen($custom_description))
					$meta['description'] = '<meta name="description" content="' . trim(wptexturize(strip_tags(stripslashes($custom_description)))) . '" />';
				elseif (strlen($deprecated_custom_meta))
					$meta['description'] = '<meta name="description" content="' . trim(wptexturize(strip_tags(stripslashes($deprecated_custom_meta)))) . '" />';
				elseif (strlen($excerpt))
					$meta['description'] = '<meta name="description" content="' . $excerpt . '" />';

				if (strlen($custom_keywords))
					$meta['keywords'] = '<meta name="keywords" content="' . trim(wptexturize(strip_tags(stripslashes($custom_keywords)))) . '" />';
				elseif (strlen($deprecated_custom_keywords))
					$meta['keywords'] = '<meta name="keywords" content="' . trim(wptexturize(strip_tags(stripslashes($deprecated_custom_keywords)))) . '" />';
				else {
					$tags = thesis_get_post_tags($post->ID);

					if ($tags)
						$meta['keywords'] = '<meta name="keywords" content="' . implode(', ', $tags) . '" />';
				}
			}
			elseif (is_category()) {
				$category_description = trim(strip_tags(stripslashes(category_description())));
				$meta['description'] = (strlen($category_description)) ? '<meta name="description" content="' . $category_description . '" />' : '<meta name="description" content="' . single_cat_title('', false) . '" />';
			}
			else {
				if ($thesis['home']['meta']['description'])
					$meta['description'] = '<meta name="description" content="' . trim(wptexturize(strip_tags(stripslashes($thesis['home']['meta']['description'])))) . '" />';
				elseif (strlen(get_bloginfo('description')))
					$meta['description'] = '<meta name="description" content="' . get_bloginfo('description') . '" />';
				
				if ($thesis['home']['meta']['keywords'])
					$meta['keywords'] = '<meta name="keywords" content="' . $thesis['home']['meta']['keywords'] . '" />';
			}
		}

		if ($thesis['head']['version'])
			$meta['version'] = '<meta name="wp_theme" content="Thesis ' . thesis_get_theme_version() . '" />';
		
		if ($meta)
			$this->meta = $meta;
	}
	
	function conditional_styles() {
		global $thesis_design;
		
		if ($thesis_design['multimedia_box']['status'] && !thesis_show_multimedia_box()) {
			$css = new Thesis_CSS;
			$css->baselines();
			$padding = round(($css->line_heights['content'] / $styles->base['num']), 1);
			$conditional_styles['mm_box'] = '<style type="text/css">#sidebars .sidebar ul.sidebar_list { padding-top: ' . $padding . 'em; }</style>';
		}
		elseif (!$thesis_design['multimedia_box']['status'] && thesis_show_multimedia_box())
			$conditional_styles['mm_box'] = '<style type="text/css">#sidebars .sidebar ul.sidebar_list { padding-top: 0; }</style>';
		
		if ($conditional_styles)
			$this->conditional_styles = $conditional_styles;
	}
	
	function stylesheets() {
		global $thesis_design;

		// Main stylesheet
		$date_modified = filemtime(TEMPLATEPATH . '/style.css');
		$styles['core'] = array(
			'url' => get_bloginfo('stylesheet_url') . '?' . date('mdy-Gis', $date_modified),
			'media' => 'screen, projection'
		);

		if (file_exists(THESIS_CUSTOM)) {
			$layout_path = THESIS_CUSTOM . '/layout.css';
			$custom_path = THESIS_CUSTOM . '/custom.css';
			$layout_url = THESIS_CUSTOM_FOLDER . '/layout.css';
			$custom_url = THESIS_CUSTOM_FOLDER . '/custom.css';
		}
		elseif (file_exists(TEMPLATEPATH . '/custom-sample')) {
			$layout_path = TEMPLATEPATH . '/custom-sample/layout.css';
			$custom_path = TEMPLATEPATH . '/custom-sample/custom.css';
			$layout_url = get_bloginfo('template_url') . '/custom-sample/layout.css';
			$custom_url = get_bloginfo('template_url') . '/custom-sample/custom.css';
		}

		$date_modified = filemtime($layout_path);
		$styles['layout'] = array(
			'url' => $layout_url . '?' . date('mdy-Gis', $date_modified),
			'media' => 'screen, projection'
		);
		
		$date_modified = filemtime(THESIS_CSS . '/ie.css');
		$styles['ie'] = array(
			'url' => THESIS_CSS_FOLDER . '/ie.css?' . date('mdy-Gis', $date_modified),
			'media' => 'screen, projection'
		);

		// Custom stylesheet, if applicable
		if ($thesis_design['style']['custom']) {
			$date_modified = filemtime($custom_path);
			
			$styles['custom'] = array(
				'url' => $custom_url . '?' . date('mdy-Gis', $date_modified),
				'media' => 'screen, projection'
			);
		}
		
		foreach ($styles as $type => $style)
			$stylesheets[$type] = ($type == 'ie') ? sprintf('<!--[if lte IE 7]><link rel="stylesheet" href="%1$s" type="text/css" media="%2$s" /><![endif]-->', $style['url'], $style['media']) : $stylesheets[$type] = sprintf('<link rel="stylesheet" href="%1$s" type="text/css" media="%2$s" />', $style['url'], $style['media']);
		
		$this->stylesheets = $stylesheets;
	}
	
	function scripts() {
	}
	
	function rss_xml() {
		$feed_title = get_bloginfo('name') . ' RSS Feed';
		$rss_xml['alternate'] = '<link rel="alternate" type="application/rss+xml" title="' . $feed_title . '" href="' . thesis_feed_url() . '" />';
		$rss_xml['pingback'] = '<link rel="pingback" href="' . get_bloginfo('pingback_url') . '" />';
		$this->rss_xml = $rss_xml;
	}

	function user_scripts() {
		global $thesis;

		if ($thesis['scripts']['header']) {
			$user_scripts['header'] = stripslashes($thesis['scripts']['header']) . "\n";
			$this->user_scripts = $user_scripts;
		}
	}

	function output() {
		$head_items = array();

		foreach ($this as $item)
			$head_items[] = implode("\n", $item);

		echo "\n";
		echo implode("\n\n", $head_items);
	}
	
	function add_ons() {
		// Feature box
		thesis_add_feature_box();
	}
}

function thesis_get_theme_version() {
	$theme_data = get_theme_data(TEMPLATEPATH . '/style.css');
	$theme_version = trim($theme_data['Version']);
	
	if (strlen($theme_version) > 0)
		return $theme_version;
}