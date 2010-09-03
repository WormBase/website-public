 
  $(document).ready(function() {  

//       $(".toggle").addClass("ui-icon ui-icon-plus").show();
      $(".module-min").addClass("ui-icon ui-icon-triangle-1-s").attr("title", "minimize");;
      $(".module-close").addClass("ui-icon ui-icon-close").hide();
      $(".widget-container").children("footer").hide();
      $("#nav-min-icon").addClass("ui-icon ui-icon-triangle-1-w");

    $("#widget-holder").sortable({
      handle: 'header, footer',
      items:'li',
      update: function() { 
                //storing the order in session
                var order = $(this).sortable("toArray");
                var class = $(this).attr("class");
                var log_url = $(this).attr("log");
                var count = 1;
                for(i=0; i<order.length; i++) {
                  if ($("#nav-" + order[i]).attr("load") == 0){
                    $.get(log_url + "/" + order[i] + "/" + count++);
                  }
                }
                $.get(log_url + "/" + count);
              }
    });
    $("#widget-holder").children("header").disableSelection();

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
      $(this).children("#nav-min-icon").toggleClass("ui-icon-triangle-1-w").toggleClass("ui-icon-triangle-1-e");
    });

    $(".module-min").live('click', function() {
        var module = $("div#" + $(this).attr("class").split(" ")[1]);
        module.slideToggle("fast");
        module.next().slideToggle("fast");
        $(this).parent().toggleClass("minimized");
        if ($(this).attr("show") != 1){
          $(this).attr("show", 1).attr("title", "maximize");
          $(this).removeClass("ui-icon-circle-triangle-s").removeClass("ui-icon-triangle-1-s");
          $(this).addClass("ui-icon-circle-triangle-e");
        }else{
          $(this).attr("show", 0).attr("title", "minimize");
          $(this).removeClass("ui-icon-circle-triangle-e");
          $(this).addClass("ui-icon-circle-triangle-s");
        }
      });

      $(".widget-container").hover(
        function () {
          $(this).children("header").children(".ui-icon").show();
          if($(this).children("header").children("h3").children(".module-min").attr("show") != 1){
            $(this).children("footer").show();
          }
        }, 
        function () {
          $(this).children("header").children(".ui-icon").hide();
          $(this).children("footer").hide();
        }
      );

      $(".module-min").hover(
        function () {
          if ($(this).attr("show")!=1){ $(this).addClass("ui-icon-circle-triangle-s");
          }else{ $(this).addClass("ui-icon-circle-triangle-e");}
        }, 
        function () {
          $(this).removeClass("ui-icon-circle-triangle-s").removeClass("ui-icon-circle-triangle-e");
          if ($(this).attr("show")!=1){ $(this).addClass("ui-icon-triangle-1-s");
          }else{ $(this).addClass("ui-icon-triangle-1-e");}
        }
      );

      $(".module-close").hover(
        function () {
          $(this).addClass("ui-icon-circle-close");
        }, 
        function () {
          $(this).removeClass("ui-icon-circle-close").addClass("ui-icon-close");
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


 
