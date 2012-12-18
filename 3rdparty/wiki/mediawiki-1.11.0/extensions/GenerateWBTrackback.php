<?php
# Example WikiMedia extension
# with WikiMedia's extension mechanism it is possible to define
# new tags of the form
# <TAGNAME> some text </TAGNAME>
# the function registered by the extension gets the text between the
# tags as input and can transform it into arbitrary HTML code.
# Note: The output is not interpreted as WikiText but directly
#       included in the HTML output. So Wiki markup is not supported.
# To activate the extension, include it from your LocalSettings.php
# with: include("extensions/YourExtensionName.php");

$wgExtensionFunctions[] = "wfGenerateWBTrackback";

#<WBTrackback page={{PAGENAME}}>
#</WBTrackback>

function wfGenerateWBTrackback() {
    global $wgParser;
    # register the extension with the WikiText parser
    # the first parameter is the name of the new tag.
    # In this case it defines the tag <example> ... </example>
    # the second parameter is the callback function for
    # processing the text between the tags

    $wgParser->setHook( "WBTrackback", "renderWBTrackback" );
}

function renderWBTrackback( $input, $argv ) {
    global $wgOut;

    # Wiki-fy the page name
    $page = $wgOut->parse($argv[page],false);

    # Split into object and class
    list($preface,$class,$name) = split(':',$page);

    # Only add the stub for new WB pages....
    if ($preface == 'WB' && $class && $name) {
        # It is a pain that it must be done this way. Carriage return not respect by wgOUt
         $url     = "http://www.wormbase.org/db/get?name=$name;class=$class";
         $return = '<div style="border:1px solid gray;padding:5px"><div style="background-color:#CCFFFF;border:1px solid gray;font-size:16px;padding:10px;text-align:center">';
         $return .= $wgOut->parse("The comments on this page refer to WormBase $class " . "[$url $name]",false);
         $return .= '</div>';
         $return .= $wgOut->parse("==Resources==",false);
         $return .= $wgOut->parse("[$url WormBase $class Report for $name]" . "<br />",false);
         $return .= $wgOut->parse("Browse WormBase class: " . "[http://www.wormbase.org/db/searches/class_query?class=$class $class]" . "<br />",false); 
         $return .= $wgOut->parse("Search [http://www.google.com/search?rls=en&q=site:www.wormbase.org+$name&ie=UTF-8&oe=UTF-8 WormBase via Google] or [http://www.google.com/search?rls=en&q=$name&ie=UTF-8&oe=UTF-8 All of Google] for [$url $name]" . "<br />",false);
         $return .= $wgOut->parse("[[Category:$class]]<br />",false);
         $return .= 'Note: Please remember to include your contact details!<br /><br />';
         $return .= '<i>Note: Any text entered here is publically viewable and editable and should be treated as personal communication.</i><br />';

         $return .= '<i>To automatically display this reference box, include the following entry at the top of your page:</i><pre>{{wormbase}}</pre></div>';
         return $return;

#         $return = '<div style="background-color:#CCFFFF;border:1px solid gray;font-size:16px;padding:10px;text-align:center">' 
#             . "The comments on this page refer to WormBase $class " . "[$url $name]</div>";
#         $return .= "\n==Resources==";
#         $return .= "[$url $class Report for $name]" . "<br />";
#         $return .= "Browse WormBase class: " . "[http://www.wormbase.org/db/searches/class_query?class=$class $class]" . "<br />"; 
#         $return .= "Search [http://www.google.com/search?rls=en&q=site:www.wormbase.org+$name&ie=UTF-8&oe=UTF-8 WormBase via Google] or [http://www.google.com/search?rls=en&q=unc-26&ie=UTF-8&oe=UTF-8 All of Google] for [$url $name]" . "<br />";
#         $return .- '----';
#         return $wgOut->parse($return,false);
    } else {
     $ns = $wgOut->parse('{{NAMESPACE}}',false); 
     if ($ns) {
       $target = "$ns:$page";
     } else {
       $target = $page;
     }
#    return $wgOut->parse("No content exists yet for $page.  Please help the WormBase community by [http://www.wormbase.org/wiki/index.php?title=$target&action=edit editing this document]",false);
}
}
?>