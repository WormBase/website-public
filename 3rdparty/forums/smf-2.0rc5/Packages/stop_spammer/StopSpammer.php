<?php

##########################################
##		<id>M-DVD:StopSpammer</id>		##
##		<name>Stop Spammer</name>		##
##		<version>2.3.9</version>		##
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
	$remoteXML = 'http://www.stopforumspam.com/api?' . ('127.0.0.1' != $check_ip ? ($modSettings['stopspammer_check_ip'] ? 'ip=' . $check_ip . '&' : '') : '') . ($modSettings['stopspammer_check_name'] ? 'username=' . urlencode($check_name) . '&' : '') . ($modSettings['stopspammer_check_mail'] ? 'email=' . urlencode($check_mail) : '');

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
		// Condicional (!empty($row['id_member'])) added in version 2.3.7 to avoid the yellow bug
		// The functions loadcheckedMembers 1 and 2 (added in version 2.3) were passing to the array
		// 		$members_data an empty key at the end. When processing this empty key with the foreach loop,
		// 		as there was no id_member to send, it was making the function checkDBSpammer to actually
		// 		check all the members in the database.
		// When there was no conexion with stopforumspam all of them went to is_activated = 3, is_spammer = 8 
		if (!empty($row['id_member']))
		{
			if ($report)
			{
				// Change requested by Stop Forum Spam Admin due to the amount of people
				// 		reporting spammers wrongly with the "default" API key
				if ($modSettings['stopspammer_api_key'] == '')
					fatal_lang_error('stopspammer_error_no_api_key');
				else
					fetch_web_data('http://www.stopforumspam.com/add', 'username=' . $row['member_name'] . '&ip_addr=' . $row['member_ip'] . '&email=' . $row['email_address'] . '&api_key=' . $modSettings['stopspammer_api_key']);
			}
			else
			{
				$is_spammer = checkDBSpammer($row['member_ip'], $row['member_name'], $row['email_address']);
				if ($row['is_spammer'] != $is_spammer)
				{
					// This change from Tom Mortensen sort the bug reported by him:
					//		Once a member wass marked "yellow" (is_spammer==8) because the mod
					//		could not access SFS database, that member was always "yellow".
					if ($is_spammer)
						++$modSettings['stopspammer_count'];
					updateMemberData($row['id_member'], array('is_activated' => 3, 'is_spammer' => $is_spammer));
				}
			}
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

/*
	stopspammer_test_mod_ok()
		Checks if the mod is enabled, if it can make connection with stopforumspam and if it's up-to-date
		Returns a <div> with different colors and messages
 */
function stopspammer_test_mod_ok()
{
	global $txt, $modSettings, $sourcedir;
	
	// Check first if it's enabled
	if ($modSettings['stopspammer_enable'] == 1)
	{
		require_once($sourcedir . '/Subs-Package.php');
		
		// Check connection
		$lookup = checkDBSpammer('127.0.0.1', 'Test_Conection_DB', 'xxx@xxx.com', true);
		
		$txt['stopspammer_faildb_sub'] = $lookup ? '<span style="color: #008000">' . $txt['stopspammer_faildb1_sub'] . '</span>' : '<span class="error">'.$txt['stopspammer_faildb2_sub'].$txt['stopspammer_not_translate'].'</span>';
		
		// Check version
		$internal_version = '2.3.9';
		$remote = 'http://www.snoopyvirtualstudio.com/update_stopspammer.php';
		$updated_version = fetch_web_data($remote);
		
		if ($updated_version && version_compare($internal_version, $updated_version, '<'))
		{
			// There is a new version
			$string = '<div style="background-color:red; font-weight: bold; color:#fff;">'. $txt['stopspammer_new_version_1']. '</div>'. $txt['stopspammer_new_version_2']. '<strong>'. $internal_version. '</strong><br />'. $txt['stopspammer_new_version_3']. '<strong>'. $updated_version. '</strong>';
		}
		else if (!$lookup)
		{
			// Something wrong with the connection
			$string = '<div style="background-color:yellow; font-weight: bold; color:#000;">'. $txt['stopspammer_no_connect_1']. '</div>'. $txt['stopspammer_no_connect_2'];
		}
		else
		{
			// All OK
			$string = '<div style="background-color:green; font-weight: bold; color:#fff;">'. $txt['stopspammer_all_ok']. '</div>';
		}
	}
	else
	{
		// Mod is OFF
		$string = '<div style="background-color:red; font-weight: bold; color:#fff;">'. $txt['stopspammer_is_off']. '</div>';
	}
	
	return $string;
}
?>
