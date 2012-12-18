<?php

// Using hooks is absolutely the smartest, most bulletproof way to implement things like plugins,
// custom design elements, and ads. You can add your hook calls below, and they should take the 
// following form:
// add_action('thesis_hook_name', 'function_name');
// The function you name above will run at the location of the specified hook. The example
// hook below demonstrates how you can insert Thesis' default recent posts widget above
// the content in Sidebar 1:
// add_action('thesis_hook_before_sidebar_1', 'thesis_widget_recent_posts');

// Delete this line, including the dashes to the left, and add your hooks in its place.

/**
 * function custom_bookmark_links() - outputs an HTML list of bookmarking links
 * NOTE: This only works when called from inside the WordPress loop!
 * SECOND NOTE: This is really just a sample function to show you how to use custom functions!
 *
 * @since 1.0
 * @global object $post
*/


// *************************************************
//
//  HEADER
//
// *************************************************


// *************************************************
//
//  POST BY-LINE
//
// *************************************************

/* byline avatars */
function byline_avatars() {
  echo get_avatar(get_the_author_id(), 50);
}

add_action('thesis_hook_before_headline', 'byline_avatars');



// *************************************************
//
//  FEATURE BOX
//
//  Make this above the content box a column width google map.
//
// *************************************************


// *************************************************
//
//  MULTIMEDIA BOX
//
// *************************************************


// *************************************************
//
//  FOOTER
//
// *************************************************

function my_footer() {
    echo 'Copyright @ 2010 The WormBase Consortium';
}

add_action('thesis_hook_footer','my_footer');
remove_action('thesis_hook_footer','thesis_attribution');




// *************************************************
//
//  COMMENTS
//
// *************************************************
function friend_feed_comments() {
	 wp_ffcomments();
}
add_action('thesis_hook__comment_field','friend_feed_comments');