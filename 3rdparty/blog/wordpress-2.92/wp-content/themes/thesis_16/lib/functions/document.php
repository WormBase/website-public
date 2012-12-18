<?php

function thesis_output_title() {
	// Is an SEO title tag plugin already being used? If so, defer to it to prevent conflict.
	if (function_exists('seo_title_tag'))
		seo_title_tag();
	else {
		global $post;
		global $thesis;
		$site_name = get_bloginfo('name');
		$separator = thesis_title_separator($thesis['head']);
	
		if (is_home() || is_front_page()) {
			// Allow for custom home pages to have completely custom <title> tag, like pages and posts
			if (get_option('show_on_front') == 'page' && is_front_page())
				$title_override = strip_tags(stripslashes(get_post_meta($post->ID, 'thesis_title', true)));
			elseif (get_option('show_on_front') == 'page' && is_home())
				$title_override = strip_tags(stripslashes(get_post_meta(get_option('page_for_posts'), 'thesis_title', true)));

			if (!$title_override) {
				$site_tagline = get_bloginfo('description');

				if ($thesis['head']['title']['tagline'] && $thesis['head']['title']['tagline_first'])
					echo "$site_tagline $separator $site_name";
				elseif ($thesis['head']['title']['title'] && $thesis['head']['title']['tagline'])
					echo "$site_name $separator $site_tagline";
				elseif ($thesis['head']['title']['tagline'])
					echo $site_tagline;
				else
					echo $site_name;
			}
			else
				echo $title_override;
		}
		elseif (is_category()) {
			$category_description = trim(strip_tags(category_description()));
			$category_title = (strlen($category_description)) ? $category_description : single_cat_title();

			if ($thesis['head']['title']['branded'])
				echo "$category_title $separator $site_name";
			else
				echo $category_title;
		}
		elseif (is_search()) {
			$search_title = __('You searched for', 'thesis') . ' &#8220;' . attribute_escape(get_search_query()) . '&#8221;';
			
			if ($thesis['head']['title']['branded'])
				echo "$search_title $separator $site_name";
			else
				echo $search_title;
		}
		else {
			$custom_title = (is_single() || is_page()) ? get_post_meta($post->ID, 'thesis_title', true) : false;
			$page_title = ($custom_title) ? strip_tags(stripslashes($custom_title)) : trim(wp_title('', false));

			if ($thesis['head']['title']['branded'])
				echo "$page_title $separator $site_name";
			else
				echo $page_title;
		}
		
		if (is_home() || is_archive() || is_search()) {
			$current_page = get_query_var('paged');
			
			if ($current_page > 1)
				echo " $separator " . __('Page', 'thesis') . " $current_page";
		}
	}
}

function thesis_title_separator($head) {
	return ($head['title']['separator']) ? urldecode($head['title']['separator']) : '&#8212;';
}

function thesis_feed_url($display = false) {
	global $thesis;
	$feed_url = ($thesis['feed']['url']) ? $thesis['feed']['url'] : get_bloginfo(get_default_feed() . '_url');

	if ($display)
		echo $feed_url;
	else
		return $feed_url;
}

function thesis_body_classes() {
	global $thesis_design;
	$browser = $_SERVER['HTTP_USER_AGENT'];

	// Enable custom stylesheet
	if ($thesis_design['style']['custom'])
		$classes[] = 'custom';
	
	// Enable skin stylesheet
/*	if ($thesis['style']['skin']) {
		$skin_file = $thesis['style']['skin'];
		$classes[] = str_replace('.css', '', $skin_file);
	}*/
	
	// Generate per-page classes
	if (is_page() || is_single()) {
		global $post;
		$custom_slug = get_post_meta($post->ID, 'thesis_slug', true);
		$deprecated_custom_slug = get_post_meta($post->ID, thesis_get_custom_field_key('slug'), true);

		if ($custom_slug)
			$classes[] = $custom_slug;
		elseif ($deprecated_custom_slug)
			$classes[] = $deprecated_custom_slug;
		elseif (is_page())
			$classes[] = $post->post_name;
	}
	elseif (is_category()) {
		$categories = thesis_get_categories(true);
		$classes[] = 'cat_' . $categories[intval(get_query_var('cat'))];
	}
	elseif (is_tag()) {
		$tags = thesis_get_tags(true);
		$classes[] = 'tag_' . $tags[intval(get_query_var('tag_id'))];
	}
	elseif (is_author()) {
		$author = thesis_get_author_data(get_query_var('author'));
		$classes[] = $author->user_nicename;
	}
	elseif (is_day())
		$classes[] = 'daily ' . strtolower(get_the_time('M_d_Y'));
	elseif (is_month())
		$classes[] = 'monthly ' . strtolower(get_the_time('M_Y'));
	elseif (is_year())
		$classes[] = 'year_' . strtolower(get_the_time('Y'));
	
	$classes = apply_filters('thesis_body_classes', $classes);
	
	if (is_array($classes))
		$classes = implode(' ', $classes);
		
	if ($classes)
		echo ' class="' . $classes . '"';
}

function thesis_title_and_tagline() {
	global $thesis;

	if ($thesis['display']['header']['title'] || $_GET['template']) {
		if (!$thesis['display']['header']['tagline'] && (is_home() || is_front_page())) {
?>
		<h1 id="logo"><a href="<?php bloginfo('url'); ?>"><?php bloginfo('name'); ?></a></h1>
<?php
		}
		else {
?>
		<p id="logo"><a href="<?php bloginfo('url'); ?>"><?php bloginfo('name'); ?></a></p>
<?php
		}
	}
	
	if ($thesis['display']['header']['tagline'] || $_GET['template']) {
		if (is_home() || is_front_page()) {
?>
		<h1 id="tagline"><?php bloginfo('description'); ?></h1>
<?php 
		}
		else {
?>
		<p id="tagline"><?php bloginfo('description'); ?></p>
<?php
		}
	}
}

function thesis_trackback_rdf() {
	if (is_single()) {
		echo '<!-- ';
		trackback_rdf();
		echo ' -->' . "\n";
	}
}

function thesis_404_title() {
	_e('You 404&#8217;d it. Gnarly, dude.', 'thesis');
}

function thesis_404_content() {
?>
<p><?php _e('Surfin&#8217; ain&#8217;t easy, and right now, you&#8217;re lost at sea. But don&#8217;t worry; simply pick an option from the list below, and you&#8217;ll be back out riding the waves of the Internet in no time.', 'thesis'); ?></p>
<ul>
	<li><?php _e('Hit the &#8220;back&#8221; button on your browser. It&#8217;s perfect for situations like this!', 'thesis'); ?></li>
	<li><?php printf(__('Head on over to the <a href="%s" rel="nofollow">home page</a>.', 'thesis'), get_bloginfo('url')); ?></li>
	<li><?php _e('Punt.', 'thesis'); ?></li>
</ul>
<?php	
}

function thesis_admin_link() {
	global $thesis;

	if ($thesis['display']['admin']['link'] || $_GET['preview'])
		echo '		<p><a href="' . admin_url() . '">' . __('WordPress Admin', 'thesis') . '</a></p>' . "\n";
}

function thesis_ie_clear() {
?>
<!--[if lte IE 7]>
<div id="ie_clear"></div>
<![endif]-->
<?php
}

function thesis_add_footer_scripts() {
	global $thesis;

	if ($thesis['scripts']['footer'])
		add_action('thesis_hook_after_html', 'thesis_footer_scripts');
}

function thesis_footer_scripts() {
	global $thesis;
	echo stripslashes($thesis['scripts']['footer']) . "\n";
}