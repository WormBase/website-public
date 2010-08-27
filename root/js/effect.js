 
  $(document).ready(function() {  

    $("#widget-holder").sortable({
      handle: 'header, footer'
    });
    $("#widget-holder").disableSelection();

    $(".widget-container").addClass('ui-corner-all');
//     $("#navigaion").children("li").addClass('ui-corner-all');

	 $(".toggle").live('click',function() {
              $(this).toggleClass("active").next().slideToggle("fast");
              return false;
        });

    $("#nav-min").click(function() {
      $("#navigation").animate({width: 'toggle'});
      $(this).children("#nav-min-icon").toggleClass("nav-min-open");
      $(this).children("#nav-min-icon").toggleClass("nav-min-close");
    });

 $(".module-min").live('click', function() {
    var mytitle = "#" + $(this).attr("class").split(" ")[1];
    $(mytitle).slideToggle("fast");
    $(mytitle).next().slideToggle("fast");
    if ($(this).attr("show") == 0){
      $(this).attr("show", 1);
      $(this).removeClass("ui-icon ui-icon-minus");
      $(this).addClass("ui-icon ui-icon-plus");
    }else{
      $(this).attr("show", 0);
      $(this).removeClass("ui-icon ui-icon-plus");
      $(this).addClass("ui-icon ui-icon-minus");
    }
  });

 $(".module-min").addClass("ui-icon ui-icon-minus");
 $(".module-close").addClass("ui-icon ui-icon-close");
 $("#nav-min-icon").addClass("nav-min-close");

 $(".module-min").hover(
  function () {
    if ($(this).attr("show")==0){ $(this).addClass("ui-icon ui-icon-circle-minus");
    }else{ $(this).addClass("ui-icon ui-icon-circle-plus");}
  }, 
  function () {
    $(this).removeClass("ui-icon ui-icon-circle-minus");
    $(this).removeClass("ui-icon ui-icon-circle-plus");
    if ($(this).attr("show")==0){ $(this).addClass("ui-icon ui-icon-minus");
    }else{ $(this).addClass("ui-icon ui-icon-plus");}
  }
);

 $(".module-close").hover(
  function () {
    $(this).addClass("ui-icon ui-icon-circle-close");
  }, 
  function () {
    $(this).removeClass("ui-icon ui-icon-circle-close");
    $(this).addClass("ui-icon ui-icon-close");
  }
);
   
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


 
