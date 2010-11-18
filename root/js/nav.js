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


  var dropdownLen = $("#nav-bar").children("ul").children("li").children("ul").children("li").length;
  var j=0;
  var drop = $("#nav-bar").children("ul").children("li").children("ul").children("li").first();
  for(j=0; j<dropdownLen; j++){
    $('<span class="ui-icon ui-icon-triangle-1-e"></span>').prependTo(drop.children("a"));
    drop = drop.next();
  }

  $("#nav-bar ul li, #searchForm").hover(function () {
      $(this).children("ul.dropdown").show();
      $(this).children("a").addClass("hover");
    }, function () {
      $(this).children("ul.dropdown").hide();
      $(this).children("a").removeClass("hover");
    });


});