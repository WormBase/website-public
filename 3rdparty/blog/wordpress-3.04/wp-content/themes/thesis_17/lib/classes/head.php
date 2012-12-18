<?php
/**
 * class thesis_head (Formerly called Head, and Document before that. Keeping notes? I didn't think so.)
 *
 * @package Thesis
 * @since 1.2
 */
class thesis_head {
	function build() {
		$head = new thesis_head;
		$head->title();
		$head->meta();
		$head->conditional_styles();
		$head->stylesheets();
		$head->links();
		$head->scripts();
		
		echo "<head " . apply_filters('thesis_head_profile', 'profile="http://gmpg.org/xfn/11"') . ">\n"; #filter
		echo '<meta http-equiv="Content-Type" content="' . get_bloginfo('html_type') . '; charset=' . get_bloginfo('charset') . '" />' . "\n"; #wp
		$head->output();
		wp_head(); #wp
		echo "\n</head>\n";
		
		$head->add_ons(); // this is bogus and will disappear once I get this all figured out
	}

	function title() {
		global $thesis_site, $thesis_pages;
		$site_name = get_bloginfo('name'); #wp
		$separator = ($thesis_site->head['title']['separator']) ? urldecode($thesis_site->head['title']['separator']) : '&#8212;';

		if (is_home() || is_front_page()) { #wp
			$tagline = get_bloginfo('description'); #wp
			$home_title = ($thesis_pages->home['head']['title']) ? trim(wptexturize(urldecode($thesis_pages->home['head']['title']))) : "$site_name $separator $tagline"; #wp

			if (get_option('show_on_front') == 'page' && is_front_page()) #wp
				$page_title = get_post_meta(get_option('page_on_front'), 'thesis_title', true); #wp
			elseif (get_option('show_on_front') == 'page' && is_home()) #wp
				$page_title = get_post_meta(get_option('page_for_posts'), 'thesis_title', true); #wp

			$output = ($page_title) ? trim(wptexturize(strip_tags(stripslashes($page_title)))) : $home_title; #wp
		}
		elseif (is_category()) { #wp
			global $wp_query; #wp
			$category_title = ($thesis_pages->categories[$wp_query->query_vars['cat']]['head']['title']) ? trim(wptexturize(urldecode($thesis_pages->categories[$wp_query->query_vars['cat']]['head']['title']))) : single_cat_title('', false); #wp
			$output = ($thesis_site->head['title']['branded']) ? "$category_title $separator $site_name" : $category_title;
		}
		elseif (is_tag()) {
			global $wp_query; #wp
			$tag_title = ($thesis_pages->tags[$wp_query->query_vars['tag_id']]['head']['title']) ? trim(wptexturize(urldecode($thesis_pages->tags[$wp_query->query_vars['tag_id']]['head']['title']))) : single_tag_title('', false); #wp
			$output = ($thesis_site->head['title']['branded']) ? "$tag_title $separator $site_name" : $tag_title;
		}
		elseif (is_search()) { #wp
			$search_title = __('You searched for', 'thesis') . ' &#8220;' . attribute_escape(get_search_query()) . '&#8221;'; #wp
			$output = ($thesis_site->head['title']['branded']) ? "$search_title $separator $site_name" : $search_title;
		}
		else {
			global $post; #wp
			$custom_title = (is_single() || is_page()) ? trim(wptexturize(strip_tags(stripslashes(get_post_meta($post->ID, 'thesis_title', true))))) : false; #wp
			$page_title = ($custom_title) ? $custom_title : trim(wp_title('', false)); #wp
			$output = ($thesis_site->head['title']['branded']) ? "$page_title $separator $site_name" : $page_title;
		}

		if (is_home() || is_archive() || is_search()) { #wp
			$current_page = get_query_var('paged'); #wp

			if ($current_page > 1)
				$output .= " $separator " . __('Page', 'thesis') . " $current_page";
		}

		$this->title['title'] = '<title>' . apply_filters('thesis_title', $output, $separator) . '</title>'; #wp #filter
	}

	function meta() {
		global $thesis_site;
		global $thesis_pages;

		// robots meta
		if (get_option('blog_public') != 0) { #wp
			$noindex = $thesis_site->head['meta']['robots']['noindex'];
			$nofollow = $thesis_site->head['meta']['robots']['nofollow'];
			$noarchive = $thesis_site->head['meta']['robots']['noarchive'];

			if (is_home() && (get_query_var('paged') > 1)) #wp
				$page_type = 'sub';
			elseif (is_author()) #wp
				$page_type = 'author';
			elseif (is_day()) #wp
				$page_type = 'day';
			elseif (is_month()) #wp
				$page_type = 'month';
			elseif (is_year()) #wp
				$page_type = 'year';

			if (!$page_type && (is_home() || is_front_page())) {
				if (get_option('show_on_front') == 'page' && is_front_page()) #wp
					$page_id = get_option('page_on_front'); #wp
				elseif (get_option('show_on_front') == 'page' && is_home()) #wp
					$page_id = get_option('page_for_posts'); #wp

				$robots_meta = ($page_id) ? get_post_meta($page_id, 'thesis_robots', true) : $thesis_pages->home['head']['meta']['robots'];
				if ($page_id) $robots_deprecated = get_post_meta($page_id, 'thesis_noindex', true);

				if (is_array($robots_meta)) {
					foreach ($robots_meta as $meta_tag => $value)
						if ($value) $content[] = $meta_tag;
				}
				elseif ($robots_deprecated)
					$content[] = 'noindex';
			}
			elseif (!$page_type && (is_page() || is_single())) { #wp
				global $post; #wp
				$robots_meta = get_post_meta($post->ID, 'thesis_robots', true); #wp
				$robots_deprecated = get_post_meta($post->ID, 'thesis_noindex', true); #wp
				
				if (is_array($robots_meta)) {
					foreach ($robots_meta as $meta_tag => $value)
						if ($value) $content[] = $meta_tag;
				}
				elseif ($robots_deprecated)
					$content[] = 'noindex';
			}
			elseif (is_category()) { #wp
				global $wp_query; #wp
				$cat_noindex = $thesis_pages->categories[$wp_query->query_vars['cat']]['head']['meta']['robots']['noindex'];
				$cat_nofollow = $thesis_pages->categories[$wp_query->query_vars['cat']]['head']['meta']['robots']['nofollow'];
				$cat_noarchive = $thesis_pages->categories[$wp_query->query_vars['cat']]['head']['meta']['robots']['noarchive'];

				if ((isset($cat_noindex) && $cat_noindex) || (!isset($cat_noindex) && $noindex['category']))
					$content[] = 'noindex';
				if ((isset($cat_nofollow) && $cat_nofollow) || (!isset($cat_nofollow) && $nofollow['category']))
					$content[] = 'nofollow';
				if ((isset($cat_noarchive) && $cat_noarchive) || (!isset($cat_noarchive) && $noarchive['category']))
					$content[] = 'noarchive';
			}
			elseif (is_tag()) { #wp
				global $wp_query; #wp
				$tag_noindex = $thesis_pages->tags[$wp_query->query_vars['tag_id']]['head']['meta']['robots']['noindex'];
				$tag_nofollow = $thesis_pages->tags[$wp_query->query_vars['tag_id']]['head']['meta']['robots']['nofollow'];
				$tag_noarchive = $thesis_pages->tags[$wp_query->query_vars['tag_id']]['head']['meta']['robots']['noarchive'];

				if ((isset($tag_noindex) && $tag_noindex) || (!isset($tag_noindex) && $noindex['tag']))
					$content[] = 'noindex';
				if ((isset($tag_nofollow) && $tag_nofollow) || (!isset($tag_nofollow) && $nofollow['tag']))
					$content[] = 'nofollow';
				if ((isset($tag_noarchive) && $tag_noarchive) || (!isset($tag_noarchive) && $noarchive['tag']))
					$content[] = 'noarchive';
			}
			elseif (is_search() || is_404()) #wp
				$content[] = 'noindex, nofollow, noarchive';
			elseif ($page_type) {
				if ($noindex[$page_type])
					$content[] = 'noindex';
				if ($nofollow[$page_type])
					$content[] = 'nofollow';
				if ($noarchive[$page_type])
					$content[] = 'noarchive';
			}

			if ($thesis_site->head['meta']['robots']['noodp'])
				$content[] = 'noodp';
			if ($thesis_site->head['meta']['robots']['noydir'])
				$content[] = 'noydir';

			$meta['robots'] = ($content) ? '<meta name="robots" content="' . implode(', ', $content) . '" />' : false;
		}

		// meta description and keywords
		if (!class_exists('All_in_One_SEO_Pack')) {
			if (is_home() || is_front_page()) {
				if (get_option('show_on_front') == 'page' && is_front_page()) #wp
					$page_id = get_option('page_on_front'); #wp
				elseif (get_option('show_on_front') == 'page' && is_home()) #wp
					$page_id = get_option('page_for_posts'); #wp

				$keywords = ($page_id) ? get_post_meta($page_id, 'thesis_keywords', true) : urldecode($thesis_pages->home['head']['meta']['keywords']);

				if ($page_id && !get_post_meta($page_id, 'thesis_no_description', true))
					$description = strip_tags(stripslashes(get_post_meta($page_id, 'thesis_description', true)));
				else
					$description = ($thesis_pages->home['head']['meta']['description']) ? urldecode($thesis_pages->home['head']['meta']['description']) : get_bloginfo('description');

				if ($description)
					$meta['description'] = '<meta name="description" content="' . trim(wptexturize($description)) . '" />'; #wp
				if ($keywords)
					$meta['keywords'] = '<meta name="keywords" content="' . trim(wptexturize($keywords)) . '" />';
			}
			elseif (is_single() || is_page()) { #wp
				global $post; #wp

				$no_description = get_post_meta($post->ID, 'thesis_no_description', true); #wp
				$description = get_post_meta($post->ID, 'thesis_description', true); #wp
				$deprecated_description = get_post_meta($post->ID, thesis_get_custom_field_key('meta'), true); #wp

				$keywords = get_post_meta($post->ID, 'thesis_keywords', true); #wp
				$deprecated_keywords = get_post_meta($post->ID, thesis_get_custom_field_key('keywords'), true); #wp

				if (!$no_description) {
					if (strlen($description))
						$meta['description'] = '<meta name="description" content="' . trim(wptexturize(strip_tags(stripslashes($description)))) . '" />'; #wp
					elseif (strlen($deprecated_description))
						$meta['description'] = '<meta name="description" content="' . trim(wptexturize(strip_tags(stripslashes($deprecated_description)))) . '" />'; #wp
					else {
						setup_postdata($post); #wp
						add_filter('excerpt_length', 'thesis_meta_excerpt_length'); #wp #filter
						$excerpt = trim(str_replace('[...]', '', wp_trim_excerpt(''))); #wp
						remove_filter('excerpt_length', 'thesis_meta_excerpt_length'); #wp
						$meta['description'] = '<meta name="description" content="' . $excerpt . '" />';
					}
				}

				if (strlen($keywords))
					$meta['keywords'] = '<meta name="keywords" content="' . trim(wptexturize(strip_tags(stripslashes($keywords)))) . '" />'; #wp
				elseif (strlen($deprecated_keywords))
					$meta['keywords'] = '<meta name="keywords" content="' . trim(wptexturize(strip_tags(stripslashes($deprecated_keywords)))) . '" />'; #wp
				else {
					$tags = thesis_get_post_tags($post->ID);

					if ($tags)
						$meta['keywords'] = '<meta name="keywords" content="' . implode(', ', $tags) . '" />';
				}
			}
			elseif (is_category() || is_tag()) { #wp
				global $wp_query; #wp
				$description = (is_category()) ? urldecode($thesis_pages->categories[$wp_query->query_vars['cat']]['head']['meta']['description']) : urldecode($thesis_pages->tags[$wp_query->query_vars['tag_id']]['head']['meta']['description']); #wp
				$keywords = (is_category()) ? urldecode($thesis_pages->categories[$wp_query->query_vars['cat']]['head']['meta']['keywords']) : urldecode($thesis_pages->tags[$wp_query->query_vars['tag_id']]['head']['meta']['keywords']); #wp

				if ($description)
					$meta['description'] = '<meta name="description" content="' . trim(wptexturize($description)) . '" />'; #wp
				if ($keywords)
					$meta['keywords'] = '<meta name="keywords" content="' . trim(wptexturize($keywords)) . '" />'; #wp
			}
		}
		
		if ($meta)
			$this->meta = $meta;
	}
	
	function conditional_styles() {
		global $thesis_design;

		if ($thesis_design->multimedia_box['status'] && !thesis_show_multimedia_box()) {
			$css = new Thesis_CSS;
			$css->baselines();
			$padding = round(($css->line_heights['content'] / $styles->base['num']), 1);
			$conditional_styles['mm_box'] = '<style type="text/css">#sidebars .sidebar ul.sidebar_list { padding-top: ' . $padding . 'em; }</style>';
		}
		elseif (!$thesis_design->multimedia_box['status'] && thesis_show_multimedia_box())
			$conditional_styles['mm_box'] = '<style type="text/css">#sidebars .sidebar ul.sidebar_list { padding-top: 0; }</style>';

		if ($conditional_styles)
			$this->conditional_styles = $conditional_styles;
	}
	
	function stylesheets() {
		global $thesis_design;

		// Main stylesheet
		$date_modified = filemtime(TEMPLATEPATH . '/style.css');
		$styles['core'] = array(
			'url' => get_bloginfo('stylesheet_url') . '?' . date('mdy-Gis', $date_modified), #wp
			'media' => 'screen, projection'
		);

		if (file_exists(THESIS_CUSTOM)) {
			$path = THESIS_CUSTOM;
			$url = THESIS_CUSTOM_FOLDER;
		}
		elseif (file_exists(TEMPLATEPATH . '/custom-sample')) {
			$path = TEMPLATEPATH . '/custom-sample';
			$url = THESIS_SAMPLE_FOLDER;
		}

		$layout_path = "$path/layout.css";
		$custom_path = "$path/custom.css";
		$layout_url = "$url/layout.css";
		$custom_url = "$url/custom.css";

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
		if ($thesis_design->layout['custom']) {
			$date_modified = filemtime($custom_path);
			
			$styles['custom'] = array(
				'url' => $custom_url . '?' . date('mdy-Gis', $date_modified),
				'media' => 'screen, projection'
			);
		}

		foreach ($styles as $type => $style)
			$stylesheets[$type] = ($type == 'ie') ? sprintf('<!--[if lte IE 8]><link rel="stylesheet" href="%1$s" type="text/css" media="%2$s" /><![endif]-->', $style['url'], $style['media']) : sprintf('<link rel="stylesheet" href="%1$s" type="text/css" media="%2$s" />', $style['url'], $style['media']);

		$this->stylesheets = $stylesheets;
	}
	
	function links() {
		global $thesis_site;

		// Canonical URL
		if (!function_exists('yoast_canonical_link') && $thesis_site->head['links']['canonical']) {
			if (is_single() || is_page()) { #wp
				global $post;				
				$url = (is_page() && get_option('show_on_front') == 'page' && get_option('page_on_front') == $post->ID) ? trailingslashit(get_permalink()) : get_permalink(); #wp
			}
			elseif (is_author()) { #wp
				$author = get_userdata(get_query_var('author')); #wp
				$url = get_author_link(false, $author->ID, $author->user_nicename); #wp
			}
			elseif (is_category()) #wp
				$url = get_category_link(get_query_var('cat')); #wp
			elseif (is_tag()) { #wp
				$tag = get_term_by('slug', get_query_var('tag'), 'post_tag'); #wp

				if (!empty($tag->term_id))
					$url = get_tag_link($tag->term_id); #wp
			}
			elseif (is_day()) #wp
				$url = get_day_link(get_query_var('year'), get_query_var('monthnum'), get_query_var('day')); #wp
			elseif (is_month()) #wp
				$url = get_month_link(get_query_var('year'), get_query_var('monthnum')); #wp
			elseif (is_year()) #wp
				$url = get_year_link(get_query_var('year')); #wp
			elseif (is_home()) #wp
				$url = (get_option('show_on_front') == 'page') ? trailingslashit(get_permalink(get_option('page_for_posts'))) : trailingslashit(get_option('home')); #wp

			$links['canonical'] = '<link rel="canonical" href="' . $url . '" />';
		}

		$feed_title = get_bloginfo('name') . ' RSS Feed'; #wp
		$links['alternate'] = '<link rel="alternate" type="application/rss+xml" title="' . $feed_title . '" href="' . thesis_feed_url() . '" />';
		$links['pingback'] = '<link rel="pingback" href="' . get_bloginfo('pingback_url') . '" />'; #wp
		$this->links = $links;
	}

	function scripts() {
		global $thesis_site;

		if ($thesis_site->head['scripts'])
			$this->scripts['head'] = stripslashes($thesis_site->head['scripts']);
			
		if ((is_single() && get_option('thread_comments')) || (is_page() && get_option('thread_comments') && !$thesis_site->comments['disable_pages']))
			wp_enqueue_script('comment-reply');
	}

	function output() {
		$head_items = array();

		foreach ($this as $item)
			$head_items[] = implode("\n", $item);

		echo implode("\n", $head_items);
		echo "\n";
	}
	
	function add_ons() {
		// Feature box
		thesis_add_feature_box();
	}
}