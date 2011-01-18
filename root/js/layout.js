/***************************/
// layout functions
// author: Abigail Cabunoc
// abigail.cabunoc@oicr.on.ca      
/***************************/

//The layout methods

    function columns(leftWidth, rightWidth, noUpdate){
      if(leftWidth>99){
        $jq("#widget-holder").children(".sortable").css('min-height', '0');
      }else{
        $jq("#widget-holder").children(".sortable").css('min-height', '5em');
      }
      $jq("#widget-holder").children(".left").css("width",leftWidth + "%");
      if(rightWidth==0){rightWidth=100;}
      $jq("#widget-holder").children(".right").css("width",rightWidth + "%");
      if(!noUpdate){ updateLayout(); }
    }

    function deleteLayout(layout){
      var $class = $jq("#widget-holder").attr("class");
      $jq.get("/rest/layout/" + $class + "/" + layout + "?delete=1");
      $jq("div.columns ul div li#layout-" + layout).remove();
    }

    function setLayout(layout){
      var $class = $jq("#widget-holder").attr("class");
      $jq.get("/rest/layout/" + $class + "/" + layout, function(data) {
          var nodeList = data.childNodes[0].childNodes;
          var len = nodeList.length;
          for(i=0; i<len; i++){
            var node = nodeList.item(i);
            if(node.nodeName == "data"){
              location.hash = node.attributes.getNamedItem('lstring').nodeValue;
            }
          }
        }, "xml");
    }
    
    function goToAnchor(anchor){
      document.getElementById(anchor).scrollIntoView(true);
    }

    function newLayout(layout){
      updateLayout(layout, function() {
        $jq(".list-layouts").load("/rest/layout_list/" + $jq(".list-layouts").attr("type"), function(response, status, xhr) {
            if (status == "error") {
                var msg = "Sorry but there was an error: ";
                $jq(".list-layouts").html(msg + xhr.status + " " + xhr.statusText);
              }
            });
          });
      return false;
    }
    
    function updateURLHash (left, right, leftWidth) {
      var l = left.map(function(i) { return getWidgetID(i);});
      var r = right.map(function(i) { return getWidgetID(i);});
      var ret = "l" + l.join('') + "r" + r.join('') + "w" + leftWidth;
      location.hash = ret;
      return ret;
    }
    
    function readHash() {
      var h = decodeURI(location.hash);

      var left = [];
      var right = [];
      var findL = h.match(/l([0-9A-Z]*)/);
      var findR = h.match(/r([0-9A-Z]*)/);
      var findW = h.match(/w([0-9A-Z]*)/);
      var w = (findW && findW.length>0) ? findW[1] : false;

      var l = findL[1].split('');
      var r = findR[1].split('');
      
      l = l.map(function(i) { return getWidgetName(i);});
      r = r.map(function(i) { return getWidgetName(i);});

      var reset = compare(l, r, w);
      if(reset){
        resetLayout(l, r, w);
      }
    }
    
    //get an ordered list of all the widgets as they appear in the sidebar.
    //only generate once, save for future
    var widgetList = function() {
        if (this.wl) return this.wl;
        var instance = this;
        var navigation = $jq("#navigation");
        var list = navigation.children("ul").children(".module-load")
                  .map(function() { return this.getAttribute("wname");})
                  .get();
        this.wl = { list: list };
        return this.wl;
    }
    
    //returns order of widget in widget list in radix (base 36) 0-9a-z
    function getWidgetID (widget_name) {
        var wl = widgetList();
        return wl.list.indexOf(widget_name).toString(36).toUpperCase();
    }
    
    //returns widget name 
    function getWidgetName (widget_id) {
        var wl = widgetList();
        return wl.list[parseInt(widget_id,36)];
    }

    function compare(l, r, w) {
      var holder =  $jq("#widget-holder");
      var left = holder.children(".left").children(".visible")
                        .map(function() { return this.id;})
                        .get();
      var right = holder.children(".right").children(".visible")
                        .map(function() { return this.id;})
                        .get();
      var leftWidth = getLeftWidth(holder);
      var diff = leftWidth - w;
      if((left.length != l.length) || (right.length != r.length)){
        return true;
      }else if((diff > 5)||(diff < -5)){
        return true;
      }else {
          var i = 0;
          for(i=0;i<left.length;i++){
            if(left[i] != l[i]){
              return true;
            }
          }
          i=0;
          for(i=0;i<right.length;i++){
            if(right[i] != r[i]){
              return true;
            }
          }
      }
      return false;
    }

    function updateLayout(layout, callback){
      l = 'default';
      if((typeof layout) == 'string'){
        l = escape(layout); 
      }

      var holder =  $jq("#widget-holder");
      var $class = holder.attr("class");
      var left = holder.children(".left").children(".visible")
                        .map(function() { return this.id;})
                        .get();
      var right = holder.children(".right").children(".visible")
                        .map(function() { return this.id;})
                        .get();
      var leftWidth = getLeftWidth(holder);
      var lstring = updateURLHash(left, right, leftWidth);
      $jq.post("/rest/layout/" + $class + "/" + l, { 'lstring':lstring }, function(){
        if(callback){ callback(); }
      });

    }

    function getLeftWidth(holder){
      var totWidth = parseFloat(holder.css("width"));
//       var leftWidth = parseFloat(holder.children(".left").css("width"));
      var leftWidth = (parseFloat(holder.children(".left").css("width"))/totWidth)*100;
      return Math.round(leftWidth); //if you don't round, the slightest change causes an update
    }

    function resetLayout(leftList, rightList, leftWidth){
      $jq("div#navigation").children("ul").children("li").removeClass("ui-selected");
      $jq("#widget-holder").children().children("li").removeClass("visible");

      columns(leftWidth, (100-leftWidth), 1);
      for(widget in leftList){
        var widget_name = leftList[widget];
        if(widget_name.length > 0){
          var nav = $jq("#nav-" + widget_name);
          var content = "div#" + widget_name + "-content";
          nav.attr("load", 0);
          openWidget(widget_name, nav, content, ".left");
        }
      }
      for(widget in rightList){
        var widget_name = rightList[widget];
        if(widget_name.length > 0){
          var nav = $jq("#nav-" + widget_name);
          var content = "div#" + widget_name + "-content";
          openWidget(widget_name, nav, content, ".right");
        }
      }
      updateLayout();
    }






$jq(function() {

    var $sidebar   = $jq("#navigation"),
        $window    = $jq(window),
        offset     = 0,
        loadcount  = 0,
        at_default = -45;

    $window.scroll(function() {
      if($sidebar.offset()){
        if(!offset){offset = $sidebar.offset().top;}

        var bottomPos = $sidebar.parent().height() - $sidebar.outerHeight();
        if( bottomPos < at_default )
            bottomPos = at_default;
        var objBiggerThanWindow = $sidebar.outerHeight() < $window.height();
        if (objBiggerThanWindow){
          if ($window.scrollTop() > offset) {
              var newpos = $window.scrollTop() - offset + 10 + at_default;
              if (newpos > bottomPos)
                  newpos = bottomPos;
                  $sidebar.stop().css(
                  'margin-top', newpos
              );
          } else {
              $sidebar.stop().css(
                  'margin-top', at_default
              );
          }
        }
      } 
      var results    = $jq("#results"); //load inside so we can catch the results loaded by ajax calls
      if(results.offset() && loadcount < 2){

        var rHeight = results.height() + results.offset().top;
        var rBottomPos = rHeight - ($window.height() + $window.scrollTop())
        if(rBottomPos < 400) {
          results.children(".load-results").trigger('click');
          loadcount++;
        }
      }

    });

});