<?php

function thesis_redirect() {
	global $wp_query;
	if ($wp_query->is_singular) {
		$redirect = get_post_meta($wp_query->post->ID, 'thesis_redirect', true);
		if ($redirect) wp_redirect($redirect, 301);
	}
}

function thesis_meta_excerpt_length($length) {
	return (apply_filters('thesis_meta_excerpt_length', 40)); #wp
}

function thesis_feed_url($display = false) {
	global $thesis_site;
	$feed_url = ($thesis_site->head['feed']['url']) ? $thesis_site->head['feed']['url'] : get_bloginfo(get_default_feed() . '_url');
	$feed_url = apply_filters('thesis_feed_url', $feed_url);

	if ($display)
		echo $feed_url;
	else
		return $feed_url;
}

function thesis_body_classes() {
	global $thesis_design;
	$browser = $_SERVER['HTTP_USER_AGENT'];

	// Enable custom stylesheet
	if ($thesis_design->layout['custom'])
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
		
		if (is_page())
			$classes[] = $post->post_name;

		if ($custom_slug)
			$classes[] = $custom_slug;
		elseif ($deprecated_custom_slug)
			$classes[] = $deprecated_custom_slug;
			
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
		return ' class="' . $classes . '"';
}

function thesis_title_and_tagline() {
	global $thesis_site;

	if ($thesis_site->display['header']['title'] || $_GET['template']) {
		if (!$thesis_site->display['header']['tagline'] && (is_home() || is_front_page()))
			echo "\t\t<h1 id=\"logo\"><a href=\"" . get_bloginfo('url') . "\">" . get_bloginfo('name') . "</a></h1>\n";
		else
			echo "\t\t<p id=\"logo\"><a href=\"" . get_bloginfo('url') . "\">" . get_bloginfo('name') . "</a></p>\n";
	}

	if ($thesis_site->display['header']['tagline'] || $_GET['template']) {
		if (is_home() || is_front_page())
			echo "\t\t<h1 id=\"tagline\">" . get_bloginfo('description') . "</h1>\n";
		else
			echo "\t\t<p id=\"tagline\">" . get_bloginfo('description') . "</p>\n";
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
	global $thesis_site;
	if ($thesis_site->display['admin']['link'] || $_GET['preview']) echo "\t\t<p><a href=\"" . admin_url() . '">' . __('WordPress Admin', 'thesis') . "</a></p>\n";
}

function thesis_ie_clear($output = true) {
	$ie_clear = "<!--[if lte IE 8]>\n<div id=\"ie_clear\"></div>\n<![endif]-->\n";
	if ($output) echo $ie_clear;
	else return $ie_clear;
}