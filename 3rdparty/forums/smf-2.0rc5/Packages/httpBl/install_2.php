<?php
/*
	<id>snoopy_virtual:httpBL</id>
	<name>httpBL</name>
	<version>2.5.1</version>
*/
global $smcFunc, $db_prefix, $context, $db_name, $db_type, $sourcedir, $themedir, $boarddir;

if (file_exists(dirname(__FILE__) . '/SSI.php') && !defined('SMF'))
	require_once(dirname(__FILE__) . '/SSI.php');
elseif (!defined('SMF')) die('<strong>Error:</strong> Cannot install - please verify you put this in the same place as SMF\'s index.php.');

if (SMF == 'SSI' && !$context['user']['is_admin']) die('Admin priveleges required.');

if (SMF == 'SSI')
	echo 'Making the database changes needed for mod httpBL<br />
	Please wait...<br />...<br />...<br />';

db_extend('packages');

$smcFunc['db_insert']('ignore',
			'{db_prefix}settings',
			array('variable' => 'string','value' => 'string'),
			array(
				array ('httpBL_enable' ,'0'),
				array ('httpBL_honeyPot_key',''),
				array ('httpBL_honeyPot_link',''),
				array ('httpBL_honeyPot_word',''),
				array ('httpBL_info_email_1','info'),
				array ('httpBL_info_email_2',''),
				array ('httpBL_info_email_3','com'),
				array ('httpBL_bad_last_activity','90'),
				array ('httpBL_bad_threat','10'),
				array ('httpBL_very_bad_threat','30'),
				array ('httpBL_cache_length','5'),
				array ('httpBL_cookie_length','24'),
				array ('httpBL_viewlog_extra','0'),
				array ('httpBL_view_os_whosonline','0'),
				array ('httpBL_use_two_languages','1'),
				array ('httpBL_horizontal_separator','<hr />'),
				array ('httpBL_count','0')
			),
			array()
		);

// Let's see if we are updating from v.2.2
$updating = false;

// This will work only in mysql, but it's not too important anyway
// TODO: Find a way to do it as well with postgresql and sqlite
//		maybe using the information_schema.tables
if ($db_type == "mysql")
{
	$query_old_table = $smcFunc['db_query']('', '
		SHOW TABLES FROM `'.$db_name.'` LIKE {string:table_name}',
		array(
			'table_name' => '%log_httpBL',
		)
	);
	$old_table_exists = $smcFunc['db_num_rows']($query_old_table);
	$smcFunc['db_free_result']($query_old_table);

	if ($old_table_exists)
	{
		$result = $smcFunc['db_query']('', '
			DESCRIBE {db_prefix}log_httpBL errorNumber',
			array(
			)
		);
	
		$updating = $smcFunc['db_num_rows']($result) == 0;
		$smcFunc['db_free_result']($result);
	}
}

if ($updating)
{
	// If we are updating we have httpBL_count = 0
	// A good guess of the spammers stopped until now is the highest number in
	//		column ID in table log_httpBL
	$request = $smcFunc['db_query']('', '
		SELECT ID
		FROM {db_prefix}log_httpBL
		ORDER BY ID DESC
		LIMIT 1',
		array(
		)
	);
	
	if ($row = $smcFunc['db_fetch_row']($request))
		$httpBL_stopped = (string)$row[0];
	else
		$httpBL_stopped = '0';
	$smcFunc['db_free_result']($request);
	
	if ($httpBL_stopped != '0')
		$smcFunc['db_query']('', '
			UPDATE {db_prefix}settings
			SET value = {string:value}
			WHERE variable = {string:variable}',
			array(
				'value' => $httpBL_stopped,
				'variable' => 'httpBL_count',
			)
		);
}

$smcFunc['db_create_table'](
			'{db_prefix}log_httpBL',
			array (
				array (
					'name' => 'ID',
					'type' => 'mediumint',
					'size' => '8',
					'unsigned' => 'unsigned',
					'null' => '',
					'auto' => 'auto_increment'
					),
				array (
					'name' => 'logTime',
					'type' => 'int',
					'size' => '10',
					'unsigned' => 'unsigned',
					'null' => '',
					'default' => 0
					),
				array (
					'name' => 'ip',
					'type' => 'char',
					'size' => '16',
					'null' => '',
					'default' => ''
					),
				array (
					'name' => 'threat',
					'type' => 'mediumint',
					'size' => '6',
					'unsigned' => 'unsigned',
					'null' => '',
					'default' => 0
					),
				array (
					'name' => 'last_activity',
					'type' => 'mediumint',
					'size' => '6',
					'unsigned' => 'unsigned',
					'null' => '',
					'default' => 0
					),
				array (
					'name' => 'suspicious',
					'type' => 'tinyint',
					'size' => '1',
					'unsigned' => 'unsigned',
					'null' => '',
					'default' => 0
					),
				array (
					'name' => 'harvester',
					'type' => 'tinyint',
					'size' => '1',
					'unsigned' => 'unsigned',
					'null' => '',
					'default' => 0
					),
				array (
					'name' => 'comment',
					'type' => 'tinyint',
					'size' => '1',
					'unsigned' => 'unsigned',
					'null' => '',
					'default' => 0
					),
				array (
					'name' => 'url',
					'type' => 'text',
					'null' => ''
					),
				array (
					'name' => 'user_agent',
					'type' => 'text',
					'null' => ''
					),
				array (
					'name' => 'error',
					'type' => 'text',
					'null' => ''
					),
				array (
					'name' => 'errorNumber',
					'type' => 'mediumint',
					'size' => '6',
					'unsigned' => 'unsigned',
					'null' => '',
					'default' => 0
					),
				array (
					'name' => 'username',
					'type' => 'varchar',
					'size' => '80',
					'null' => '',
					'default' => ''
					),
				array (
					'name' => 'raw',
					'type' => 'char',
					'size' => '16',
					'null' => '',
					'default' => ''
					),
				array (
					'name' => 'stopped',
					'type' => 'tinyint',
					'size' => '1',
					'unsigned' => 'unsigned',
					'null' => '',
					'default' => 0
					)
			),
			array (
				array (
					'columns' => array ('ID'),
					'type' => 'primary'
					)
			),
			'',
			'update'
		);

if (function_exists('chmod'))
{
	@chmod("$sourcedir/httpBL_Subs.php", 0644);
	@chmod("$sourcedir/httpBL_2_Config.php", 0644);
	@chmod("$themedir/httpBL.template.php", 0644);
	@chmod("$themedir/httpBL_css.css", 0644);
	@chmod("$boarddir/warning.php", 0644);
	@chmod("$boarddir/warning_css.css", 0644);
}

if (SMF == 'SSI')
	echo 'Database changes done.<br />
	Please remember to delete this file install_2.php from your server.';
?>
