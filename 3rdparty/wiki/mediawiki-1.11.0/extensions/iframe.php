<?php
$wgExtensionFunctions[] = "iframeS";

function iframeS(){
	global $wgParser ;
	$wgParser->setHook ( "iframe" , 'iframeR' ) ;
}

function iframeR( $data ){
	$param = array();
	$info = explode("\n", $data);
	if(is_array($info)){
		foreach($info as $lin){
			$line = explode("=",$lin, 2);
			if(count($line)==2){
				$param[trim($line[0])] = trim($line[1]);
			}
		}
	}
	$width = (isset($param["width"]))? $param["width"] : 200;
	$height = (isset($param["height"]))? $param["height"] : 200;
	$url = (isset($param["url"]))? $param["url"] : "";
	$url = "http://". str_replace("http://", "", $url);
	$name = (isset($param["name"]))? $param["name"] : "";
//here you may add some other variables, but be very very careful!

	$script = ""; $onload ="";
// if you do not want autoresize script, just remove following if statement
if(strtoupper($height)=="ADJUST"){
	$onload = "onload='adjustHeight(this)'";
	$script = "<script>
	function adjustHeight(obj){
		var doc = window.frames[obj.name].document;
		obj.style.height = (doc.body.offsetHeight+15)+'px';
		doc.body.style.borderWidth = '0px';
	}
	</script>
	";
	$height=400;
       }
       if (empty($iFrameCount)) //iFrameCount is never really used??? 
         $iFrameCount = 0;
	$ret  = "$script<"."iframe $onload id='$name$iFrameCount' frameborder='0' name='$name' "; 
//remove the space between < and iframe
	$ret .= "width='$width' height='$height' src='$url' style='border:solid 0px; 
margin:none;'></iframe >" ;
	return $ret ;
}
?>
