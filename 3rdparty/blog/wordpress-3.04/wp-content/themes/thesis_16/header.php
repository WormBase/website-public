<?php
/**
 * Handle the opening HTML and actions.
 *
 * @package Thesis
 */

# Added to appease certain plugins which check for this code in this file:
# wp_head();
?>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" <?php language_attributes(); ?>>

<head profile="http://gmpg.org/xfn/11">

<title><?php thesis_output_title(); ?></title>

<meta http-equiv="Content-Type" content="<?php bloginfo('html_type'); ?>; charset=<?php bloginfo('charset'); ?>" />
<?php wp_head(); ?>

</head>

<body<?php thesis_body_classes(); ?>>

<?php thesis_hook_before_html(); ?>