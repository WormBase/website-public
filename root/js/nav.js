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

  var timer;
  $("#nav-bar ul li, #searchForm").hover(function () {
      if(timer){
        $(this).siblings("li").children("ul.dropdown").hide();
        $(this).siblings("li").children("a").removeClass("hover");
        $(this).children("ul.dropdown").find("a").removeClass("hover");
        $(this).children("ul.dropdown").find("ul.dropdown").hide();
        clearTimeout(timer);
        timer = null;
      }
      $(this).children("ul.dropdown").show();
      $(this).children("a").addClass("hover");
    }, function () {
      var toHide = $(this);
      if(timer){
        clearTimeout(timer);
        timer = null;
      }
      timer = setTimeout(function() {
            toHide.children("ul.dropdown").hide();
            toHide.children("a").removeClass("hover");
          }, 500)
    });


});