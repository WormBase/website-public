/***************************/
// layout functions
// author: Abigail Cabunoc
// abigail.cabunoc@oicr.on.ca      
/***************************/

//The layout methods
    var reloadLayout = true; //keeps track of whether or not to reload the layout on hash change
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
      var $class = $jq("#widget-holder").attr("wclass");
      $jq.get("/rest/layout/" + $class + "/" + layout + "?delete=1");
      $jq("div.columns ul div li#layout-" + layout).remove();
    }

    function setLayout(layout){
      var $class = $jq("#widget-holder").attr("wclass");
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
      var l = $jq.map(left, function(i) { return getWidgetID(i);});
      var r = $jq.map(right, function(i) { return getWidgetID(i);});
      var ret = l.join('') + "-" + r.join('') + "-" + (leftWidth/10);
      if(location.hash && decodeURI(location.hash).match(/^[#](.*)$/)[1] != ret){
        reloadLayout = false;
      }
      location.hash = ret;
      return ret;
    }
    
    function readHash() {
      if(reloadLayout){
        var h = decodeURI(location.hash).match(/^[#](.*)$/)[1].split('-');
        if(!h){ return; }
//         h = h[1].split('-');
        
        var l = h[0];
        var r = h[1];
        var w = (h[2] * 10);
        
        if(l){ l = $jq.map(l.split(''), function(i) { return getWidgetName(i);}); }
        if(r){ r = $jq.map(r.split(''), function(i) { return getWidgetName(i);}); }
        resetLayout(l,r,w);
      }else{
        reloadLayout = true;
      }
    }
    
    //get an ordered list of all the widgets as they appear in the sidebar.
    //only generate once, save for future
    var widgetList = function() {
        if (this.wl) return this.wl;
        var instance = this;
        var navigation = $jq("#navigation");
        var list = navigation.find(".module-load")
                  .map(function() { return this.getAttribute("wname");})
                  .get();
        this.wl = { list: list };
        return this.wl;
    }
    
    //returns order of widget in widget list in radix (base 36) 0-9a-z
    function getWidgetID (widget_name) {
        var wl = widgetList();
        return wl.list.indexOf(widget_name).toString(36);
    }
    
    //returns widget name 
    function getWidgetName (widget_id) {
        var wl = widgetList();
        return wl.list[parseInt(widget_id,36)];
    }

    function updateLayout(layout, callback){
      l = 'default';
      if((typeof layout) == 'string'){
        l = escape(layout); 
      }

      var holder =  $jq("#widget-holder");
      var $class = holder.attr("wclass");
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
      $jq("div#navigation").find(".ui-selected").removeClass("ui-selected");
      $jq("#widget-holder").children().children("li").removeClass("visible");

      columns(leftWidth, (100-leftWidth), 1);
      for(var widget = 0; widget < leftList.length; widget++){
        var widget_name = leftList[widget];
        if(widget_name.length > 0){
          var nav = $jq("#nav-" + widget_name);
          var content = "div#" + widget_name + "-content";
          openWidget(widget_name, nav, content, ".left");
        }
      }
      for(var widget = 0; widget < rightList.length; widget++){
        var widget_name = rightList[widget];
        if(widget_name.length > 0){
          var nav = $jq("#nav-" + widget_name);
          var content = "div#" + widget_name + "-content";
          openWidget(widget_name, nav, content, ".right");
        }
      }
      if(location.hash.length > 0){
        updateLayout();
      }
    }



  var loadcount = 0;

$jq(function() {

    var $sidebar   = $jq("#navigation"),
        $window    = $jq(window),
        offset     = 0,
        at_default = -45;

    $window.scroll(function() {
      if($sidebar.offset()){
        if(!offset){offset = $sidebar.offset().top;}

        var bottomPos = $sidebar.parent().height() - $sidebar.outerHeight() - 20;
        if( bottomPos < 0 )
            bottomPos = at_default;
        var objSmallerThanWindow = $sidebar.outerHeight() < $window.height();
        if (objSmallerThanWindow){
          if ($window.scrollTop() > offset) {
              var newpos = $window.scrollTop() - offset + at_default + system_message;
              if (newpos > bottomPos) {
                  newpos = bottomPos;
              }
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
      var results    = $jq("#results.lazyload-widget"); //load inside so we can catch the results loaded by ajax calls

      if(results.offset() && loadcount < 3){
        var rHeight = results.height() + results.offset().top;
        var rBottomPos = rHeight - ($window.height() + $window.scrollTop())
        if(rBottomPos < 400) {
          results.children(".load-results").trigger('click');
        }
      }

    });

});

    if(!Array.indexOf){
        Array.prototype.indexOf = function(obj){
            for(var i=0; i<this.length; i++){
                if(this[i]==obj){
                    return i;
                }
            }
            return -1;
        }
    }
