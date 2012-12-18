<?php
/*
Global Headers Footers
Version 1.0
by:vbgamer45
http://www.smfhacks.com
*/

if (!defined('SMF'))
	die('Hacking attempt...');

function globalhf()
{

	//Check if the current user can change headers footers
	isAllowedTo('admin_forum');

	loadtemplate('globalhf');

	//Global Headers Footers Actions
	$subActions = array(
		'view' => 'view',
		'save' => 'save'
	);


	// Follow the sa or just go to View function
	if (!empty($subActions[$_GET['sa']]))
		$subActions[$_GET['sa']]();
	else
		$subActions['view']();

}
function view()
{
	global $context;

	adminIndex('globalhf');

	//Load main trader template.
	$context['sub_template']  = 'main';

	//Set the page title
	$context['page_title'] = 'Global Headers and Footers';
}
function  save()
{
	global $boarddir;

	$styleheaders = $_POST['headers'];
	$stylefooters = $_POST['footers'];

	$styleheaders=stripslashes($styleheaders);
	$stylefooters=stripslashes($stylefooters);


	//Save Headers
	$filename = $boarddir . '/smfheader.php';
	@chmod($filename, 0644);
	if (!$handle = fopen($filename, 'w'))
		fatal_error('Can not open' . $filename   . '.',false);

	// Write the headers to our opened file.
	if (!fwrite($handle, $styleheaders))
	{
		//fatal_error('Can not write to' . $filename   . '.',false);
	}
	fclose($handle);

	//Save Footers
	$filename = $boarddir . '/smffooter.php';
	@chmod($filename, 0644);
	if (!$handle = fopen($filename, 'w'))
		fatal_error('Can not open' . $filename   . '.',false);

	// Write the headers to our opened file.
	if (!fwrite($handle, $stylefooters))
	{

		//fatal_error('Can not write to' . $filename   . '.',false);
	}

	fclose($handle);

	redirectexit('action=globalhf');
}
?>