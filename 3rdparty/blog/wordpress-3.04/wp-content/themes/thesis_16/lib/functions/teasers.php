<?php

function thesis_is_teaser($post_count) {
	global $thesis;

	if (is_home() && $thesis['home']['features'] >= 0) {
		if ($post_count > $thesis['home']['features'])
			return true;
		else {
			$current_page = get_query_var('paged');
	
			if ($thesis['home']['features'] < get_option('posts_per_page') && $current_page > 1)
				return true;
			else
				return false;
		}
	}
	elseif (is_archive() || is_search()) {
	 	if ($thesis['display']['archives']['style'] == 'teasers')
			return true;
		elseif ($thesis['display']['archives']['style'] == 'content') {
			if ($post_count > $thesis['home']['features'])
				return true;
			else {
				$current_page = get_query_var('paged');
			
				if ($thesis['home']['features'] < get_option('posts_per_page') && $current_page > 1)
					return true;
				else
					return false;
			}
		}
		else
			return false;
	}
	else
		return false;
}

function thesis_teaser($classes, $post_count = false, $right = false) {
	$classes = 'teaser';
	$post_image = thesis_post_image_info('thumb');
	
	if ($right)
		$classes .= ' teaser_right';
	
	thesis_hook_before_teaser_box($post_count);
?>
			<div <?php post_class($classes); ?> id="post-<?php the_ID(); ?>">
<?php thesis_build_teaser($post_count, $post_image); ?>
			</div>

<?php
	thesis_hook_after_teaser_box($post_count);
	
	echo $close_box;
}

function thesis_build_teaser($post_count, $post_image) {
	global $thesis_design;
	
	if (is_array($thesis_design['teasers']['options'])) {
		foreach ($thesis_design['teasers']['options'] as $teaser_item => $teaser) {
			if ($teaser['show'])
				call_user_func('thesis_teaser_' . $teaser_item, $post_count, $post_image);
		}
	}
}

function thesis_teaser_headline($post_count, $post_image) {
	thesis_hook_before_teaser_headline($post_count);
	
	if ($post_image['show'] && $post_image['y'] == 'before-headline')
		echo $post_image['output'];
		
	echo '<h2 class="entry-title"><a href="' . get_permalink() . '" rel="bookmark" title="Permanent link to ' . get_the_title() . '">' . get_the_title() . '</a></h2>' . "\n";
	
	if ($post_image['show'] && $post_image['y'] == 'after-headline')
		echo $post_image['output'];
	
	thesis_hook_after_teaser_headline($post_count);
}

function thesis_teaser_author($post_count, $post_image) {
	echo '<span class="teaser_author">';
	thesis_author();
	echo "</span>\n";
}

function thesis_teaser_date($post_count, $post_image) {
	global $thesis_design;
	$date_formats = thesis_get_date_formats();
	$use_format = ($thesis_design['teasers']['date']['format'] == 'custom') ? $thesis_design['teasers']['date']['custom'] : $date_formats[$thesis_design['teasers']['date']['format']];

	echo '<abbr class="teaser_date published" title="' . get_the_time('Y-m-d') . '">' . get_the_time($use_format) . '</abbr>' . "\n";
}

function thesis_teaser_category($post_count, $post_image) {
	$categories = get_the_category();
	echo '<a class="teaser_category" href="' . get_category_link($categories[0]->cat_ID) . '">' . $categories[0]->cat_name . '</a>' . "\n";
}

function thesis_teaser_excerpt($post_count, $post_image) {
	echo '				<div class="format_teaser entry-content">' . "\n";

	thesis_hook_before_teaser($post_count);
	
	if ($post_image['show'] && $post_image['y'] == 'before-post')
		echo $post_image['output'];
	
	the_excerpt();
	thesis_hook_after_teaser($post_count);

	echo '				</div>' . "\n";
}

function thesis_teaser_tags($post_count, $post_image) {
	thesis_post_tags();
}

function thesis_teaser_comments($post_count, $post_image) {
	if (comments_open() || get_comments_number() > 0) {
		echo '<a class="teaser_comments" href="' . get_permalink() . '#comments" rel="nofollow">';
		echo comments_number(__('<span>0</span> comments', 'thesis'), __('<span>1</span> comment', 'thesis'), __('<span>%</span> comments', 'thesis'));
		echo '</a>' . "\n";
	}
}

function thesis_teaser_link($post_count, $post_image) {
	echo '<a class="teaser_link" href="' . get_permalink() . '" rel="nofollow">' . thesis_teaser_link_text() . '</a>' . "\n";
}

function thesis_teaser_link_text() {
	global $thesis_design;
	$link_text = ($thesis_design['teasers']['link_text']) ? urldecode($thesis_design['teasers']['link_text']) : __('Read the full article &rarr;', 'thesis');
	return $link_text;
}

function thesis_teaser_edit() {
	edit_post_link(__('edit', 'thesis'), '<span class="edit_post">[', ']</span>');
	echo "\n";
}