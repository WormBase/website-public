/***************************/
// layout functions
// author: Abigail Cabunoc
// abigail.cabunoc@oicr.on.ca      
/***************************/

//The layout methods

    function columns(leftWidth, rightWidth, noUpdate){
      $("#widget-holder").children(".left").css("width",leftWidth + "%");
      if(rightWidth==0){rightWidth=100;}
      $("#widget-holder").children(".right").css("width",rightWidth + "%");
      if(!noUpdate){ updateLayout(); }
    }

    function deleteLayout(layout){
      var class = $("#widget-holder").attr("class");
      $("div.columns ul div li#" + layout).remove();
      $.get("/rest/layout/" + class + "/" + layout + "?delete=1");
    }

    function updateLayout(layout){
      var l = layout;
      if(!layout){ l = 'default'; }
      var holder =  $("#widget-holder");
      var class = holder.attr("class");
      var left = holder.children(".left").children(".visible")
                        .map(function() { return this.id;})
                        .get();
      var right = holder.children(".right").children(".visible")
                        .map(function() { return this.id;})
                        .get();
      var leftWidth = getLeftWidth(holder);
      $.post("/rest/layout/" + class + "/" + l, { 'left[]': left, 'right[]' : right, 'leftWidth':leftWidth });
    }

    function getLeftWidth(holder){
      var totWidth = parseFloat(holder.css("width"));
//       var leftWidth = parseFloat(holder.children(".left").css("width"));
      var leftWidth = (parseFloat(holder.children(".left").css("width"))/totWidth)*100;
      return leftWidth
    }

    function resetLayout(leftList, rightList, leftWidth){
      $("div#navigation").children("ul").children("li").removeClass("ui-selected");
      $("#widget-holder").children().children("li").removeClass("visible");

      columns(leftWidth, (100-leftWidth), 1);
      for(widget in leftList){
        var widget_name = leftList[widget];
        if(widget_name.length > 0){
          var nav = $("#nav-" + widget_name);
          var content = "div#" + widget_name + "-content";
          nav.attr("load", 0);
          openWidget(widget_name, nav, content, ".left");
        }
      }
      for(widget in rightList){
        var widget_name = rightList[widget];
        if(widget_name.length > 0){
          var nav = $("#nav-" + widget_name);
          var content = "div#" + widget_name + "-content";
          openWidget(widget_name, nav, content, ".right");
        }
      }
    }

