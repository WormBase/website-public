<?php

if (! class_exists('icsCalDisplay')) {
	class icsCalDisplay {
		var $cellWidth = '15%';
		var $cellHeight = '50px';
		
		function initCalendar($options, $eventid='', $eventdate='', $cuid='') {
			if(empty($cuid)) $cuid = rand(1,5000);
			$cellStyle = ' style="width:'.$this->cellWidth.'; height:'.$this->cellHeight.'; "';
			//$calContent .= _r($calEvents);
			$calContent .= '<script type="text/javascript">
				jQuery(document).ready(function() { 
						var options = {
							realPath:"'.base64_encode($_SERVER['REQUEST_URI']).'",
							calendar:"'.$options['ics_file_default'].'",
							cuid:"'.$cuid.'"
						};
					';
			$calContent .= '				jQuery("#ics-prev-button'.$cuid.', #ics-next-button'.$cuid.'").click(function() {
						jQuery.get("' . ICSCALENDAR_URLPATH . 'ajax-load.php?showMonth="+jQuery(this).attr("month")+"", options, function(data) {
							jQuery("#ics-calendar-uid'.$cuid.' > div").unbind();
							jQuery().unbind("mousemove");
							jQuery("#ics-calendar-uid'.$cuid.'").html(data);
						});
					});
				});
				';

			$calContent .= '</script>';
			$calContent .= '<div class="ics-calendar-header"><small><a class="ics-nav-button" id="ics-prev-button'.$cuid.'" href="javascript:void(0);">&laquo; '.__('Prev Month','WPICSImporter').'</a></small> ' . 
							'<div id="ics-calendar-header-text'.$cuid.'"></div> <small><a class="ics-nav-button" id="ics-next-button'.$cuid.'" href="javascript:void(0);">'.__('Next Month','WPICSImporter').' &raquo;</a></small></div>';
			$calContent .= '<div id="ics-calendar-uid'.$cuid.'" class="ics-calendar-holder">';
			$calContent .= icsCalDisplay::showCalendar($options, NULL, $eventid, $eventdate, $cuid);
			$calContent .= '</div>';

			return $calContent;
			
		}
		function showCalendar($options, $selected_date=NULL, $eventid='', $eventdate='', $cuid=''){
			if($selected_date!=NULL) {
				$today = getdate(strtotime($selected_date));
			} elseif(!empty($eventid)) {
				//$selectedEvent = ICalEvents::get_event($options['ics_file'], $eventid, $eventdate);
				//$pretoday = getdate($selectedEvent['StartTime']);
				//$today = getdate( mktime(0,0,0,$pretoday['mon'],1,$pretoday['year']) );
				$today = getdate( $eventdate );
			} else {
				$today = getdate();
			}
			
			$fixed_locales = preg_replace('/ +/','',$options['date_language']);
			$locales = explode(',',$fixed_locales);
			if(!setlocale(LC_ALL, $locales)) {
				//return "Locale Error";
				exit;
			}


			$calArray = icsCalDisplay::getCalendarArray($today, $options);

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
			$events = ICalEvents::get_events($icsFile, $calArray[0], end($calArray)+(24*3600)+1, NULL);
			
			if(is_array($events)) {
				foreach($events as $event) {
					if($options['cal_show_multiday']=='1') {
						$days = ceil( ($event['EndTime'] - $event['StartTime'])/(3600*24) );
					} else {
						$days = 1;
					}
					for($i=0;$i<$days;$i++) {
						$calEvents[date('Y-n-j',$event['StartTime']+($i*3600*24) )][] = $event;
					}
				}
			}
			
			$calContent = '<table class="ics-calendar-table" cellspacing="1" cellpadding="1" width="100%">';
			$calContent .= '<tr class="ics-calendar-days">'."\n";
			
			$calContentWeekdays = array();
			for($d=1; $d<=7; $d++) {
				$calContentWeekdays[] = strftime('%a',strtotime('2009-3-'.$d));
			}
			//$calContentWeekdays = array('Sun', 'Mon', 'Tue', 'Wed', 'Thur', 'Fri', 'Sat');
			
			$dayHolder = array_splice($calContentWeekdays,$options['cal_startday']);
			$calContentWeekdays = array_merge($dayHolder, $calContentWeekdays);
			
			$calContent .= '<td>' . implode('</td><td>',$calContentWeekdays) . '</td></tr>' . "\n";
			
			//foreach($calArray as $day){
			//	echo date('m-d-Y',$day)."<br>";
			//}
			// Display the first calendar row with correct positioning
			
			//Get how many complete weeks are in the actual month
			$fullWeeks = floor(count($calArray)/7);
			$lineWeeks = ($options['cal_shrink']=='1') ? ceil(count($calArray)/7) : 6;
			$x = 0;
			for ($i=0;$i<$lineWeeks;$i++){
				$calContent .= '<tr>';
				for ($j=0;$j<7;$j++){
					$currDate = getdate($calArray[$x]); $x++; #increase to the next item in the array.

					$calContent .= "<td>";
					//$calContent .= '<div id="ics-cell-'.$currDate['mon'].'-'.$currDate['mday'].'" class="ics-calendar-cell">';
					$calContent .= '<div class="';
						if($currDate['mon']==$today['mon']) $calContent .= 'date-holder'; else $calContent .= 'old-date-holder'; ##Current selected month, or outside the month.
						if($currDate['mday']==date('j',time()) && $currDate['year']==date('Y',time()) && $currDate['mon']==date('n',time())) $calContent .= ' ics-calendar-today'; #select the actual day.
						$calContent .= '">';
					$eventsKey = $currDate['year'].'-'.$currDate['mon'].'-'.$currDate['mday'];
					
/*------------>*/	$CAL_NUM_DISPLAY = $options['cal_events_per_day'];
					
					if(isset($calEvents) && array_key_exists($eventsKey,$calEvents)) {
						if(!function_exists('sortEvents')) {
							function sortEvents($a, $b) {
								if ($a['StartTime'] == $b['StartTime']) {
									return 0;
								}
								return ($a['StartTime'] < $b['StartTime']) ? -1 : 1;
							}
						}					
						usort($calEvents[$eventsKey], 'sortEvents');
						//print_r($calEvents[$eventsKey]);
						
						if(count($calEvents[$eventsKey])>$CAL_NUM_DISPLAY) {
							### MORE button if there are too many events
							$calContent .= '<a class="ics-more-button" href="javascript:void(0);" tag="ics-cell-'.$currDate['mon'].'-'.$currDate['mday'].'">&laquo; '.__('more','WPICSImporter').'</a>';
							### Get events and place them in an enlarged box.
							$calContent .= '<div id="ics-cell-'.$currDate['mon'].'-'.$currDate['mday'].'" class="ics-calendar-more-box">';
							$calContent .= '<div style="width:100%; text-align:right; "><span style="float:left; "><small><a href="javascript:void(0);" onclick="jQuery(\'#ics-cell-'.$currDate['mon'].'-'.$currDate['mday'].'\').hide()">&laquo; '.__('close','WPICSImporter').'</a></small></span> <strong>'.$currDate['mday'].'</strong></div>';
							foreach($calEvents[$eventsKey] as $event) {
								$eventUID = 'ics_'.md5($event['UID']);
								$calContent .= '<div class="ics-calendar-event" icstag="'.$eventUID.$eventsKey.$cuid.'">';
								$calContent .= ($options['cal_popups']=='mouse-over' && !empty($event['attach']) ? 
																		'<a href="'.$event['attach'].'" target="_blank">'.$event['Summary'].'</a>' : 
																		$event['Summary']);
								$calContent .= '</div>';
							}
							$calContent .= '</div>';
						}						
						$calContent .= '<strong>'.$currDate['mday'].'</strong></div>';
						$e = 0;
						//print '<pre>';
						//print_r($calEvents);
						foreach($calEvents[$eventsKey] as $key=>$event) {
							if(!isset($event['SkipBox'])) {
								$eventUID = 'ics_'.md5($event['UID']);
								$showBoxNow = ($eventid == $event['UID']) ? ' style="margin-top: 20px; display: block;"' : '';
								$calContent .= '<div class="ics-calendar-event-box" id="'.$eventUID.$eventsKey.$cuid.'"'.$showBoxNow.'>';
								
								$icsRequestURI = (!empty($_GET['realPath'])) ? base64_decode($_GET['realPath']) : $_SERVER['REQUEST_URI'];
								$icsRequestURI = preg_replace('/(\?|&)?(icsevent|icsdate)=([^?=&]*)/i','',$icsRequestURI);
									
								if($options['cal_event_download']==1) {
									$icsEventLink = ICSCALENDAR_URLPATH . 'ajax-load.php?';
									$icsEventLink .= 'downloadEvent='.$event['UID'].'';									
									$icsEventLink .= '&calendarID='.$event['calID'].'';
									$calContent .= '<div class="ics-calendar-permalink"><a href="'.$icsEventLink.'">'.__('Download','WPICSImporter').'</a></div>  ';
								}
								if($options['cal_permalinks']==1) {
									$icsPermalink = $icsRequestURI;
									$icsPermalink .= (preg_match('/\?/',$icsPermalink)) ? '&' : '?';
									//$icsPermalink .= 'icsevent='.$event['UID'].'';									
									//$icsPermalink .= '&icsdate='.$event['StartTime'].'';
									$icsPermalink .= 'ics-perm='.$event['UID'].'';									
									$calContent .= '<div class="ics-calendar-permalink"><a href="'.$icsPermalink.'">'.__('Permalink','WPICSImporter').'</a></div>';
								}
								$calContent .= '<div>'.__('Event:','WPICSImporter').' <strong>'. ($options['cal_popups']=='click' && !empty($event['attach']) ? 
																		'<a href="'.$event['attach'].'" target="_blank">'.$event['Summary'].'</a>' : 
																		$event['Summary']) .
												'</strong><br />';
								
								if (ICalEvents::is_all_day($event['StartTime'], $event['EndTime']) || (isset($options['hide_time']) && $options['hide_time']=='true'))
									 $formated_date = (ICalEvents::fdate($options['date_format'], $event['StartTime']));
								else 
									 $formated_date = (ICalEvents::format_date_range($event['StartTime'], $event['EndTime'], $event['Untimed'], $options['date_format'], $options['time_format']));
								$calContent .= __('When:','WPICSImporter').' ' . $formated_date . '<br />';
								
								if(!empty($event['Description'])) $calContent .= __('Description:','WPICSImporter').' ' . $event['Description'] . '<br />';
								if(!empty($event['Location'])) $calContent .= __('Location:','WPICSImporter').' ' . $event['Location'] . '<br />';
								
								$calContent .= '</div></div>';
							}
							$e++;
						}
						
						for($f=0; $f<$CAL_NUM_DISPLAY; $f++) {
							$fevent = $calEvents[$eventsKey][$f];
							if($fevent['Summary']!='') {
								$eventUID = 'ics_'.md5($fevent['UID']);
								$calContent .= '<div class="ics-calendar-event" icstag="'.$eventUID.$eventsKey.$cuid.'">';
								$calContent .= ($options['cal_popups']=='mouse-over' && !empty($fevent['attach']) ? 
																		'<a href="'.$fevent['attach'].'" target="_blank">'.$fevent['Summary'].'</a>' : 
																		$fevent['Summary']);
								$calContent .= '</div>';
							}
						}
					} elseif($x <= count($calArray)) $calContent .= $currDate['mday'] . '</div>';
						else $calContent .= '</div>';
					//$calContent .= '</div>';
					$calContent .= "</td>"."\n";
				}
				$calContent .= '</tr>'."\n";
			}
						
			$calContent .= '</table>';
			$calContent .= '<script type="text/javascript">
								jQuery("#ics-prev-button'.$cuid.'").attr("month","'.date('Y-m-d',mktime(0,0,0,$today['mon']-1,1,$today['year'])).'");
								jQuery("#ics-next-button'.$cuid.'").attr("month","'.date('Y-m-d',mktime(0,0,0,$today['mon']+1,1,$today['year'])).'");
								jQuery("#ics-calendar-header-text'.$cuid.'").html("' . strftime( "%B" , mktime(0,0,0,$today['mon'],1,$today['year']) ) . ' ' . $today['year'] .' ");
								';
			if($options['cal_popups']=='mouse-over') {
				$calContent .= '	jQuery().mousemove(function(e){
										if(e.pageX > (jQuery(window).width()/2) ) {
											jQuery(".ics-calendar-event-box").css("left",e.pageX + 5 - jQuery(".ics-calendar-event-box").width());
										} else {
											jQuery(".ics-calendar-event-box").css("left",e.pageX + 5);
										}
										jQuery(".ics-calendar-event-box").css("top",e.pageY + 5);
									});';
				$calContent .= '	jQuery("div.ics-calendar-event").hover(
										function () {
											jQuery("#" + jQuery(this).attr("icstag")).show();
										}, 
										function () {
											jQuery("#" + jQuery(this).attr("icstag")).hide();
										}
									);';
			} elseif($options['cal_popups']=='click') {
				$calContent .= '	jQuery("div.ics-calendar-event").click(
										function (e) {
											var $jObject = jQuery("#" + jQuery(this).attr("icstag"));
											var css = {};								
											css.marginTop = 20;
											if(jQuery(this).offset().left > (jQuery(window).width()/2) ) {
												css.marginLeft = -$jObject.width()
											} else {
												css.marginLeft = 0;
											}
											jQuery(".ics-calendar-event-box").hide();
											$jObject.css(css).show();
											e.stopPropagation();
										}
									);';
				$calContent .= '	jQuery(".ics-calendar-event-box").click(function(e) {
											e.stopPropagation();
										}
									);
									';
				$calContent .= '	jQuery(document).click(function(e){
										jQuery(".ics-calendar-event-box").hide();
									});';
			}
			$calContent .= '	jQuery("a.ics-more-button").click(function() { jQuery(".ics-calendar-more-box").hide(); jQuery("#"+jQuery(this).attr("tag")).show(); });';
								//jQuery(".ics-calendar-more-box").mouseout(function() { jQuery(this).hide(); });
								
			$calContent .= '</script>';
			$calContent .= '';
			
			return $calContent;
		}
		
		function eventBoxArray($array, $options, $uid) {
			$aEvents = array();
			foreach($array as $event) {
				$eventUID = 'ics_'.md5($event['UID'].time());
				$eventContent = '<div class="ics-calendar-event-box" id="'.$eventUID.$uid.'">';
				$eventContent .= __('Event:','WPICSImporter').' <strong>'.$event['Summary'].'</strong><br />';
				
				if (ICalEvents::is_all_day($event['StartTime'], $event['EndTime']) || (isset($options['hide_time']) && $options['hide_time']=='true'))
					 $formated_date = (date($options['date_format'], $event['StartTime']));
				else 
					 $formated_date = (ICalEvents::format_date_range($event['StartTime'], $event['EndTime'], $event['Untimed'], $options['date_format'], $options['time_format']));
				$eventContent .= __('When:','WPICSImporter').' ' . $formated_date . '<br />';
				
				if($event['Description']!='') $calContent .= __('Description:','WPICSImporter').' ' . $event['Description'];
				
				$eventContent .= '</div>';
				$eventContent .= '<div class="ics-calendar-event" icstag="'.$eventUID.$uid.'">';
				$eventContent .= $event['Summary'];
				$eventContent .= '</div>';
				$aEvents[] = $eventContent;
			}
			return $aEvents;
		}
		### FUNCTION THAT RETURNS ALL DAYS THAT WILL APPEAR ON A CALENDAR
		### This includes previous and next months days as well.
		function getCalendarArray($today, $options) {
			$calEvents = array();
			$buildDay = 1;
			
			$firstDayUnix = mktime(0,0,0,$today['mon'],1,$today['year']);
			$firstDay = getdate($firstDayUnix);
			$lastDayUnix = mktime(0,0,0,$today['mon']+1,0,$today['year']);
			$lastDay  = getdate($lastDayUnix);

			$calendarArray = array();
			
			$week_start_day = $firstDay['wday'] - $options['cal_startday'];
			if($week_start_day<0) {
				$week_start_day = $firstDay['wday'] + (7 - $options['cal_startday']);
			}
			
			for($x=$week_start_day-1;$x>=0;$x--) {
				array_push($calendarArray, (mktime(0,0,0,$today['mon'],-$x,$today['year'])));
			}
			for($x=$week_start_day;$x<=6;$x++) {
				array_push($calendarArray, (mktime(0,0,0,$today['mon'],$buildDay,$today['year'])));
				$buildDay++;
			}
			$fullWeeks = floor(($lastDay['mday']-$buildDay)/7);
			for ($i=0;$i<$fullWeeks;$i++){
				for ($j=0;$j<7;$j++){
					array_push($calendarArray, (mktime(0,0,0,$today['mon'],$buildDay,$today['year'])));
					$buildDay++;
				}
			}
			if ($buildDay <= $lastDay['mday']){
				for ($i=0; $i<7;$i++){
					if ($actday <= $lastDay['mday']){
						array_push($calendarArray, (mktime(0,0,0,$today['mon'],$buildDay,$today['year'])));
					} else {
						array_push($calendarArray, (mktime(0,0,0,$today['mon'],$buildDay,$today['year'])));
					}
					$buildDay++;					
				}
			}
			return $calendarArray;
		}
	}
}

?>
