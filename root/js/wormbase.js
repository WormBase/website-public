/*!
 * WormBase
 * http://wormbase.org/
 *
 * WormBase copyright © 1999-2011 
 * California Institute of Technology, 
 * Ontario Institute for Cancer Research,
 * Washington University at St. Louis, and 
 * The Wellcome Trust Sanger Institute.
 *
 * WormBase is supported by a grant from the 
 * National Human Genome Research Institute at the 
 * US National Institutes of Health # P41 HG02223 and the 
 * British Medical Research Council.
 *
 * author: Abigail Cabunoc 
 *         abigail.cabunoc@oicr.on.ca
 */

+function(window, document, undefined){ 
  var location = window.location,
      $jq = jQuery.noConflict();
     
  var WB = (function(){
    var timer,
        notifyTimer,
        cur_search_type = 'all',
        reloadLayout = 0, //keeps track of whether or not to reload the layout on hash change
        loadcount = 0,
        plugins = new Array(),
        loading = false;
    
    function init(){
      var pageInfo = $jq("#header").data("page"),
          searchAll = $jq("#all-search-results");
      
      if($jq(".user-history").size()>0){
        (function histUpdate(){
          ajaxGet($jq(".user-history"), "/rest/history?count=3");
          setTimeout(histUpdate, 6e5); //update the history every 10min
          return;
        })();
      }
      
      $jq.post("/rest/history", { 'ref': pageInfo['ref'] , 'name' : pageInfo['name'], 'id':pageInfo['id'], 'class':pageInfo['class'], 'type': pageInfo['type'], 'is_obj': pageInfo['is_obj'] });

      search_change(pageInfo['class']);
      if($jq("#top-system-message").size()>0) {systemMessage('show');}

      if(searchAll.size()>0) { 
        var searchInfo = searchAll.data("search");
        allResults(searchInfo['type'], searchInfo['species'], searchInfo['query']);
        Scrolling.search;
      } 

      Breadcrumbs.init();
      comment.init(pageInfo);
      issue.init(pageInfo);
        
      if($jq(".workbench-status-" + pageInfo['wbid']).size()>0){$jq(".workbench-status-" + pageInfo['wbid']).load("/rest/workbench/star?wbid=" + pageInfo['wbid'] + "&name=" + pageInfo['name'] + "&class=" + pageInfo['class'] + "&type=" + pageInfo['type'] + "&id=" + pageInfo['id'] + "&url=" + pageInfo['ref'] + "&save_to=" + pageInfo['save'] + "&is_obj=" + pageInfo['is_obj']);}

      updateCounts(pageInfo['ref']);
      
      navBarInit();
      pageInit();
      widgetInit();
      effects();
    }
   

    function navBarInit(){
      searchInit();
      $jq("#nav-bar").find("ul li").hover(function () {
          $jq("div.columns>ul").hide();
          if(timer){
            $jq(this).siblings("li").children("ul.dropdown").hide();
            $jq(this).siblings("li").children("a").removeClass("hover");
            $jq(this).children("ul.dropdown").find("a").removeClass("hover");
            $jq(this).children("ul.dropdown").find("ul.dropdown").hide();
            clearTimeout(timer);
            timer = undefined;
          }
          $jq(this).children("ul.dropdown").show();
          $jq(this).children("a").addClass("hover");
        }, function () {
          var toHide = $jq(this);
          if(timer){
            clearTimeout(timer);
            timer = undefined;
          }
          timer = setTimeout(function() {
                toHide.children("ul.dropdown").hide();
                toHide.children("a").removeClass("hover");
              }, 300)
        });
        ajaxGet($jq(".status-bar"), "/rest/auth", undefined, function(){
          $jq("#bench-status").load("/rest/workbench");
          var login = $jq("#login");
          if(login.size() > 0){
            login.click(function(){
              $jq(this).siblings().toggle();
              $jq(this).toggleClass("open ui-corner-top");
            });
          }else{
            $jq("#logout").click(function(){
              window.open('/logout','pop','status=no,resizable=yes,height=2px,width=2px').blur();
            });
          }
        });
    }
    
    function pageInit(){
      var personSearch = $jq("#person-search"),
          colDropdown = $jq("#column-dropdown");
      
      operator();
      $jq("#print").click(function() {
        var layout = location.hash.replace('#',''),
            print = $jq(this);
          $jq.ajax({
              type: "POST",
              url : '/rest/print',
              data: {layout:layout}, 
              beforeSend:function(){
                setLoading(print); 
              },
              success: function(data){
                print.html('');
                location.href=data;
              },
              error: function(request,status,error) {
                alert(request + " " + status + " " + error );
              }
            });
      });
   
      $jq(".section-button").click(function() {
          var section = $jq(this).attr('wname');
          $jq("#nav-" + section).trigger("open");
          goToAnchor(section);
      });

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
      
      
      colDropdown.find("a, div.columns div.ui-icon, div.columns>ul>li>a").click(function() {
        $jq("div.columns>ul").toggle();
      });
      
      colDropdown.children("ul").children("li").hover(
        function(){
          $jq(this).children("ul").show();
        },
        function(){
          var layout = $jq(this).children("ul");
          setTimeout(function(){layout.hide();}, 500);
        });
      
      $jq("#nav-min").click(function() {
        var nav = $jq(".navigation").add("#navigation"),
            ptitle = $jq("#page-title"),
            w = nav.width(),
            msg = "open sidebar",
            marginLeft = '-1em';
        if(w == 0){ w = '12em'; msg = "close sidebar"; marginLeft = 175; }else { w = 0;}
        nav.animate({width: w}).show();
        ptitle.animate({marginLeft: marginLeft}).show();
        nav.children("#title").children("div").toggle();
        $jq(this).attr("title", msg);
        $jq(this).children("#nav-min-icon").toggleClass("ui-icon-triangle-1-w").toggleClass("ui-icon-triangle-1-e");
      });
      
      // Should be a user supplied site-wide option for this.
      // which can be over-ridden on any widget.
      // Toggle should empty look of button
      $jq("#hide-empty-fields").click(function() {       
            $jq(".disabled" ).toggle();    
            $jq(this).toggleClass('ui-state-highlight');
      });
      if(personSearch.size()>0){
          ajaxGet(personSearch, personSearch.attr("href"), undefined, function(){
            personSearch.delegate(".results-person .result li a", 'click', function(){
                $jq(".ui-state-highlight").removeClass("ui-state-highlight");
                var wbid = $jq(this).attr("href").split('/').pop();
                $jq.ajax({
                    type: "GET",
                    url: "/auth/info/" + wbid,
                    dataType: 'json',
                    success: function(data){
                          var linkAccount = $jq("#link-account");
                          if(linkAccount.size()==0){
                            $jq("input#name").attr("value", data.fullname).attr("disabled", "disabled");
                            var email = new String(data.email);
                            if(data.email && data.status_ok){
                              var re = new RegExp($jq("input#email").attr("value"),"gi");
                              if (((email.match(re))) || !($jq("input#email").attr("value"))){
                                $jq("#email").attr("disabled", "disabled").parent().hide(); 
                              }
                              $jq("input#wbemail").attr("value", email).parent().show();
                            }else{
                              $jq("input#wbemail").attr("value", "").parent().hide();
                              $jq("#email").removeAttr("disabled").parent().show(); 
                            }
                            $jq(".register-notice").html("<span id='fade'>" +  data.message + "</span>").show();
                            $jq("input#wbid").attr("value", data.wbid);
                          }else{
                            $jq("input#wbid").attr("value", data.wbid);
                            $jq("input#email").attr("value", data.email);
                            linkAccount.removeAttr("disabled");
                            $jq("input#confirm").attr("value", "");
                            var emails = ["[% emails.join('", "') %]"];
                            if(data.email && data.status_ok){
                              var e = "" + data.email;
                              for(var i=0; i<emails.length; i++){
                                var re = new RegExp(emails[i],"gi");
                                if (e.match(re)){
                                  $jq(".register-notice").css("visibility", "hidden");
                                  $jq("input#confirm").attr("value", 1);
                                  return;
                                }
                              }
                            }else{
                              linkAccount.attr("disabled", 1);
                            }
                            $jq(".register-notice").html("<span id='fade'>" +  data.message + "</span>").css("visibility", "visible");

                          }
                      },
                    error: function(request,status,error) {
                        alert(request + " " + status + " " + error );
                      }
                });
                $jq(this).parent().parent().addClass("ui-state-highlight");
                return false;
            });
          });
      }
    }
    
    
    
    function widgetInit(){
      var widgetHolder = $jq("#widget-holder"),
          widgets = $jq("#widgets"),
          listLayouts = $jq(".list-layouts"),
          layout;
      if(widgetHolder.size()==0){return;}
      
      window.onhashchange = readHash;
      if(location.hash.length > 0){
        readHash();
      }else if(layout = widgetHolder.data("layout")){
        resetPageLayout(layout);
      }
      
      if(listLayouts.size()>0){ajaxGet(listLayouts, "/rest/layout_list/" + listLayouts.attr("type"));}
      
      // used in sidebar view, to open and close widgets when selected
      widgets.find(".module-load, .module-close").click(function() {
        var widget_name = $jq(this).attr("wname"),
            nav = $jq("#nav-" + widget_name),
            content = "div#" + widget_name + "-content";
        if(!nav.hasClass('ui-selected')){
          if($jq(content).text().length < 4){
              var column = ".left";
              if(getLeftWidth(widgetHolder) >= 90){
                if(widgetHolder.children(".right").children(".visible").height()){
                  column = ".right";
                }
              }else{
                var leftHeight = parseFloat(widgetHolder.children(".left").css("height")),
                    rightHeight = parseFloat(widgetHolder.children(".right").css("height"));
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
      
     
      Scrolling.sidebarInit();
      
      widgetHolder.children("#widget-header").disableSelection();

      widgetHolder.find(".module-max").click(function() {
        var module = $jq(this).parents(".widget-container"),
    //     if(module.find(".cboxElement").trigger('click').size() < 1){
            clone = module.clone(),
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
          popout = window.open("", "test", "height=" + module.height() + ",width=" + module.width());
        popout.document.write(document.head.innerHTML);
        popout.document.write(clone.html());
      });

      // used in sidebar view, to open and close widgets when selected
      widgets.find(".module-load, .module-close").bind('open',function() {
        var widget_name = $jq(this).attr("wname"),
            nav = $jq("#nav-" + widget_name),
            content = "div#" + widget_name + "-content";

        openWidget(widget_name, nav, content, ".left");
        return false;
      });
      
      widgetHolder.find(".module-min").click(function() {
        var module = $jq("#" + $jq(this).attr("wname") + "-content"),
            button = $jq(this);
        module.next().slideToggle("fast");
        module.slideToggle("fast");
        button.parent().toggleClass("minimized");
        if (button.attr("show") != 1){
          button.attr("show", 1).attr("title", "maximize");
          button.removeClass("ui-icon-circle-triangle-s").removeClass("ui-icon-triangle-1-s");
          button.addClass("ui-icon-circle-triangle-e");
        }else{
          button.attr("show", 0).attr("title", "minimize");
          button.removeClass("ui-icon-circle-triangle-e");
          button.addClass("ui-icon-circle-triangle-s");
        }
      });
      
      widgetHolder.find(".reload").click(function() {
        reloadWidget($jq(this).attr("wname"));
      });
      
      $jq(".feed").click(function() {
        var url=$jq(this).attr("rel");
        var div=$jq(this).parent().next("#widget-feed");
        div.filter(":hidden").empty().load(url);
        div.slideToggle('fast');
      });
    }
    
    

    
    
    function effects(){
      var content = $jq("#content");
      $jq("body").delegate(".toggle", 'click', function(){
            $jq(this).toggleClass("active").next().slideToggle("fast", function(){
            if($jq.colorbox){ $jq.colorbox.resize(); }
            });
            return false;
      });
        
      content.delegate(".tooltip", 'mouseover', function(){
          var tip = $jq(this);
          getCluetip(function(){
            tip.cluetip({
              activation: 'click',
              sticky: true, 
              cluetipClass: 'jtip',
              dropShadow: false, 
              closePosition: 'title',
              arrows: true, 
              hoverIntent: false,
              });
            });
      });
      content.delegate(".text-min", 'click', function(){ expand($jq(this), $jq(this).next());});
      content.delegate(".more", 'click', function(){ expand($jq(this).prev(), $jq(this));});
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
      content.delegate(".text-min", 'mouseover mouseout', function(){ 
        $jq(this).next().toggleClass('opaque');
      });
      
      
      
      content.delegate(".tip-simple", 'mouseover', function(){ 
        if(!($jq(this).children("div.tip-elem").show().children('span:not(".ui-icon")').text($jq(this).attr("tip")).size())){
          var tip = $jq('<div class="tip-elem tip ui-corner-all" style="display:block"><span>' + $jq(this).attr("tip") + '</span><span class="tip-elem ui-icon ui-icon-triangle-1-s"></span></div>');
          tip.appendTo($jq(this)).show();
        }
      });
      content.delegate(".tip-simple", 'mouseout', function(){ 
        $jq(this).children("div.tip-elem").hide();
      });
      
      content.delegate(".slink", 'mouseover', function(){
          var slink = $jq(this);
          getColorbox(function(){
            slink.colorbox({data: slink.attr("href"), 
                            width: "750px", 
                            height: "550px",
                            title: function(){ return slink.prev().text() + " sequence"; }});
          });
      });
      
      content.delegate(".bench-update", 'click', function(){
        var wbid     = $jq(this).attr("wbid"),
            $class     = $jq(this).attr("objclass"),
            label     = $jq(this).attr("name"),
            obj_url  = $jq(this).attr("url"),
            is_obj  = $jq(this).attr("is_obj"),
            url     = $jq(this).attr("href") + '?name=' + escape(label) + "&class=" + $class + "&url=" + obj_url + "&is_obj=" + is_obj;
        $jq("#bench-status").load(url, function(){
          ajaxGet($jq(".workbench-status-" + wbid), "/rest/workbench/star?wbid=" + wbid + "&name=" + escape(label) + "&class=" + $class + "&url=" + obj_url + "&is_obj=" + is_obj, 1);
          $class != "paper" ? ajaxGet($jq("div#reports-content"), "/rest/widget/me/reports", 1) : ajaxGet($jq("div#my_library-content"), "/rest/widget/me/my_library", 1);
        });
      return false;
      });
    }
    

    function displayNotification (message){
        if(notifyTimer){
          clearTimeout(notifyTimer);
          notifyTimer = undefined;
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
        notifyTimer = undefined;
      }
      $jq(this).hide();
    });
    
    
       
   function systemMessage(action, messageId){
     var systemMessage = $jq(".system-message");
    if(action == 'show'){
      systemMessage.show().css("display", "block").animate({height:"20px"}, 'slow');
      $jq("#notifications").css("top", "20px");
      Scrolling.set_system_message(20); 
    }else{
      systemMessage.animate({height:"0px"}, 'slow', undefined,function(){ $jq(this).hide();});
      $jq.post("/rest/system_message/" + messageId);
      Scrolling.set_system_message(0); 
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
        var opTimer,
            opLoaded = false;
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
          if($jq(this).attr("rel")) {
            $jq.post("/rest/livechat?open=1",function() {
              location.href="/tools/operator";
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
          searchForm = $jq("#searchForm"),
          lastXhr;

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
      
      searchBox.autocomplete({
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





  function SearchResult(q, type, species, widget, nostar){
    var query = decodeURI(q),
        page = 1.0,
        total = 0,
        countSpan = $jq((widget ? "." + widget + "-widget " : '') + "#count"),
        resultDiv = $jq((widget ? "." + widget + "-widget " : '') + ".load-results"),
        queryList = query ? query.replace(/[,\.\*]/, ' ').split(' ') : [];

    this.setTotal = function(t){
    total = t;
    countSpan.html(total);
    }
    
    Scrolling.search;
    
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
      var url = $jq(this).attr("href") + (page + 1) + "?" + (species ? "species=" + species : '') + (widget ? "&widget=" + widget : '') + (nostar ? "&nostar=" + nostar : '');
          div = $jq("<div></div>"),
          res = $jq((widget ? "." + widget + "-widget" : '') + " #load-results");

      $jq(this).removeClass("load-results");
      page++;
      
      setLoading(div);
      
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
    var allSearch = $jq("#all-search-results");
    allSearch.empty(); 
    ajaxGet(allSearch, url);
    loadcount = 0;
    $jq(window).scrollTop(0);
    $jq("#navigation").find(".ui-selected").removeClass("ui-selected");
    Scrolling.resetSidebar();
    return false;
  }
  
  function allResults(type, species, query){
    var url = "/search/" + type + "/" + query + "/?inline=1",
        allSearch = $jq("#all-search-results");
    allSearch.empty(); 
    if(species) { url = url + "&species=" + species;} 
    ajaxGet(allSearch, url);

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
        var content = $jq(content),
            url     = nav.attr("href");
            
        content.closest("li").appendTo($jq("#widget-holder").children(column));
        addWidgetEffects(content.parent(".widget-container"));

        if(content.text().length < 4){
          ajaxGet(content, url);
        }
        nav.addClass("ui-selected");
        content.parents("li").addClass("visible");
        return false;
    }
    
    function reloadWidget(widget_name){
        var nav = $jq("#nav-" + widget_name),
            url = nav.attr("href");
        ajaxGet($jq("div#" + widget_name + "-content"), url);
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
    
    function columns(leftWidth, rightWidth, noUpdate){
      var widgetHolder = $jq("#widget-holder");
      if(leftWidth>99){
        widgetHolder.children(".sortable").css('min-height', '0');
      }else{
        widgetHolder.children(".sortable").css('min-height', '5em');
      }
      widgetHolder.children(".left").css("width",leftWidth + "%");
      if(rightWidth==0){rightWidth=100;}
      widgetHolder.children(".right").css("width",rightWidth + "%");
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
          var nodeList = data.childNodes[0].childNodes,
              len = nodeList.length;
          for(i=0; i<len; i++){
            var node = nodeList.item(i);
            if(node.nodeName == "data"){
              location.hash = node.attributes.getNamedItem('lstring').nodeValue;
            }
          }
        }, "xml");
    }
    
    function resetPageLayout(layout){
      layout = layout || $jq("#widget-holder").data("layout");
      if(layout['hash']){
          location.hash = layout['hash'];
      }else{
          resetLayout(layout['leftlist'], layout['rightlist'] || [], layout['leftwidth'] || 100);
          reloadLayout++;
          updateLayout();
      }
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
      var l = $jq.map(left, function(i) { return getWidgetID(i);}),
          r = $jq.map(right, function(i) { return getWidgetID(i);}),
          ret = l.join('') + "-" + r.join('') + "-" + (leftWidth/10);
      if(location.hash && decodeURI(location.hash).match(/^[#](.*)$/)[1] != ret){
        reloadLayout++;
      }
      location.hash = ret;
      return ret;
    }
    
    function readHash() {
      if(reloadLayout == 0){
        var h = decodeURI(location.hash).match(/^[#](.*)$/)[1].split('-');
        if(!h){ return; }
        
        var l = h[0],
            r = h[1],
            w = (h[2] * 10);
        
        if(l){ l = $jq.map(l.split(''), function(i) { return getWidgetName(i);}); }
        if(r){ r = $jq.map(r.split(''), function(i) { return getWidgetName(i);}); }
        resetLayout(l,r,w);
      }else{
        reloadLayout--;
      }
    }
    
    //get an ordered list of all the widgets as they appear in the sidebar.
    //only generate once, save for future
    var widgetList = this.wl || (function() {
        var instance = this,
            navigation = $jq("#navigation"),
            list = navigation.find(".module-load")
                  .map(function() { return this.getAttribute("wname");})
                  .get();
        this.wl = { list: list };
        return this.wl;
        })();
    
    //returns order of widget in widget list in radix (base 36) 0-9a-z
    function getWidgetID (widget_name) {
        return widgetList.list.indexOf(widget_name).toString(36);
    }
   
    function openAllWidgets(){
      var hash = "";
      for(i=0; i<(widgetList.list.length-3); i++){
        hash = hash + (i.toString(36));
      }
      window.location.hash = hash + "--10";
      return false;
    }
    
    //returns widget name 
    function getWidgetName (widget_id) {
        return widgetList.list[parseInt(widget_id,36)];
    }

    function updateLayout(layout, callback){
      var holder =  $jq("#widget-holder"),
          $class = holder.attr("wclass"),
          left = holder.children(".left").children(".visible")
                            .map(function() { return this.id;})
                            .get(),
          right = holder.children(".right").children(".visible")
                            .map(function() { return this.id;})
                            .get(),
          leftWidth = getLeftWidth(holder),
          lstring = updateURLHash(left, right, leftWidth),
          l = 'default';
      if((typeof layout) == 'string'){
        l = escape(layout); 
      }
      $jq.post("/rest/layout/" + $class + "/" + l, { 'lstring':lstring }, function(){
        if(callback){ callback(); }
      });
    }

    function getLeftWidth(holder){
      var totWidth = parseFloat(holder.css("width")),
          leftWidth = (parseFloat(holder.children(".left").css("width"))/totWidth)*100;
      return Math.round(leftWidth); //if you don't round, the slightest change causes an update
    }

    function resetLayout(leftList, rightList, leftWidth){
      $jq("#navigation").find(".ui-selected").removeClass("ui-selected");
      $jq("#widget-holder").children().children("li").removeClass("visible");

      columns(leftWidth, (100-leftWidth), 1);
      for(var widget = 0; widget < leftList.length; widget++){
        var widget_name = $jq.trim(leftList[widget]);
        if(widget_name.length > 0){
          var nav = $jq("#nav-" + widget_name),
              content = "div#" + widget_name + "-content";
          openWidget(widget_name, nav, content, ".left");
        }
      }
      for(var widget = 0; widget < rightList.length; widget++){
        var widget_name = $jq.trim(rightList[widget]);
        if(widget_name.length > 0){
          var nav = $jq("#nav-" + widget_name),
              content = "div#" + widget_name + "-content";
          openWidget(widget_name, nav, content, ".right");
        }
      }
      if(location.hash.length > 0){
        updateLayout();
      }
    }




var Scrolling = (function(){
  var $window = $jq(window),
      system_message = 0,
      static = 0;// 1 = sidebar fixed position top of page. 0 = sidebar in standard pos
  
  function resetSidebar(){
    static = 0;
    $jq("#navigation").stop().css('position', 'relative').css('top', 0);
  }

  function sidebarInit(){
    var sidebar   = $jq("#navigation"),
        offset = sidebar.offset().top,
        widgetHolder = $jq("#widget-holder"),
        count = 0, //semaphore
        titles;
        
    sidebar.find(".title").click(function(){
      $jq(this).children(".ui-icon").toggleClass("ui-icon-triangle-1-s").toggleClass("ui-icon-triangle-1-e");
    }); 
    
    $window.scroll(function() {
      if(sidebar.offset()){
        var objSmallerThanWindow = sidebar.outerHeight() < ($window.height() - system_message),
            scrollTop = $window.scrollTop(),
            maxScroll = $jq(document).height() - (sidebar.outerHeight() + $jq("#footer").outerHeight() + system_message + 20); //the 20 is for padding before footer
          
        if (objSmallerThanWindow){
          if(static==0){
            if ((scrollTop > offset) && (scrollTop < maxScroll)) {
                sidebar.stop().css('position', 'fixed').css('top', system_message);
                static++;
            }else if(scrollTop > maxScroll){
                sidebar.stop().css('top', system_message - (scrollTop - maxScroll));
            }
          }else{
            if (scrollTop < offset) {
                sidebar.stop().css('position', 'relative').css('top', 0);
                static--;
            }else if(scrollTop > maxScroll){
                sidebar.stop().css('top', system_message - (scrollTop - maxScroll));
                static--;
            }
          }
        }else if(count==0 && (titles = sidebar.find(".ui-icon-triangle-1-s"))){ 
          // try to make the sidebar smaller
          if(sidebar.outerHeight() < widgetHolder.height()){
            //close lowest section. delay for animation. Add counting semaphore to lock
            count++;
            titles.last().parent().click().delay(250).queue(function(){ count--; });
          }else{
            sidebar.stop().css('position', 'relative').css('top', 0);
          }
        }
      } 
    });
  }
  
  var search = search || (function searchInit(){
      $window.scroll(function() {
        var results    = $jq("#results.lazyload-widget"); 

        if(results.offset() && loadcount < 3){
          var rHeight = results.height() + results.offset().top;
          var rBottomPos = rHeight - ($window.height() + $window.scrollTop())
          if(rBottomPos < 400) {
            results.children(".load-results").trigger('click');
          }
        }
      });
      return true;
    })();
  
  function set_system_message(val){
    system_message = val;
  }
  
  return{
    sidebarInit:sidebarInit,
    search:search,
    set_system_message:set_system_message, 
    resetSidebar:resetSidebar
  }
})();

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
  
  
  
  function validate_fields(email,username, password, confirm_password, wbemail){
      if( (email.val() =="") && (!wbemail || wbemail.val() == "")){
                email.focus().addClass("ui-state-error");return false;
      } else if( email.val() && (validate_email(email.val(),"Not a valid email address!")==false)) {
                email.focus().addClass("ui-state-error");return false;
      } else if(password) {
          if( password.val() ==""){
                password.focus().addClass("ui-state-error");return false;
          } else if( confirm_password && (password.val() != confirm_password.val())) {
              alert("The passwords do not match. Please enter again"); password.focus().addClass("ui-state-error");return false;
          }  
      } else if( username && username.val() =="") {
                username.focus().addClass("ui-state-error"); return false;
      }  else {
        return true;
      }
  }

  function validate_email(field,alerttxt){
    var apos=field.indexOf("@"),
        dotpos=field.lastIndexOf(".");
    if (apos<1||dotpos-apos<2)
      {alert(alerttxt);return false;}
    else {return true;}
  } 
  
  
  var comment = {
    init: function(pageInfo){
      comment.url = pageInfo['ref'];
    },
    submit: function(cm){
        var feed = cm.closest('#comment-new'),
            content = feed.find(".comment-content").val();
        if(content == "" || content == "write a comment..."){
            alert("Please provide your name & comment"); return false;
        }
        $jq.ajax({
          type: 'POST',
          url: '/rest/feed/comment',
          data: { content: content, url: comment.url},
          success: function(data){
            displayNotification("Comment Submitted!");
            feed.find("#comment-box").prepend(data);
            feed.find(".comment-content").val("write a comment...");
            updateCounts(url);
              },
          error: function(request,status,error) {
                alert(request + " " + status + " " + error);
              }
        });
        var box = $jq('<div class="comment-box"><a href="/me">' + name + '</a> ' + content + '<br /><span id="fade">just now</span></div>');
        var comments = $jq("#comments");
        comments.prepend(box);
        return false;
    },
    cmDelete: function(cm){
       var $id=cm.attr("id");
      var url= cm.attr("rel");
      
      $jq.ajax({
        type: "POST",
        url : url,
        data: {method:"delete",id:$id}, 
        success: function(data){
                      updateCounts(url);
          },
        error: function(request,status,error) {
            alert(request + " " + status + " " + error );
          }
      });
      cm.parent().remove(); 
    }
    
  }


  var issue = {
    init: function(pageInfo){
      issue.url = pageInfo['ref'];
    },
   submit:function(is){
        var rel= is.attr("rel"),
            url = is.attr("url"),
            page= is.attr("page"),
            feed = is.closest('#issues-new'),
            email = feed.find("#email"),
            username= feed.find("#display-name"),
            is_private = feed.find("#isprivate:checked").size();
        if(email.attr('id') && username.attr('id')) {
           if(validate_fields(email,username)==false) {return false;}
        }  
        $jq.ajax({
          type: 'POST',
          url: rel,
          data: {title:feed.find("#title").val(), 
                content: feed.find("#content").val(), 
                email:email.val() ,
                username:username.val() , 
                url:issue.url,
                isprivate:is_private},
          success: function(data){
                if(data==0) {
                   alert("The email address has already been registered! Please sign in."); 
                }else {
                  displayNotification("Problem Submitted! We will be in touch soon.");
                  feed.closest('#widget-feed').hide(); 
                              updateCounts(url);
                  reloadWidget('issue');
                }
              },
          error: function(request,status,error) {
                alert(request + " " + status + " " + error);
              }
        });

        return false;
   },
   isDelete: function(button){
      var url = button.attr("rel"),
          id = new Array();
      $jq(".issue-deletebox").filter(":checked").each(function(){
         id.push($jq(this).attr('name'));
      });
      var answer = confirm("Do you really want to delete these issues: #"+id.join(' #'));
      if(answer){
        $jq.ajax({
              type: "POST",
              url : url,
              data: {method:"delete",issues:id.join('_')}, 
              success: function(data){
                  window.location.reload(1);
                  updateCounts(url);
              },
              error: function(request,status,error) {
                  alert(request + " " + status + " " + error );
            }
          });
      } 
   },
   update: function(is, issue_id){
          var url= is.attr("rel"),
              thread = is.closest('#threads-new');
          $jq.ajax({
            type: 'POST',
            url: url,
            data: { content: $jq("textarea").val(),
                    issue:issue_id,
                    state:$jq("#issue_status option:selected").val(),
                    severity:$jq("#issue_severity option:selected").val(),
                    assigned_to:$jq("#issue_assigned_to option:selected").val()},
            success: function(data){
                      window.location.reload();  
                },
            error: function(request,status,error) {
    // I don't know why this always throws an error if everything goes well....
//                       alert(request + " " + status + " " + error);
                }
          });
        return false;
   }
  }


  var StaticWidgets = {
    update: function(widget_id, path){
        if(!widget_id){ widget_id = "0"; }
        var widget = $jq("li#static-widget-" + widget_id),
            widget_title = widget.find("input#widget_title").val(),
            widget_order = widget.find("input#widget-order").val(),
            widget_content = widget.find("textarea#widget_content").val();

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
      var widget_id = wname.split("-").pop(),
          w_content = $jq("#" + wname + "-content"),
          widget = w_content.parent(),
          edit_button = widget.find("a#edit-button");
      if(edit_button.hasClass("ui-state-highlight")){
        StaticWidgets.reload(widget_id);
      }else{
        edit_button.addClass("ui-state-highlight");
        w_content.load("/rest/widget/static/" + widget_id + "?edit=1");
      }

    },
    reload: function(widget_id, rev_id, content_id){
      var w_content = $jq("#static-widget-" + widget_id + "-content"),
          widget = w_content.parent(),
          title = widget.find("h3 span.widget-title input"),
          url = "/rest/widget/static/" + (content_id || widget_id);
      if(title.size()>0){
        title.parent().html(title.val());
      }
      widget.find("a.button").removeClass("ui-state-highlight");
      $jq("#nav-static-widget-" + widget_id).text(title.val());
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
      var widget = $jq("#" + wname),
         history = widget.find("div#" + wname + "-history");
      if(history.size() > 0){
        history.toggle();
        widget.find("a#history-button").toggleClass("ui-state-highlight");
      }else{
        var widget_id = wname.split("-").pop(),
            history = $jq('<div id="' + wname + '-history"></div>'); 
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
      signin: function(box_id, onload) {
        var provider = providers[box_id];
        if (! provider) {
            return;
        }
        var pop_url = '/auth/popup?id='+box_id + '&url=' + provider['url']  + '&redirect=' + location;
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
    function getMarkItUp(callback){
      getPlugin("markitup", "/js/jquery/plugins/markitup/jquery.markitup.js", "/js/jquery/plugins/markitup/skins/markitup/style.css", function(){
      getPlugin("markitup-wiki", "/js/jquery/plugins/markitup/sets/wiki/set.js", "/js/jquery/plugins/markitup/sets/wiki/style.css", callback);
      });
      return;
    }
    function getColorbox(callback){
      getPlugin("colorbox", "/js/jquery/plugins/colorbox/colorbox/jquery.colorbox-min.js", "/js/jquery/plugins/colorbox/colorbox/colorbox.css", callback);
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
      goToAnchor: goToAnchor,
      systemMessage: systemMessage,
      Breadcrumbs: Breadcrumbs,
      setLoading: setLoading,
      SearchResult: SearchResult,
      resetLayout: resetLayout,
      openAllWidgets: openAllWidgets,
      deleteLayout: deleteLayout,
      columns: columns,
      setLayout: setLayout,
      resetPageLayout: resetPageLayout,
      search: search,
      search_change: search_change,
      loadResults: loadResults,
      openid: openid,
      validate_fields: validate_fields,
      StaticWidgets: StaticWidgets,
      recordOutboundLink: recordOutboundLink,
      comment: comment,
      issue: issue,
      getDataTables: getDataTables,
      getMarkItUp: getMarkItUp,
      getColorbox: getColorbox,
      effects: effects
    }
  })();




 $jq(document).ready(function() {
      $jq.ajaxSetup( {timeout: 6e4 }); //one minute timeout on ajax requests
      WB.init();
 });

 window.WB = WB;
 window.$jq = $jq;
}(this,document);
