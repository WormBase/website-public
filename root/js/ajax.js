 $jq(document).ready(function() {



// Load wiki content into a page or widget by binding to a div.
function loadWikiContentDynamically(widget_name){   
    alert(widget_name);
    $jq('#'+widget_name+'-content > .wiki-content').each(function() {
	    //'#' + widget_name +'-content' + '.wiki-content').each(function() {
	    var title = $jq(this).attr('title');
	    alert("widget name is " + widget_name);
	    alert(title);
	    alert('what');
    // JSONP via the Mediawiki API
    // $jq.getJSON("http://wiki.wormbase.org/api.php?action=query&prop=revisions&titles=Updating_The_Development_Server&rvprop=content&format=json&callback=?",

    // XML (formatted) via the Mediawiki API
    // $jq.getJSON("http://wiki.wormbase.org/api.php?action=query&prop=revisions&titles=Updating_The_Development_Server&rvprop=content&format=xmlfm&callback=?",

    // HTML via the Mediawiki API
    //        $jq.getJSON("http://wiki.wormbase.org/api.php?action=parse&page=Updating_The_Development_Server&callback=?",

    // JSONP directly
    //$jq.getJSON("http://wiki.wormbase.org/index.php/Updating_The_Development_Server?callback=?",
    
    // HTML via YQL via the Mediawiki API, selecting the content we want by xpath.       
	    $jq.getJSON("http://query.yahooapis.com/v1/public/yql?"
			+"q=select%20*%20from%20html%20where%20url%3D%22"
			+"http%3A%2F%2Fwiki.wormbase.org%2Findex.php%2F"
			+title
			+"%22%20and%20xpath%3D%22%2F%2Fdiv%5B%40id%3D'globalWrapper'%5D%22&callback=?",
			function(data){			
			    if(data.results[0]){
				// var data = filterData(data.results[0]);
				var data = data.results[0];
				alert(data);
				$jq(this).html(data).focus().effect("highlight",{},1000);
				return false;
			    } else {			    
				var errormsg = '<p>Error: could not load the page at all.</p>';
				$jq(this).
				    html(errormsg).
				    focus().
				    effect('highlight',{color:'#c00'},1000);
			    }
			}
			);
	});
}



//	 var container = $jq('div.wiki-content'); 
	//container.html('<h1>insert</h1>');
	//container.attr('tabIndex','-1');
// Bind a click event to all wiki-help links
$jq('.wiki-help').live('click',function(){
	var href      = $jq(this).attr('href');		
	var container = href;
	container.replace(':','');  // can't use these as selectors

	// Insert a div that I can load the content into.
	$jq(this).after('<div class="wiki-help-container" id="'+container+'"></div>');
	loadWikiContent(href,container);
	return false;
    });



// Load MediaWiki content into our site via YQL and xpath
// when the widget loads OR on click.
// Requires:
// A template page with the following markup:
// <script> loadWikiContent("Title_of_the_Wiki_Page"); </script>
// You can have more than one of these calls in a widget.
// To make this generic:
//    1. Change the container name to something more meaningful
//    2. Change the URL constructor to be generic (currently wiki specific)
//          perhaps by specifying the full URL in template
//    3. Update/remove the xpath selector.
function loadWikiContent(title,container){   
    var target = $jq('#'+container);
    // JSONP via the Mediawiki API
    // $jq.getJSON("http://wiki.wormbase.org/api.php?action=query&prop=revisions&titles=Updating_The_Development_Server&rvprop=content&format=json&callback=?",

    // XML (formatted) via the Mediawiki API
    // $jq.getJSON("http://wiki.wormbase.org/api.php?action=query&prop=revisions&titles=Updating_The_Development_Server&rvprop=content&format=xmlfm&callback=?",

    // HTML via the Mediawiki API
    //        $jq.getJSON("http://wiki.wormbase.org/api.php?action=parse&page=Updating_The_Development_Server&callback=?",

    // JSONP directly
    //$jq.getJSON("http://wiki.wormbase.org/index.php/Updating_The_Development_Server?callback=?",
    
    // HTML via YQL via the Mediawiki API, selecting the content we want by xpath.       
    $jq.getJSON("http://query.yahooapis.com/v1/public/yql?"
		+"q=select%20*%20from%20html%20where%20url%3D%22"
		+"http%3A%2F%2Fwiki.wormbase.org%2Findex.php%2F"
		+title
		+"%22%20and%20xpath%3D%22%2F%2Fdiv%5B%40id%3D'globalWrapper'%5D%22&callback=?",
		function(data){			
		    if(data.results[0]){
			// var data = filterData(data.results[0]);
			var data = data.results[0];
			$jq(target).html(data).focus().effect("highlight",{},1000);
			alert(data);
			return false;
		    } else {
			// Couldn't fetch or no content?
    
			var errormsg = '<p>Error: unable to fetch content from the wiki.</p>';
			$jq(target).
			    html(errormsg).
			    focus().
			    effect('highlight',{color:'#c00'},1000);
		    }
		}
		)
	}



