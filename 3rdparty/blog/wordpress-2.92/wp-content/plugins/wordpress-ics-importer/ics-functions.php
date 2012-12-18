<?php

if (! defined('ICAL_EVENTS_CACHE_TTL')) define('ICAL_EVENTS_CACHE_TTL', 60 * 60);  // 1 hour
define('ICAL_EVENTS_CACHE_DEFAULT_EXTENSION', 'ics');
define('ICAL_EVENTS_MAX_REPEATS', '100');
if (! defined('ICAL_EVENTS_DEBUG')) define('ICAL_EVENTS_DEBUG', false);

// As defined by import_ical.php
$ICAL_EVENTS_REPEAT_INTERVALS = array(
	1 => 24 * 60 * 60,        // Daily
	2 => 7 * 24 * 60 * 60,    // Weekly
	3 => 7 * 24 * 4 * 60 * 60,    // Monthly
	5 => 365 * 24 * 60 * 60,  // Yearly
);

if (! class_exists('ICalEvents')) {
	class ICalEvents {
		/*
		 * Display up to the specified number of events that fall within
		 * the specified range on the specified calendar. All
		 * constraints are optional.
		 */
		
		function display_events($url, $gmt_start, $gmt_end, $limit, $start=-1, $uuid=NULL) {
			$icsOptions = get_option(ADMIN_OPTIONS_NAME);
			
			//$limit = $icsOptions['event_limit'];
			$date_format = $icsOptions['date_format'];
			$time_format = $icsOptions['time_format'];
			
			$events = ICalEvents::get_events($url, $gmt_start, $gmt_end, $limit);
						
			if (!is_array($events)) return $events;
			
			if($start>0) $events = array_slice($events,$start);
			
			if(!$uuid) $uuid = rand(1,1000000);
			if($start==-1) $output = '<div id="ics-event-list-'.$uuid.'">';
			$output .= '<ul>';
			foreach ($events as $event) {
				$output .= '<li style="list-style:none; ">';

				$output .= '<strong>';
				
				$save_date_format = $date_format;
				if(date('Y',$event['StartTime'])!=date('Y') && $icsOptions['date_format_add_year']=='1') {
					if($icsOptions['date_function']=='date') {
						$date_format .= ', Y';
					} else {
						$date_format .= ', %Y';
					}
				}

				if (ICalEvents::is_all_day($event['StartTime'], $event['EndTime'])) {
					$output .= (ICalEvents::fdate($date_format, $event['StartTime']));
				}
				else {
					$output .= (ICalEvents::format_date_range($event['StartTime'], $event['EndTime'], $event['Untimed'], $date_format, $time_format));
				}
				$output .= '</strong>: ';

				if (!empty($event['Summary'])) {
					$output .= '<i>';
					if ($event['URL']) {
						$output .= '<a href="' . $event['URL'] . '">';
					}
					$output .= ($event['Summary']);
					if ($event['URL']) {
						$output .= '</a>';
					}
					$output .= '</i><br />';
				}

				if (!empty($event['Description'])) {
					$output .= nl2br(trim($event['Description']));
				}

				if (!empty($event['Location'])) {
					$output .= ' (' . ($event['Location']) . ')';
				}

				if (!empty($event['UID'])) {
					//$output .= '<!-- ' . htmlentities($event['UID']) . ' -->';
				}
				$output .= '</li>' . "\n";
				$date_format = $save_date_format;
			}
			$output .= '</ul>';
			if($start==-1) {
				$output .= '</div>';
				if($icsOptions['show_next_prev']==1) {
					$output .= '<script type="text/javascript">
								var ICSEventsCurrentPage'.$uuid.' = 0;
								var ICSEventsStart'.$uuid.' = "'.$gmt_start.'";
								var ICSEventsEnd'.$uuid.' = "'.$gmt_end.'";
								function ICSEventsPage'.$uuid.'(move) {
									ICSEventsCurrentPage'.$uuid.' += parseInt(move);
									var options = {
											\'eventsPage\' : ICSEventsCurrentPage'.$uuid.',
											\'eventsStart\' : ICSEventsStart'.$uuid.',
											\'eventsEnd\' : ICSEventsEnd'.$uuid.',
											\'eventsFile\' : \''.base64_encode(serialize($url)).'\',
											\'uuid\' : \''.$uuid.'\'
											}
									jQuery.get("'.ICSCALENDAR_URLPATH.'ajax-load.php", options, function(data) {
										jQuery("#ics-event-list-'.$uuid.'-next").show();
										if(ICSEventsCurrentPage'.$uuid.'>=1) {
											jQuery("#ics-event-list-'.$uuid.'-prev").show();
										} else {
											jQuery("#ics-event-list-'.$uuid.'-prev").hide();
										}
										jQuery("#ics-event-list-'.$uuid.'").html(data);
									});
								}
							</script>';
					$output .= '<small><a id="ics-event-list-'.$uuid.'-prev" href="javascript:ICSEventsPage'.$uuid.'(-1);" style="display:none; ">&laquo; '.__('Previous','WPICSImporter').'</a> | <a id="ics-event-list-'.$uuid.'-next" href="javascript:ICSEventsPage'.$uuid.'(1);">'.__('Next','WPICSImporter').' &raquo;</a></small>';
				}
			}
			
			return $output;
		}
		
		function display_one_event($url, $UID) {
			$icsOptions = get_option(ADMIN_OPTIONS_NAME);
			
			$date_format = $icsOptions['date_format'];
			$time_format = $icsOptions['time_format'];

			$events = ICalEvents::get_event($url, $UID);
			$event = array_pop($events);			
			$output = '<div class="ics-event-item">';

			$output .= '<strong>';
			$save_date_format = $date_format;
			if(date('Y',$event['StartTime'])!=date('Y') && $icsOptions['date_format_add_year']=='1') {
				if($icsOptions['date_function']=='date') {
					$date_format .= ', Y';
				} else {
					$date_format .= ', %Y';
				}
			}

			if (ICalEvents::is_all_day($event['StartTime'], $event['EndTime'])) {
				$output .= (ICalEvents::fdate($date_format, $event['StartTime']));
			}
			else {
				$output .= (ICalEvents::format_date_range($event['StartTime'], $event['EndTime'], $event['Untimed'], $date_format, $time_format));
			}
			$output .= '</strong>: ';

			if (!empty($event['Summary'])) {
				$output .= '<i>';
				if ($event['URL']) {
					$output .= '<a href="' . $event['URL'] . '">';
				}
				$output .= ($event['Summary']);
				if ($event['URL']) {
					$output .= '</a>';
				}
				$output .= '</i><br />';
			}

			if (!empty($event['Description'])) {
				$output .= nl2br(trim($event['Description']));
			}

			if (!empty($event['Location'])) {
				$output .= ' (' . ($event['Location']) . ')';
			}

			if (!empty($event['UID'])) {
				//$output .= '<!-- ' . htmlentities($event['UID']) . ' -->';
			}
			$output .= '</div>' . "\n";
			
			return $output;
		}
		
		/* DISPLAY CUSTOM EVENT */
		
		function custom_display_events($options, $return_count = false) {
			if(!isset($options['events_page'])) $options['events_page']=1;
			
			if($options['gmt_start_now']=='true') {
				$gmt_start = time();
				$gmt_end = NULL;
				if($options['limit_type']=='days') {
					$gmt_end = time() + (int)$options['event_limit']*24*3600 * (int)$options['events_page'];
					$options['event_limit'] = 0;
				}
			} else {
				if($options['gmt_start']!='') $gmt_start = strtotime($options['gmt_start'], time());
				if($options['gmt_end']!='') $gmt_end = strtotime($options['gmt_end'], time());
			}
			$icsArray = unserialize($options['ics_files']);
			if($options['ics_file_default'] == 'combine') {
				$icsFile = $icsArray;
			} elseif(strstr($options['ics_file_default'],',')) {
				$cals = explode(',',$options['ics_file_default']);
				foreach($cals as $calid) {
					$icsFile[] = $icsArray[trim($calid)];
				}
			} elseif(!empty($icsArray[$options['ics_file_default']])) {
				$icsFile = $icsArray[$options['ics_file_default']];
			} else {
				$icsFile = array_shift($icsArray);
			}
			$events = ICalEvents::get_events($icsFile, $gmt_start, $gmt_end, ($options['event_limit'] * (int)$options['events_page']) );
			if (!is_array($events)) return $events;
			
			if(count($events) > $options['event_limit']) {
				$event_offset = $options['event_limit'] * ($options['events_page'] - 1);
				$events = array_slice($events,$event_offset);
			}
			
			$final_output = '';
			
			foreach ($events as $event) {
				//$final_output .= '<div>';
				$output = stripslashes($options['custom_format']);
				
				$save_date_format = $options['date_format'];
				if(date('Y',$event['StartTime'])!=date('Y') && $options['date_format_add_year']=='1') {
					if($options['date_function']=='date') {
						$options['date_format'] .= ', Y';
					} else {
						$options['date_format'] .= ', %Y';
					}
				}

				if (ICalEvents::is_all_day($event['StartTime'], $event['EndTime']) || (isset($options['hide_time']) && $options['hide_time']=='true')) {
					$formated_date = (ICalEvents::fdate($options['date_format'], $event['StartTime']));
					$output = str_replace('%start-time%','',$output);
					$output = str_replace('%end-time%','',$output);
					$output = str_replace('%end-date%','',$output);
				}
				else {
					$formated_date = (ICalEvents::format_date_range($event['StartTime'], $event['EndTime'], $event['Untimed'], $options['date_format'], $options['time_format']));
				}
				$output = str_replace('%date-time%',$formated_date,$output);
				
				if($event['Untimed']) {
					$output = str_replace('%start-time%','',$output);
					$output = str_replace('%end-time%','',$output);
				} else {
					$formatted_time = ICalEvents::fdate($options['time_format'], $event['StartTime']);
					$output = str_replace('%start-time%',$formatted_time,$output);
					$formatted_time = ICalEvents::fdate($options['time_format'], $event['EndTime']);
					$output = str_replace('%end-time%',$formatted_time,$output);
				}
				
				$formatted_date = ICalEvents::fdate($options['date_format'], $event['StartTime']);
				$output = str_replace('%start-date%',$formatted_date,$output);
				
				if(ICalEvents::is_same_day($event['StartTime'], $event['EndTime'])) {
					$output = str_replace('%end-date%','',$output);
				} else {
					$formatted_date = ICalEvents::fdate($options['date_format'], $event['EndTime']);
					$output = str_replace('%end-date%',$formatted_date,$output);
				}
				
				if($event['Summary']) {
					$event_title = ($event['Summary']);
				} else {
					$event_title = 'Untitled Event';
				}
				$output = str_replace('%event-title%',$event_title,$output);
				
				if($event['Description']) {
					$event_description = ($event['Description']);
				} else {
					$event_description = '';
				}
				$output = str_replace('%description%',$event_description,$output);
				
				if($event['Location']) {
					$event_location = ($event['Location']);
				} else {
					$event_location = '';
				}
				$output = str_replace('%location%',$event_location,$output);
				
				if ($event['UID']) {
					//$output .= '<!-- ' . htmlentities($event['UID']) . ' -->';
				}

				$final_output .= str_replace(array("\r\n", "\n", "\r"), ' ', $output).'';
				//$final_output .= eregi_replace("[\r\n]","",$output);// . '</div>';
				$options['date_format'] = $save_date_format;
			}
			if($return_count == true) {
				return array( 'output'=>$final_output, 'count'=>count($events) );
			} else {
				return $final_output;
			}
		}

		/*
		 * Return a specific event using the UID
		 */
		function get_event($url, $uid, $date='') {
			if($url=='') return "<i>".__('There is no calendar set. Please review the calendar settings.','WPICSImporter')."</i>";
			
			if(!is_array($url)) { $url = array($url); }
			$allEvents = array();
			$calID = 1;
			foreach($url as $u) {
				$file = ICalEvents::cache_url($u);
				if (! $file) {
					return "<i>".sprintf(__('iCal Events: Error loading [%s]','WPICSImporter'), $url)."</i>";
				}
				$events = ics_import_parse($file);
				foreach($events as $k=>$na) {
					$events[$k]['calID'] = $calID;
				}
				$allEvents = array_merge($allEvents, $events);
				
				$calID++;
			}
			$events = $allEvents;
			
			if(!defined('CURRENT_UID')) define('CURRENT_UID', $uid);
			
			function filter_events($event) {
				if($event['UID'] == CURRENT_UID) {
					return $event;
				}
			}
			
			$events = array_filter($events, 'filter_events');
			
			//$events = ICalEvents::constrain($events, $date-100, $date+100, 1);
			//echo $date;
			//print_r($events); exit;
			return $events;
		}

		/* Sorts the events by date, then alphabetically */
		function sortEvents($a, $b) {
			if ($a['StartTime'] == $b['StartTime']) {
				return strnatcasecmp($a['Summary'],$b['Summary']);
			}
			return ($a['StartTime'] < $b['StartTime']) ? -1 : 1;
		}
		
		/*
		 * Return a list of events from the specified calendar.  For
		 * more on what's available, read import_ical.php or use
		 * print_r.
		 */
		function get_events($url, $gmt_start = null, $gmt_end = null, $limit = null) {
			if($url=='') return "<i>".__('There is no calendar set. Please review the calendar settings.','WPICSImporter')."</i>";
			
			
			if(!is_array($url)) { $url = array($url); }
			$allEvents = array();
			$calID = 1;
			foreach($url as $u) {
				$file = ICalEvents::cache_url($u);
				if (! $file) {
					return "<i>".sprintf(__('iCal Events: Error loading [%s]','WPICSImporter'), $url)."</i>";
				}
				$events = ics_import_parse($file);
				foreach($events as $k=>$na) {
					$events[$k]['calID'] = $calID;
				}
				$allEvents = array_merge($allEvents, $events);
				
				$calID++;
			}
			$events = $allEvents;
			
			$events = ICalEvents::constrain($events, $gmt_start, $gmt_end, $limit);
			
			//usort($events, array('ICalEvents', 'sortEvents'));

			if (!is_array($events) || count($events) <= 0) {
				return "<i>There are no events.</i>"; //"iCal Events: Error parsing calendar [$url]";
			}
			
			return $events;
		}

		/*
		 * Cache the specified URL and return the name of the
		 * destination file.
		 */
		function cache_url($url, $force_reload=false) {
			$file = ICalEvents::get_cache_file($url);

			if (! file_exists($file) || (time() - filemtime($file) >= ICAL_EVENTS_CACHE_TTL) || $force_reload==true) {
				$data = wp_remote_fopen($url);
				if ($data === false) {
					print("Your ICS file is unable to update.");
					return $file;
				}

				$dest = fopen($file, 'w') or die("Error opening $file");
				fwrite($dest, $data);
				fclose($dest);
			}

			return $file;
		}
		function update_cache($url) {
			$file = ICalEvents::get_cache_file($url);
			$data = wp_remote_fopen($url);
			if ($data === false) return "".sprintf(__('iCal Events: Error loading [%s]','WPICSImporter'), $url)."";

			if(($dest = fopen($file, 'w'))===false) return "Error opening $file";
			fwrite($dest, $data);
			fclose($dest);
		}
		/*
		 * Return the full path to the cache file for the specified URL.
		 */
		function get_cache_file($url) {
			return ICalEvents::get_cache_path() . ICalEvents::get_cache_filename($url);
		}

		/*
		 * Attempt to create the cache directory if it doesn't exist.
		 * Return the path if successful.
		 */
		function get_cache_path() {
			$cache_path = rtrim(ABSPATH . 'wp-content/ics-importer-cache', '/').'/';

			if (! file_exists($cache_path)) {
				if (is_writable(dirname($cache_path))) {
					if (! mkdir($cache_path, 0777)) {
						die("Error creating cache directory ($cache_path)");
					}
				}
				else {
					if(function_exists('get_settings')) {
						die("Your cache directory (<code>$cache_path</code>) needs to be writable for this plugin to work. Double-check it. <a href='" . get_settings('siteurl') . "/wp-admin/plugins.php?action=deactivate&amp;plugin=ical-events.php'>Deactivate the iCal Events plugin</a>.");
					}
				}
			}

			return $cache_path;
		}

		/*
		 * Return the cache filename for the specified URL.
		 */
		function get_cache_filename($url) {
			$extension = ICAL_EVENTS_CACHE_DEFAULT_EXTENSION;

			$matches = array();
			if (preg_match('/\.(\w+)$/', $url, $matches)) {
				$extension = $matches[1];
			}

			return md5($url) . ".$extension";
		}

		/*
		 * Constrain the list of events to those which fall between the
		 * specified start and end time, up to the specified number of
		 * events.
		 */
		function constrain($events, $gmt_start = null, $gmt_end = null, $limit = null) {
			$repeats = ICalEvents::collapse_repeats($events, $gmt_start, $gmt_end, $limit);
			if (is_array($repeats) and count($repeats) > 0) {
				$events = array_merge($events, $repeats);
			}

			$events = ICalEvents::sort_by_key($events, 'StartTime');
			if (! $limit) $limit = count($events);

			$constrained = array();
			$count = 0;
			foreach ($events as $event) {
				if (ICalEvents::falls_between($event, $gmt_start, $gmt_end)) {
					$constrained[] = $event;
					++$count;
				}

				if ($count >= $limit) break;
			}

			return $constrained;
		}

		/*
		 * Sort the specified associative array by the specified key.
		 * Originally from
		 * http://us2.php.net/manual/en/function.usort.php.
		 */
		function sort_by_key($data, $key) {
			// Reverse sort
			$compare = create_function('$a, $b', 'if ($a["' . $key . '"] == $b["' . $key . '"]) { return 0; } else { return ($a["' . $key . '"] < $b["' . $key . '"]) ? -1 : 1; }');
			usort($data, $compare);

			return $data;
		}

		/*
		 * Return true iff the specified event falls between the given
		 * start and end times.
		 */
		function falls_between($event, $gmt_start, $gmt_end) {
			$falls_between = false;

			if ($event['Untimed'] or $event['Duration'] == 1440) {
				// Keep all-day events for the whole day
				$falls_between = (
									(!$gmt_start or ($event['StartTime'] + 86400 > $gmt_start || $event['EndTime'] > $gmt_start) )
								 and (!$gmt_end or ($event['EndTime'] < $gmt_end || $event['StartTime'] + 86400 < $gmt_end) )
								 );
			}
			else {
				$falls_between = (
									(!$gmt_start or ($event['StartTime'] > $gmt_start && $event['EndTime'] > $gmt_start) )
								 and (!$gmt_end or ($event['EndTime'] < $gmt_end && $event['StartTime'] < $gmt_end) )
								 );
			}

			return $falls_between;
		}

		/*
		 * Collapse repeating events down to nonrepeating events at the
		 * corresponding repeat time.
		 */
		function collapse_repeats($events, $gmt_start, $gmt_end, $limit) {
			$repeats = array();

			foreach ($events as $event) {
				if (isset($event['Repeat'])) {
					$r = ICalEvents::get_repeats_between($event, $gmt_start, $gmt_end, $limit, $events);
					if (is_array($r) and count($r) > 0) {
						$repeats = array_merge($repeats, $r);
					}
				}
			}

			return $repeats;
		}

		/*
		 * If the specified event repeats between the given start and
		 * end times, return one or more nonrepeating events at the
		 * corresponding times.
		 * TODO: Only handles some types of repeating events
		 * TODO: Check for exceptions to the RRULE
		 */
		function get_repeats_between($event, $gmt_start, $gmt_end, $limit, $events) {
			global $ICAL_EVENTS_REPEAT_INTERVALS;

			$rrule = $event['Repeat'];

			$repeats = array();

			//print_r($rrule);
			if (isset($ICAL_EVENTS_REPEAT_INTERVALS[$rrule['Interval']])) {
				$interval    = $ICAL_EVENTS_REPEAT_INTERVALS[$rrule['Interval']] * ($rrule['Frequency'] ? $rrule['Frequency'] : 1);
				$repeat_days = ICalEvents::get_repeat_days($rrule['RepeatDays']);
				$t = getdate($event['StartTime']);
				
				$exceptions_array = array();
				$exceptions_array = $rrule['Exceptions'];
				foreach($events as $value) {
					if($value['UID'] == $event['UID'] && !empty($value['RecurrenceID'])) {
						$exceptions_array[] = $value['RecurrenceID'];
					}
				}
				
				$repeat = null;
				$count = 0;
				while ($count <= ICAL_EVENTS_MAX_REPEATS) {

					if(isset($rrule['ByMonthDay'])) {
						if($count>0) {
							$repeat = $event;
							unset($repeat['Repeat']);
							$repeat['StartTime'] = mktime($t['hours'],$t['minutes'],$t['seconds'],$t['mon']+$count,$rrule['ByMonthDay'],$t['year']);
							$repeat['EndTime'] = $repeat['StartTime'] - $event['StartTime'];
							if (!ICalEvents::is_duplicate($repeat, $event) && ICalEvents::falls_between($repeat, $gmt_start, $gmt_end) && !@in_array($repeat['StartTime'],$exceptions_array)) {
								$repeats[] = $repeat;
							}
						}
					} else {
						if ($repeat_days) {
							foreach ($repeat_days as $repeat_day=>$repeat_week) {
								$repeat = ICalEvents::get_repeat($event, $interval, $count, $repeat_day, $repeat_week);
								if (! ICalEvents::is_duplicate($repeat, $event)
									and ICalEvents::falls_between($repeat, $gmt_start, $gmt_end) && !@in_array($repeat['StartTime'],$exceptions_array)) {
									$repeats[] = $repeat;
								}
	
								if (ICalEvents::after_rrule_end_time($repeat, $rrule)) break;
							}
						}
						else {
							$repeat = ICalEvents::get_simple_repeat($event, $interval, $count);
							if (! ICalEvents::is_duplicate($repeat, $event)
								and ICalEvents::falls_between($repeat, $gmt_start, $gmt_end) && !@in_array($repeat['StartTime'],$exceptions_array)) {
								$repeats[] = $repeat;
							}
						}
					
					}
					
					if (ICalEvents::after_rrule_end_time($repeat, $rrule)) break;

					// Don't repeat past the user-defined limit, if one exists
					if ($limit and $count >= $limit) break;

					++$count;
				}
			}
			else {
				echo "Unknown repeat interval: {$rr['Interval']}";
			}

			return $repeats;
		}

		/*
		 * Given a string like 'nynynyn' from import_ical.php, return
		 * an array containing the weekday numbers (0 = Sun, 6 = Sat).
		 */
		function get_repeat_days($repeats) {
			if(!is_array($repeats)) return NULL;
			$repeat_days = array();
			$dayArray = array(
							'SU'=>0,
							'MO'=>1,
							'TU'=>2,
							'WE'=>3,
							'TH'=>4,
							'FR'=>5,
							'SA'=>6
							);
			foreach($repeats as $key=>$num) {
				
				$repeat_days[$dayArray[$key]] = $num;
			}

			return $repeat_days;
		}

		/*
		 * Using the specified event as a base, return the repeating
		 * event the given number of intervals (in seconds) in the
		 * future on the repeat day (0 = Sun, 6 = Sat).
		 */
		function get_repeat($event, $interval, $count, $repeat_day, $repeat_week='') {
			$repeat = ICalEvents::get_simple_repeat($event, $interval, $count);

			$date = getdate($event['StartTime']);
			if(!empty($repeat_week) && is_numeric($repeat_week)) {
				if($repeat_week>0) {
					$rd = getdate($repeat['StartTime']);
					$startDiff = date('w',mktime(0,0,0,$rd['mon'],1,$rd['year'])) - $date['wday'];
					
					//$repeat['StartTime'] = mktime($rd['hours'],$rd['minutes'],$rd['seconds'],$rd['mon'],$rd['mday'],$rd['year']);
					
					if($startDiff==0) {
						$woffset = 0;
					} else {
						$woffset = (7 - $startDiff);
					}
					$daysIntoMonth = (($repeat_week) * (7+$woffset));
					//if(strstr($event['Description'],'Rockin\'')) echo 'here!';
					//$offset = (($repeat_week-1) * (7+$woffset) * 24 * 3600);
					$tempStart = $repeat['StartTime'];
					$repeat['StartTime'] = mktime($rd['hours'],$rd['minutes'],$rd['seconds'],$rd['mon'], $daysIntoMonth,$rd['year']);
					$offset = $repeat['StartTime'] - $tempStart;
				} else {
					
					
				}
				$repeat['StartTime'] += $offset;
			} else {
				$wday = $date['wday'];
				$offset = ($repeat_day - $wday) * 86400;
				$repeat['StartTime'] += $offset;
			}
			if (isset($repeat['EndTime'])) {
				$repeat['EndTime'] += $offset;
			}

			return $repeat;
		}

		/*
		 * Using the specified event as a base, return the repeating
		 * event the given number of intervals (in seconds) in the
		 * future.
		 */
		function get_simple_repeat($event, $interval, $count) {
			$duration = 0;

			if ($event['Duration']) {
				$duration = $event['Duration'] * 60;
			}
			else if ($event['EndTime']) {
				$duration = $event['EndTime'] - $event['StartTime'];
			}

			$repeat = $event;
			unset($repeat['Repeat']);
			
			if($interval == (365 * 24 * 60 * 60)) {
				$y = getdate($repeat['StartTime']);
				$repeat['StartTime'] = mktime($y['hours'],$y['minutes'],$y['seconds'],$y['mon'],$y['mday'],$y['year']+$count);
			} else {
				$repeat['StartTime'] += $interval * $count;
			}
			
			// Default to no duration
			$repeat['EndTime'] = $repeat['StartTime'];
			if ($duration > 0) {
				$repeat['EndTime'] = $repeat['StartTime'] + $duration;
			}

			// Handle timezone changes since the initial event date
			/*$offset = ICalEvents::fdate('Z', $event['StartTime']) - ICalEvents::fdate('Z', $repeat['StartTime']);
			$repeat['StartTime'] += $offset;
			$repeat['EndTime'] += $offset;*/

			return $repeat;
		}

		/*
		 * Return true if the specified event is passed the
		 * RRULE's end time.  If an end time isn't specified,
		 * return false.
		 */
		function after_rrule_end_time($repeat, $rrule) {
			return ($repeat and $rrule
				and $repeat['StartTime'] and $rrule['EndTime']
				and $repeat['StartTime'] >= $rrule['EndTime']);
		}

		/*
		 * Return true if the start and end times are the same.
		 */
		function is_duplicate($event1, $event2) {
			return ($event1['StartTime'] == $event2['StartTime']
				and $event1['EndTime'] == $event2['EndTime']);
		}

		/*
		 * Return a string representing the specified date range.
		 */
		function format_date_range($gmt_start, $gmt_end, $untimed, $date_format, $time_format, $separator = ' &ndash; ') {
			$output = '';
			$isToday = ICalEvents::is_today($gmt_start);
			if($isToday) {
				$output .= 'Today ';
			}
			$output .= ICalEvents::format_date_range_part($gmt_start, $untimed, $isToday, $date_format, $time_format);

			if ($gmt_start != $gmt_end) {
				$output .= $separator;
				if($untimed) $gmt_end--;
				$output .= ICalEvents::format_date_range_part($gmt_end, $untimed, ICalEvents::is_same_day($gmt_start, $gmt_end), $date_format, $time_format);
			}

			$output = trim(preg_replace('/\s{2,}/', ' ', $output));

			return $output;
		}

		/*
		 * Return a string representing the specified date.
		 */
		function format_date_range_part($gmt, $untimed, $only_use_time, $date_format, $time_format) {
			$default_format = "$date_format $time_format";

			$format = $default_format;
			if ($untimed) {
				$format = $date_format;
				
			}
			else if ($only_use_time) {
				$format = $time_format;
			}

			return ICalEvents::fdate($format, $gmt);
		}

		/*
		 * Given a time value (as seconds since the epoch), return true
		 * iff the time falls on the current day.
		 */
		function is_today($gmt) {
			return ICalEvents::is_same_day(strtotime(current_time('mysql')), $gmt);
		}

		/*
		 * Return true iff the two times span exactly 24 hours, from
		 * midnight one day to midnight the next.
		 */
		function is_all_day($gmt1, $gmt2) {
			$local1 = localtime(($gmt1 <= $gmt2 ? $gmt1 : $gmt2), 1);
			$local2 = localtime(($gmt1 <= $gmt2 ? $gmt2 : $gmt1), 1);

			return (abs($gmt2 - $gmt1) == 86400
				and $local1['tm_hour'] == 0);
		}

		/*
		 * Return true iff the two specified times fall on the same day.
		 */
		function is_same_day($gmt1, $gmt2) {
			$local1 = localtime($gmt1, 1);
			$local2 = localtime($gmt2, 1);

			return ($local1['tm_mday'] == $local2['tm_mday']
				and $local1['tm_mon'] == $local2['tm_mon']
				and $local1['tm_year'] == $local2['tm_year']);
		}
		
		function fdate($format, $gmt) {
			$icsOptions = get_option(ADMIN_OPTIONS_NAME);
			if($icsOptions['date_function']=='strftime') {
				return strftime($format, $gmt);
			} else {
				return date($format, $gmt);
			}
		}
				
	}
}
?>
