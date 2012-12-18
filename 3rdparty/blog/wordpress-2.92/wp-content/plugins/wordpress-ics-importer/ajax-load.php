<?php
require_once("../../../wp-config.php");

if(isset($_GET['showMonth'])) {
	$options = get_option(ADMIN_OPTIONS_NAME); //$_GET;
	//$icsOptions = WPICSImporter::getAdminOptions();
	$options['ics_file_default'] = $_GET['calendar'];
	echo icsCalDisplay::showCalendar($options, $_GET['showMonth'], '', '', $_GET['cuid']);
	exit;
} 

if(isset($_GET['widgetPage'])) {
	$widget = WPICSImporter::getWidgetOptions();				
	$options = WPICSImporter::getAdminOptions();
	$options = WPICSImporter::prepareWidgetOptions($widget, $options);
	$options['events_page'] = (int)$_GET['widgetPage'];
	$output = ICalEvents::custom_display_events($options, true);
	echo $output['output'];
	if($output['count'] < $options['event_limit']) {
		echo '<script>jQuery("#ics-calendar-widget-next").hide();</script>';
	}
	exit;
}

if(isset($_GET['eventsPage']) && isset($_GET['eventsStart']) && isset($_GET['eventsEnd']) && isset($_GET['eventsFile'])) {
	$icsOptions = WPICSImporter::getAdminOptions();
	$gmt_start = $_GET['eventsStart'];
	$gmt_end = $_GET['eventsEnd'];
	if($icsOptions['limit_type']=='days') {
		$gmt_start += (int)$icsOptions['event_limit']*24*3600*(int)$_GET['eventsPage'];
		$gmt_end += (int)$icsOptions['event_limit']*24*3600*(int)$_GET['eventsPage'];
		$icsOptions['event_limit'] = 0;
		$start = 0;
	} else {
		$gmt_end = NULL;
		$start = $icsOptions['event_limit'] * ((int)$_GET['eventsPage']);
		$icsOptions['event_limit'] = $icsOptions['event_limit'] * ((int)$_GET['eventsPage']+1);
	}
	$output = ICalEvents::display_events(unserialize(base64_decode($_GET['eventsFile'])), $gmt_start, $gmt_end, $icsOptions['event_limit'], $start, $_GET['uuid']);
	echo $output;
	exit;
}

if(isset($_GET['downloadEvent'])) {
	$options = get_option(ADMIN_OPTIONS_NAME);
	$calendars = unserialize($options['ics_files']);
	
	$events = ICalEvents::get_event($calendars[$_GET['calendarID']], $_GET['downloadEvent']);
	header("Content-Type: text/Calendar");
	header("Content-Disposition: inline; filename=calendar-event.ics");
	echo "BEGIN:VCALENDAR\n";
	echo "PRODID:ICS Calendar for Wordpress (fullimpact.net)\n";
	foreach($events as $event) {
		echo "BEGIN:VEVENT\n";
		echo utf8_decode(implode("\n",$event['raw']))."\n";
	}
	echo "END:VCALENDAR\n";
	exit;
}

?>