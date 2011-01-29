 
  $jq(document).ready(function() {
    
    
   $jq('#operator').live('click',function()  
    { 
      if($jq('#operator').attr("rel")) {
	 $jq.post("/rest/livechat?open=1",function() {
		window.location.href="/tools/operator";
	  });
      }else {
	  if($jq("#operator-box").size()==0) {  
		  $jq('#operator-box-wrap').html('<div id="operator-box"  class="ui-corner-all" ></div>');
		  ajaxGet($jq("#operator-box"), "/rest/livechat");
		  $jq("#operator-box").draggable();
	   } 
      }
    });  

  $jq('#operator-box-close').live('click',function()  
    {  

      $jq.post("/rest/livechat",function() {
	  $jq('#operator-box').remove();
      });
         
    }); 
    
  

   var nameBox = $jq("#comment-name"),
      nameBoxDefault = "name",
      contentBox = $jq("#comment-content"),
      contentBoxDefault = "enter your comment here"

 
  //show/hide default text if needed
  nameBox.live('focus',function() {
    if($jq(this).val().trim()== nameBoxDefault) $jq(this).attr("value", "");
  });
  nameBox.live('blur',function() {
    if($jq(this).val().trim() == "") $jq(this).attr("value",nameBoxDefault);
  });
  
  contentBox.live('focus',function() {
    if($jq(this).val().trim() == contentBoxDefault) $jq(this).attr("value", "");
  });
  contentBox.live('blur',function() {
    if($jq(this).val().trim() == "") $jq(this).attr("value",contentBoxDefault);
  });
  

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
      placeholder: 'placeholder',
      connectWith: '.sortable',
      opacity: 0.6,
      forcePlaceholderSize: true,
      update: function(event, ui) { updateLayout(); },
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

  $jq(".tip-simple").live('mouseover', function(){
    if(!($jq(this).children("div").show().size())){
      var tip = $jq('<div class="tip ui-corner-all" style="display:block"><span class="ui-icon ui-icon-triangle-1-s"></span></div>');
      tip.prepend($jq(this).attr("tip")).appendTo($jq(this)).show();
    }
  });
  $jq(".tip-simple").live('mouseout', function(){
    $jq(this).children("div").hide();
  });

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



  var rss = new Raphael("footer-rss", 35, 30).path("M4.135,16.762c3.078,0,5.972,1.205,8.146,3.391c2.179,2.187,3.377,5.101,3.377,8.202h4.745c0-9.008-7.299-16.335-16.269-16.335V16.762zM4.141,8.354c10.973,0,19.898,8.975,19.898,20.006h4.743c0-13.646-11.054-24.749-24.642-24.749V8.354zM10.701,25.045c0,1.815-1.471,3.287-3.285,3.287s-3.285-1.472-3.285-3.287c0-1.813,1.471-3.285,3.285-3.285S10.701,23.231,10.701,25.045z").attr({fill: "#FFF", stroke: "none"});
  var t = new Raphael("footer-tweet", 35, 30).path("M23.295,22.567h-7.213c-2.125,0-4.103-2.215-4.103-4.736v-1.829h11.232c1.817,0,3.291-1.469,3.291-3.281c0-1.813-1.474-3.282-3.291-3.282H11.979V6.198c0-1.835-1.375-3.323-3.192-3.323c-1.816,0-3.29,1.488-3.29,3.323v11.633c0,6.23,4.685,11.274,10.476,11.274h7.211c1.818,0,3.318-1.463,3.318-3.298S25.112,22.567,23.295,22.567z").attr({fill: "#FFF", stroke: "none"});
  var email = new Raphael("footer-mail", 35, 30).path("M28.516,7.167H3.482l12.517,7.108L28.516,7.167zM16.74,17.303C16.51,17.434,16.255,17.5,16,17.5s-0.51-0.066-0.741-0.197L2.5,10.06v14.773h27V10.06L16.74,17.303z").attr({fill: "#FFF", stroke: "none"});

  icon_hover(rss);
  icon_hover(t);
  icon_hover(email);

  function icon_hover(e1){
    e1.hover(function (event) {
      this.attr({fill: "#6FA2D9"});
    }, function (event) {
      this.attr({fill: "white"});
    });
  }

  });



 
