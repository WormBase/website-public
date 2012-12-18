<?php

function thesis_content_classes() {	
	if (have_posts()) {
		if (!is_page())
			$classes[] = 'hfeed';

		if (is_array($classes))
			$classes = implode(' ', $classes);

		if ($classes) {
			$classes = apply_filters('thesis_content_classes', $classes);
			echo ' class="' . $classes . '"';
		}
	}
}

function thesis_headline_area($post_count = false, $post_image = false) {
?>
<div class="headline_area">
<?php

	thesis_hook_before_headline($post_count);
	
	if ($post_image['show'] && $post_image['y'] == 'before-headline')
		echo $post_image['output'];
	
	if (is_404()) {
		echo '					<h1>';
		thesis_hook_404_title();
		echo '</h1>' . "\n";
	}
	elseif (is_page()) {
		if (is_front_page())
			echo '					<h2>' . get_the_title() . '</h2>' . "\n";
		else
			echo '					<h1>' . get_the_title() . '</h1>' . "\n";
			
		if ($post_image['show'] && $post_image['y'] == 'after-headline')
			echo $post_image['output'];
		
		thesis_hook_after_headline($post_count);
		thesis_byline();
	}
	else {
		if (is_single()) {
?>
					<h1 class="entry-title"><?php the_title(); ?></h1>
<?php
		}
		else {
?>
					<h2 class="entry-title"><a href="<?php the_permalink() ?>" rel="bookmark" title="Permanent link to <?php the_title(); ?>"><?php the_title(); ?></a></h2>
<?php
		}
		
		if ($post_image['show'] && $post_image['y'] == 'after-headline')
			echo $post_image['output'];

		thesis_hook_after_headline($post_count);
		thesis_byline($post_count);
		thesis_post_categories();
	}
?>
				</div>
<?php
}

function thesis_show_byline() {
	global $thesis;

	if (is_page()) {
		if ($thesis['display']['byline']['page']['author'] || $thesis['display']['byline']['page']['date'] || ($thesis['display']['byline']['num_comments']['show'] && comments_open() && !$thesis['display']['comments']['disable_pages']))
			return true;
	}
	else {
		if ($thesis['display']['byline']['author']['show'] || $thesis['display']['byline']['date']['show'] || ($thesis['display']['byline']['num_comments']['show'] && (comments_open() || get_comments_number() > 0)))
			return true;
	}
}

function thesis_byline($post_count = false) {
	global $thesis;

	if (thesis_show_byline()) {
		if (is_page()) {
			$author = $thesis['display']['byline']['page']['author'];
			$date = $thesis['display']['byline']['page']['date'];

			if (!$thesis['display']['comments']['disable_pages'] && comments_open() && $thesis['display']['byline']['num_comments']['show'])
				$show_comments = true;
		}
		else {
			$author = $thesis['display']['byline']['author']['show'];
			$date = $thesis['display']['byline']['date']['show'];

			if ($thesis['display']['byline']['num_comments']['show'] && (comments_open() || get_comments_number() > 0))
				$show_comments = true;
		}
	}
	elseif ($thesis['display']['admin']['edit_post'] && is_user_logged_in())
		$edit_link = true;
	elseif ($_GET['template'])
		$author = $date = true;

	if ($author || $date || $show_comments || $edit_link) {
?>
					<p class="headline_meta"><?php 
		if ($author)
			thesis_author();
		
		if ($author && $date)
			echo ' ' . __('on', 'thesis') . ' ';
		
		if ($date)
			echo '<abbr class="published" title="' . get_the_time('Y-m-d') . '">' . get_the_time(get_option('date_format')) . '</abbr>';
		
		if ($show_comments) {
			if ($author || $date)
				$sep = ' &middot; ';
				
			echo $sep . '<span><a href="' . get_permalink() . '#comments" rel="nofollow">';
			comments_number(__('0 comments', 'thesis'), __('1 comment', 'thesis'), __('% comments', 'thesis'));
			echo '</a></span>';
		}
		
		thesis_hook_byline_item($post_count);

		if (($author || $date || $show_comments) && $thesis['display']['admin']['edit_post'])
			edit_post_link(__('edit', 'thesis'), '<span class="edit_post pad_left">[', ']</span>');
		elseif ($thesis['display']['admin']['edit_post'])
			edit_post_link(__('edit', 'thesis'), '<span class="edit_post">[', ']</span>');
?></p>
<?php
	}
}

function thesis_author() {
	global $thesis;

	if ($thesis['display']['byline']['author']['link']) {
		if ($thesis['display']['byline']['author']['nofollow'])
			$nofollow = ' rel="nofollow"';

		$author = '<a href="' . get_author_posts_url(get_the_author_ID()) . '" class="url fn"' . $nofollow .'>' . get_the_author() . '</a>';
	}
	else {
		$author = get_the_author();
		$fn = ' fn';
	}

	echo __('by', 'thesis') . ' <span class="author vcard' . $fn . '">' . $author . '</span>';
}

function thesis_post_categories() {
	global $thesis;

	if ($thesis['display']['byline']['categories']['show']) {
?>
					<p class="headline_meta"><?php echo __('in', 'thesis') . ' <span>' . get_the_category_list(',') . '</span>'; ?></p>
<?php
	}
}

function thesis_post_tags() {
	global $thesis;

	if ((is_single() && $thesis['display']['tags']['single']) || (!is_single() && $thesis['display']['tags']['index'])) {
		$post_tags = get_the_tags();
		
		if ($post_tags) {
			$num_tags = count($post_tags);
			$tag_count = 1;
			
			if ($thesis['display']['tags']['nofollow'])
				$nofollow = ' nofollow';
?>
					<p class="post_tags"><?php echo __('Tagged as:', 'thesis') . "\n";

			foreach ($post_tags as $tag) {			
				$html_before = '						<a href="' . get_tag_link($tag->term_id) . '" rel="tag' . $nofollow . '">';
				$html_after = '</a>';
				
				if ($tag_count < $num_tags)
					$sep = ', ' . "\n";
				elseif ($tag_count == $num_tags)
					$sep = "\n";
				
				echo $html_before . $tag->name . $html_after . $sep;
				$tag_count++;
			}
?>
					</p>
<?php
		}
	}
}

function thesis_get_categories($flip = false) {
	$raw_categories = &get_categories('type=post');
	
	if ($raw_categories) {
		$categories = array();
		
		foreach ($raw_categories as $category)
			$categories[$category->slug] = $category->cat_ID;
		
		if ($flip)
			return array_flip($categories);
		else
			return $categories;
	}
}

function thesis_get_tags($flip = false) {
	$raw_tags = &get_tags('taxonomy=post_tag');

	if ($raw_tags) {
		$tags = array();
		
		foreach ($raw_tags as $tag)
			$tags[$tag->slug] = $tag->term_id;
		
		if ($flip)
			return array_flip($tags);
		else
			return $tags;
	}
}

function thesis_get_post_tags($post_id = false) {
	if ($post_id) {
		$tags_objects = wp_get_post_tags($post_id);
		
		if ($tags_objects) {
			foreach ($tags_objects as $tag_object)
				$tags[] = $tag_object->name;
			
			return $tags;
		}
	}
}

function thesis_default_archive_info() {
	echo '			<div id="archive_info">' . "\n";
	
	if (is_category()) {
?>
				<p><?php _e('From the category archives:', 'thesis'); ?></p>
				<h1><?php single_cat_title(); ?></h1>
<?php 
	}
	elseif (is_tag()) {
?>
				<p><?php _e('Posts tagged as:', 'thesis'); ?></p>
				<h1><?php single_tag_title(); ?></h1>
<?php
	}
	elseif (is_author()) {
?>
				<p><?php _e('Posts by author:', 'thesis'); ?></p>
				<h1><?php echo get_author_name(get_query_var('author')); ?></h1>
<?php
	}
	elseif (is_day()) {
?>
 				<p><?php _e('From the daily archives:', 'thesis'); ?></p>
				<h1><?php the_time('l, F j, Y'); ?></h1>
<?php
	}
	elseif (is_month()) { 
?>
				<p><?php _e('From the monthly archives:', 'thesis'); ?></p>
				<h1><?php the_time('F Y'); ?></h1>
<?php 
	}
	elseif (is_year()) {
?>
				<p><?php _e('From the yearly archives:', 'thesis'); ?></p>
				<h1><?php the_time('Y'); ?></h1>
<?php
	}
	elseif (is_search()) {
?>
				<p><?php _e('You searched for:', 'thesis'); ?></p>
				<h1><?php echo attribute_escape(get_search_query()); ?></h1>
<?php
	}
	
	echo '			</div>' . "\n";
}

function thesis_get_author_data($author_id, $field = false) {
	if ($author_id) {
		$author = get_userdata($author_id);

		if ($field && !empty($author->$field))
			return $author->$field;
		else
			return $author;
	}
}

function thesis_read_more_text() {
	global $thesis;

	$readmore = strip_tags(stripslashes(get_post_meta(get_the_ID(), 'thesis_readmore', true)));
	if ($readmore != '')
		return $readmore;
	elseif ($thesis['display']['posts']['read_more_text'])
		return urldecode($thesis['display']['posts']['read_more_text']);
	else
		return __('[click to continue&hellip;]', 'thesis');
}

function thesis_post_navigation() {
	if (is_home() || is_archive() || is_search()) {
		global $wp_query;
		$total_pages = $wp_query->max_num_pages;
		$current_page = get_query_var('paged');
	
		if ($total_pages > 1) {
			echo '			<div class="prev_next">' . "\n";
		
			if ($current_page <= 1) {
				echo '				<p class="previous">';	
				if (is_search())
					next_posts_link('&larr; ' . __('Previous Results', 'thesis'));
				else
					next_posts_link('&larr; ' . __('Previous Entries', 'thesis'));
				echo "</p>\n";
			}
			elseif ($current_page < $total_pages) {
				echo '				<p class="previous floated">';	
				if (is_search())
					next_posts_link('&larr; ' . __('Previous Results', 'thesis'));
				else
					next_posts_link('&larr; ' . __('Previous Entries', 'thesis'));
				echo "</p>\n";
			
				echo '				<p class="next">';
				if (is_search())
					previous_posts_link(__('Next Results', 'thesis') . ' &rarr;');
				else
					previous_posts_link(__('Next Entries', 'thesis') . ' &rarr;');
				echo "</p>\n";
			}
			elseif ($current_page >= $total_pages) {
				echo '				<p class="next">';
				if (is_search())
					previous_posts_link(__('Next Results', 'thesis') . ' &rarr;');
				else
					previous_posts_link(__('Next Entries', 'thesis') . ' &rarr;');
				echo "</p>\n";
			}
		
			echo "			</div>\n\n";
		}
	}
}

function thesis_prev_next_posts() {
	global $thesis;

	if (is_single() && $thesis['display']['posts']['nav']) {
		$previous = get_previous_post();
		$next = get_next_post();
		
		if ($previous || $next) {
			echo '					<div class="prev_next post_nav">' . "\n";
			
			if ($previous) {
				if ($previous && $next)
					$add_class = ' class="previous"';

				echo '						<p' . $add_class . '>' . __('Previous post:', 'thesis') . ' ';
				previous_post_link('%link', '%title');
				echo '</p>' . "\n";
			}
			
			if ($next) {
				echo '						<p>' . __('Next post:', 'thesis') . ' ';
				next_post_link('%link', '%title');
				echo '</p>' . "\n";
			}
			
			echo '					</div>' . "\n";
		}
	}
}

/**
 * Handle [caption] and [wp_caption] shortcodes.
 *
 * This function is mostly copy pasta from WP (wp-includes/media.php),
 * but with minor alteration to play more nicely with our styling.
 *
 * The supported attributes for the shortcode are 'id', 'align', 'width', and
 * 'caption'. These are unchanged from WP's default.
 *
 * @since 2.5
 *
 * @param array $attr Attributes attributed to the shortcode.
 * @param string $content Optional. Shortcode content.
 * @return string
 */
function thesis_img_caption_shortcode($attr, $content = null) {
	// Allow this to be overriden.
	$output = apply_filters('thesis_img_caption_shortcode', '', $attr, $content);

	if ($output != '')
		return $output;

	// Get necessary attributes or use the default.
	extract(shortcode_atts(array(
		'id'	=> '',
		'align'	=> 'alignnone',
		'width'	=> '',
		'caption' => ''
	), $attr));

	// Not enough information to form a caption, so just dump the image.
	if (1 > (int) $width || empty($caption))
		return $content;

	// For unique styling, create an ID.
	if ($id)
		$id = ' id="' . $id . '"';

	// Format our captioned image.
	$output = "<div$id class=\"wp-caption $align\" style=\"width: " . (int) $width . "px\">
	$content
	<p class=\"wp-caption-text\">$caption</p>\n</div>";

	// Return our result.
	return $output;
}