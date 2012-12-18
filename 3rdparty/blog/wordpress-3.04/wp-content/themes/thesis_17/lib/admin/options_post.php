<?php
/**
 * class thesis_post_options
 *
 * @package Thesis
 * @since 1.7
 */
class thesis_post_options {
	function add_meta_boxes() {
		$post_options = new thesis_post_options;
		$post_options->meta_boxes();

		foreach ($post_options->meta_boxes as $meta_name => $meta_box) {
			add_meta_box($meta_box['id'], $meta_box['title'], array('thesis_post_options', 'output_' . $meta_name . '_box'), 'post', 'normal', 'high'); #wp
			add_meta_box($meta_box['id'], $meta_box['title'], array('thesis_post_options', 'output_' . $meta_name . '_box'), 'page', 'normal', 'high'); #wp
		}

		add_action('save_post', array('thesis_post_options', 'save_meta')); #wp
	}
	
	// These functions are really dumb and unnecessary. They're only here because WP is sucky and limited.
	function output_seo_box() {
		$post_options = new thesis_post_options;
		$post_options->meta_boxes();
		$tabindex = 60;
		$post_options->output_meta_box($post_options->meta_boxes['seo'], $tabindex);
	}
	
	function output_image_box() {
		$post_options = new thesis_post_options;
		$post_options->meta_boxes();
		$tabindex = 90;
		$post_options->output_meta_box($post_options->meta_boxes['image'], $tabindex);
	}
	
	function output_javascript_box() {
		$post_options = new thesis_post_options;
		$post_options->meta_boxes();
		$tabindex = 130;
		$post_options->output_meta_box($post_options->meta_boxes['javascript'], $tabindex);
	}
	
	function output_multimedia_box() {
		$post_options = new thesis_post_options;
		$post_options->meta_boxes();
		$tabindex = 150;
		$post_options->output_meta_box($post_options->meta_boxes['multimedia'], $tabindex);
	}

	function output_meta_box($meta_box, $tabindex) {
		global $post;
		if ($meta_box) {
			foreach ($meta_box['fields'] as $meta_id => $meta_field) { // Spit out the actual form on the WordPress post page
				$existing_value = get_post_meta($post->ID, $meta_field['name'], true);
				$value = ($existing_value != '') ? $existing_value : $meta_field['default'];
				$margin = ($meta_field['margin']) ? ' class="add_margin"' : '';

				echo "<div id=\"$meta_id\" class=\"thesis-post-control\">\n";

				if ($meta_field['description']) {
					$switch = ' <a class="switch" href="">[+] more info</a>';
					$description = '<p class="description">' . $meta_field['description'] . "</p>\n";
				}
				else {
					$switch = '';
					$description = '';
				}

				if ($meta_field['title'])
					echo '<p><strong>' . $meta_field['title'] . "</strong>$switch</p>\n";

				if ($description)
					echo $description;

				if (is_array($meta_field['type'])) {
					echo "<ul$margin>\n";
					$type = $meta_field['type']['type'];

					if ($type == 'radio') {
						$options = $meta_field['type']['options'];
						$default = $meta_field['default'];

						foreach ($options as $option_value => $label) {
							if ($existing_value)
								$checked = ($existing_value == $option_value) ? ' checked="checked"' : '';
							elseif ($option_value == $default)
								$checked = ' checked="checked"';
							else
								$checked = '';

							if ($option_value == $default)
								$option_value = '';

							echo "\t<li><input type=\"$type\" name=\"" . $meta_field['name'] . "\" value=\"$option_value\"$checked tabindex=\"$tabindex\" /> <label>$label</label></li>\n";
						}
					}
					elseif ($type == 'checkbox') {
						$options = $meta_field['type']['options'];
						foreach ($options as $option_name => $option) {
							$checked = ($value[$option_name] || (!isset($value[$option_name]) && $option['default'])) ? ' checked="checked"' : '';
							echo "\t<li><input type=\"hidden\" name=\"" . $meta_field['name'] . "[$option_name]\" value=\"0\" /><input type=\"$type\" name=\"" . $meta_field['name'] . "[$option_name]\" value=\"1\"$checked tabindex=\"$tabindex\" /> <label>" . $option['label']. "</label></li>\n";
						}
					}

					echo "</ul>\n";
				}	
				elseif ($meta_field['type'] == 'text') {
					$width = ($meta_field['width']) ? ' ' . $meta_field['width'] : '';

					echo "<p$margin>\n";
					echo "\t<input type=\"text\" class=\"text_input$width\" id=\"" . $meta_field['name'] . '" name="' . $meta_field['name'] . "\" value=\"$value\" tabindex=\"$tabindex\" />\n";
					echo "\t" . '<label for="' . $meta_field['name'] . '">' . $meta_field['label'] . "</label>\n";
					echo "</p>\n";
				}
				elseif ($meta_field['type'] == 'textarea') {
					echo "<p$margin>\n";
					echo "\t" . '<textarea id="' . $meta_field['name'] . '" name="' . $meta_field['name'] . "\" tabindex=\"$tabindex\">$value</textarea>\n";
					echo "\t" . '<label for="' . $meta_field['name'] . '">' . $meta_field['label'] . "</label>\n";
					echo "</p>\n";
				}
				elseif ($meta_field['type'] == 'checkbox') {
					$checked = ($value) ? ' checked="checked"' : '';
					echo "<p$margin>" . '<input type="checkbox" id="' . $meta_field['name'] . '" name="' . $meta_field['name'] . "\" value=\"1\"$checked tabindex=\"$tabindex\" /> <label for=\"" . $meta_field['name'] . '">' . $meta_field['label'] . "</label></p>\n";
				}

				echo "</div>\n";
				$tabindex++;
			}

			echo "\t" . '<input type="hidden" name="' . $meta_box['noncename'] . '_noncename" id="' . $meta_box['noncename'] . '_noncename" value="' . wp_create_nonce(plugin_basename(__FILE__)) . "\" />\n";
		}
	}

	function save_meta($post_id) {
		$post_options = new thesis_post_options;
		$post_options->meta_boxes();

		// We have to make sure all new data came from the proper Thesis entry fields
		foreach($post_options->meta_boxes as $meta_box) {
			if (!wp_verify_nonce($_POST[$meta_box['noncename'] . '_noncename'], plugin_basename(__FILE__)))
				return $post_id;
		}

		if ($_POST['post_type'] == 'page') {
			if (!current_user_can('edit_page', $post_id))
				return $post_id;
		}
		else {
			if (!current_user_can('edit_post', $post_id))
				return $post_id;
		}

		// If we reach this point in the code, that means we're authenticated. Proceed with saving the new data
		foreach ($post_options->meta_boxes as $meta_box) {
			foreach ($meta_box['fields'] as $meta_field) {
				$current_data = get_post_meta($post_id, $meta_field['name'], true);
				$new_data = $_POST[$meta_field['name']];

				if (($meta_field['type']['type'] == 'checkbox') && is_array($meta_field['type']['options'])) {
					foreach ($meta_field['type']['options'] as $option_name => $option) {
						if ((bool) $new_data[$option_name] != (bool) $option['default'])
							$new_data[$option_name] = (bool) $new_data[$option_name];
						elseif ((bool) $new_data[$option_name] == (bool) $option['default'])
							unset($new_data[$option_name]);
					}

					if ($new_data)
						update_post_meta($post_id, $meta_field['name'], $new_data);
					else
						delete_post_meta($post_id, $meta_field['name']);
				}
				else {
					if ($current_data) {
						if ($new_data == '')
							delete_post_meta($post_id, $meta_field['name']);
						elseif ($new_data == $meta_field['default'])
							delete_post_meta($post_id, $meta_field['name']);
						elseif ($new_data != $current_data)
							update_post_meta($post_id, $meta_field['name'], $new_data);
					}
					elseif ($new_data != '')
						add_post_meta($post_id, $meta_field['name'], $new_data, true);
				}
			}
		}
	}
	
	function meta_boxes() {
		global $thesis_site, $thesis_design;
		$javascript = new thesis_javascript;
		$libs = $javascript->libs;

		$this->meta_boxes = array(
			'seo' => array(
				'id' => 'thesis_seo_meta',
				'title' => __('<acronym title="Search Engine Optimization">SEO</acronym> Details and Additional Style', 'thesis'),
				'noncename' => 'thesis_seo',
				'fields' => array(
					'thesis_meta_title' => array(
						'name' => 'thesis_title',
						'type' => 'text',
						'width' => 'full',
						'default' => '',
						'title' => __('Custom Title Tag', 'thesis'),
						'description' => __('By default, Thesis uses the title of your post as the contents of the <code>&lt;title&gt;</code> tag. You can override this and further extend your on-page <acronym title="Search Engine Optimization">SEO</acronym> by entering your own <code>&lt;title&gt;</code> tag below.', 'thesis'),
						'label' => __('custom <code>&lt;title&gt;</code> tag', 'thesis'),
						'margin' => true,
						'upgrade' => false
					),
					'thesis_meta_description' => array(
						'name' => 'thesis_description',
						'type' => 'textarea',
						'width' => false,
						'default' => '',
						'title' => __('Meta Description', 'thesis'),
						'description' => __('Entering a <code>&lt;meta&gt;</code> description is just one more thing you can do to seize an on-page <acronym title="Search Engine Optimization">SEO</acronym> opportunity. Keep in mind that a good <code>&lt;meta&gt;</code> description is both informative and concise.', 'thesis'),
						'label' => __('<code>&lt;meta&gt;</code> description', 'thesis'),
						'margin' => false,
						'upgrade' => 'meta'
					),
					'thesis_meta_no_description' => array(
						'name' => 'thesis_no_description',
						'type' => 'checkbox',
						'width' => '',
						'default' => false,
						'title' => '',
						'description' => '',
						'label' => __('force search engines to pull a <code>&lt;meta&gt;</code> description based on the content of the page', 'thesis'),
						'margin' => true,
						'upgrade' => false
					),
					'thesis_meta_keywords' => array(
						'name' => 'thesis_keywords',
						'type' => 'text',
						'width' => 'full',
						'default' => '',
						'title' => __('Meta Keywords', 'thesis'),
						'description' => __('Like the <code>&lt;meta&gt;</code> description, <code>&lt;meta&gt;</code> keywords are yet another on-page <acronym title="Search Engine Optimization">SEO</acronym> opportunity. Enter a few keywords that are relevant to your article, but don&#8217;t go crazy here&#8212;just a few should suffice.', 'thesis'),
						'label' => __('<code>&lt;meta&gt;</code> keywords', 'thesis'),
						'margin' => true,
						'upgrade' => 'keywords'
					),
					'thesis_meta_robots' => array(
						'name' => 'thesis_robots',
						'type' => array(
							'type' => 'checkbox',
							'options' => array(
								'noindex' => array('label' => __('add a <code>noindex</code> robot meta tag to this page', 'thesis'), 'default' => false),
								'nofollow' => array('label' => __('add a <code>nofollow</code> robot meta tag to this page', 'thesis'), 'default' => false),
								'noarchive' => array('label' => __('add a <code>noarchive</code> robot meta tag to this page', 'thesis'), 'default' => false)
							)
						),
						'width' => '',
						'default' => false,
						'title' => __('Robots Meta Tags', 'thesis'),
						'description' => sprintf(__('Fine-tune the <acronym title="Search Engine Optimization">SEO</acronym> on every page of your site using the handy robots meta tag selectors below. For a detailed description of what each option does, check out the <a href="%s">Document Head section</a> of the Thesis Options.', 'thesis'), get_bloginfo('wpurl') . '/wp-admin/admin.php?page=thesis-options#document-head'),
						'label' => '',
						'margin' => true,
						'upgrade' => false
					),
					'thesis_meta_slug' => array(
						'name' => 'thesis_slug',
						'type' => 'text',
						'width' => 'short',
						'default' => '',
						'title' => __('<acronym title="Cascading Style Sheet">CSS</acronym> Class', 'thesis'),
						'description' => __('If you want to style this post individually via <acronym title="Cascading Style Sheet">CSS</acronym>, you should enter a class name below. <strong>Note</strong>: <acronym title="Cascading Style Sheet">CSS</acronym> class names cannot begin with numbers!', 'thesis'),
						'label' => __('<acronym title="Cascading Style Sheet">CSS</acronym> class name', 'thesis'),
						'margin' => true,
						'upgrade' => 'slug'
					),
					'thesis_meta_readmore' => array(
						'name' => 'thesis_readmore',
						'type' => 'text',
						'width' => 'short',
						'default' => '',
						'title' => __('&ldquo;Read More&rdquo; Text', 'thesis'),
						'description' => __('If you use <code>&lt;!--more--&gt;</code> within your post, you can specify custom &ldquo;Read More&rdquo; text; otherwise, whatever is set in the global Thesis Options will be used.', 'thesis'),
						'label' => __('use custom &ldquo;Read More&rdquo; text for this entry', 'thesis'),
						'margin' => true,
						'upgrade' => false
					),
					'thesis_meta_redirect' => array(
						'name' => 'thesis_redirect',
						'type' => 'text',
						'width' => 'full',
						'default' => '',
						'title' => __('301 Redirect for this Page&#8217;s <acronym title="Uniform Resource Locator">URL</acronym>', 'thesis'),
						'description' => __('Use this handy tool to set up nice-looking affiliate links for your site. If you place a <acronym title="Uniform Resource Locator">URL</acronym> in the field below, users will get redirected to this <acronym title="Uniform Resource Locator">URL</acronym> whenever they visit the <acronym title="Uniform Resource Locator">URL</acronym> defined in the <strong>Permalink</strong> above (located beneath the post title field). <strong>Remember</strong>: The permalink is the <acronym title="Uniform Resource Locator">URL</acronym> that you&#8217;ll give to users when you want to send them to the <acronym title="Uniform Resource Locator">URL</acronym> in the field below.', 'thesis'),
						'label' => __('destination <acronym title="Uniform Resource Locator">URL</acronym>', 'thesis'),
						'margin' => false,
						'upgrade' => false
					)
				)
			),
			'image' => array(
				'id' => 'thesis_image_meta',
				'title' => __('Post Image and Thumbnail', 'thesis'),
				'noncename' => 'thesis_image',
				'fields' => array(
					'thesis_meta_post_image' => array(
						'name' => 'thesis_post_image',
						'type' => 'text',
						'width' => 'full',
						'default' => '',
						'title' => __('Post Image', 'thesis'),
						'description' => sprintf(__('To add a post image, simply upload an image with the <em>Add an Image</em> button above, and then paste the <strong>Link <acronym title="Uniform Resource Locator">URL</acronym></strong> here. If you like, you can also add your own <code>alt</code> text for the image in the appropriate field below. Based on the current width of your content column, the maximum width for post images is %1$s pixels. Based on your content width <em>and</em> current font size settings, the maximum width for framed post images is %2$s pixels. Finally, there are certain areas around the theme where full-size post images cannot be displayed. In this case, Thesis will automatically crop your post image into a thumbnail with default dimensions as specified on the <a href="%3$s">Thesis Options</a> page. If you like, you can override this (on this post only) by specifying your own thumbnail dimensions below. Please note that automatic thumbnail generation requires your image to be hosted at <strong>%4$s</strong>.', 'thesis'), thesis_max_post_image_width(), thesis_max_post_image_width(true), get_bloginfo('wpurl') . '/wp-admin/admin.php?page=thesis-options#post-image-options', $_SERVER['HTTP_HOST']),
						'label' => __('post image <acronym title="Uniform Resource Locator">URL</acronym> (including <code>http://</code>)', 'thesis'),
						'margin' => false,
						'upgrade' => false
					),
					'thesis_meta_post_image_alt' => array(
						'name' => 'thesis_post_image_alt',
						'type' => 'text',
						'width' => 'full',
						'default' => '',
						'title' => '',
						'description' => '',
						'label' => __('post image <code>alt</code> text', 'thesis'),
						'margin' => false,
						'upgrade' => false
					),
					'thesis_meta_post_image_frame' => array(
						'name' => 'thesis_post_image_frame',
						'type' => array(
							'type' => 'radio',
							'options' => array(
								'on' => __('frame this post image', 'thesis'),
								'off' => __('do not frame this post image', 'thesis')
							)
						),
						'width' => '',
						'default' => $thesis_design->image['post']['frame'],
						'title' => '',
						'description' => '',
						'label' => __('add a frame to this post image', 'thesis'),
						'margin' => false,
						'upgrade' => false
					),
					'thesis_meta_post_image_horizontal' => array(
						'name' => 'thesis_post_image_horizontal',
						'type' => array(
							'type' => 'radio',
							'options' => array(
								'flush' => __('flush left with no text wrap', 'thesis'),
								'left' => __('left with text wrap', 'thesis'),
								'right' => __('right with text wrap', 'thesis'),
								'center' => __('centered (no wrap)', 'thesis')
							)
						),
						'width' => '',
						'default' => $thesis_design->image['post']['x'],
						'title' => __('Horizontal Position', 'thesis'),
						'description' => '',
						'label' => '',
						'margin' => true,
						'upgrade' => false
					),
					'thesis_meta_post_image_vertical' => array(
						'name' => 'thesis_post_image_vertical',
						'type' => array(
							'type' => 'radio',
							'options' => array(
								'before-headline' => __('above headline', 'thesis'),
								'after-headline' => __('below headline', 'thesis'),
								'before-post' => __('before post/page content', 'thesis')
							)
						),
						'width' => '',
						'default' => $thesis_design->image['post']['y'],
						'title' => __('Vertical Position', 'thesis'),
						'description' => '',
						'label' => '',
						'margin' => false,
						'upgrade' => false
					),
					'thesis_meta_thumb' => array(
						'name' => 'thesis_thumb',
						'type' => 'text',
						'width' => 'full',
						'default' => '',
						'title' => __('Thumbnail Image', 'thesis'),
						'description' => __('If you like, you can supply your own thumbnail image. If you do this, the new thumbnail image will not be cropped, so make sure that you size the image appropriately before adding it here.', 'thesis'),
						'label' => __('thumbnail image <acronym title="Uniform Resource Locator">URL</acronym> (including <code>http://</code>)', 'thesis'),
						'margin' => false,
						'upgrade' => 'thumb'
					),
					'thesis_meta_thumb_alt' => array(
						'name' => 'thesis_thumb_alt',
						'type' => 'text',
						'width' => 'full',
						'default' => '',
						'title' => '',
						'description' => '',
						'label' => __('thumbnail image <code>alt</code> text', 'thesis'),
						'margin' => false,
						'upgrade' => false
					),
					'thesis_meta_thumb_frame' => array(
						'name' => 'thesis_thumb_frame',
						'type' => array(
							'type' => 'radio',
							'options' => array(
								'on' => __('frame this thumbnail image', 'thesis'),
								'off' => __('do not frame this thumbnail image', 'thesis')
							)
						),
						'width' => '',
						'default' => $thesis_design->image['thumb']['frame'],
						'title' => '',
						'description' => '',
						'label' => __('add a frame to this thumbnail image', 'thesis'),
						'margin' => false,
						'upgrade' => false
					),
					'thesis_meta_thumb_horizontal' => array(
						'name' => 'thesis_thumb_horizontal',
						'type' => array(
							'type' => 'radio',
							'options' => array(
								'flush' => __('flush left with no text wrap', 'thesis'),
								'left' => __('left with text wrap', 'thesis'),
								'right' => __('right with text wrap', 'thesis'),
								'center' => __('centered (no wrap)', 'thesis')
							)
						),
						'width' => '',
						'default' => $thesis_design->image['thumb']['x'],
						'title' => __('Horizontal Position', 'thesis'),
						'description' => '',
						'label' => '',
						'margin' => true,
						'upgrade' => false
					),
					'thesis_meta_thumb_vertical' => array(
						'name' => 'thesis_thumb_vertical',
						'type' => array(
							'type' => 'radio',
							'options' => array(
								'before-headline' => __('above headline', 'thesis'),
								'after-headline' => __('below headline', 'thesis'),
								'before-post' => __('before post/page content', 'thesis')
							)
						),
						'width' => '',
						'default' => $thesis_design->image['thumb']['y'],
						'title' => __('Vertical Position', 'thesis'),
						'description' => '',
						'label' => '',
						'margin' => false,
						'upgrade' => false
					),
					'thesis_meta_thumb_width' => array(
						'name' => 'thesis_thumb_width',
						'type' => 'text',
						'width' => 'tiny',
						'default' => $thesis_design->image['thumb']['width'],
						'title' => __('Thumbnail Size Dimensions', 'thesis'),
						'description' => sprintf(__('If you&#8217;ve supplied a post image for this post but have not supplied your own thumbnail image, Thesis will auto-crop your post image into a thumbnail. The resulting thumbnail will be cropped to the dimensions specified below. If you&#8217;d like to change the default crop dimensions, you can do so on the <a href="%1$s">Thesis Options</a> page.', 'thesis'), get_bloginfo('wpurl') . '/wp-admin/admin.php?page=thesis-options#post-image-options'),
						'label' => __('width (px)', 'thesis'),
						'margin' => false,
						'upgrade' => false
					),
					'thesis_meta_thumb_height' => array(
						'name' => 'thesis_thumb_height',
						'type' => 'text',
						'width' => 'tiny',
						'default' => $thesis_design->image['thumb']['height'],
						'title' => '',
						'description' => '',
						'label' => __('height (px)', 'thesis'),
						'margin' => false,
						'upgrade' => false
					)
				)
			),
			'javascript' => array(
				'id' => 'thesis_javascript_meta',
				'title' => __('JavaScript', 'thesis'),
				'noncename' => 'thesis_javascript',
				'fields' => array(
					'thesis_meta_javascript_libs' => array(
						'name' => 'thesis_javascript_libs',
						'type' => array(
							'type' => 'checkbox',
							'options' => array(
								'jquery' => array('label' => sprintf(__('%1$s library <a href="%2$s" target="_blank">[?]</a>', 'thesis'), $libs['jquery']['name'], $libs['jquery']['info_url']), 'default' => $thesis_design->javascript['libs']['jquery']),
								'jquery_ui' => array('label' => sprintf(__('%1$s library <a href="%2$s" target="_blank">[?]</a>', 'thesis'), $libs['jquery_ui']['name'], $libs['jquery_ui']['info_url']), 'default' => $thesis_design->javascript['libs']['jquery_ui']),
								'prototype' => array('label' => sprintf(__('%1$s library <a href="%2$s" target="_blank">[?]</a>', 'thesis'), $libs['prototype']['name'], $libs['prototype']['info_url']), 'default' => $thesis_design->javascript['libs']['prototype']),
								'scriptaculous' => array('label' => sprintf(__('%1$s library <a href="%2$s" target="_blank">[?]</a>', 'thesis'), $libs['scriptaculous']['name'], $libs['scriptaculous']['info_url']), 'default' => $thesis_design->javascript['libs']['scriptaculous']),
								'mootools' => array('label' => sprintf(__('%1$s library <a href="%2$s" target="_blank">[?]</a>', 'thesis'), $libs['mootools']['name'], $libs['mootools']['info_url']), 'default' => $thesis_design->javascript['libs']['mootools']),
								'dojo' => array('label' => sprintf(__('%1$s library <a href="%2$s" target="_blank">[?]</a>', 'thesis'), $libs['dojo']['name'], $libs['dojo']['info_url']), 'default' => $thesis_design->javascript['libs']['dojo']),
								'yui' => array('label' => sprintf(__('%1$s library <a href="%2$s" target="_blank">[?]</a>', 'thesis'), $libs['yui']['name'], $libs['yui']['info_url']), 'default' => $thesis_design->javascript['libs']['yui']),
								'ext' => array('label' => sprintf(__('%1$s library <a href="%2$s" target="_blank">[?]</a>', 'thesis'), $libs['ext']['name'], $libs['ext']['info_url']), 'default' => $thesis_design->javascript['libs']['ext']),
								'chrome' => array('label' => sprintf(__('%1$s library <a href="%2$s" target="_blank">[?]</a>', 'thesis'), $libs['chrome']['name'], $libs['chrome']['info_url']), 'default' => $thesis_design->javascript['libs']['chrome'])
							)
						),
						'width' => '',
						'default' => false,
						'title' => __('Include JavaScript Libraries', 'thesis'),
						'description' => __('Need to add some JavaScript for killer functionality on this page? Use the controls below to add lightning-fast, cached JavaScript libraries as needed!', 'thesis'),
						'label' => '',
						'margin' => true,
						'upgrade' => false
					),
					'thesis_meta_javascript_scripts' => array(
						'name' => 'thesis_javascript_scripts',
						'type' => 'textarea',
						'width' => '',
						'default' => false,
						'title' => __('Embed Your Own JavaScript', 'thesis'),
						'description' => __('Add any JavaScript you like to the box below, but remember to include opening and closing <code>&lt;script&gt;</code> tags!', 'thesis'),
						'label' => __('embedded script code (please include <code>&lt;script&gt;</code> tags)', 'thesis'),
						'margin' => false,
						'upgrade' => false
					)
				)
			),
			'multimedia' => array(
				'id' => 'thesis_multimedia_meta',
				'title' => __('Multimedia Box Options', 'thesis'),
				'noncename' => 'thesis_multimedia',
				'fields' => array(
					'thesis_meta_image' => array(
						'name' => 'thesis_image',
						'type' => 'text',
						'width' => 'full',
						'default' => '',
						'title' => __('Multimedia Box Image', 'thesis'),
						'description' => __('Even if you have the multimedia box disabled by default, you can display any custom image you like in the box on this particular post. To accomplish this, simply upload your own image or use the <em>Add an Image</em> button above, and then paste the image <strong>Link <acronym title="Uniform Resource Locator">URL</acronym></strong> in the field below.', 'thesis'),
						'label' => __('multimedia box image <acronym title="Uniform Resource Locator">URL</acronym> (including <code>http://</code>)', 'thesis'),
						'margin' => true,
						'upgrade' => 'image'
					),
					'thesis_meta_video' => array(
						'name' => 'thesis_video',
						'type' => 'textarea',
						'width' => false,
						'default' => '',
						'title' => __('Multimedia Box Video', 'thesis'),
						'description' => __('Like the image box above, you can override your multimedia box settings and display any video you want on this particular post. Upload a video using the <em>Add Video</em> button, and then paste the video embed code in the box below. Also, please note that you may need to change the width and height attributes of the video in order to make it fit perfectly inside your multimedia box.', 'thesis'),
						'label' => __('video embed code', 'thesis'),
						'margin' => true,
						'upgrade' => 'video'
					),
					'thesis_meta_custom_code' => array(
						'name' => 'thesis_custom_code',
						'type' => 'textarea',
						'width' => false,
						'default' => '',
						'title' => __('Custom Multimedia Box Code', 'thesis'),
						'description' => __('If you want to get really fancy, you can inject your own custom <acronym title="HyperText Markup Language">HTML</acronym> into the multimedia box on this post by entering your code in the box below.', 'thesis'),
						'label' => __('custom <acronym title="HyperText Markup Language">HTML</acronym>', 'thesis'),
						'margin' => true,
						'upgrade' => 'custom'
					),
					'thesis_meta_custom_hook' => array(
						'name' => 'thesis_custom_hook',
						'type' => 'checkbox',
						'width' => false,
						'default' => false,
						'title' => __('Access the Multimedia Box Hook', 'thesis'),
						'description' => __('Real ninjas do it with hooks, and if you want to add some amazing functionality to the multimedia box on this post (with <acronym title="Recursive acronym for Hypertext Preprocessor">PHP</acronym>, perhaps), check the box below. Also, if you&#8217;re already using the multimedia box hook by default, there&#8217;s no need to check this box.', 'thesis'),
						'label' => __('access the multimedia box hook, <code>thesis_hook_multimedia_box</code>, on this post', 'thesis'),
						'margin' => false,
						'upgrade' => false
					)
				)
			)
		);
	}
}