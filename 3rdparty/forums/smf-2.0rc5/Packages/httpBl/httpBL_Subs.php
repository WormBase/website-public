<?php
/**********************************************************************************
* httpBL_Subs.php                                                                 *
***********************************************************************************
* MOD to stop spammers from accesisng any SMF forum                               *
* Modification Version:       MOD httpBL 2.5.1                                    *
* Made by:                    Snoopy (http://www.snoopyvirtualstudio.com)         *
* Copyleft 2009 by:     	  Snoopy (http://www.snoopyvirtualstudio.com)         *
* =============================================================================== *
* SMF: Simple Machines Forum                                                      *
* Open-Source Project Inspired by Zef Hemel (zef@zefhemel.com)                    *
* =============================================================================== *
* Software Version:           SMF 1.1.12 and SMF 2.0 RC4                          *
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

/*  
	Some of the functions in this file had been developed by me based on the ideas from
		Project Honey Pot message board. Mainly from this thread:
			http://www.projecthoneypot.org/board/read.php?f=10&i=1&t=1
		and also from the Drupal http:BL MOD made by praseodym at
			http://drupal.org/project/httpBL
	
	Others are original from me, helped by people from SMF forums
 */

/*  
	Functions in this file:
	
	httpBL_setPassCookie($ip)
		Create a cookie valid for as many hours as set in config page (default 24h)
		Add all the cookie data to $_SESSION too, in case cookies are off
	
	httpBL_checkPassCookie($ip)
		Check if this IP have our cookie (or our $_SESSION) and if it's valid
		Return true if cookie (or $_SESSION) found and validated, false otherwise
		
	httpBL_session_put_data($session_name, $data, $seconds)
		Store data in cache if it's enabled
		Also store $data in $_SESSION[$session_name] just in case cache is off or not working properly
		This data will be valid only for a fix amount of $seconds
		
	httpBL_session_get_data($session_name, $seconds)
		Retrieves data from cache if it's enabled
		Also retrieves data from $_SESSION[$session_name] just in case cache is off or not working properly
		If the data is no longer valid or $_SESSION[$session_name] doesn't exists, returns ''
	
	httpBL_logme($response, $return = false)
		Everytime we block a spammer or there is an error this
		function store the data in the table log_httpBL
		It returns the ID of the entry if return is true
	
	httpBL_update_log($ID, $stopped, $errorNumber)
		Change an entry in the log after they have seen the warning.php page
	
	httpBL_check_data($values, $log_it = false)
		Checks if the data in $values belongs to a bad one or not.
		Returns false if it's a good one or the updated $values is it's a bad one.
		Also send $values to the log if $log_it = true
	
	httpBL_captcha($last_answer = 0)
		Return a random question and its answer
		always different than the last one
	
	httpBL_look_for_empty_ip($ip)
		We have tried already to get the IP with $_SERVER['REMOTE_ADDR']
		If this is empty let's try with the rest of the methods I know about
		If anybody knows more methods please tell me
	
	httpBL_get_real_ip_address()
		New method sent by butchs http://www.snoopyvirtualstudio.com/foro/index.php?topic=362.0
	
	httpBl_get_env($htvars)
		Needed for function httpBl_get_real_ip_address()
		sent by butchs http://www.snoopyvirtualstudio.com/foro/index.php?topic=362.0
	
	httpBL_reverse_ip($ip)
		Reverse IP octets
	
	httpBL_dnslookup($ip, $key = NULL)
		Do http:BL DNS lookup
	
	httpBL_honeyLink($link, $word = 'anything')
		Return HTML code with hidden Honeypot link
		in one of the many styles.
	
	httpBL_test_mod_ok()
		Checks if the mod is enabled, if it can make connection with HoneyPot and if it's up-to-date
		Returns a <div> with different colors and messages
 */

/* ensure this file is being included by a parent file and stop direct linking */
defined( 'SMF' ) or die( 'Direct Access to this location is not allowed.' );


/*
	httpBL_setPassCookie($ip)
		Create a cookie valid for as many hours as set in config page (default 24h)
		Add all the cookie data to $_SESSION too, in case cookies are off
 */
function httpBL_setPassCookie($ip)
{
	global $boardurl, $sourcedir, $modSettings;
	
	$hours = isset($modSettings['httpBL_cookie_length']) && $modSettings['httpBL_cookie_length'] != '' ? (int)$modSettings['httpBL_cookie_length'] : 24;
	$cookie_length = $hours * 3600;
	$ip = empty($ip) ? '0.0.0.0' : $ip;
	$cookiename = md5($boardurl . 'httpBL' . $ip);
	$data = serialize(array($ip, time() + $cookie_length, 'ok'));
	
	require_once($sourcedir . '/Subs-Auth.php');
	// I'm going to set this cookie global just now. We will see in future versions.
	// TO DO: See if we don't get any problem here
	$cookie_url = url_parts(false, true);
	setcookie($cookiename, $data, time() + $cookie_length, $cookie_url[1], $cookie_url[0], 0);

	// Any alias URLs?  This is mainly for use with frames, etc.
	// TO DO: See what happen in this case
	
	$_COOKIE[$cookiename] = $data;
	$_SESSION[$cookiename] = $data;
}



/*
	httpBL_checkPassCookie($ip)
		Check if this IP have our cookie (or our $_SESSION) and if it's valid
		Return true if cookie (or $_SESSION) found and validated, false otherwise
 */
function httpBL_checkPassCookie($ip)
{
	global $boardurl, $modSettings;
	
	$ip = empty($ip) ? '0.0.0.0' : $ip;
	$cookiename = md5($boardurl . 'httpBL' . $ip);
	
	if (!isset($_COOKIE[$cookiename]) && !isset($_SESSION[$cookiename]))
		return false;
	
	if (!isset($_SESSION[$cookiename]))
		list ($cookie_ip, $timeout, $cookie_ok) = @unserialize(stripslashes($_COOKIE[$cookiename]));
	else
		list ($cookie_ip, $timeout, $cookie_ok) = @unserialize(stripslashes($_SESSION[$cookiename]));
	
	if ($cookie_ip != $ip || $cookie_ok != 'ok')
		return false;
	
	// Where did you get an expired cookie?
	if ($timeout <= time())
		return false;
	
	return true;
}



/*
	httpBL_session_put_data($session_name, $data, $seconds)
		Store data in cache if it's enabled
		Also store $data in $_SESSION[$session_name] just in case cache is off or not working properly
		This data will be valid only for a fix amount of $seconds
 */
function httpBL_session_put_data($session_name, $data, $seconds)
{
	global $modSettings;
	
	// Put the data in the cache if it's enabled.
	if (!empty($modSettings['cache_enable']))
		cache_put_data($session_name, $data, $seconds);
	
	// Now put it also in $_SESSION
	$expire = time() + $seconds;
	$_SESSION[$session_name]['data'] = $data;
	$_SESSION[$session_name]['expire'] = $expire;
}


/*
	httpBL_session_get_data($session_name, $seconds)
		Retrieves data from cache if it's enabled
		Also retrieves data from $_SESSION[$session_name] just in case cache is off or not working properly
		If the data is no longer valid or $_SESSION[$session_name] doesn't exists, returns ''
 */
function httpBL_session_get_data($session_name, $seconds)
{
	global $modSettings;
	
	// Try $_SESSION first.
	if (isset($_SESSION[$session_name]['expire']))
	{
		$expire = (int)$_SESSION[$session_name]['expire'];
		if (time() >= $expire)
			return '';
	}
	else
		$data = '';
	
	if (isset($_SESSION[$session_name]['data']))
	{
		$data = $_SESSION[$session_name]['data'];
		return $data;
	}
	else
		$data = '';
	
	// Now try the cache if it's enabled and we haven't got any data yet.
	if (!empty($modSettings['cache_enable']) && $data == '')
		$data = cache_get_data($session_name, $seconds);
	
	return $data;
}



/*
	httpBL_logme($response, $return = false)
		Everytime we block a spammer or there is an error this
		function store the data in the table log_httpBL
		It returns the ID of the entry if return is true
 */
function httpBL_logme($response, $return = false)
{
	global $db_prefix, $smcFunc, $modSettings;
	
	// Caught one more
	$modSettings['httpBL_count'] = (int)$modSettings['httpBL_count'];
	++$modSettings['httpBL_count'];
	updateSettings(array('httpBL_count' => (string)$modSettings['httpBL_count']), true);
	
	$ip				= empty($response['ip']) ? '' : (string)$response['ip'] ;
	$threat			= empty($response['threat']) ? 0 : (int)$response['threat'] ;
	$last_activity	= empty($response['last_activity']) ? 0 : (int)$response['last_activity'] ;
	$suspicious		= empty($response['suspicious']) ? 0 : (int)$response['suspicious'] ;
	$harvester		= empty($response['harvester']) ? 0 : (int)$response['harvester'] ;
	$comment		= empty($response['comment_spammer']) ? 0 : (int)$response['comment_spammer'] ;
	$url			= empty($response['url']) ? '' : (string)$response['url'] ;
	$user_agent		= empty($response['user_agent']) ? '' : (string)$response['user_agent'] ;
	$errorNumber	= empty($response['errorNumber']) ? 0 : (int)$response['errorNumber'] ;
	$username		= empty($response['username']) ? '' : (string)$response['username'] ;
	$raw			= empty($response['raw']) ? '' : (string)$response['raw'] ;
	$stopped		= empty($response['stopped']) ? 0 : (int)$response['stopped'] ;

	// If we are in SMF 1.x
	if (empty($smcFunc['db_query']))
	{
	db_query("
		INSERT INTO {$db_prefix}log_httpBL
			(logTime, ip, threat, last_activity, suspicious, harvester, comment, url, user_agent, errorNumber, username, raw, stopped)
		VALUES (" . time() . ", '$ip', $threat, $last_activity, $suspicious, $harvester, $comment, '$url', '$user_agent', $errorNumber, '$username', '$raw', $stopped)", __FILE__, __LINE__);
		
		if ($return)
		{
			$request = db_query("
				SELECT ID
				FROM {$db_prefix}log_httpBL
				ORDER BY logTime DESC
				LIMIT 1", __FILE__, __LINE__);
			if ($row = mysql_fetch_row($request))
				$ID = $row[0];
			else
				$ID = 0;
			mysql_free_result($request);
			return $ID;
		}
	}
	else
	{
		// Do it 2.0 way
		$time = time();
		$smcFunc['db_insert']('insert',
			'{db_prefix}log_httpBL',
			array(
				'logTime' => 'int', 'ip' => 'string', 'threat' => 'int', 'last_activity' => 'int', 
				'suspicious' => 'int', 'harvester' => 'int', 'comment' => 'int', 'url' => 'string', 
				'user_agent' => 'string', 'errorNumber' => 'int', 'username' => 'string', 
				'raw' => 'string', 'stopped' => 'int'
			),
			array(
				$time, $ip, $threat, $last_activity, 
				$suspicious, $harvester, $comment, $url, 
				$user_agent, $errorNumber, $username, 
				$raw, $stopped
			),
			array()
		);
		
		if ($return)
		{
			$request = $smcFunc['db_query']('', '
				SELECT ID
				FROM {db_prefix}log_httpBL
				ORDER BY logTime DESC
				LIMIT 1',
				array(
				)
			);
			if ($row = $smcFunc['db_fetch_row']($request))
				$ID = (int)$row[0];
			else
				$ID = 0;
			$smcFunc['db_free_result']($request);
			return $ID;
		}
	}
}



/*
	httpBL_update_log($ID, $stopped, $errorNumber)
		Change an entry in the log after they have seen the warning.php page
 */
function httpBL_update_log($ID, $stopped, $errorNumber)
{
	global $db_prefix, $smcFunc, $modSettings;
	
	if ($ID == 0)
	{
		/* TO DO
		 * I suppose ID can never be 0 unless there is a mistake with the DB
		 * Find out what to do if that happen.
		 */
		/* From version 2.4 onwards ID can be 0 if we are just watching the warning.php design
		 * In this case we don't need to update anything in the logs.
		 */
		return;
	}
	
	if ($stopped == 0)
	{
		// If they have proved they are humans we haven't caught them
		$modSettings['httpBL_count'] = (int)$modSettings['httpBL_count'];
		--$modSettings['httpBL_count'];
		// Just in case
		if ($modSettings['httpBL_count'] < 0)
			$modSettings['httpBL_count'] = 0;
		updateSettings(array('httpBL_count' => (string)$modSettings['httpBL_count']), true);
	}
	
	// If we are in SMF 1.x
	if (empty($smcFunc['db_query']))
	{
		db_query("
			UPDATE {$db_prefix}log_httpBL
			SET stopped = $stopped,
				errorNumber = $errorNumber
			WHERE ID = $ID
			LIMIT 1", __FILE__, __LINE__);
	}
	else
	{
		// Do it 2.0 way
		$smcFunc['db_query']('', '
			UPDATE {db_prefix}log_httpBL
			SET stopped = {int:stopped}, errorNumber = {int:errorNumber}
			WHERE ID = {int:ID}
			LIMIT 1',
			array(
				'stopped' => $stopped,
				'errorNumber' => $errorNumber,
				'ID' => $ID,
			)
		);
	}
}


/*
	httpBL_check_data($values, $log_it = false)
		Checks if the data in $values belongs to a bad one or not.
		Returns false if it's a good one or the updated $values is it's a bad one.
		Also send $values to the log, cache and session if $log_it = true
 */
function httpBL_check_data($values, $log_it = false)
{
	global $modSettings, $httpBL_session, $cache_seconds;
	
	if (isset($values['search_engine']) && $values['search_engine'] == 1)
	{
		// Known robot. You can pass.
		if ($log_it)
		{
			// No need to log the data of a known robot.
			// Just put it in the cache and $_SESSION
			httpBL_session_put_data($httpBL_session, $values, $cache_seconds);
		}
		return false;
	}
	
	if (isset($values['last_activity']) && (int)$values['last_activity'] >= (int)$modSettings['httpBL_bad_last_activity'])
	{
		// Last activity too long ago
		// Let the visitor pass, but log the error if $log_it is true.
		if ($log_it)
		{
			$values['stopped'] = 0;
			$values['errorNumber'] = 6;
			httpBL_logme($values, false);
			httpBL_session_put_data($httpBL_session, $values, $cache_seconds);
		}
		return false;
	}
	
	if (isset($values['threat']) && (int)$values['threat'] <= (int)$modSettings['httpBL_bad_threat'])
	{
		// Threat Level too low
		// Let the visitor pass, but log the error if $log_it is true.
		if ($log_it)
		{
			$values['stopped'] = 0;
			$values['errorNumber'] = 7;
			httpBL_logme($values, false);
			httpBL_session_put_data($httpBL_session, $values, $cache_seconds);
		}
		return false;
	}
	
	if (isset($values['errorNumber']) && ((int)$values['errorNumber'] == 201 || (int)$values['errorNumber'] == 202))
	{
		// Something wrong again with the API key or the first octet
		// Let the visitor pass, but log the error if $log_it is true.
		if ($log_it)
		{
			$values['stopped'] = 2;
			httpBL_logme($values, false);
			httpBL_session_put_data($httpBL_session, $values, $cache_seconds);
		}
		return false;
	}
	
	$values['stopped'] = 1;
	if ($values['ip'] == '')
		$values['errorNumber'] = 150;
	else
		$values['errorNumber'] = 100;
	if ($log_it)
	{
		$values['ID'] = httpBL_logme($values, true);
		httpBL_session_put_data($httpBL_session, $values, $cache_seconds);
	}
	return $values;
}



/*
	httpBL_captcha($last_answer = 0)
		Return a random question and its answer
		Always different than the last one
 */
function httpBL_captcha($last_answer = 0)
{
	$captcha = array(
		array(),
		array(
			'question' => '0 + 1 = ',
			'answer' => '1'
		),
		array(
			'question' => '1 + 1 = ',
			'answer' => '2'
		),
		array(
			'question' => '2 + 1 = ',
			'answer' => '3'
		),
		array(
			'question' => '2 + 2 = ',
			'answer' => '4'
		),
		array(
			'question' => '3 + 2 = ',
			'answer' => '5'
		),
		array(
			'question' => '4 + 2 = ',
			'answer' => '6'
		),
		array(
			'question' => '4 + 3 = ',
			'answer' => '7'
		)
	);
	
	$new_answer = mt_rand(1, 7);
	while ($new_answer == $last_answer)
		$new_answer = mt_rand(1, 7);
	
	return $captcha[$new_answer];
}


/*
	httpBL_look_for_empty_ip($ip)
		We have tried already to get the IP with $_SERVER['REMOTE_ADDR']
		If this is empty let's try with the rest of the methods I know about
		If anybody knows more methods please tell me
		I have changed this function from version 2.4.1 to mix it with the functions
			-httpBL_get_real_ip_address()
			-httpBl_get_env()
		Both sent by butchs http://www.snoopyvirtualstudio.com/foro/index.php?topic=362.0
 */
function httpBL_look_for_empty_ip($ip)
{
	if ($ip == '')
		$ip = httpBl_get_env('REMOTE_ADDR');
	if ($ip == '')
		$ip = httpBl_get_env('BAN_CHECK_IP');
	if ($ip == '')
		$ip = httpBl_get_env('HTTP_VIA');
	if ($ip == '')
		$ip = httpBl_get_env('HTTP_CLIENT_IP');
	if ($ip == '')
		$ip = httpBl_get_env('HTTP_PROXY_CONNECTION');
	if ($ip == '')
		$ip = httpBl_get_env('HTTP_X_FORWARDED_FOR');
	if ($ip == '')
		$ip = httpBl_get_env('HTTP_X_FORWARDED');
	if ($ip == '')
		$ip = httpBl_get_env('HTTP_FORWARDED_FOR');
	if ($ip == '')
		$ip = httpBl_get_env('HTTP_FORWARDED');
	if ($ip == '')
		$ip = httpBl_get_env('X_HTTP_FORWARDED_FOR');
	if ($ip == '')
		$ip = httpBl_get_env('X_FORWARDED_FOR');
	if ($ip == '')
		$ip = httpBl_get_env('FORWARDED_FOR');
	if ($ip == '')
		$ip = httpBl_get_env('REMOTE_HOST');

	// The X-Forwarded-for header might contain multiple addresses (comma separated),
	// 		if the request was forwarded through multiple proxies.
	// Thanks to Romeo  http://www.webmasterworld.com/php/3212979.htm  #:3213118
	// If so, just get the first one not empty.
		/* TO DO
		 * As I haven't seen this case yet, I'm supposing the first one is the original IP.
		 * I'm not interested in all the proxies it may has passed. (?) Why not?
		 * Need to find out if the original IP is the first one or the last one.
		 * (?) Maybe we should check all of them separately anyway.
		 */
	if ($ip != '' && strpos($ip, ',') !== false)
	{
		$ip = explode(',', $ip);
		for ($i=0; $i<=count($ip); $i++)
		{
			$ip = $ip[$i];
			if ($ip != '')
				return $ip;
		}
	}
	
	return $ip;
}


/*
	httpBl_get_env($htvars)
		Needed for function httpBl_get_real_ip_address()
		sent by butchs http://www.snoopyvirtualstudio.com/foro/index.php?topic=362.0
 */
function httpBl_get_env($htvars)
{
	if (isset($_SERVER[$htvars])  && $_SERVER[$htvars] != '')
		return strip_tags($_SERVER[$htvars]);
	elseif (isset($_ENV[$htvars]) && $_ENV[$htvars] != '')
		return strip_tags($_ENV[$htvars]);
	elseif (isset($HTTP_SERVER_VARS[$htvars]) && $HTTP_SERVER_VARS[$htvars] != '')
		return strip_tags($HTTP_SERVER_VARS[$htvars]);
	elseif (getenv($htvars) && getenv($htvars) != '')
		return strip_tags(getenv($htvars));
	elseif (function_exists('apache_getenv') && apache_getenv($htvars, true))
		if (strip_tags(apache_getenv($htvars, true)) != '')
			return strip_tags(apache_getenv($htvars, true));
	return '';
}





/*
	httpBL_reverse_ip($ip)
		Reverse IP octets
 */
function httpBL_reverse_ip($ip)
{
	if (!is_numeric(str_replace('.', '', $ip)))
		return NULL;
	
	$ip = explode('.', $ip);
	
	if (count($ip) != 4)
		return NULL;
	
	return $ip[3] .'.'. $ip[2] .'.'. $ip[1] .'.'. $ip[0];
}


/*
	httpBL_dnslookup($ip, $key = NULL)
		Do http:BL DNS lookup
 */
function httpBL_dnslookup($ip, $key = NULL)
{
	// Thanks to J.Wesley2 at
	// http://www.projecthoneypot.org/board/read.php?f=10&i=1&t=1
	// Also thanks to praseodym at
	// http://drupal.org/project/httpBL
	global $txt, $modSettings, $user_info, $httpBL_session, $cache_seconds;

	// Don't continue if it's somebody with a free pass
	// Continue only when doing a test connection
	if (allowedTo('httpBL_free_pass') && $ip != '127.1.80.1')
		return false;

	// Apparently sometimes $_SERVER['REMOTE_ADDR'] add white space
	// Wouldn't do any harm trimming it just in case
	$ip = trim($ip);
	
	$ip_temp = $ip;

	// Let's see if this IP got our cookie
	if (httpBL_checkPassCookie($ip) === true && $ip != '127.1.80.1')
		return false;

	// Before we look in the Proyect Honey Pot db let's see if we already got information about
	//	 this IP in the cache if it's enabled.
	//	 That will save lots of hostname lookups if a site is very very busy.
	//	 (thanks to the member of the Customization Team who gave me the idea whatever his/her name was)
	$response = '';
	if ($ip == 'unknown' || $ip == '')
		$ip = '';
	$ip2 = str_replace('.', '-', $ip);
	$httpBL_session = 'httpBL-response-' . $ip2;
	$cache_minutes = $modSettings['httpBL_cache_length'] >= 1 ? (int)$modSettings['httpBL_cache_length'] : 5;
	$cache_seconds = $cache_minutes * 60;
	if ($ip != '127.1.80.1' && $ip != '')
		$response = httpBL_session_get_data($httpBL_session, $cache_seconds);
		
	// If the data was already OK don't do anything else
	if (!is_array($response) && $response == 'ok')
		return false;
	else if (is_array($response) && !empty($response))
	{
		$check_data = httpBL_check_data($response, false);
		return $check_data;
	}
	else
		$response = ''; // Something wrong. Better to start again.
	
	// Initialize some values and add some more stuff you could log for further analysis
	$values = array();
	$httpBL_url = httpBL_get_env('REQUEST_URI');
	$values['url'] = $httpBL_url != '' ? $httpBL_url : '/';
	$httpBL_user_agent = httpBL_get_env('HTTP_USER_AGENT');
	$values['user_agent'] = $httpBL_user_agent != '' ? $httpBL_user_agent : $txt['httpBL_unknown'];
	$values['username'] = $user_info['is_guest'] ? $txt['guest'] : $user_info['username'];
	$values['stopped'] = 1;
	$values['raw'] = $txt['httpBL_unknown'];
	// If we ever get this error number something has gone really wrong
	$values['errorNumber'] = 300;

	// If $ip is empty let's try to find it with more methods
	if ($ip == '')
		$ip = httpBL_look_for_empty_ip();
	
	$values['ip'] = $ip;
	if ($values['ip'] == '')
	{
		// Still empty? Stop the visitor. Sorry, no blanks IPs allowed
		// TO DO: Find more methods or more possibilities why sometimes $ip is blank
		$values['errorNumber'] = 150;
		$values['ID'] = httpBL_logme($values, true);
		//httpBL_session_put_data($httpBL_session, $values, $cache_seconds);
		return $values;
	}
	else if ($ip != $ip_temp)
	{
		// If the IP has changed, let's see if this new IP got our cookie
		if (httpBL_checkPassCookie($ip) === true && $ip != '127.1.80.1')
			return false;
		// Let's check also session and cache.
		$ip2 = str_replace('.', '-', $ip);
		$httpBL_session = 'httpBL-response-' . $ip2;
		if ($ip != '127.1.80.1' && $ip != '')
			$response = httpBL_session_get_data($httpBL_session, $cache_seconds);
		
		if (!is_array($response) && $response == 'ok')
			return false;
		else if (is_array($response) && !empty($response))
		{
			$check_data = httpBL_check_data($response, false);
			return $check_data;
		}
		else
			$response = '';
	}

	// No data about this IP in the cache, in $_SESSION or cookies. Look in the Proyect Honey Pot db
	if ($response == '')
	{
		if (!$reverse_ip = httpBL_reverse_ip($ip))
		{
			// Something wrong with the IP
			// Let the visitor pass, but log the error
			$values['stopped'] = 2;
			$values['errorNumber'] = 200;
			httpBL_logme($values, false);
			return false;
		}
	
		if (!$key || $key == '')
		{
			// Something wrong with the API key
			// Let the visitor pass, but log the error and put the values in the cache and session
			$values['stopped'] = 2;
			$values['errorNumber'] = 201;
			httpBL_logme($values, false);
			httpBL_session_put_data($httpBL_session, $values, $cache_seconds);
			return false;
		}
	
		$query = $key .'.'. $reverse_ip .'.dnsbl.httpBL.org.';
		$response = gethostbyname($query);
	
		if ($response == $query)
		{
			// If the domain does not resolve then it will be the same thing we passed to gethostbyname
			/*
			 * TO DO
		 	 * Usually if the domain does not resolve it is because this IP is not in the Honey Pot database.
		 	 * We should consider any other possibilities though.
		 	 */
			// If we consider this IP OK, we should put it in the cache and $_SESSION
			if ($ip != '127.1.80.1')
				httpBL_session_put_data($httpBL_session, 'ok', $cache_seconds);
			return false;
		}
	}

	$values['raw'] = $response;
	$response = explode('.', $response);

	if ($response[0] != '127')
	{
		// If the first octet is not 127, the response should be considered invalid
		// Let the visitor pass, but log the error and put the values in the cache and session
		$values['stopped'] = 2;
		$values['errorNumber'] = 202;
		httpBL_logme($values, false);
		httpBL_session_put_data($httpBL_session, $values, $cache_seconds);
		return false;
	}

	$values['last_activity'] = $response[1];
	$values['threat'] = $response[2];
	$values['type'] = $response[3];

	// If it's 0 then there's only one thing it can be
	if ($response[3] == 0)
		$values['search_engine'] = 1;

	// Does it have the same bits as 1 set
	if ($response[3] & 1)
		$values['suspicious'] = 1;

	// Does it have the same bits as 2 set
	if ($response[3] & 2)
		$values['harvester'] = 1;

	// Does it have the same bits as 4 set
	if ($response[3] & 4)
		$values['comment_spammer'] = 1;

	if ($values['ip'] == '127.1.80.1')
	{
		// We are doing a test connection.
		// Don't log anything. Just return the values.
		return $values;
	}

	// Check the data, log it and put it in the cache and $_SESSION.
	$check_data = httpBL_check_data($values, true);
	return $check_data;
}



/*
	httpBL_honeyLink($link, $word = 'anything')
		Return HTML code with hidden Honeypot link
		in one of the many styles.
 */
function httpBL_honeyLink($link, $word = 'anything')
{
	global $txt;
	
	if (!$link || $link == '')
		return $txt['httpBL_honeyPot_link_error'];
	
	if ($word == '')
		$word = 'anything';
	
	switch (mt_rand(0, 5))
	{
		case 0:
			return '<div><a href="'. $link .'"><!-- '. $word .' --></a></div>';
		case 1:
			return '<div><a href="'. $link .'" style="display: none;">'. $word .'</a></div>';
		case 2:
			return '<div style="display: none;"><a href="'. $link .'">'. $word .'</a></div>';
		case 3:
			return '<div><a href="'. $link .'"></a></div>';
		case 4:
			return '<div><a href="'. $link .'"><span style="display: none;">'. $word .'</span></a></div>';
		default:
			return '<!-- <a href="'. $link .'">'. $word .'</a> -->';
	}
}



/*
	httpBL_error_message($errorNumber)
		Return an error message for every error number for the ViewLog page
 */
function httpBL_error_message($errorNumber)
{
	global $txt;
	
	if ($errorNumber == '')
		return $txt['httpBL_no_errorNumber'];
	
	$error = array(
		0 => array(
			'message' => '2 '. $txt['httpBL_answers_captcha']. '<br />2 '. $txt['httpBL_good']. ' - 0 '. $txt['httpBL_bad'],
			'class' => ''
		),
		1 => array(
			'message' => '3 '. $txt['httpBL_answers_captcha']. '<br />2 '. $txt['httpBL_good']. ' - 1 '. $txt['httpBL_bad'],
			'class' => ''
		),
		2 => array(
			'message' => '4 '. $txt['httpBL_answers_captcha']. '<br />2 '. $txt['httpBL_good']. ' - 2 '. $txt['httpBL_bad'],
			'class' => ''
		),
		3 => array(
			'message' => '5 '. $txt['httpBL_answers_captcha']. '<br />2 '. $txt['httpBL_good']. ' - 3 '. $txt['httpBL_bad'],
			'class' => ''
		),
		6 => array(
			'message' => $txt['httpBL_last_act_too_high'],
			'class' => ''
		),
		7 => array(
			'message' => $txt['httpBL_threat_too_low'],
			'class' => ''
		),
		50 => array(
			'message' => $txt['httpBL_empty_ip']. '<br />2 '. $txt['httpBL_answers_captcha']. '<br />2 '. $txt['httpBL_good']. ' - 0 '. $txt['httpBL_bad'],
			'class' => ''
		),
		51 => array(
			'message' => $txt['httpBL_empty_ip']. '<br />3 '. $txt['httpBL_answers_captcha']. '<br />2 '. $txt['httpBL_good']. ' - 1 '. $txt['httpBL_bad'],
			'class' => ''
		),
		52 => array(
			'message' => $txt['httpBL_empty_ip']. '<br />4 '. $txt['httpBL_answers_captcha']. '<br />2 '. $txt['httpBL_good']. ' - 2 '. $txt['httpBL_bad'],
			'class' => ''
		),
		53 => array(
			'message' => $txt['httpBL_empty_ip']. '<br />5 '. $txt['httpBL_answers_captcha']. '<br />2 '. $txt['httpBL_good']. ' - 3 '. $txt['httpBL_bad'],
			'class' => ''
		),
		100 => array(
			'message' => '0 '. $txt['httpBL_answers_captcha'],
			'class' => ''
		),
		101 => array(
			'message' => '1 '. $txt['httpBL_answer_captcha']. '<br />0 '. $txt['httpBL_good']. ' - 1 '. $txt['httpBL_bad'],
			'class' => ''
		),
		102 => array(
			'message' => '2 '. $txt['httpBL_answers_captcha']. '<br />0 '. $txt['httpBL_good']. ' - 2 '. $txt['httpBL_bad'],
			'class' => ''
		),
		103 => array(
			'message' => '3 '. $txt['httpBL_answers_captcha']. '<br />0 '. $txt['httpBL_good']. ' - 3 '. $txt['httpBL_bad'],
			'class' => ''
		),
		104 => array(
			'message' => '4 '. $txt['httpBL_answers_captcha']. '<br />0 '. $txt['httpBL_good']. ' - 4 '. $txt['httpBL_bad'],
			'class' => ''
		),
		110 => array(
			'message' => '1 '. $txt['httpBL_answer_captcha']. '<br />1 '. $txt['httpBL_good']. ' - 0 '. $txt['httpBL_bad'],
			'class' => ''
		),
		111 => array(
			'message' => '2 '. $txt['httpBL_answers_captcha']. '<br />1 '. $txt['httpBL_good']. ' - 1 '. $txt['httpBL_bad'],
			'class' => ''
		),
		112 => array(
			'message' => '3 '. $txt['httpBL_answers_captcha']. '<br />1 '. $txt['httpBL_good']. ' - 2 '. $txt['httpBL_bad'],
			'class' => ''
		),
		113 => array(
			'message' => '4 '. $txt['httpBL_answers_captcha']. '<br />1 '. $txt['httpBL_good']. ' - 3 '. $txt['httpBL_bad'],
			'class' => ''
		),
		114 => array(
			'message' => '5 '. $txt['httpBL_answers_captcha']. '<br />1 '. $txt['httpBL_good']. ' - 4 '. $txt['httpBL_bad'],
			'class' => ''
		),
		120 => array(
			'message' => '0 '. $txt['httpBL_answers_captcha']. '<br />'. $txt['httpBL_wrote_hiding'],
			'class' => ''
		),
		121 => array(
			'message' => '1 '. $txt['httpBL_answer_captcha']. '<br />0 '. $txt['httpBL_good']. ' - 1 '. $txt['httpBL_bad']. '<br />'. $txt['httpBL_wrote_hiding'],
			'class' => ''
		),
		122 => array(
			'message' => '2 '. $txt['httpBL_answers_captcha']. '<br />0 '. $txt['httpBL_good']. ' - 2 '. $txt['httpBL_bad']. '<br />'. $txt['httpBL_wrote_hiding'],
			'class' => ''
		),
		123 => array(
			'message' => '3 '. $txt['httpBL_answers_captcha']. '<br />0 '. $txt['httpBL_good']. ' - 3 '. $txt['httpBL_bad']. '<br />'. $txt['httpBL_wrote_hiding'],
			'class' => ''
		),
		130 => array(
			'message' => '1 '. $txt['httpBL_answer_captcha']. '<br />1 '. $txt['httpBL_good']. ' - 0 '. $txt['httpBL_bad']. '<br />'. $txt['httpBL_wrote_hiding'],
			'class' => ''
		),
		131 => array(
			'message' => '2 '. $txt['httpBL_answers_captcha']. '<br />1 '. $txt['httpBL_good']. ' - 1 '. $txt['httpBL_bad']. '<br />'. $txt['httpBL_wrote_hiding'],
			'class' => ''
		),
		132 => array(
			'message' => '3 '. $txt['httpBL_answers_captcha']. '<br />1 '. $txt['httpBL_good']. ' - 2 '. $txt['httpBL_bad']. '<br />'. $txt['httpBL_wrote_hiding'],
			'class' => ''
		),
		133 => array(
			'message' => '4 '. $txt['httpBL_answers_captcha']. '<br />1 '. $txt['httpBL_good']. ' - 3 '. $txt['httpBL_bad']. '<br />'. $txt['httpBL_wrote_hiding'],
			'class' => ''
		),
		150 => array(
			'message' => $txt['httpBL_empty_ip']. '<br />0 '. $txt['httpBL_answers_captcha'],
			'class' => ''
		),
		151 => array(
			'message' => $txt['httpBL_empty_ip']. '<br />1 '. $txt['httpBL_answer_captcha']. '<br />0 '. $txt['httpBL_good']. ' - 1 '. $txt['httpBL_bad'],
			'class' => ''
		),
		152 => array(
			'message' => $txt['httpBL_empty_ip']. '<br />2 '. $txt['httpBL_answers_captcha']. '<br />0 '. $txt['httpBL_good']. ' - 2 '. $txt['httpBL_bad'],
			'class' => ''
		),
		153 => array(
			'message' => $txt['httpBL_empty_ip']. '<br />3 '. $txt['httpBL_answers_captcha']. '<br />0 '. $txt['httpBL_good']. ' - 3 '. $txt['httpBL_bad'],
			'class' => ''
		),
		154 => array(
			'message' => $txt['httpBL_empty_ip']. '<br />4 '. $txt['httpBL_answers_captcha']. '<br />0 '. $txt['httpBL_good']. ' - 4 '. $txt['httpBL_bad'],
			'class' => ''
		),
		160 => array(
			'message' => $txt['httpBL_empty_ip']. '<br />1 '. $txt['httpBL_answer_captcha']. '<br />1 '. $txt['httpBL_good']. ' - 0 '. $txt['httpBL_bad'],
			'class' => ''
		),
		161 => array(
			'message' => $txt['httpBL_empty_ip']. '<br />2 '. $txt['httpBL_answers_captcha']. '<br />1 '. $txt['httpBL_good']. ' - 1 '. $txt['httpBL_bad'],
			'class' => ''
		),
		162 => array(
			'message' => $txt['httpBL_empty_ip']. '<br />3 '. $txt['httpBL_answers_captcha']. '<br />1 '. $txt['httpBL_good']. ' - 2 '. $txt['httpBL_bad'],
			'class' => ''
		),
		163 => array(
			'message' => $txt['httpBL_empty_ip']. '<br />4 '. $txt['httpBL_answers_captcha']. '<br />1 '. $txt['httpBL_good']. ' - 3 '. $txt['httpBL_bad'],
			'class' => ''
		),
		164 => array(
			'message' => $txt['httpBL_empty_ip']. '<br />5 '. $txt['httpBL_answers_captcha']. '<br />1 '. $txt['httpBL_good']. ' - 4 '. $txt['httpBL_bad'],
			'class' => ''
		),
		170 => array(
			'message' => $txt['httpBL_empty_ip']. '<br />0 '. $txt['httpBL_answers_captcha']. '<br />'. $txt['httpBL_wrote_hiding'],
			'class' => ''
		),
		171 => array(
			'message' => $txt['httpBL_empty_ip']. '<br />1 '. $txt['httpBL_answer_captcha']. '<br />0 '. $txt['httpBL_good']. ' - 1 '. $txt['httpBL_bad']. '<br />'. $txt['httpBL_wrote_hiding'],
			'class' => ''
		),
		172 => array(
			'message' => $txt['httpBL_empty_ip']. '<br />2 '. $txt['httpBL_answers_captcha']. '<br />0 '. $txt['httpBL_good']. ' - 2 '. $txt['httpBL_bad']. '<br />'. $txt['httpBL_wrote_hiding'],
			'class' => ''
		),
		173 => array(
			'message' => $txt['httpBL_empty_ip']. '<br />3 '. $txt['httpBL_answers_captcha']. '<br />0 '. $txt['httpBL_good']. ' - 3 '. $txt['httpBL_bad']. '<br />'. $txt['httpBL_wrote_hiding'],
			'class' => ''
		),
		180 => array(
			'message' => $txt['httpBL_empty_ip']. '<br />1 '. $txt['httpBL_answer_captcha']. '<br />1 '. $txt['httpBL_good']. ' - 0 '. $txt['httpBL_bad']. '<br />'. $txt['httpBL_wrote_hiding'],
			'class' => ''
		),
		181 => array(
			'message' => $txt['httpBL_empty_ip']. '<br />2 '. $txt['httpBL_answers_captcha']. '<br />1 '. $txt['httpBL_good']. ' - 1 '. $txt['httpBL_bad']. '<br />'. $txt['httpBL_wrote_hiding'],
			'class' => ''
		),
		182 => array(
			'message' => $txt['httpBL_empty_ip']. '<br />3 '. $txt['httpBL_answers_captcha']. '<br />1 '. $txt['httpBL_good']. ' - 2 '. $txt['httpBL_bad']. '<br />'. $txt['httpBL_wrote_hiding'],
			'class' => ''
		),
		183 => array(
			'message' => $txt['httpBL_empty_ip']. '<br />4 '. $txt['httpBL_answers_captcha']. '<br />1 '. $txt['httpBL_good']. ' - 3 '. $txt['httpBL_bad']. '<br />'. $txt['httpBL_wrote_hiding'],
			'class' => ''
		),
		199 => array(
			'message' => $txt['httpBL_no_show_captcha'],
			'class' => ''
		),
		200 => array(
			'message' => $txt['httpBL_no_reverse_ip'],
			'class' => ''
		),
		201 => array(
			'message' => $txt['httpBL_log_key_error'],
			'class' => ''
		),
		202 => array(
			'message' => $txt['httpBL_no_127'],
			'class' => ''
		),
	);
	
	if (isset($error[$errorNumber]))
		return $error[$errorNumber]['message'];
	else
		return 'errorNumber = '. $errorNumber. ' - '. $txt['httpBL_no_defined'];
}

/*
	httpBL_test_mod_ok()
		Checks if the mod is enabled, if it can make connection with HoneyPot and if it's up-to-date
		Returns a <div> with different colors and messages
 */
function httpBL_test_mod_ok()
{
	global $txt, $modSettings, $sourcedir;
	
	// Check first if it's enabled
	if ($modSettings['httpBL_enable'] == 1)
	{
		// Check connection
		$lookup = httpbl_dnslookup('127.1.80.1', $modSettings['httpBL_honeyPot_key']);
		
		// Check version
		$internal_version = 2.51;
		$remote = 'http://www.snoopyvirtualstudio.com/update_httpBL.php';
		require_once($sourcedir . '/Subs-Package.php');
		$updated_version = fetch_web_data($remote);
		
		if (!$lookup || $lookup['threat'] != 80)
		{
			// Something wrong with the connection
			$string = '<div class="httpBL_mod_no_ok">'. $txt['httpBL_mod_no_connect_1']. '</div>'. $txt['httpBL_mod_no_connect_2'];
		}
		else if ($updated_version && ($internal_version < $updated_version))
		{
			// There is a new version
			$string = '<div class="httpBL_mod_no_ok">'. $txt['httpBL_mod_new_version_1']. '</div>'. $txt['httpBL_mod_new_version_2'];
		}
		else
		{
			// All OK
			$string = '<div class="httpBL_mod_ok">'. $txt['httpBL_mod_all_ok']. '</div>';
		}
	}
	else
	{
		// Mod is OFF
		$string = '<div class="httpBL_mod_no_ok">'. $txt['httpBL_mod_is_off']. '</div>';
	}
	
	return $string;
}
?>
