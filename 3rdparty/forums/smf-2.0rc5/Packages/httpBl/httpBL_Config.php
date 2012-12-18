<?php
/**********************************************************************************
* httpBL_Config.php                                                               *
***********************************************************************************
* MOD to stop spammers from accesisng any SMF forum                               *
* Modification Version:       MOD httpBL 2.5.1                                    *
* Made by:                    Snoopy (http://www.snoopyvirtualstudio.com)         *
* Copyleft 2009 by:     	  Snoopy (http://www.snoopyvirtualstudio.com)         *
* =============================================================================== *
* SMF: Simple Machines Forum                                                      *
* Open-Source Project Inspired by Zef Hemel (zef@zefhemel.com)                    *
* =============================================================================== *
* Software Version:           SMF 1.1.12                                          *
* Software by:                Simple Machines (http://www.simplemachines.org)     *
* Copyright 2006-2009 by:     Simple Machines LLC (http://www.simplemachines.org) *
*           2001-2006 by:     Lewis Media (http://www.lewismedia.com)             *
* Support, News, Updates at:  http://www.simplemachines.org                       *
***********************************************************************************
* This program is free software; you may redistribute it and/or modify it under   *
* the terms of the provided license as published by Simple Machines LLC.          *
*                                                                                 *
* This program is distributed in the hope that it is and will be useful, but      *
* WITHOUT ANY WARRANTIES; without even any implied warranty of MERCHANTABILITY    *
* or FITNESS FOR A PARTICULAR PURPOSE.                                            *
*                                                                                 *
* See the "license.txt" file for details of the Simple Machines license.          *
* The latest version can always be found at http://www.simplemachines.org.        *
**********************************************************************************/
if (!defined('SMF'))
	die('Hacking attempt...');

/* Used to configurate the MOD httpBL or to see the spammers blocked by this mod

	void httpBL_Admin()
		- the main entrance point for the httpBL Config screen.
		- called by ?action=httpBL.
		- choses a function based on the 'sa' parameter.
		- defaults to httpBL_Config().
		- requires the admin_forum permission.
		- initializes the admin tabs.
		- loads the httpBL template file.

	void httpBL_Config()
		- set MOD httpBL settings.
		- accessed by ?action=httpBL;sa=config.
		- requires the admin_forum permission.
		- uses the config sub template of the httpBL template.

	array httpBL_ViewLog()
		- show a list of logged access attempts by spammers and internal errors from MOD httpBL.
		- is accessed by ?action=httpBL;sa=viewlog.
		              -  ?action=httpBL;sa=viewlogpass.
		              -  ?action=httpBL;sa=viewlogerror.
		- allows sorting of several columns.
		- also handles deletion of (a selection of) log entries.
		- requires the admin_forum permission.
		- uses the viewlog sub template of the httpBL template.

	array httpBL_Helping()
		- show a helping page
		- is accessed by ?action=httpBL;sa=helping.
		- requires the admin_forum permission.
		- uses the helping sub template of the httpBL template.
*/


function httpBL_Admin()
{
	global $context, $txt, $scripturl;

	isAllowedTo('admin_forum');

	// Boldify "httpBL" on the admin bar.
	adminIndex('httpBL');

	loadTemplate('httpBL');

	$subActions = array(
		'config' => 'httpBL_Config',
		'viewlog' => 'httpBL_ViewLog',
		'viewlogpass' => 'httpBL_ViewLog',
		'viewlogerror' => 'httpBL_ViewLog',
		'helping' => 'httpBL_Helping',
	);

	// Default the sub-action to 'config mod'.
	$_REQUEST['sa'] = isset($_REQUEST['sa']) && isset($subActions[$_REQUEST['sa']]) ? $_REQUEST['sa'] : 'config';

	$context['page_title'] = &$txt['httpBL_title'];
	$context['sub_action'] = $_REQUEST['sa'];

	// Tabs for browsing the different ban functions.
	$context['admin_tabs'] = array(
		'title' => &$txt['httpBL_title'],
		'description' => $txt['httpBL_description'],
		'tabs' => array(
			'config' => array(
				'title' => $txt['httpBL_config'],
				'description' => $txt['httpBL_description'],
				'href' => $scripturl . '?action=httpBL;sa=config',
				'is_selected' => $_REQUEST['sa'] == 'config',
			),
			'viewlog' => array(
				'title' => $txt['httpBL_viewlog'],
				'description' => $txt['httpBL_viewlog_description'],
				'href' => $scripturl . '?action=httpBL;sa=viewlog',
				'is_selected' => $_REQUEST['sa'] == 'viewlog',
			),
			'viewlogpass' => array(
				'title' => $txt['httpBL_viewlogpass'],
				'description' => $txt['httpBL_viewlogpass_description'],
				'href' => $scripturl . '?action=httpBL;sa=viewlogpass',
				'is_selected' => $_REQUEST['sa'] == 'viewlogpass',
			),
			'viewlogerror' => array(
				'title' => $txt['httpBL_viewlogerror'],
				'description' => $txt['httpBL_viewlogerror_description'],
				'href' => $scripturl . '?action=httpBL;sa=viewlogerror',
				'is_selected' => $_REQUEST['sa'] == 'viewlogerror',
			),
			'helping' => array(
				'title' => $txt['httpBL_helping'],
				'description' => $txt['httpBL_helping_description'],
				'href' => $scripturl . '?action=httpBL;sa=helping',
				'is_selected' => $_REQUEST['sa'] == 'helping',
				'is_last' => true,
			),
		),
	);

	// Call the right function for this sub-acton.
	$subActions[$_REQUEST['sa']]();
}


function httpBL_Config()
{
	global $txt, $context, $db_prefix, $settings, $sourcedir;

	// We are going to need this
	require_once($sourcedir . '/httpBL_Subs.php');

	// Setup the template
	$context['sub_template'] = 'config';
	$context['page_title'] = $txt['httpBL_title'];
	
	// Test if the mod is OK
	$context['httpBL_ok'] = httpBL_test_mod_ok();

	// We need a special style sheet for httpBL_Config
	$context['html_headers'] .= '
		<link rel="stylesheet" type="text/css" href="' . $settings['default_theme_url'] . '/httpBL_css.css" />';

	// Saving?
	if (isset($_POST['save']))
	{
		checkSession();

		// The API key should be 12 lowercase alpha characters.
		if (!empty($_POST['httpBL_honeyPot_key']) && (preg_match('/[^a-z]/', $_POST['httpBL_honeyPot_key']) || strlen($_POST['httpBL_honeyPot_key']) != 12))
			fatal_error($txt['httpBL_enable_bad_API_key']);

		// Do a test lookup (with known result).
		// We are doing it now inside httpBL_test_mod_ok()
		// No need to do it twice.
		/*if (!empty($_POST['httpBL_honeyPot_key']))
		{
			$lookup = httpbl_dnslookup('127.1.80.1', $_POST['httpBL_honeyPot_key']);
			if (!$lookup || $lookup['threat'] != 80) {
				fatal_error($txt['httpBL_honeyPot_key_error_2']);
			}
		}*/

		// Are we trying to activate without email?
		if (!empty($_POST['httpBL_enable']) && (empty($_POST['httpBL_info_email_1']) || empty($_POST['httpBL_info_email_2']) || empty($_POST['httpBL_info_email_3'])))
			fatal_error($txt['httpBL_enable_bad_email']);

		// None of these can be negative
		if ($_POST['httpBL_bad_last_activity'] <= 0 || $_POST['httpBL_bad_threat'] <= 0 || $_POST['httpBL_very_bad_threat'] <= 0 || $_POST['httpBL_cookie_length'] <= 0)
			fatal_error($txt['httpBL_no_negative_here']);

		// bad_threat cannot be higher than very_bad_threat
		if ($_POST['httpBL_bad_threat'] > $_POST['httpBL_very_bad_threat'])
			fatal_error($txt['httpBL_no_higher_than']);
	
		// Let's find out if we got mod OS & Browser Detection
		$os_browser_exists = FALSE;
		if (file_exists($sourcedir.'/os_browser_detection.php'))
			$os_browser_exists = TRUE;
	
		// Update the actual settings.
		updateSettings(array(
			'httpBL_enable' => empty($_POST['httpBL_enable']) ? 0 : 1,
			'httpBL_honeyPot_key' => empty($_POST['httpBL_honeyPot_key']) ? '' : $_POST['httpBL_honeyPot_key'],
			'httpBL_honeyPot_link' => empty($_POST['httpBL_honeyPot_link']) ? '' : $_POST['httpBL_honeyPot_link'],
			'httpBL_honeyPot_word' => empty($_POST['httpBL_honeyPot_word']) ? '' : $_POST['httpBL_honeyPot_word'],
			'httpBL_info_email_1' => empty($_POST['httpBL_info_email_1']) ? '' : $_POST['httpBL_info_email_1'],
			'httpBL_info_email_2' => empty($_POST['httpBL_info_email_2']) ? '' : $_POST['httpBL_info_email_2'],
			'httpBL_info_email_3' => empty($_POST['httpBL_info_email_3']) ? '' : $_POST['httpBL_info_email_3'],
			'httpBL_bad_last_activity' => empty($_POST['httpBL_bad_last_activity']) ? 90 : (int) $_POST['httpBL_bad_last_activity'],
			'httpBL_bad_threat' => empty($_POST['httpBL_bad_threat']) ? 1 : (int) $_POST['httpBL_bad_threat'],
			'httpBL_very_bad_threat' => empty($_POST['httpBL_very_bad_threat']) ? 30 : (int) $_POST['httpBL_very_bad_threat'],
			'httpBL_cache_length' => empty($_POST['httpBL_cache_length']) ? 5 : (int) $_POST['httpBL_cache_length'],
			'httpBL_cookie_length' => empty($_POST['httpBL_cookie_length']) ? 24 : (int) $_POST['httpBL_cookie_length'],
			'httpBL_viewlog_extra' => empty($_POST['httpBL_viewlog_extra']) ? 0 : 1,
			'httpBL_view_os_whosonline' => empty($_POST['httpBL_view_os_whosonline']) || !$os_browser_exists ? 0 : 1,
			'httpBL_use_two_languages' => empty($_POST['httpBL_use_two_languages']) ? 0 : 1,
			'httpBL_horizontal_separator' => empty($_POST['httpBL_horizontal_separator']) ? '' : html_entity_decode($_POST['httpBL_horizontal_separator']),
		));

		// Reload the page, so the tabs are accurate.
		redirectexit('action=httpBL;sa=config');
	}

}


function httpBL_ViewLog()
{
	global $txt, $context, $db_prefix, $scripturl, $settings, $sourcedir;

	// We are going to need this
	require_once($sourcedir . '/httpBL_Subs.php');

	// We need a special style sheet for ViewLog
	$context['html_headers'] .= '
		<link rel="stylesheet" type="text/css" href="' . $settings['default_theme_url'] . '/httpBL_css.css" />';

	// Change the ViewLog style to normal or extra
	if (isset($_POST['httpBL_viewlog_extra']) || isset($_POST['httpBL_viewlog_normal']))
	{
		checkSession();

		// Update the actual settings.
		updateSettings(array(
			'httpBL_viewlog_extra' => isset($_POST['httpBL_viewlog_extra']) ? 1 : 0,
		));

		// Reload the page, so the tabs are accurate.
		redirectexit('action=httpBL;sa='. $context['sub_action']);
	}

	$sort_columns = array(
		'date' => 'logTime',
		'ip' => 'ip',
		'threat' => 'threat',
		'activity' => 'last_activity',
		'suspicious' => 'suspicious',
		'harvester' => 'harvester',
		'comment' => 'comment',
		'username' => 'username',
	);

	// The number of entries to show per page of the ban log.
	$entries_per_page = 30;

	// Construct the WHERE part for all the queries
	if ($context['sub_action'] == 'viewlogpass')
		$query_where = "(stopped = 0 AND raw != '') OR error = 'Human - let them pass'";
	else if ($context['sub_action'] == 'viewlog')
		$query_where = "stopped = 1 OR (error = '' AND raw = '')";
	else
		$query_where = "stopped = 2 OR (error != '' AND error != 'Human - let them pass') OR (errorNumber != 0 AND raw = '') OR errorNumber > 200";

	// Delete one or more entries.
	if (!empty($_POST['removeAll']) || !empty($_POST['clearThisLog']) || (!empty($_POST['removeSelected']) && !empty($_POST['remove'])))
	{
		checkSession();

		// 'Delete all entries' button was pressed.
		if (!empty($_POST['removeAll']))
			db_query("
				TRUNCATE {$db_prefix}log_httpBL", __FILE__, __LINE__);

		// 'Clear this log' button was pressed.
		else if (!empty($_POST['clearThisLog']))
			db_query("
				DELETE FROM {$db_prefix}log_httpBL
				WHERE " . $query_where, __FILE__, __LINE__);

		// 'Delete selection' button was pressed.
		else
		{
			// Make sure every entry is integer.
			foreach ($_POST['remove'] as $index => $log_id)
				$_POST['remove'][$index] = (int) $log_id;

			db_query("
				DELETE FROM {$db_prefix}log_httpBL
				WHERE ID IN (" . implode(', ', $_POST['remove']) . ')', __FILE__, __LINE__);
		}
	}

	// Count the total number of log entries.
	$request = db_query("
		SELECT COUNT(*)
		FROM {$db_prefix}log_httpBL
		WHERE " . $query_where, __FILE__, __LINE__);
	list ($num_log_entries) = mysql_fetch_row($request);
	mysql_free_result($request);

	// Set start if not already set.
	$_REQUEST['start'] = empty($_REQUEST['start']) || $_REQUEST['start'] < 0 ? 0 : (int) $_REQUEST['start'];

	// Default to newest entries first.
	if (empty($_REQUEST['sort']) || !isset($sort_columns[$_REQUEST['sort']]))
	{
		$_REQUEST['sort'] = 'date';
		$_REQUEST['desc'] = true;
	}

	$context['sort_direction'] = isset($_REQUEST['desc']) ? 'down' : 'up';
	$context['sort'] = $_REQUEST['sort'];
	$context['page_index'] = constructPageIndex($scripturl . '?action=httpBL;sa=' . $context['sub_action'] . ';sort=' . $context['sort'] . ($context['sort_direction'] == 'down' ? ';desc' : ''), $_REQUEST['start'], $num_log_entries, $entries_per_page);
	$context['start'] = $_REQUEST['start'];

	$request = db_query("
		SELECT ID, logTime, ip, threat, last_activity, suspicious, harvester, comment, url, user_agent, error, errorNumber, username, raw
		FROM {$db_prefix}log_httpBL
		WHERE " . $query_where . "
		ORDER BY " . $sort_columns[$context['sort']] . (isset($_REQUEST['desc']) ? ' DESC' : '') . "
		LIMIT $_REQUEST[start], $entries_per_page", __FILE__, __LINE__);
	
	// Let's find out if we got mod OS & Browser Detection
	$os_browser_exists = FALSE;
	if (file_exists($sourcedir.'/os_browser_detection.php'))
	{
		require_once($sourcedir . '/os_browser_detection.php');
		$os_browser_exists = TRUE;
	}
	
	$context['log_entries'] = array();
	while ($row = mysql_fetch_assoc($request))
	{
		// For members find the ID for linking to their profile
		if  ($row['username'] != '')
		{
			$username = (string)$row['username'];
			$result = db_query("
				SELECT ID_MEMBER
				FROM {$db_prefix}members
				WHERE memberName = '$username'
				LIMIT 1", __FILE__, __LINE__);
			list ($ID_MEMBER) = mysql_fetch_row($result);
			mysql_free_result($result);
		}
		else
			$ID_MEMBER = 0;

		// Some color code depending on threat level
		/* TO DO
		 * Add as well color code depending on errorNumber
		 * and move this to a function in httpBL_Subs
		 */
		$httpBL_class = '';
		if ($row['threat'] >= 40)
			$httpBL_class = 'httpBL_threat_very_high';
		else if ($row['threat'] >= 20)
			$httpBL_class = 'httpBL_threat_high';
		else if ($row['threat'] >= 15 || $row['harvester'] != 0 || $row['comment'] != 0)
			$httpBL_class = 'httpBL_threat_medium';
		else if ($row['threat'] != 0)
			$httpBL_class = 'httpBL_threat_low';

		if ($os_browser_exists)
		{
			$os_browser_detected = parse_user_agent($row['user_agent']);
			if ($os_browser_detected['system'])
				$httpBL_os = '<img src="'. $settings['default_images_url']. '/os_browser_detection/icon_'. $os_browser_detected['system_icon']. '.png" align="top" alt="'. $os_browser_detected['system']. '" /> '. $os_browser_detected['system'];
			else
				$httpBL_os = '<img src="'. $settings['default_images_url']. '/os_browser_detection/icon_unknown.png" align="top" alt="'. $txt['OS_Browser_Unknown']. '" /> '. $txt['OS_Browser_Unknown'];
			if ($os_browser_detected['browser'])
				$httpBL_browser = '<img src="'. $settings['default_images_url']. '/os_browser_detection/icon_'. $os_browser_detected['browser_icon']. '.png" align="top" alt="'. $os_browser_detected['browser']. '" /> '. $os_browser_detected['browser'];
			else
				$httpBL_browser = '<img src="'. $settings['default_images_url']. '/os_browser_detection/icon_unknown.png" align="top" alt="'. $txt['OS_Browser_Unknown']. '" /> '. $txt['OS_Browser_Unknown'];
		}
		else
		{
			$httpBL_os = $txt['OS_Browser_Unknown'];
			$httpBL_browser = $txt['OS_Browser_Unknown'];
		}

		$context['log_entries'][] = array(
			'id' => $row['ID'],
			'date' => timeformat($row['logTime']),
			'ip' => $row['ip'],
			'threat' => $row['threat'] == 0 ? '' : $row['threat'],
			'last_activity' => $row['last_activity'] == 0 ? '' : $row['last_activity'],
			'suspicious' => $row['suspicious'] == 0 ? '' : $txt['httpBL_yes'],
			'harvester' => $row['harvester'] == 0 ? '' : $txt['httpBL_yes'],
			'comment' => $row['comment'] == 0 ? '' : $txt['httpBL_yes'],
			'url' => $row['url'],
			'user_agent' => $row['user_agent'],
			'os' => $httpBL_os,
			'browser' => $httpBL_browser,
			'errorNumber' => $row['error'] != '' ? $row['error'] : ($row['raw'] == '' ? $txt['httpBL_log_no_error'] : httpBL_error_message($row['errorNumber'])),
			'username' => $row['username'] == '' ? $txt[28] : $row['username'],
			'id_member' => $ID_MEMBER,
			'raw' => $row['raw'],
			'class' => $httpBL_class,
		);
	}
	mysql_free_result($request);

	// Setup the template
	$context['sub_template'] = 'viewlog';
	if ($context['sub_action'] == 'viewlogpass')
		$context['page_title'] = $txt['httpBL_title'] . ' - ' . $txt['httpBL_viewlogpass'];
	else if ($context['sub_action'] == 'viewlogerror')
		$context['page_title'] = $txt['httpBL_title'] . ' - ' . $txt['httpBL_viewlogerror'];
	else
		$context['page_title'] = $txt['httpBL_title'] . ' - ' . $txt['httpBL_viewlog'];
}


function httpBL_Helping()
{
	global $txt, $context, $sourcedir;

	if ($context['user']['language'] == "spanish_es" || $context['user']['language'] == "spanish_es-utf8" || $context['user']['language'] == "spanish_latin" || $context['user']['language'] == "spanish_latin-utf8")
	{
		$httpBL_lang = 'es';
		$httpBL_donate = 'Donar';
		$httpBL_skype_alt = array (
			1 => 'Conectado',
			2 => 'Ocupado',
			3 => 'Ausente',
			4 => 'Desconectado'
		);
		$httpBL_skype_text = 'No hay conexión entre tu servidor y el mío ahora mismo, por lo que no se puede comprobar si estoy conectado. Inténtalo más tarde o pulsa este botón para comprobarlo manualmente.';
	}
	else
	{
		$httpBL_lang = 'en';
		$httpBL_donate = 'Donate';
		$httpBL_skype_alt = array (
			1 => 'Online',
			2 => 'Busy',
			3 => 'Away',
			4 => 'Offline'
		);
		$httpBL_skype_text = 'There is no connexion between your server and mine just now, so it\'s impossible to check if I am connected. Please try later or click this button to check it manually.';
	}
	
	$httpBL_skype_on = 4;
	$remote_skype_on = 'http://www.snoopyvirtualstudio.com/snp_skype_on.php';
	$remote_skype_text = 'http://www.snoopyvirtualstudio.com/snp_skype_text.php?lang=' . $httpBL_lang;
	require_once($sourcedir . '/Subs-Package.php');
	$try_skype_on = fetch_web_data($remote_skype_on);
	$try_skype_text = fetch_web_data($remote_skype_text);
	if ($try_skype_on !== false)
		$httpBL_skype_on = intval($try_skype_on);
	if ($httpBL_skype_on == 0)
		$httpBL_skype_on = 4;
	if ($try_skype_text !== false && $try_skype_text != '')
		$httpBL_skype_text = stripslashes($try_skype_text);
	if ($context['character_set'] != 'UTF-8')
		$httpBL_skype_text = iconv("UTF-8", "ISO-8859-15", $httpBL_skype_text);
	
	$context['httpBL_skype_div'] = '<img src="http://www.snoopyvirtualstudio.com/templates/snp_oscuro/images/skype-peq.jpg" title="' . $txt['httpBL_online_title'] . '" alt="' . $txt['httpBL_online_title'] . '" style="border:none;" /><br /><br />' . ($httpBL_skype_on == 1 ? '<script type="text/javascript" src="http://download.skype.com/share/skypebuttons/js/skypeCheck.js"></script>' : '') . '<a href="' . ($httpBL_skype_on == 1 ? 'skype:snoopy_virtual_studio?call' : 'http://www.snoopyvirtualstudio.com/contact.php' . ($httpBL_lang == 'en' ? '?language=english' : '')) . '" target="_blank"><img src="http://www.snoopyvirtualstudio.com/templates/snp_oscuro/images/' . $httpBL_lang . '/skype-' . $httpBL_skype_on . '.jpg" alt="' . $httpBL_skype_alt[$httpBL_skype_on] . '" style="border:none;" /></a><br /><br />' . $httpBL_skype_text;
	
	$context['httpBL_donate'] = '<a href="https://www.paypal.com/cgi-bin/webscr?cmd=_s-xclick&amp;hosted_button_id=WF3C2X98ET272" target="_blank"><img src="http://www.snoopyvirtualstudio.com/images/btn_donate_LG_' . $httpBL_lang . '_USD.png" alt="' . $httpBL_donate . ' USD" style="border:none;" /></a><br /><br /><a href="https://www.paypal.com/cgi-bin/webscr?cmd=_s-xclick&amp;hosted_button_id=5VD4E8A9KHXGL" target="_blank"><img src="http://www.snoopyvirtualstudio.com/images/btn_donate_LG_' . $httpBL_lang . '_EUR.png" alt="' . $httpBL_donate . ' EUR" style="border:none;" /></a>';
	
	// Setup the template
	$context['sub_template'] = 'helping';
	$context['page_title'] = $txt['httpBL_title'] . ' - ' . $txt['httpBL_helping'];
}
?>
