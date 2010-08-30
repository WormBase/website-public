 
  $(document).ready(function() {  

    $("#widget-holder").sortable({
      handle: 'header, footer',
      items:'li'
    });

// TODO:get jquery icons working for toggle
// 	 $(".toggle").live('click',function() {
//               $(this).next().slideToggle("fast");
//               $(this).toggleClass("ui-icon-triangle-1-e");
//               $(this).toggleClass("ui-icon-triangle-1-s");
//               return false;
//         });

     $(".toggle").live('click',function() {
              $(this).toggleClass("active").next().slideToggle("fast");
              return false;
        });

    $("#nav-min").click(function() {
      $("#navigation").animate({width: 'toggle'});
      $(this).children("#nav-min-icon").toggleClass("ui-icon-triangle-1-w");
      $(this).children("#nav-min-icon").toggleClass("ui-icon-triangle-1-e");
    });

    $(".module-min").live('click', function() {
        var mytitle = "#" + $(this).attr("class").split(" ")[1];
        $(mytitle).slideToggle("fast");
        $(mytitle).next().slideToggle("fast");
        $(this).parent().toggleClass("minimized");
        if ($(this).attr("show") == 0){
          $(this).attr("show", 1);
          $(this).removeClass("ui-icon-circle-triangle-s");
          $(this).removeClass("ui-icon-triangle-1-s");
          $(this).addClass("ui-icon-circle-triangle-e");
        }else{
          $(this).attr("show", 0);
          $(this).removeClass("ui-icon-circle-triangle-e");
          $(this).addClass("ui-icon-circle-triangle-s");
        }
      });

//       $(".toggle").addClass("ui-icon ui-icon-plus").show();
      $(".module-min").addClass("ui-icon ui-icon-triangle-1-s");
      $(".module-close").addClass("ui-icon ui-icon-close").hide();
      $(".widget-container").children("footer").hide();
      $("#nav-min-icon").addClass("ui-icon ui-icon-triangle-1-w");

      $(".widget-container").hover(
        function () {
          $(this).children("header").children(".module-close").show();
          if($(this).children("header").children("h3").children(".module-min").attr("show") == 0){
            $(this).children("footer").show();
          }
        }, 
        function () {
          $(this).children("header").children(".module-close").hide();
          $(this).children("footer").hide();
        }
      );

      $(".module-min").hover(
        function () {
          if ($(this).attr("show")==0){ $(this).addClass("ui-icon-circle-triangle-s");
          }else{ $(this).addClass("ui-icon-circle-triangle-e");}
        }, 
        function () {
          $(this).removeClass("ui-icon-circle-triangle-s");
          $(this).removeClass("ui-icon-circle-triangle-e");
          if ($(this).attr("show")==0){ $(this).addClass("ui-icon-triangle-1-s");
          }else{ $(this).addClass("ui-icon-triangle-1-e");}
        }
      );

      $(".module-close").hover(
        function () {
          $(this).addClass("ui-icon-circle-close");
        }, 
        function () {
          $(this).removeClass("ui-icon-circle-close");
          $(this).addClass("ui-icon-close");
        }
      );
   
	$(".tooltip").live('mouseover',function() {
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


 
