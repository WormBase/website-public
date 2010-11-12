/***************************/
// Search Bar functions
// author: Abigail Cabunoc
// abigail.cabunoc@oicr.on.ca      
/***************************/

//The search bar methods
$(document).ready(function(){
  var searchBox = $("#Search"),
      searchBoxDefault = "search...",
      searchForm = $("#searchForm")

  searchBox.focus(function(e){
    $(this).addClass("active");
  });
  searchBox.blur(function(e){
    $(this).removeClass("active");
  });

  //show/hide default text if needed
  searchBox.focus(function(){
    if($(this).attr("value") == searchBoxDefault) $(this).attr("value", "");
  });
  searchBox.blur(function(){
    if($(this).attr("value") == "") $(this).attr("value", searchBoxDefault);
  });
 
});


var cur_search_type = 'gene';

function search() {
    var f = $("#Search").attr("value");
    f = encodeURIComponent(f);
    f = f.replace('%26', '&');
    f = f.replace('%2F', '/');

    location.href = '/search_new/' + cur_search_type + '/' + f;
}

function search_change(new_search) {
  $("#searchForm ul.dropdown li#" + cur_search_type).removeClass("selected");
  cur_search_type = new_search;
  $("#searchForm ul.dropdown li#" + new_search).addClass("selected");

  
}