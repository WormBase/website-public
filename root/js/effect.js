 
  $(document).ready(function() {  

     openid.init('openid_identifier');
     $("#openid_identifier").focus();


    $("#widget-holder").sortable({
      handle: 'header, footer'
    });
    $("#widget-holder").disableSelection();

	 $(".toggle").live('click',function() {
		  //$(this).click(function(){
              $(this).toggleClass("active").next().slideToggle("fast");
              return false;
        });
      
	$(".tooltip").live('mouseover',function() {
	   // var employee_id = $(this).attr("id");
	    $(this).cluetip({
		activation: 'click',
		sticky: true, 
		cluetipClass: 'jtip',
		dropShadow: false, 
		closePosition: 'title',
		arrows: true, 
// 		height: '80px',
// 		width: '450px',
		hoverIntent: false,
		//ajaxSettings : {
	     //       type : "GET",
		//    data : "id=" + employee_id,
		//},
	      });
	});
  });


 
