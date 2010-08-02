 
  $(document).ready(function() {  
    
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

   //     // Tooltips
   //     $("a[title]").tooltip({
   //
   //  // use div.tooltip as our tooltip
   //  //  tip: '.tooltip',
   //
   //  // use the fade effect instead of the default
   //  effect: 'fade',
   //
   //  // make fadeOutSpeed similar to the browser's default
   //  fadeOutSpeed: 100,
   //
   //  // the time before the tooltip is shown
   //  predelay: 400,
   //
   //  // tweak the position
   //   position: "bottom right",
   //   offset: [-50, -80]
   //  });

 
