<?php
# GeshiHighlight.php
# 
# By: E. Rogan Creswick (aka: Largos)
# largos@ciscavate.org
# ciscavate.org/wiki/
#
# Loosely based on SyntaxHighlight.php by Coffman, (www.wickle.com)
# Code arranged and packaged by Coffman (www.wickle.com) ;) 10-nov-2004
include_once('geshi/geshi.php');
global $lang;
class GeshiSyntaxSettings {                                                                               };
$wgGeshiSyntaxSettings = new GeshiSyntaxSettings;
$wgExtensionFunctions[] = "wfGeshiSyntaxExtension"; 
function wfGeshiSyntaxExtension() {

        global $wgParser;
        $langArray = array("actionscript","ada","apache","asm","asp","bash",
                           "caddcl","cadlisp","c","cpp","css","delphi",
                           "html4strict","java","javascript","lisp", "lua",
                           "nsis","oobas","pascal","perl","php-brief","php",
                           "python","qbasic","sql","vb","visualfoxpro","xml");

        foreach ( $langArray as $lang ){
             $wgParser->setHook( $lang,create_function( '$text', '$geshi = new GeSHi($text, ' . $lang . ', 
"extensions/geshi/geshi");
	     return $geshi->parse_code();'));
        }
/*Its better to implement the  highlight syntax parser 
on a separate function , but at the moment, setHook
only accepts one parameter to pass)...
function GeshirenderSyntax($text){
  echo "HOLA->".$lang;
  //echo "HOLA->".$text;
  //$lang="java";
  $geshi = new GeSHi($text, $lang, 'extensions/geshi/geshi');
  //echo $geshi->parse_code();
  return $geshi->parse_code();
}*/
}                                                            
?>