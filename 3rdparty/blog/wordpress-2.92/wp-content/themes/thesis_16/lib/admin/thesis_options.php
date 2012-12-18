<?php
/**
 * Outputs the HTML for the Thesis Options page.
 *
 * @package Thesis-Admin
 */
?>

<div id="thesis_options" class="wrap<?php if (get_bloginfo('text_direction') == 'rtl') { echo ' rtl'; } ?>">
	<span id="thesis_version"><?php printf(__('You are rocking Thesis version <strong>%s</strong>', 'thesis'), thesis_version()); ?></span>
	<h2><?php _e('Thesis Options', 'thesis'); ?> <a id="master_switch" href="" title="<?php _e('Big Ass Toggle Switch', 'thesis'); ?>"><span class="pos">+</span><span class="neg">&#8211;</span></a></h2>
	<ul id="thesis_links">
		<li><a href="http://diythemes.com/answers/">DIYthemes Answers</a></li>
		<li><a href="http://diythemes.com/forums/">Support Forums</a></li>
		<li><a href="http://diythemes.com/thesis/rtfm/">User&#8217;s Guide</a></li>
		<li><a href="https://diythemes.com/affiliate-program/">Sell Thesis, Earn Cash!</a></li>
		<li><a href="http://diythemes.com/dev/">Thesis Dev Blog</a></li>
	</ul>

<?php 
	if ($_GET['updated']) {
?>
	<div id="updated" class="updated fade">
		<p><?php echo __('Options updated!', 'thesis') . ' <a href="' . get_bloginfo('url') . '/">' . __('Check out your site &rarr;', 'thesis') . '</a>'; ?></p>
	</div>

<?php 
	}
	elseif ($_GET['upgraded']) {
?>
	<div id="updated" class="updated fade">
		<p><?php echo __('Nicely done&#8212;Thesis <strong>' . thesis_version() . '</strong> is ready to rock. Take a moment to browse around the options panels and check out the new awesomeness, or simply <a href="' . get_bloginfo('url') . '/">check out your site now</a>.', 'thesis'); ?></p>
	</div>
<?php
	}
	
	global $thesis;
	global $thesis_design;
	
	$head = $thesis['head'];
	$style = $thesis['style'];
	$feed = $thesis['feed'];
	$scripts = $thesis['scripts'];
	$home = $thesis['home'];
	$display = $thesis['display'];
	$nav = $thesis['nav'];
	$image = $thesis['image'];
	
	if (version_compare($thesis['version'], thesis_version()) != 0 || (!isset($thesis_design['nav']['link']['parent']))) {
?>
	<form id="upgrade_needed" action="<?php echo admin_url('admin-post.php?action=thesis_upgrade'); ?>" method="post">
		<h3><?php _e('Oooh, Exciting!', 'thesis'); ?></h3>
		<p><?php _e('It&#8217;s time to upgrade your Thesis, which means there&#8217;s new awesomeness in your immediate future. Click the button below to fast-track your way to the awesomeness!', 'thesis'); ?></p>
		<p><input type="submit" class="upgrade_button" id="teh_upgrade" name="upgrade" value="<?php _e('Upgrade Thesis', 'thesis'); ?>" /></p>
	</form>
<?php
	}
	else {
		thesis_is_css_writable();
?>

	<form class="thesis" action="<?php echo admin_url('admin-post.php?action=thesis_options'); ?>" method="post">
		<div class="options_column">
			<div class="options_module" id="document-head">
				<h3><?php _e('Document Head', 'thesis'); ?> <code>&lt;head&gt;</code></h3>
				<div class="module_subsection">
					<h4><a href="" title="<?php _e('Show/hide additional information', 'thesis'); ?>"><span class="pos">+</span><span class="neg">&#8211;</span></a><?php _e('Title Tag', 'thesis'); ?> <code>&lt;title&gt;</code></h4>
					<div class="more_info">
						<p class="label_note"><?php _e('Home page settings:', 'thesis'); ?></p>
						<ul class="multi_control add_margin">
							<li class="control"><input type="checkbox" id="head[title][title]" name="head[title][title]" value="1" <?php if ($head['title']['title']) echo 'checked="checked" '; ?>/><label for="head[title][title]"><?php _e('Show site name in title', 'thesis'); ?></label></li>
							<li class="control"><input type="checkbox" id="head[title][tagline]" name="head[title][tagline]" value="1" <?php if ($head['title']['tagline']) echo 'checked="checked" '; ?>/><label for="head[title][tagline]"><?php _e('Show site tagline in title', 'thesis'); ?></label></li>
							<li class="dependent"><input type="checkbox" id="head[title][tagline_first]" name="head[title][tagline_first]" value="1" <?php if ($head['title']['tagline_first']) echo 'checked="checked" '; ?>/><label for="head[title][tagline_first]"><?php _e('Show tagline before title', 'thesis'); ?></label></li>
						</ul>
						<p class="label_note"><?php _e('All other pages:', 'thesis'); ?></p>
						<ul class="add_margin">
							<li><input type="checkbox" id="head[title][branded]" name="head[title][branded]" value="1" <?php if ($head['title']['branded']) echo 'checked="checked" '; ?>/><label for="head[title][branded]"><?php _e('Append site name to page titles', 'thesis'); ?></label></li>
						</ul>
						<p class="form_input add_margin">
							<input type="text" class="text_input" id="head[title][separator]" name="head[title][separator]" value="<?php echo thesis_title_separator($head); ?>" />
							<label for="head[title][separator]"><?php _e('Character separator in titles (where applicable)', 'thesis'); ?></label>
						</p>
						<p class="tip"><?php _e('You can tweak the titles on your category archive pages by editing the <em>Description</em> field for your respective categories.', 'thesis'); ?></p>
					</div>
				</div>
				<div class="module_subsection">
					<h4><a href="" title="<?php _e('Show/hide additional information', 'thesis'); ?>"><span class="pos">+</span><span class="neg">&#8211;</span></a><?php _e('Add Noindex to Archive Pages', 'thesis'); ?></h4>
					<div class="more_info">
						<p><?php _e('Adding the <code>noindex</code> robot meta tag is a great way to fine-tune your site&#8217;s <acronym title="Search Engine Optimization">SEO</acronym> by streamlining the amount of pages that get indexed by the search engines. The options below will help you prevent the indexing of &#8220;bloat&#8221; pages that do nothing but dilute your search results and keep you from ranking as well as you should.', 'thesis'); ?></p>
						<ul>
							<li><input type="checkbox" id="head[noindex][category]" name="head[noindex][category]" value="1" <?php if ($head['noindex']['category']) echo 'checked="checked" '; ?>/><label for="head[noindex][category]"><?php _e('Add <code>noindex</code> to category archives', 'thesis'); ?></label></li>
							<li><input type="checkbox" id="head[noindex][tag]" name="head[noindex][tag]" value="1" <?php if ($head['noindex']['tag']) echo 'checked="checked" '; ?>/><label for="head[noindex][tag]"><?php _e('Add <code>noindex</code> to tag archives', 'thesis'); ?></label></li>
							<li><input type="checkbox" id="head[noindex][author]" name="head[noindex][author]" value="1" <?php if ($head['noindex']['author']) echo 'checked="checked" '; ?>/><label for="head[noindex][author]"><?php _e('Add <code>noindex</code> to author archives', 'thesis'); ?></label></li>
							<li><input type="checkbox" id="head[noindex][day]" name="head[noindex][day]" value="1" <?php if ($head['noindex']['day']) echo 'checked="checked" '; ?>/><label for="head[noindex][day]"><?php _e('Add <code>noindex</code> to daily archives', 'thesis'); ?></label></li>
							<li><input type="checkbox" id="head[noindex][month]" name="head[noindex][month]" value="1" <?php if ($head['noindex']['month']) echo 'checked="checked" '; ?>/><label for="head[noindex][month]"><?php _e('Add <code>noindex</code> to monthly archives', 'thesis'); ?></label></li>
							<li><input type="checkbox" id="head[noindex][year]" name="head[noindex][year]" value="1" <?php if ($head['noindex']['year']) echo 'checked="checked" '; ?>/><label for="head[noindex][year]"><?php _e('Add <code>noindex</code> to yearly archives', 'thesis'); ?></label></li>
						</ul>
					</div>
				</div>
				<div class="module_subsection">
					<h4><a href="" title="<?php _e('Show/hide additional information', 'thesis'); ?>"><span class="pos">+</span><span class="neg">&#8211;</span></a><?php _e('Canonical <acronym title="Uniform Resource Locator">URL</acronym>s', 'thesis'); ?></h4>
					<ul class="more_info">
						<li><input type="checkbox" id="head[canonical]" name="head[canonical]" value="1" <?php if ($head['canonical']) echo 'checked="checked" '; ?>/><label for="head[canonical]"><?php _e('Add canonical <acronym title="Uniform Resource Locator">URL</acronym>s to your site', 'thesis'); ?></label></li>
					</ul>
				</div>
				<div class="module_subsection">
					<h4><a href="" title="<?php _e('Show/hide additional information', 'thesis'); ?>"><span class="pos">+</span><span class="neg">&#8211;</span></a><?php _e('Thesis Version', 'thesis'); ?></h4>
					<ul class="more_info">
						<li><input type="checkbox" id="head[version]" name="head[version]" value="1" <?php if ($head['version']) echo 'checked="checked" '; ?>/><label for="head[version]"><?php _e('Show Thesis version in document head', 'thesis'); ?></label></li>
					</ul>
				</div>
			</div>
			<div class="options_module" id="syndication">
				<h3><?php _e('Syndication/Feed', 'thesis'); ?></h3>
				<div class="module_subsection">
					<h4><a href="" title="<?php _e('Show/hide additional information', 'thesis'); ?>"><span class="pos">+</span><span class="neg">&#8211;</span></a><?php _e('Set your feed <acronym title="Uniform Resource Locator">URL</acronym>:', 'thesis'); ?></h4>
					<div class="more_info">
						<p><?php _e('If you&#8217;re using a service like <a href="http://www.feedburner.com/">Feedburner</a> to manage your <acronym title="Really Simple Syndication">RSS</acronym> feed (highly recommended), you should enter the <acronym title="Uniform Resource Locator">URL</acronym> of your feed in the box below. If you&#8217;d prefer to use the default WordPress feed, simply leave this box blank.', 'thesis'); ?></p>
						<p class="form_input">
							<input type="text" class="text_input" id="feed[url]" name="feed[url]" value="<?php if ($feed['url']) echo $feed['url']; ?>" />
							<label for="feed[url]"><?php _e('Feed <acronym title="Uniform Resource Locator">URL</acronym> (including &#8216;http://&#8217;)', 'thesis'); ?></label>
						</p>
					</div>
				</div>
			</div>
			<div class="options_module" id="thesis-stats">
				<h3><?php _e('Stats Software and Scripts', 'thesis'); ?></h3>
				<div class="module_subsection">
					<h4><a href="" title="<?php _e('Show/hide additional information', 'thesis'); ?>"><span class="pos">+</span><span class="neg">&#8211;</span></a><?php _e('Header Scripts', 'thesis'); ?></h4>
					<div class="more_info">
						<p><?php _e('If you need to add scripts to your header (like <a href="http://haveamint.com/">Mint</a> tracking code, perhaps), you should enter them in the box below.', 'thesis'); ?></p>
						<p class="form_input">
							<label for="scripts[header]"><?php _e('Header scripts (code)', 'thesis'); ?></label>
							<textarea class="scripts" id="scripts[header]" name="scripts[header]"><?php if ($scripts['header']) thesis_massage_code($scripts['header']); ?></textarea>
						</p>
					</div>
				</div>
				<div class="module_subsection">
					<h4><a href="" title="<?php _e('Show/hide additional information', 'thesis'); ?>"><span class="pos">+</span><span class="neg">&#8211;</span></a><?php _e('Footer Scripts', 'thesis'); ?></h4>
					<div class="more_info">
						<p><?php _e('If you need to add scripts to your footer (like <a href="http://www.google.com/analytics/">Google Analytics</a> tracking code), you should enter them here.', 'thesis'); ?></p>
						<p class="form_input">
							<label for="scripts[footer]"><?php _e('Footer scripts (code)'); ?></label>
							<textarea class="scripts" id="scripts[footer]" name="scripts[footer]"><?php if ($scripts['footer']) thesis_massage_code($scripts['footer']); ?></textarea>
						</p>
					</div>
				</div>
			</div>
		</div>
		
		<div class="options_column">
			<div class="options_module" id="home-layout">
				<h3><?php _e('Home Page', 'thesis'); ?></h3>
				<div class="module_subsection">
					<h4><a href="" title="<?php _e('Show/hide additional information', 'thesis'); ?>"><span class="pos">+</span><span class="neg">&#8211;</span></a><?php _e('Home Page Meta', 'thesis'); ?> <code>&lt;meta&gt;</code></h4>
					<div class="more_info">
						<p><?php _e('You should use meta descriptions and keywords to provide search engines with additional information about topics that appear on your site. Please note that the information you enter below only applies to your home page. You can supply separate descriptions and keywords for <em>each page of your site</em> on the post editing screen.', 'thesis'); ?></p>
						<p class="form_input add_margin">
							<label for="home[meta][description]"><?php _e('Meta description for your home page', 'thesis'); ?></label>
							<textarea class="scripts" id="home[meta][description]" name="home[meta][description]"><?php if ($home['meta']['description']) echo strip_tags(stripslashes($home['meta']['description'])); ?></textarea>
						</p>
						<p class="form_input add_margin">
							<input type="text" class="text_input" id="home[meta][keywords]" name="home[meta][keywords]" value="<?php if ($home['meta']['keywords']) echo $home['meta']['keywords']; ?>" />
							<label for="home[meta][keywords]"><?php _e('Meta keywords for your home page', 'thesis'); ?></label>
						</p>
					</div>
				</div>
				<div class="module_subsection">
					<h4><a href="" title="<?php _e('Show/hide additional information', 'thesis'); ?>"><span class="pos">+</span><span class="neg">&#8211;</span></a><?php _e('Home Page Display', 'thesis'); ?></h4>
					<div class="more_info">
						<p><?php _e('Below, you can select the number of &#8220;featured&#8221; posts to show (normal format) on your home page, and the rest of your posts will be displayed as teasers. In this context, teasers are simply boxes that take up half the width of your content area and contain whatever you specify in your <a href="' . get_bloginfo('wpurl') . '/wp-admin/admin.php?page=thesis-design-options#teaser-options">Teaser Display Options</a>.', 'thesis'); ?></p>
						<p class="tip add_margin"><?php _e('<strong>Tip:</strong> To turn off teasers entirely, simply choose the largest value from the dropdown list below&#8212;that way, <em>all</em> your posts will be shown as features.', 'thesis'); ?></p>
						<p class="label_note"><?php _e('Number of featured posts to show', 'thesis'); ?></p>
						<p class="form_input">
							<select id="home[features]" name="home[features]" size="1">
<?php
						$posts_per_page = get_option('posts_per_page');
						
						if ($home['features'] > $posts_per_page)
							$home['features'] = $posts_per_page;

						for ($i = 0; $i <= $posts_per_page; $i++) {
							$selected = ($home['features'] == $i) ? ' selected="selected"' : '';
							echo '									<option value="' . $i . '"' . $selected . '>' . $i . '</option>' . "\n";
						}
?>
							</select>
						</p>
					</div>
				</div>
			</div>
			<div class="options_module" id="display-options">
				<h3><?php _e('Display Options', 'thesis'); ?></h3>
				<div class="module_subsection">
					<h4><a href="" title="<?php _e('Show/hide additional information', 'thesis'); ?>"><span class="pos">+</span><span class="neg">&#8211;</span></a><?php _e('Header', 'thesis'); ?></h4>
					<ul class="more_info">
						<li><input type="checkbox" id="display[header][title]" name="display[header][title]" value="1" <?php if ($display['header']['title']) echo 'checked="checked" '; ?>/><label for="display[header][title]"><?php _e('Show site name in header', 'thesis'); ?></label></li>
						<li><input type="checkbox" id="display[header][tagline]" name="display[header][tagline]" value="1" <?php if ($display['header']['tagline']) echo 'checked="checked" '; ?>/><label for="display[header][tagline]"><?php _e('Show site tagline in header', 'thesis'); ?></label></li>
					</ul>
				</div>
				<div class="module_subsection">
					<h4><a href="" title="<?php _e('Show/hide additional information', 'thesis'); ?>"><span class="pos">+</span><span class="neg">&#8211;</span></a><?php _e('Bylines', 'thesis'); ?></h4>
					<div class="more_info">
						<div class="control_box">
							<ul class="control no_margin">
								<li><input type="checkbox" id="display[byline][author][show]" name="display[byline][author][show]" value="1" <?php if ($display['byline']['author']['show']) echo 'checked="checked" '; ?>/><label for="display[byline][author][show]"><?php _e('Show author name in <strong>post</strong> byline', 'thesis'); ?></label></li>
							</ul>
							<ul class="dependent">
								<li><input type="checkbox" id="display[byline][author][link]" name="display[byline][author][link]" value="1" <?php if ($display['byline']['author']['link']) echo 'checked="checked" '; ?>/><label for="display[byline][author][link]"><?php _e('Link author names to archives', 'thesis'); ?></label></li>
								<li><input type="checkbox" id="display[byline][author][nofollow]" name="display[byline][author][nofollow]" value="1" <?php if ($display['byline']['author']['nofollow']) echo 'checked="checked" '; ?>/><label for="display[byline][author][nofollow]"><?php _e('Add <code>nofollow</code> to author links', 'thesis'); ?></label></li>
							</ul>
						</div>
						<ul>
							<li><input type="checkbox" id="display[byline][date][show]" name="display[byline][date][show]" value="1" <?php if ($display['byline']['date']['show']) echo 'checked="checked" '; ?>/><label for="display[byline][date][show]"><?php _e('Show published-on date in <strong>post</strong> byline', 'thesis'); ?></label></li>
							<li><input type="checkbox" id="display[byline][page][author]" name="display[byline][page][author]" value="1" <?php if ($display['byline']['page']['author']) echo 'checked="checked" '; ?>/><label for="display[byline][page][author]"><?php _e('Show author name in <strong>page</strong> byline', 'thesis'); ?></label></li>
							<li><input type="checkbox" id="display[byline][page][date]" name="display[byline][page][date]" value="1" <?php if ($display['byline']['page']['date']) echo 'checked="checked" '; ?>/><label for="display[byline][page][date]"><?php _e('Show published-on date in <strong>page</strong> byline', 'thesis'); ?></label></li>
							<li><input type="checkbox" id="display[byline][num_comments][show]" name="display[byline][num_comments][show]" value="1" <?php if ($display['byline']['num_comments']['show']) echo 'checked="checked" '; ?>/><label for="display[byline][num_comments][show]"><?php _e('Show number of comments in byline', 'thesis'); ?></label></li>
							<li><input type="checkbox" id="display[byline][categories][show]" name="display[byline][categories][show]" value="1" <?php if ($display['byline']['categories']['show']) echo 'checked="checked" '; ?>/><label for="display[byline][categories][show]"><?php _e('Show <strong>post</strong> categories', 'thesis'); ?></label></li>
						</ul>
					</div>
				</div>
				<div class="module_subsection">
					<h4><a href="" title="<?php _e('Show/hide additional information', 'thesis'); ?>"><span class="pos">+</span><span class="neg">&#8211;</span></a><?php _e('Posts', 'thesis'); ?></h4>
					<div class="more_info">
						<p><?php _e('The display setting you select below only affects your <strong>features</strong>&#8212;teasers (if you&#8217;re using them) are always displayed in excerpt format.', 'thesis'); ?></p>
						<ul class="add_margin">
							<li><input type="radio" name="display[posts][excerpts]" value="0" <?php if (!$display['posts']['excerpts']) echo 'checked="checked" '; ?>/><label><?php _e('Display full post content', 'thesis'); ?></label></li>
							<li><input type="radio" name="display[posts][excerpts]" value="1" <?php if ($display['posts']['excerpts']) echo 'checked="checked" '; ?>/><label><?php _e('Display post excerpts', 'thesis'); ?></label></li>
						</ul>
						<p class="label_note"><?php _e('&#8220;Read More&#8221; link', 'thesis'); ?></p>
						<p><?php _e('This is the clickthrough text on home and archive pages that appears on any post where you use the <code>&lt;!--more--&gt;</code> tag:', 'thesis'); ?></p>
						<p class="form_input add_margin">
							<input type="text" class="text_input" id="display[posts][read_more_text]" name="display[posts][read_more_text]" value="<?php echo thesis_read_more_text(); ?>" />
							<label for="display[posts][read_more_text]"><?php _e('clickthrough text', 'thesis'); ?></label>
						</p>
						<p class="label_note"><?php _e('Single entry pages', 'thesis'); ?></p>
						<ul>
							<li><input type="checkbox" id="display[posts][nav]" name="display[posts][nav]" value="1" <?php if ($display['posts']['nav']) echo 'checked="checked" '; ?>/><label for="display[posts][nav]"><?php _e('Show previous/next post links', 'thesis'); ?></label></li>
						</ul>
					</div>
				</div>
				<div class="module_subsection">
					<h4><a href="" title="<?php _e('Show/hide additional information', 'thesis'); ?>"><span class="pos">+</span><span class="neg">&#8211;</span></a><?php _e('Archives', 'thesis'); ?></h4>
					<div class="more_info">
						<p><?php _e('Select a display format for your archive pages:', 'thesis'); ?></p>
						<ul>
							<li><input type="radio" name="display[archives][style]" value="titles" <?php if ($display['archives']['style'] == 'titles') echo 'checked="checked" '; ?>/><label><?php _e('Titles only', 'thesis'); ?></label></li>
							<li><input type="radio" name="display[archives][style]" value="teasers" <?php if ($display['archives']['style'] == 'teasers') echo 'checked="checked" '; ?>/><label><?php _e('Everything&#8217;s a teaser!', 'thesis'); ?></label></li>
							<li><input type="radio" name="display[archives][style]" value="content" <?php if ($display['archives']['style'] == 'content') echo 'checked="checked" '; ?>/><label><?php _e('Same as your home page', 'thesis'); ?></label></li>
							<li><input type="radio" name="display[archives][style]" value="excerpts" <?php if ($display['archives']['style'] == 'excerpts') echo 'checked="checked" '; ?>/><label><?php _e('Post excerpts', 'thesis'); ?></label></li>
						</ul>
					</div>
				</div>
				<div class="module_subsection">
					<h4><a href="" title="<?php _e('Show/hide additional information', 'thesis'); ?>"><span class="pos">+</span><span class="neg">&#8211;</span></a><?php _e('Tagging', 'thesis'); ?></h4>
					<ul class="more_info">
						<li><input type="checkbox" id="display[tags][single]" name="display[tags][single]" value="1" <?php if ($display['tags']['single']) echo 'checked="checked" '; ?>/><label for="display[tags][single]"><?php _e('Show tags on single entry pages', 'thesis'); ?></label></li>
						<li><input type="checkbox" id="display[tags][index]" name="display[tags][index]" value="1" <?php if ($display['tags']['index']) echo 'checked="checked" '; ?>/><label for="display[tags][index]"><?php _e('Show tags on index and archives pages', 'thesis'); ?></label></li>
						<li><input type="checkbox" id="display[tags][nofollow]" name="display[tags][nofollow]" value="1" <?php if ($display['tags']['nofollow']) echo 'checked="checked" '; ?>/><label for="display[tags][nofollow]"><?php _e('Add <code>nofollow</code> to tag links', 'thesis'); ?></label></li>
					</ul>
				</div>
				<div class="module_subsection">
					<h4><a href="" title="<?php _e('Show/hide additional information', 'thesis'); ?>"><span class="pos">+</span><span class="neg">&#8211;</span></a><?php _e('Comments', 'thesis'); ?></h4>
					<div class="more_info">
						<ul class="add_margin">
							<li><input type="checkbox" id="display[comments][numbers]" name="display[comments][numbers]" value="1" <?php if ($display['comments']['numbers']) echo 'checked="checked" '; ?>/><label for="display[comments][numbers]"><?php _e('Show comment numbers', 'thesis'); ?></label></li>
							<li><input type="checkbox" id="display[comments][allowed_tags]" name="display[comments][allowed_tags]" value="1" <?php if ($display['comments']['allowed_tags']) echo 'checked="checked" '; ?>/><label for="display[comments][allowed_tags]"><?php _e('Show list of allowed <abbr title="Hypertext Markup Language">HTML</abbr> tags', 'thesis'); ?></label></li>
						</ul>
						<p class="label_note"><?php _e('Pages', 'thesis'); ?></p>
						<ul class="add_margin">
							<li><input type="checkbox" id="display[comments][disable_pages]" name="display[comments][disable_pages]" value="1" <?php if ($display['comments']['disable_pages']) echo 'checked="checked" '; ?>/><label for="display[comments][disable_pages]"><?php _e('Disable comments on all <strong>pages</strong>', 'thesis'); ?></label></li>
						</ul>
						<p><?php printf(__('You can modify your avatar settings <a href="%1$s">here</a>, and you can change the size of your avatar below.', 'thesis'), get_bloginfo('wpurl') . '/wp-admin/options-discussion.php'); ?></p>
						<p class="form_input">
							<input type="text" class="text_input" id="display[comments][avatar_size]" name="display[comments][avatar_size]" value="<?php echo $display['comments']['avatar_size']; ?>" />
							<label for="display[comments][avatar_size]"><?php _e('Set your avatar size (between 1 and 96 px)', 'thesis'); ?></label>
						</p>
					</div>
				</div>
				<div class="module_subsection">
					<h4><a href="" title="<?php _e('Show/hide additional information', 'thesis'); ?>"><span class="pos">+</span><span class="neg">&#8211;</span></a><?php _e('Sidebars', 'thesis'); ?></h4>
					<ul class="more_info">
						<li><input type="checkbox" id="display[sidebars][default_widgets]" name="display[sidebars][default_widgets]" value="1" <?php if ($display['sidebars']['default_widgets']) echo 'checked="checked" '; ?>/><label for="display[sidebars][default_widgets]"><?php _e('Show default sidebar widgets', 'thesis'); ?></label></li>
					</ul>
				</div>
				<div class="module_subsection">
					<h4><a href="" title="<?php _e('Show/hide additional information', 'thesis'); ?>"><span class="pos">+</span><span class="neg">&#8211;</span></a><?php _e('Administration', 'thesis'); ?></h4>
					<div class="more_info">
						<ul class="add_margin">
							<li><input type="checkbox" id="display[admin][edit_post]" name="display[admin][edit_post]" value="1" <?php if ($display['admin']['edit_post']) echo 'checked="checked" '; ?>/><label for="display[admin][edit_post]"><?php _e('Show edit post links', 'thesis'); ?></label></li>
							<li><input type="checkbox" id="display[admin][edit_comment]" name="display[admin][edit_comment]" value="1" <?php if ($display['admin']['edit_comment']) echo 'checked="checked" '; ?>/><label for="display[admin][edit_comment]"><?php _e('Show edit comment links', 'thesis'); ?></label></li>
						</ul>
						<p class="label_note"><?php _e('WordPress admin panel link (in footer)', 'thesis'); ?></p>
						<ul>
							<li><input type="checkbox" id="display[admin][link]" name="display[admin][link]" value="1" <?php if ($display['admin']['link']) echo 'checked="checked" '; ?>/><label><?php _e('Show admin link in footer', 'thesis'); ?></label></li>
						</ul>
					</div>
				</div>
			</div>
		</div>
		
		<div class="options_column">
			<div class="options_module" id="thesis-nav-menu">
				<h3><?php _e('Navigation Menu', 'thesis'); ?></h3>
				<div class="module_subsection">
					<h4><a href="" title="<?php _e('Show/hide additional information', 'thesis'); ?>"><span class="pos">+</span><span class="neg">&#8211;</span></a><?php _e('Select pages to include in nav menu:', 'thesis') ?></h4>
					<div class="more_info">
						<p><?php _e('Start by selecting the pages you want to include in your nav menu. Next, drag and drop the pages to change their display order (topmost item displays first), and if you <em>really</em> want to get crazy, you can even edit the display text on each item. <strong>Try it!</strong>', 'thesis'); ?></p>
						<p><?php _e('<strong class="new">New!</strong> Thesis now features automatic dropdown menus, so if you have nested pages or categories, you&#8217;ll save space <em>and</em> gain style points with your slick new nav menu!', 'thesis'); ?></p>
						<ul id="nav_pages" class="sortable add_margin">
<?php
					$pages = &get_pages('sort_column=post_parent,menu_order');
					$active_pages = array();

					if ($nav['pages']) {
						foreach ($nav['pages'] as $id => $nav_page) {
							$active_page = get_page($id);
							if (post_exists($active_page->post_title)) {
								$checked = ($nav_page['show']) ? ' checked="checked"' : '';
								$link_text = ($nav['pages'][$id]['text'] != '') ? $nav['pages'][$id]['text'] : $active_page->post_title;
								echo '<li><input class="checkbox" type="checkbox" id="nav[pages][' . $id . '][show]" name="nav[pages][' . $id . '][show]" value="1"' . $checked . ' /><input type="text" class="text_input" id="nav[pages][' . $id . '][text]" name="nav[pages][' . $id . '][text]" value="' . $link_text . '" /></li>' . "\n";
								$active_pages[] = $id;
							}
						}
					}
					if ($pages) {
						foreach ($pages as $page) {
							if (!in_array($page->ID, $active_pages)) {
								$link_text = ($nav['pages'][$page->ID]['text'] != '') ? $nav['pages'][$page->ID]['text'] : $page->post_title;
								echo '<li><input class="checkbox" type="checkbox" id="nav[pages][' . $page->ID . '][show]" name="nav[pages][' . $page->ID . '][show]" value="1" /><input type="text" class="text_input" id="nav[pages][' . $page->ID . '][text]" name="nav[pages][' . $page->ID . '][text]" value="' . $link_text . '" /></li>' . "\n";
							}
						}
					}

?>
						</ul>
					</div>
				</div>
				<div class="module_subsection">
					<h4><a href="" title="<?php _e('Show/hide additional information', 'thesis'); ?>"><span class="pos">+</span><span class="neg">&#8211;</span></a><?php _e('Include these category pages in nav menu:', 'thesis') ?></h4>
					<div class="more_info">
						<p><?php _e('If you&#8217;d like to include category archive pages in your nav menu, simply select the appropriate categories from the list below (you can select more than one).', 'thesis'); ?></p>
						<p class="form_input">
							<select class="select_multiple" id="nav[categories]" name="nav[categories][]" multiple="multiple" size="1">
								<option value="0"><?php _e('No category page links', 'thesis'); ?></option>
<?php
					$categories = &get_categories('type=post&orderby=name&hide_empty=0');

					if ($categories) {
						$nav_category_pages = explode(',', $nav['categories']);

						foreach ($categories as $category) {
							$selected = (in_array($category->cat_ID, $nav_category_pages)) ? ' selected="selected"' : '';
							echo '<option value="' . $category->cat_ID . '"' . $selected . '>' . $category->cat_name . '</option>' . "\n";
						}
					}
?>
							</select>
						</p>
					</div>
				</div>
				<div class="module_subsection">
					<h4><a href="" title="<?php _e('Show/hide additional information', 'thesis'); ?>"><span class="pos">+</span><span class="neg">&#8211;</span></a><?php _e('Add More Links', 'thesis'); ?></h4>
					<div class="more_info">
						<p><?php _e('You can insert additional navigation links on the <a href="' . get_bloginfo('wpurl') . '/wp-admin/link-manager.php">Manage Links</a> page. To ensure that things go smoothly, you should first <a href="' . get_bloginfo('wpurl') . '/wp-admin/edit-link-categories.php#addcat">create a link category</a> solely for your navigation menu, and then make sure you place your new links in that category. Once you&#8217;ve done that, you can select your category below to include it in your nav menu.', 'thesis'); ?></p>
						<p class="form_input">
							<select id="nav[links]" name="nav[links]" size="1">
								<option value="0"><?php _e('No additional links', 'thesis'); ?></option>
<?php
					$link_categories = &get_categories('type=link&hide_empty=0');
					
					if ($link_categories) {
						foreach ($link_categories as $link_category) {
							$selected = ($nav['links'] == $link_category->cat_ID) ? ' selected="selected"' : '';
							echo '<option value="' . $link_category->cat_ID . '"' . $selected . '>' . $link_category->cat_name . '</option>' . "\n";
						}
					}
?>
							</select>
						</p>
					</div>
				</div>
				<div class="module_subsection">
					<h4><a href="" title="<?php _e('Show/hide additional information', 'thesis'); ?>"><span class="pos">+</span><span class="neg">&#8211;</span></a><?php _e('Home Link', 'thesis'); ?></h4>
					<div class="control_box more_info">
						<ul class="control">
							<li><input type="checkbox" id="nav[home][show]" name="nav[home][show]" value="1" <?php if ($nav['home']['show']) echo 'checked="checked" '; ?>/><label for="nav[home][show]"><?php _e('Show home link in nav menu', 'thesis'); ?></label></li>
						</ul>
						<div class="dependent">
							<p class="form_input add_margin">
								<input type="text" id="nav[home][text]" name="nav[home][text]" value="<?php echo thesis_home_link_text(); ?>" />
								<label for="nav[home][text]"><?php _e('home link text', 'thesis'); ?></label>
							</p>
							<ul>
								<li><input type="checkbox" id="nav[home][nofollow]" name="nav[home][nofollow]" value="1" <?php if ($nav['home']['nofollow']) echo 'checked="checked" '; ?>/><label for="nav[home][nofollow]"><?php _e('Add <code>nofollow</code> to home link', 'thesis'); ?></label></li>
							</ul>
						</div>
					</div>
				</div>
				<div class="module_subsection">
					<h4><a href="" title="<?php _e('Show/hide additional information', 'thesis'); ?>"><span class="pos">+</span><span class="neg">&#8211;</span></a><?php _e('Feed Link in Nav Menu', 'thesis'); ?></h4>
					<div class="control_box more_info">
						<ul class="control">
							<li><input type="checkbox" id="nav[feed][show]" name="nav[feed][show]" value="1" <?php if ($nav['feed']['show']) echo 'checked="checked" '; ?>/><label for="nav[feed][show]"><?php _e('Show feed link in nav menu', 'thesis'); ?></label></li>
						</ul>
						<div class="dependent">
							<p class="form_input add_margin">
								<input type="text" class="text_input" id="nav[feed][text]" name="nav[feed][text]" value="<?php echo thesis_feed_link_text(); ?>" />
								<label for="nav[feed][text]"><?php _e('Change your feed link text', 'thesis'); ?></label>
							</p>
							<ul>
								<li><input type="checkbox" id="nav[feed][nofollow]" name="nav[feed][nofollow]" value="1" <?php if ($nav['feed']['nofollow']) echo 'checked="checked" '; ?>/><label for="nav[feed][nofollow]"><?php _e('Add <code>nofollow</code> to feed link', 'thesis'); ?></label></li>
							</ul>
						</div>
					</div>
				</div>
			</div>
			<div class="options_module" id="post-image-options">
				<h3><?php _e('Post Images and Thumbnails', 'thesis'); ?></h3>
				<div class="module_subsection" id="post-images">
					<h4><a href="" title="<?php _e('Show/hide additional information', 'thesis'); ?>"><span class="pos">+</span><span class="neg">&#8211;</span></a><?php _e('Default Post Image Settings', 'thesis'); ?></h4>
					<div class="more_info">
						<p><?php _e('Post images are a perfect way to add more visual punch to your site. To use them, simply specify a post image in the appropriate field on the post editing screen. During the normal stream of content, post images will display full-size, and by default, they will be automatically cropped into smaller thumbnail images for use in other areas (like teasers and excerpts).', 'thesis'); ?></p>
						<p><?php _e('Don&#8217;t want Thesis to auto-crop your thumbnails? No worries&#8212;you can override this by uploading your own thumbnail image on <em>any</em> post or page. Also, it&#8217;s worth noting that you can override <em>all</em> of the settings below on the post editing screen.', 'thesis'); ?></p>
						<p class="label_note"><?php _e('Horizontal position', 'thesis'); ?></p>
						<ul class="add_margin">
							<li><input type="radio" name="image[post][x]" value="flush" <?php if ($image['post']['x'] == 'flush') echo 'checked="checked" '; ?>/><label><?php _e('Flush left with no text wrap', 'thesis'); ?></label></li>
							<li><input type="radio" name="image[post][x]" value="left" <?php if ($image['post']['x'] == 'left') echo 'checked="checked" '; ?>/><label><?php _e('Left with text wrap', 'thesis'); ?></label></li>
							<li><input type="radio" name="image[post][x]" value="right" <?php if ($image['post']['x'] == 'right') echo 'checked="checked" '; ?>/><label><?php _e('Right with text wrap', 'thesis'); ?></label></li>
							<li><input type="radio" name="image[post][x]" value="center" <?php if ($image['post']['x'] == 'center') echo 'checked="checked" '; ?>/><label><?php _e('Centered (no wrap)', 'thesis'); ?></label></li>
						</ul>
						<p class="label_note"><?php _e('Vertical position', 'thesis'); ?></p>
						<ul class="add_margin">
							<li><input type="radio" name="image[post][y]" value="before-headline" <?php if ($image['post']['y'] == 'before-headline') echo 'checked="checked" '; ?>/><label><?php _e('Above headline', 'thesis'); ?></label></li>
							<li><input type="radio" name="image[post][y]" value="after-headline" <?php if ($image['post']['y'] == 'after-headline') echo 'checked="checked" '; ?>/><label><?php _e('Below headline', 'thesis'); ?></label></li>
							<li><input type="radio" name="image[post][y]" value="before-post" <?php if ($image['post']['y'] == 'before-post') echo 'checked="checked" '; ?>/><label><?php _e('Before post/page content', 'thesis'); ?></label></li>
						</ul>
						<ul>
							<li><input type="checkbox" id="image[post][frame]" name="image[post][frame]" value="1" <?php if ($image['post']['frame'] == 'on') echo 'checked="checked" '; ?>/><label for="image[post][frame]"><?php _e('Add a frame to post images', 'thesis'); ?></label></li>
							<li><input type="checkbox" id="image[post][single]" name="image[post][single]" value="1" <?php if ($image['post']['single']) echo 'checked="checked" '; ?>/><label for="image[post][single]"><?php _e('Show images on single entry pages', 'thesis'); ?></label></li>
							<li><input type="checkbox" id="image[post][archives]" name="image[post][archives]" value="1" <?php if ($image['post']['archives']) echo 'checked="checked" '; ?>/><label for="image[post][archives]"><?php _e('Show images on archives pages', 'thesis'); ?></label></li>
						</ul>
					</div>
				</div>
				<div class="module_subsection" id="thumbnail-images">
					<h4><a href="" title="<?php _e('Show/hide additional information', 'thesis'); ?>"><span class="pos">+</span><span class="neg">&#8211;</span></a><?php _e('Default Thumbnail Settings', 'thesis'); ?></h4>
					<div class="more_info">
						<p class="label_note"><?php _e('Horizontal position', 'thesis'); ?></p>
						<ul class="add_margin">
							<li><input type="radio" name="image[thumb][x]" value="flush" <?php if ($image['thumb']['x'] == 'flush') echo 'checked="checked" '; ?>/><label><?php _e('Flush left with no text wrap', 'thesis'); ?></label></li>
							<li><input type="radio" name="image[thumb][x]" value="left" <?php if ($image['thumb']['x'] == 'left') echo 'checked="checked" '; ?>/><label><?php _e('Left with text wrap', 'thesis'); ?></label></li>
							<li><input type="radio" name="image[thumb][x]" value="right" <?php if ($image['thumb']['x'] == 'right') echo 'checked="checked" '; ?>/><label><?php _e('Right with text wrap', 'thesis'); ?></label></li>
							<li><input type="radio" name="image[thumb][x]" value="center" <?php if ($image['thumb']['x'] == 'center') echo 'checked="checked" '; ?>/><label><?php _e('Centered (no wrap)', 'thesis'); ?></label></li>
						</ul>
						<p class="label_note"><?php _e('Vertical position', 'thesis'); ?></p>
						<ul class="add_margin">
							<li><input type="radio" name="image[thumb][y]" value="before-headline" <?php if ($image['thumb']['y'] == 'before-headline') echo 'checked="checked" '; ?>/><label><?php _e('Above headline', 'thesis'); ?></label></li>
							<li><input type="radio" name="image[thumb][y]" value="after-headline" <?php if ($image['thumb']['y'] == 'after-headline') echo 'checked="checked" '; ?>/><label><?php _e('Below headline', 'thesis'); ?></label></li>
							<li><input type="radio" name="image[thumb][y]" value="before-post" <?php if ($image['thumb']['y'] == 'before-post') echo 'checked="checked" '; ?>/><label><?php _e('Before post/page content', 'thesis'); ?></label></li>
						</ul>
						<ul class="add_margin">
							<li><input type="checkbox" id="image[thumb][frame]" name="image[thumb][frame]" value="1" <?php if ($image['thumb']['frame'] == 'on') echo 'checked="checked" '; ?>/><label for="image[thumb][frame]"><?php _e('Add a frame to thumbnail images', 'thesis'); ?></label></li>
						</ul>
						<p><?php _e('If you do not supply a thumbnail image on a particular post (in addition to or in place of a post image), the post image that you upload will be auto-cropped to these dimensions and re-saved for use as a thumbnail:', 'thesis'); ?></p>
						<p class="form_input add_margin">
							<input type="text" class="short" id="image[thumb][width]" name="image[thumb][width]" value="<?php if ($image['thumb']['width']) echo $image['thumb']['width']; ?>" />
							<label for="image[thumb][width]" class="inline"><?php _e('default thumbnail width', 'thesis'); ?></label>
						</p>
						<p class="form_input">
							<input type="text" class="short" id="image[thumb][height]" name="image[thumb][height]" value="<?php if ($image['thumb']['height']) echo $image['thumb']['height']; ?>" />
							<label for="image[thumb][height]" class="inline"><?php _e('default thumbnail height', 'thesis'); ?></label>
						</p>
					</div>
				</div>
			</div>
			<div class="options_module button_module">
				<input type="submit" class="save_button" id="options_submit" name="submit" value="<?php thesis_save_button_text(true); ?>" />
			</div>
			<div class="options_module" id="save_button_control">
				<div class="module_subsection">
					<h4><a href="" title="<?php _e('Show/hide additional information', 'thesis'); ?>"><span class="pos">+</span><span class="neg">&#8211;</span></a><?php _e('Change Save Button Text', 'thesis'); ?></h4>
					<p class="form_input more_info">
						<input type="text" id="save_button_text" name="save_button_text" value="<?php if ($thesis['save_button_text']) thesis_save_button_text(true); ?>" />
						<label for="save_button_text"><?php _e('not recommended (heh)', 'thesis'); ?></label>
					</p>
				</div>
			</div>
		</div>
	</form>
<?php
	}
?>
</div>