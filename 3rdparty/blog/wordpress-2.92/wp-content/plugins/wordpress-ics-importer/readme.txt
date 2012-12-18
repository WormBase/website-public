=== ICS Calendar ===
Contributors: Daniel Olfelt
Donate link: https://www.paypal.com/cgi-bin/webscr?cmd=_s-xclick&hosted_button_id=1592264
Tags: calendar, events, ics, ical, icalendar, google, ajax, multi
Requires at least: 2.5
Tested up to: 2.7.1
Stable tag: 1.6.8

Display upcoming events from a shared Google, Outlook, iCal or other ICS calendar.

== Description ==

It has been awhile since I updated this plugin, so I thought I would give you a new version with some big new features requested by users. Enjoy!

Fetch and display events from your Google, Outlook or iCal calendar (or any other .ics file) in your blog. This plugin now support Multiple ICS Files!

This plugin provides a graphical interface for adding and customizing the format of how calendar events are displayed on your site. It also includes a widget for displaying events in the sidebar. There is also an ajax calendar that you can place on your blog, which uses AJAX.

Features Include:

* Event list and calendar views
* Permalinks to individual events
* Ajax browsing of calendar and events list
* Sidebar widget showing event list
* Show only current events
* Show events between certain dates
* Show X number of events, or events happening in X number of days
* Display multiple lists from multiple calendars
* Combine multiple calendars into one list or calendar view
* Date language support
* Custom date and time formatting
* Privacy mode to show times but not event information
* Can change week start day
* Cache calendar file to improve server performance

See our [other plugins](http://wordpress.org/extend/plugins/profile/dolfelt).

Feel free to give me suggestions for new [features](http://www.fullimpact.net/ics-calendar.php) or [donate](https://www.paypal.com/cgi-bin/webscr?cmd=_s-xclick&hosted_button_id=1592264) to help keep this project going strong!

== Installation ==

1. Upload 'wordpress-ics-importer' folder to your plugins folder, usually `wp-content/plugins`.
2. Activate the plugin on the Plugins screen.
3. Place the following on a page (not post):
		`[show-ics-events] or [show-ics-events=num_events] or [show-ics-events cal=ics_num,ics_num] (for events list) 
		 [show-ics-calendar] or [show-ics-calendar cal=ics_num,ics_num] (for new calendar)`

4. You can also use the widget in your sidebar.

== Screenshots ==

1. The admin section is clean and intuitive.
2. The calendar uses AJAX for loading.

== Version History ==
Version 1.6.8

* Added AJAX 'Next' and 'Previous' buttons to allow browsing event lists
* Permalinks now link to an individual page with a link back to the calendar
* Several Bug fixes suggested by users

Version 1.6.0

* Bug Fix: Parser did not allow for multiple exceptions to repeating events
* Added option to download events into Outlook, iCal, etc.
* Code cleanup to improve stability and performance

Version 1.5.8

* Added Next / Previous buttons to the widget to allow you to browse events in the future
* Several other minor fixes

Version 1.5.5

* Fixed "Current Events" bug created in last release
* Small bug in sidebar widget

Version 1.5.4

* Multi-day events bug fixed
* Sidebar HTML bug fixed
* Several minor text changes in the admin
* Improved event parsing selection (related to multiday events)

Version 1.5.2

* Extended Multi-Calendar support
* Can now select multiple calendars inline
* Added more language support

Version 1.5.0

* Multi-Calendar (ICS) Support!
* Allows you to combine multiple ICS files, or display them seperately
* Limit events to number of days
* Extended support for custom event list
* Fixed events issue regarding daylight savings
* Fixed display of some all-day events
* Display of "Today" was based on server time
* Fix for widget and calendar language support
* Numerous other bug fixes and code cleanups

Version 1.3.6

* FULL SUPPORT for timezones within Wordpress in ICS Calendar
* Fix for GMT dates where server is in different timezone
* Shows dates outside of month in gray days
* Added support for attaching links to events.
* Can now specify a separate CSS file that replaces the default CSS
* Several small security fixes

Version 1.3.4

* Update popups to show correctly with repeating events
* Language support for the calendar improved
* Option to shrink calendar based on number of weeks
* Fixed bugs in the display of all day events
* Showing current events between two dates now works
* Fixed yearly recurrence to account for leap year
* Fixed last day of the calendar month bug.

Version 1.3.0

* Yearly recurrence now works correctly.
* Added option to display multiday events on multiple days of the calendar.
* Added option to change number of events displayed within a calendar cell.

Version 1.2.12

* Extended support to include Microsoft Office ICS files.
* Added support for Timezones due to popular demand. This is still beta. Please contact me with issues.

Version 1.2.10

* Minor bug fixing.

Version 1.2.9

* Fixed array error caused by unique repeating events.

Version 1.2.8

* Fixed unique repeating events.
* Fixed deletions of a single occurence of a repeating event.
* Fixed bug where events on the last day of the month do not appear.

Version 1.2.6

* Added 'Privacy Mode' to hide the name of your events.
* Added Location to the calendar popups.
* Fixed the popups from going off the edge of the page.

Version 1.2.5

* Fixed a bug where all day events on Dec. 31 were messing up (thanks randy!)
* Minor improvements for WP 2.7
* Changed layout slightly to fit with WP 2.7 (Removed Tabs)

Version 1.2.4

* Added permalinks function for showing a certain event bubble with direct link.
* Increased security by not passing AJAX variables through GET command. It is all kept internal.
* Language support the dates in the calendar as well as weekday names in the calendar.

Version 1.2.2

* Added feature to select starting day of week.
* Added function to allow popups to be shown onclick.

Version 1.2.1

* Fixed bug in locale settings. Locales now can be set.
* Added listing of supported locales for Linux systems.

Version 1.2

* Fixed `unterminated string literal` error. Next / Prev Month buttons now work. (Improved: variables now kept internal)
* Fixed display of multi-day events displaying one extra day.
* Added support for `strftime`. Current support for `date` remains.
* Added multi-language support for dates. Change using locales.
* Minor formatting fixes.

Version 1.1.8

* Fixed bug when using `""` inside custom format.
* Added custom format to the sidebar widget.
* Improved support for XHTML formatting.
* Now you can select number of events using `[show-ics-events=num_events]`.

Version 1.1.4

* Fixed repeat events bug and IE7 calendar overflow bug.
* Fixed bug where events always show at top of post.
* When no events exists, it now displays "No Events."
* Some internal code changes as well as code cleanup.

Version 1.1

* Calendar added employing AJAX and jQuery.
* Inserting Events and Calendar has changed. Now [show-ics-event/calendar] in post rather than custom field.
* Admin interface tabs added using jQuery Tabs 3.
* New admin interface feeling to match well with 2.3 and the new 2.5 theme.

Version 1.0

* This was the first version available.
* Added a GUI to the ical-events plugin.
* Featured simple custom formatting.
* Sidebar widget that could display events.

== Frequently Asked Questions ==

= There is a feature that I want... =

If you would like a new feature, or something doesn't work the way it should, do not hesitate to [contact me](http://www.fullimpact.net/contact.php) or [suggest a new feature](http://www.fullimpact.net/ics-calendar.php).

= I have a URL that starts with WebCal =

If you have a URL that starts with `webcal`, then all you have to do is change the `webcal://` to `http://` and that should work.

= How often is the calendar checked for new events? =

Every 24 hours. Currently this can only be changed through the source code. You can change this using the `ICAL_EVENTS_CACHE_TTL` (time to live) near the top of the ics-functions.php file to the desired number of seconds in between checks. For example, to load events every day, use the following:
`define('ICAL_EVENTS_CACHE_TTL', 3600);`

Loading calendars too frequently can get your server banned, so use your best judgment when setting this value.

= Why aren't my events showing up correctly? =

This plugin makes an attempt to support as many event definitions that follow the ICS specification (RFC 2445) as possible. However, there may be bugs in how the plugin interprets the parsed data.

If an event is showing up correctly in your calendar application (iCal, Google Calendar) but not on your blog, please contact me: http://www.fullimpact.net/contact.php . In most cases I will
ask that you send me your ICS file so that I can look into it further.

= Where can I find ICS files? =

There are many ICS sources, such as:

* [Apple's iCal library](http://www.apple.com/ical/library/)
* [iCalShare](http://www.icalshare.com/)
* [Google Calendar](http://calendar.google.com/)
* [Outlook](http://www.microsoft.com/)

= My server does not support `fopen` on URLs. Can I still use this plugin? =

Yes, this plugin supports usage of cURL via WordPress' `wp_remote_fopen` function.