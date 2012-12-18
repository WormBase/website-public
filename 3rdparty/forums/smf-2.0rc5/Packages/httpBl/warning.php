<?php
/**********************************************************************************
* warning.php                                                                     *
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

// First we need to set up a variable so we know we are coming from the file warning.php
global $httpBL_warning;
$httpBL_warning = true;

// Now we can load SSI.php to read $modSettings
$boarddir = dirname(__FILE__);
require_once($boarddir . '/SSI.php');
global $modSettings, $user_info, $txt, $boardurl, $smcFunc;

/**********************************************************************************
* START - INFORMATION FOR TRANSLATORS                                             *
***********************************************************************************
* I have put all the language variables here at the beginning so it's easier      *
* to find and translate them.                                                     *
* =============================================================================== *
* This file is in 2 languages so, apart from the variables common to both         *
* languages, there are 2 sets of variables. Set 1 for English and set 2 for       *
* Spanish. Each set have the same variables with exactly the same meaning.        *
* The only difference is the number at the end of each variable.                  *
* =============================================================================== *
* To translate this file to your language you should leave set 1 in English and   *
* translate only set 2, so any visitor will see the page in English and in your   *
* language. Of course this is up to you and depend on the kind of visitors you    *
* have in your site. For example: if none of the visitors you have normally can   *
* speak any English at all and you know some of them speak "language X" and       *
* the rest of them "language Y", then you should tranlate set 1 to "language X"   *
* and set 2 to "language Y".                                                      *
* =============================================================================== *
* Please be sure that all the variables in set 1 have a number 1 at the end and   *
* all the variables in set 2 have a number 2 at the end.                          *
* =============================================================================== *
* After translating it, check if you can see the page properly. Depending on the  *
* length of each sentence, the result can be sometimes un-readable. If this is    *
* your case, try changing some sentences. Sometimes you can say the same thing    *
* using different words. Or, if you know some basic HTML, try changing the values *
* of "width" and "height" inside the CSS section for the "div" causing the        *
* problem. And, of course, if you cannot sort the problem by yourself, ask for    *
* help in the support forum for the mod at SMF.                                   *
**********************************************************************************/

/*******************
* Common variables *
*******************/
$txt['httpBL_warn_charset'] = 'UTF-8';

/*******************
*  Set 1 - English *
*******************/
$txt['httpBL_warn_title_1'] = 'Warning';
$txt['httpBL_warn_denied_1'] = 'Access Denied';
$txt['httpBL_warn_head_1'] = 'Our anti-spam program has detected that you are a robot trying to send spam via our forum.';
$txt['httpBL_warn_infected_1'] = 'The most likely cause is that your computer, or another computer operating on your local network, has been <strong>infected with a virus, trojan, or worm</strong>. Infected computers are used by criminals, without their owners knowledge, to send spam and attack websites like this one you are trying yo visit.';
$txt['httpBL_warn_dynamic_IP_1'] = 'If you are using a dynamic IP, the kind of IP that changes every time you re-start your router, maybe the only problem is that today you are using an IP that used to belong to an infected computer some time ago, so you can try, if you want, to re-start your router and your computer and open again one of our web pages to see if you can access them normally now.';
$txt['httpBL_warn_technician_1_1'] = 'Anyway, to test whether your computer is infected, and to remove any possible infection, we would recomend you to contact as soon as possible a computer technician and ask them to visit <strong>www.projecthoneypot.org</strong> and check the details for your IP:';
$txt['httpBL_warn_technician_2_1'] = 'to see exactly what it has been doing wrong.';
$txt['httpBL_warn_info_1'] = 'For more information, please contact:';
$txt['httpBL_warn_at_1'] = 'at';
$txt['httpBL_warn_dot_1'] = 'dot';
$txt['httpBL_warn_hurry_1'] = 'You have a more detailed explanation about it below these lines but, in case you are in a hurry to see our pages and you haven\'t got time just now to scan your computer looking for a possible virus, we can let you in temporarily. We are going to ask you 2 easy questions writing them in a way a robot wouldn\'t be able to see. Please answer this first question (just the number) to prove you are not a robot and press the <strong>"Send"</strong> button:';
$txt['httpBL_warn_send_1'] = 'Send';
$txt['httpBL_warn_blank_1'] = 'Please leave this field blank.<br />Write the answer in the above field.';
$txt['httpBL_warn_wrong_1'] = 'Wrong';
$txt['httpBL_warn_wrong_head_1'] = 'Incorrect answer.';
$txt['httpBL_warn_wrong_answer_1'] = 'Maybe we didn\'t explain it properly or maybe you pressed the wrong key. What you have here are 2 different rows. In the first row you can see an easy sum, an empty field and a "Send" button. In that first empty field you need to write the answer (just the number) and press the button. You should leave the field in the second row empty, as it is just now.';
$txt['httpBL_warn_good_1'] = 'Good';
$txt['httpBL_warn_good_head_1'] = 'Correct answer.';
$txt['httpBL_warn_good_answer_1'] = 'Your answer was right, but please notice that a robot, even not been able to see or understand the question, could have got the right answer just trying random numbers. Of course it will be impossible to get the answer right twice in a row just by chance so, if you don\'t mind, please answer this last question and press again the <strong>"Send"</strong> button:';

/*******************
*  Set 2 - Spanish *
*******************/
$txt['httpBL_warn_title_2'] = 'Aviso';
$txt['httpBL_warn_denied_2'] = 'Acceso Denegado';
$txt['httpBL_warn_head_2'] = 'El programa anti-spam ha detectado que usted es un robot intentando enviar spam usando nuestro foro.';
$txt['httpBL_warn_infected_2'] = 'La causa más probable es que su ordenador, o algún otro ordenador de su red local, haya sido <strong>infectado con un virus, troyano, o gusano</strong>. Los ordenadores infectados son usados por criminales, sin el conocimiento de sus dueños, para enviar spam y atacar páginas webs como ésta que está intentando visitar.';
$txt['httpBL_warn_dynamic_IP_2'] = 'En caso de que usted use una IP dinámica, de las que cambian a menudo cada vez que se reinicia el router, puede ser simplemente que hoy esté usando una IP que en su día perteneció a un ordenador infectado, por lo que puede probar a reiniciar su router y su ordenador y volver a abrir nuestras páginas para ver si ya puede acceder normalmente a ellas.';
$txt['httpBL_warn_technician_1_2'] = 'De todas formas, para ver si su ordenador está infectado y eliminar cualquier infección, le recomendamos que llame cuanto antes a un técnico de informática y le pida que visite <strong>www.projecthoneypot.org</strong> y compruebe los detalles de su IP:';
$txt['httpBL_warn_technician_2_2'] = 'para ver que tipo de acciones maliciosas ha estado haciendo.';
$txt['httpBL_warn_info_2'] = 'Para más información, por favor contacte:';
$txt['httpBL_warn_at_2'] = 'arroba';
$txt['httpBL_warn_dot_2'] = 'punto';
$txt['httpBL_warn_hurry_2'] = 'Tiene una explicación detallada más abajo pero, si tiene prisa por ver nuestras páginas y no tiene tiempo ahora mismo de analizar su ordenador en busca de virus, podemos dejarle pasar de forma temporal. Para ello vamos a hacerle 2 preguntas sencillas pero escritas de forma que un robot no podría ver. Por favor responda esta primera pregunta (en número) para demostrar que usted no es un robot y presione el botón de <strong>"Enviar"</strong>:';
$txt['httpBL_warn_send_2'] = 'Enviar';
$txt['httpBL_warn_blank_2'] = 'Por favor, deje este recuadro en blanco.<br />Escriba la respuesta en el de arriba.';
$txt['httpBL_warn_wrong_2'] = 'Mal';
$txt['httpBL_warn_wrong_head_2'] = 'Respuesta incorrecta.';
$txt['httpBL_warn_wrong_answer_2'] = 'Tal vez no nos hayamos explicado bien o se haya equivocado de tecla. Lo que tiene debajo son 2 renglones diferentes. En el primer renglón hay una suma sencilla, un recuadro en blanco y un botón de "Enviar". En ese primer recuadro es donde debe escribir la respuesta (en número) y darle al botón. El recuadro del segundo renglón debe dejarlo en blanco, tal como está.';
$txt['httpBL_warn_good_2'] = 'Bien';
$txt['httpBL_warn_good_head_2'] = 'Respuesta correcta.';
$txt['httpBL_warn_good_answer_2'] = 'Su respuesta ha sido correcta, pero tenga en cuenta que un robot, incluso aunque no pueda ver ni entender la pregunta, podría haberla acertado probando números al azar. Lo que sería imposible es que un robot acertara la respuesta 2 veces seguidas al azar así que, si no le importa, responda esta última pregunta y presione otra vez el botón de <strong>"Enviar"</strong>';

/**********************************************************************************
* END - INFORMATION FOR TRANSLATORS                                               *
**********************************************************************************/

/*
		If we cannot read the DB or some required values are wrong
		we just use the values from one of my honeypots instead.
		You should edit this file and use your own values if you want.
		(just in case one day I close my site or change my honeypots) ;)
 */
$modSettings['httpBL_honeyPot_link'] = isset($modSettings['httpBL_honeyPot_link']) ? $modSettings['httpBL_honeyPot_link'] : 'http://www.snoopyvirtualstudio.com/maniacal.php';
$modSettings['httpBL_honeyPot_word'] = isset($modSettings['httpBL_honeyPot_word']) ? $modSettings['httpBL_honeyPot_word'] : 'default_value';
$modSettings['httpBL_info_email_1'] = isset($modSettings['httpBL_info_email_1']) ? $modSettings['httpBL_info_email_1'] : 'info';
$modSettings['httpBL_info_email_2'] = isset($modSettings['httpBL_info_email_2']) ? $modSettings['httpBL_info_email_2'] : 'snoopyvirtualstudio';
$modSettings['httpBL_info_email_3'] = isset($modSettings['httpBL_info_email_3']) ? $modSettings['httpBL_info_email_3'] : 'com';

/**********************************************************************************
* You shouldn't need to change anything below this line                           *
**********************************************************************************/

$modSettings['httpBL_use_two_languages'] = isset($modSettings['httpBL_use_two_languages']) ? $modSettings['httpBL_use_two_languages'] : '1';
$modSettings['httpBL_horizontal_separator'] = isset($modSettings['httpBL_horizontal_separator']) ? $modSettings['httpBL_horizontal_separator'] : '&lt;hr /&gt;';
$use_two_languages = $modSettings['httpBL_use_two_languages'] == "1" ? TRUE : FALSE;
$horizontal_separator = html_entity_decode($modSettings['httpBL_horizontal_separator']);

// Load the needed functions
require_once($boarddir . '/Sources/httpBL_Subs.php');

// Set up the link 
$honeyLink = httpBL_honeylink($modSettings['httpBL_honeyPot_link'], $modSettings['httpBL_honeyPot_word']);

// If we haven't been redirected here, but we are just testing the design there is no $_SESSION['response']
// so apart from validating the data we need some default values
$response['ip'] = isset($_SESSION['response']['ip']) && $_SESSION['response']['ip'] != '' ? $_SESSION['response']['ip'] : $user_info['ip'];
$response['ID'] = isset($_SESSION['response']['ID']) ? (int)$_SESSION['response']['ID'] : 0;
$_SESSION['response']['errorNumber'] = isset($_SESSION['response']['errorNumber']) ? (int)$_SESSION['response']['errorNumber'] : 0;
$response['url'] = isset($_SESSION['response']['url']) && $_SESSION['response']['ID'] != '' ? $_SESSION['response']['url'] : '/';
$response['threat'] = isset($_SESSION['response']['threat']) ? (int)$_SESSION['response']['threat'] : 0;

// If we have an answer to the captcha let's see if it's from a human or a robot
if (isset($_POST['send']))
{
	// Validate a little
	$question = isset($_POST['httpBL_question']) ? (int)$_POST['httpBL_question'] : 0 ;
	$answer = isset($_POST['httpBL_answer']) ? (int)$_POST['httpBL_answer'] : 0 ;
	$text_1 = isset($_POST['httpBL_text_1']) ? $_POST['httpBL_text_1'] : '' ;
	$text_2 = isset($_POST['httpBL_text_2']) ? $_POST['httpBL_text_2'] : '' ;
	$captcha_try = isset($_POST['httpBL_captcha_try']) ? (int)$_POST['httpBL_captcha_try'] : 0 ;
	$captcha_bad_try = isset($_POST['httpBL_captcha_bad_try']) ? (int)$_POST['httpBL_captcha_bad_try'] : 4 ;
	
	// They have written in the blank field or wrong answer.
	// Maybe it was a typo. Give them another try.
	if (($text_1 != '' || $question != $answer) && $text_2 == '' && $captcha_bad_try <= 2)
	{
		$page_style = 'short';
		$wrong_answer = 1;
		$good_answer = 0;
		$last_answer = $answer;
		$captcha_bad_try++;
		// Update the errorNumber and the log
		$_SESSION['response']['errorNumber']++;
		httpBL_update_log($response['ID'], 1, $_SESSION['response']['errorNumber']);
	}
	// Good first answer. Let's try a second time. Even robots can get it right once by chance.
	else if ($captcha_try == 1 && $captcha_bad_try <= 3 && $text_1 == '' && $question != 0 && $question == $answer)
	{
		$page_style = 'short';
		$wrong_answer = 0;
		$good_answer = 1;
		$last_answer = $answer;
		$captcha_try++;
		// Update the errorNumber and the log
		$_SESSION['response']['errorNumber'] = $_SESSION['response']['errorNumber'] + 10;
		httpBL_update_log($response['ID'], 1, $_SESSION['response']['errorNumber']);
	}
	// Good second answer. They must be humans.
	else if ($captcha_try == 2 && $captcha_bad_try <= 3 && $text_1 == '' && $question != 0 && $question == $answer)
	{
		// Update the errorNumber and the log
		$_SESSION['response']['errorNumber'] = $_SESSION['response']['errorNumber'] - 110;
		httpBL_update_log($response['ID'], 0, $_SESSION['response']['errorNumber']);
		
		// Create a cookie valid for as many hours as set in config page (default 24h)
		httpBL_setPassCookie($response['ip']);
		
		// Redirect to the last page they were visiting (or the root if we have lost it)
		$url = isset($response['url']) && $response['url'] != '' ? $response['url'] : '/';
		$boardurl_data = parse_url($boardurl);
		if ($boardurl_data['scheme'] == '' || $boardurl_data['host'] == '')
		{
			// Not very sure is this can happen and if my solution is right.
			// TO DO: Check this possibility.
			header('Location: '. $url);
			exit();
		}
		else
		{
			header('Location: '. $boardurl_data['scheme']. '://'. $boardurl_data['host']. $url);
			exit();
		}
	}
	// Are they writing in a hidden field? They are robots. They don't pass.
	// OR - Too many bad answers? I don't know any human so thick.
	else
	{
		// Update the errorNumber
		// Writing in a hidden field
		if ($text_2 != '')
			$_SESSION['response']['errorNumber'] == $_SESSION['response']['errorNumber'] + 20;
		else
			$_SESSION['response']['errorNumber']++;
		// Update the log
		httpBL_update_log($response['ID'], 1, $_SESSION['response']['errorNumber']);
		
		$GLOBALS = array();
		$_COOKIES = array();
		$_FILES = array();
		$_ENV = array();
		$_REQUEST = array();
		$_POST = array();
		$_GET = array();
		$_SERVER = array();
		$_SESSION = array();
		@session_destroy();
		$page_style = 'medium';
	}
}
// Too high a threat. Don't care if they are humans or not.
// OR - Writing in a form input field without even clicking the send button? Can a robot do that? A human not for sure.
// They don't pass.
else if ((isset($response['threat']) && (int)$response['threat'] >= (int)$modSettings['httpBL_very_bad_threat']) || isset($_POST['httpBL_text_1']) || isset($_POST['httpBL_text_2']) || isset($_POST['httpBL_question']))
{
	httpBL_update_log($response['ID'], 1, 199);
	$GLOBALS = array();
	$_COOKIES = array();
	$_FILES = array();
	$_ENV = array();
	$_REQUEST = array();
	$_POST = array();
	$_GET = array();
	$_SERVER = array();
	$_SESSION = array();
	@session_destroy();
	$page_style = 'medium';
}
// Just arrived here and threat not too high.
// Show them the captcha.
else
{
	$page_style = 'long';
	$last_answer = 0;
	$captcha_try = 1;
	$captcha_bad_try = 0;
}

// If we want to see the page the way a VERY VERY bad bot sees it
// 		we need to add something to the link
if (isset($_REQUEST['style']) && $_REQUEST['style'] == 'medium')
	$page_style = 'medium';

// Ready to echo the page
echo '<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" lang="en" xml:lang="en">

<head>
	<meta http-equiv="content-type" content="text/html; charset=' . $txt['httpBL_warn_charset'] . '" />
	<title>' . $txt['httpBL_warn_title_1'] . ' | ' . $txt['httpBL_warn_title_2'] . '</title>';

// Load the css file for our forum Theme
// If we are in SMF 1.x
if (empty($smcFunc['db_query']))
	echo '
	<link rel="stylesheet" type="text/css" href="', $settings['theme_url'], '/style.css" />';
else
	echo '
	<link rel="stylesheet" type="text/css" href="', $settings['theme_url'], '/css/index.css" />';

// Now the specific css file for the warning page
echo '
	<link rel="stylesheet" type="text/css" href="warning_css.css" />
</head>
<body>

<div class="centered">
	<div class="container">
    	<div id="warn_logo" class="catbg">';

	// You can change all the staff here inside the div id="warn_logo" to whatever you want
	// Just be sure you don't put here any links at all, just pictures or text.
	if (empty($settings['header_logo_url']))
		echo '
					<span style="font-family: Verdana, sans-serif; font-size: 140%; ">', $context['forum_name'], '</span>';
	else
		echo '
					<img src="', $settings['header_logo_url'], '" style="margin: 4px;" alt="', $context['forum_name'], '" />';

	echo '
		</div>';

// First paragraph
if ($page_style == 'long')
{
	echo '
		<table width="100%" border="0" cellpadding="0" cellspacing="0">
			<tr>
				<td class="windowbg" align="center" valign="top">
					<div class="grey-border">
						<h1 class="normal">' . $txt['httpBL_warn_denied_1'] . '</h1>
						<h2 class="normal">' . $txt['httpBL_warn_head_1'] . '</h2>
						' . $txt['httpBL_warn_hurry_1'] . '
					</div>
				</td>';
	if ($use_two_languages)
	{
		echo '
				<td class="vertical-td"><img src="', $settings['default_images_url'], '/blank.gif" width="10" alt="" border="0" /></td>
				<td class="windowbg" align="center" valign="top">
					<div class="grey-border">
						<h1 class="normal">' . $txt['httpBL_warn_denied_2'] . '</h1>
						<h2 class="normal">' . $txt['httpBL_warn_head_2'] . '</h2>
						' . $txt['httpBL_warn_hurry_2'] . '
					</div>
				</td>';
	}
	echo '
			</tr>
		</table>
		' . $horizontal_separator;
}
else if ($page_style == 'short' && $wrong_answer)
{
	echo '
		<table width="100%" border="0" cellpadding="0" cellspacing="0">
			<tr>
				<td class="windowbg" align="center" valign="top">
					<div class="grey-border">
						<h1 class="red">' . $txt['httpBL_warn_wrong_1'] . '</h1>
						<h2 class="red">' . $txt['httpBL_warn_wrong_head_1'] . '</h2>
						' . $txt['httpBL_warn_wrong_answer_1'] . '
					</div>
				</td>';
	if ($use_two_languages)
	{
		echo '
				<td class="vertical-td"><img src="', $settings['default_images_url'], '/blank.gif" width="10" alt="" border="0" /></td>
				<td class="windowbg" align="center" valign="top">
					<div class="grey-border">
						<h1 class="red">' . $txt['httpBL_warn_wrong_2'] . '</h1>
						<h2 class="red">' . $txt['httpBL_warn_wrong_head_2'] . '</h2>
						' . $txt['httpBL_warn_wrong_answer_2'] . '
					</div>
				</td>';
	}
	echo '
			</tr>
		</table>
		' . $horizontal_separator;
}
else if ($page_style == 'short' && $good_answer)
{
	echo '
		<table width="100%" border="0" cellpadding="0" cellspacing="0">
			<tr>
				<td class="windowbg" align="center" valign="top">
					<div class="grey-border">
						<h1 class="green">' . $txt['httpBL_warn_good_1'] . '</h1>
						<h2 class="green">' . $txt['httpBL_warn_good_head_1'] . '</h2>
						' . $txt['httpBL_warn_good_answer_1'] . '
					</div>
				</td>';
	if ($use_two_languages)
	{
		echo '
				<td class="vertical-td"><img src="', $settings['default_images_url'], '/blank.gif" width="10" alt="" border="0" /></td>
				<td class="windowbg" align="center" valign="top">
					<div class="grey-border">
						<h1 class="green">' . $txt['httpBL_warn_good_2'] . '</h1>
						<h2 class="green">' . $txt['httpBL_warn_good_head_2'] . '</h2>
						' . $txt['httpBL_warn_good_answer_2'] . '
					</div>
				</td>';
	}
	echo '
			</tr>
		</table>
		' . $horizontal_separator;
}
else
{
	echo '
		<table width="100%" border="0" cellpadding="0" cellspacing="0">
			<tr>
				<td class="windowbg" align="center" valign="top">
					<div class="grey-border">
						<h1 class="red">' . $txt['httpBL_warn_denied_1'] . '</h1>
						<h2 class="normal">' . $txt['httpBL_warn_head_1'] . '</h2>
						' . $txt['httpBL_warn_infected_1'] . '
					</div>
				</td>';
	if ($use_two_languages)
	{
		echo '
				<td class="vertical-td"><img src="', $settings['default_images_url'], '/blank.gif" width="10" alt="" border="0" /></td>
				<td class="windowbg" align="center" valign="top">
					<div class="grey-border">
						<h1 class="red">' . $txt['httpBL_warn_denied_2'] . '</h1>
						<h2 class="normal">' . $txt['httpBL_warn_head_2'] . '</h2>
						' . $txt['httpBL_warn_infected_2'] . '
					</div>
				</td>';
	}
	echo '
			</tr>
		</table>
		' . $horizontal_separator . '
		<table width="100%" border="0" cellpadding="0" cellspacing="0">
			<tr>
				<td class="windowbg2" align="center" valign="top">
					<div class="grey-border">' . $txt['httpBL_warn_dynamic_IP_1'] . '</div>
				</td>';
	if ($use_two_languages)
	{
		echo '
				<td class="vertical-td"><img src="', $settings['default_images_url'], '/blank.gif" width="10" alt="" border="0" /></td>
				<td class="windowbg2" align="center" valign="top">
					<div class="grey-border">' . $txt['httpBL_warn_dynamic_IP_2'] . '</div>
				</td>';
	}
	echo '
			</tr>
		</table>
		' . $horizontal_separator . '
		<table width="100%" border="0" cellpadding="0" cellspacing="0">
			<tr>
				<td class="windowbg" align="center" valign="top">
					<div class="grey-border">' . $txt['httpBL_warn_technician_1_1'] . ' ' . $response['ip'] . ' ' . $txt['httpBL_warn_technician_2_1'] . '</div>
				</td>';
	if ($use_two_languages)
	{
		echo '
				<td class="vertical-td"><img src="', $settings['default_images_url'], '/blank.gif" width="10" alt="" border="0" /></td>
				<td class="windowbg" align="center" valign="top">
					<div class="grey-border">' . $txt['httpBL_warn_technician_1_2'] . ' ' . $response['ip'] . ' ' . $txt['httpBL_warn_technician_2_2'] . '</div>
				</td>';
	}
	echo '
			</tr>
		</table>
		' . $horizontal_separator . '
		<table width="100%" border="0" cellpadding="0" cellspacing="0">
			<tr>
				<td class="windowbg2" align="center" valign="top">
					<div class="grey-border">
						<h2 class="normal">' . $txt['httpBL_warn_info_1'] . '</h2>
						<strong>'. $modSettings['httpBL_info_email_1'] .'</strong> [' . $txt['httpBL_warn_at_1'] . '] <strong>'. $modSettings['httpBL_info_email_2'] .'</strong> [' . $txt['httpBL_warn_dot_1'] . '] <strong>'. $modSettings['httpBL_info_email_3'] .'</strong>
					</div>
				</td>';
	if ($use_two_languages)
	{
		echo '
				<td class="vertical-td"><img src="', $settings['default_images_url'], '/blank.gif" width="10" alt="" border="0" /></td>
				<td class="windowbg2" align="center" valign="top">
					<div class="grey-border">
						<h2 class="normal">' . $txt['httpBL_warn_info_2'] . '</h2>
						<strong>'. $modSettings['httpBL_info_email_1'] .'</strong> [' . $txt['httpBL_warn_at_2'] . '] <strong>'. $modSettings['httpBL_info_email_2'] .'</strong> [' . $txt['httpBL_warn_dot_2'] . '] <strong>'. $modSettings['httpBL_info_email_3'] .'</strong>
					</div>
				</td>';
	}
	echo '
			</tr>
		</table>';
}

// captcha form
if ($page_style == 'long' || $page_style == 'short')
{
	$captcha = httpBL_captcha($last_answer);
	if ($use_two_languages)
		$httpBL_warn_send = $txt['httpBL_warn_send_1'] . ' - ' . $txt['httpBL_warn_send_2'];
	else
		$httpBL_warn_send = $txt['httpBL_warn_send_1'];
	echo '
		<div class="windowbg2 grey-border">
			<form action="warning.php" method="post" accept-charset="' . $txt['httpBL_warn_charset'] . '">
				<table border="0" cellspacing="0" cellpadding="4" align="center" width="100%">
					<tr>
						<td align="right" valign="middle" width="45%"><label for="httpBL_question" class="captcha_label">' . $captcha['question'] . '</label></td>
						<td align="center" valign="middle" width="10%"><input type="text" name="httpBL_question" id="httpBL_question" value="" size="5" maxlength="50" /></td>
						<td align="left" valign="middle" width="45%">&nbsp;<input type="submit" name="send" value="' . $httpBL_warn_send . '" /></td>
					</tr>
					<tr>
						<td align="right" valign="middle" class="warn_blank">' . $txt['httpBL_warn_blank_1'] . '&nbsp;</td>
						<td align="center" valign="middle"><input type="text" name="httpBL_text_1" id="httpBL_text_1" value="" size="5" maxlength="50" /></td>
						<td align="left" valign="middle" class="warn_blank">';
	if ($use_two_languages)
	{
		echo '&nbsp;' . $txt['httpBL_warn_blank_2'];
	}
	echo '</td>
					</tr>
				</table>
				<input type="text" name="httpBL_text_2" id="httpBL_text_2" value="" size="30" maxlength="100" style="display: none;" />
				<input type="hidden" name="httpBL_answer" value="' . $captcha['answer'] . '" />
				<input type="hidden" name="httpBL_captcha_try" value="' . $captcha_try . '" />
				<input type="hidden" name="httpBL_captcha_bad_try" value="' . $captcha_bad_try . '" />
			</form>
		</div>
		' . $horizontal_separator;
}

// Second paragraph
if ($page_style == 'long')
{
	echo '
		<table width="100%" border="0" cellpadding="0" cellspacing="0">
			<tr>
				<td class="windowbg" align="center" valign="top">
					<div class="grey-border">' . $txt['httpBL_warn_infected_1'] . '</div>
				</td>';
	if ($use_two_languages)
	{
		echo '
				<td class="vertical-td"><img src="', $settings['default_images_url'], '/blank.gif" width="10" alt="" border="0" /></td>
				<td class="windowbg" align="center" valign="top">
					<div class="grey-border">' . $txt['httpBL_warn_infected_2'] . '</div>
				</td>';
	}
	echo '
			</tr>
		</table>
		' . $horizontal_separator . '
		<table width="100%" border="0" cellpadding="0" cellspacing="0">
			<tr>
				<td class="windowbg2" align="center" valign="top">
					<div class="grey-border">' . $txt['httpBL_warn_dynamic_IP_1'] . '</div>
				</td>';
	if ($use_two_languages)
	{
		echo '
				<td class="vertical-td"><img src="', $settings['default_images_url'], '/blank.gif" width="10" alt="" border="0" /></td>
				<td class="windowbg2" align="center" valign="top">
					<div class="grey-border">' . $txt['httpBL_warn_dynamic_IP_2'] . '</div>
				</td>';
	}
	echo '
			</tr>
		</table>
		' . $horizontal_separator . '
		<table width="100%" border="0" cellpadding="0" cellspacing="0">
			<tr>
				<td class="windowbg" align="center" valign="top">
					<div class="grey-border">' . $txt['httpBL_warn_technician_1_1'] . ' ' . $response['ip'] . ' ' . $txt['httpBL_warn_technician_2_1'] . '</div>
				</td>';
	if ($use_two_languages)
	{
		echo '
				<td class="vertical-td"><img src="', $settings['default_images_url'], '/blank.gif" width="10" alt="" border="0" /></td>
				<td class="windowbg" align="center" valign="top">
					<div class="grey-border">' . $txt['httpBL_warn_technician_1_2'] . ' ' . $response['ip'] . ' ' . $txt['httpBL_warn_technician_2_2'] . '</div>
				</td>';
	}
	echo '
			</tr>
		</table>
		' . $horizontal_separator . '
		<table width="100%" border="0" cellpadding="0" cellspacing="0">
			<tr>
				<td class="windowbg2" align="center" valign="top">
					<div class="grey-border">
						<h2 class="normal">' . $txt['httpBL_warn_info_1'] . '</h2>
						<strong>'. $modSettings['httpBL_info_email_1'] .'</strong> [' . $txt['httpBL_warn_at_1'] . '] <strong>'. $modSettings['httpBL_info_email_2'] .'</strong> [' . $txt['httpBL_warn_dot_1'] . '] <strong>'. $modSettings['httpBL_info_email_3'] .'</strong>
					</div>
				</td>';
	if ($use_two_languages)
	{
		echo '
				<td class="vertical-td"><img src="', $settings['default_images_url'], '/blank.gif" width="10" alt="" border="0" /></td>
				<td class="windowbg2" align="center" valign="top">
					<div class="grey-border">
						<h2 class="normal">' . $txt['httpBL_warn_info_2'] . '</h2>
						<strong>'. $modSettings['httpBL_info_email_1'] .'</strong> [' . $txt['httpBL_warn_at_2'] . '] <strong>'. $modSettings['httpBL_info_email_2'] .'</strong> [' . $txt['httpBL_warn_dot_2'] . '] <strong>'. $modSettings['httpBL_info_email_3'] .'</strong>
					</div>
				</td>';
	}
	echo '
			</tr>
		</table>';
}
else if ($page_style == 'short')
{
	echo '
		<table width="100%" border="0" cellpadding="0" cellspacing="0">
			<tr>
				<td class="windowbg" align="center" valign="top">
					<div class="grey-border">' . $txt['httpBL_warn_technician_1_1'] . ' ' . $response['ip'] . ' ' . $txt['httpBL_warn_technician_2_1'] . '</div>
				</td>';
	if ($use_two_languages)
	{
		echo '
				<td class="vertical-td"><img src="', $settings['default_images_url'], '/blank.gif" width="10" alt="" border="0" /></td>
				<td class="windowbg" align="center" valign="top">
					<div class="grey-border">' . $txt['httpBL_warn_technician_1_2'] . ' ' . $response['ip'] . ' ' . $txt['httpBL_warn_technician_2_2'] . '</div>
				</td>';
	}
	echo '
			</tr>
		</table>
		' . $horizontal_separator . '
		<table width="100%" border="0" cellpadding="0" cellspacing="0">
			<tr>
				<td class="windowbg2" align="center" valign="top">
					<div class="grey-border">
						<h2 class="normal">' . $txt['httpBL_warn_info_1'] . '</h2>
						<strong>'. $modSettings['httpBL_info_email_1'] .'</strong> [' . $txt['httpBL_warn_at_1'] . '] <strong>'. $modSettings['httpBL_info_email_2'] .'</strong> [' . $txt['httpBL_warn_dot_1'] . '] <strong>'. $modSettings['httpBL_info_email_3'] .'</strong>
					</div>
				</td>';
	if ($use_two_languages)
	{
		echo '
				<td class="vertical-td"><img src="', $settings['default_images_url'], '/blank.gif" width="10" alt="" border="0" /></td>
				<td class="windowbg2" align="center" valign="top">
					<div class="grey-border">
						<h2 class="normal">' . $txt['httpBL_warn_info_2'] . '</h2>
						<strong>'. $modSettings['httpBL_info_email_1'] .'</strong> [' . $txt['httpBL_warn_at_2'] . '] <strong>'. $modSettings['httpBL_info_email_2'] .'</strong> [' . $txt['httpBL_warn_dot_2'] . '] <strong>'. $modSettings['httpBL_info_email_3'] .'</strong>
					</div>
				</td>';
	}
	echo '
			</tr>
		</table>';
}

echo '
	</div>
</div>
<div id="footer_' . $page_style . '">&nbsp;'. $honeyLink .'</div>
</body>
</html>';
?>
