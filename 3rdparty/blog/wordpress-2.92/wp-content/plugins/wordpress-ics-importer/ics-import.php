<?php
/*
Plugin Name: ICS Calendar
Plugin URI: http://www.fullimpact.net/ics-calendar.php
Author: <a href="http://www.fullimpact.net/">Daniel Olfelt</a>
Author URI: http://www.fullimpact.net/
Tags: calendar, events, ics, ical, icalendar, import, google calendar, event widget, ajax
Version: v1.6.8
Description: A plugin for importing multiple (or one) ICS files from Google, Outlook or iCal into a blog page as an event list or an ajax calendar.
Text Domain: WPICSImporter 
*/

require_once('import_ical.php');
require_once('ics-functions.php');
require_once('cal-functions.php');

$myabspath = str_replace("\\","/",ABSPATH);  // required for Windows & XAMPP
define('WINABSPATH', $myabspath);
define('ICSFOLDER', dirname(plugin_basename(__FILE__)));
//define('ICSCALENDAR_ABSPATH', $myabspath.'wp-content/plugins/' . ICSFOLDER .'/');
define('ICSCALENDAR_URLPATH', get_option('siteurl').'/wp-content/plugins/' . ICSFOLDER.'/');

define('ADMIN_OPTIONS_NAME',"ICSAdminOptions");

if (!class_exists("WPICSImporter")) {
	class WPICSImporter {
		var $adminOptionsName 			= "ICSAdminOptions";
		var $showCalendar				= "show-ics-calendar";
		var $showEvents					= "show-ics-events";
		function WPICSImporter() { //constructor
			
		}
		
		function init() {
			$this->getAdminOptions();
		}
		
		function getAdminOptions() {
			$ICSAdminOptions = array(
				'ics_file' 				=> '',
				'ics_files'				=> array(),
				'ics_file_default'		=> '1',
				'title' 				=> 'ICS Calendar',
				'event_limit'	 		=> '15',
				'limit_type'	 		=> 'events',
				'time_format' 			=> 'g:i a',
				'date_format' 			=> 'D, M j',
				'date_format_add_year' 	=> '0',
				'custom_format' 		=> '',
				'gmt_start' 			=> '',
				'gmt_end' 				=> '',
				'gmt_start_now' 		=> 'true',
				'cache_time'	 		=> '3600',
				'enable_cache'	 		=> 'true',
				'use_custom_format' 	=> 'false',
				'widget_event_limit' 	=> '5',
				'widget_title' 			=> 'Upcoming Events',
				'calendar_num_events'	=> '2',
				'date_function'			=> 'date',
				'date_language'			=> '',
				'show_next_prev'		=> '0',
				/* CALENDAR SETTINGS */
				'cal_popups'			=> 'click',
				'cal_startday'			=> '0',
				'cal_permalinks'		=> '0',
				'cal_show_multiday'		=> '1',
				'cal_events_per_day'	=> '2',
				'cal_shrink'			=> '0',
				'cal_css_file'			=> '',
				'cal_event_download'	=> '0',
				/* PRIVACY SETTINGS */
				'privacy_mode'			=> '0',
				'privacy_mode_name'		=> 'Busy'
				);
			$icsOptions = get_option(ADMIN_OPTIONS_NAME);
			if (!empty($icsOptions)) {
				foreach ($icsOptions as $key => $option)
					$ICSAdminOptions[$key] = $option;
			}
			// UPGRADE FROM SINGLE ICS FILE
			if(!empty($ICSAdminOptions['ics_file'])) {
				$ICSAdminOptions['ics_files'] = serialize(array(1=>$ICSAdminOptions['ics_file']));
				unset($ICSAdminOptions['ics_file']);
			}
			update_option(ADMIN_OPTIONS_NAME, $ICSAdminOptions);
			
			return $ICSAdminOptions;
		}
		function printAdminPage() {
		
			global $wp_version;
		
			$icsOptions = $this->getAdminOptions();
			
			
			if (isset($_POST['update_ICSImporterSettings'])) {

				$icsArray=array();
				foreach($_POST['icsFile'] as $k=>$val) {
					if(!empty($val)) {
						//$key = (empty($_POST['icsFileKey'][$k])) ? $k+1 : $_POST['icsFileKey'][$k];
						$icsArray[$k+1] = $val;
					}
				}
				$icsOptions['ics_files'] = serialize($icsArray);
				$icsOptions['ics_file_default'] = $_POST['icsFileDefault'];
				$icsOptions['title'] = $_POST['icsTitle'];
				$icsOptions['event_limit'] = $_POST['icsEventLimit'];
				$icsOptions['limit_type'] = $_POST['icsLimitType'];
				$icsOptions['cache_time'] = $_POST['icsCacheTime'];
				$icsOptions['enable_cache'] = $_POST['icsEnableCache'];
				$icsOptions['time_format'] = $_POST['icsTimeFormat'];
				$icsOptions['date_format'] = $_POST['icsDateFormat'];
				$icsOptions['date_format_add_year'] = $_POST['icsDateFormatAddYear'];
				$icsOptions['gmt_start'] = $_POST['icsGmtStart'];
				$icsOptions['gmt_end'] = $_POST['icsGmtEnd'];
				$icsOptions['gmt_start_now'] = $_POST['icsGmtStartNow'];
				$icsOptions['custom_format'] = $_POST['icsCustomFormat'];
				$icsOptions['use_custom_format'] = $_POST['icsUseCustomFormat'];
				$icsOptions['calendar_num_events'] = $_POST['icsCalendarNumEvents'];
				$icsOptions['date_language'] = $_POST['icsDateLanguage'];
				$icsOptions['date_function'] = $_POST['icsDateFunction'];
				$icsOptions['show_next_prev'] = $_POST['icsShowNextPrev'];
				/* CALENDAR OPTIONS */
				$icsOptions['cal_popups'] = $_POST['icsCalPopups'];
				$icsOptions['cal_startday'] = $_POST['icsCalStartDay'];
				$icsOptions['cal_permalinks'] = $_POST['icsCalPermalinks'];
				$icsOptions['cal_show_multiday'] = $_POST['icsCalMultiDay'];
				$icsOptions['cal_events_per_day'] = $_POST['icsCalEventsPerDay'];
				$icsOptions['cal_shrink'] = $_POST['icsCalShrink'];
				$icsOptions['cal_css_file'] = $_POST['icsCalCssFile'];
				$icsOptions['cal_event_download'] = $_POST['icsCalEventDownload'];
				
				$icsOptions['privacy_mode'] = $_POST['icsPrivacyMode'];
				$icsOptions['privacy_mode_name'] = $_POST['icsPrivacyModeName'];

				if(class_exists('ICalEvents')) {
					foreach($icsArray as $val) {
						$ics_load_error[] = ICalEvents::update_cache($val);
					}
				}
				
				update_option($this->adminOptionsName, $icsOptions);
				
				?>
				<div class="fade updated" id="message"><p><strong><?php _e("Settings Updated.", "WPICSImporter");?></strong></p></div>
				<?php
			}
			foreach($icsOptions as $key=>$item) { $icsOptions[$key] = stripslashes($item); }
			?>
			<style type="text/css">
				.form-table th { white-space:nowrap; }
				<?php if($wp_version < "2.5") { ?>
				.form-table { width:100%; }
				.form-table td { padding:10px; border-bottom:10px solid #FFFFFF; }
				.form-table tr { background:#EFEFEF; }
				.form-table th { border-bottom:10px solid #FFFFFF; text-align:left; padding:10px 25px 0 10px; }
				
				.ui-tabs-nav { margin:0 -13px 0 -13px; }
				.ui-tabs-nav .ui-tabs-selected a { color:#000000; font-weight:bold; }
				<?php } ?>
			</style>
			<div style="width:100%;">
				<div class="wrap">
					<?php if($wp_version>='2.7') { ?><div class="icon32" id="icon-options-general"><br/></div><?php } ?>
                    <h2>ICS Calendar</h2>
				<br />
				<form method="post" action="<?php echo $_SERVER["REQUEST_URI"]; ?>">
                    <h3>General Settings</h3>
                        <a href="javascript:void(0);" onclick="jQuery(this).next('div').toggle();">Installation Instructions</a>
						<div style="display:none; padding-left:20px; border:1px solid #CCC; ">
							<p>This plugin can only be used on a <b>Page</b>.</p>
							<h4>Event List</h4>
							<p>
								<b>[show-ics-events]</b> - shows the event list with default settings.<br />
								<b>[show-ics-events=<i>num_events</i>]</b> - shows the specified number of events<br />
								<b>[show-ics-events cal=<i>ics_num</i>,<i>ics_num</i>]</b> - show only events from the specified calendar file(s)
							</p>
							<h4>Event Calendar</h4>
							<p>
								<b>[show-ics-calendar]</b> - shows the calendar with default settings<br />
								<b>[show-ics-calendar cal=<i>ics_num</i>,<i>ics_num</i>]</b> - shows the calendar using the specified calendar file(s)
							</p>
						</div>
						<table class="form-table">
							<tr valign="top"><th scope="row" width="100">Calendar Title</th>
							<td>
								<input type="text" name="icsTitle" style="width: 250px; " value="<?php _e(stripslashes($icsOptions['title']), 'WPICSImporter') ?>" />
							</td></tr>
							<tr valign="top"><th scope="row">URL to ICS File(s)</th>
								<td>
								<?php
								$icsArray = unserialize($icsOptions['ics_files']);
								if(is_array($icsArray)) {
								foreach($icsArray as $key=>$val) { ?>
									<input type="text" name="icsFileKey[]" value="<?php _e($key, 'WPICSImporter') ?>" style="width:40px;" disabled="disabled" />
									<input type="text" name="icsFile[]" style="width: 80%; " value="<?php _e($val, 'WPICSImporter') ?>" /><br />
								<?php } 
								} ?>
								<input type="text" id="addNewKey" name="icsFileKey[]" value="" style="width:40px;" value="<?php _e($key+1, 'WPICSImporter') ?>" disabled="disabled" />
								<input type="text" id="addNewFile" name="icsFile[]" style="width: 80%; " value="" />
								<?php if(isset($ics_load_error)) {
									foreach($ics_load_error as $error) {
										if(!empty($error))
											echo '<br /><font color="#CC0000">'.$error.'</font>';
									}
								}?>
								</td></tr>
							<tr valign="top"><th scope="row">Default Calendar</th>
								<td>
									<select name="icsFileDefault">
										<?php
										foreach($icsArray as $key=>$val) { 
											echo '<option value="'.$key.'" '.($icsOptions['ics_file_default']==$key ? 'selected="selected"' : '').'>Calendar #'.$key.'</option>'."\n";
										} 
										echo '<option value="combine" '.($icsOptions['ics_file_default']=='combine' ? 'selected="selected"' : '').'>Combine All Calendars</option>'."\n";
										?>
									</select> Select the default calendar to show.
								</td></tr>
							<tr valign="top"><th scope="row">Cache Calendar File</th>
								<td>
								<label><input type="checkbox" name="icsEnableCache" value="true" <?php if ($icsOptions['enable_cache'] == "true") { echo 'CHECKED'; }?> /> Enable caching to save the .ics file on my server.</label>
								<br /><small>The .ics file will be updated once per day. You can update it manually by clicking "Save Changes."</small>
								<!--<input disabled="disabled" type="text" name="icsCacheTime" style="width: 10%; " value="<?php _e($icsOptions['cache_time'], 'WPICSImporter') ?>" /> Seconds
								&nbsp;&nbsp;&nbsp;&nbsp;<small>Set to 1 hour. [Feature coming soon.]</small>-->
								</td></tr>
							<tr valign="top"><th scope="row">Event Display Limit</th>
								<td>
									Show next <input type="text" name="icsEventLimit" style="width: 10%; " value="<?php _e($icsOptions['event_limit'], 'WPICSImporter') ?>" /> 
									<label><input type="radio" name="icsLimitType" value="events" <?php echo ($icsOptions['limit_type']=='events') ? 'checked="checked"' : ''; ?> /> Events</label>
									<label><input type="radio" name="icsLimitType" value="days" <?php echo ($icsOptions['limit_type']=='days') ? 'checked="checked"' : ''; ?> /> Days</label>
									<br /><small>Set to "0" to show all events.</small>
								</td></tr>
							<tr valign="top">
								<th scope="row">Current Event Display</th>
								<td>
								<label><input type="checkbox" id="icsGmtStartNow_yes" name="icsGmtStartNow" value="true" <?php if ($icsOptions['gmt_start_now'] == "true") { echo('CHECKED="checked"'); }?> /> Show only upcoming event. (Only events in the future.)</label>
								<br />
								From <input type="text" name="icsGmtStart" style="width: 100px; " value="<?php _e($icsOptions['gmt_start'], 'WPICSImporter') ?>" /> to
								<input type="text" name="icsGmtEnd" style="width: 100px; " value="<?php _e($icsOptions['gmt_end'], 'WPICSImporter') ?>" />
								<br /><small>Use format 'YYYY-MM-DD' or 'YYYY-MM-DD HH:MM:SS'. This is irrelevant if the Upcoming Events box is checked. Leave these blank if you want to show all events.</small>
								</td></tr>
							<tr valign="top"><th scope="row">Previous &amp; Next</th>
								<td>
                                <label><input type="radio" name="icsShowNextPrev" value="0" <?php if($icsOptions['show_next_prev']=='0') echo ' checked="checked"'; ?>/> Hide</label>
                                <label><input type="radio" name="icsShowNextPrev" value="1" <?php if($icsOptions['show_next_prev']=='1') echo ' checked="checked"'; ?>/> Show</label>
								<br /><small>Whether or not to show buttons that allow users to view future events.</small>
								</td></tr>
							</table>
                    <div<?php if($wp_version >= "2.5") { print ' class="wrap"'; } ?>>
                        <div class="submit"><input type="submit" class="button" name="update_ICSImporterSettings" value="<?php _e('Save Changes', 'WPICSImporter') ?>" /></div>
                    </div>

					<h3>Formatting</h3>
						<table class="form-table">
							<tr valign="top"><th scope="row" width="100">Date Format</th>
								<td>
								<input type="text" name="icsDateFormat" style="width: 20%; " value="<?php _e($icsOptions['date_format'], 'WPICSImporter') ?>" /> <b><?php echo ICalEvents::fdate($icsOptions['date_format'], time()); ?></b> 
								<br /><label><input type="checkbox" name="icsDateFormatAddYear" value="1" <?php if ($icsOptions['date_format_add_year'] == '1') { echo('CHECKED="checked"'); }?> /> Show year at the end of dates that are not within the current year.</label>
								<br /><small>Uses PHP <a target="_blank" href="http://us3.php.net/manual/en/function.date.php">Date Function</a> or <a href="http://us2.php.net/manual/en/function.strftime.php" target="_blank">strftime Function</a>.</small>
								</td></tr>
							<tr valign="top"><th scope="row">Time Format</th>
								<td>
								<input type="text" name="icsTimeFormat" style="width: 20%; " value="<?php _e($icsOptions['time_format'], 'WPICSImporter') ?>" /> <b><?php echo ICalEvents::fdate($icsOptions['time_format'], time()); ?></b> <small>Local Server Time</small>
								<br /><small>Uses PHP <a target="_blank" href="http://us3.php.net/manual/en/function.date.php">Date Function</a> or <a href="http://us2.php.net/manual/en/function.strftime.php" target="_blank">strftime Function</a>.</small>
								</td></tr>
							<tr valign="top"><th scope="row">Custom Event Format</th>
								<td>
									<p>Use custom format? <label><input type="radio" name="icsUseCustomFormat" value="true" <?php if ($icsOptions['use_custom_format'] == "true") { echo ('checked="checked"'); }?> onclick="if(this.checked==true) { document.getElementById('ics_custom_format').style.display='block'; }" /> Yes</label>
										<label><input type="radio" name="icsUseCustomFormat" value="false" <?php if ($icsOptions['use_custom_format'] == "false") { echo('checked="checked"'); }?> onclick="if(this.checked==true) { document.getElementById('ics_custom_format').style.display='none'; }" /> No</label></p>
								<div id="ics_custom_format" style="display:<?php print (($icsOptions['use_custom_format'] == "false") ? 'none' : 'block'); ?>; ">
									<h5 style="margin-bottom:0;">Set Custom Format</h5>
									<textarea name="icsCustomFormat" style="width: 90%; height:100px; "><?php _e($icsOptions['custom_format'], 'WPICSImporter') ?></textarea>
									<br />Use <i>%date-time%</i>, <i>%start-date%</i>, <i>%start-time%</i>, <i>%end-date%</i>, <i>%end-time%</i>, <i>%event-title%</i>, <i>%description%</i> and <i>%location%</i>.
								</div>
							</td></tr>
							<tr valign="top"><th scope="row">Date Function</th>
								<td>
								<select name="icsDateFunction" style="width: 20%; " >
									<option value="strftime" <?php if($icsOptions['date_function']=='strftime') echo ' selected="selected"'; ?>>Strftime Function</option>
									<option value="date" <?php if($icsOptions['date_function']=='date') echo ' selected="selected"'; ?>>Date Function</option>
								</select>
								<br /><small>Uses PHP <a target="_blank" href="http://us3.php.net/manual/en/function.date.php">Date Function</a> or <a href="http://us2.php.net/manual/en/function.strftime.php" target="_blank">strftime Function</a>.</small>
								</td></tr>
							<tr valign="top"><th scope="row">Date Locale (Language)</th>
								<td>
								<input type="text" name="icsDateLanguage" style="width: 20%; " value="<?php _e($icsOptions['date_language'], 'WPICSImporter') ?>" />
								<br /><small>Use a comma to seperate multiple locales. This can only be used if the date function is set to 'strftime'.</small><br />
								<?php 
									ob_start();
									system('locale -a');
									$locales = ob_get_contents();
									ob_end_clean();
									
									$local = explode("\n",$locales);
									echo '<a href="javascript:void(0);" onclick="jQuery(\'#supported_locales\').toggle();">Show / Hide Supported Locales</a> - Only works on Linux';
									echo '<div id="supported_locales" style="display:none; font-size:10px; ">';
									foreach($local as $key=>$val) {
										echo $val." | \n";
									}
									echo '</div>';
									?>
								</td></tr> 
							<tr valign="top"><th scope="row">Privacy Mode</th>
								<td>
									<p>Hide your event information? <label><input type="radio" name="icsPrivacyMode" value="1" <?php if ($icsOptions['privacy_mode'] == "1") { echo('checked="checked"'); }?> onclick="if(this.checked==true) { document.getElementById('ics_privacy_mode').style.display='block'; }" /> Yes</label>
										<label><input type="radio" name="icsPrivacyMode" value="0" <?php if ($icsOptions['privacy_mode'] == "0") { echo('checked="checked"'); }?> onclick="if(this.checked==true) { document.getElementById('ics_privacy_mode').style.display='none'; }" /> No</label></p>
								<div id="ics_privacy_mode" style="display:<?php print (($icsOptions['privacy_mode'] == "0") ? 'none' : 'block'); ?>; ">
									<h5 style="margin:0;">Set Privacy Event Title</h5>
									<input type="text" name="icsPrivacyModeName" style="width: 20%; " value="<?php _e($icsOptions['privacy_mode_name'], 'WPICSImporter') ?>" />
									<small>This will replace your event title</small>
								</div>
							</td></tr>
						</table>

					<h3>Calendar</h3>
						<table class="form-table">
							<tr valign="top"><th scope="row">Show Calendar Popups</th>
								<td>
								<select name="icsCalPopups" style="width: 20%; " >
									<option value="none" <?php if($icsOptions['cal_popups']=='none') echo ' selected="selected"'; ?>>Never</option>
									<option value="mouse-over" <?php if($icsOptions['cal_popups']=='mouse-over') echo ' selected="selected"'; ?>>On Mouse Over</option>
									<option value="click" <?php if($icsOptions['cal_popups']=='click') echo ' selected="selected"'; ?>>On Click</option>
								</select>
								<br /><small>When to show the popups</small>
								</td></tr>
							<tr valign="top"><th scope="row">Calendar Start Day</th>
								<td>
								<select name="icsCalStartDay" style="width: 20%; " >
									
									<?php 
									$cal_days = array('0'=>'Sunday', '1'=>'Monday', '2'=>'Tuesday', '3'=>'Wednesday', '4'=>'Thursday', '5'=>'Friday', '6'=>'Saturday');
									foreach($cal_days as $key=>$value) {
										echo '<option value="'.$key.'" ' . ( ($icsOptions['cal_startday']==$key) ? ' selected="selected"' : '' ) . '>'.$value.'</option>'."\n";
									} ?>
								</select>
								<br /><small>What day of the week would you like the calendar to start on?</small>
								</td></tr>
							<tr valign="top"><th scope="row">Events Per Cell</th>
								<td>
									<input type="text" name="icsCalEventsPerDay" style="width: 10%; " value="<?php _e($icsOptions['cal_events_per_day'], 'WPICSImporter') ?>" /> <small>How many events to display per calendar cell.</small>
								</td></tr>
							<tr valign="top"><th scope="row">Events on Multiple Days</th>
								<td>
                                <label><input type="radio" name="icsCalMultiDay" value="0" <?php if($icsOptions['cal_show_multiday']=='0') echo ' checked="checked"'; ?>/> One Day</label>
                                <label><input type="radio" name="icsCalMultiDay" value="1" <?php if($icsOptions['cal_show_multiday']=='1') echo ' checked="checked"'; ?>/> Multiple Days</label>
								<br /><small>Whether or not to show multiday events on multiple days of the calendar, instead of just the first day.</small>
								</td></tr>
							<tr valign="top"><th scope="row">Calendar Permalinks</th>
								<td>
                                <label><input type="radio" name="icsCalPermalinks" value="0" <?php if($icsOptions['cal_permalinks']=='0') echo ' checked="checked"'; ?>/> Hide</label>
                                <label><input type="radio" name="icsCalPermalinks" value="1" <?php if($icsOptions['cal_permalinks']=='1') echo ' checked="checked"'; ?>/> Show</label>
								<br /><small>Whether or not to show permalinks in the calendar popups.</small>
								</td></tr>
							<tr valign="top"><th scope="row">Calendar Download Links</th>
								<td>
                                <label><input type="radio" name="icsCalEventDownload" value="0" <?php if($icsOptions['cal_event_download']=='0') echo ' checked="checked"'; ?>/> Hide</label>
                                <label><input type="radio" name="icsCalEventDownload" value="1" <?php if($icsOptions['cal_event_download']=='1') echo ' checked="checked"'; ?>/> Show</label>
								<br /><small>Allow users to download individual events to their own calendars.</small>
								</td></tr>
							<tr valign="top"><th scope="row">Shrink Calendar</th>
								<td>
                                <label><input type="radio" name="icsCalShrink" value="0" <?php if($icsOptions['cal_shrink']=='0') echo ' checked="checked"'; ?>/> Always Show 6 Rows</label>
                                <label><input type="radio" name="icsCalShrink" value="1" <?php if($icsOptions['cal_shrink']=='1') echo ' checked="checked"'; ?>/> Shrink Calendar Based on Month</label>
								<br /><small>Whether or not to shrink the height of the calendar based on the weeks in a given month.</small>
								</td></tr>
						</table>
                    <div<?php if($wp_version >= "2.5") { print ' class="wrap"'; } ?>>
                        <div class="submit"><input type="submit" class="button-primary" name="update_ICSImporterSettings" value="<?php _e('Save Changes', 'WPICSImporter') ?>" /></div>
                    </div>
						
					<h3>Advanced</h3>
						<p>These settings are for advanced users. Please only change them if you know what you are doing.</p>
						<table class="form-table">
							<tr valign="top"><th scope="row">Import CSS File</th>
								<td>
									<input type="text" name="icsCalCssFile" style="width: 50%; " value="<?php _e($icsOptions['cal_css_file'], 'WPICSImporter') ?>" /><br />
									<small>An absolute link to a CSS file to replace the one in this plugin. (ie: '/wordpress/css/my-ics-calendar-replacement.css')</small>
								</td></tr>
							</table>
                    <div<?php if($wp_version >= "2.5") { print ' class="wrap"'; } ?>>
                        <div class="submit"><input type="submit" class="button" name="update_ICSImporterSettings" value="<?php _e('Save Changes', 'WPICSImporter') ?>" /></div>
                    </div>
				</form>
				</div>
			</div>
			<?php
		}
		
		function placePageCalendar($content) {
			// Get the options...
			$icsOptions = $this->getAdminOptions();
				
			// SET LOCALE FOR EVERY PAGE/EVENT
			if(!empty($icsOptions['date_language'])) {
				$fixed_locales = preg_replace('/ +/','',$icsOptions['date_language']);
				$locales = explode(',',$fixed_locales);
				if(!setlocale(LC_ALL, $locales)) {
					//return "Locale Error";
					exit;
				}
			}
			
			// Only do this if this is a page and it has the appropriate custom field
			if (is_page()) {

				$savedLimit = $icsOptions['event_limit'];
				$savedDefault = $icsOptions['ics_file_default'];
				
				if(isset($_GET['ics-perm'])) {
					$icsArray = unserialize($icsOptions['ics_files']);
					$output = '<a style="float:right;" href="'.preg_replace('/ics-perm=([^&?]*)(&|\?)?/i','',$_SERVER['REQUEST_URI']).'">'.__('Return to Calendar','WPICSImporter').'</a>'.
								'<br style="clear:both;" />';
					return $output . ICalEvents::display_one_event($icsArray, $_GET['ics-perm']);
				}
				
				if (preg_match('/\['.$this->showEvents.'=?([0-9]*)?( +cal=)?([0-9,]{1,})?\]/i',$content,$args)) {
					define('ICAL_EVENTS_CACHE_TTL', $icsOptions['cache_time']);
					
					preg_match_all('/\['.$this->showEvents.'=?([0-9]*)?( +cal=)?([0-9,]{1,})?\]/i',$content,$args);
					foreach($args[1] as $k=>$arg) {
						$more = '';
						if(!empty($arg)) {
							$icsOptions['event_limit'] = $arg;
							$more .= '='.$arg;
						} else {
							$icsOptions['event_limit'] = $savedLimit;
						}
						if(!empty($args[3][$k])) {
							$icsOptions['ics_file_default'] = $args[3][$k];
							$more .= ' +cal='.$args[3][$k];
						} else {
							$icsOptions['ics_file_default'] = $savedDefault;
						}
						
						if($icsOptions['use_custom_format']=='true') {
							$eventsContent = ICalEvents::custom_display_events($icsOptions);
						} else {
							if($icsOptions['gmt_start_now']=='true') {
								$gmt_start = time();
								$gmt_end = NULL;
								if($icsOptions['limit_type']=='days') {
									$gmt_end = time() + (int)$icsOptions['event_limit']*24*3600;
									$icsOptions['event_limit'] = 0;
								}
							} else {
								if($icsOptions['gmt_start']!='') $gmt_start = strtotime($icsOptions['gmt_start'], time());
								if($icsOptions['gmt_end']!='') $gmt_end = strtotime($icsOptions['gmt_end'], time());
							}
							$icsArray = unserialize($icsOptions['ics_files']);
							if($icsOptions['ics_file_default'] == 'combine') {
								$icsFile = $icsArray;
							} elseif(strstr($icsOptions['ics_file_default'],',')) {
								$cals = explode(',',$icsOptions['ics_file_default']);
								foreach($cals as $calid) {
									$icsFile[] = $icsArray[trim($calid)];
								}
							} elseif(!empty($icsArray[$icsOptions['ics_file_default']])) {
								$icsFile = $icsArray[$icsOptions['ics_file_default']];
							} else {
								$icsFile = array_shift($icsArray);
							}
							$eventsContent = ICalEvents::display_events($icsFile, $gmt_start, $gmt_end, $icsOptions['event_limit']);
							
						}
						$content = preg_replace('/\['.$this->showEvents.$more.'\]/i',$eventsContent,$content);
							
					}
					
				}
				if(preg_match('/\['.$this->showCalendar.'( +cal=)?([0-9,]{1,})?\]/i',$content)) {
					$cssAdd = '<style type="text/css" media="screen">@import "'. (empty($icsOptions['cal_css_file']) ? ICSCALENDAR_URLPATH.'library/ics-calendar.css' : $icsOptions['cal_css_file'] ) .'";</style>'."\n";
					$eventid = '';
					if(!empty($_GET['icsevent'])) $eventid = $_GET['icsevent'];
					if(!empty($_GET['icsdate'])) $eventdate = $_GET['icsdate'];
					
					$icsArray = unserialize($icsOptions['ics_files']);
					preg_match_all('/\['.$this->showCalendar.'( +cal=)?([0-9,]{1,})?\]/i',$content,$finds);
					foreach($finds[2] as $find) {
						if(!empty($find)) {
							$icsOptions['ics_file_default'] = $find;
							$more = ' +cal='.$find;
						} else {
							$icsOptions['ics_file_default'] = $savedDefault;
							$more = '';
						}
						$calDisplay = $cssAdd . icsCalDisplay::initCalendar($icsOptions, $eventid, $eventdate);
						
						$content = preg_replace('/\['.$this->showCalendar.$more.'\]/i',$calDisplay, $content);
						
					}
				}
			}
			return $content;
		}
		
		function addHeader() {
			global $wp_version;
			
			if ($wp_version < "2.5") {
				if ($wp_version > "2.1.3") wp_deregister_script('jquery'); 
				wp_enqueue_script('jquery', ICSCALENDAR_URLPATH .'library/jquery-1.2.3.js', FALSE, '1.2.3');
			}
		}
		function addUserHeader() {
			$this->addHeader();
			wp_enqueue_script('jquery', ICSCALENDAR_URLPATH .'library/jquery-1.2.3.js', FALSE, '1.2.3');
			/*echo '<script type="text/javascript">var jQuery = window.jQuery = function( selector, context ) { return new jQuery.prototype.init( selector, context ); }; window.$ = jQuery; </script>'; //*/
		}		
		function addAdminHeader() {
			if(isset($_GET['page']) && $_GET['page']=='ics-import.php') {
				//$this->addHeader();
				echo "\n".'<style type="text/css" media="screen">@import "'.ICSCALENDAR_URLPATH.'library/ui.tabs.css";</style>'."\n";
			}
		}
		
		function addAdminHeaderJS() {
			global $wp_version;
			
			$plugin_dir = basename(dirname(__FILE__));
			load_plugin_textdomain('WPICSImporter', 'wp-content/plugins/' . $plugin_dir, $plugin_dir );

			if(isset($_GET['page']) && $_GET['page']=='ics-import.php') {
				if ($wp_version < "2.5") {
					wp_deregister_script('jquery'); 
					wp_register_script('jquery', ICSCALENDAR_URLPATH .'library/jquery-1.2.3.js', FALSE, '1.2.3');
				} 
				//wp_enqueue_script('jquery2', ICSCALENDAR_URLPATH .'library/jquery-1.2.3.js', FALSE, '1.2.3');
				wp_enqueue_script('jquery-tabs', ICSCALENDAR_URLPATH .'library/jquery.ui.tabs.pack.js', array('jquery'), '2.7.4');
			}
		}
		
		### SIDEBAR WIDGET COMPILE INFORMATION
		
		function widgetICSImporterInit() {
			if (!function_exists('register_sidebar_widget')) { return; }
			
			//$options = $this->getAdminOptions();
			
			function widgetICSImporter($args) {
				global $dl_pluginICS;
				extract($args, EXTR_SKIP);
				
				if (!isset($dl_pluginICS)) { return; }
				
				$widget = WPICSImporter::getWidgetOptions();				
				
				$options = $dl_pluginICS->getAdminOptions();
				
				$options = WPICSImporter::prepareWidgetOptions($widget, $options);
				
				echo $before_widget . $before_title;
				echo $widget['widget_title'];	
				echo $after_title;
				if($widget['show_next_buttons']==1) {
					?>
					<script type="text/javascript">
						var ICSCalendarCurrentPage = 1;
						function ICSCalendarPage(move) {
							jQuery.get("<?php echo ICSCALENDAR_URLPATH; ?>ajax-load.php", {'widgetPage' : ICSCalendarCurrentPage+parseInt(move)}, function(data) {
								ICSCalendarCurrentPage += parseInt(move);
								jQuery("#ics-calendar-widget-next").show();
								if(ICSCalendarCurrentPage>1) {
									jQuery("#ics-calendar-widget-prev").show();
								} else {
									jQuery("#ics-calendar-widget-prev").hide();
								}
								jQuery("#ics-calendar-widget").html(data);
							});
						}
					</script>
					<?php
				}
				echo '<ul id="ics-calendar-widget">';
				echo ICalEvents::custom_display_events($options);
				echo '</ul>';
				if($widget['widget_link']!='') {
					echo '<small><a href="'.$widget['widget_link'].'">More &raquo;</a></small> ';
				}
				if($widget['show_next_buttons']==1) {
				echo '<small><a id="ics-calendar-widget-prev" href="javascript:ICSCalendarPage(-1);" style="display:none; ">&laquo; Previous</a> &nbsp;&nbsp;&nbsp;
					  <a id="ics-calendar-widget-next" href="javascript:ICSCalendarPage(1);">Next &raquo;</a></small>';
				}
				print $after_widget;
				
			}
			
			function widgetICSImporterOptions()
			{
		
				$options = WPICSImporter::getWidgetOptions();
				
				if($_POST['icsImporterSubmit'])
				{
					$options['widget_event_limit'] = $_POST['icsWidgetEventLimit'];
					$options['widget_title'] = $_POST['icsWidgetTitle'];
					$options['date_format'] = $_POST['icsWidgetDateFormat'];
					$options['time_format'] = $_POST['icsWidgetTimeFormat'];
					$options['custom_format'] = $_POST['icsCustomFormat'];
					$options['widget_link'] = $_POST['icsWidgetLink'];
					$options['hide_time'] = $_POST['icsWidgetHideTime'];
					$options['gmt_start_now'] = $_POST['icsWidgetGmtStartNow'];
					$options['show_next_buttons'] = $_POST['icsWidgetShowNextButtons'];
					update_option('ICSWidgetOptions', $options);
		
				}
				foreach($options as $key=>$item) { $options[$key] = stripslashes($item); }
				?>
		
				<p>Title: <input type="text" name="icsWidgetTitle" value="<?php echo $options['widget_title']; ?>" id="icsWidgetTitle" /></p>
				<p>Event Limit: <input type="text" name="icsWidgetEventLimit" value="<?php echo $options['widget_event_limit']; ?>" id="icsWidgetEventLimit" /></p>
				<label for="icsWidgetGmtStartNow_checked"><input type="checkbox" id="icsWidgetGmtStartNow_checked" name="icsWidgetGmtStartNow" value="true"<?php if ($options['gmt_start_now'] == "true") { echo ' CHECKED'; }?> /> Show upcoming events only.</label>
				<p>Date Format: <input type="text" name="icsWidgetDateFormat" value="<?php echo $options['date_format']; ?>" id="icsWidgetDateFormat" /><br />
				<small>Default will be used if not set.</small></p>
				<p>Time Format: <input type="text" name="icsWidgetTimeFormat" value="<?php echo $options['time_format']; ?>" id="icsWidgetTimeFormat" /><br />
				<label><input type="checkbox" name="icsWidgetHideTime" value="true"<?php if ($options['hide_time'] == "true") { echo ' CHECKED'; }?> /> Do not display time.</label>
				<br /><small>Default will be used if not set.</small></p>
				<p>Bottom Link: <input type="text" name="icsWidgetLink" value="<?php echo $options['widget_link']; ?>" id="icsWidgetLink" /><br />
				<small>Will be used at the bottom of the events.</small></p>
				<p>Custom Event Format:<br />
				<textarea name="icsCustomFormat" style="width:100%; font-size:10px; " rows="4"><?php echo $options['custom_format']; ?></textarea>
				</p>
				<p><label><input type="checkbox" value="1" name="icsWidgetShowNextButtons" <?php if($options['show_next_buttons']==1) echo 'checked="checked"'; ?> id="icsWidgetShowNextButtons" />
					Show Previous / Next buttons for showing more events.</label>
				</p>
				<input type="hidden" id="icsImporterSubmit" name="icsImporterSubmit" value="1" />
				
				<?php
		
			}
			register_sidebar_widget('ICS Calendar', 'widgetICSImporter');
			register_widget_control('ICS Calendar', 'widgetICSImporterOptions', 300, 300);
		}

/* WIDGET FUNCTIONS BELOW HERE */
		
		function prepareWidgetOptions($widget, $options) {
			foreach($widget as $key=>$item) { $widget[$key] = stripslashes($item); }
			foreach($options as $key=>$item) { $options[$key] = stripslashes($item); }
			
			$options['event_limit'] = $widget['widget_event_limit'];
			$options['use_custom_format'] = 'false';
			$options['hide_time'] = $widget['hide_time'];
			
			if($widget['date_format']!='') $options['date_format'] = $widget['date_format'];
			if($widget['time_format']!='') $options['time_format'] = $widget['time_format'];
			if($widget['gmt_start_now']=='true') {
				$options['gmt_start_now'] = 'true';
				$gmt_start = time();
				$gmt_end = NULL;
			}
			$options['limit_type'] = 'events';
			if($widget['custom_format']!='') $options['custom_format'] = $widget['custom_format'];
				else $options['custom_format'] = '<li style="color:#333333; "><strong>%date-time%:</strong>%event-title%</li>';
			
			return $options;
		}
		function getWidgetOptions() {
			if(!$options = get_option('ICSWidgetOptions')) 
				$options = array('widget_event_limit'=>'5', 
					'widget_title'=>'Upcoming Events', 
					'widget_link'=>'', 
					'date_format'=>'', 
					'time_format'=>'',
					'hide_time'=>'',
					'custom_format'=>'',
					'gmt_start_now'=>'true',
					'show_next_buttons'=>'0');
			
			return $options;
		}
	
	}
}

if (class_exists("WPICSImporter")) {
	$dl_pluginICS = new WPICSImporter();
}

//Actions and Filters
if (isset($dl_pluginICS)) {
	if (!function_exists("ICSImporter_ap")) {
		function ICSImporter_ap() {
			global $dl_pluginICS;
			if (!isset($dl_pluginICS)) {
				return;
			}
			if (function_exists('add_options_page')) {
				add_options_page('ICS Calendar', 'ICS Calendar', 9, basename(__FILE__), array(&$dl_pluginICS, 'printAdminPage'));
			}
		}
	}
	//Actions
	add_action('init',  array(&$dl_pluginICS, 'addAdminHeaderJS'), 1);
	add_action('wp_head',  array(&$dl_pluginICS, 'addUserHeader'), 1);
	add_action('admin_head',  array(&$dl_pluginICS, 'addAdminHeader'), 1);
	add_action('admin_menu', 'ICSImporter_ap');
	add_action('activate_wordpress-ics-importer/ics-import.php',  array(&$dl_pluginICS, 'init'));
	add_action('plugins_loaded', array(&$dl_pluginICS, 'widgetICSImporterInit'));
	//add_action('wp_head', array(&$dl_pluginICS, 'addHeaderCode'), 1);
	//Filters
	add_filter('the_content', array(&$dl_pluginICS, 'placePageCalendar'), '7');
}


?>