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
	if (!is_single() && !is_page()) { #wp
		$num_comments = get_comments_number(); #wp
		$link = (comments_open()) ? '<a href="' . get_permalink() . '#comments" rel="nofollow">' . thesis_num_comments($num_comments, true) . '</a>' : apply_filters('thesis_comments_link_closed', __('Comments on this entry are closed', 'thesis')); #wp #filter
		echo "<p class=\"to_comments\">" . apply_filters('thesis_comments_link', $link) . "</p>\n"; #filter
	}
}

function default_skin_comments_link($link) {
	return "<span class=\"bracket\">{</span> $link <span class=\"bracket\">}</span>";
}

function default_skin_edit_comment_link($link) {
	return "[$link]";
}

/**
 * function thesis_num_comments()
 *
 * Generated semantic "# comments" statement
 *
 * @since 1.5
 */
function thesis_num_comments($num_comments, $span = false) {
	$number = ($span) ? "<span>$num_comments</span>" : $num_comments;
	$text = ($num_comments == 1) ?  __('comment', 'thesis') : __('comments', 'thesis');
	return "$number $text";
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
		$id = 'comments_intro';
		$type_singular = __('comment', 'thesis');
		$type_plural = __('comments', 'thesis');
	}
	elseif ($type == 'trackbacks') {
		$id = 'trackbacks_intro';
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

	$output = "\t\t\t\t<div id=\"$id\" class=\"comments_intro\">\n";	
	$output .= "\t\t\t\t\t<p><span class=\"bracket\">{</span> $comments_text$add_link <span class=\"bracket\">}</span></p>\n";
	$output .= "\t\t\t\t</div>\n\n";

	echo apply_filters('thesis_comments_intro', $output); #filter
}

function thesis_trackback_link($comment) {
	$output = '<a href="' . $comment->comment_author_url . '" rel="nofollow">' . $comment->comment_author . '</a>';
	return apply_filters('thesis_trackback_link', $output, $comment); #filter
}

function thesis_trackback_date($comment) {
	global $thesis_design;
	if ($thesis_design->comments['trackbacks']['options']['date']) {
		$output = apply_filters('thesis_trackback_date', date($thesis_design->comments['trackbacks']['options']['date_format'], strtotime($comment->comment_date)), $comment); #filter
		return " <span>$output</span>";
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
			$nav = "\t\t\t\t<div id=\"comment_nav_$position\" class=\"prev_next\">\n";

			if ($current_page == $total_pages) {
				$nav .= "\t\t\t\t\t<p class=\"previous\">";
				$nav .= get_previous_comments_link('&larr; ' . __('Previous Comments', 'thesis'));
				$nav .= "</p>\n";
			}
			elseif ($current_page == 1) {
				$nav .= "\t\t\t\t\t<p class=\"next\">";
				$nav .= get_next_comments_link(__('Next Comments', 'thesis') . ' &rarr;');
				$nav .= "</p>\n";
			}
			elseif ($current_page < $total_pages) {
				$nav .= "\t\t\t\t\t<p class=\"previous floated\">";	
				$nav .= get_previous_comments_link('&larr; ' . __('Previous Comments', 'thesis'));
				$nav .= "</p>\n";
			
				$nav .= "\t\t\t\t\t<p class=\"next\">";
				$nav .= get_next_comments_link(__('Next Comments', 'thesis') . ' &rarr;');
				$nav .= "</p>\n";
			}

			$nav .= "\t\t\t\t</div>\n\n";

			echo apply_filters('thesis_comments_navigation', $nav, $position); #filter
		}
	}
}