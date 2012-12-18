<?php
/**
 * class thesis_javascript
 *
 * @package Thesis
 * @since 1.7
 */
class thesis_javascript {
	var $libs = array(
		'jquery' => array(
			'name' => 'jQuery',
			'url' => 'http://ajax.googleapis.com/ajax/libs/jquery/1.4.2/jquery.min.js',
			'info_url' => 'http://jquery.com/'
		),
		'jquery_ui' => array(
			'name' => 'jQuery UI',
			'url' => 'http://ajax.googleapis.com/ajax/libs/jqueryui/1.7.2/jquery-ui.min.js',
			'info_url' => 'http://jqueryui.com/'
		),
		'prototype' => array(
			'name' => 'Prototype',
			'url' => 'http://ajax.googleapis.com/ajax/libs/prototype/1.6.1.0/prototype.js',
			'info_url' => 'http://www.prototypejs.org/'
		),
		'scriptaculous' => array(
			'name' => 'script.aculo.us',
			'url' => 'http://ajax.googleapis.com/ajax/libs/scriptaculous/1.8.3/scriptaculous.js',
			'info_url' => 'http://script.aculo.us/'
		),
		'mootools' => array(
			'name' => 'MooTools',
			'url' => 'http://ajax.googleapis.com/ajax/libs/mootools/1.2.4/mootools-yui-compressed.js',
			'info_url' => 'http://mootools.net/'
		),
		'dojo' => array(
			'name' => 'Dojo',
			'url' => 'http://ajax.googleapis.com/ajax/libs/dojo/1.4.1/dojo/dojo.xd.js',
			'info_url' => 'http://dojotoolkit.org/'
		),
		'yui' => array(
			'name' => 'Yahoo! User Interface (YUI)',
			'url' => 'http://ajax.googleapis.com/ajax/libs/yui/2.8.0r4/build/yuiloader/yuiloader-min.js',
			'info_url' => 'http://developer.yahoo.com/yui/'
		),
		'ext' => array(
			'name' => 'Ext Core',
			'url' => 'http://ajax.googleapis.com/ajax/libs/ext-core/3.1.0/ext-core.js',
			'info_url' => 'http://www.extjs.com/products/extcore/'
		),
		'chrome' => array(
			'name' => 'Chrome Frame',
			'url' => 'http://ajax.googleapis.com/ajax/libs/chrome-frame/1.0.2/CFInstall.min.js',
			'info_url' => 'http://code.google.com/chrome/chromeframe/'
		)
	);

	function output_scripts() {
		$javascript = new thesis_javascript;
		global $thesis_site, $thesis_design, $thesis_pages;
		$design_scripts = ($thesis_design->javascript['scripts']) ? $thesis_design->javascript['scripts'] . "\n" : '';
		$user_scripts = ($thesis_site->javascript['scripts']) ? $thesis_site->javascript['scripts'] : '';

		if (is_home() || is_front_page()) {
			if (get_option('show_on_front') == 'page') $page_id = (is_front_page()) ? get_option('page_on_front') : get_option('page_for_posts');
			$libs = ($page_id) ? get_post_meta($page_id, 'thesis_javascript_libs', true) : $thesis_pages->home['javascript']['libs'];
			$page_scripts = ($page_id) ? get_post_meta($page_id, 'thesis_javascript_scripts', true) : $thesis_pages->home['javascript']['scripts'];
		}
		elseif (is_page() || is_single()) { #wp
			global $post; #wp
			$libs = get_post_meta($post->ID, 'thesis_javascript_libs', true);
			$page_scripts = get_post_meta($post->ID, 'thesis_javascript_scripts', true);
		}
		elseif (is_category()) { #wp
			global $wp_query; #wp
			$libs = $thesis_pages->categories[$wp_query->query_vars['cat']]['javascript']['libs'];
			$page_scripts = $thesis_pages->categories[$wp_query->query_vars['cat']]['javascript']['scripts'];
		}
		elseif (is_tag()) { #wp
			global $wp_query; #wp
			$libs = $thesis_pages->tags[$wp_query->query_vars['tag_id']]['javascript']['libs'];
			$page_scripts = $thesis_pages->tags[$wp_query->query_vars['tag_id']]['javascript']['scripts'];
		}

		if (is_array($thesis_design->javascript['libs'])) {
			foreach ($thesis_design->javascript['libs'] as $lib_name => $include) {
				if ((isset($libs[$lib_name]) && $libs[$lib_name]) || (!isset($libs[$lib_name]) && $include))
					$output[$lib_name] = '<script type="text/javascript" src="' . $javascript->libs[$lib_name]['url'] . '"></script>';
			}
			if ($output) echo implode("\n", $output) . "\n";
		}

		$scripts = ($page_scripts) ? "$design_scripts$page_scripts\n$user_scripts" : "$design_scripts$user_scripts";
		if ($scripts != '') echo stripslashes($scripts) . "\n";
	}
}