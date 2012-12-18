<?php
# To activate the extension, include it at the end from your LocalSettings.php at
# with: require_once("extensions/EmbedURL.php");
#
# Syntax: (2007-02-17)
# <embedurl>http://www.my-url.com/</embedurl>
# <embedurl>http://www.my-url.com/{width=640}{height=480}</embedurl>
#
$wgExtensionFunctions[] = "wfEmbedURL";
 
$wgExtensionCredits['parserhook'][] = array(
        'name' => 'EmbedURL',
        'author' => 'Unknown author',
        'url' => 'http://www.mediawiki.org/wiki/Extension:EmbedURL',
        'description' => '<tt>&lt;embedurl&gt;</tt> parser tag for embedding other websites into a wiki page'
);
 
function wfEmbedURL() {
   global $wgParser;
 
   $wgParser->setHook( "embedurl", "renderEmbedURL" );
}
 
# The callback function for converting the input text to HTML output
function renderEmbedURL( $input ) {
 
   # Building the code
 
   $pos = strpos($input, "{width=");
   if ($pos == false) {
     $url = $input;
   } else {
     $url = substr($input, 0, $pos);
     $width = substr($input, $pos+7);
     $pos1 = strpos($width, "}");
     if ($pos1 != false) {
       $width = substr($width, 0, $pos1);
     }
   }
   $pos = strpos($input, "{height=");
   if ($pos != false) {
     $height = substr($input, $pos+8);
     $pos1 = strpos($height, "}");
     if ($pos1 != false) {
       $height = substr($height, 0, $pos1);
     }
   }
 
   if ($url == false ) {
     $url = "http://www.mediawiki.org/wiki/Extension:EmbedURL";
   }
   if ($width == false ) {
     $width = "400";
   }
   if ($height == false ) {
     $height = "300";
   }
 
   $output = "<iframe src='$url' style='width:".$width."px;height:".$height."px;' scrolling='no' marginwidth='0' marginheight='0' 
frameborder='0'></iframe>";
 
   return $output;
}

