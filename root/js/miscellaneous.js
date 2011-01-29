/***************************/
// to be written
/***************************/
 

$jq('input[value=[% c.user.roles %]]:radio').attr('checked', 'checked');

String.prototype.trim = function () {
    return this.replace(/^\s*/, "").replace(/\s*$/, "");
}
 

function validate_fields(email,username, password, confirm_password){
	if( email.val() ==""){
		      alert("Please provide your email address."); email.focus();return false;
	} else if( validate_email(email.val(),"Not a valid email address!")==false) {
		      email.focus();return false;
	} else if( username.val() =="") {
		      alert("Please provide your username");username.focus(); return false;
	} else if(password) {
	    if( password.val() ==""){
		      alert("Please provide your password."); password.focus();return false;
	    } else if( password.val() != confirm_password.val()) {
			alert("The passwords do not match. Please enter again"); password.focus();return false;
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