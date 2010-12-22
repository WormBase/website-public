/***************************/
// Search Bar functions
// author: Abigail Cabunoc
// abigail.cabunoc@oicr.on.ca      
/***************************/

//The search bar methods
$jq(document).ready(function(){
  var searchBox = $jq("#Search"),
      searchBoxDefault = "search...",
      searchForm = $jq("#searchForm")

  searchBox.focus(function(e){
    $jq(this).addClass("active");
  });
  searchBox.blur(function(e){
    $jq(this).removeClass("active");
  });

  //show/hide default text if needed
  searchBox.focus(function(){
    if($jq(this).attr("value") == searchBoxDefault) $jq(this).attr("value", "");
  });
  searchBox.blur(function(){
    if($jq(this).attr("value") == "") $jq(this).attr("value", searchBoxDefault);
  });
 
});


var cur_search_type = 'gene';

function search() {
    var f = $jq("#Search").attr("value");
    if(f == "search..." || f == "*" || !f){
//       location.href= '/search/preview/' + cur_search_type + '/*';
      return;
    }
    f = encodeURIComponent(f);
    f = f.replace('%26', '&');
    f = f.replace('%2F', '/');

    location.href = '/search/' + cur_search_type + '/' + f;
}

function search_change(new_search) {
  if((new_search == "home") || (new_search == "me") || (new_search == "bench")){ new_search = "gene"; }
  $jq("#searchForm ul.dropdown li#" + cur_search_type).removeClass("selected");
  cur_search_type = new_search;
  $jq("#searchForm ul.dropdown li#" + new_search).addClass("selected");
  
}