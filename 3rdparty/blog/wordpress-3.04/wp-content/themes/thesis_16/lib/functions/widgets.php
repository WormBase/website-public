<?php

function thesis_register_sidebars() {
	register_sidebars(2,
		array(
			'name' => 'Sidebar %d',
			'before_widget' => '<li class="widget %2$s" id="%1$s">',
			'after_widget' => '</li>',
			'before_title' => '<h3>',
			'after_title' => '</h3>'
		)
	);
}

function thesis_register_widgets() {
	register_sidebar_widget(__('Search', 'thesis'), 'thesis_widget_search');
	register_widget_control(__('Search', 'thesis'), 'thesis_widget_search_control');
	register_sidebar_widget(__('Subscriptions', 'thesis'), 'thesis_widget_subscriptions');
	register_widget_control(__('Subscriptions', 'thesis'), 'thesis_widget_subscriptions_control');
	register_sidebar_widget(__('Google Custom Search', 'thesis'), 'thesis_widget_google_cse');
	register_widget_control(__('Google Custom Search', 'thesis'), 'thesis_widget_google_cse_control');
	add_action('widgets_init', 'thesis_register_multiple_widgets');
}

function thesis_register_multiple_widgets() {
	thesis_widget_recent_entries_register();
}

function thesis_search_form() {
	$field_value = apply_filters('thesis_search_form_value', __('To search, type and hit enter', 'thesis'));
?>
<form method="get" class="search_form" action="<?php bloginfo('home'); ?>/">
	<p>
		<input class="text_input" type="text" value="<?php echo $field_value; ?>" name="s" id="s" onfocus="if (this.value == '<?php echo $field_value; ?>') {this.value = '';}" onblur="if (this.value == '') {this.value = '<?php echo $field_value; ?>';}" />
		<input type="hidden" id="searchsubmit" value="Search" />
	</p>
</form>
<?php	
}

function thesis_widget_search($args) {
	extract($args, EXTR_SKIP);
	$options = get_option('thesis_widget_search');

	echo $before_widget . "\n";
	
	if ($options['thesis-search-title'])
		echo $before_title . $options['thesis-search-title'] . $after_title . "\n";
	
	thesis_search_form();
	echo $after_widget . "\n";
}

function thesis_widget_search_control() {
	$options = $newoptions = get_option('thesis_widget_search');

	if ($_POST['thesis-search-options-submit'])
		$newoptions['thesis-search-title'] = strip_tags(stripslashes($_POST['thesis-search-title']));

	if ($options != $newoptions) {
		$options = $newoptions;
		update_option('thesis_widget_search', $options);
	}
	
	$title = attribute_escape($options['thesis-search-title']);
?>
		<p>
			<label for="thesis-pages-title"><?php _e('Title:', 'thesis'); ?>
			<input type="text" class="widefat" id="thesis-search-title" name="thesis-search-title" value="<?php echo $title; ?>" /></label>
			<input type="hidden" id="thesis-search-options-submit" name="thesis-search-options-submit" value="1" />
		</p>
<?php
}

function thesis_widget_subscriptions($args) {
	extract($args);
	$options = get_option('thesis_widget_subscriptions');

	if ($options['thesis-subscriptions-rss-text'] != '' || $options['thesis-subscriptions-email'] != '') {
		$list = '<ul>' . "\n";

		if ($options['thesis-subscriptions-rss-text'] != '')
			$list .= '	<li class="sub_rss"><a href="' . thesis_feed_url() . '">' . $options['thesis-subscriptions-rss-text'] . '</a></li>' . "\n";

		if ($options['thesis-subscriptions-email'] != '')
			$list .= '	<li class="sub_email">' . $options['thesis-subscriptions-email'] . '</li>' . "\n";
	
		$list .= '</ul>' . "\n";
	}
	
	echo $before_widget . "\n";
	echo $before_title . $options['thesis-subscriptions-title'] . $after_title . "\n";
	
	if ($options['thesis-subscriptions-description'])
		echo '<p>' . $options['thesis-subscriptions-description'] . '</p>' . "\n";
		
	echo $list;
	echo $after_widget . "\n";
}

function thesis_widget_subscriptions_control() {
	$options = $newoptions = get_option('thesis_widget_subscriptions');
	
	if ($_POST['thesis-subscriptions-submit']) {
		$newoptions['thesis-subscriptions-title'] = strip_tags(stripslashes($_POST['thesis-subscriptions-title']));
		$newoptions['thesis-subscriptions-description'] = stripslashes($_POST['thesis-subscriptions-description']);
		$newoptions['thesis-subscriptions-rss-text'] = stripslashes($_POST['thesis-subscriptions-rss-text']);
		$newoptions['thesis-subscriptions-email'] = stripslashes($_POST['thesis-subscriptions-email']);
	}
	
	if ($options != $newoptions) {
		$options = $newoptions;
		update_option('thesis_widget_subscriptions', $options);
	}
	
	$title = attribute_escape($options['thesis-subscriptions-title']);
	$description = attribute_escape($options['thesis-subscriptions-description']);
	$rss_text = attribute_escape($options['thesis-subscriptions-rss-text']);
	$email = attribute_escape($options['thesis-subscriptions-email']);
?>
		<p>
			<label for="thesis-subscriptions-title"><?php _e('Title:', 'thesis'); ?>
			<input type="text" class="widefat" id="thesis-subscriptions-title" name="thesis-subscriptions-title" value="<?php echo $title; ?>" /></label>
		</p>
		<p>
			<label for="thesis-subscriptions-description"><?php _e('Describe your subscription options:', 'thesis'); ?></label>
			<textarea class="widefat" rows="8" cols="10" id="thesis-subscriptions-description" name="thesis-subscriptions-description"><?php echo $description; ?></textarea>
		</p>
		<p>
			<label for="thesis-subscriptions-rss-text"><?php _e('<acronym title="Really Simple Syndication">RSS</acronym> link text:', 'thesis'); ?>
			<input type="text" class="widefat" id="thesis-subscriptions-rss-text" name="thesis-subscriptions-rss-text" value="<?php echo $rss_text; ?>" /></label>
		</p>
		<p>
			<label for="thesis-subscriptions-email"><?php _e('Email link and text:', 'thesis'); ?></label>
			<textarea class="widefat" rows="8" cols="10" id="thesis-subscriptions-email" name="thesis-subscriptions-email"><?php echo $email; ?></textarea>
			<input type="hidden" id="thesis-subscriptions-submit" name="thesis-subscriptions-submit" value="1" />
		</p>
<?php
}

function thesis_widget_google_cse($args) {
	extract($args, EXTR_SKIP);
	$options = get_option('thesis_widget_google_cse');
	
	echo $before_widget . "\n";
	
	if ($options['thesis-google-cse-title'])
		echo $before_title . $options['thesis-google-cse-title'] . $after_title . "\n";
	
	echo stripslashes($options['thesis-google-cse-code']) . "\n";
	echo $after_widget . "\n";
}

function thesis_widget_google_cse_control() {
	$options = $newoptions = get_option('thesis_widget_google_cse');
	
	if ($_POST['thesis-google-cse-submit']) {
		$newoptions['thesis-google-cse-title'] = strip_tags(stripslashes($_POST['thesis-google-cse-title']));
		$newoptions['thesis-google-cse-code'] = $_POST['thesis-google-cse-code'];
	}

	if ($options != $newoptions) {
		$options = $newoptions;
		update_option('thesis_widget_google_cse', $options);
	}
	
	$title = attribute_escape($options['thesis-google-cse-title']);
	$code = stripslashes($options['thesis-google-cse-code']);
?>
		<p>
			<label for="thesis-google-cse-title"><?php _e('Title:', 'thesis'); ?>
			<input type="text" class="widefat" id="thesis-google-cse-title" name="thesis-google-cse-title" value="<?php echo $title; ?>" /></label>
		</p>
		<p>
			<label for="thesis-google-cse-code"><?php _e('Google Custom Search code:', 'thesis'); ?></label>
			<textarea class="widefat" rows="8" cols="10" id="thesis-google-cse-code" name="thesis-google-cse-code"><?php echo $code; ?></textarea>
			<input type="hidden" id="thesis-google-cse-submit" name="thesis-google-cse-submit" value="1" />
		</p>
<?php
}

function thesis_widget_recent_entries($args, $widget_args = 1) {
	extract($args, EXTR_SKIP);
	
	if (is_numeric($widget_args))
		$widget_args = array('number' => $widget_args);
	
	$widget_args = wp_parse_args($widget_args, array('number' => -1));
	extract($widget_args, EXTR_SKIP);
	
	$options = get_option('widget_killer_recent_entries');
	
	if (!isset($options[$number]))
		return;

	if ($options[$number]['category'] != 'all') {
		$category = 'category_name=' . $options[$number]['category'];

		if ($options[$number]['title'] == '') {
			$categories = &get_categories('type=post&orderby=name&hide_empty=0');

			if ($categories) {
				foreach ($categories as $current_category) {
					if ($current_category->slug == $options[$number]['category'])
						$title = $current_category->cat_name;
				}
			}
		}
		else
			$title = $options[$number]['title'];
	}
	elseif ($options[$number]['title'] != '') {
		$category = '';
		$title = $options[$number]['title'];
	}
	else {
		$category = '';
		$title = 'Recent Posts';
	}

	$numposts = $options[$number]['numposts'];
	$comments = $options[$number]['comments'];

	if (is_home() && $category == '' && $options[$number]['title'] == '') {
		global $posts;
		$title = 'More ' . $title;
		$offset = count($posts);
	}
	else
		$offset = 0;
	
	// HTML output
	$custom_query = query_posts("$category&showposts=$numposts&offset=$offset");
	
	echo $before_widget . "\n";
	echo $before_title . $title . $after_title . "\n";
	
	echo '<ul>' . "\n";
	
	if (is_array($custom_query)) {
		foreach ($custom_query as $queried_post) {
			$this_post = thesis_get_post_data_from_object($queried_post);

			if ($comments) {
				if (!comments_open($this_post['id']))
					$show_comments = (get_comments_number($this_post['id']) > 0) ? ' <a href="' . get_permalink($this_post['id']) . '#comments"><span class="num_comments" title="' . thesis_num_comments(get_comments_number($this_post['id'])) . ' ' . __('on this post', 'thesis') . '">' . get_comments_number($this_post['id']) . '</span></a>' : '';
				else
					$show_comments = ' <a href="' . get_permalink($this_post['id']) . '#comments"><span class="num_comments" title="' . thesis_num_comments(get_comments_number($this_post['id'])) . ' ' . __('on this post', 'thesis') . '">' . get_comments_number($this_post['id']) . '</span></a>';
			}
			else
				$show_comments = '';
	
			echo '	<li><a href="' . get_permalink($this_post['id']) . '" title="' . __('Click to read', 'thesis') . ' ' . get_the_title($this_post['id']) . '" rel="bookmark">' . get_the_title($this_post['id']) . '</a>' . $show_comments . '</li>' . "\n";
		}
	}
	
	echo '</ul>' . "\n";

	echo $after_widget . "\n";

	unset($custom_query);
	wp_reset_query();
}

function thesis_widget_recent_entries_control($widget_args) {
	global $wp_registered_widgets;
	static $updated = false;

	if (is_numeric($widget_args))
		$widget_args = array('number' => $widget_args);
	
	$widget_args = wp_parse_args($widget_args, array('number' => -1));
	extract($widget_args, EXTR_SKIP);

	$options = get_option('widget_killer_recent_entries');
	
	if (!is_array($options))
		$options = array();

	if (!$updated && !empty($_POST['sidebar'])) {
		$sidebar = (string) $_POST['sidebar'];

		$sidebars_widgets = wp_get_sidebars_widgets();
		
		if (isset($sidebars_widgets[$sidebar]))
			$this_sidebar =& $sidebars_widgets[$sidebar];
		else
			$this_sidebar = array();

		foreach ((array) $this_sidebar as $_widget_id) {
			if ('thesis_widget_recent_entries' == $wp_registered_widgets[$_widget_id]['callback'] && isset($wp_registered_widgets[$_widget_id]['params'][0]['number'])) {
				$widget_number = $wp_registered_widgets[$_widget_id]['params'][0]['number'];
				
				if (!in_array("widget_killer_recent_entries-$widget_number", $_POST['widget-id'])) // the widget has been removed.
					unset($options[$widget_number]);
			}
		}

		foreach ((array) $_POST['widget-killer-recent-entries'] as $widget_number => $widget_recent_entries) {				
			$category = $widget_recent_entries['category'];
			$title = strip_tags(stripslashes($widget_recent_entries['title']));
			$numposts = $widget_recent_entries['numposts'];
			$comments = $widget_recent_entries['comments'];
			$options[$widget_number] = compact('category', 'title', 'numposts', 'comments');
		}

		update_option('widget_killer_recent_entries', $options);
		$updated = true;
	}

	if (-1 == $number) {
		$category = 'all';
		$title = '';
		$numposts = 5;
		$comments = false;
		$number = '%i%';
	} 
	else {
		$category = attribute_escape($options[$number]['category']);
		$title = format_to_edit($options[$number]['title']);
		$numposts = format_to_edit($options[$number]['numposts']);
		$comments = format_to_edit($options[$number]['comments']);
	}
?>
		<p>
			<label for="widget-killer-recent-entries-category-<?php echo $number; ?>"><?php _e('Show recent posts from this category:', 'thesis'); ?>
			<select id="widget-killer-recent-entries-category-<?php echo $number; ?>" name="widget-killer-recent-entries[<?php echo $number; ?>][category]" size="1">
				<option value="all"<?php if ($category == 'all' || $category == '') echo ' selected="selected"'; ?>><?php _e('All recent posts', 'thesis'); ?></option>
<?php
			$categories = &get_categories('type=post&orderby=name&hide_empty=0');
			
			if ($categories) {
				foreach ($categories as $current_category) {
					$selected = ($current_category->slug == $category) ? ' selected="selected"' : '';
					echo '<option value="' . $current_category->slug . '"' . $selected . '>' . $current_category->cat_name . '</option>' . "\n";
				}
			}
?>
			</select></label>
		</p>
		<p>
			<label for="widget-killer-recent-entries-title-<?php echo $number; ?>"><?php _e('Title (optional, defaults to category name):', 'thesis'); ?>
			<input class="widefat" id="widget-killer-recent-entries-title-<?php echo $number; ?>" name="widget-killer-recent-entries[<?php echo $number; ?>][title]" type="text" value="<?php echo $title; ?>" /></label>
		</p>
		<p>
			<label for="widget-killer-recent-entries-numposts-<?php echo $number; ?>"><?php _e('Number of posts to show:', 'thesis'); ?>
			<select id="widget-killer-recent-entries-numposts-<?php echo $number; ?>" name="widget-killer-recent-entries[<?php echo $number; ?>][numposts]" size="1">
<?php
			for ($i = 1; $i <= 20; $i++) {
				$selected = ($numposts == $i) ? ' selected="selected"' : '';
				echo '				<option value="' . $i . '"' . $selected . '>' . $i . '</option>' . "\n";
			}
?>
			</select>
			<input type="hidden" name="widget-killer-recent-entries[<?php echo $number; ?>][submit]" value="1" />
		</p>
		<p>
			<label for="widget-killer-recent-entries-comments-<?php echo $number; ?>"><?php _e('Show number of comments?', 'thesis'); ?>
			<input type="checkbox" id="widget-killer-recent-entries-comments-<?php echo $number; ?>" name="widget-killer-recent-entries[<?php echo $number; ?>][comments]" value="1" /></label>
		</p>
<?php
}

function thesis_widget_recent_entries_register() {
	if (!$options = get_option('widget_killer_recent_entries'))
		$options = array();

	$widget_ops = array('classname' => 'widget_killer_recent_entries', 'description' => __('Show recent posts from any category or your entire site'));
	$control_ops = array('width' => '', 'height' => '', 'id_base' => 'widget_killer_recent_entries');
	$name = __('Killer Recent Entries');
	$id = false;
	
	foreach ((array) array_keys($options) as $o) {
		// Old widgets can have null values for some reason
		if (!isset($options[$o]['category']) || !isset($options[$o]['numposts']))
			continue;
		
		$id = "widget_killer_recent_entries-$o"; // Never never never translate an id
		wp_register_sidebar_widget($id, $name, 'thesis_widget_recent_entries', $widget_ops, array('number' => $o));
		wp_register_widget_control($id, $name, 'thesis_widget_recent_entries_control', $control_ops, array('number' => $o));
	}

	// If there are none, we register the widget's existance with a generic template
	if (!$id) {
		wp_register_sidebar_widget('widget_killer_recent_entries-1', $name, 'thesis_widget_recent_entries', $widget_ops, array('number' => -1));
		wp_register_widget_control('widget_killer_recent_entries-1', $name, 'thesis_widget_recent_entries_control', $control_ops, array('number' => -1));
	}
}

function thesis_widget_recent_posts($category_slug = false, $title = 'Recent Entries', $number = 5) {
	$category = ($category_slug) ? 'category_name=' . $category_slug : '';

	if (is_home() && !$category_slug) {
		global $posts;
		$title = 'More ' . $title;
		$offset = count($posts);
	}
	else
		$offset = 0;

	$custom_query = new WP_Query("$category&showposts=$number&offset=$offset");
	
	thesis_output_post_list($category_slug, $title, $custom_query);
	
	unset($custom_query);
	wp_reset_query();
}

function thesis_output_post_list($category_slug, $title, $query) {
	if ($query->have_posts()) {
?>
						<li class="widget<?php if ($category_slug) echo ' widget_' . $category_slug; ?>">
							<h3><?php echo $title; ?></h3>
							<ul>
<?php
		while ($query->have_posts()) :
			$query->the_post();
?>
								<li><a href="<?php the_permalink(); ?>" title="<?php the_title(); ?>" rel="bookmark"><?php the_title(); ?></a></li>
<?php
		endwhile;
?>
							</ul>
						</li>
<?php
	}
}

function thesis_get_post_data_from_object($post_object) {
	$post['id'] = $post_object->ID;
	$post['author'] = $post_object->post_author;
	$post['date'] = $post_object->post_date;
	$post['content'] = $post_object->post_content;
	$post['title'] = $post_object->post_title;
	$post['category'] = $post_object->post_category;
	$post['excerpt'] = $post_object->post_excerpt;
	$post['comment_count'] = $post_object->comment_count;
	
	return $post;
}

function thesis_widget_tag_cloud() {
	if (function_exists('wp_tag_cloud')) {
?>
	<li class="widget tag_cloud">
		<h3>Popular Tags</h3>
<?php wp_tag_cloud('smallest=10&largest=16&number=30'); ?>

	</li>
<?php
	}
}

function thesis_default_widget($sidebar = 1) {
	global $thesis;

	if ((!dynamic_sidebar($sidebar) && $thesis['display']['sidebars']['default_widgets']) || $_GET['template']) {
?>
					<li class="widget">
						<div class="widget_box">
							<h3><?php _e('Default Widget', 'thesis'); ?></h3>
							<p class="remove_bottom_margin"><?php _e('This is Sidebar ' . $sidebar . '. You can edit the content that appears here by visiting your <a href="' . get_bloginfo('wpurl') . '/wp-admin/widgets.php">Widgets panel</a> and modifying the <em>current widgets</em> in Sidebar ' . $sidebar . '. Or, if you want to be a true ninja, you can add your own content to this sidebar by using the <a href="http://diythemes.com/thesis/rtfm/hooks/">appropriate hooks</a>.', 'thesis'); ?></p>
						</div>
					</li>
<?php
	}
}