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

$wgExtensionFunctions[] = "wfExampleExtension";
#$wgExtensionFunctions[] = "wfExampleExten";
#$wgHooks['ParserBeforeStrip'][] = 'myhook';

#$wgHooks['ParserBeforeTidy'][] = 'wfExampleExten' ;



function wfExampleExtension() {
    global $wgParser;
    # register the extension with the WikiText parser
    # the first parameter is the name of the new tag.
    # In this case it defines the tag <example> ... </example>
    # the second parameter is the callback function for
    # processing the text between the tags

    $wgParser->setHook( "example", "renderExample" );
}

function myhook ( &$parser , &$text ) {

      $text .= "and then some"; 
#     $text .= $_SERVER['REQUEST_URI'];
 #    $text .= "<br />" . $_SERVER['PHP_SELF'];
  #   $text .= "<br />" . $_SERVER['QUERY_STRING'];
}

# The callback function for converting the input text to HTML output
function renderExample( $input, $argv ) {
    # $argv is an array containing any arguments passed to the
    # extension like <example argument="foo" bar>..
    # Put this on the sandbox page:  (works in MediaWiki 1.5.5)
    #   <example argument="foo" argument2="bar">Testing text **example** in between the new tags</example>

#      $url = 'http://username:password@hostname/path?arg=value#anchor';
    
    #$output = "Text passed into example extension: <br/>$input";
    #$output .= " <br/> and the value for the arg 'argument' is" .$argv[argument];
    #$output .= " <br/> and the value for the arg 'argument2' is: ".$argv[argument2];

     $output = $_SERVER['REQUEST_URI'];
     $output .= "<br />" . $_SERVER['PHP_SELF'];
     $output .= "<br />" . $_SERVER['QUERY_STRING'];
 #   $output .= (parse_url($url));
#print_r(parse_url($url));
    return $output;
}


#function get_query_edited_url($url, $arg, $val) {
#$parsed_url = parse_url($url);
#parse_str($parsed_url['query'],$url_query);
#$url_query[$arg] = $val;
#   
#$parsed_url['query'] = http_implode($url_query);
#$url = glue_url($parsed_url);
#return $url;
#}


?>