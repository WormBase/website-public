<?php
/**
 * Primary entry-point to the Thesis theme framework.
 *
 * @package Thesis
 */

thesis_html_framework();

/**
 * NOT WHAT YOU WERE EXPECTING?
 *
 * Thesis stores much of its programming in a unique manner when
 * compared to other themes; in order to reduce redundancy and to
 * improve efficiency, we have extracted much of what usually
 * constitutes a theme into logical, programmatic functions.
 *
 * In order to customize items, such as the famous Loop, we
 * provide dozens of "hooks" into the Thesis code -- the same
 * sort of hooks which makes WordPress so extensible to plugin
 * authors.
 *
 * Much more information can be found on DIYthemes.com and in our
 * support community, but here is a brief example:
 *
 * A plugin wants you to add my_social_links() to to the Loop in
 * order to add social links to your posts; here's how you would
 * do that with Thesis:
 *
 * In your custom/custom_functions.php file, add this line:
 *
 * add_action('thesis_hook_after_post', 'my_social_links');
 *
 * That is the simplest of examples and is just a taste of what
 * is actually possible. We highly encourage you to experiment.
 *
 * Remember: Customizations made only to the custom directory
 * are not only kept together for easy reference, but they are
 * also futureproof agaisnt any Thesis updates.
 */
?>