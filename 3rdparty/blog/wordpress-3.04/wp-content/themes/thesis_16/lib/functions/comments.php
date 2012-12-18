<?php

/**
 * function thesis_comments_link()
 *
 * Generates and outputs a direct link to a page's or post's comments from index
 * or archive views.
 *
 * @since 1.0.2
 */
function thesis_comments_link() {
	if (!is_single() && !is_page()) {
		$num_comments = get_comments_number();
		$text = (comments_open()) ? '<a href="' . get_permalink() . '#comments" rel="nofollow">' . thesis_num_comments($num_comments, true) . '</a>' : __('Comments on this entry are closed', 'thesis');
		$text = '<p class="to_comments"><span class="bracket">{</span> ' . $text . ' <span class="bracket">}</span></p>' . "\n";
		echo apply_filters('thesis_comments_link', $text);
	}
}

/**
 * function thesis_num_comments()
 *
 * Generated semantic "# comments" statement
 *
 * @since 1.5
 */
function thesis_num_comments($num_comments, $span = false) {
	$number = ($span) ? '<span>' . $num_comments . '</span> ' : $num_comments . ' ';
	$text = ($num_comments == 1) ?  __('comment', 'thesis') : __('comments', 'thesis');
	return $number . $text;
}

/**
 * function thesis_comments_intro()
 *
 * Generates and echos the div#comments_intro class, which includes the number
 * of comments present as well as a link to them.
 *
 * @since 1.0.2
 */
function thesis_comments_intro($number, $comments_open, $type = 'comments') {
	if ($type == 'comments') {
		$type_singular = __('comment', 'thesis');
		$type_plural = __('comments', 'thesis');
	}
	elseif ($type == 'trackbacks') {
		$type_singular = __('trackback', 'thesis');
		$type_plural = __('trackbacks', 'thesis');
	}

	if ($number == 0)
		$comments_text = '<span>0</span> ' . $type_plural;
	elseif ($number == 1)
		$comments_text = '<span>1</span> ' . $type_singular;
	elseif ($number > 1)
		$comments_text = str_replace('%', $number, '<span>%</span> ') . $type_plural;

	if ($comments_open && $type == 'comments') {
		if ($number == 0)
			$add_link = '&#8230; <a href="#respond" rel="nofollow">' . __('add one now', 'thesis') . '</a>';
		elseif ($number == 1)
			$add_link = '&#8230; ' . __('read it below or ', 'thesis') . '<a href="#respond" rel="nofollow">' . __('add one', 'thesis') . '</a>';
		elseif ($number > 1)
			$add_link = '&#8230; ' . __('read them below or ', 'thesis') . '<a href="#respond" rel="nofollow">' . __('add one', 'thesis') . '</a>';
	}
	else
		$add_link = '';	

	$output = '				<div class="comments_intro">' . "\n";	
	$output .= '					<p><span class="bracket">{</span> ' . $comments_text . $add_link . ' <span class="bracket">}</span></p>' . "\n";
	$output .= '				</div>' . "\n\n";

	echo apply_filters('thesis_comments_intro', $output);
}

/**
 * function thesis_commenet_meta()
 *
 * Display comment meta information, including author, author link, and time posted.
 *
 * @since 1.2
 * @uses thesis_avatar()
 */
function thesis_comment_meta($comment_number) {
	global $thesis;
	$comment_link_before = '<a href="#comment-' . get_comment_id() . '" title="Permalink to this comment" rel="nofollow">';
	$comment_link_after = '</a>';
	
	if ($thesis['display']['comments']['numbers']) {
		$comment_num = '						<span class="comment_num">' . $comment_link_before . $comment_number . $comment_link_after . '</span>' . "\n";
		$comment_time = '<span class="comment_time">' . sprintf(__('%1$s at %2$s'), get_comment_date(), get_comment_time()) . '</span>';
	}
	else
		$comment_time = '<span class="comment_time">' . $comment_link_before . sprintf(__('%1$s at %2$s'), get_comment_date(), get_comment_time()) . $comment_link_after . '</span>';

	thesis_avatar($thesis['display']);
	echo $comment_num;
	echo '						<span class="comment_author">' . get_comment_author_link() . '</span> ' . $comment_time;
	
	if ($thesis['display']['admin']['edit_comment'])
		edit_comment_link(__('edit', 'thesis'), ' <span class="edit_comment">[', ']</span>');
		
	echo "\n";
}

/**
 * function thesis_avatar()
 *
 * If avatars are enabled in WordPress, process and echo them accordingly
 *
 * @param array $display
 */
function thesis_avatar($display) {
	if (get_option('show_avatars')) {
		$before = '						<span class="avatar">';
		$after = '</span>' . "\n";
		$avatar = get_avatar(get_comment_author_email(), $display['comments']['avatar_size'], '');
		$author_url = get_comment_author_url();
		
		$output = $before;
		
		if (empty($author_url) || $author_url == 'http://')
			$output = $output . $avatar;
		else
			$output = $output . '<a href="' . $author_url . '" rel="nofollow">' . $avatar . '</a>';

		$output = $output . $after;

		echo apply_filters('thesis_avatar', $output);
	}
}

/**
 * function thesis_comments_navigation()
 *
 * Display comment navigation links
 *
 * @since 1.5
 */
function thesis_comments_navigation($position = 1) {
	// Output navigation only if comment pagination is enabled.
	if (get_option('page_comments')) {
		$total_pages = get_comment_pages_count();
		$default_page = (get_option('default_comments_page') == 'oldest') ? 1 : $total_pages;
		$current_page = (isset($_GET['cpage'])) ? get_query_var('cpage') : $default_page;

		if ($total_pages > 1) {
			$nav = '				<div id="comment_nav_' . $position . '" class="prev_next">' . "\n";
	
			if ($current_page == $total_pages) {
				$nav .= '					<p class="previous">';	
				$nav .= get_previous_comments_link('&larr; ' . __('Previous Comments', 'thesis'));
				$nav .= "</p>\n";
			}
			elseif ($current_page == 1) {
				$nav .= '					<p class="next">';
				$nav .= get_next_comments_link(__('Next Comments', 'thesis') . ' &rarr;');
				$nav .= "</p>\n";
			}
			elseif ($current_page < $total_pages) {
				$nav .= '					<p class="previous floated">';	
				$nav .= get_previous_comments_link('&larr; ' . __('Previous Comments', 'thesis'));
				$nav .= "</p>\n";
			
				$nav .= '					<p class="next">';
				$nav .= get_next_comments_link(__('Next Comments', 'thesis') . ' &rarr;');
				$nav .= "</p>\n";
			}
	
			$nav .= "				</div>\n\n";

			echo apply_filters('thesis_comments_navigation', $nav, $position);
		}
	}
}

/**
 * class Thesis_Comment
 *
 * Comment handling.
 *
 * @since 1.5
 */
class Thesis_Comment extends Walker {
	/**
	 * Set type of "tree" for Walker.
	 *
	 * @since 1.5
	 * @var string
	 */
	var $tree_type = 'comment';

	/**
	 * Set needed database fields for Walker.
	 *
	 * @since 1.5
	 * @var array
	 */
	var $db_fields = array('parent' => 'comment_parent', 'id' => 'comment_ID');

	/**
	 * function start_lvl()
	 *
	 * Output beginning of child comments list.
	 *
	 * @param string $output Passed by reference. Used to append additional content.
	 * @param int $depth Depth of comment.
	 * @param array $args
	 * @since 1.5
	 */
	function start_lvl(&$output, $depth, $args) {
		$GLOBALS['comment_depth'] = $depth + 1;

		echo "					<dl class=\"children\">\n";
	}

	/**
	 * function end_lvl()
	 *
	 * Output ending of child comments list.
	 *
	 * @param string $output Passed by reference. Used to append additional content.
	 * @param int $depth Depth of comment.
	 * @param array $args
	 * @since 1.5
	 */
	function end_lvl(&$output, $depth, $args) {
		$GLOBALS['comment_depth'] = $depth + 1;

		echo "					</dl>\n";
	}

	/**
	 * function start_el()
	 *
	 * Output opening and body of comments.
	 *
	 * @param string $output Passed by reference. Used to append additional content.
	 * @param object $comment Comment data object.
	 * @param int $depth Depth of comment in reference to parents.
	 * @param array $args
	 * @since 1.5
	 */
	function start_el(&$output, $comment, $depth, $args) {
		$depth++;
		$GLOBALS['comment_depth'] = $depth;
		$GLOBALS['comment'] = $comment;

		extract($args, EXTR_SKIP);

		$classes = comment_class(empty($args['has_children']) ? '' : 'parent', $comment, '', false);
?>
					<dt <?php echo $classes; ?> id="comment-<?php comment_ID(); ?>">
<?php
thesis_hook_before_comment_meta();
thesis_comment_meta(did_action('thesis_hook_before_comment_meta'));
thesis_hook_after_comment_meta();
?>
					</dt>
					<dd <?php echo $classes; ?>>
						<div class="format_text" id="comment-body-<?php comment_ID(); ?>">
<?php 
		if ($comment->comment_approved == '0') {
?>
							<p class="comment_moderated"><?php _e('Your comment is awaiting moderation.', 'thesis'); ?></p>
<?php 
		}
		comment_text();
		thesis_hook_after_comment();

		if (get_option('thread_comments')) {
?>
							<p class="reply"><?php comment_reply_link(array_merge($args, array('add_below' => 'comment-body', 'depth' => $depth, 'max_depth' => $args['max_depth']))); ?></p>
<?php
		}
?>
						</div>
<?php
					// </dd> excluded as it is added by end_el().
	}

	/**
	 * function end_el()
	 *
	 * Output closing tag for comments
	 *
	 * @param string $output Passed by reference. Used to append additional content.
	 * @param object $comment
	 * @param int $depth Depth of comment.
	 * @param array $args
	 * @since 1.5
	 */
	function end_el(&$output, $comment, $depth, $args) {
		echo "					</dd>\n";
	}

}

/**
 * function thesis_list_comments()
 *
 * List comments — Warning: Here be dragons.
 *
 * @param string|array $args Formatting options
 * @param array $comments Optional array of comment objects.  Defaults to $wp_query->comments
 * @since 1.5
 * @usedby ../../comments.php
 * @uses Thesis_Comment
 */
function thesis_list_comments() {
	global $wp_query, $comment_alt, $comment_depth, $comment_thread_alt, $overridden_cpage, $in_comment_loop;
	$in_comment_loop = true;
	$comment_alt = $comment_thread_alt = 0;
	$comment_depth = 1;
	$r = array('walker' => null, 'max_depth' => '', 'type' => 'comment', 'page' => '', 'per_page' => '', 'reverse_top_level' => null, 'reverse_children' => '');

	// Get our comments.
	$wp_query->comments_by_type = &separate_comments($wp_query->comments);
	$_comments = $wp_query->comments_by_type['comment'];

	// Are we paginating?
	if (get_option('page_comments'))
		$r['per_page'] = get_query_var('comments_per_page');
	if (empty($r['per_page'])) {
		$r['per_page'] = 0;
		$r['page'] = 0;
	}

	// How deep does our comments hole go?
	if (get_option('thread_comments'))
		$r['max_depth'] = get_option('thread_comments_depth');
	else
		$r['max_depth'] = -1;

	// Determine page number of comments.
	if (empty($overridden_cpage)) {
		$r['page'] = get_query_var('cpage');
	} else {
		$threaded = (-1 == $r['max_depth']) ? false : true;
		$r['page'] = ('newest' == get_option('default_comments_page')) ? get_comment_pages_count($_comments, $r['per_page'], $threaded) : 1;
		set_query_var('cpage', $r['page']);
	}

	// Validate our page number.
	$r['page'] = intval($r['page']);
	if (0 == $r['page'] && 0 != $r['per_page'])
		$r['page'] = 1;

	// Which order should comments be displayed in?
	$r['reverse_top_level'] = ('desc' == get_option('comment_order')) ? TRUE : FALSE;

	// Convert array into handy variables.
	extract($r, EXTR_SKIP);

	// Insantiate comments class.
	if (empty($walker))
		$walker = new Thesis_Comment;

	$walker->paged_walk($_comments, $max_depth, $page, $per_page, $r);
	$wp_query->max_num_comment_pages = $walker->max_pages;

	$in_comment_loop = false;
}