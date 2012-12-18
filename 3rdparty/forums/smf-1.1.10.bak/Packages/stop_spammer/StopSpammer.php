<?php

##########################################
##		<id>M-DVD:StopSpammer</id>		##
##		<name>Stop Spammer</name>		##
##		<version>2.3.7</version>		##
##		<type>modification</type>		##
##########################################

/******************************************************************************
* This program is free software; you may redistribute it and/or modify it     *
* under the terms of the provided license as published by SMF.                *
*******************************************************************************
* This program is distributed in the hope that it is and will be useful,      *
* but WITHOUT ANY WARRANTIES; without even any implied warranty of            *
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.                        *
******************************************************************************/

if (!defined('SMF'))
	die('Hacking attempt...');

// This function Check Spammer in DB - MOD StopSpammer
function checkDBSpammer($check_ip, $check_name, $check_mail, $test = false)
{
	global $sourcedir, $modSettings;

	//$remoteXML = 'http://www.stopforumspam.com/api?' . ('127.0.0.1' != $check_ip ? "ip={$check_ip}&" : '') . 'username=' . urlencode($check_name) . '&email=' . $check_mail;
	$remoteXML = 'http://www.stopforumspam.com/api?' . ('127.0.0.1' != $check_ip ? ($modSettings['stopspammer_check_ip'] ? 'ip=' . $check_ip . '&' : '') : '') . ($modSettings['stopspammer_check_name'] ? 'username=' . urlencode($check_name) . '&' : '') . ($modSettings['stopspammer_check_mail'] ? 'email=' . $check_mail : '');

	// Try to download.
	require_once($sourcedir . '/Subs-Package.php');
	$down_ok = fetch_web_data($remoteXML);

	// Test Host Connection
	if ($test) return (bool)$down_ok;

	// Connection Failed
	if (!$down_ok)
		if ($modSettings['stopspammer_faildb']) 
			return ('1' == $modSettings['stopspammer_faildb'] ? 0 : 8);
		else 
			fatal_lang_error('stopspammer_error');

	// Limit Exceded?
	if (strpos($down_ok, 'rate limit exceeded')) //  || 	strpos($down_ok, '<error>')
		if (allowedTo('moderate_forum')) // Is Logged?  // Moderate Forum?
			fatal_lang_error('stopspammer_limitexceded');
		else
			return 8;

	// Procesing XML
	preg_match_all('~<type>(\w+)</type>[\n\s]*<appears>(\w+)</appears>~', $down_ok, $q_is_spammer);

	$suma = 0;
	foreach ($q_is_spammer[1] as $key => $value)
		$suma += ('yes' == $q_is_spammer[2][$key]) << ('ip' == $value ? 0 : ('username' == $value ? 1 : 2));

	return $suma;
}

// This function Check & Report Many Members in DB Spammer - MOD StopSpammer
function checkreportMembers($users, $report)
{
	global $db_prefix, $sourcedir, $modSettings, $smcFunc;

	if ($report)
		require_once($sourcedir . '/Subs-Package.php');

	// Read data of Group Users
	$members_data = empty($smcFunc['db_query']) ? loadcheckedMembers_1($users) : loadcheckedMembers_2($users);

	foreach ($members_data as $row)
	{
	  if (!empty($row['id_member'])) {
		if ($report)
			fetch_web_data('http://www.stopforumspam.com/add', 'username=' . $row['member_name'] . '&ip_addr=' . $row['member_ip'] . '&email=' . $row['email_address'] . '&api_key=' . (!empty($modSettings['stopspammer_api_key']) ? $modSettings['stopspammer_api_key'] : 'O0Ys3RHtDZPMfB'));

		if ($is_spammer = checkDBSpammer($row['member_ip'], $row['member_name'], $row['email_address']))
			updateMemberData($row['id_member'], array('is_activated' => 3, 'is_spammer' => $is_spammer));
		if ($row['is_spammer'] != $is_spammer)
			++$modSettings['stopspammer_count'];
	  }
	}
	updateSettings(array('stopspammer_count' => $modSettings['stopspammer_count']), true);
}

function loadcheckedMembers_1($users)
{
	global $db_prefix;

	// Read data of Group Users
	$row = array();
	$resource = db_query("
		SELECT ID_MEMBER AS id_member, memberName AS member_name, emailAddress AS email_address, memberIP AS member_ip, is_spammer
			FROM {$db_prefix}members
			WHERE ID_MEMBER " . (is_array($users) ? 'IN (' . implode(',', $users) . ')' : '= ' . $users)
		, __FILE__, __LINE__);
	while ($row[] = mysql_fetch_assoc($resource)) {};
	mysql_free_result($resource);
	return $row;
}

function loadcheckedMembers_2($users)
{
	global $smcFunc, $db_prefix;

	// Read data of Group Users
	$row = array();
	$resource = $smcFunc['db_query']('', '
		SELECT id_member, member_name, email_address, member_ip, is_spammer
			FROM {db_prefix}members
			WHERE id_member {raw:where}',
		array('where' => is_array($users) ? 'IN (' . implode(',', $users) . ')' : '= ' . $users)
	);
	while ($row[] = $smcFunc['db_fetch_assoc']($resource)) {};
	$smcFunc['db_free_result']($resource);
	return $row;
}

function sprintfspamer(&$value, $url, $index, $type)
{
	global $txt, $settings, $modSettings;

	$is_spamer = (!$modSettings['stopspammer_enable'] || 3 != $value['is_activated']) ? 0 : $value['is_spammer'];
//	$is_spamer = (!$modSettings['stopspammer_enable']) ? 0 : $value['is_spammer'];

	$format1 = $modSettings['stopspammer_enable'] && $type && (($bol_1 = $is_spamer >> ($type - 1) & 1) || ($bol_2 = 8 == $is_spamer) || $modSettings['stopspammer_show01'])
		? '<a href="http://www.stopforumspam.com/search?q=' . urlencode($value[$index]) . '" target="_blank"><img src="' . $settings['default_images_url'] . '/icons/' . ($bol_1 ? 'spammer' : ($bol_2 ? 'suspect' : 'moreinfo')) . '.gif" alt="[' . (empty($txt['search']) ? $txt[182] : $txt['search']) . ']" title="' . $txt['stopspammer_title'] . '" style="vertical-align: middle" /></a>' : '';

	$format2 = $is_spamer % 8 ? array('<span class="error">', '</span>') : array('', '');

	return $format1 . '<a href="'. $url . '">' . implode($value[$index], $format2) . '</a>';
}