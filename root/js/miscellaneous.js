/***************************/
// to be written
/***************************/
 

$jq('input[value=[% c.user.roles %]]:radio').attr('checked', 'checked');

String.prototype.trim = function () {
    return this.replace(/^\s*/, "").replace(/\s*$/, "");
}
     

// Automatically generate table of contents in #documentation-with-toc divs
// use by the jquery table of contents plugin.  See resources/documentation/nomenclature for example.
$jq(document).ready(function(){ 
	$jq("#toc").tableOfContents(
				    $jq("#userguide-with-toc"),   // Scoped to div#documentation-with-toc
				    {
					startLevel: 2,    // H1 and up
					    depth:  4,    // H1 through H4
        			     }
				    );
       	   });

