<?php
/**
 * Display comments on posts and pages.
 *
 * TrackBacks, PingBacks, Comments and the comment form itself
 * are handled by this file.
 *
 * @package Thesis
 */

// Prevent direct access to this file
if (!defined('ABSPATH')) {
	header('HTTP/1.1 403 Forbidden');
	die('Please do not load this file directly. Thank you.');
}

// Check for password protection
if (post_password_required()) {
	$pass_req = "<p>" . __('This post is password protected. Enter the password to view comments.', 'thesis') . "</p>\n";
	return;
}

$thesis_comments = new thesis_comments;
$thesis_comments->output_comments($comments);