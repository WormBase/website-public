<?php

function thesis_loop_posts() {
	if (is_404())
		thesis_404_loop();
	elseif (have_posts()) {
		if (is_single())
			thesis_single_loop();
		elseif (is_page())
			thesis_page_loop();
		elseif (is_archive() || is_search())
			thesis_archive_loop();
		elseif (is_home())
			thesis_home_loop();
		else
			thesis_default_loop();
	}
	else
		thesis_no_posts();
}

function thesis_default_loop() {
	$post_count = 1;

	while (have_posts()) {
		the_post();
		$classes = 'post_box';
		
		if ($post_count == 1)
			$classes .= ' top';

		thesis_post_box($classes, $post_count);
		$post_count++;
	}
}

function thesis_home_loop() {
	$post_count = 1;
	$teaser_count = 1;

	while (have_posts()) {
		the_post();

		if (thesis_is_teaser($post_count)) {
			if (($teaser_count % 2) == 1) {
				$top = ($post_count == 1) ? ' top' : '';
				$open_box = '			<div class="teasers_box' . $top . '">' . "\n\n";
				$close_box = '';
				$right = false;
			}
			else {
				$open_box = '';
				$close_box = '			</div>' . "\n\n";
				$right = true;
			}

			if ($open_box != '') {
				echo $open_box;
				thesis_hook_before_teasers_box($post_count);
			}

			thesis_teaser($classes, $post_count, $right);

			if ($close_box != '') {
				echo $close_box;
				thesis_hook_after_teasers_box($post_count);
			}

			$teaser_count++;
		}
		else {
			$classes = 'post_box';

			if ($post_count == 1)
				$classes .= ' top';

			thesis_post_box($classes, $post_count);
		}

		$post_count++;
	}
	
	if ((($teaser_count - 1) % 2) == 1)
		echo '			</div>' . "\n\n";
}

function thesis_single_loop() {
	while (have_posts()) {
		the_post();
		$classes = 'post_box top';
		thesis_post_box($classes);
		comments_template();
	}
}

function thesis_post_box($classes = '', $post_count = false) {
	$post_image = thesis_post_image_info('image');

	thesis_hook_before_post_box($post_count);
?>
			<div <?php post_class($classes); ?> id="post-<?php the_ID(); ?>">
				<?php thesis_headline_area($post_count, $post_image); ?>
				<div class="format_text entry-content">
<?php thesis_post_content($post_count, $post_image); ?>
				</div>
			</div>

<?php
	thesis_hook_after_post_box($post_count);
}

function thesis_post_content($post_count = false, $post_image = false) {
	global $thesis;

	thesis_hook_before_post($post_count);

	if ($post_image['show'] && $post_image['y'] == 'before-post')
		echo $post_image['output'];

	if (((is_home() || is_archive() || is_search()) && $thesis['display']['posts']['excerpts']) || ((is_archive() || is_search()) && $thesis['display']['archives']['style'] == 'excerpts'))
		the_excerpt();
	else
		the_content(thesis_read_more_text());

	if (is_single() || is_page())
		link_pages('<p><strong>Pages:</strong> ', '</p>', 'number');

	thesis_hook_after_post($post_count);
}

function thesis_page_loop() {
	global $post, $thesis;

	while (have_posts()) {
		the_post();
		$post_image = thesis_post_image_info('image');

		thesis_hook_before_post_box();
	
?>
			<div class="post_box top" id="post-<?php the_ID(); ?>">
				<?php thesis_headline_area(false, $post_image); ?>
				<div class="format_text">
<?php
	
		if (get_post_meta($post->ID, '_wp_page_template', true) == 'archives.php')
			thesis_hook_archives_template();
		else
			thesis_post_content(false, $post_image);
?>
				</div>
			</div>

<?php
		thesis_hook_after_post_box();

		if (!$thesis['display']['comments']['disable_pages'])
			comments_template();
	}
}

function thesis_archive_loop() {
	global $thesis;

	thesis_hook_archive_info();

	if ($thesis['display']['archives']['style'] == 'titles') {
		$post_count = 1;

		while (have_posts()) {
			the_post();
			$classes = 'post_box';
			$post_image = thesis_post_image_info('image');
		
			if ($post_count == 1)
				$classes .= ' top';
				
			thesis_hook_before_post_box($post_count);
?>
			<div <?php post_class($classes); ?> id="post-<?php the_ID(); ?>">
				<?php thesis_headline_area($post_count, $post_image); ?>
			</div>

<?php
			thesis_hook_after_post_box($post_count);

			$post_count++;
		}
	}
	else
		thesis_home_loop();
}

function thesis_404_loop() {
?>
			<div class="post_box top">
				<?php thesis_headline_area(); ?>
				<div class="format_text">
<?php thesis_hook_404_content(); ?>
				</div>
			</div>

<?php
}

function thesis_no_posts() {
	if (is_search()) {
?>
			<div class="post_box top">
				<div class="headline_area">
					<h2><?php _e('Sorry, but no results were found', 'thesis'); ?></h2>
				</div>
				<div class="format_text">
					<p><?php _e('Don&#8217;t give up&#8212;try another search!', 'thesis'); ?></p>
				</div>
			</div>

<?php
	}
	else {
?>
			<div class="post_box top">
				<div class="headline_area">
					<h2><?php _e('There&#8217;s nothing here.', 'thesis'); ?></h2>
				</div>
				<div class="format_text">
					<p><?php printf(__('If there were posts in the database, you&#8217;d be seeing them. Try <a href="%s/wp-admin/post-new.php">creating a post</a>, and see if that solves your problem.', 'thesis'), get_bloginfo('url')); ?></p>
				</div>
			</div>

<?php
	}
}