<?php
/**********************************************************************************
* httpBL_2_Config.php                                                             *
***********************************************************************************
* MOD to stop spammers from accesisng any SMF forum                               *
* Modification Version:       MOD httpBL 2.5.1                                    *
* Made by:                    Snoopy (http://www.snoopyvirtualstudio.com)         *
* Copyleft 2009 by:     	  Snoopy (http://www.snoopyvirtualstudio.com)         *
* =============================================================================== *
* SMF: Simple Machines Forum                                                      *
* Open-Source Project Inspired by Zef Hemel (zef@zefhemel.com)                    *
* =============================================================================== *
* Software Version:           SMF 2.0 RC4                                         *
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
		- called by ?action=admin;area=httpBL.
		- choses a function based on the 'sa' parameter.
		- defaults to httpBL_Config().
		- requires the admin_forum permission.
		- initializes the admin tabs.

	void httpBL_Config()
		- set MOD httpBL settings.
		- accessed by ?action=admin;area=httpBL;sa=config.
		- requires the admin_forum permission.

	array httpBL_ViewLog()
		- show a list of logged access attempts by spammers and internal errors from MOD httpBL.
		- is accessed by ?action=admin;area=httpBL;sa=viewlog.
		              -  ?action=admin;area=httpBL;sa=viewlogpass.
		              -  ?action=admin;area=httpBL;sa=viewlogerror.
		- allows sorting of several columns.
		- also handles deletion of (a selection of) log entries.
		- requires the admin_forum permission.
		- loads the httpBL template file.
		- uses the viewlog sub template of the httpBL template.

	array httpBL_Helping()
		- show a helping page
		- is accessed by ?action=admin;area=httpBL;sa=helping.
		- requires the admin_forum permission.
		- uses the helping sub template of the httpBL template.
*/


function httpBL_Admin()
{
	global $context, $txt, $scripturl;

	isAllowedTo('admin_forum');

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

	// Tabs for browsing the different httpBL functions.
	$context[$context['admin_menu_name']]['tab_data'] = array(
		'title' => &$txt['httpBL_title'],
		'description' => $txt['httpBL_description'],
		'tabs' => array(
			'config' => array(
				'description' => $txt['httpBL_description'],
			),
			'viewlog' => array(
				'description' => $txt['httpBL_viewlog_description'],
			),
			'viewlogpass' => array(
				'description' => $txt['httpBL_viewlogpass_description'],
			),
			'viewlogerror' => array(
				'description' => $txt['httpBL_viewlogerror_description'],
			),
			'helping' => array(
				'description' => $txt['httpBL_helping_description'],
			),
		),
	);

	// Call the right function for this sub-acton.
	$subActions[$_REQUEST['sa']]();
}


function httpBL_Config($return_config = false)
{
	global $txt, $context, $scripturl, $sourcedir, $boardurl, $settings, $modSettings;

	// We are going to need this
	require_once($sourcedir . '/httpBL_Subs.php');
	
	// Test if the mod is OK
	$context['httpBL_ok'] = httpBL_test_mod_ok();

	// We need a special style sheet for httpBL_Config
	$context['html_headers'] .= '
		<link rel="stylesheet" type="text/css" href="' . $settings['default_theme_url'] . '/css/httpBL_css.css" />';

	// This is really quite wanting.
	require_once($sourcedir . '/ManageServer.php');
	
	// Let's find out if we got mod OS & Browser Detection
	$os_browser_exists = FALSE;
	if (file_exists($sourcedir.'/os_browser_detection.php'))
		$os_browser_exists = TRUE;
	
	if ($os_browser_exists)
		$os_whosonline_array = array('check', 'httpBL_view_os_whosonline', 'subtext' => $txt['httpBL_view_os_whosonline_sub']);
	else
		$os_whosonline_array = array('check', 'httpBL_view_os_whosonline', 'subtext' => $txt['httpBL_view_os_whosonline_sub'], 'disabled' => 'disabled');
	
	$config_vars = array(
		array('title', 'httpBL_general_settings'),
		array('desc', 'httpBL_general_settings_desc'),
			array('check', 'httpBL_enable', 'subtext' => $txt['httpBL_enable_sub']),
			array('text', 'httpBL_honeyPot_link', 'subtext' => $txt['httpBL_honeyPot_link_sub'], 'onchange' => 'checkEnable();', 'size' => '50'),
			array('text', 'httpBL_honeyPot_key', 'subtext' => $txt['httpBL_honeyPot_key_sub'], 'onchange' => 'checkEnable();'),
			array('text', 'httpBL_honeyPot_word', 'subtext' => $txt['httpBL_honeyPot_word_sub']),
		array('title', 'httpBL_info_email'),
		array('desc', 'httpBL_info_email_desc'),
			array('text', 'httpBL_info_email_1'),
			array('text', 'httpBL_info_email_2'),
			array('text', 'httpBL_info_email_3'),
		array('title', 'httpBL_internal_settings'),
		array('desc', 'httpBL_internal_settings_desc'),
			array('int', 'httpBL_bad_last_activity', 'subtext' => $txt['httpBL_bad_last_activity_sub']),
			array('int', 'httpBL_bad_threat', 'subtext' => $txt['httpBL_bad_threat_sub']),
			array('int', 'httpBL_very_bad_threat', 'subtext' => $txt['httpBL_very_bad_threat_sub']),
			array('int', 'httpBL_cache_length', 'subtext' => $txt['httpBL_cache_length_sub']),
			array('int', 'httpBL_cookie_length', 'subtext' => $txt['httpBL_cookie_length_sub']),
		array('title', 'httpBL_extra_settings'),
		array('desc', 'httpBL_extra_settings_desc'),
			array('check', 'httpBL_viewlog_extra', 'subtext' => $txt['httpBL_viewlog_extra_sub']),
			$os_whosonline_array,
		array('title', 'httpBL_warning_settings'),
		array('desc', 'httpBL_warning_settings_desc'),
			array('check', 'httpBL_use_two_languages', 'subtext' => $txt['httpBL_use_two_languages_sub']),
			array('text', 'httpBL_horizontal_separator', 'subtext' => $txt['httpBL_horizontal_separator_sub'], 'size' => '50'),
	);

	if ($return_config)
		return $config_vars;

	// Setup the template
	$context['sub_template'] = 'show_settings';
	$context['page_title'] = $txt['httpBL_title'];

	// Saving?
	if (isset($_GET['save']))
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

		// Better double check all the values are correct before saving.
		$_POST['httpBL_enable'] = empty($_POST['httpBL_enable']) ? 0 : 1;
		$_POST['httpBL_honeyPot_key'] = empty($_POST['httpBL_honeyPot_key']) ? '' : $_POST['httpBL_honeyPot_key'];
		$_POST['httpBL_honeyPot_link'] = empty($_POST['httpBL_honeyPot_link']) ? '' : $_POST['httpBL_honeyPot_link'];
		$_POST['httpBL_honeyPot_word'] = empty($_POST['httpBL_honeyPot_word']) ? '' : $_POST['httpBL_honeyPot_word'];
		$_POST['httpBL_info_email_1'] = empty($_POST['httpBL_info_email_1']) ? '' : $_POST['httpBL_info_email_1'];
		$_POST['httpBL_info_email_2'] = empty($_POST['httpBL_info_email_2']) ? '' : $_POST['httpBL_info_email_2'];
		$_POST['httpBL_info_email_3'] = empty($_POST['httpBL_info_email_3']) ? '' : $_POST['httpBL_info_email_3'];
		$_POST['httpBL_bad_last_activity'] = empty($_POST['httpBL_bad_last_activity']) ? 90 : (int) $_POST['httpBL_bad_last_activity'];
		$_POST['httpBL_bad_threat'] = empty($_POST['httpBL_bad_threat']) ? 1 : (int) $_POST['httpBL_bad_threat'];
		$_POST['httpBL_very_bad_threat'] = empty($_POST['httpBL_very_bad_threat']) ? 30 : (int) $_POST['httpBL_very_bad_threat'];
		$_POST['httpBL_cache_length'] = empty($_POST['httpBL_cache_length']) ? 5 : (int) $_POST['httpBL_cache_length'];
		$_POST['httpBL_cookie_length'] = empty($_POST['httpBL_cookie_length']) ? 24 : (int) $_POST['httpBL_cookie_length'];
		$_POST['httpBL_viewlog_extra'] = empty($_POST['httpBL_viewlog_extra']) ? 0 : 1;
		$_POST['httpBL_view_os_whosonline'] = empty($_POST['httpBL_view_os_whosonline']) || !$os_browser_exists ? 0 : 1;
		$_POST['httpBL_use_two_languages'] = empty($_POST['httpBL_use_two_languages']) ? 0 : 1;
		$_POST['httpBL_horizontal_separator'] = empty($_POST['httpBL_horizontal_separator']) ? '' : $_POST['httpBL_horizontal_separator'];

		saveDBSettings($config_vars);

		redirectexit('action=admin;area=httpBL;sa=config');
	}

	$context['post_url'] = $scripturl . '?action=admin;area=httpBL;save;sa=config';
	$context['settings_title'] = $context['page_title'] . ' - ' . $txt['httpBL_config'];

	// Define some javascript for httpBL_enable.
	$context['settings_post_javascript'] = '
		function checkEnable()
		{
			var httpBLkeyDisabled = document.getElementById(\'httpBL_honeyPot_link\').value == "";
			document.getElementById(\'httpBL_honeyPot_key\').disabled = httpBLkeyDisabled;

			var httpBLDisabled = httpBLkeyDisabled || document.getElementById(\'httpBL_honeyPot_key\').value == "";
			document.getElementById(\'httpBL_enable\').disabled = httpBLDisabled;
		}
		checkEnable();';

	$context['settings_message'] = $context['httpBL_ok'];

	prepareDBSettingContext($config_vars);
}


function httpBL_ViewLog()
{
	global $txt, $context, $smcFunc, $scripturl, $sourcedir, $settings;

	// In SMF 1.x we needed the template for all the tabs
	// In 2.0 we only need it for ViewLog and Helping
	loadTemplate('httpBL');

	// We are going to need this
	require_once($sourcedir . '/httpBL_Subs.php');

	// We need a special style sheet for ViewLog
	$context['html_headers'] .= '
		<link rel="stylesheet" type="text/css" href="' . $settings['default_theme_url'] . '/css/httpBL_css.css" />';

	// Change the ViewLog style to normal or extra
	if (isset($_POST['httpBL_viewlog_extra']) || isset($_POST['httpBL_viewlog_normal']))
	{
		checkSession();

		// Update the actual settings.
		updateSettings(array(
			'httpBL_viewlog_extra' => isset($_POST['httpBL_viewlog_extra']) ? 1 : 0,
		));

		// Reload the page, so the tabs are accurate.
		redirectexit('action=admin;area=httpBL;sa='. $context['sub_action']);
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
	$items_per_page = 30;

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
			$smcFunc['db_query']('truncate_table', '
				TRUNCATE {db_prefix}log_httpBL',
				array(
				)
			);

		// 'Clear this log' button was pressed.
		else if (!empty($_POST['clearThisLog']))
			$smcFunc['db_query']('', '
				DELETE FROM {db_prefix}log_httpBL
				WHERE ' . $query_where,
				array(
				)
			);

		// 'Delete selection' button was pressed.
		else
		{
			// Make sure every entry is integer.
			foreach ($_POST['remove'] as $index => $log_id)
				$_POST['remove'][$index] = (int) $log_id;

			$smcFunc['db_query']('', '
				DELETE FROM {db_prefix}log_httpBL
				WHERE ID IN ({array_int:httpBL_list})',
				array(
					'httpBL_list' => $_POST['remove'],
				)
			);
		}
	}

	// Count the total number of log entries.
	$result = $smcFunc['db_query']('', '
		SELECT COUNT(*)
		FROM {db_prefix}log_httpBL
		WHERE ' . $query_where,
		array(
		)
	);
	list ($num_log_entries) = $smcFunc['db_fetch_row']($result);
	$smcFunc['db_free_result']($result);

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
	$context['page_index'] = constructPageIndex($scripturl . '?action=admin;area=httpBL;sa=' . $context['sub_action'] . ';sort=' . $context['sort'] . ($context['sort_direction'] == 'down' ? ';desc' : ''), $_REQUEST['start'], $num_log_entries, $items_per_page);
	$context['start'] = $_REQUEST['start'];
	
	$sort = $sort_columns[$context['sort']] . (isset($_REQUEST['desc']) ? ' DESC' : '');
	$start = $context['start'];
	$request = $smcFunc['db_query']('', '
		SELECT ID, logTime, ip, threat, last_activity, suspicious, harvester, comment, url, user_agent, error, errorNumber, username, raw
		FROM {db_prefix}log_httpBL
		WHERE ' . $query_where . '
		ORDER BY ' . $sort . '
		LIMIT ' . $start . ', ' . $items_per_page,
		array(
		)
	);
	
	// Let's find out if we got mod OS & Browser Detection
	$os_browser_exists = FALSE;
	if (file_exists($sourcedir.'/os_browser_detection.php'))
	{
		require_once($sourcedir . '/os_browser_detection.php');
		$os_browser_exists = TRUE;
	}
	
	$context['log_entries'] = array();
	while ($row = $smcFunc['db_fetch_assoc']($request))
	{
		// For members find the ID for linking to their profile
		if  ($row['username'] != '')
		{
			$result = $smcFunc['db_query']('', '
				SELECT ID_MEMBER
				FROM {db_prefix}members
				WHERE member_name = {string:username}
				LIMIT 1',
				array(
					'username' => $row['username'],
				)
			);
			list ($ID_MEMBER) = $smcFunc['db_fetch_row']($result);
			$smcFunc['db_free_result']($result);
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
			'username' => $row['username'] == '' ? $txt['guest_title'] : $row['username'],
			'id_member' => $ID_MEMBER,
			'raw' => $row['raw'],
			'class' => $httpBL_class,
		);
	}
	$smcFunc['db_free_result']($request);

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

	// In SMF 1.x we needed the template for all the tabs
	// In 2.0 we only need it for ViewLog and Helping
	loadTemplate('httpBL');

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
