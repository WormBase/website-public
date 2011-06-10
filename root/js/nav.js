/***************************/
// global nav functions
// author: Abigail Cabunoc
// abigail.cabunoc@oicr.on.ca      
/***************************/

//The global nav methods
$jq(document).ready(function(){
  var navLen = $jq("#nav-bar").children("ul").children("li").length;
  var i=0;
  var nav = $jq("#nav-bar").children("ul").children("li").first();
  for(i=0; i<navLen; i++){
    $jq('<span class="ui-icon ui-icon-triangle-1-s"></span>').prependTo(nav.children("a"));
    nav = nav.next();
  }


  var dropdownLen = $jq("#nav-bar").children("ul").children("li").children("ul").children("li").length;
  var j=0;
  var drop = $jq("#nav-bar").children("ul").children("li").children("ul").children("li").first();
  for(j=0; j<dropdownLen; j++){
    $jq('<span class="ui-icon ui-icon-triangle-1-e"></span>').prependTo(drop.children("a"));
    drop = drop.next();
  }

  var timer;
  $jq("#nav-bar ul li").hover(function () {
            $jq("div.columns>ul").hide();
      if(timer){
        $jq(this).siblings("li").children("ul.dropdown").hide();
        $jq(this).siblings("li").children("a").removeClass("hover");
        $jq(this).children("ul.dropdown").find("a").removeClass("hover");
        $jq(this).children("ul.dropdown").find("ul.dropdown").hide();
        clearTimeout(timer);
        timer = null;
      }
      $jq(this).children("ul.dropdown").show();
      $jq(this).children("a").addClass("hover");
    }, function () {
      var toHide = $jq(this);
      if(timer){
        clearTimeout(timer);
        timer = null;
      }
      timer = setTimeout(function() {
            toHide.children("ul.dropdown").hide();
            toHide.children("a").removeClass("hover");
          }, 300)
    });

//   var searchTimer;
//   $jq("#searchForm").hover(function () {
//       if(searchTimer){
//         clearTimeout(searchTimer);
//         searchTimer = null;
//       }
//       $jq(this).children("ul.dropdown").show();
//       $jq(this).children("a").addClass("hover");
//     }, function () {
//       var toHide = $jq(this);
//       if(searchTimer){
//         clearTimeout(searchTimer);
//         searchTimer = null;
//       }
//       searchTimer = setTimeout(function() {
//             toHide.children("ul.dropdown").hide();
//             toHide.children("a").removeClass("hover");
//           }, 300)
//     });


});