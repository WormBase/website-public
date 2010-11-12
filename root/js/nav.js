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
    $('<span class="ui-icon ui-icon-triangle-1-s"></span>').prependTo(nav.children("a"));
    nav = nav.next();
  }
  $(".dropdown").addClass("ui-corner-bottom");
  $(".dropdown").children("li").last().addClass("ui-corner-bottom");

  $("#nav-bar ul li, #searchForm").hover(function () {
      $(this).children("ul.dropdown").show();
      $(this).children("a").addClass("hover");
    }, function () {
      $(this).children("ul.dropdown").hide();
      $(this).children("a").removeClass("hover");
    });


});