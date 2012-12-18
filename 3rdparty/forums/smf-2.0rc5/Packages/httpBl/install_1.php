<?php
/*
	<id>snoopy_virtual:httpBL</id>
	<name>httpBL</name>
	<version>2.5.1</version>
*/
global $db_prefix, $context, $db_name, $sourcedir, $themedir, $boarddir;

if (file_exists(dirname(__FILE__) . '/SSI.php') && !defined('SMF'))
	require_once(dirname(__FILE__) . '/SSI.php');
elseif (!defined('SMF')) die('<strong>Error:</strong> Cannot install - please verify you put this in the same place as SMF\'s index.php.');

if (SMF == 'SSI' && !$context['user']['is_admin']) die('Admin priveleges required.');

if (SMF == 'SSI')
	echo 'Making the database changes needed for mod httpBL<br />
	Please wait...<br />...<br />...<br />';

db_query("INSERT IGNORE INTO
	{$db_prefix}settings
		(variable, value)
	VALUES	('httpBL_enable','0'),
			('httpBL_honeyPot_key',''),
			('httpBL_honeyPot_link',''),
			('httpBL_honeyPot_word',''),
			('httpBL_info_email_1','info'),
			('httpBL_info_email_2',''),
			('httpBL_info_email_3','com'),
			('httpBL_bad_last_activity','90'),
			('httpBL_bad_threat','10'),
			('httpBL_very_bad_threat','30'),
			('httpBL_cache_length','5'),
			('httpBL_cookie_length','24'),
			('httpBL_viewlog_extra','0'),
			('httpBL_view_os_whosonline','0'),
			('httpBL_use_two_languages','1'),
			('httpBL_horizontal_separator','<hr />'),
			('httpBL_count','0')
	", __FILE__, __LINE__);

db_query("CREATE TABLE IF NOT EXISTS
	{$db_prefix}log_httpBL (
		ID mediumint(8) unsigned NOT NULL AUTO_INCREMENT,
		logTime int(10) unsigned NOT NULL default 0,
		ip char(16) NOT NULL default '',
		threat mediumint(6) unsigned NOT NULL default 0,
		last_activity mediumint(6) unsigned NOT NULL default 0,
		suspicious tinyint(1) unsigned NOT NULL default 0,
		harvester tinyint(1) unsigned NOT NULL default 0,
		comment tinyint(1) unsigned NOT NULL default 0,
		url text NOT NULL,
		user_agent text NOT NULL,
		error text NOT NULL,
		errorNumber mediumint(6) unsigned NOT NULL default 0,
		username varchar(80) NOT NULL default '',
		raw char(16) NOT NULL default '',
		stopped tinyint(1) unsigned NOT NULL default 0,
		PRIMARY KEY(ID)
	)", __FILE__, __LINE__);

// Let's see if we are updating from v.2.2
$updating = false;

$query_old_table = db_query("SHOW TABLES 
	FROM `$db_name`
	LIKE '%log_httpBL'
	",__FILE__,__LINE__);
$old_table_exists = mysql_num_rows($query_old_table);
mysql_free_result($query_old_table);

if ($old_table_exists)
{
	$result = db_query("DESCRIBE
		{$db_prefix}log_httpBL errorNumber
		",__FILE__,__LINE__);
	
	$updating = !mysql_num_rows($result);
	mysql_free_result($result);
}

if ($updating)
{
	// If we are updating from v.2.2 we have 4 missing columns
	db_query("ALTER TABLE
		{$db_prefix}log_httpBL
		ADD COLUMN errorNumber mediumint(6) unsigned NOT NULL default 0,
		ADD COLUMN username varchar(80) NOT NULL default '',
		ADD COLUMN raw char(16) NOT NULL default '',
		ADD COLUMN stopped tinyint(1) unsigned NOT NULL default 0
		", __FILE__, __LINE__);
	
	// If we are updating we also have httpBL_count = 0
	// A good guess of the spammers stopped until now is the highest number in
	//	column ID in table log_httpBL
	$request = db_query("
		SELECT ID
		FROM {$db_prefix}log_httpBL
		ORDER BY ID DESC
		LIMIT 1
		", __FILE__, __LINE__);
	if ($row = mysql_fetch_row($request))
		$httpBL_stopped = $row[0];
	else
		$httpBL_stopped = 0;
	mysql_free_result($request);
	if ($httpBL_stopped != 0)
		db_query("
			UPDATE {$db_prefix}settings
			SET value = '$httpBL_stopped'
			WHERE variable = 'httpBL_count'
			LIMIT 1", __FILE__, __LINE__);
}

if (function_exists('chmod'))
{
	@chmod("$sourcedir/httpBL_Subs.php", 0644);
	@chmod("$sourcedir/httpBL_Config.php", 0644);
	@chmod("$themedir/httpBL.template.php", 0644);
	@chmod("$themedir/httpBL_css.css", 0644);
	@chmod("$boarddir/warning.php", 0644);
	@chmod("$boarddir/warning_css.css", 0644);
}

if (SMF == 'SSI')
	echo 'Database changes done.<br />
	Please remember to delete this file install_1.php from your server.';
?>
