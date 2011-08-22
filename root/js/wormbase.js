
 
 
 
(function(window, document, undefined){ 
  var document = window.document,
      location = window.location;
     
  var WB = (function(){
    
    function init(){
      window.onhashchange = readHash;
      var pageInfo = $jq("#header").data("page");
      if($jq(".user-history").size()>0){
        function histUpdate(){
          WB.ajaxGet($jq(".user-history"), "/rest/history?count=3");
          setTimeout(histUpdate, 6e5); //update the history every now and then
          return;
        }
        histUpdate();
      }
      if($jq(".list-layouts").size()>0){WB.ajaxGet($jq(".list-layouts"), "/rest/layout_list/" + $jq(".list-layouts").attr("type"));}
    
      
      $jq.post("/rest/history", { 'ref': pageInfo['ref'] , 'name' : pageInfo['name'], 'id':pageInfo['id'], 'class':pageInfo['class'], 'type': pageInfo['type'], 'is_obj': pageInfo['is_obj'] });

      search_change(pageInfo['class']);
      if($jq("#top-system-message").size()>0) {systemMessage('show');}
      var searchAll = $jq("#all-search-results");
      if(searchAll.size()>0) { 
        var searchInfo = searchAll.data("search");
        allResults(searchInfo['type'], searchInfo['species'], searchInfo['query']);
      } 

      Breadcrumbs.init();
        
      if($jq(".workbench-status-" + pageInfo['wbid']).size()>0){$jq(".workbench-status-" + pageInfo['wbid']).load("/rest/workbench/star?wbid=" + pageInfo['wbid'] + "&name=" + pageInfo['name'] + "&class=" + pageInfo['class'] + "&type=" + pageInfo['type'] + "&id=" + pageInfo['id'] + "&url=" + pageInfo['ref'] + "&save_to=" + pageInfo['save'] + "&is_obj=" + pageInfo['is_obj']);}

      updateCounts(pageInfo['ref']);
      var layout;
      if(location.hash.length > 0){
        readHash();
      }else if(layout = $jq("#widget-holder").data("layout")){
        if(layout['hash']){
          location.hash = layout['hash'];
        }else{
          resetLayout(layout['leftlist'], layout['rightlist'] || [], layout['leftwidth'] || 100);
          updateLayout();
        }
      }
      
      searchInit();
      navBarInit();
      operator();
      pageInit();
      widgetInit();
      effects();
    }
   
    
    var timer;
    function navBarInit(){
      $jq("#nav-bar").find("ul li").hover(function () {
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
        ajaxGet($jq(".status-bar"), "/rest/auth");
    }
    
    
    function pageInit(){
      $jq("#print").live('click',function() {
        var layout= window.location.hash.replace('#','');
        var print = $jq(this);
        
          $jq.ajax({
                type: "POST",
                url : '/rest/print',
                data: {layout:layout}, 
                beforeSend:function(){
                WB.setLoading(print); 
              },
                success: function(data){
                print.html('');
                window.location.href=data;
              },
                error: function(request,status,error) {
                    alert(request + " " + status + " " + error );
              }
            });
      });
   
      $jq(".section-button").click(function() {
          var section = $jq(this).attr('wname');
          $jq("#nav-" + section).trigger("open");
          WB.goToAnchor(section);
      });
      
      $jq("#nav-min-icon").addClass("ui-icon ui-icon-triangle-1-w");

      if($jq(".sortable").size()>0){
        $jq(".sortable").sortable({
          handle: '.widget-header, #widget-footer',
          items:'li.widget',
          placeholder: 'placeholder',
          connectWith: '.sortable',
          opacity: 0.6,
          forcePlaceholderSize: true,
          update: function(event, ui) { updateLayout(); },
        });
      }
      
      $jq("#widget-holder").children("#widget-header").disableSelection();

      
      $jq("div#column-dropdown").find("a, div.columns div.ui-icon, div.columns>ul>li>a").click(function() {
        $jq("div.columns>ul").toggle();
      });
      
      $jq("#nav-min").click(function() {
        var nav = $jq("#navigation");
        var ptitle = $jq("#page-title");
        var w = nav.width();
        var msg = "open sidebar";
        var marginLeft = '-1em';
        if(w == 0){ w = '12em'; msg = "close sidebar"; marginLeft = 175; }else { w = 0;}
        nav.animate({width: w}).show();
        ptitle.animate({marginLeft: marginLeft}).show();
        nav.children("#title").children("div").toggle();
        $jq(this).attr("title", msg);
        $jq(this).children("#nav-min-icon").toggleClass("ui-icon-triangle-1-w").toggleClass("ui-icon-triangle-1-e");
      });
            
      $jq(".bench-update").live('click',function() {
        var wbid     = $jq(this).attr("wbid");
        var $class     = $jq(this).attr("objclass");
        var label     = $jq(this).attr("name");
        var obj_url  = $jq(this).attr("url");
        var is_obj  = $jq(this).attr("is_obj");
        var url     = $jq(this).attr("href") + '?name=' + escape(label) + "&class=" + $class + "&url=" + obj_url + "&is_obj=" + is_obj;

        $jq("#bench-status").load(url, function(){
          WB.ajaxGet($jq(".workbench-status-" + wbid), "/rest/workbench/star?wbid=" + wbid + "&name=" + escape(label) + "&class=" + $class + "&url=" + obj_url + "&is_obj=" + is_obj, 1);
          $jq("#bench-status").addClass("highlight").delay(3000).queue( function(){ $jq(this).removeClass("highlight"); $jq(this).dequeue();});       
          if($class != "paper"){
            WB.ajaxGet($jq("div#reports-content"), "/rest/widget/me/reports", 1);
          }
          if($class == "paper"){
            WB.ajaxGet($jq("div#my_library-content"), "/rest/widget/me/my_library", 1);
          }
        });
      return false;
      });
      
      
      // Should be a user supplied site-wide option for this.
      // which can be over-ridden on any widget.
      // Toggle should empty look of button
      $jq("#hide-empty-fields").click(function() {       
            $jq(".disabled" ).toggle();    
            $jq(this).toggleClass('ui-state-highlight');
      });
    }
    
    function widgetInit(){
      
    
      // used in sidebar view, to open and close widgets when selected
      $jq("#widgets").find(".module-load, .module-close").click(function() {
        var widget_name = $jq(this).attr("wname");
        var nav = $jq("#nav-" + widget_name);
        var content = "div#" + widget_name + "-content";
        if(!nav.hasClass('ui-selected')){
          if($jq(content).text().length < 4){
              var column = ".left";
              var holder = $jq("#widget-holder");
              if(getLeftWidth(holder) >= 90){
                if(holder.children(".right").children(".visible").height()){
                  column = ".right";
                }
              }else{
                var leftHeight = parseFloat(holder.children(".left").css("height"));
                var rightHeight = parseFloat(holder.children(".right").css("height"));
                if (rightHeight < leftHeight){ column = ".right"; }
              }
              openWidget(widget_name, nav, content, column);
          }else{
            $jq(content).parents("li").addClass("visible");
            nav.addClass("ui-selected");
          }
          goToAnchor(widget_name);
        } else {
          nav.removeClass("ui-selected");
          $jq(content).parents("li").removeClass("visible"); 
        }
        updateLayout();
        return false;
      });

      $jq("#widget-holder").find(".module-max").click(function() {
        var module = $jq(this).parents(".widget-container")
    //     if(module.find(".cboxElement").trigger('click').size() < 1){
          var clone = module.clone();
    //       clone.find(".module-max").remove();
    //       clone.find(".module-close").remove();
    //       clone.find(".module-min").remove();
    //       clone.find("#widget-footer").remove();
    //       clone.find("h3").children(".ui-icon").remove();
    //       clone.css("min-width", "400px");
    //       var cbox = $jq('<a class="cboxElement" href="#"></a>');
    //       cbox.appendTo(module).hide();
    //       cbox.colorbox({html:clone, title:"Note: not all effects are supported while widget is maximized", maxWidth:"100%"}).trigger('click');
    //     }

    // code for external pop out window - if we need that
        var popout = window.open("", "test", "height=" + module.height() + ",width=" + module.width());
        popout.document.write(document.head.innerHTML);
        popout.document.write(clone.html());
      });

      // used in sidebar view, to open and close widgets when selected
      $jq("#widgets").find(".module-load, .module-close").bind('open',function() {
        var widget_name = $jq(this).attr("wname");
        var nav = $jq("#nav-" + widget_name);
        var content = "div#" + widget_name + "-content";

        openWidget(widget_name, nav, content, ".left");
        return false;
      });
      $jq("#widget-holder").find(".module-min").click(function() {
        var module = $jq("div#" + $jq(this).attr("wname") + "-content");
        module.next().slideToggle("fast");
        module.slideToggle("fast");
        $jq(this).parent().toggleClass("minimized");
        if ($jq(this).attr("show") != 1){
          $jq(this).attr("show", 1).attr("title", "maximize");
          $jq(this).removeClass("ui-icon-circle-triangle-s").removeClass("ui-icon-triangle-1-s");
          $jq(this).addClass("ui-icon-circle-triangle-e");
        }else{
          $jq(this).attr("show", 0).attr("title", "minimize");
          $jq(this).removeClass("ui-icon-circle-triangle-e");
          $jq(this).addClass("ui-icon-circle-triangle-s");
        }
      });
      
      $jq("#widget-holder").find(".reload").click(function() {
        var widget_name = $jq(this).attr("wname");
        var nav = $jq("#nav-" + widget_name);
        var url     = nav.attr("href");
        WB.ajaxGet($jq("div#" + widget_name + "-content"), url);
      });
        
      
      
      
      $jq(".feed").live('click',function() {
        var url=$jq(this).attr("rel");
        var div=$jq(this).parent().next("#widget-feed");
        div.filter(":hidden").empty().load(url);
        div.slideToggle('fast');
      });
    }
    
    
    
    
    function effects(){
      
      
      $jq(".toggle").live('click',function() {
            $jq(this).toggleClass("active").next().slideToggle("fast");
            return false;
      });
        
      $jq(".tooltip").live('mouseover',function() {
          getCluetip();
          $jq(this).cluetip({
          activation: 'click',
          sticky: true, 
          cluetipClass: 'jtip',
          dropShadow: false, 
          closePosition: 'title',
          arrows: true, 
          hoverIntent: false,
            });
        
      });
            
      $jq("div.text-min").live('click',function() {expand($jq(this), $jq(this).next());});
      $jq("div.more").live('click',function() {expand($jq(this).prev(), $jq(this));});
      function expand(txt, more){
          var h = txt.height();
          if(h<40){
            h='100%';
                    //expand the shorted items before the text, also
              txt.prev('.ellipsis')
              .add(txt.prev().prev().prev('.author-list'))
              .add(txt.prev().prev().prev().prev().children('.paper-title'))
              .removeClass('ellipsis');
          }else{
            h='2.4em';
                    //expand the shorted items before the text, also
              txt.prev(":not(.gene-link)")
              .add(txt.prev().prev().prev('.author-list'))
              .add(txt.prev().prev().prev().prev().children('.paper-title'))
              .addClass('ellipsis');
          }
          txt.css("max-height", "none");
          txt.animate({height:h});
          more.children(".ui-icon").toggleClass('ui-icon-triangle-1-s');
          more.children(".ui-icon").toggleClass('ui-icon-triangle-1-n');
          more.toggleClass('open');
      }

      $jq("div.text-min").live('mouseover mouseout',function() {
        $jq(this).next().toggleClass('opaque');
      });
      
      
      
      $jq(".tip-simple").live('mouseover', function(){
        if(!($jq(this).children("div.tip-elem").show().children('span:not(".ui-icon")').text($jq(this).attr("tip")).size())){
          var tip = $jq('<div class="tip-elem tip ui-corner-all" style="display:block"><span>' + $jq(this).attr("tip") + '</span><span class="tip-elem ui-icon ui-icon-triangle-1-s"></span></div>');
          tip.appendTo($jq(this)).show();
        }
      });
      $jq(".tip-simple").live('mouseout', function(){
        $jq(this).children("div.tip-elem").hide();
      });
    }
    
    var notifyTimer;
    function displayNotification (message){
        if(notifyTimer){
          clearTimeout(notifyTimer);
          notifyTimer = null;
        }
        var notification = $jq("#notifications");
        notification.show().children("#notification-text").text(message);

        notifyTimer = setTimeout(function() {
              notification.fadeOut(400);
            }, 3e3)
    }
    $jq("#notifications").click(function() {
      if(notifyTimer){
        clearTimeout(notifyTimer);
        notifyTimer = null;
      }
      $jq(this).hide();
    });
    
    
       
   function systemMessage(action, messageId){
    if(action == 'show'){
      $jq(".system-message").show().css("display", "block").animate({height:"20px"}, 'slow');
      $jq("#notifications").css("top", "20px");
      system_message = 20; 
    }else{
      $jq(".system-message").animate({height:"0px"}, 'slow', '',function(){ $jq(this).hide();});
      $jq.post("/rest/system_message/" + messageId);
      $jq("#notifications").css("top", "0");
    }
  }


    function setLoading(panel) {
      panel.html('<div class="loading"><img src="/img/ajax-loader.gif" alt="Loading..." /></div>');
    }

    function ajaxGet(ajaxPanel, $url, noLoadImg, callback) {
      $jq.ajax({
        url: $url,
        beforeSend:function(){
          if(!noLoadImg){ setLoading(ajaxPanel); }
        },
        success:function(data){
          ajaxPanel.html(data);
        },
        error:function(xhr, ajaxOptions, thrownError){
          var error = $jq(xhr.responseText);
          ajaxPanel.html('<p class="error"><strong>Oops!</strong> Try that again in a few moments.</p>');
          ajaxPanel.append(error.find(".error-message-technical").html());
        },
        complete:function(XMLHttpRequest, textStatus){
          if(callback){ callback(); }
        }
      });

    }
    
      function operator(){
        var opTimer;
        var opLoaded = false;
        $jq('#operator-box').click(function(){ 
          var opBox = $jq(this);
          if(!(opLoaded)){
            ajaxGet($jq("#operator-box"), "/rest/livechat", 0, 
                    function(){ 
                      if($jq("#operator-box").hasClass("minimize")){
                        $jq("#operator-box").children().hide();
                      }
                    });
            opLoaded = true;
          }
          if(opBox.hasClass("minimize")){
              opBox.removeClass("minimize");
              opBox.animate({width:"9em"});
              opBox.children().show();
          }else{
            opBox.addClass("minimize");
            opBox.animate({width:"1.5em"});
            opBox.children().hide();
          }
        });
        
        $jq('#operator').click(function() { 
          if($jq('#operator').attr("rel")) {
            $jq.post("/rest/livechat?open=1",function() {
              window.location.href="/tools/operator";
            });
          }else {
            var opBox = $jq("#operator-box");
            ajaxGet(opBox, "/rest/livechat", 0, 
            function(){ 
              if(opBox.hasClass("minimize")){
                opBox.children().hide();
              }
            });
            opLoaded = true;
            if(opBox.hasClass("minimize")){
                opBox.removeClass("minimize");
                opBox.animate({width:"9em"});
                opBox.children().show();
            }
            opTimer = setTimeout(function() {
              opBox.addClass("minimize");
              opBox.animate({width:"1.5em"});
              opBox.children().hide();

            }, 4e3)
          }
        }); 
    }
    
  function hideTextOnFocus(selector){
    var area = $jq(selector);
      
    if(area.attr("value") != ""){
      area.siblings().fadeOut();
    }
    area.focus(function(){
      $jq(this).siblings().fadeOut();
    });

    area.blur(function(){
      if($jq(this).attr("value") == ""){
        $jq(this).siblings().fadeIn();
      }
    });
  }











    /***************************/
    // Search Bar functions
    // author: Abigail Cabunoc
    // abigail.cabunoc@oicr.on.ca      
    /***************************/

    //The search bar methods
    function searchInit(){
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
      
    
    }


    var cur_search_type = 'all';

    function search(box) {
        if(!box){ box = "Search"; }else{ cur_search_type = 'all'; } 
        var f = $jq("#" + box).attr("value");
        if(f == "search..." || !f){
          f = "*";
        }
        f = encodeURIComponent(f);
        f = f.replace('%26', '&');
        f = f.replace('%2F', '/');

        location.href = '/search/' + cur_search_type + '/' + f;
    }

    function search_change(new_search, focus) {
      if((!new_search) || (new_search == "home") || (new_search == "me") || (new_search == "bench")){ new_search = "gene"; }
      cur_search_type = new_search;
      if(new_search == "all"){
      new_search = "for anything";
      }else{
        var search_for = "for a";
        if(new_search.match(/^[aeiou]/)){
          search_for = search_for + "n";
        }
        new_search = search_for + " " + new_search.replace(/[_]/, ' ');
      }
      
      $jq("#current-search").text(new_search);
    //   if(focus){ $jq("#Search").focus();}
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
    var queryList = query ? query.replace(/[,\.\*]/, ' ').split(' ') : [];

    this.setTotal = function(t){
    total = t;
    countSpan.html(total);
    }
    
    function queryHighlight(div){
      if(queryList.length == 0) { return; }
      getHighlight(function(){
        for (var i=0; i<queryList.length; i++){
          if(queryList[i]) { div.highlight(queryList[i]); }
        }
      });
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

  function loadResults(url){
    $jq("#all-search-results").empty(); 
    ajaxGet($jq("#all-search-results"), url);
    loadcount = 0;
    $jq(window).scrollTop(0);
    $jq("#navigation").find(".ui-selected").removeClass("ui-selected");
    return false;
  }
  
  function allResults(type, species, query){
    at_default = 0; 
    $jq("#all-search-results").empty(); 
    var url = "/search/" + type + "/" + query + "/?inline=1";
    if(species) { url = url + "&species=" + species;} 
    ajaxGet($jq("#all-search-results"), url);


    $jq("#search-count-summary").find(".count").each(function() {
      $jq(this).load($jq(this).attr("href"), function(){
        if($jq(this).text() == '0'){
          $jq(this).parent().remove();
        }else {
          $jq(this).parent().show();
        }
      });
    });
  }


  function recordOutboundLink(link, category, action) {
    try {
      var pageTracker=_gat._createTracker("UA-16257183-1");
      pageTracker._trackEvent(category, action);
    }catch(err){}
  }




 

   
    function openWidget(widget_name, nav, content, column){
        $jq(content).closest("li").appendTo($jq("#widget-holder").children(column));
        var content = $jq(content);
        addWidgetEffects(content.parent(".widget-container"));
        var url     = nav.attr("href");
        ajaxGet(content, url);
        nav.addClass("ui-selected");
        content.parents("li").addClass("visible");
        return false;
    }
    
    function openAllWidgets(){
      var widgets = $jq("#navigation .module-load");
      var widget = widgets.first();
      for(i=0; i<widgets.length; i++){
        if($jq("#" + widget.attr("wname") + ".visible").length == 0){
          widget.click();
        }
        widget = widget.next();
      }
      return false;
    }
    
    
    
      
  function addWidgetEffects(widget_container) {
      widget_container.find("div.module-min").addClass("ui-icon-large ui-icon-triangle-1-s").attr("title", "minimize");
      widget_container.find("div.module-close").addClass("ui-icon ui-icon-large ui-icon-close").hide();
      widget_container.find("div.module-max").addClass("ui-icon ui-icon-extlink").hide();
      widget_container.find("#widget-footer").hide();
      widget_container.find(".widget-header").children("h3").children("span.hide").hide();

      widget_container.find(".widget-header").hover(
        function () {
          $jq(this).children("h3").children("span").show();
        },
        function () {
          $jq(this).children("h3").children("span.hide").hide();
        }
      );

      widget_container.hover(
        function () {
          $jq(this).find(".widget-header").children(".ui-icon").show();
          if($jq(this).find(".widget-header").children("h3").children(".module-min").attr("show") != 1){
            $jq(this).find("#widget-footer").show();
          }
        }, 
        function () {
          $jq(this).find(".widget-header").children(".ui-icon").hide();
          $jq(this).find("#widget-footer").hide();
        }
      );

      widget_container.find("div.module-min").hover(
        function () {
          if ($jq(this).attr("show")!=1){ $jq(this).addClass("ui-icon-circle-triangle-s");
          }else{ $jq(this).addClass("ui-icon-circle-triangle-e");}
        }, 
        function () {
          $jq(this).removeClass("ui-icon-circle-triangle-s").removeClass("ui-icon-circle-triangle-e");
          if ($jq(this).attr("show")!=1){ $jq(this).addClass("ui-icon-triangle-1-s");
          }else{ $jq(this).addClass("ui-icon-triangle-1-e");}
        }
      );

      widget_container.find("div.module-close").hover(
        function () {
          $jq(this).addClass("ui-icon-circle-close");
        }, 
        function () {
          $jq(this).removeClass("ui-icon-circle-close").addClass("ui-icon-close");
        }
      );
  }












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
        var widget_name = $jq.trim(leftList[widget]);
        if(widget_name.length > 0){
          var nav = $jq("#nav-" + widget_name);
          var content = "div#" + widget_name + "-content";
          openWidget(widget_name, nav, content, ".left");
        }
      }
      for(var widget = 0; widget < rightList.length; widget++){
        var widget_name = $jq.trim(rightList[widget]);
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
  var at_default = -45;
  var system_message = 0;

$jq(function() {

    var $sidebar   = $jq("#navigation"),
        $window    = $jq(window),
        offset     = 0;

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
      
      
  function updateCounts(url){
    var comments = $jq(".comment-count");
    if(comments.size() == 0){ return; }
    
    comments.load("/rest/feed/comment?count=1;url=" + url);
    var is = $jq("<span></span>");
    is.load("/rest/feed/issue?count=1;url=" + url, function(){
      if(is.html() != "0"){
        $jq(".issue-count").html("!").css({color:"red"});
      } 
    });
  }



  var StaticWidgets = {
    update: function(widget_id, path){
        if(!widget_id){ widget_id = "0"; }
        var widget = $jq("li#static-widget-" + widget_id);
        var widget_title = widget.find("input#widget_title").val();
        var widget_order = widget.find("input#widget-order").val();
        var widget_content = widget.find("textarea#widget_content").val();

        $jq.ajax({
              type: "POST",
              url: "/rest/widget/static/" + widget_id,
              dataType: 'json',
              data: {widget_title:widget_title, path:path, widget_content:widget_content, widget_order:widget_order},
              success: function(data){
                    StaticWidgets.reload(widget_id, 0, data.widget_id);
                },
              error: function(request,status,error) {
                  alert(request + " " + status + " " + error );
                }
          }); 
    },
    edit: function(wname, rev) {
      
      var widget_id = wname.split("-").pop();
      var w_content = $jq("#" + wname + "-content");
      var widget = w_content.parent();
      var edit_button = widget.find("a#edit-button");
      if(edit_button.hasClass("ui-state-highlight")){
        StaticWidgets.reload(widget_id);
      }else{
        edit_button.addClass("ui-state-highlight");
        w_content.load("/rest/widget/static/" + widget_id + "?edit=1");
      }

    },
    reload: function(widget_id, rev_id, content_id){
      var w_content = $jq("#static-widget-" + widget_id + "-content");
      var widget = w_content.parent();
      var title = widget.find("h3 span.widget-title input");
      if(title.size()>0){
        title.parent().html(title.val());
      }
      widget.find("a.button").removeClass("ui-state-highlight");
      $jq("#nav-static-widget-" + widget_id).text(title.val());
      var url = "/rest/widget/static/" + (content_id || widget_id);
      if(rev_id) { url = url + "?rev=" + rev_id; } 
      w_content.load(url);
    },
    delete_widget: function(widget_id){
      if(confirm("are you sure you want to delete this widget?")){
        $jq.ajax({
          type: "POST",
          url: "/rest/widget/static/" + widget_id + "?delete=1",
          success: function(data){
            $jq("#nav-static-widget-" + widget_id).click().hide();
          },
          error: function(request,status,error) {
            alert(request + " " + status + " " + error );
          }
        }); 
      }
    },
    history: function(wname){
      var widget = $jq("#" + wname);
      var history = widget.find("div#" + wname + "-history");
      if(history.size() > 0){
        history.toggle();
        widget.find("a#history-button").toggleClass("ui-state-highlight");
      }else{
        var widget_id = wname.split("-").pop();
        var history = $jq('<div id="' + wname + '-history"></div>'); 
        history.load("rest/widget/static/" + widget_id + "?history=1");
        widget.find("div.content").append(history);
        widget.find("a#history-button").addClass("ui-state-highlight");
      }
    }
  }


  var Breadcrumbs = {
    init: function() {
      this.bc = $jq('#breadcrumbs');
      if (!this.bc) { return; };
      this.children = this.bc.children(),
      this.bCount = this.children.size();
      if(this.bCount < 3){ return; }; //less than three items, don't bother with breadcrumbs
      this.exp = false;
      this.bc.empty();
      var hidden = this.children.slice(0, (this.bCount - 2));
      var shown = this.children.slice((this.bCount - 2));
      this.hiddenContainer = $jq('<span id="breadcrumbs-hide"></span>');
      this.hiddenContainer.append(hidden).children().after(' &raquo; ');

      this.bc.append('<span id="breadcrumbs-expand" class="tip-simple ui-icon-large ui-icon-triangle-1-e " tip="exapand"></span>').append(this.hiddenContainer).append(shown);
      this.bc.children(':last').before(" &raquo; ");
    
      this.expand = $jq("#breadcrumbs-expand");
      
  ;
      this.expand.click( function(){
        if( Breadcrumbs.exp ){ Breadcrumbs.show(); }
        else{ Breadcrumbs.hide(); }
      });
      this.width = this.hiddenContainer.width();
      this.hide();
    },
    
    show: function(){
      Breadcrumbs.hiddenContainer.animate({width:Breadcrumbs.width}, function(){ Breadcrumbs.hiddenContainer.css("width", "auto");}).css("visibility", 'visible');
      Breadcrumbs.expand.attr("tip", "minimize");
      Breadcrumbs.expand.removeClass("ui-icon-triangle-1-e").addClass("ui-icon-triangle-1-w");
      Breadcrumbs.exp = false;
    },
    
    hide: function() {
      Breadcrumbs.hiddenContainer.animate({width:0}, function(){ Breadcrumbs.hiddenContainer.css("visibility", 'hidden');});     
      Breadcrumbs.expand.attr("tip", "expand");
      Breadcrumbs.expand.removeClass("ui-icon-triangle-1-w").addClass("ui-icon-triangle-1-e");
      Breadcrumbs.exp = true;
    }
  }



  var providers_large = {
      google: {
          name: 'Google',
          url: 'https://www.google.com/accounts/o8/id'
      },
      facebook: {
          name: 'Facebook',      
          url:  'http://facebook.anyopenid.com/'
      }
  };
  
  var providers = $jq.extend({}, providers_large);

  var openid = {
      /* Provider image click */
      signin: function(box_id, onload) {
        var provider = providers[box_id];
        if (! provider) {
            return;
        }
        var pop_url = '/auth/popup?id='+box_id + '&url=' + provider['url']  + '&redirect=' + window.location;
        this.popupWin(pop_url);
      },

      popupWin: function(url) {
        var h = 400;
        var w = 600;
        var screenx = (screen.width/2) - (w/2 );
        var screeny = (screen.height/2) - (h/2);
        
        var win2 = window.open(url,"popup","status=no,resizable=yes,height="+h+",width="+w+",left=" + screenx + ",top=" + screeny + ",toolbar=no,menubar=no,scrollbars=no,location=no,directories=no");
        win2.focus();
      }
  };
  
  
  var plugins = new Array();
  var loading = false;
  function getScript(name, url, stylesheet, callback) {
    var head = document.documentElement,
        script = document.createElement("script"),
        done = false;
    loading = true;
    script.src = url;
    
    if(stylesheet){
     var link = document.createElement("link");
     link.href = stylesheet;
     link.rel="stylesheet";
     document.getElementsByTagName("head")[0].appendChild(link)
    }
    
    script.onload = script.onreadystatechange = function() {
     if(!done && (!this.readyState ||
       this.readyState === "loaded" || this.readyState === "complete")){
       done = true;
       loading = false;
       plugins[name] = true;
       callback();
     
        script.onload = script.onreadystatechange = null;
        if( head && script.parentNode){
          head.removeChild( script );
        }
      }
    };
    
    head.insertBefore( script, head.firstChild);
    return undefined;
  }
  

    function getDataTables(callback){
      getPlugin("dataTables", "/js/jquery/plugins/dataTables/media/js/jquery.dataTables.min.js", "/js/jquery/plugins/dataTables/media/css/demo_table.min.css", callback);
      return;
    }
    function getHighlight(callback){
      getPlugin("highlight", "/js/jquery/plugins/jquery.highlight-1.1.js", undefined, callback);
      return;
    }
    function getCluetip(callback){
      getPlugin("cluetip", "/js/jquery/plugins/cluetip-1.0.6/jquery.cluetip.min.js", "/js/jquery/plugins/cluetip-1.0.6/jquery.cluetip.css", callback);
      return;
    }
  
  
    function getPlugin(name, url, stylesheet, callback){
      if(!plugins[name]){
        getScript(name, url, stylesheet, callback);
      }else{
        if(loading){
          setTimeout(getPlugin(name, url, stylesheet, callback),1);
          return;
        }
        callback(); 
      }
      return;
    }
    
    return{
      init: init,
      displayNotification: displayNotification, 
      ajaxGet: ajaxGet,
      hideTextOnFocus: hideTextOnFocus,
      systemMessage: systemMessage,
      Breadcrumbs: Breadcrumbs,
      resetLayout: resetLayout,
      setLoading: setLoading,
      SearchResult: SearchResult,
      updateLayout: updateLayout,
      search: search,
      search_change: search_change,
      loadResults: loadResults,
      openid: openid,
      StaticWidgets: StaticWidgets,
      recordOutboundLink: recordOutboundLink,
      getDataTables: getDataTables
    }
  })();




 $jq(document).ready(function() {
      $jq.ajaxSetup( {timeout: 99999 });
      WB.init();
 });

 window.WB = WB;
})(this,document);
