<?php
/**
 * class thesis_page_options
 *
 * @package Thesis
 * @since 1.7
 */
class thesis_page_options {
	function default_options() {
		// Home page options
		$this->home = array(
			'head' => array(
				'title' => false,
				'meta' => array(
					'robots' => array(
						'noindex' => false,
						'nofollow' => false,
						'noarchive' => false
					),
					'description' => false,
					'keywords' => false
				)
			),
			'body' => array(
				'content' => array(
					'features' => 2
				)
			),
			'javascript' => array(
				'libs' => false,
				'scripts' => false
			)
		);
	}

	function get_options() {
		$saved_options = maybe_unserialize(get_option('thesis_pages'));

		if (!empty($saved_options) && is_object($saved_options)) {
			foreach ($saved_options as $option_name => $value)
				$this->$option_name = $value;
		}
	}

	function update_options() {
		global $thesis_site, $thesis_design;
		$home = $_POST['home'];
		$categories = $_POST['categories'];
		$tags = $_POST['tags'];
		$head = $thesis_site->head;
		$javascript = $thesis_design->javascript;
		$thesis_javascript = new thesis_javascript;
		
		$this->home['head']['title'] = ($home['head']['title']) ? urlencode(strip_tags(stripslashes($home['head']['title']))) : false;
		$this->home['head']['meta']['description'] = ($home['head']['meta']['description']) ? urlencode(strip_tags(stripslashes($home['head']['meta']['description']))) : false;
		$this->home['head']['meta']['keywords'] = ($home['head']['meta']['keywords']) ? urlencode(strip_tags(stripslashes($home['head']['meta']['keywords']))) : false;
		$this->home['head']['meta']['robots']['noindex'] = (bool) $home['head']['meta']['robots']['noindex']; 		
		$this->home['head']['meta']['robots']['nofollow'] = (bool) $home['head']['meta']['robots']['nofollow'];
		$this->home['head']['meta']['robots']['noarchive'] = (bool) $home['head']['meta']['robots']['noarchive'];
		$this->home['body']['content']['features'] = $home['body']['content']['features'];
		if (is_array($thesis_javascript->libs)) {
			foreach ($thesis_javascript->libs as $lib_name => $lib) {
				if ((bool) $home['javascript']['libs'][$lib_name] != (bool) $javascript['libs'][$lib_name])
					$this->home['javascript']['libs'][$lib_name] = (bool) $home['javascript']['libs'][$lib_name];
			}
		}
		$this->home['javascript']['scripts'] = ($home['javascript']['scripts']) ? $home['javascript']['scripts'] : false;

		if (is_array($categories)) {
			foreach ($categories as $cat_id => $values) {
				if ($values['head']['title']) $this->categories[$cat_id]['head']['title'] = urlencode(strip_tags(stripslashes($values['head']['title'])));
				if ($values['head']['meta']['description']) $this->categories[$cat_id]['head']['meta']['description'] = urlencode(strip_tags(stripslashes($values['head']['meta']['description'])));
				if ($values['head']['meta']['keywords']) $this->categories[$cat_id]['head']['meta']['keywords'] = urlencode(strip_tags(stripslashes($values['head']['meta']['keywords'])));
				if ((bool) $head['meta']['robots']['noindex']['category'] != (bool) $values['head']['meta']['robots']['noindex']) $this->categories[$cat_id]['head']['meta']['robots']['noindex'] = (bool) $values['head']['meta']['robots']['noindex'];
				if ((bool) $head['meta']['robots']['nofollow']['category'] != (bool) $values['head']['meta']['robots']['nofollow']) $this->categories[$cat_id]['head']['meta']['robots']['nofollow'] = (bool) $values['head']['meta']['robots']['nofollow'];
				if ((bool) $head['meta']['robots']['noarchive']['category'] != (bool) $values['head']['meta']['robots']['noarchive']) $this->categories[$cat_id]['head']['meta']['robots']['noarchive'] = (bool) $values['head']['meta']['robots']['noarchive'];
				if (is_array($thesis_javascript->libs)) {
					foreach ($thesis_javascript->libs as $lib_name => $lib) {
						if ((bool) $values['javascript']['libs'][$lib_name] != (bool) $javascript['libs'][$lib_name])
							$this->categories[$cat_id]['javascript']['libs'][$lib_name] = (bool) $values['javascript']['libs'][$lib_name];
					}
				}
				$this->categories[$cat_id]['javascript']['scripts'] = ($values['javascript']['scripts']) ? $values['javascript']['scripts'] : false;
			}
		}

		if (is_array($tags)) {
			foreach ($tags as $tag_id => $values) {
				if ($values['head']['title']) $this->tags[$tag_id]['head']['title'] = urlencode(strip_tags(stripslashes($values['head']['title'])));
				if ($values['head']['meta']['description']) $this->tags[$tag_id]['head']['meta']['description'] = urlencode(strip_tags(stripslashes($values['head']['meta']['description'])));
				if ($values['head']['meta']['keywords']) $this->tags[$tag_id]['head']['meta']['keywords'] = urlencode(strip_tags(stripslashes($values['head']['meta']['keywords'])));
				if ((bool) $head['meta']['robots']['noindex']['tag'] != (bool) $values['head']['meta']['robots']['noindex']) $this->tags[$tag_id]['head']['meta']['robots']['noindex'] = (bool) $values['head']['meta']['robots']['noindex'];
				if ((bool) $head['meta']['robots']['nofollow']['tag'] != (bool) $values['head']['meta']['robots']['nofollow']) $this->tags[$tag_id]['head']['meta']['robots']['nofollow'] = (bool) $values['head']['meta']['robots']['nofollow'];
				if ((bool) $head['meta']['robots']['noarchive']['tag'] != (bool) $values['head']['meta']['robots']['noarchive']) $this->tags[$tag_id]['head']['meta']['robots']['noarchive'] = (bool) $values['head']['meta']['robots']['noarchive'];
				if (is_array($thesis_javascript->libs)) {
					foreach ($thesis_javascript->libs as $lib_name => $lib) {
						if ((bool) $values['javascript']['libs'][$lib_name] != (bool) $javascript['libs'][$lib_name])
							$this->tags[$tag_id]['javascript']['libs'][$lib_name] = (bool) $values['javascript']['libs'][$lib_name];
					}
				}
				$this->tags[$tag_id]['javascript']['scripts'] = ($values['javascript']['scripts']) ? $values['javascript']['scripts'] : false;
			}
		}
	}

	function save_options() {
		if (!current_user_can('edit_themes'))
			wp_die(__('Easy there, homey. You don&#8217;t have admin privileges to access theme options.', 'thesis'));

		if (isset($_POST['submit'])) {
			$page_options = new thesis_page_options;
			$page_options->update_options();
			update_option('thesis_pages', $page_options);
		}

		wp_redirect(admin_url('admin.php?page=thesis-pages&updated=true'));
	}
	
	function upgrade_options() {
		$page_options = new thesis_page_options;
		$default_options = new thesis_page_options;
		$page_options->get_options();
		$default_options->default_options();

		foreach ($default_options as $option_name => $value) {
			if (!isset($page_options->$option_name)) 
				$page_options->$option_name = $default_options->$option_name;
		}
		
		update_option('thesis_pages', $page_options);
	}

	function options_page() {
		global $thesis_site, $thesis_design, $thesis_pages;
		$thesis_javascript = new thesis_javascript;
		$thesis_categories = &get_categories('type=post&orderby=name'); #wp
		$thesis_tags = &get_tags(); #wp

		$home = $thesis_pages->home;
		$categories = $thesis_pages->categories;
		$tags = $thesis_pages->tags;

		$rtl = (get_bloginfo('text_direction') == 'rtl') ? ' rtl' : ''; #wp
		echo "<div id=\"thesis_options\" class=\"wrap$rtl\">\n";

		thesis_version_indicator();
		thesis_options_title(__('Thesis Page Options', 'thesis'), true);
		thesis_options_nav();
		thesis_options_status_check();
?>
	<form class="thesis" action="<?php echo admin_url('admin-post.php?action=thesis_pages'); ?>" method="post">
		<div class="options_column">
			<div class="options_module" id="home-page-options">
				<h3><?php _e('Home Page Options', 'thesis'); ?></h3>
				<div class="module_subsection">
					<h4 class="module_switch"><a href="" title="<?php _e('Show/hide additional information', 'thesis'); ?>"><span class="pos">+</span><span class="neg">&#8211;</span></a><?php _e('Document Head', 'thesis'); ?> <code>&lt;head&gt;</code></h4>
					<div class="more_info">
						<p class="form_input add_margin">
							<input type="text" class="text_input" id="home[head][title]" name="home[head][title]" value="<?php if ($home['head']['title']) echo urldecode($home['head']['title']); ?>" />
							<label for="home[head][title]"><?php _e('home page <code>&lt;title&gt;</code> tag', 'thesis'); ?></label>
						</p>
						<p class="form_input add_margin">
							<label for="home[head][meta][description]"><?php _e('home page <code>&lt;meta&gt;</code> description', 'thesis'); ?></label>
							<textarea class="scripts" id="home[head][meta][description]" name="home[head][meta][description]"><?php if ($home['head']['meta']['description']) echo urldecode($home['head']['meta']['description']); ?></textarea>
						</p>
						<p class="form_input add_margin">
							<input type="text" class="text_input" id="home[head][meta][keywords]" name="home[head][meta][keywords]" value="<?php if ($home['head']['meta']['keywords']) echo urldecode($home['head']['meta']['keywords']); ?>" />
							<label for="home[head][meta][keywords]"><?php _e('home page <code>&lt;meta&gt;</code> keywords', 'thesis'); ?></label>
						</p>
						<ul>
							<li><input type="checkbox" id="home[head][meta][robots][noindex]" name="home[head][meta][robots][noindex]" value="1" <?php if ($home['head']['meta']['robots']['noindex']) echo 'checked="checked" '; ?>/><label for="home[head][meta][robots][noindex]"><?php _e('Add <code>noindex</code> to this page', 'thesis'); ?></label></li>
							<li><input type="checkbox" id="home[head][meta][robots][nofollow]" name="home[head][meta][robots][nofollow]" value="1" <?php if ($home['head']['meta']['robots']['nofollow']) echo 'checked="checked" '; ?>/><label for="home[head][meta][robots][nofollow]"><?php _e('Add <code>nofollow</code> to this page', 'thesis'); ?></label></li>
							<li><input type="checkbox" id="home[head][meta][robots][noarchive]" name="home[head][meta][robots][noarchive]" value="1" <?php if ($home['head']['meta']['robots']['noarchive']) echo 'checked="checked" '; ?>/><label for="home[head][meta][robots][noarchive]"><?php _e('Add <code>noarchive</code> to this page', 'thesis'); ?></label></li>
						</ul>
					</div>
				</div>
				<div class="module_subsection">
					<h4 class="module_switch"><a href="" title="<?php _e('Show/hide additional information', 'thesis'); ?>"><span class="pos">+</span><span class="neg">&#8211;</span></a><?php _e('Home Page Display', 'thesis'); ?></h4>
					<div class="more_info">
						<p><?php printf(__('Below, you can select the number of &#8220;featured&#8221; posts to show (normal format) on your home page, and the rest of your posts will be displayed as teasers. In this context, teasers are simply boxes that take up half the width of your content area and contain whatever you specify in your <a href="%s">Teaser Display Options</a>.', 'thesis'), get_bloginfo('wpurl') . '/wp-admin/admin.php?page=thesis-design-options#teaser-options'); ?></p>
						<p class="label_note"><?php _e('Number of featured posts to show', 'thesis'); ?></p>
						<p class="form_input add_margin">
							<select id="home[body][content][features]" name="home[body][content][features]" size="1">
<?php
						$posts_per_page = get_option('posts_per_page');

						if ($home['body']['content']['features'] > $posts_per_page)
							$home['body']['content']['features'] = $posts_per_page;

						for ($i = 0; $i <= $posts_per_page; $i++) {
							$selected = ($home['body']['content']['features'] == $i) ? ' selected="selected"' : '';
							echo "\t\t\t\t\t\t\t\t\t<option value=\"$i\"$selected>$i</option>\n";
						}
?>
							</select>
						</p>
						<p class="tip"><?php _e('<strong>Tip:</strong> To turn off teasers entirely, simply choose the largest value from the dropdown list above&#8212;that way, <em>all</em> your posts will be shown as features.', 'thesis'); ?></p>
					</div>
				</div>
				<div class="module_subsection">
					<h4 class="module_switch"><a href="" title="<?php _e('Show/hide additional information', 'thesis'); ?>"><span class="pos">+</span><span class="neg">&#8211;</span></a><?php _e('JavaScript', 'thesis'); ?></h4>
					<div class="more_info">
						<ul class="add_margin">
<?php
						foreach ($thesis_javascript->libs as $lib_name => $lib) {
							$checked = (($home['javascript']['libs'][$lib_name] && !$thesis_design->javascript['libs'][$lib_name]) || (!isset($home['javascript']['libs'][$lib_name]) && $thesis_design->javascript['libs'][$lib_name]) || ($home['javascript']['libs'][$lib_name] && $thesis_design->javascript['libs'][$lib_name])) ? ' checked="checked" ' : '';
							echo "\t\t\t\t\t\t\t\t\t" . '<li><input type="checkbox" id="home[javascript][libs][' . $lib_name . ']" name="home[javascript][libs][' . $lib_name . ']" value="1"' . $checked . '/><label>' . sprintf(__('%1$s library <a href="%2$s" target="_blank">[?]</a>', 'thesis'), $lib['name'], $lib['info_url']) . "</label></li>\n";
						}
?>
						</ul>
						<p class="form_input">
							<label for="home[javascript][scripts]"><?php _e('JavaScripts (include <code>&lt;script&gt;</code> tags!)', 'thesis'); ?></label>
							<textarea class="scripts" id="home[javascript][scripts]" name="home[javascript][scripts]"><?php if ($home['javascript']['scripts']) thesis_massage_code($home['javascript']['scripts']); ?></textarea>
						</p>
					</div>
				</div>
			</div>
			<div class="options_module" id="thesis-category-options">
				<h3><?php _e('Category Page Options', 'thesis'); ?></h3>
<?php
				foreach ($thesis_categories as $category) {
?>
				<div class="module_subsection">
					<h4 class="module_switch"><a href="" title="<?php _e('Show/hide additional information', 'thesis'); ?>"><span class="pos">+</span><span class="neg">&#8211;</span></a><?php _e($category->cat_name); ?></h4>
					<div class="more_info">
						<div class="mini_module indented_module">
							<h5 class="module_switch"><a href="" title="<?php _e('Show/hide additional information', 'thesis'); ?>"><span class="pos">+</span><span class="neg">&#8211;</span></a><?php _e('Document Head', 'thesis'); ?> <code>&lt;head&gt;</code></h5>
							<div class="more_info">
								<p class="form_input add_margin">
									<input type="text" class="text_input" id="categories[<?php _e($category->cat_ID); ?>][head][title]" name="categories[<?php _e($category->cat_ID); ?>][head][title]" value="<?php if ($categories[$category->cat_ID]['head']['title']) echo urldecode($categories[$category->cat_ID]['head']['title']); ?>" />
									<label for="categories[<?php _e($category->cat_ID); ?>][head][title]"><?php _e($category->cat_name . ' page <code>&lt;title&gt;</code> tag', 'thesis'); ?></label>
								</p>
								<p class="form_input add_margin">
									<label for="categories[<?php _e($category->cat_ID); ?>][head][meta][description]"><?php _e($category->cat_name . ' page <code>&lt;meta&gt;</code> description', 'thesis'); ?></label>
									<textarea class="scripts" id="categories[<?php _e($category->cat_ID); ?>][head][meta][description]" name="categories[<?php _e($category->cat_ID); ?>][head][meta][description]"><?php if ($categories[$category->cat_ID]['head']['meta']['description']) echo urldecode($categories[$category->cat_ID]['head']['meta']['description']); ?></textarea>
								</p>
								<p class="form_input add_margin">
									<input type="text" class="text_input" id="categories[<?php _e($category->cat_ID); ?>][head][meta][keywords]" name="categories[<?php _e($category->cat_ID); ?>][head][meta][keywords]" value="<?php if ($categories[$category->cat_ID]['head']['meta']['keywords']) echo urldecode($categories[$category->cat_ID]['head']['meta']['keywords']); ?>" />
									<label for="categories[<?php _e($category->cat_ID); ?>][head][meta][keywords]"><?php _e($category->cat_name . ' page <code>&lt;meta&gt;</code> keywords', 'thesis'); ?></label>
								</p>
								<ul>
									<li><input type="checkbox" id="categories[<?php _e($category->cat_ID); ?>][head][meta][robots][noindex]" name="categories[<?php _e($category->cat_ID); ?>][head][meta][robots][noindex]" value="1" <?php if (($categories[$category->cat_ID]['head']['meta']['robots']['noindex'] && !$thesis_site->head['meta']['robots']['noindex']['category']) || (!isset($categories[$category->cat_ID]['head']['meta']['robots']['noindex']) && $thesis_site->head['meta']['robots']['noindex']['category']) || ($categories[$category->cat_ID]['head']['meta']['robots']['noindex'] && $thesis_site->head['meta']['robots']['noindex']['category'])) echo 'checked="checked" '; ?>/><label for="categories[<?php _e($category->cat_ID); ?>][head][meta][robots][noindex]"><?php _e('Add <code>noindex</code> to this page', 'thesis'); ?></label></li>
									<li><input type="checkbox" id="categories[<?php _e($category->cat_ID); ?>][head][meta][robots][nofollow]" name="categories[<?php _e($category->cat_ID); ?>][head][meta][robots][nofollow]" value="1" <?php if (($categories[$category->cat_ID]['head']['meta']['robots']['nofollow'] && !$thesis_site->head['meta']['robots']['nofollow']['category']) || (!isset($categories[$category->cat_ID]['head']['meta']['robots']['nofollow']) && $thesis_site->head['meta']['robots']['nofollow']['category']) || ($categories[$category->cat_ID]['head']['meta']['robots']['nofollow'] && $thesis_site->head['meta']['robots']['nofollow']['category'])) echo 'checked="checked" '; ?>/><label for="categories[<?php _e($category->cat_ID); ?>][head][meta][robots][nofollow]"><?php _e('Add <code>nofollow</code> to this page', 'thesis'); ?></label></li>
									<li><input type="checkbox" id="categories[<?php _e($category->cat_ID); ?>][head][meta][robots][noarchive]" name="categories[<?php _e($category->cat_ID); ?>][head][meta][robots][noarchive]" value="1" <?php if (($categories[$category->cat_ID]['head']['meta']['robots']['noarchive'] && !$thesis_site->head['meta']['robots']['noarchive']['category']) || (!isset($categories[$category->cat_ID]['head']['meta']['robots']['noarchive']) && $thesis_site->head['meta']['robots']['noarchive']['category']) || ($categories[$category->cat_ID]['head']['meta']['robots']['noarchive'] && $thesis_site->head['meta']['robots']['noarchive']['category'])) echo 'checked="checked" '; ?>/><label for="categories[<?php _e($category->cat_ID); ?>][head][meta][robots][noarchive]"><?php _e('Add <code>noarchive</code> to this page', 'thesis'); ?></label></li>
								</ul>
							</div>
						</div>
						<div class="mini_module indented_module">
							<h5 class="module_switch"><a href="" title="<?php _e('Show/hide additional information', 'thesis'); ?>"><span class="pos">+</span><span class="neg">&#8211;</span></a><?php _e('JavaScript', 'thesis'); ?></h5>
							<div class="more_info">
								<ul class="add_margin">
<?php
								foreach ($thesis_javascript->libs as $lib_name => $lib) {
									$checked = (($categories[$category->cat_ID]['javascript']['libs'][$lib_name] && !$thesis_design->javascript['libs'][$lib_name]) || (!isset($categories[$category->cat_ID]['javascript']['libs'][$lib_name]) && $thesis_design->javascript['libs'][$lib_name]) || ($categories[$category->cat_ID]['javascript']['libs'][$lib_name] && $thesis_design->javascript['libs'][$lib_name])) ? ' checked="checked" ' : '';
									echo "\t\t\t\t\t\t\t\t\t" . '<li><input type="checkbox" id="categories[' . $category->cat_ID . '][javascript][libs][' . $lib_name . ']" name="categories[' . $category->cat_ID . '][javascript][libs][' . $lib_name . ']" value="1"' . $checked . '/><label>' . sprintf(__('%1$s library <a href="%2$s" target="_blank">[?]</a>', 'thesis'), $lib['name'], $lib['info_url']) . "</label></li>\n";
								}
?>
								</ul>
								<p class="form_input">
									<label for="categories[<?php _e($category->cat_ID); ?>][javascript][scripts]"><?php _e('JavaScripts (include <code>&lt;script&gt;</code> tags!)', 'thesis'); ?></label>
									<textarea class="scripts" id="categories[<?php _e($category->cat_ID); ?>][javascript][scripts]" name="categories[<?php _e($category->cat_ID); ?>][javascript][scripts]"><?php if ($categories[$category->cat_ID]['javascript']['scripts']) thesis_massage_code($categories[$category->cat_ID]['javascript']['scripts']); ?></textarea>
								</p>
							</div>
						</div>
					</div>
				</div>
<?php
				}
?>
			</div>
		</div>
		<div class="options_column">
			<div class="options_module" id="thesis-tag-options">
				<h3><?php _e('Tag Page Options', 'thesis'); ?></h3>
<?php
				foreach ($thesis_tags as $tag) {
?>
				<div class="module_subsection">
					<h4 class="module_switch"><a href="" title="<?php _e('Show/hide additional information', 'thesis'); ?>"><span class="pos">+</span><span class="neg">&#8211;</span></a><?php _e($tag->name); ?></h4>
					<div class="more_info">
						<div class="mini_module indented_module">
							<h5 class="module_switch"><a href="" title="<?php _e('Show/hide additional information', 'thesis'); ?>"><span class="pos">+</span><span class="neg">&#8211;</span></a><?php _e('Document Head', 'thesis'); ?> <code>&lt;head&gt;</code></h5>
							<div class="more_info">
								<p class="form_input add_margin">
									<input type="text" class="text_input" id="tags[<?php _e($tag->term_id); ?>][head][title]" name="tags[<?php _e($tag->term_id); ?>][head][title]" value="<?php if ($tags[$tag->term_id]['head']['title']) echo urldecode($tags[$tag->term_id]['head']['title']); ?>" />
									<label for="tags[<?php _e($tag->term_id); ?>][head][title]"><?php _e($tag->name . ' page <code>&lt;title&gt;</code> tag', 'thesis'); ?></label>
								</p>
								<p class="form_input add_margin">
									<label for="tags[<?php _e($tag->term_id); ?>][head][meta][description]"><?php _e($tag->name . ' page <code>&lt;meta&gt;</code> description', 'thesis'); ?></label>
									<textarea class="scripts" id="tags[<?php _e($tag->term_id); ?>][head][meta][description]" name="tags[<?php _e($tag->term_id); ?>][head][meta][description]"><?php if ($tags[$tag->term_id]['head']['meta']['description']) echo urldecode($tags[$tag->term_id]['head']['meta']['description']); ?></textarea>
								</p>
								<p class="form_input add_margin">
									<input type="text" class="text_input" id="tags[<?php _e($tag->term_id); ?>][head][meta][keywords]" name="tags[<?php _e($tag->term_id); ?>][head][meta][keywords]" value="<?php if ($tags[$tag->term_id]['head']['meta']['keywords']) echo urldecode($tags[$tag->term_id]['head']['meta']['keywords']); ?>" />
									<label for="tags[<?php _e($tag->term_id); ?>][head][meta][keywords]"><?php _e($tag->name . ' page <code>&lt;meta&gt;</code> keywords', 'thesis'); ?></label>
								</p>
								<ul>
									<li><input type="checkbox" id="tags[<?php _e($tag->term_id); ?>][head][meta][robots][noindex]" name="tags[<?php _e($tag->term_id); ?>][head][meta][robots][noindex]" value="1" <?php if (($tags[$tag->term_id]['head']['meta']['robots']['noindex'] && !$thesis_site->head['meta']['robots']['noindex']['tag']) || (!isset($tags[$tag->term_id]['head']['meta']['robots']['noindex']) && $thesis_site->head['meta']['robots']['noindex']['tag']) || ($tags[$tag->term_id]['head']['meta']['robots']['noindex'] && $thesis_site->head['meta']['robots']['noindex']['tag'])) echo 'checked="checked" '; ?>/><label for="tags[<?php _e($tag->term_id); ?>][head][meta][robots][noindex]"><?php _e('Add <code>noindex</code> to this page', 'thesis'); ?></label></li>
									<li><input type="checkbox" id="tags[<?php _e($tag->term_id); ?>][head][meta][robots][nofollow]" name="tags[<?php _e($tag->term_id); ?>][head][meta][robots][nofollow]" value="1" <?php if (($tags[$tag->term_id]['head']['meta']['robots']['nofollow'] && !$thesis_site->head['meta']['robots']['nofollow']['tag']) || (!isset($tags[$tag->term_id]['head']['meta']['robots']['nofollow']) && $thesis_site->head['meta']['robots']['nofollow']['tag']) || ($tags[$tag->term_id]['head']['meta']['robots']['nofollow'] && $thesis_site->head['meta']['robots']['nofollow']['tag'])) echo 'checked="checked" '; ?>/><label for="tags[<?php _e($tag->term_id); ?>][head][meta][robots][nofollow]"><?php _e('Add <code>nofollow</code> to this page', 'thesis'); ?></label></li>
									<li><input type="checkbox" id="tags[<?php _e($tag->term_id); ?>][head][meta][robots][noarchive]" name="tags[<?php _e($tag->term_id); ?>][head][meta][robots][noarchive]" value="1" <?php if (($tags[$tag->term_id]['head']['meta']['robots']['noarchive'] && !$thesis_site->head['meta']['robots']['noarchive']['tag']) || (!isset($tags[$tag->term_id]['head']['meta']['robots']['noarchive']) && $thesis_site->head['meta']['robots']['noarchive']['tag']) || ($tags[$tag->term_id]['head']['meta']['robots']['noarchive'] && $thesis_site->head['meta']['robots']['noarchive']['tag'])) echo 'checked="checked" '; ?>/><label for="tags[<?php _e($tag->term_id); ?>][head][meta][robots][noarchive]"><?php _e('Add <code>noarchive</code> to this page', 'thesis'); ?></label></li>
								</ul>
							</div>
						</div>
						<div class="mini_module indented_module">
							<h5 class="module_switch"><a href="" title="<?php _e('Show/hide additional information', 'thesis'); ?>"><span class="pos">+</span><span class="neg">&#8211;</span></a><?php _e('JavaScript', 'thesis'); ?></h5>
							<div class="more_info">
								<ul class="add_margin">
<?php
								foreach ($thesis_javascript->libs as $lib_name => $lib) {
									$checked = (($tags[$tag->term_id]['javascript']['libs'][$lib_name] && !$thesis_design->javascript['libs'][$lib_name]) || (!isset($tags[$tag->term_id]['javascript']['libs'][$lib_name]) && $thesis_design->javascript['libs'][$lib_name]) || ($tags[$tag->term_id]['javascript']['libs'][$lib_name] && $thesis_design->javascript['libs'][$lib_name])) ? ' checked="checked" ' : '';
									echo "\t\t\t\t\t\t\t\t\t" . '<li><input type="checkbox" id="tags[' . $tag->term_id . '][javascript][libs][' . $lib_name . ']" name="tags[' . $tag->term_id . '][javascript][libs][' . $lib_name . ']" value="1"' . $checked . '/><label>' . sprintf(__('%1$s library <a href="%2$s" target="_blank">[?]</a>', 'thesis'), $lib['name'], $lib['info_url']) . "</label></li>\n";
								}
?>
								</ul>
								<p class="form_input">
									<label for="tags[<?php _e($tag->term_id); ?>][javascript][scripts]"><?php _e('JavaScripts (include <code>&lt;script&gt;</code> tags!)', 'thesis'); ?></label>
									<textarea class="scripts" id="tags[<?php _e($tag->term_id); ?>][javascript][scripts]" name="tags[<?php _e($tag->term_id); ?>][javascript][scripts]"><?php if ($tags[$tag->term_id]['javascript']['scripts']) thesis_massage_code($tags[$tag->term_id]['javascript']['scripts']); ?></textarea>
								</p>
							</div>
						</div>
					</div>
				</div>
<?php
				}
?>
			</div>
		</div>
		<div class="options_column">
			<div class="options_module button_module">
				<input type="submit" class="save_button" id="options_submit" name="submit" value="<?php thesis_save_button_text(); ?>" />
			</div>
		</div>
	</form>
<?php
	echo "</div>\n";
	}
}