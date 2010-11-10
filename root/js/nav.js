/***************************/
// global nav functions
// author: Abigail Cabunoc
// abigail.cabunoc@oicr.on.ca      
/***************************/

//The global nav methods
$(document).ready(function(){
  var navLen = $("#nav-bar").children("ul").children("li").length;
  
  var i=0;
  var nav = $("#nav-bar").children("ul").children("li").first();
  for(i=0; i<navLen; i++){
    if(nav.children().length > 1){
      $('<span class="ui-icon ui-icon-triangle-1-s"></span>').prependTo(nav.children("a"));
    }else{
      nav.children("a").css("padding", "0.5em 1.5em 0");
    }
    nav.children("ul").addClass("dropdown");
    nav = nav.next();
  }

//   $("#nav-bar ul li").live('hover', function(){
//     $(this).children("ul").toggle();
//   });

  $("#nav-bar ul li").hover(function () {
      $(this).children("ul").show();
      $(this).children("a").addClass("hover");
    }, function () {
      $(this).children("ul").hide();
      $(this).children("a").removeClass("hover");
    });


});