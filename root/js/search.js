/***************************/
// Search Bar functions
// author: Abigail Cabunoc
// abigail.cabunoc@oicr.on.ca      
/***************************/

//The search bar methods
$(document).ready(function(){
  var searchBox = $("#Search"),
      searchBoxDefault = "search...",
      searchForm = $("#searchForm"),
      searchMsgText = "enter a value";

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
  
  //display the error msg if the user didn't input a search query
  searchForm.submit(function(){
    if (searchBox.val() == searchBoxDefault || !searchBox.val()) {
      $("#searchMsg").text(searchMsgText).show().fadeOut(2000);
      return false;
    }
    return true;
  });

});
