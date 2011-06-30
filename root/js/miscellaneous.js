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

function validate_fields(email,username, password, confirm_password, wbemail){
	if( (email.val() =="") && (wbemail.val() == "")){
		      email.focus().addClass("ui-state-error");return false;
	} else if( email.val() && (validate_email(email.val(),"Not a valid email address!")==false)) {
		      email.focus().addClass("ui-state-error");return false;
	} else if( username.val() =="") {
		      username.focus().addClass("ui-state-error"); return false;
	} else if(password) {
	    if( password.val() ==""){
		      password.focus().addClass("ui-state-error");return false;
	    } else if( password.val() != confirm_password.val()) {
			alert("The passwords do not match. Please enter again"); password.focus().addClass("ui-state-error");return false;
	    }  
	} else {
	  return true;
	}
}

function validate_email(field,alerttxt)
{
 
  var apos=field.indexOf("@");
  var dotpos=field.lastIndexOf(".");
  if (apos<1||dotpos-apos<2)
    {alert(alerttxt);return false;}
  else {return true;}
   
} 