<?php
// Version: 1.1; httpBL

function template_config()
{
	global $context, $scripturl, $txt, $modSettings, $boardurl, $sourcedir;

	echo '
	<form action="', $scripturl, '?action=httpBL" method="post" accept-charset="', $context['character_set'], '">
		<table border="0" cellspacing="1" cellpadding="4" align="center" width="100%" class="tborder">
			<tr class="titlebg">
				<td>', $context['page_title'] , ' - ' , $txt['httpBL_config'], '</td>
			</tr>
			<tr class="windowbg2">
				<td align="center">';
	
	// Let's find out if we got mod OS & Browser Detection
	$os_browser_exists = FALSE;
	if (file_exists($sourcedir.'/os_browser_detection.php'))
		$os_browser_exists = TRUE;
	
	// Functions to do some nice box disabling dependant on honeyPot link and API key existing or not.
	echo '
					<script language="JavaScript" type="text/javascript"><!-- // --><![CDATA[
						function checkEnable()
						{
							var httpBLkeyDisabled = document.getElementById(\'httpBL_honeyPot_link\').value == "";
							document.getElementById(\'httpBL_honeyPot_key\').disabled = httpBLkeyDisabled;

							var httpBLDisabled = httpBLkeyDisabled || document.getElementById(\'httpBL_honeyPot_key\').value == "";
							document.getElementById(\'httpBL_enable\').disabled = httpBLDisabled;
						}
					// ]]></script>';

	echo '
				<table border="0" cellspacing="0" cellpadding="4" align="center" width="100%">
					<tr class="windowbg2">
							<td width="100%" colspan="2" align="left">', $context['httpBL_ok'], '</td>
					</tr><tr class="titlebg">
							<td colspan="2">', $txt['httpBL_general_settings'], '</td>
						</tr><tr class="windowbg">
							<td class="smalltext" style="padding: 2ex;" colspan="2">', $txt['httpBL_general_settings_desc'], '</td>
						</tr><tr class="windowbg2" valign="top">
							<th width="50%" align="right">
								<label for="httpBL_enable">', $txt['httpBL_enable'], '</label>:
								<div class="smalltext" style="font-weight: normal;">', $txt['httpBL_enable_sub'], '</div>
								</th>
							<td valign="top" align="left">
								<input type="checkbox" name="httpBL_enable" id="httpBL_enable"', empty($modSettings['httpBL_enable']) ? '' : ' checked="checked"', ' class="check" />
							</td>
						</tr><tr class="windowbg2" valign="top">
							<th width="50%" align="right">
								<label for="httpBL_honeyPot_link">', $txt['httpBL_honeyPot_link'], '</label>:
								<div class="smalltext" style="font-weight: normal;">', $txt['httpBL_honeyPot_link_sub'], '</div>
							</th>
							<td align="left">
								<input type="text" name="httpBL_honeyPot_link" id="httpBL_honeyPot_link" value="', $modSettings['httpBL_honeyPot_link'], '" size="50" maxlength="255" onkeyup="checkEnable();" />
							</td>
						</tr><tr class="windowbg2" valign="top">
							<th width="50%" align="right">
								<label for="httpBL_honeyPot_key">', $txt['httpBL_honeyPot_key'], '</label>:
								<div class="smalltext" style="font-weight: normal;">', $txt['httpBL_honeyPot_key_sub'], '</div>
							</th>
							<td align="left">
								<input type="text" name="httpBL_honeyPot_key" id="httpBL_honeyPot_key" value="', $modSettings['httpBL_honeyPot_key'], '" size="22" maxlength="35" onkeyup="checkEnable();" />
							</td>
						</tr><tr class="windowbg2" valign="top">
							<th width="50%" align="right">
								<label for="httpBL_honeyPot_word">', $txt['httpBL_honeyPot_word'], '</label>:
								<div class="smalltext" style="font-weight: normal;">', $txt['httpBL_honeyPot_word_sub'], '</div>
							</th>
							<td align="left">
								<input type="text" name="httpBL_honeyPot_word" id="httpBL_honeyPot_word" value="', $modSettings['httpBL_honeyPot_word'], '" size="22" maxlength="35" />
							</td>
					</tr><tr class="titlebg">
							<td colspan="2">', $txt['httpBL_info_email'], '</td>
						</tr><tr class="windowbg">
							<td class="smalltext" style="padding: 2ex;" colspan="2">', $txt['httpBL_info_email_desc'], '</td>
						</tr><tr class="windowbg2" valign="top">
							<th width="50%" align="right">
								<label for="httpBL_info_email_1">', $txt['httpBL_info_email_1'], '</label>:
							</th>
							<td align="left">
								<input type="text" name="httpBL_info_email_1" id="httpBL_info_email_1" value="', $modSettings['httpBL_info_email_1'], '" size="22" maxlength="35" />
							</td>
						</tr><tr class="windowbg2" valign="top">
							<th width="50%" align="right">
								<label for="httpBL_info_email_2">', $txt['httpBL_info_email_2'], '</label>:
							</th>
							<td align="left">
								<input type="text" name="httpBL_info_email_2" id="httpBL_info_email_2" value="', $modSettings['httpBL_info_email_2'], '" size="22" maxlength="35" />
							</td>
						</tr><tr class="windowbg2" valign="top">
							<th width="50%" align="right">
								<label for="httpBL_info_email_3">', $txt['httpBL_info_email_3'], '</label>:
							</th>
							<td align="left">
								<input type="text" name="httpBL_info_email_3" id="httpBL_info_email_3" value="', $modSettings['httpBL_info_email_3'], '" size="22" maxlength="35" />
							</td>
					</tr><tr class="titlebg">
							<td colspan="2">', $txt['httpBL_internal_settings'], '</td>
						</tr><tr class="windowbg">
							<td class="smalltext" style="padding: 2ex;" colspan="2">', $txt['httpBL_internal_settings_desc'], '</td>
						</tr><tr class="windowbg2" valign="top">
							<th width="50%" align="right">
								<label for="httpBL_bad_last_activity">', $txt['httpBL_bad_last_activity'], '</label>:
								<div class="smalltext" style="font-weight: normal;">', $txt['httpBL_bad_last_activity_sub'], '</div>
							</th>
							<td align="left">
								<input type="text" name="httpBL_bad_last_activity" id="httpBL_bad_last_activity" value="', $modSettings['httpBL_bad_last_activity'], '" size="5" maxlength="5" />
							</td>
						</tr><tr class="windowbg2" valign="top">
							<th width="50%" align="right">
								<label for="httpBL_bad_threat">', $txt['httpBL_bad_threat'], '</label>:
								<div class="smalltext" style="font-weight: normal;">', $txt['httpBL_bad_threat_sub'], '</div>
							</th>
							<td align="left">
								<input type="text" name="httpBL_bad_threat" id="httpBL_bad_threat" value="', $modSettings['httpBL_bad_threat'], '" size="5" maxlength="5" />
							</td>
						</tr><tr class="windowbg2" valign="top">
							<th width="50%" align="right">
								<label for="httpBL_very_bad_threat">', $txt['httpBL_very_bad_threat'], '</label>:
								<div class="smalltext" style="font-weight: normal;">', $txt['httpBL_very_bad_threat_sub'], '</div>
							</th>
							<td align="left">
								<input type="text" name="httpBL_very_bad_threat" id="httpBL_very_bad_threat" value="', $modSettings['httpBL_very_bad_threat'], '" size="5" maxlength="5" />
							</td>
						</tr><tr class="windowbg2" valign="top">
							<th width="50%" align="right">
								<label for="httpBL_cache_length">', $txt['httpBL_cache_length'], '</label>:
								<div class="smalltext" style="font-weight: normal;">', $txt['httpBL_cache_length_sub'], '</div>
							</th>
							<td align="left">
								<input type="text" name="httpBL_cache_length" id="httpBL_cache_length" value="', $modSettings['httpBL_cache_length'], '" size="5" maxlength="5" />
							</td>
						</tr><tr class="windowbg2" valign="top">
							<th width="50%" align="right">
								<label for="httpBL_cookie_length">', $txt['httpBL_cookie_length'], '</label>:
								<div class="smalltext" style="font-weight: normal;">', $txt['httpBL_cookie_length_sub'], '</div>
							</th>
							<td align="left">
								<input type="text" name="httpBL_cookie_length" id="httpBL_cookie_length" value="', $modSettings['httpBL_cookie_length'], '" size="5" maxlength="5" />
							</td>
					</tr><tr class="titlebg">
							<td colspan="2">', $txt['httpBL_extra_settings'], '</td>
						</tr><tr class="windowbg">
							<td class="smalltext" style="padding: 2ex;" colspan="2">', $txt['httpBL_extra_settings_desc'], '</td>
						</tr><tr class="windowbg2" valign="top">
							<th width="50%" align="right">
								<label for="httpBL_viewlog_extra">', $txt['httpBL_viewlog_extra'], '</label>:
								<div class="smalltext" style="font-weight: normal;">', $txt['httpBL_viewlog_extra_sub'], '</div>
							</th>
							<td valign="top" align="left">
								<input type="checkbox" name="httpBL_viewlog_extra" id="httpBL_viewlog_extra"', empty($modSettings['httpBL_viewlog_extra']) ? '' : ' checked="checked"', ' class="check" />
							</td>
						</tr><tr class="windowbg2">
							<th width="50%" align="right">
								<label for="httpBL_view_os_whosonline">', $txt['httpBL_view_os_whosonline'], '</label>:
								<div class="smalltext" style="font-weight: normal;">', $txt['httpBL_view_os_whosonline_sub'], '</div>
							</th>
							<td valign="top" align="left">
								<input type="checkbox" name="httpBL_view_os_whosonline" id="httpBL_view_os_whosonline"', empty($modSettings['httpBL_view_os_whosonline']) || !$os_browser_exists ? '' : ' checked="checked"', $os_browser_exists ? '' : ' disabled="disabled"', ' class="check" />
							</td>
					</tr><tr class="titlebg">
							<td colspan="2">', $txt['httpBL_warning_settings'], '</td>
						</tr><tr class="windowbg">
							<td class="smalltext" style="padding: 2ex;" colspan="2">', $txt['httpBL_warning_settings_desc'], '</td>
						</tr><tr class="windowbg2" valign="top">
							<th width="50%" align="right">
								<label for="httpBL_use_two_languages">', $txt['httpBL_use_two_languages'], '</label>:
								<div class="smalltext" style="font-weight: normal;">', $txt['httpBL_use_two_languages_sub'], '</div>
							</th>
							<td valign="top" align="left">
								<input type="checkbox" name="httpBL_use_two_languages" id="httpBL_use_two_languages"', empty($modSettings['httpBL_use_two_languages']) ? '' : ' checked="checked"', ' class="check" />
							</td>
						</tr><tr class="windowbg2" valign="top">
							<th width="50%" align="right">
								<label for="httpBL_horizontal_separator">', $txt['httpBL_horizontal_separator'], '</label>:
								<div class="smalltext" style="font-weight: normal;">', $txt['httpBL_horizontal_separator_sub'], '</div>
							</th>
							<td align="left">
								<input type="text" name="httpBL_horizontal_separator" id="httpBL_horizontal_separator" value="', htmlentities($modSettings['httpBL_horizontal_separator']), '" size="50" maxlength="255" />
							</td>
					</tr><tr class="windowbg2" valign="top">
							<td width="100%" colspan="2" align="right">
								<input type="submit" name="save" value="', $txt[10], '" />
								<input type="hidden" name="sa" value="config" />
							</td>
						</tr><tr class="windowbg2">
							<td width="100%" colspan="2" align="center">
								<hr />
							</td>
						</tr>
					</table>';

	// Handle disabling of some of the input boxes.
	echo '
					<script language="JavaScript" type="text/javascript"><!-- // --><![CDATA[';

	if (empty($modSettings['httpBL_honeyPot_key']) || empty($modSettings['httpBL_honeyPot_link']))
		echo '
						document.getElementById(\'httpBL_enable\').disabled = true;';
	if (empty($modSettings['httpBL_honeyPot_link']))
		echo '
						document.getElementById(\'httpBL_honeyPot_key\').disabled = true;';

	echo '
					// ]]></script>
				</td>
			</tr>
		</table>
		<input type="hidden" name="sc" value="', $context['session_id'], '" />
	</form>';
}

function template_viewlog()
{
	global $context, $settings, $options, $scripturl, $txt, $modSettings, $smcFunc;

	// Set the "empty log" message and avoid any surprises
	if ($context['sub_action'] == 'viewlogpass')
	{
		$subpage = 'viewlogpass';
		$empty_log_message = $txt['httpBL_logpass_no_entries'];
		$this_log = 'HumanLog';
	}
	else if ($context['sub_action'] == 'viewlogerror')
	{
		$subpage = 'viewlogerror';
		$empty_log_message = $txt['httpBL_logerror_no_entries'];
		$this_log = 'ErrorLog';
	}
	else
	{
		$subpage = 'viewlog';
		$empty_log_message = $txt['httpBL_log_no_entries'];
		$this_log = 'SpammerLog';
	}
	
	// In SMF 2.0 this is a little different than 1.x
	if (empty($smcFunc['db_query']))
		$httpBL_action = 'httpBL';
	else
		$httpBL_action = 'admin;area=httpBL';

	echo '
	<script language="JavaScript" type="text/javascript"><!-- // --><![CDATA[
		var current_legend = ', empty($options['collapse_legend']) ? 'false' : 'true', ';
		function shrink_legend(mode)
		{
			smf_setThemeOption("collapse_legend", mode ? 1 : 0, null, "', $context['session_id'], '");
			document.getElementById("httpBL_legend_button").value = mode ? "', $txt['httpBL_log_show_legend'], '" : "', $txt['httpBL_log_hide_legend'], '";
			document.getElementById("httpBL_legend").style.display = mode ? "none" : "block";
			current_legend = mode;
		}
	// ]]></script>
	
	<table border="0" align="center" cellspacing="2" cellpadding="5" class="bordercolor" width="100%">
		<tr class="windowbg">
			<td align="left" valign="middle" colspan="2"><strong>', $txt['httpBL_caught'], $modSettings['httpBL_count'], '</strong></td>
		</tr>
		<tr class="windowbg2">
			<td align="right" valign="top" width="50%">
				<form action="javascript:void();">
					<input type="submit" value="', empty($options['collapse_legend']) ? $txt['httpBL_log_hide_legend'] : $txt['httpBL_log_show_legend'], '" id="httpBL_legend_button" onclick="shrink_legend(!current_legend); return false;" />
				</form>
			</td>
			<td align="left" valign="top" width="50%">
				<form action="', $scripturl, '?action=', $httpBL_action, ';sa=', $subpage, '" method="post" accept-charset="', $context['character_set'], '">
					<input type="submit" value="', $modSettings['httpBL_viewlog_extra'] ? $txt['httpBL_viewlog_normal'] : $txt['httpBL_viewlog_extra'], '" name="httpBL_viewlog_', $modSettings['httpBL_viewlog_extra'] ? 'normal' : 'extra', '" />
					<input type="hidden" name="sc" value="', $context['session_id'], '" />
				</form>
			</td>
		</tr>
	</table>
	<form action="', $scripturl, '?action=', $httpBL_action, ';sa=', $subpage, '" method="post" accept-charset="', $context['character_set'], '">
		<table border="0" align="center" cellspacing="2" cellpadding="5" class="bordercolor" width="100%" id="httpBL_legend" style="display: ', empty($options['collapse_legend']) ? 'block' : 'none', ';">
			<tr class="windowbg">
				<td align="right" valign="top" style="width: 70px"><strong>', $txt['httpBL_log_threat'], '</strong></td>
				<td align="left" valign="top" class="windowbg2"> - ', $txt['httpBL_log_threat_long'], '</td>
				<td class="windowbg2" style="width: 10px" rowspan="6">&nbsp;</td>
				<td align="center" valign="middle" rowspan="2"><strong>', $txt['httpBL_threat_colors'], '</strong></td>
			</tr>
			<tr class="windowbg">
				<td align="right" valign="top"><strong>', $txt['httpBL_log_activity'], '</strong></td>
				<td align="left" valign="top" class="windowbg2"> - ', $txt['httpBL_log_activity_long'], '</td>
			</tr>
			<tr class="windowbg">
				<td align="right" valign="top"><strong>', $txt['httpBL_log_suspicious'], '</strong></td>
				<td align="left" valign="top" class="windowbg2"> - ', $txt['httpBL_log_suspicious_long'], '</td>
				<td align="center" valign="middle" class="httpBL_threat_low" style="width: 150px">', $txt['httpBL_threat_low'], '</td>
			</tr>
			<tr class="windowbg">
				<td align="right" valign="top"><strong>', $txt['httpBL_log_harvester'], '</strong></td>
				<td align="left" valign="top" class="windowbg2"> - ', $txt['httpBL_log_harvester_long'], '</td>
				<td align="center" valign="middle" class="httpBL_threat_medium">', $txt['httpBL_threat_medium'], '</td>
			</tr>
			<tr class="windowbg">
				<td align="right" valign="top"><strong>', $txt['httpBL_log_comment'], '</strong></td>
				<td align="left" valign="top" class="windowbg2"> - ', $txt['httpBL_log_comment_long'], '</td>
				<td align="center" valign="middle" class="httpBL_threat_high">', $txt['httpBL_threat_high'], '</td>
			</tr>
			<tr class="windowbg">
				<td align="right" valign="top"><strong>', $txt['httpBL_log_url'], '</strong></td>
				<td align="left" valign="top" class="windowbg2"> - ', $txt['httpBL_log_url_long'], '</td>
				<td align="center" valign="middle" class="httpBL_threat_very_high">', $txt['httpBL_threat_very_high'], '</td>
			</tr>
		</table>
		<br />
		<table border="0" align="center" cellspacing="2" cellpadding="5" class="bordercolor" width="100%">
			<tr class="catbg3">
				<td colspan="9"><strong>', $txt['httpBL_pages'], ':</strong> ', $context['page_index'], '</td>
			</tr><tr class="titlebg">
				<th align="center" style="width: 100px">
					<a href="', $scripturl, '?action=', $httpBL_action, ';sa=', $subpage, ';sort=date', $context['sort_direction'] == 'up' ? ';desc' : '', ';start=', $context['start'], '">' . $txt['httpBL_log_date'], $context['sort'] == 'date' ? '&nbsp;<img src="' . $settings['images_url'] . '/sort_' . $context['sort_direction'] . '.gif" alt="" />' : '', '</a>
				</th>
				<th align="center" style="width: 130px">
					<a href="', $scripturl, '?action=', $httpBL_action, ';sa=', $subpage, ';sort=ip', $context['sort_direction'] == 'up' ? ';desc' : '', ';start=', $context['start'], '">' . $txt['httpBL_log_ip'], $context['sort'] == 'ip' ? '&nbsp;<img src="' . $settings['images_url'] . '/sort_' . $context['sort_direction'] . '.gif" alt="" />' : '', '</a>
				</th>
				<th align="center" style="width: 70px">
					<a href="', $scripturl, '?action=', $httpBL_action, ';sa=', $subpage, ';sort=threat', $context['sort_direction'] == 'up' ? ';desc' : '', ';start=', $context['start'], '">' . $txt['httpBL_log_threat'], $context['sort'] == 'threat' ? '&nbsp;<img src="' . $settings['images_url'] . '/sort_' . $context['sort_direction'] . '.gif" alt="" />' : '', '</a>
				</th>
				<th align="center" style="width: 70px">
					<a href="', $scripturl, '?action=', $httpBL_action, ';sa=', $subpage, ';sort=activity', $context['sort_direction'] == 'up' ? ';desc' : '', ';start=', $context['start'], '">' . $txt['httpBL_log_activity'], $context['sort'] == 'activity' ? '&nbsp;<img src="' . $settings['images_url'] . '/sort_' . $context['sort_direction'] . '.gif" alt="" />' : '', '</a>
				</th>
				<th align="center" style="width: 20px">
					<a href="', $scripturl, '?action=', $httpBL_action, ';sa=', $subpage, ';sort=suspicious', $context['sort_direction'] == 'up' ? ';desc' : '', ';start=', $context['start'], '">' . $txt['httpBL_log_suspicious'], $context['sort'] == 'suspicious' ? '&nbsp;<img src="' . $settings['images_url'] . '/sort_' . $context['sort_direction'] . '.gif" alt="" />' : '', '</a>
				</th>
				<th align="center" style="width: 20px">
					<a href="', $scripturl, '?action=', $httpBL_action, ';sa=', $subpage, ';sort=harvester', $context['sort_direction'] == 'up' ? ';desc' : '', ';start=', $context['start'], '">' . $txt['httpBL_log_harvester'], $context['sort'] == 'harvester' ? '&nbsp;<img src="' . $settings['images_url'] . '/sort_' . $context['sort_direction'] . '.gif" alt="" />' : '', '</a>
				</th>
				<th align="center" style="width: 20px">
					<a href="', $scripturl, '?action=', $httpBL_action, ';sa=', $subpage, ';sort=comment', $context['sort_direction'] == 'up' ? ';desc' : '', ';start=', $context['start'], '">' . $txt['httpBL_log_comment'], $context['sort'] == 'comment' ? '&nbsp;<img src="' . $settings['images_url'] . '/sort_' . $context['sort_direction'] . '.gif" alt="" />' : '', '</a>
				</th>
				<th align="center">
					<a href="', $scripturl, '?action=', $httpBL_action, ';sa=', $subpage, ';sort=username', $context['sort_direction'] == 'up' ? ';desc' : '', ';start=', $context['start'], '">' . $txt['user'], $context['sort'] == 'username' ? '&nbsp;<img src="' . $settings['images_url'] . '/sort_' . $context['sort_direction'] . '.gif" alt="" />' : '', '</a>
				</th>
				<th', $modSettings['httpBL_viewlog_extra'] ? ' rowspan="3"' : '', ' align="center" style="width: 20px"><input type="checkbox" class="check" onclick="invertAll(this, this.form);" />', $modSettings['httpBL_viewlog_extra'] ? '<br />ID' : '', '</th>
			</tr>';
	if ($modSettings['httpBL_viewlog_extra'])
		echo '
			<tr class="titlebg">
				<th colspan="2" align="center"><a href="javascript:void();">', $txt['OS_Browser_OS'], '</a></th>
				<th colspan="2" align="center"><a href="javascript:void();">', $txt['OS_Browser_Browser'], '</a></th>
				<th colspan="2" align="center"><a href="javascript:void();">response[raw]</a></th>
				<th colspan="2" align="center"><a href="javascript:void();">', $txt['httpBL_log_error_message'], '</a></th>
			</tr>
			<tr class="titlebg">
				<th colspan="4" align="center"><a href="javascript:void();">', $txt['httpBL_log_user_agent'], '</a></th>
				<th colspan="4" align="center"><a href="javascript:void();">', $txt['httpBL_log_url'], '</a></th>
			</tr>';
	if (empty($context['log_entries']))
		echo '
			<tr class="windowbg2">
				<td colspan="9">(', $empty_log_message, ')</td>
			</tr>';
	else
	{
		foreach ($context['log_entries'] as $log)
		{
			// Build the links for the IP and username
			$link_ip = $log['ip'] == '' ? $txt['httpBL_unknown'] : '<a href="'. $scripturl. '?action=trackip;searchip='. $log['ip']. '"><strong>'. $log['ip']. '</strong></a>';
			$link_username = $log['id_member'] == 0 ? $log['username'] : '<a href="'. $scripturl. '?action=profile;u='. $log['id_member']. '"><strong>'. $log['username']. '</strong></a>';
			
			echo '
			<tr>
				<td class="', $log['class'], '" align="center">', $log['date'], '</td>
				<td class="windowbg2" align="center">', $link_ip, '</td>
				<td class="', $log['threat'] ? $log['class'] : 'windowbg2', '" align="center">', $log['threat'], '</td>
				<td class="', $log['last_activity'] ? $log['class'] : 'windowbg2', '" align="center">', $log['last_activity'], '</td>
				<td class="', $log['suspicious'] ? $log['class'] : 'windowbg2', '" align="center">', $log['suspicious'], '</td>
				<td class="', $log['harvester'] ? $log['class'] : 'windowbg2', '" align="center">', $log['harvester'], '</td>
				<td class="', $log['comment'] ? $log['class'] : 'windowbg2', '" align="center">', $log['comment'], '</td>
				<td class="windowbg2" align="center">', $link_username, '</td>
				<td class="windowbg" align="center"', $modSettings['httpBL_viewlog_extra'] ? ' rowspan="3"' : '', '><input type="checkbox" name="remove[]" value="', $log['id'], '" class="check" />', $modSettings['httpBL_viewlog_extra'] ? '<br />'. $log['id'] : '', '</td>
			</tr>';
			if ($modSettings['httpBL_viewlog_extra'])
				echo '
				<tr>
					<td colspan="2" align="left" class="windowbg">', $log['os'], '</th>
					<td colspan="2" align="left" class="windowbg">', $log['browser'], '</th>
					<td colspan="2" align="center" class="windowbg">', $log['raw'], '</th>
					<td colspan="2" align="center" class="', $log['class'], '">', $log['errorNumber'], '</th>
				</tr>
				<tr>
					<td colspan="4" align="left" class="windowbg">', $log['user_agent'], '</th>
					<td colspan="4" align="left" class="windowbg">', $log['url'], '</th>
				</tr>';
		}
		echo '
			<tr class="catbg3">
				<td colspan="9"><strong>', $txt['httpBL_pages'], ':</strong> ', $context['page_index'], '</td>
			</tr>
			<tr class="windowbg2">
				<td colspan="9" align="right">
					<input type="submit" name="removeAll" value="', $txt['ban_log_remove_all'], '" onclick="return confirm(\'', $txt['httpBL_log_remove_all_confirm'], '\');" />
					<input type="submit" name="clearThisLog" value="', $txt['httpBL_log_clear_this_log'], '" onclick="return confirm(\'', $txt['httpBL_log_clear_'. $this_log. '_confirm'], '\');" />
					<input type="submit" name="removeSelected" value="', $txt['ban_log_remove_selected'], '" onclick="return confirm(\'', $txt['httpBL_log_remove_selected_confirm'], '\');" />
				</td>
			</tr>';
	}
	echo '
		</table>
		<input type="hidden" name="sc" value="', $context['session_id'], '" />
	</form>';
}

function template_helping()
{
	global $txt, $context;
	
	echo '
		<table border="0" align="center" cellspacing="2" cellpadding="5" class="bordercolor" width="100%">
			<tr class="titlebg">
				<td>' , $txt['httpBL_online_title'] , '</td>
			</tr>
			<tr class="windowbg" valign="top">
				<td colspan="2" align="left"><div style="width: 202px; float: right; padding: 10px; margin: 0px 0px 10px 10px; border: 1px solid #e9d387; background: #4C4C4C; color: white; text-align: center; font-family: Arial,\'Times New Roman\',Verdana,Helvetica,sans-serif; line-height: 20px; font-size: 17px; font-weight: normal;">' , $context['httpBL_skype_div'] , '</div>' , $txt['httpBL_online_body'] , '</td>
			</tr>
			<tr class="titlebg">
				<td>' , $txt['httpBL_help_1_title'] , '</td>
			</tr>
			<tr class="windowbg2" valign="top">
				<td colspan="2" align="left">' , $txt['httpBL_help_1_body'] , '</td>
			</tr>
			<tr class="titlebg">
				<td>' , $txt['httpBL_help_2_title'] , '</td>
			</tr>
			<tr class="windowbg" valign="top">
				<td align="left"><div style="width: 202px; float: right; padding: 10px; margin: 0px 0px 10px 10px; text-align: center;">' , $context['httpBL_donate'] , '</div>' , $txt['httpBL_help_2_body'] , '</td>
			</tr>
			<tr class="titlebg">
				<td>' , $txt['httpBL_about_title'] , '</td>
			</tr>
			<tr class="windowbg2" valign="top">
				<td align="left">' , $txt['httpBL_about_body'] , '</td>
			</tr>
		</table>';
}
?>
