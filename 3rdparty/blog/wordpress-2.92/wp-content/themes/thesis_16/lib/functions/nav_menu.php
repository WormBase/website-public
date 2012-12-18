<?php

function thesis_nav_menu() {
	global $thesis;
	global $wp_query;
	$current['id'] = (!is_archive()) ? $wp_query->queried_object_id : false;
	$home_text = thesis_home_link_text();
	$home_nofollow = ($thesis['nav']['home']['nofollow']) ? ' rel="nofollow"' : '';
	
	if ($current['id'] && $wp_query->post->ancestors)
		$current['ancestors'] = $wp_query->post->ancestors;

	echo '<ul class="menu">' . "\n";
	
	thesis_hook_first_nav_item();
	
	if ($thesis['nav']['home']['show'] || $_GET['template']) {
		if (is_front_page()) {
			$current_page = get_query_var('paged');
			$is_current = ($current_page <= 1) ? ' current' : '';
		}
		else
			$is_current = (is_home() && is_front_page()) ? ' current' : '';

		echo '<li class="tab tab-home' . $is_current . '"><a href="' . get_bloginfo('url') . '"' . $home_nofollow . '>' . $home_text . '</a></li>' . "\n";
	}

	if ($thesis['nav']['pages']) {
		foreach ($thesis['nav']['pages'] as $id => $nav_page) {
			if ($nav_page['show']) {
				$nav_items[] = $id;
				$page_data[$id] = get_page($id);
				$parents[$id] = ($page_data[$id]->post_parent != 0) ? $page_data[$id]->post_parent : 0;
			}
		}
		
		if (is_array($nav_items)) {
			foreach ($nav_items as $id) {
				if (!$parents[$id])
					$nav_array[] = thesis_nav_array($id, $nav_items, $current);
			}
		}

		if (is_array($nav_array))
			thesis_output_nav($nav_array, $page_data);
	}
	
	if ($thesis['nav']['categories'])
		wp_list_categories('title_li=&include=' . $thesis['nav']['categories']);
	
	if ($thesis['nav']['links']) {
		$nav_links = get_bookmarks('category=' . $thesis['nav']['links']);

		foreach ($nav_links as $nav_link) {
			if ($nav_link->link_description)
				$title = ' title="' . $nav_link->link_description . '"';
			if ($nav_link->link_rel)
				$rel = ' rel="' . $nav_link->link_rel . '"';
			if ($nav_link->link_target)
				$target = ' target="' . $nav_link->link_target . '"';
			
			echo '<li><a href="' . $nav_link->link_url . '"' . $title . $rel . $target . '>' . $nav_link->link_name . '</a></li>' . "\n";
		}
	}
	
	if ($thesis['nav']['feed']['show'] || $_GET['template']) {
		$feed_title = get_bloginfo('name') . ' RSS Feed';
		$feed_nofollow = ($thesis['nav']['feed']['nofollow']) ? ' rel="nofollow"' : '';

		echo '<li class="rss"><a href="' . thesis_feed_url() . '" title="' . $feed_title . '"' . $feed_nofollow . '>' . thesis_feed_link_text() . '</a></li>' . "\n";
	}
	
	thesis_hook_last_nav_item();
		
	echo "</ul>\n";
}

function thesis_nav_array($id, $nav_items, $current = false) {
	$raw_children = get_posts('numberposts=-1&post_type=page&post_parent=' . $id);
	
	foreach ($raw_children as $child) {
		if (in_array($child->ID, $nav_items))
			$possible_children[] = $child->ID;
	}
	
	// This conditional construct exists solely to sort the submenu items according to the user's input
	if ($possible_children) {
		foreach ($nav_items as $nav_item) {
			if (in_array($nav_item, $possible_children))
				$children[] = thesis_nav_array($nav_item, $nav_items, $current);
		}
	}
	
	$item['id'] = $id;
	$item['children'] = ($children) ? $children : '';
	$item['current'] = ($item['id'] == $current['id']) ? true : false;

	if (is_array($current['ancestors']))
		$item['ancestor'] = (in_array($id, $current['ancestors'])) ? true : false;
	else
		$item['ancestor'] = false;
	
	return $item;
}

function thesis_output_nav($nav_array, $page_data, $tab_num = 1, $depth = 0, $thesis_nav_item_num = 0) {
	global $wp_query;
	global $thesis;
	global $thesis_nav_item_num;

	foreach ($nav_array as $nav_item) {
		$tab_classes = false;

		if ($depth == 0) {
			$tab_classes[] = 'tab';
			$tab_classes[] = 'tab-' . $tab_num;
			$tab_num++;
		}
		else {
			$thesis_nav_item_num++;
			$tab_classes[] = 'item';
			$tab_classes[] = 'item-' . $thesis_nav_item_num;
		}

		if ($nav_item['current'])
			$tab_classes[] = 'current';
		elseif ($nav_item['ancestor'])
			$tab_classes[] = 'current-parent';

		$tab = ' class="' . implode(' ', $tab_classes) . '"';
		$link_text = ($thesis['nav']['pages'][$nav_item['id']]['text'] != '') ? $thesis['nav']['pages'][$nav_item['id']]['text'] : $page_data[$nav_item['id']]->post_title;
		$title = $page_data[$nav_item['id']]->post_title;

		if (is_array($nav_item['children'])) {
			$depth++;
			$level = ($depth > 0) ? ' class="submenu submenu-' . $depth . '"' : '';
			echo '<li' . $tab . '><a href="' . get_page_link($nav_item['id']) . '" title="' . $title . '">' . $link_text . '<!--[if IE 7]><!--></a><!--<![endif]-->' . "\n";
			echo '<!--[if lte IE 6]><table><tr><td><![endif]-->' . "\n<ul$level>\n";
			thesis_output_nav($nav_item['children'], $page_data, $tab_num, $depth, $thesis_nav_item_num);
			echo "</ul>\n<!--[if lte IE 6]></td></tr></table></a><![endif]-->\n</li>\n";
			$depth--;
		}
		else
			echo '<li' . $tab .'><a href="' . get_page_link($nav_item['id']) . '" title="' . $title . '">' . $link_text . '</a></li>' . "\n";
	}
}

function thesis_home_link_text() {
	global $thesis;
	$link_text = ($thesis['nav']['home']['text']) ? $thesis['nav']['home']['text'] : __('Home', 'thesis');
	return $link_text;
}

function thesis_feed_link_text() {
	global $thesis;
	$link_text = ($thesis['nav']['feed']['text']) ? $thesis['nav']['feed']['text'] : __('Subscribe', 'thesis');
	return $link_text;
}