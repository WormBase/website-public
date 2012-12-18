<?php
/**
 * Outputs the HTML for the Design Options page.
 *
 * @package Thesis-Admin
 */
?>

<div id="thesis_options" class="wrap<?php if (get_bloginfo('text_direction') == 'rtl') { echo ' rtl'; } ?>">
	<span id="thesis_version"><?php printf(__('You are rocking Thesis version <strong>%s</strong>', 'thesis'), thesis_version()); ?></span>
	<h2><?php _e('Thesis Design Options', 'thesis'); ?> <a id="master_switch" href="" title="<?php _e('Big Ass Toggle Switch', 'thesis'); ?>"><span class="pos">+</span><span class="neg">&#8211;</span></a></h2>
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
	
	// Grab arrays needed to crank out the Design Options
	global $thesis;
	global $thesis_design;
	
	$font_stacks = thesis_get_fonts();
	$fonts = $thesis_design['fonts'];
	$colors = $thesis_design['colors'];
	$borders = $thesis_design['borders'];
	$nav = $thesis_design['nav'];
	$style = $thesis_design['style'];
	$layout = $thesis_design['layout'];
	$teasers = $thesis_design['teasers'];
	$feature_box = $thesis_design['feature_box'];
	$multimedia_box = $thesis_design['multimedia_box'];
	
	if (version_compare($thesis['version'], thesis_version()) != 0 || (!isset($nav['link']['parent']))) {
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

	<form class="thesis" action="<?php echo admin_url('admin-post.php?action=thesis_design_options'); ?>" method="post">
		<div class="options_column">
			<div class="options_module" id="font-selector">
				<h3><?php _e('Fonts, Colors, and More!', 'thesis'); ?></h3>
				<div class="module_subsection">
					<h4><a href="" title="<?php _e('Show/hide additional information', 'thesis'); ?>"><span class="pos">+</span><span class="neg">&#8211;</span></a><?php _e('Body (and Content Area)', 'thesis'); ?></h4>
					<div class="more_info">
						<p><?php _e('The font you select here will be the main font on your site. You can tweak individual fonts and sizes below.', 'thesis'); ?></p>
						<p class="form_input add_margin">
							<select id="fonts[families][body]" name="fonts[families][body]" size="1">
<?php
						foreach ($font_stacks as $font_key => $font) {
							$selected = ($fonts['families']['body'] == $font_key) ? ' selected="selected"' : '';
							$web_safe = ($font['web_safe']) ? ' *' : '';
							echo "<option" . $selected . " value=\"" . $font_key . "\">" . $font['name'] . $web_safe . "</option>\n";	
						}
?>
							</select>
						</p>
						<p class="tip add_margin"><?php _e('Asterisks (*) denote web-safe fonts.', 'thesis'); ?></p>
						<p><?php _e('<strong class="new">New!</strong> Add some personal flair to your design by using the controls below. This is only a taste of what you can expect in Thesis 2.0, but it should give you a nice start nonetheless. Also, don&#8217;t miss the new color controls that you&#8217;ll find in the other options below!', 'thesis'); ?></p>
						<p class="form_input add_margin">
							<input class="short color" type="text" id="colors[background]" name="colors[background]" value="<?php echo $colors['background']; ?>" maxlength="6" />
							<label class="inline" for="colors[background]"><?php _e('site background color', 'thesis'); ?></label>
						</p>
						<p class="form_input add_margin">
							<input class="short color" type="text" id="colors[page]" name="colors[page]" value="<?php echo $colors['page']; ?>" maxlength="6" />
							<label class="inline" for="colors[page]"><?php _e('page background color', 'thesis'); ?></label>
						</p>
						<p class="form_input add_margin">
							<input class="short color" type="text" id="colors[text]" name="colors[text]" value="<?php echo $colors['text']; ?>" maxlength="6" />
							<label class="inline" for="colors[text]"><?php _e('primary text color', 'thesis'); ?></label>
						</p>
						<p class="form_input add_margin">
							<input class="short color" type="text" id="colors[link]" name="colors[link]" value="<?php echo $colors['link']; ?>" maxlength="6" />
							<label class="inline" for="colors[link]"><?php _e('primary link color', 'thesis'); ?></label>
						</p>
						<p>
						<ul>
							<li><input type="checkbox" id="colors[shadow]" name="colors[shadow]" value="1" <?php if ($colors['shadow']) echo 'checked="checked" '; ?>/><label for="colors[shadow]"><?php _e('Add a cool shadow effect to your layout', 'thesis'); ?></label></li>
							<li><input type="checkbox" id="borders[show]" name="borders[show]" value="1" <?php if ($borders['show']) echo 'checked="checked" '; ?>/><label for="borders[show]"><?php _e('Show interior layout borders', 'thesis'); ?></label></li>
						</ul>
					</div>
				</div>
<?php
			$layout_areas = thesis_layout_areas();
				
			foreach ($layout_areas as $area_key => $area) {
?>
				<div class="module_subsection">
					<h4><a href="" title="<?php _e('Show/hide additional information', 'thesis'); ?>"><span class="pos">+</span><span class="neg">&#8211;</span></a><?php echo $area['name']; ?></h4>
					<div class="more_info">
						<p><?php echo $area['intro_text']; ?></p>
<?php
				if ($area['define_font']) {
?>
						<p class="form_input add_margin">
							<select id="fonts[families][<?php echo $area_key; ?>]" name="fonts[families][<?php echo $area_key; ?>]" size="1">
<?php
						$selected = (!$fonts['families'][$area_key]) ? ' selected="selected"' : '';
						echo "<option" . $selected . " value=\"\">Inherited from Body</option>\n";
						
						foreach ($font_stacks as $font_key => $font) {
							$selected = ($fonts['families'][$area_key] == $font_key) ? ' selected="selected"' : '';
							$web_safe = ($font['web_safe']) ? ' *' : '';
							
							if ($area_key == 'code') {
								if ($font['monospace'])
									echo "<option" . $selected . " value=\"" . $font_key . "\">" . $font['name'] . $web_safe . "</option>\n";
							}
							else
								echo "<option" . $selected . " value=\"" . $font_key . "\">" . $font['name'] . $web_safe . "</option>\n";
						}
?>
							</select>
						</p>
<?php
				}
?>
						<p class="form_input add_margin">
							<select id="fonts[sizes][<?php echo $area_key; ?>]" name="fonts[sizes][<?php echo $area_key; ?>]" size="1">
<?php
						foreach ($area['font_sizes'] as $size) {
							$selected = ($fonts['sizes'][$area_key] == $size) ? ' selected="selected"' : '';
							echo "<option" . $selected . " value=\"" . $size . "\">" . $size . " pt." . "</option>\n";
						}
?>
							</select>
						</p>
<?php
				$has_secondary = ($area['secondary_font']) ? ' add_margin' : '';

				if ($area_key != 'content' && $area_key != 'nav_menu' && $area_key != 'multimedia_box')
					echo '<p class="form_input' . $has_secondary . '">' . "\n\t" . '<input class="short color" type="text" id="colors[' . $area_key . ']" name="colors[' . $area_key . ']" value="' . $colors[$area_key] . '" />' . "\n\t" . '<label class="inline" for="colors[' . $area_key . ']">' . $area['name'] . ' ' . __('text color', 'thesis') . '</label>' . "\n" . '</p>' . "\n";

				if ($area_key == 'nav_menu') {
?>
						<p class="form_input add_margin">
							<input class="short color" type="text" id="nav[link][color]" name="nav[link][color]" value="<?php echo $nav['link']['color']; ?>" maxlength="6" />
							<label class="inline" for="nav[link][color]">link text color</label>
						</p>
						<p class="form_input add_margin">
							<input class="short color" type="text" id="nav[link][hover]" name="nav[link][hover]" value="<?php echo $nav['link']['hover']; ?>" maxlength="6" />
							<label class="inline" for="nav[link][hover]">link text hover color</label>
						</p>
						<p class="form_input add_margin">
							<input class="short color" type="text" id="nav[link][current]" name="nav[link][current]" value="<?php echo $nav['link']['current']; ?>" maxlength="6" />
							<label class="inline" for="nav[link][current]">current link text color</label>
						</p>
						<p class="form_input add_margin">
							<input class="short color" type="text" id="nav[link][parent]" name="nav[link][parent]" value="<?php echo $nav['link']['parent']; ?>" maxlength="6" />
							<label class="inline" for="nav[link][parent]">current parent link text color</label>
						</p>
						<p class="form_input add_margin">
							<input class="short color" type="text" id="nav[background][link]" name="nav[background][link]" value="<?php echo $nav['background']['link']; ?>" maxlength="6" />
							<label class="inline" for="nav[background][link]">link background color</label>
						</p>
						<p class="form_input add_margin">
							<input class="short color" type="text" id="nav[background][hover]" name="nav[background][hover]" value="<?php echo $nav['background']['hover']; ?>" maxlength="6" />
							<label class="inline" for="nav[background][hover]">hover background color</label>
						</p>
						<p class="form_input add_margin">
							<input class="short color" type="text" id="nav[background][current]" name="nav[background][current]" value="<?php echo $nav['background']['current']; ?>" maxlength="6" />
							<label class="inline" for="nav[background][current]">current background color</label>
						</p>
						<p class="form_input add_margin">
							<input class="short color" type="text" id="nav[background][parent]" name="nav[background][parent]" value="<?php echo $nav['background']['parent']; ?>" maxlength="6" />
							<label class="inline" for="nav[background][parent]">current parent background color</label>
						</p>
						<p class="form_input add_margin">
							<input class="short" type="text" id="nav[border][width]" name="nav[border][width]" value="<?php echo $nav['border']['width']; ?>" />
							<label class="inline" for="nav[border][width]"><?php _e('nav border width (px)', 'thesis'); ?></label>
						</p>
						<p class="form_input add_margin">
							<input class="short color" type="text" id="nav[border][color]" name="nav[border][color]" value="<?php echo $nav['border']['color']; ?>" maxlength="6" />
							<label class="inline" for="nav[border][color]">nav border color</label>
						</p>
						<p class="form_input">
							<input class="short" type="text" id="nav[submenu_width]" name="nav[submenu_width]" value="<?php echo $nav['submenu_width']; ?>" />
							<label class="inline" for="nav[submenu_width]"><?php _e('submenu width (px)', 'thesis'); ?></label>
						</p>
<?php
				}
				elseif ($area_key == 'multimedia_box') {
?>
						<p class="form_input add_margin">
							<input class="short color" type="text" id="multimedia_box[color]" name="multimedia_box[color]" value="<?php echo $multimedia_box['color']; ?>" maxlength="6" />
							<label class="inline" for="multimedia_box[color]">text color</label>
						</p>
						<p class="form_input add_margin">
							<input class="short color" type="text" id="multimedia_box[background][image]" name="multimedia_box[background][image]" value="<?php echo $multimedia_box['background']['image']; ?>" maxlength="6" />
							<label class="inline" for="multimedia_box[background][image]">image box background color</label>
						</p>
						<p class="form_input add_margin">
							<input class="short color" type="text" id="multimedia_box[background][video]" name="multimedia_box[background][video]" value="<?php echo $multimedia_box['background']['video']; ?>" maxlength="6" />
							<label class="inline" for="multimedia_box[background][video]">video box background color</label>
						</p>
						<p class="form_input">
							<input class="short color" type="text" id="multimedia_box[background][code]" name="multimedia_box[background][code]" value="<?php echo $multimedia_box['background']['code']; ?>" maxlength="6" />
							<label class="inline" for="multimedia_box[background][code]">custom box background color</label>
						</p>
<?php	
				}

				if ($area['secondary_font']) {
?>
						<p class="label_note"><?php echo $area['secondary_font']['item_name']; ?></p>
						<p><?php echo $area['secondary_font']['item_intro']; ?></p>
						<p class="form_input add_margin">
							<select id="fonts[families][<?php echo $area['secondary_font']['item_reference']; ?>]" name="fonts[families][<?php echo $area['secondary_font']['item_reference']; ?>]" size="1">
<?php
						$selected = (!$fonts['families'][$area['secondary_font']['item_reference']]) ? ' selected="selected"' : '';
						echo "<option" . $selected . " value=\"\">Inherited from " . $area['name'] . "</option>\n";

						foreach ($font_stacks as $font_key => $font) {
							$selected = ($fonts['families'][$area['secondary_font']['item_reference']] == $font_key) ? ' selected="selected"' : '';
							$web_safe = ($font['web_safe']) ? ' *' : '';

							echo "<option" . $selected . " value=\"" . $font_key . "\">" . $font['name'] . $web_safe . "</option>\n";
						}
?>
							</select>
						</p>
<?php
					if ($area['secondary_font']['item_sizes']) {
?>
						<p class="form_input add_margin">
							<select id="fonts[sizes][<?php echo $area['secondary_font']['item_reference']; ?>]" name="fonts[sizes][<?php echo $area['secondary_font']['item_reference']; ?>]" size="1">
<?php
						foreach ($area['secondary_font']['item_sizes'] as $size) {
							$selected = ($fonts['sizes'][$area['secondary_font']['item_reference']] == $size) ? ' selected="selected"' : '';
							echo "<option" . $selected . " value=\"" . $size . "\">" . $size . " pt." . "</option>\n";
						}
?>
							</select>
						</p>
<?php
					}
					
					echo '<p class="form_input">' . "\n\t" . '<input class="short color" type="text" id="colors[' . $area['secondary_font']['item_reference'] . ']" name="colors[' . $area['secondary_font']['item_reference'] . ']" value="' . $colors[$area['secondary_font']['item_reference']] . '" />' . "\n\t" . '<label class="inline" for="colors[' . $area['secondary_font']['item_reference'] . ']">' . $area['secondary_font']['item_name'] . ' ' . __('text color', 'thesis') . '</label>' . "\n" . '</p>' . "\n";
				}
?>
					</div>
				</div>
<?php
			}
?>
			</div>
		</div>
		
		<div class="options_column">
			<div class="options_module" id="layout-constructor">
				<h3><?php _e('Site Layout', 'thesis'); ?></h3>
				<div class="module_subsection">
					<h4><a href="" title="<?php _e('Show/hide additional information', 'thesis'); ?>"><span class="pos">+</span><span class="neg">&#8211;</span></a><?php _e('Columns', 'thesis'); ?></h4>
					<div class="more_info">
						<p><?php _e('Select the number of columns you want in your layout:', 'thesis'); ?></p>
						<p class="form_input add_margin" id="num_columns">
							<select id="layout[columns]" name="layout[columns]" size="1">
								<option value="3"<?php if ($layout['columns'] == 3) echo ' selected="selected"'; ?>><?php _e('3 columns', 'thesis'); ?></option>
								<option value="2"<?php if ($layout['columns'] == 2) echo ' selected="selected"'; ?>><?php _e('2 columns', 'thesis'); ?></option>
								<option value="1"<?php if ($layout['columns'] == 1) echo ' selected="selected"'; ?>><?php _e('1 column', 'thesis'); ?></option>
							</select>
						</p>
						<p><?php _e('Enter a width between 300 and 934 pixels for your <strong>content column</strong>:', 'thesis'); ?></p>
						<p id="width_content" class="form_input">
							<input type="text" class="short" id="layout[widths][content]" name="layout[widths][content]" value="<?php echo $layout['widths']['content']; ?>" />
							<label for="layout[widths][content]" class="inline"><?php _e('px', 'thesis'); ?></label>
						</p>
						<div id="width_sidebar_1">
							<p><?php _e('Enter a width between 60 and 500 pixels for <strong>sidebar 1</strong>:', 'thesis'); ?></p>
							<p class="form_input add_margin">
								<input type="text" class="short" id="layout[widths][sidebar_1]" name="layout[widths][sidebar_1]" value="<?php echo $layout['widths']['sidebar_1']; ?>" />
								<label for="layout[widths][sidebars_1]" class="inline"><?php _e('px (default is 195)', 'thesis'); ?></label>
							</p>
						</div>
						<div id="width_sidebar_2">
							<p><?php _e('Enter a width between 60 and 500 pixels for <strong>sidebar 2</strong>:', 'thesis'); ?></p>
							<p class="form_input add_margin">
								<input type="text" class="short" id="layout[widths][sidebar_2]" name="layout[widths][sidebar_2]" value="<?php echo $layout['widths']['sidebar_2']; ?>" />
								<label for="layout[widths][sidebar_2]" class="inline"><?php _e('px (default is 195)', 'thesis'); ?></label>
							</p>
						</div>
					</div>
				</div>
				<div class="module_subsection" id="column_order">
					<h4><a href="" title="<?php _e('Show/hide additional information', 'thesis'); ?>"><span class="pos">+</span><span class="neg">&#8211;</span></a><?php _e('Column Order', 'thesis'); ?></h4>
					<div class="more_info">
						<ul class="column_structure" id="order_3_col">
							<li>
								<input type="radio" name="layout[order]" value="normal" <?php if ($layout['order'] == 'normal' && $layout['columns'] == 3) echo 'checked="checked" '; ?>/><label><?php _e('Content, Sidebar 1, Sidebar 2 <span>&darr;</span>', 'thesis'); ?></label>
								<p><span class="col_content">Content</span><span class="col_sidebar">S1</span><span class="col_sidebar no_margin">S2</span></p>
							</li>
							<li>
								<input type="radio" name="layout[order]" value="invert" <?php if ($layout['order'] == 'invert') echo 'checked="checked" '; ?>/><label><?php _e('Sidebar 1, Content, Sidebar 2 <span>&darr;</span>', 'thesis'); ?></label>
								<p><span class="col_sidebar">S1</span><span class="col_content">Content</span><span class="col_sidebar no_margin">S2</span></p>
							</li>
							<li>
								<input type="radio" name="layout[order]" value="0" <?php if (!$layout['order'] && $layout['columns'] == 3) echo 'checked="checked" '; ?>/><label><?php _e('Sidebar 1, Sidebar 2, Content <span>&darr;</span>', 'thesis'); ?></label>
								<p><span class="col_sidebar">S1</span><span class="col_sidebar">S2</span><span class="col_content no_margin">Content</span></p>
							</li>
						</ul>
						<ul class="column_structure" id="order_2_col">
							<li>
								<input type="radio" name="layout[order]" value="normal" <?php if ($layout['order'] == 'normal' && $layout['columns'] == 2) echo 'checked="checked" '; ?>/><label><?php _e('Content, Sidebar 1 <span>&darr;</span>', 'thesis'); ?></label>
								<p><span class="col_content">Content</span><span class="col_sidebar">S1</span></p>
							</li>
							<li>
								<input type="radio" name="layout[order]" value="0" <?php if (!$layout['order'] && $layout['columns'] == 2) echo 'checked="checked" '; ?>/><label><?php _e('Sidebar 1, Content <span>&darr;</span>', 'thesis'); ?></label>
								<p><span class="col_sidebar">S1</span><span class="col_content no_margin">Content</span></p>
							</li>
						</ul>
					</div>
				</div>
			</div>
			<div class="options_module" id="teaser-options">
				<h3><?php _e('Teasers', 'thesis'); ?></h3>
				<div class="module_subsection">
					<h4><a href="" title="<?php _e('Show/hide additional information', 'thesis'); ?>"><span class="pos">+</span><span class="neg">&#8211;</span></a><?php _e('Teaser Display Options'); ?></h4>
					<div class="more_info">
						<p><?php _e('Pick and choose what you want your teasers to display! Drag and drop the elements to change the order in which they appear on your site.', 'thesis'); ?></p>
						<ul id="teaser_content" class="sortable">
<?php
						foreach ($teasers['options'] as $teaser_item => $teaser) {
							$checked = ($teaser['show']) ? ' checked="checked"' : '';

							if ($teaser_item == 'date')
								$id = 'teasers_date_show';
							elseif ($teaser_item == 'link')
								$id = 'teasers_link_show';
							else
								$id = 'teasers[options][' . $teaser_item . '][show]';

							echo '								<li><input type="checkbox" class="checkbox" id="' . $id . '" name="teasers[options][' . $teaser_item . '][show]" value="1"' . $checked . ' /> ' . $teaser['name'] . '<input type="hidden" name="teasers[options][' . $teaser_item . '][name]" value="' . $teaser['name'] . '" /></li>' . "\n";
						}
?>
						</ul>
					</div>
				</div>
				<div class="module_subsection" id="teaser_date_format">
					<h4><a href="" title="<?php _e('Show/hide additional information', 'thesis'); ?>"><span class="pos">+</span><span class="neg">&#8211;</span></a><?php _e('Teaser Date Format', 'thesis'); ?></h4>
					<ul class="more_info">
						<li><input type="radio" name="teasers[date][format]" value="standard" <?php if ($teasers['date']['format'] == 'standard') echo 'checked="checked" '; ?>/><label><?php echo(date('F j, Y')); ?></label></li>
						<li><input type="radio" name="teasers[date][format]" value="no_comma" <?php if ($teasers['date']['format'] == 'no_comma') echo 'checked="checked" '; ?>/><label><?php echo(date('j F Y')); ?></label></li>
						<li><input type="radio" name="teasers[date][format]" value="numeric" <?php if ($teasers['date']['format'] == 'numeric') echo 'checked="checked" '; ?>/><label><?php echo(date('m.d.Y')); ?></label></li>
						<li><input type="radio" name="teasers[date][format]" value="reversed" <?php if ($teasers['date']['format'] == 'reversed') echo 'checked="checked" '; ?>/><label><?php echo(date('d.m.Y')); ?></label></li>
						<li><input type="radio" name="teasers[date][format]" value="custom" <?php if ($teasers['date']['format'] == 'custom') echo 'checked="checked" '; ?>/><label><?php _e('Custom: ', 'thesis'); ?> <input type="text" class="date_entry" name="teasers[date][custom]" value="<?php echo $teasers['date']['custom']; ?>" /> <a href="http://us.php.net/manual/en/function.date.php" target="_blank" title="See the full list of PHP date formats">[?]</a></label></li>
					</ul>
				</div>
				<div class="module_subsection" id="teaser_link">
					<h4><a href="" title="<?php _e('Show/hide additional information', 'thesis'); ?>"><span class="pos">+</span><span class="neg">&#8211;</span></a><?php _e('Link to Full Article', 'thesis'); ?></h4>
					<p class="more_info form_input">
						<input type="text" id="teasers[link_text]" name="teasers[link_text]" value="<?php echo thesis_teaser_link_text(); ?>" />
						<label for="teasers[link_text]"><?php _e('link display text', 'thesis'); ?></label>
					</p>
				</div>
				<div class="module_subsection" id="teaser_fonts">
					<h4><a href="" title="<?php _e('Show/hide additional information', 'thesis'); ?>"><span class="pos">+</span><span class="neg">&#8211;</span></a><?php _e('Teaser Font Sizes', 'thesis'); ?></h4>
					<div class="more_info">
						<p><?php _e('Use the controls below to fine-tune the font sizes of your teaser elements.', 'thesis'); ?></p>
<?php
					$teaser_areas = thesis_teaser_areas();
					$area_count = 1;

					foreach ($teaser_areas as $teaser_area => $available_sizes) {
						$add_margin = ($area_count == count($teaser_areas)) ? '' : ' add_margin';
?>
						<p class="form_input<?php echo $add_margin; ?>">
							<select id="teasers[font_sizes][<?php echo $teaser_area; ?>]" name="teasers[font_sizes][<?php echo $teaser_area; ?>]" size="1">
<?php
						foreach ($available_sizes as $available_size) {
							$selected = ($teasers['font_sizes'][$teaser_area] == $available_size) ? ' selected="selected"' : '';
							echo '									<option value="' . $available_size . '"' . $selected . '>' . $available_size . ' pt.</option>' . "\n";
						}
?>
							</select>
							<label for="teasers[font_sizes][<?php echo $teaser_area; ?>]"><?php _e($teasers['options'][$teaser_area]['name'] . ' font size', 'thesis'); ?></label>
						</p>
<?php
						$area_count++;
					}
?>
					</div>
				</div>
			</div>
			<div class="options_module" id="feature-box">
				<h3><?php _e('Feature Box', 'thesis'); ?></h3>
				<div class="module_subsection">
					<h4><a href="" title="<?php _e('Show/hide additional information', 'thesis'); ?>"><span class="pos">+</span><span class="neg">&#8211;</span></a><?php _e('Placement', 'thesis'); ?></h4>
					<div class="more_info">
						<p><?php _e('Select a placement setting below, and then depending on your site&#8217;s configuration, you&#8217;ll be presented with different options for managing your feature box.', 'thesis'); ?></p>
						<p class="form_input" id="feature_select">
							<select id="feature_box[position]" name="feature_box[position]" size="1">
								<option value="0"<?php if (!$feature_box['position']) echo ' selected="selected"'; ?>><?php _e('Do not use feature box', 'thesis'); ?></option>
								<option value="content"<?php if ($feature_box['position'] == 'content') echo ' selected="selected"'; ?>><?php _e('In your content column', 'thesis'); ?></option>
								<option value="full-content"<?php if ($feature_box['position'] == 'full-content') echo ' selected="selected"'; ?>><?php _e('Full-width above content and sidebars', 'thesis'); ?></option>
								<option value="full-header"<?php if ($feature_box['position'] == 'full-header') echo ' selected="selected"'; ?>><?php _e('Full-width above header area', 'thesis'); ?></option>
							</select>
						</p>
						<div id="feature_box_radio">
							<p class="label_note"><?php _e('Show feature box&hellip;', 'thesis'); ?></p>
							<ul>
<?php
					if (get_option('show_on_front') == 'page') {
?>
								<li><input type="radio" name="feature_box[status]" value="front" <?php if ($feature_box['status'] == 'front') echo 'checked="checked" '; ?>/><label><?php _e('on front page <em>only</em>', 'thesis'); ?></label></li>
								<li><input type="radio" name="feature_box[status]" value="0" <?php if (!$feature_box['status']) echo 'checked="checked" '; ?>/><label><?php _e('on blog page <em>only</em>', 'thesis'); ?></label></li>
								<li><input type="radio" name="feature_box[status]" value="front-and-blog" <?php if ($feature_box['status'] == 'front-and-blog') echo 'checked="checked" '; ?>/><label><?php _e('on front page and blog page', 'thesis'); ?></label></li>
<?php
					}
					else {
?>
								<li><input type="radio" name="feature_box[status]" value="0" <?php if (!$feature_box['status']) echo 'checked="checked" '; ?>/><label><?php _e('on home page <em>only</em>', 'thesis'); ?></label></li>
<?php
					}
?>
								<li><input type="radio" name="feature_box[status]" value="sitewide" <?php if ($feature_box['status'] == 'sitewide') echo 'checked="checked" '; ?>/><label><?php _e('sitewide', 'thesis'); ?></label></li>
							</ul>
						</div>
						<div id="feature_box_content_position">
							<p class="label_note"><?php _e('Display feature box after post&hellip;', 'thesis'); ?></p>
							<p class="form_input">
								<select id="feature_box[after_post]" name="feature_box[after_post]" size="1">
									<option value="0"<?php if (!$feature_box['after_post']) echo ' selected="selected"'; ?>><?php _e('Above all posts'); ?></option>
<?php
						$available_posts = $thesis['home']['features'];
						for ($j = 1; $j <= $available_posts; $j++) {
							$selected = ($feature_box['after_post'] == $j) ? ' selected="selected"' : '';
							echo '								<option value="' . $j . '"' . $selected . '>' . $j . '</option>' . "\n";
						}
?>
								</select>
							</p>
						</div>
					</div>
				</div>
				<div class="module_subsection" id="feature_box_display">
					<h4><a href="" title="<?php _e('Show/hide additional information', 'thesis'); ?>"><span class="pos">+</span><span class="neg">&#8211;</span></a><?php _e('Display Options', 'thesis'); ?></h4>
					<p class="more_info"><?php _e('Right now, the only thing you can do with your shiny new feature box is access a hook, <code>thesis_hook_feature_box</code>. Expect your display options to improve dramatically in a future release!', 'thesis'); ?></p>
				</div>
			</div>
		</div>
		
		<div class="options_column">
			<div class="options_module" id="thesis-multimedia-box">
				<h3><?php _e('Multimedia Box', 'thesis'); ?></h3>
				<div class="module_subsection">
					<h4><a href="" title="<?php _e('Show/hide additional information', 'thesis'); ?>"><span class="pos">+</span><span class="neg">&#8211;</span></a><?php _e('Default Settings', 'thesis'); ?></h4>
					<div class="more_info">
						<p><?php _e('The default multimedia box setting applies to your home page, archive pages (category, tag, date-based, and author-based), search pages, and 404 pages. You can override the default setting on any individual post or page by utilizing the multimedia box controls on the post editing screen.', 'thesis'); ?></p>
						<p class="form_input" id="multimedia_select">
							<select id="multimedia_box[status]" name="multimedia_box[status]" size="1">
								<option value="0"<?php if (!$multimedia_box['status']) echo ' selected="selected"'; ?>><?php _e('Do not show box', 'thesis'); ?></option>
								<option value="image"<?php if ($multimedia_box['status'] == 'image') echo ' selected="selected"'; ?>><?php _e('Rotating images', 'thesis'); ?></option>
								<option value="video"<?php if ($multimedia_box['status'] == 'video') echo ' selected="selected"'; ?>><?php _e('Embed a video', 'thesis'); ?></option>
								<option value="custom"<?php if ($multimedia_box['status'] == 'custom') echo ' selected="selected"'; ?>><?php _e('Custom code', 'thesis'); ?></option>
							</select>
						</p>
						<p class="tip" id="no_box_tip"><?php _e('Remember, even though you&#8217;ve disabled the multimedia box here, you can activate it on single posts or pages by using the multimedia box options on the post editing screen.', 'thesis'); ?></p>
						<p class="tip" id="image_tip"><?php _e('Any images you upload to your <a href="' . THESIS_ROTATOR_FOLDER . '">rotator folder</a> will automatically appear in the list below.', 'thesis'); ?></p>
						<div class="mini_module" id="image_alt_module">
							<h5><?php _e('Define Image Alt Tags and Links', 'thesis'); ?></h5>
							<p><?php _e('It&#8217;s a good practice to add descriptive alt tags to every image you place on your site. Use the input fields below to add customized alt tags to your rotating images.', 'thesis'); ?></p>
	<?php
						$rotator_dir = opendir(THESIS_ROTATOR);	
						while (($file = readdir($rotator_dir)) !== false) {
							if (strpos($file, '.jpg') || strpos($file, '.jpeg') || strpos($file, '.png') || strpos($file, '.gif'))
								$images[$file] = THESIS_ROTATOR_FOLDER . '/' . $file;
						}

						$image_count = 1;

						if ($images) {
							foreach ($images as $image => $image_url) {
	?>
							<div class="toggle_box">
								<p class="form_input add_margin">
									<input type="text" class="text_input" id="multimedia_box[alt_tags][<?php echo $image; ?>]" name="multimedia_box[alt_tags][<?php echo $image; ?>]" value="<?php if ($multimedia_box['alt_tags'][$image]) echo stripslashes($multimedia_box['alt_tags'][$image]); ?>" />
									<label for="multimedia_box[alt_tags][<?php echo $image; ?>]"><?php _e('alt text for ' . $image . ' &nbsp; <a href="' . $image_url . '" target="_blank">view</a>', 'thesis'); ?> &nbsp; <a class="switch" href=""><?php _e('[+] add link', 'thesis'); ?></a></label>
								</p>
								<p class="form_input dependent indented<?php if ($image_count < count($images)) echo ' add_margin'; ?>">
									<input type="text" class="text_input" id="multimedia_box[link_urls][<?php echo $image; ?>]" name="multimedia_box[link_urls][<?php echo $image; ?>]" value="<?php if ($multimedia_box['link_urls'][$image]) echo $multimedia_box['link_urls'][$image]; ?>" />
									<label for="multimedia_box[link_urls][<?php echo $image; ?>]"><?php _e('link <acronym title="Uniform Resource Locator">URL</acronym> for ' . $image . ' (including &#8216;http://&#8217;)', 'thesis'); ?></label>
								</p>
							</div>
	<?php
								$image_count++;
							}
						}
						else {
	?>
							<p class="form_input"><?php _e('You don&#8217;t have any images to rotate! Try adding some images to your <a href="' . THESIS_ROTATOR_FOLDER . '">rotator folder</a>, and then come back here to edit your alt tags.', 'thesis'); ?></p>
	<?php
						}
	?>
						</div>
						<div class="mini_module" id="video_code_module">
							<h5><?php _e('Embedded Video Code', 'thesis'); ?></h5>
							<p><?php _e('Place your video embed code in the box below, and it will appear in the multimedia box by default.', 'thesis'); ?></p>
							<p class="form_input">
								<label for="multimedia_box[video]"><?php _e('Video embed code', 'thesis'); ?></label>
								<textarea id="multimedia_box[video]" name="multimedia_box[video]"><?php if ($multimedia_box['video']) thesis_massage_code($multimedia_box['video']); ?></textarea>
							</p>
						</div>
						<div class="mini_module" id="custom_code_module">
							<h5><?php _e('Custom Multimedia Box Code', 'thesis'); ?></h5>
							<p><?php _e('You&#8217;ve now activated the special multimedia box hook, <code>thesis_hook_multimedia_box</code>, and you can use this to make the multimedia box do just about anything via your custom functions file, <code>custom_functions.php</code>.', 'thesis'); ?></p>
							<p><?php _e('If you like, you can override this hook by placing your own custom <acronym title="HyperText Markup Language">HTML</acronym> in the box below. Even if you do this, you can still access the hook on any post or page by adding a custom field with a key of <code>custom</code> and a value of <code>php</code>.', 'thesis'); ?></p>
							<p class="form_input">
								<label for="multimedia_box[code]"><?php _e('Custom multimedia box code', 'thesis'); ?></label>
								<textarea id="multimedia_box[code]" name="multimedia_box[code]"><?php if ($multimedia_box['code']) thesis_massage_code($multimedia_box['code']); ?></textarea>
							</p>
						</div>
					</div>
				</div>
			</div>
			<div class="options_module" id="html-framework">
				<h3><?php _e('Framework Options', 'thesis'); ?></h3>
				<div class="module_subsection">
					<h4><a href="" title="<?php _e('Show/hide additional information', 'thesis'); ?>"><span class="pos">+</span><span class="neg">&#8211;</span></a><?php _e('<acronym title="HyperText Markup Language">HTML</acronym> Framework', 'thesis'); ?></h4>
					<div class="more_info">
						<p><?php _e('If you&#8217;re customizing your Thesis design, you may wish to employ a different <acronym title="HyperText Markup Language">HTML</acronym> framework in order to better suit your design needs. There are two primary types of frameworks that should accommodate just about any type of design&#8212;<strong>page</strong> and <strong>full-width</strong>. By default, Thesis uses the page framework, but you can change that below.', 'thesis'); ?></p>
						<ul>
							<li><input type="radio" name="layout[framework]" value="page" <?php if ($layout['framework'] != 'full-width') echo 'checked="checked" '; ?>/><label><?php _e('Page framework', 'thesis'); ?></label></li>
							<li><input type="radio" name="layout[framework]" value="full-width" <?php if ($layout['framework'] == 'full-width') echo 'checked="checked" '; ?>/><label><?php _e('Full-width framework', 'thesis'); ?></label></li>
						</ul>
					</div>
				</div>
				<div class="module_subsection">
					<h4><a href="" title="<?php _e('Show/hide additional information', 'thesis'); ?>"><span class="pos">+</span><span class="neg">&#8211;</span></a><?php _e('Outer Page Padding', 'thesis'); ?></h4>
					<div class="more_info">
						<p><?php _e('By default, Thesis adds whitespace around your layout for styling purposes. One unit of whitespace is equal to the line height of the text in your content area, and by default, Thesis places adds one unit of whitespace around your layout. How many units of whitespace would you like around your layout?', 'thesis'); ?></p>
						<p class="form_input">
							<select id="layout[page_padding]" name="layout[page_padding]" size="1">
<?php
						for ($k = 0; $k <= 8; $k++) {
							$padding = $k / 2;
							$selected = ($layout['page_padding'] == $padding) ? ' selected="selected"' : '';
							echo '<option value="' . $padding . '"' . $selected . '>' . number_format($padding, 1) . '</option>' . "\n";
						}
?>
							</select>
						</p>
					</div>
				</div>
			</div>
			<div class="options_module" id="design-customizations">
				<h3><?php _e('More Design Customizations', 'thesis'); ?></h3>
				<div class="module_subsection">
					<h4><a href="" title="<?php _e('Show/hide additional information', 'thesis'); ?>"><span class="pos">+</span><span class="neg">&#8211;</span></a><?php _e('Custom Stylesheet', 'thesis'); ?></h4>
					<div class="more_info">
						<p><?php _e('If you want to make stylistic changes with <acronym title="Cascading Style Sheet">CSS</acronym>, you should use the Thesis custom stylesheet to do so.', 'thesis'); ?></p>
<?php
						if (!file_exists(THESIS_CUSTOM))
							echo '<p class="tip add_margin">' . __('Your custom stylesheet <strong>will not work</strong> until you rename your <code>/custom-sample</code> folder to <code>/custom</code>.', 'thesis') . '</p>' . "\n";
?>
						<ul>
							<li><input type="checkbox" id="style[custom]" name="style[custom]" value="1" <?php if ($style['custom']) echo 'checked="checked" '; ?>/><label for="style[custom]"><?php _e('Use custom stylesheet', 'thesis'); ?></label></li>
						</ul>
					</div>
				</div>
			</div>
			<div class="options_module button_module">
				<input type="submit" class="save_button" id="design_submit" name="submit" value="<?php thesis_save_button_text(true); ?>" />
			</div>
		</div>
	</form>
<?php
	}
?>
</div>