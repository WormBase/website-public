 
  $(document).ready(function() {  
// var layoutFocused = true;
//       $(".toggle").addClass("ui-icon-large ui-icon-plus").show();
//       addWidgetEffects();
      $("#nav-min-icon").addClass("ui-icon ui-icon-triangle-1-w");
    $(".tooltip").addClass("ui-icon ui-icon-lightbulb");
     openid.init('openid_identifier');
     $("#openid_identifier").focus();

    $(".sortable").sortable({
      handle: '#widget-header, #widget-footer',
      items:'li.widget',
      placeholder: 'placeholder ui-corner-all',
      connectWith: '.sortable',
      forcePlaceholderSize: true,
      update: updateLayout,
    });
    $("#widget-holder").children("#widget-header").disableSelection();

    $("div.columns span, div.columns div.ui-icon, div.columns ul li").live('click', function() {
      $("div.columns ul").toggle();
    });

// if you want columns to show on hover: problems when using input
//   $("div.columns").hover(function () {
//       $("div.columns ul").show();
//     }, function () {
//       $("div.columns ul").hide();
//     });


// TODO:get jquery icons working for toggle
//   $(".toggle").live('click',function() {
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
      var nav = $("#navigation");
      var w = nav.width();
      var msg = "open sidebar";
      if(w == 0){ w = '9.5em'; msg = "close sidebar"; }else { w = 0;}
      nav.animate({width: w, display: 'block'});
      $(this).attr("title", msg);
      $(this).children("#nav-min-icon").toggleClass("ui-icon-triangle-1-w").toggleClass("ui-icon-triangle-1-e");
    });

    $(".module-min").live('click', function() {
        var module = $("div#" + $(this).attr("wname") + "-content");
        module.next().slideToggle("fast");
        module.slideToggle("fast");
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



  $("div.bench div.content").droppable({
      accept: ".results-paper div.result",
      hoverClass: 'placeholder ui-corner-all',
      drop: function(event, ui){
                ui.draggable.find(".bench_update").trigger('click');
            },
      
  });

    $(".tooltip").live('mouseover',function() {
        $(this).cluetip({
        activation: 'click',
        sticky: true, 
        cluetipClass: 'jtip',
        dropShadow: false, 
        closePosition: 'title',
        arrows: true, 
//      height: '80px',
//      width: '450px',
        hoverIntent: false,
        //ajaxSettings : {
         //       type : "GET",
        //    data : "id=" + employee_id,
        //},
          });
    });
  });


 
