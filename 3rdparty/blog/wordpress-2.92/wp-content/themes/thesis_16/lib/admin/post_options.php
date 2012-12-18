<?php

function thesis_seo_meta_box() {
	thesis_add_meta_box('seo');
}

function thesis_image_meta_box() {
	thesis_add_meta_box('image');
}

function thesis_multimedia_meta_box() {
	thesis_add_meta_box('multimedia');
}


function thesis_add_meta_box($box_name) {
	global $post;
	
	// Grab this meta box item's information from the construct array
	$meta_box = thesis_meta_boxes($box_name);
	
	// Spit out the actual form on the WordPress post page
	foreach ($meta_box['fields'] as $meta_id => $meta_field) {
		// Grab the existing value for this field from the database
		$existing_value = get_post_meta($post->ID, $meta_field['name'], true);
		$value = ($existing_value != '') ? $existing_value : $meta_field['default'];
		$margin = ($meta_field['margin']) ? ' class="add_margin"' : '';

		echo '<div id="' . $meta_id . '" class="thesis-post-control">' . "\n";
		
		if ($meta_field['description']) {
			$switch = ' <a class="switch" href="">[+] more info</a>';
			$description = '<p class="description">' . $meta_field['description'] . '</p>' . "\n";
		}
		else {
			$switch = '';
			$description = '';
		}
		
		if ($meta_field['title'])
			echo '<p><strong>' . $meta_field['title'] . '</strong>' . $switch . '</p>' . "\n";
		
		if ($description)
			echo $description;
		
		if (is_array($meta_field['type'])) {
			if ($meta_field['type']['type'] == 'radio') {
				$options = $meta_field['type']['options'];
				$default = $meta_field['default'];

				echo '<ul' . $margin . '>' . "\n";
				
				foreach ($options as $option_value => $label) {
					if ($existing_value)
						$checked = ($existing_value == $option_value) ? ' checked="checked"' : '';
					elseif ($option_value == $default)
						$checked = ' checked="checked"';
					else
						$checked = '';
						
					if ($option_value == $default)
						$option_value = '';

					echo '	<li><input type="radio" name="' . $meta_field['name'] . '" value="' . $option_value . '"' . $checked .' /> <label>' . $label . '</label></li>' . "\n";
				}
				
				echo '</ul>' . "\n";
			}
		}	
		elseif ($meta_field['type'] == 'text') {
			$width = ($meta_field['width']) ? ' ' . $meta_field['width'] : '';

			echo '<p' . $margin . '>' . "\n";
			echo '	<input type="text" class="text_input' . $width . '" id="' . $meta_field['name'] . '" name="' . $meta_field['name'] . '" value="' . $value . '" />' . "\n";
			echo '	<label for="' . $meta_field['name'] . '">' . $meta_field['label'] . '</label>' . "\n";
			echo '</p>' . "\n";
		}
		elseif ($meta_field['type'] == 'textarea') {
			echo '<p' . $margin . '>' . "\n";
			echo '	<textarea id="' . $meta_field['name'] . '" name="' . $meta_field['name'] . '">' . $value . '</textarea>' . "\n";
			echo '	<label for="' . $meta_field['name'] . '">' . $meta_field['label'] . '</label>' . "\n";
			echo '</p>' . "\n";
		}
		elseif ($meta_field['type'] == 'checkbox') {
			$checked = ($value) ? ' checked="checked"' : '';
			echo '<p' . $margin . '><input type="checkbox" id="' . $meta_field['name'] . '" name="' . $meta_field['name'] . '" value="1"' . $checked . ' /> <label for="' . $meta_field['name'] . '">' . $meta_field['label'] . '</label></p>' . "\n";
		}
		
		echo '</div>' . "\n";
	}
	
	echo '	<input type="hidden" name="' . $meta_box['noncename'] . '_noncename" id="' . $meta_box['noncename'] . '_noncename" value="' . wp_create_nonce(plugin_basename(__FILE__)) . '" />' . "\n";
}

function thesis_save_meta($post_id) {
	$meta_boxes = thesis_meta_boxes();
	
	// We have to make sure all new data came from the proper Thesis entry fields
	foreach($meta_boxes as $meta_box) {
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
	foreach ($meta_boxes as $meta_box) {
		foreach ($meta_box['fields'] as $meta_field) {
			$current_data = get_post_meta($post_id, $meta_field['name'], true);	
			$new_data = $_POST[$meta_field['name']];

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

function thesis_meta_boxes($meta_name = false) {
	global $thesis;

	$meta_boxes = array(
		'seo' => array(
			'id' => 'thesis_seo_meta',
			'title' => __('<acronym title="Search Engine Optimization">SEO</acronym> Details and Additional Style', 'thesis'),
			'function' => 'thesis_seo_meta_box',
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
					'margin' => true,
					'upgrade' => 'meta'
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
				'thesis_meta_noindex' => array(
					'name' => 'thesis_noindex',
					'type' => 'checkbox',
					'width' => '',
					'default' => false,
					'title' => __('Noindex this Page', 'thesis'),
					'description' => __('From time to time, you may wish to keep a particular post or page from appearing in the search engines. Checking this box will add the <code>noindex</code> robot meta tag to this page, thereby preventing it from being indexed in the search engines.', 'thesis'),
					'label' => __('add a <code>noindex</code> robot meta tag to this page', 'thesis'),
					'margin' => true,
					'upgrade' => false
				),
				'thesis_meta_readmore' => array(
					'name' => 'thesis_readmore',
					'type' => 'text',
					'width' => 'short',
					'default' => '',
					'title' => __('&ldquo;Read More&rdquo; Text', 'thesis'),
					'description' => __('If you use <code>&lt;!--more--&gt;</code> within your post, you can specify custom &ldquo;Read More&rdquo; text; otherwise, whatever is set in the global Thesis Options will be used.', 'thesis'),
					'label' => __('use custom &ldquo;Read More&rdquo; text for this entry', 'thesis'),
					'margin' => false,
					'upgrade' => false
				),
				'thesis_meta_readmore' => array(
					'name' => 'thesis_readmore',
					'type' => 'text',
					'width' => 'short',
					'default' => '',
					'title' => __('&ldquo;Read More&rdquo; Text', 'thesis'),
					'description' => __('If you use <code>&lt;!--more--&gt;</code> within your post, you can specify custom &ldquo;Read More&rdquo; text; otherwise, whatever is set in the global Thesis Options will be used.', 'thesis'),
					'label' => __('use custom &ldquo;Read More&rdquo; text for this entry', 'thesis'),
					'margin' => false,
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
					'margin' => false,
					'upgrade' => 'slug'
				)
			)
		),
		'image' => array(
			'id' => 'thesis_image_meta',
			'title' => __('Post Image and Thumbnail', 'thesis'),
			'function' => 'thesis_image_meta_box',
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
					'default' => $thesis['image']['post']['frame'],
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
					'default' => $thesis['image']['post']['x'],
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
					'default' => $thesis['image']['post']['y'],
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
					'default' => $thesis['image']['thumb']['frame'],
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
					'default' => $thesis['image']['thumb']['x'],
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
					'default' => $thesis['image']['thumb']['y'],
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
					'default' => $thesis['image']['thumb']['width'],
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
					'default' => $thesis['image']['thumb']['height'],
					'title' => '',
					'description' => '',
					'label' => __('height (px)', 'thesis'),
					'margin' => false,
					'upgrade' => false
				),
			)
		),
		'multimedia' => array(
			'id' => 'thesis_multimedia_meta',
			'title' => __('Multimedia Box Options', 'thesis'),
			'function' => 'thesis_multimedia_meta_box',
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

	if ($meta_name)
		return $meta_boxes[$meta_name];
	else
		return $meta_boxes;
}