 
  $jq(document).ready(function() {
  
   $jq(".switch-colorbox").live('click',function() {
    var mytitle = $jq(this).attr("class").split(" ");
    $jq("#"+mytitle[1]).trigger('click');
    return false;
  });

     $jq(".add-delete").live('click',function() {
	$jq(this).toggleClass( "ui-icon-circle-minus"); 
    });

    $jq(".feed").live('click',function() {
	var url=$jq(this).attr("rel");
	var div=$jq(this).parent().next("#widget-feed");
	div.filter(":hidden").empty().load(url);
	div.slideToggle('fast');
    });

    $jq("#nav-min-icon").addClass("ui-icon ui-icon-triangle-1-w");
    $jq(".tooltip").addClass("ui-icon ui-icon-lightbulb");
     openid.init('openid_identifier');
     $jq("#openid_identifier").focus();

    $jq(".sortable").sortable({
      handle: '.widget-header, #widget-footer',
      items:'li.widget',
      placeholder: 'placeholder ui-corner-all',
      connectWith: '.sortable',
      forcePlaceholderSize: true,
      update: updateLayout,
    });
    $jq("#widget-holder").children("#widget-header").disableSelection();

    $jq("div.columns span, div.columns div.ui-icon, div.columns ul li").live('click', function() {
      $jq("div.columns ul").toggle();
    });

// if you want columns to show on hover: problems when using input
//   $jq("div.columns").hover(function () {
//       $jq("div.columns ul").show();
//     }, function () {
//       $jq("div.columns ul").hide();
//     });


// TODO:get jquery icons working for toggle
//   $jq(".toggle").live('click',function() {
//               $jq(this).next().slideToggle("fast");
//               $jq(this).toggleClass("ui-icon-triangle-1-e");
//               $jq(this).toggleClass("ui-icon-triangle-1-s");
//               return false;
//         });

     $jq(".toggle").live('click',function() {
              $jq(this).toggleClass("active").next().slideToggle("fast");
              return false;
        });

  $jq("#searchForm dropdown li input").button();

    $jq("#nav-min").click(function() {
      var nav = $jq("#navigation");
      var w = nav.width();
      var msg = "open sidebar";
      if(w == 0){ w = '9.5em'; msg = "close sidebar"; }else { w = 0;}
      nav.animate({width: w, display: 'block'});
      nav.children("#title").children("div").toggle();
      $jq(this).attr("title", msg);
      $jq(this).children("#nav-min-icon").toggleClass("ui-icon-triangle-1-w").toggleClass("ui-icon-triangle-1-e");
    });

    $jq(".module-min").live('click', function() {
        var module = $jq("div#" + $jq(this).attr("wname") + "-content");
        module.next().slideToggle("fast");
        module.slideToggle("fast");
        $jq(this).parent().toggleClass("minimized");
        if ($jq(this).attr("show") != 1){
          $jq(this).attr("show", 1).attr("title", "maximize");
          $jq(this).removeClass("ui-icon-circle-triangle-s").removeClass("ui-icon-triangle-1-s");
          $jq(this).addClass("ui-icon-circle-triangle-e");
        }else{
          $jq(this).attr("show", 0).attr("title", "minimize");
          $jq(this).removeClass("ui-icon-circle-triangle-e");
          $jq(this).addClass("ui-icon-circle-triangle-s");
        }
      });


/*
  $jq("div.bench div.content").droppable({
      accept: ".results-paper div.result",
      hoverClass: 'placeholder ui-corner-all',
      drop: function(event, ui){
                ui.draggable.find(".bench-update").trigger('click');
            },
      
  });*/

  $jq(".tip-simple").hover(
        function () {
          if(!($jq(this).children("div").show().size())){
            var tip = $jq('<div class="tip ui-corner-all"><span class="ui-icon ui-icon-triangle-1-s"></span></div>');
            tip.prepend($jq(this).attr("tip")).appendTo($jq(this)).show();
          }
        }, 
        function () { $jq(this).children("div").hide(); }
      );

    $jq(".tooltip").live('mouseover',function() {
        $jq(this).cluetip({
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


 
