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
  
  var lastXhr;
  $jq( "#Search" ).autocomplete({
      source: function( request, response ) {
          lastXhr = $jq.getJSON( "/search/autocomplete/" + cur_search_type, request, function( data, status, xhr ) {
              if ( xhr === lastXhr ) {
                  response( data );
              }
          });
      },
      minLength: 2,
      select: function( event, ui ) {
          location.href = ui.item.url;
      }
  });
  
 
});


var cur_search_type = 'all';

function search() {
    var f = $jq("#Search").attr("value");
    if(f == "search..." || !f){
      f = "*";
    }
    f = encodeURIComponent(f);
    f = f.replace('%26', '&');
    f = f.replace('%2F', '/');

    location.href = '/search/' + cur_search_type + '/' + f;
}

function search_change(new_search, focus) {
  if((new_search == "home") || (new_search == "me") || (new_search == "bench")){ new_search = "all"; }
  cur_search_type = new_search;
  
  $jq("#current-search").text(new_search.charAt(0).toUpperCase() + new_search.replace(/[_]/, ' ').slice(1));
  if(focus){ $jq("#Search").focus();}
}



function SearchResult(q, type, species, widget){
  var query = decodeURI(q),
      type = type,
      species = species,
      widget = widget,
      page = 1.0,
      total = 0,
      countSpan = $jq((widget ? "." + widget + "-widget" : '') + " #count"),
      resultDiv = $jq((widget ? "." + widget + "-widget" : '') + " .load-results");
  var queryList = query.replace(/[,\.\*]/, ' ').split(' ');

  this.setTotal = function(t){
   total = t;
   countSpan.html(total);
  }
  
  function queryHighlight(div){
    for (var i=0; i<queryList.length; i++){
      if(queryList[i]) { div.highlight(queryList[i]); }
    }
  }
  
  queryHighlight($jq("div#results" + (widget ? "." + widget + "-widget" : '')));
  
  resultDiv.click(function(){
    $jq(this).removeClass("load-results");
    
    page++;
    var url = $jq(this).attr("href") + page + "?" + (species ? "species=" + species : '') + (widget ? "&widget=" + widget : '');
    var div = $jq("<div></div>");
    setLoading(div);
    
    var res = $jq((widget ? "." + widget + "-widget" : '') + " #load-results");
    res.html("loading...");
    div.load(url, function(response, status, xhr) {
      var left = total - (page*10);
      if(left > 0){
        if(left>10){left=10;}
        res.addClass("load-results");
        res.html("load " + left + " more results");
      }else{
        res.remove();
      }

      queryHighlight(div);

      if (status == "error") {
        var msg = "Sorry but there was an error: ";
        $jq(this).html(msg + xhr.status + " " + xhr.statusText);
      }
    });
    div.appendTo($jq(this).parent().children("ul"));
    loadcount++;
  });
  
}