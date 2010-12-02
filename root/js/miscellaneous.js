/***************************/
// to be written
/***************************/
$('input[value=[% c.user.roles %]]:radio').attr('checked', 'checked');

function validate_email(field,alerttxt)
{
 
  var apos=field.indexOf("@");
  var dotpos=field.lastIndexOf(".");
  if (apos<1||dotpos-apos<2)
    {alert(alerttxt);return false;}
  else {return true;}
   
} 