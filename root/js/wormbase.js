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
        cur_search_species_type = '',
        reloadLayout = 0, //keeps track of whether or not to reload the layout on hash change
        loadcount = 0;
    
    function init(){
      var pageInfo = $jq("#header").data("page"),
          searchAll = $jq("#all-search-results"),
          sysMessage = $jq("#top-system-message").children(".system-message-close"),
          history_on = (pageInfo['history'] == 1) ? 1 : undefined;

      if(history_on){
        $jq.post("/rest/history", { 'ref': pageInfo['ref'] , 'name' : pageInfo['name'], 'id':pageInfo['id'], 'class':pageInfo['class'], 'type': pageInfo['type'], 'is_obj': pageInfo['is_obj'] });
      }
      
      if($jq(".user-history").size()>0){
        histUpdate(history_on);
      }
      

      search_change(pageInfo['class']);
      if(sysMessage.size()>0) {systemMessage('show'); sysMessage.click(function(){ systemMessage('hide', sysMessage.data("id")); });}

      comment.init(pageInfo);
      issue.init(pageInfo);
        
      if($jq(".star-status-" + pageInfo['wbid']).size()>0){$jq(".star-status-" + pageInfo['wbid']).load("/rest/workbench/star?wbid=" + pageInfo['wbid'] + "&name=" + pageInfo['name'] + "&class=" + pageInfo['class'] + "&type=" + pageInfo['type'] + "&id=" + pageInfo['id'] + "&url=" + pageInfo['ref'] + "&save_to=" + pageInfo['save'] + "&is_obj=" + pageInfo['is_obj']);}

      updateCounts(pageInfo['ref']);
      if(pageInfo['notify']){ displayNotification(pageInfo['notify']); }
      
      navBarInit();
      pageInit();
      if(searchAll.size()>0) { 
        var searchInfo = searchAll.data("search");
        allResults(searchInfo['type'], searchInfo['species'], searchInfo['query']);
      } else {
        widgetInit();
      }
      effects();
    }
    
    
    function histUpdate(history_on){
      var uhc = $jq("#user_history-content");
      
      ajaxGet($jq(".user-history"), "/rest/history?sidebar=1");
      if(uhc.size()>0 && uhc.text().length > 4) ajaxGet(uhc, "/rest/history");
      if(history_on){
        setTimeout(histUpdate, 6e5); //update the history every 10min
      }
      reloadWidget('activity');
      return;
    }
   

    function navBarInit(){
      searchInit();
      $jq("#nav-bar").find("ul li").hover(function () {
          var navItem = $jq(this);
          $jq("div.columns>ul").hide();
          if(timer){
            navItem.siblings("li").children("ul.wb-dropdown").hide();
            navItem.siblings("li").children("a").removeClass("hover");
            navItem.children("ul.wb-dropdown").find("a").removeClass("hover");
            navItem.children("ul.wb-dropdown").find("ul.wb-dropdown").hide();
            clearTimeout(timer);
            timer = undefined;
          }
          navItem.children("ul.wb-dropdown").show();
          navItem.children("a").addClass("hover");
        }, function () {
          var toHide = $jq(this);
          if(timer){
            clearTimeout(timer);
            timer = undefined;
          }
          timer = setTimeout(function() {
                toHide.children("ul.wb-dropdown").hide();
                toHide.children("a").removeClass("hover");
              }, 300)
        });
        
        ajaxGet($jq(".status-bar"), "/rest/auth", undefined, function(){
          $jq("#bench-status").load("/rest/workbench");
          var login = $jq("#login");
          if(login.size() > 0){
            login.click(function(){
              $jq(this).toggleClass("open ui-corner-top").siblings().toggle();
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
          Scrolling.goToAnchor(section);
      });

      if($jq(".sortable").size()>0){
        $jq(".sortable").sortable({
          handle: '.widget-header, #widget-footer',
          items:'li.widget',
          placeholder: 'placeholder',
          connectWith: '.sortable',
          opacity: 0.6,
          forcePlaceholderSize: true,
          update: function(event, ui) { Layout.updateLayout(); },
        });
      }
      
      
      colDropdown.hover(function () {
          if(timer){
            $jq("#nav-bar").find("ul li .hover").removeClass("hover");
            $jq("#nav-bar").find("ul.wb-dropdown").hide();
            clearTimeout(timer);
            timer = undefined;
          }
          colDropdown.children("ul").show();
        }, function () {
          if(timer){
            clearTimeout(timer);
            timer = undefined;
          }
          if(colDropdown.find("#layout-input:focus").size() == 0){
            timer = setTimeout(function() {
                  colDropdown.children("ul").hide();
                }, 300)
          }else{
            colDropdown.find("#layout-input").blur(function(){
              timer = setTimeout(function() {
                  colDropdown.children("ul").hide();
                }, 600)
            });
          }
        });

      $jq("#nav-min").click(function() {
        var nav = $jq(".navigation-min").add("#navigation"),
            ptitle = $jq("#page-title"),
            w = nav.width(),
            msg = "open sidebar",
            marginLeft = '-1em';
        if(w == 0){ w = '12em'; msg = "close sidebar"; marginLeft = 175; }else { w = 0;}
        nav.animate({width: w}).show().children("#title").children("div").toggle();
        ptitle.animate({marginLeft: marginLeft}).show();
        $jq(this).attr("title", msg).children("#nav-min-icon").toggleClass("ui-icon-triangle-1-w").toggleClass("ui-icon-triangle-1-e");
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
      if(widgetHolder.size()==0){
        $jq("#content").addClass("bare-page");
        return;
      }
      Scrolling.sidebarInit();
            
      window.onhashchange = Layout.readHash;
      window.onresize = Layout.resize;
      Layout.Breadcrumbs.init();
      if(location.hash.length > 0){
        Layout.readHash();
      }else if(layout = widgetHolder.data("layout")){
        Layout.resetPageLayout(layout);
      }else{
        Layout.openAllWidgets();
      }
      
//       if(listLayouts.children().size()==0){ajaxGet(listLayouts, "/rest/layout_list/"  + $jq(".list-layouts").data("class") + "?section=" + $jq(".list-layouts").data("section"));}
      
      // used in sidebar view, to open and close widgets when selected
      widgets.find(".module-load, .module-close").click(function() {
        var widget_name = $jq(this).attr("wname"),
            nav = $jq("#nav-" + widget_name),
            content = $jq("#" + widget_name + "-content");
        if(!nav.hasClass('ui-selected')){
          if(content.text().length < 4){
              var column = ".left",
                  lWidth = Layout.getLeftWidth(widgetHolder);
              if(lWidth >= 90){
                if(widgetHolder.children(".right").children(".visible").height()){
                  column = ".right";
                }
              }else{
                var leftHeight = height(widgetHolder.children(".left").children(".visible"));
                    rightHeight = height(widgetHolder.children(".right").children(".visible"));
                if (rightHeight < leftHeight){ column = ".right"; }
              }
              openWidget(widget_name, nav, content, column);
          }else{
            content.parents("li").addClass("visible");
            nav.addClass("ui-selected");
            moduleMin(content.prev().find(".module-min"), false, "maximize");
          }
          Scrolling.goToAnchor(widget_name);
          Layout.updateLayout();
        } else {
          Scrolling.scrollUp(content.parents("li"));
          moduleMin(content.prev().find(".module-min"), false, "minimize", function(){
            nav.removeClass("ui-selected");
            content.parents("li").removeClass("visible"); 
            Layout.updateLayout();
          });
        }
        Scrolling.sidebarMove();
        return false;
      });
      
      
      function height(list){
        var len = 0; 
        for(var i=-1, l = list.length; i++<l;){ 
          len += list.eq(i).height();
        } 
        return len;
      }
      


      
     

      
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
            content = $jq("#" + widget_name + "-content");

        openWidget(widget_name, nav, content, ".left");
        return false;
      });
      
      widgetHolder.find(".module-min").click(function() {
        moduleMin($jq(this), true);
      });
      
      

      widgetHolder.find(".reload").click(function() {
        reloadWidget($jq(this).attr("wname"));
      });
      
      $jq(".feed").click(function() {
        var url=$jq(this).attr("rel"),
            div=$jq(this).parent().next("#widget-feed");
        div.filter(":hidden").empty().load(url);
        div.slideToggle('fast');
      });
    }
    
    function effects(){
      var content = $jq("#content");
      $jq("body").delegate(".toggle", 'click', function(){
            var tog = $jq(this);
            tog.toggleClass("active").next().slideToggle("fast", function(){
                if($jq.colorbox){ $jq.colorbox.resize(); }
                Scrolling.sidebarMove();
              });
            if(tog.hasClass("load-toggle")){
              ajaxGet(tog.next(), tog.attr("href"));
              tog.removeClass("load-toggle");
            }
            tog.children(".ui-icon").toggleClass("ui-icon-triangle-1-e ui-icon-triangle-1-s");
            return false;
      });

      content.delegate(".evidence", 'click', function(){
        var ev = $jq(this);
        ev.children(".ev-more").toggleClass('open').children('.ui-icon').toggleClass('ui-icon-triangle-1-s ui-icon-triangle-1-n');
        ev.children(".ev").toggle('fast');
      });
      
      content.delegate(".slink", 'mouseover', function(){
          var slink = $jq(this);
          Plugin.getPlugin("colorbox", function(){
            slink.colorbox({data: slink.attr("href"), 
                            width: "800px", 
                            height: "550px",
                            scrolling: false,
                           onComplete: function() {$jq.colorbox.resize(); },
                            title: function(){ return slink.next().text() + " " + slink.data("class"); }});
          });
      });
      
      content.delegate(".bench-update", 'click', function(){
        var update = $jq(this),
            wbid = update.attr("wbid"),
            save_to = update.attr("save_to"),
            url = update.attr("ref") + '?name=' + escape(update.attr("name")) + "&url=" + escape(update.attr("href")) + "&save_to=" + save_to + "&is_obj=" + update.attr("is_obj");
        $jq(".star-status-" + wbid).find("#save").toggleClass("ui-icon-star-yellow ui-icon-star-gray");
        $jq("#bench-status").load(url, function(){
          if($jq("div#" + save_to + "-content").text().length > 3){ 
            reloadWidget(save_to, 1);
          }
        });
        return false;
      });
      
      $jq("body").delegate(".generate-file-download", 'click', function(e){
          var filename = $jq(this).find("#filename").text(),
              content = $jq(this).find("#content").text();
          Plugin.getPlugin("generateFile", function(){
          $jq.generateFile({
              filename    : filename,
              content     : content,
              script      : '/rest/download'
          });
        });
      });     
      
    }
    
    function moduleMin(button, hover, direction, callback) {
      var module = $jq("#" + button.attr("wname") + "-content");
      
      if (direction && (button.attr("title") != direction) ){ if(callback){ callback()} return; }
      module.slideToggle("fast", function(){Scrolling.sidebarMove(); if(callback){ callback()}});
      button.toggleClass("ui-icon-triangle-1-s ui-icon-triangle-1-e").closest(".widget-container").toggleClass("minimized");
      if(hover)
        button.toggleClass("ui-icon-circle-triangle-e ui-icon-circle-triangle-s");
      (button.attr("title") != "maximize") ? button.attr("title", "maximize").addClass("show") : button.attr("title", "minimize").removeClass("show");
      
      module.find(".cyto_panel").each(function(index, domEle){
		  domEle.selectedIndex = 0;
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
            
        notification.click(function() {
          if(notifyTimer){
            clearTimeout(notifyTimer);
            notifyTimer = undefined;
          }
          $jq(this).hide();
        });
    }
    

       
   function systemMessage(action, messageId){
     var systemMessage = $jq(".system-message"),
         notifications = $jq("#notifications");
      if(action == 'show'){
//         systemMessage.show().css("display", "block").animate({height:"20px"}, 'slow');
        notifications.css("top", "20px");
        Scrolling.set_system_message(20); 
      }else{
        systemMessage.animate({height:"0px"}, 'slow', undefined,function(){ $jq(this).hide();});
        $jq.post("/rest/system_message/" + messageId);
        Scrolling.set_system_message(0); 
        notifications.css("top", "0");
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
        error:function(xhr, textStatus, thrownError){
          var error = $jq(xhr.responseText).find(".error-message-technical").html() || '';
          ajaxPanel.html('<div class="ui-state-error ui-corner-all"><p><strong>Sorry!</strong> An error has occured.</p>'
                  + '<p><a href="/tools/support?url=' + location.pathname 
                  + (error ? '&msg=' + encodeURIComponent(error.trim()) : '')
                  + '">Let us know</a></p><p>' + error + '</p></div>');
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
            ajaxGet($jq("#operator-box"), "/rest/livechat", 0);
            opLoaded = true;
          }
          (opBox.hasClass("minimize")) ? opBox.animate({width:"9em"}).children().show() : opBox.animate({width:"1.5em"}).children().hide();
          opBox.toggleClass("minimize");
        });
        
        $jq('.operator').click(function() { 
          if($jq(this).attr("rel")) {
            $jq.post("/rest/livechat?open=1",function() {
              location.href="/tools/operator";
            });
          }else {
            var opBox = $jq("#operator-box");
            ajaxGet(opBox, "/rest/livechat", 0);
            opLoaded = true;
            if(opBox.hasClass("minimize"))
                opBox.removeClass("minimize").animate({width:"9em"}).children().show();
            opTimer = setTimeout(function() {
              opBox.addClass("minimize").animate({width:"1.5em"}).children().hide();
            }, 4e3)
          }
        }); 
        
        $jq("#issue-box").click(function(){
          var isBox = $jq(this);
          isBox.toggleClass("minimize").children().toggle();
          isBox.animate({width: (isBox.hasClass("minimize")) ? "1em" : "14em"})
        });
    }
    
  function hideTextOnFocus(selector){
    var area = $jq(selector);
      
    if(area.attr("value") != ""){
      area.siblings(".holder").fadeOut();
    }
    area.focus(function(){
      $jq(this).siblings(".holder").fadeOut();
    });

    area.blur(function(){
      if($jq(this).attr("value") == ""){
        $jq(this).siblings(".holder").fadeIn();
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
          minLength: 3,
          select: function( event, ui ) {
              location.href = ui.item.url;
          }
      });
      
    
    }


    
    function search(box) {
        if(!box){ box = "Search"; }else{ cur_search_type = cur_search_type || 'all'; } 
        var f = $jq("#" + box).attr("value");
        if(f == "search..." || !f){
          f = "";
        }

        f = encodeURIComponent(f.trim());
        f = f.replace('%26', '&');
        f = f.replace('%2F', '/');

        location.href = '/search/' + cur_search_type + '/' + f + (cur_search_species_type ? '?species=' + cur_search_species_type : '');
    }

    function search_change(new_search) {
      if(!new_search) { new_search = 'gene';}
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
      
      $jq(".current-search").text(new_search);
    }
    
    
    function search_species_change(new_search) {
      cur_search_species_type = new_search;
      if(new_search == "all"){
      new_search = "all species";
      }else{
        new_search = new_search.charAt(0).toUpperCase() + new_search.slice(1);
        new_search = new_search.replace(/[_]/, '. ');
      }
      $jq(".current-species-search").text(new_search);
    }



  function checkSearch(div){
    var results = div.find("#results"),
        searchData = (results.size() > 0) ? results.data("search") : undefined;
    if(!searchData){ formatExpand(results); return; }
    SearchResult(searchData['query'], searchData["type"], searchData["species"], searchData["widget"], searchData["nostar"], searchData["count"], div);  
  }
  
  function formatExpand(div){
      var expands = div.find(".text-min");
      for(var i=-1, el, l = expands.size(); ((el = expands.eq(++i)) && i < l);){
        if (el.height() > 35){
          el.html('<div class="text-min-expand">' + el.html() + '</div><div class="more"><div class="ui-icon ui-icon-triangle-1-s"></div></div>')
            .click(function(){
            var container = $jq(this),
                txt = container.children(".text-min-expand");
            txt.animate({height:(txt.height() < 40) ? '100%' : '2.4em'})
               .css("max-height", "none")
               .next().toggleClass('open').children()
               .toggleClass('ui-icon-triangle-1-s ui-icon-triangle-1-n');
            container.parent().find(".expand").toggleClass('ellipsis');
          });
        }
      }
  }

  function SearchResult(q, type, species, widget, nostar, t, container){
    var query = decodeURI(q),
        page = 1.0,
        total = t,
        countSpan = container.find("#count"),
        resultDiv = container.find((widget ? "." + widget + "-widget " : '') + ".load-results"),
        queryList = query ? query.replace(/[,\.\*]/, ' ').split(' ') : [];

    function init(){
      container.find("#results").find(".load-star").each(function(){
        $jq(this).load($jq(this).attr("href"));
      });
    }
    
    
    function formatResults(div){
      formatExpand(div);

      if(queryList.length == 0) { return; }
      Plugin.getPlugin("highlight", function(){
        for (var i=0; i<queryList.length; i++){
          if(queryList[i]) { div.highlight(queryList[i]); }
        }
      });
    }
    
    formatResults(container.find("div#results"));
    init();
    
    if(total > 10){
      if(container.find(".lazyload-widget").size() > 0){ Scrolling.search(); }
      resultDiv.click(function(){
        var url = $jq(this).attr("href") + (page + 1) + "?" + (species ? "species=" + species : '') + (widget ? "&widget=" + widget : '') + (nostar ? "&nostar=" + nostar : '');
            div = $jq("<div></div>"),
            res = $jq((widget ? "." + widget + "-widget" : '') + " #load-results");

        $jq(this).removeClass("load-results");
        page++;
        
        setLoading(div);
        
        res.html("loading...");
        div.load(url, function(response, status, xhr) {
          total = div.find("#page-count").data("count") || total;
          var left = total - (page*10);
          if(left > 0){
            if(left>10){left=10;}
            res.addClass("load-results");
            res.html("load " + left + " more results");
          }else{
            res.remove();
          }

          formatResults(div);

          if (status == "error") {
            var msg = "Sorry but there was an error: ";
            $jq(this).html(msg + xhr.status + " " + xhr.statusText);
          }
          Scrolling.sidebarMove();
          
          div.find(".load-star").each(function(){
            $jq(this).load($jq(this).attr("href"));
          });

          countSpan.html(total);
        });

        div.appendTo($jq(this).parent().children("ul"));
        loadcount++;
        Scrolling.sidebarMove();
      });
    }
    
  } //end SearchResult

  function loadResults(url){
    var allSearch = $jq("#all-search-results");
    allSearch.empty(); 
    ajaxGet(allSearch, url, undefined, function(){
      checkSearch(allSearch);
    });
    loadcount = 0;
    if(!allSearch.hasClass("references"))
      scrollToTop();
    return false;
  }
  
  function scrollToTop(){
    $jq(window).scrollTop(0);
    Scrolling.resetSidebar();
    return undefined;
  }
  
  function allResults(type, species, query, widget){
    var url = "/search/" + type + "/" + query + "/?inline=1",
        allSearch = $jq("#all-search-results");
    if(!widget){
      Scrolling.sidebarInit();
      search_change(type);
    }
    if(species) { url = url + "&species=" + species;} 
    ajaxGet(allSearch, url, undefined, function(){
      checkSearch(allSearch);
    });

    $jq("#search-count-summary").find(".count").each(function() {
      $jq(this).load($jq(this).attr("href"), function(){
        if($jq(this).text() == '0'){
          $jq(this).parent().remove();
        }else {
          $jq(this).parent().show().parent().prev(".title").show();
        }
      });
    });
    
    $jq("#search-count-summary").find(".load-results").click(function(){
      var button = $jq(this);
      loadResults(button.attr("href"));
      button.addClass("ui-selected").siblings().removeClass("ui-selected").parent().siblings().find(".ui-selected").removeClass("ui-selected");
      $jq("#curr-ref-text").html(button.html());
      return false;
    });
    
    if (type == 'paper')
      Layout.resize();
    
  }


  function recordOutboundLink(link, category, action) {
    try {
      var pageTracker=_gat._createTracker("UA-16257183-1");
      pageTracker._trackEvent(category, action);
    }catch(err){}
  }

   
    function openWidget(widget_name, nav, content, column){
        var url     = nav.attr("href");
            
        content.closest("li").appendTo($jq("#widget-holder").children(column));

        if(content.text().length < 4){
          addWidgetEffects(content.parent(".widget-container"));
          ajaxGet(content, url, undefined, function(){ 
            Scrolling.sidebarMove();checkSearch(content);
          });
        }
        moduleMin(content.prev().find(".module-min"), false, "maximize");
        nav.addClass("ui-selected");
        content.parents("li").addClass("visible");
        return false;
    }
    
    function reloadWidget(widget_name, noLoad, url){
        var con = $jq("#" + widget_name + "-content");
        if(con.text().length > 4)
          ajaxGet(con, url || $jq("#nav-" + widget_name).attr("href"), noLoad, function(){ checkSearch(con); });
    }
    
      
  function addWidgetEffects(widget_container) {
      widget_container.find("div.module-min").hover(
        function () {
          var button = $jq(this);
          button.addClass((button.hasClass("show") ? "ui-icon-circle-triangle-e" : "ui-icon-circle-triangle-s"));
        }, 
        function () {
          var button = $jq(this);
          button.removeClass("ui-icon-circle-triangle-s ui-icon-circle-triangle-e").addClass((button.hasClass("show") ? "ui-icon-triangle-1-e" : "ui-icon-triangle-1-s"));
        }
      );

      widget_container.find("div.module-close").hover(
        function () {
          $jq(this).toggleClass("ui-icon-circle-close ui-icon-close");
        }
      );
  }
    
    
var Layout = (function(){
  var sColumns = false,
      ref = $jq("#references-content"),
      wHolder = $jq("#widget-holder"),
      maxWidth = (location.pathname == '/' || location.pathname == '/me') ? 900 : 1300; //home page? allow narrower columns
    //get an ordered list of all the widgets as they appear in the sidebar.
    //only generate once, save for future
      widgetList = this.wl || (function() {
        var instance = this,
            navigation = $jq("#navigation"),
            list = navigation.find(".module-load")
                  .map(function() { return this.getAttribute("wname");})
                  .get();
        this.wl = { list: list };
        return this.wl;
        })();
      
    function resize(){
      if(sColumns != (sColumns = (document.documentElement.clientWidth < maxWidth))){
        sColumns ? columns(100, 100) : readHash();
        if(multCol = $jq("#column-dropdown").find(".multCol")) multCol.toggleClass("ui-state-disabled");
      }
      if ((maxWidth > 1000) && 
          wHolder.children(".sortable").hasClass("table-columns") && 
        ((wHolder.children(".left").width() + wHolder.children(".right").width()) > 
        (wHolder.outerWidth() + 150)))
        columns(100, 100);
      if(ref && (ref.hasClass("widget-narrow") != (ref.innerWidth() < 845)))
        ref.toggleClass("widget-narrow");
    }
    
    function columns(leftWidth, rightWidth, noUpdate){
      var sortable = wHolder.children(".sortable"),
          tWidth = wHolder.innerWidth(),
          leftWidth = sColumns ? 100 : leftWidth;
      if(leftWidth>95){
        wHolder.removeClass('table-columns').addClass('one-column');
        rightWidth = leftWidth = 100;
      }else{
        wHolder.addClass('table-columns').removeClass('one-column');
      }
      sortable.filter(".left").css("width",leftWidth + "%");
      sortable.filter(".right").css("width",rightWidth + "%");

      if(!noUpdate){ updateLayout(); }
    }

    function deleteLayout(layout){
      var $class = wHolder.attr("wclass");
      $jq.get("/rest/layout/" + $class + "/" + layout + "?delete=1");
      $jq("div.columns ul div li#layout-" + layout).remove();
    }

    function setLayout(layout){
      var $class = wHolder.attr("wclass");
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
      layout = layout || wHolder.data("layout");
      if(layout['hash']){
          location.hash = layout['hash'];
      }else{
          resetLayout(layout['leftlist'], layout['rightlist'] || [], layout['leftwidth'] || 100);
          reloadLayout++;
          updateLayout();
      }
    }


    function newLayout(layout){
      updateLayout(layout, undefined, function() {
        $jq(".list-layouts").load("/rest/layout_list/" + $jq(".list-layouts").data("class") + "?section=" + $jq(".list-layouts").data("section"), function(response, status, xhr) {
            if (status == "error") {
                var msg = "Sorry but there was an error: ";
                $jq(".list-layouts").html(msg + xhr.status + " " + xhr.statusText);
              }
            });
          });
      if(timer){
        clearTimeout(timer);
        timer = undefined;
      }
      timer = setTimeout(function() {
          $jq("#column-dropdown").children("ul").hide();
       }, 700)
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
        var hash = location.hash,
            arr,
            h = (arr = decodeURI(hash).match(/^[#](.*)$/)) ? arr[1].split('-') : undefined;
        if(!h){ return; }
        
        var l = h[0],
            r = h[1],
            w = (h[2] * 10);
        
        if(l){ l = $jq.map(l.split(''), function(i) { return getWidgetName(i);}); }
        if(r){ r = $jq.map(r.split(''), function(i) { return getWidgetName(i);}); }
        resetLayout(l,r,w,hash);
      }else{
        reloadLayout--;
      }
    }
    

    
    //returns order of widget in widget list in radix (base 36) 0-9a-z
    function getWidgetID (widget_name) {
        return widgetList.list.indexOf(widget_name).toString(36);
    }
   
    function openAllWidgets(){
      var hash = "",
          wlen = $jq("#navigation").find("li.module-load:not(.tools,.me,.toggle)").size();
      if(widgetList.list.length == 0){ return; }
      for(i=0; i<wlen; i++){
        hash = hash + (i.toString(36));
      }
      window.location.hash = hash + "--10";
      return false;
    }
    
    //returns widget name 
    function getWidgetName (widget_id) {
        return widgetList.list[parseInt(widget_id,36)];
    }

    function updateLayout(layout, hash, callback){
      var $class = wHolder.attr("wclass"),
          lstring = hash || readLayout(wHolder),
          l = ((typeof layout) == 'string') ? escape(layout) : 'default';
      $jq.post("/rest/layout/" + $class + "/" + l, { 'lstring':lstring }, function(){
      Layout.resize();
      if(callback){ callback(); }
      });
    }
    
    function readLayout(holder){
      var left = holder.children(".left").children(".visible")
                      .map(function() { return this.id;})
                      .get(),
          right = holder.children(".right").children(".visible")
                      .map(function() { return this.id;})
                      .get(),
          leftWidth = getLeftWidth(holder);
      return updateURLHash(left, right, leftWidth);
    }

    function getLeftWidth(holder){
      var leftWidth = sColumns ?  ((decodeURI(location.hash).match(/^[#](.*)$/)[1].split('-')[2]) * 10): (parseFloat(holder.children(".left").outerWidth())/(parseFloat(holder.outerWidth())))*100;
      return Math.round(leftWidth/10) * 10; //if you don't round, the slightest change causes an update
    }

    function resetLayout(leftList, rightList, leftWidth, hash){
      $jq("#navigation").find(".ui-selected").removeClass("ui-selected");
      $jq("#widget-holder").children().children("li").removeClass("visible");

      columns(leftWidth, (100-leftWidth), 1);
      for(var widget = 0, l = leftList ? leftList.length : 0; widget < l; widget++){
        var widget_name = $jq.trim(leftList[widget]);
        if(widget_name.length > 0){
          var nav = $jq("#nav-" + widget_name),
              content = $jq("#" + widget_name + "-content");
          openWidget(widget_name, nav, content, ".left");
        }
      }
      for(var widget = 0, l = rightList ? rightList.length : 0; widget < l; widget++){
        var widget_name = $jq.trim(rightList[widget]);
        if(widget_name.length > 0){
          var nav = $jq("#nav-" + widget_name),
              content = $jq("#" + widget_name + "-content");
          openWidget(widget_name, nav, content, ".right");
        }
      }
      if(location.hash.length > 0){
        updateLayout(undefined, hash);
      }
    }
    
    
    

  var Breadcrumbs = (function(){
    var bc = $jq("#breadcrumbs"),
        bExp = false,
        hiddenContainer,
        bWidth,
        bCount;
        
    function init() {
      if (!bc || ((bCount = bc.children().size()) < 3)) { return; }
      var children = bc.children(),        
          hidden = children.slice(0, (bCount - 2)),
          shown = children.slice((bCount - 2)),
          expand;
      bc.empty();
      hiddenContainer = $jq('<span id="breadcrumbs-hide"></span>');
      hiddenContainer.append(hidden).children().after(' &raquo; ');

      bc.append('<span id="breadcrumbs-expand" class="ui-icon-large ui-icon-triangle-1-e tl" tip="exapand"></span>').append(hiddenContainer).append(shown);
      bc.children(':last').addClass("page-title").before(" &raquo; ");
    
      expand = $jq("#breadcrumbs-expand");
      expand.click( function(){
        (bExp = !bExp) ? show($jq(this)) : hide($jq(this));
      });
      bWidth = hiddenContainer.width();
      hide(expand);
    }
    
    function show(expand){
      hiddenContainer.animate({width:bWidth}, function(){ hiddenContainer.css("width", "auto");}).css("visibility", 'visible');
      expand.attr("tip", "minimize").removeClass("ui-icon-triangle-1-e").addClass("ui-icon-triangle-1-w");
    }
    
    function hide(expand){
      hiddenContainer.animate({width:0}, function(){ hiddenContainer.css("visibility", 'hidden');});     
      expand.attr("tip", "expand").removeClass("ui-icon-triangle-1-w").addClass("ui-icon-triangle-1-e");
    }
    
    return {
     init: init
    }
  })();
    
  return {
      resize: resize,
      deleteLayout: deleteLayout,
      columns: columns,
      openAllWidgets: openAllWidgets,
      resetLayout: resetLayout,
      setLayout: setLayout,
      resetPageLayout: resetPageLayout,
      readHash: readHash,
      getLeftWidth: getLeftWidth,
      updateLayout: updateLayout,
      Breadcrumbs: Breadcrumbs,
      newLayout: newLayout
  }
})();



var Scrolling = (function(){
  var $window = $jq(window),
      system_message = 0,
      static = 0,// 1 = sidebar fixed position top of page. 0 = sidebar in standard pos
      footerHeight = $jq("#footer").outerHeight(),
      sidebar,
      offset,
      widgetHolder,
      body = $jq('html,body'),
      scrollingDown = 0,
      count = 0, //semaphore
      titles;
                 
  function resetSidebar(){
    static = 0;
    sidebar.stop().css('position', 'relative').css('top', 0);
  }
  
  function goToAnchor(anchor){
      var elem = document.getElementById(anchor),
          scroll = isScrolledIntoView(elem) ? undefined : $jq(elem).offset().top - system_message - 10;
      if(scroll){
        body.stop().animate({
          scrollTop: scroll
        }, 2000, function(){ Scrolling.sidebarMove(); scrollingDown = 0;});
        scrollingDown = (body.scrollTop() < scroll) ? 1 : 0;
      }
  }
  
  function scrollUp(elem){
    var elemBottom = $jq(elem).offset().top + $jq(elem).height(),
        docViewBottom = $window.scrollTop() + $window.height();
    if((elemBottom <= docViewBottom) ){ 
      body.stop().animate({
          scrollTop: $window.scrollTop() - elem.height() - 10
      }, "fast", function(){ Scrolling.sidebarMove(); });
    }
  }
    
  function isScrolledIntoView(elem){
      var docViewTop = $window.scrollTop(),
          docViewBottom = docViewTop + ($window.height()*0.75),
          elemTop = $jq(elem).offset().top,
          elemBottom = elemTop + $jq(elem).height();
      return ((elemBottom >= docViewTop) && (elemTop <= docViewBottom));
  }
  
  function sidebarMove() {
      if(!sidebar)
        return;
      if(sidebar.offset()){
        var objSmallerThanWindow = sidebar.outerHeight() < ($window.height() - system_message),
            scrollTop = $window.scrollTop(),
            maxScroll = $jq(document).height() - (sidebar.outerHeight() + footerHeight + system_message + 20); //the 20 is for padding before footer

        if(sidebar.outerHeight() > widgetHolder.height()){
            resetSidebar();
            return;
        }
        if (objSmallerThanWindow){
          if(static==0){
            if ((scrollTop >= offset) && (scrollTop <= maxScroll)){
                sidebar.stop().css('position', 'fixed').css('top', system_message);
                static = 1;
            }else if(scrollTop > maxScroll){
                sidebar.stop().css('position', 'fixed').css('top', system_message - (scrollTop - maxScroll));
            }else{
                resetSidebar();
            }
          }else{
            if (scrollTop < offset) {
                resetSidebar();
            }else if(scrollTop > maxScroll){
                sidebar.stop().css('position', 'fixed').css('top', system_message - (scrollTop - maxScroll));
                static = 0;
                if(scrollingDown == 1){body.stop(); scrollingDown = 0; }
            } 
          }
        }else if(count==0 && (titles = sidebar.find(".ui-icon-triangle-1-s:not(.pcontent)"))){ 
          count++; //Add counting semaphore to lock
          //close lowest section. delay for animation. 
          titles.last().parent().click().delay(250).queue(function(){ count--; Scrolling.sidebarMove();});
        }else{
          resetSidebar();
        }
      } 
    }
  
  function sidebarInit(){
    sidebar   = $jq("#navigation");
    offset = sidebar.offset().top;
    widgetHolder = $jq("#widget-holder");
    
    $window.scroll(function() {
      Scrolling.sidebarMove();
    });
  }
  
  var search = function searchInit(){
      if(loadcount >= 6){ return; }
      $window.scroll(function() {
        var results    = $jq("#results");
        if(results.offset() && loadcount < 6){
          var rHeight = results.height() + results.offset().top;
          var rBottomPos = rHeight - ($window.height() + $window.scrollTop())
          if(rBottomPos < 400) {
            results.children(".load-results").trigger('click');
          }
        }
      });
    };
  
  function set_system_message(val){
    system_message = val;
  }
  
  return {
    sidebarInit:sidebarInit,
    search:search,
    set_system_message:set_system_message, 
    sidebarMove: sidebarMove,
    resetSidebar:resetSidebar,
    goToAnchor: goToAnchor,
    scrollUp: scrollUp
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
    if(comments.size() > 0)
      comments.load("/rest/feed/comment?count=1;url=" + url);
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
            feed = is.closest('#issues-new'),
            name = feed.find("#name"),
            dc = feed.find("#desc-content"),
            email = feed.find("#email");
        if (!validate_fields(email, name))
          return;
        $jq.ajax({
          type: 'POST',
          url: rel,
          data: {title:feed.find("#issue-title option:selected").val(), 
                content: feed.find("#issue-content").val() + (dc.length > 0 ? '<br />What were you doing?: <br />&nbsp;&nbsp;' + dc.val() : ''), 
                name: name.val(),
                email: email.val(),
                url: url || issue.url},
          success: function(data){
                if(data==0) {
                   alert("The email address has already been registered! Please sign in."); 
                }else {
                  var content = $jq("#content");
                  content.children().not("#spacer").remove();
                  content.prepend(data);
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
        history.load("/rest/widget/static/" + widget_id + "?history=1");
        widget.find("div.content").append(history);
        widget.find("a#history-button").addClass("ui-state-highlight");
      }
    }
  }
  
  
  function historyOn(action, value, callback){
    if(action == 'get'){
        Plugin.getPlugin("colorbox", function(){
            $jq(".history-logging").colorbox();
            if(callback) callback();
        });
    }else{
      $jq.post("/rest/history", { 'history_on': value }, function(){ if(callback) callback(); });
      histUpdate(value == 1 ? 1 : undefined);
      if($jq.colorbox) $jq.colorbox.close();
    }
  }
  
  function loadRSS(id, url){
    var container = $jq("#" + id);
    setLoading(container);
    Plugin.getPlugin("jGFeed", function(){
      $jq.jGFeed(url,
        function(feeds){
          // Check for errors
          if(!feeds){
            // there was an error
            return false;
          }
          var txt = '<div id="results"><ul>';
          for(var i=-1, entry; (entry = feeds.entries[++i]);){
            txt += '<div class="result"><li><div class="date" id="fade">' 
                + entry.publishedDate.substring(0, 16) + '</div>'
                + '<a href="' + entry.link + '">' + entry.title + '</a></li>'
                + '<div class="text-min">' + entry.content.replace(/(\<\/?p\>|\<br\>)/g, '') + '</div></div>';
          }
          txt += '</ul></div>';
          container.html(txt);
          formatExpand(container);
        }, 3);
    });
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
  
  

  
function setupCytoscape(data, types){
          var edgeColor = ["#08298A","#B40431","#FF8000", "#04B404","#8000FF", "#191007", "#73c6cd", "#92d17b", "#cC87AB4", "#e4e870" ,"#696D09"],
              edgeColorMapper = {
                attrName: "type",
                entries: []
              },
              edgeSourceArrowMapper = {
                attrName: "direction",
                entries: [ { attrValue: "Effector->Effected", value: "T" },]
              },
              edgeTargetArrowMapper = {
                attrName: "direction",
                entries: [ { attrValue: "Effector->Effected", value: "ARROW" },]
              },
        nodeShapeMapper = {
                attrName: "ntype",
                entries: [
            { attrValue: 'Sequence', value: "TRIANGLE" },
            { attrValue: 'PCR product', value: "HEXAGON" },
            { attrValue: 'CDS', value: "DIAMOND" },
            { attrValue: 'Gene', value: "OCTAGON" },
            { attrValue: 'Protein', value: "RECTANGLE" },
            { attrValue: 'Molecule', value: "PARALLELOGRAM" },
            { attrValue: 'Other', value: "ELLIPSE" },]
              },
              edgeWidthMapper = { attrName: "width",  minValue: 3, maxValue: 15, maxAttrValue: 15 },
              nodeColorMapper = { attrName: "number", minValue: "#04043D", maxValue: "#6FA2D9" },
              toolTipMapper = {
                attrName: "phenotype",
                entries:[{attrValue: "", value: "<b>${type}<br />${direction}<br />${source} --- ${target}<br />${width} citation(s)</b>"},]
              },
                // you could also use other formats (e.g. GraphML) or grab the network data via AJAX
              networ_json = {
                dataSchema: {
                  nodes: [{ name: "label", type: "string" },
                      { name: "number", type: "int" },
                      { name: "color", type: "string" },
                      { name: "ntype", type: "string" },
                      { name: "link", type: "string" },
                  ],
                      
                  edges: [ { name: "label", type: "string" },
                      { name: "type", type: "string" },
                      { name: "direction", type: "string" },
                      { name: "width", type: "int" },
                      { name: "phenotype", type: "string" },
                      { name: "nearby", type: "int" },
                      //{ name: "link", type: "string" },
                  ]
                },
                data: data,
              },
            // visual style we will use
              visual_style = {
                global: {
                backgroundColor: "#ffffff",
                tooltipDelay: 100
                },
                nodes: {
                shape: "OCTAGON",
                opacity: 0.7,
                borderWidth: 0,
                hoverGlowOpacity: 0.8,
                size: 30,
                tooltipText: "<b>${label} (${ntype})</b>",
                tooltipBackgroundColor: "#fafafa",
                shape: { discreteMapper: nodeShapeMapper },
                color: { continuousMapper: nodeColorMapper },
                hoverGlowColor: "#aae6ff",
                labelGlowOpacity: 1,
                labelHorizontalAnchor: "center",
                },
                edges: {
                width: { defaultValue: 0.5, continuousMapper: edgeWidthMapper },
                color: { defaultValue: "#999999", discreteMapper: edgeColorMapper },
                opacity:0.4,
                hoverOpacity: 1,
                sourceArrowShape: { defaultValue: "NONE", discreteMapper: edgeSourceArrowMapper },
                targetArrowShape: { defaultValue: "NONE", discreteMapper: edgeTargetArrowMapper },
                labelHorizontalAnchor: "center",
                label: { passthroughMapper: { attrName: "type" } },
                tooltipText: { defaultValue:"<b>${type}<br />${direction}<br />${source} --- ${target}<br />${phenotype}<br />${width} citation(s)</b>", discreteMapper: toolTipMapper },
                tooltipBackgroundColor: "#fafafa",
                }
              },
            
            // initialization options
              options = {
                // where you have the Cytoscape Web SWF
                swfPath: "/js/jquery/plugins/cytoscapeweb/swf/CytoscapeWeb",
                // where you have the Flash installer SWF
                flashInstallerPath: "/swf/playerProductInstall"
            };
            
          for(var i=-1, type; (type = types[++i]);){
            visual_style.edges.color.discreteMapper.entries[i] = { attrValue: type,  value: edgeColor[i] };
          }
          Plugin.getPlugin("cytoscape_web", function(){ 
            // init and draw
            var vis = new org.cytoscapeweb.Visualization("cytoscapeweb", options);
            
            vis.draw({ network: networ_json, visualStyle: visual_style,  nodeTooltipsEnabled:true, edgeTooltipsEnabled:true, });
            vis.ready(function() {
        vis.filter("nodes", function(node) { return node.data.ntype == 'Gene' || node.data.ntype == 'Other' || node.data.ntype == 'Molecule'})
                // add a listener for when nodes and edges are clicked
                vis.addListener("click", "nodes", function(event) {
                window.open(event.target.data.link);
                });
              /* Should be disabled until interactions are merged
                vis.addListener("click", "edges", function(event) {
                window.open(event.target.data.link);
                }); */ 
            });
            
            $jq('.cyto_panel').change(function(){
                  var direction = $jq("#cyto_panel_direction option:selected").val();
                  var inter_type = $jq("#cyto_panel_type option:selected").val();
                  var nearby = $jq("#cyto_panel_nearby option:selected").val();
          var nodetype = $jq("#cyto_panel_nodetype option:selected").val();

          if(nodetype ==0){
              vis.removeFilter("nodes", true);
          } else {
              vis.filter("nodes", function(node) { return node.data.ntype == nodetype });
          }

                  if(direction ==0 && inter_type==0 && nearby==0){
                    //vis.removeFilter("edges",true);
                    vis.filter("edges", function(edge){return edge.data.type != "No_interaction"}, true);
                  }else{
                  vis.filter("edges", function(edge) {
                    if(direction !=0 && inter_type!=0 && nearby!=0) {
                        return edge.data.type == inter_type && edge.data.direction == direction && edge.data.nearby == 0;
                    }else if(direction !=0 && nearby!=0){
                        return edge.data.direction == direction && edge.data.nearby == 0  && edge.data.type != "No_interaction";
                    }else if(direction !=0 && inter_type!=0){
                        return edge.data.type == inter_type;
                    }else if(direction !=0){
                        return edge.data.direction == direction && edge.data.type != "No_interaction";
                    }else if(inter_type !=0 && nearby!=0){
                        return  edge.data.type == inter_type && edge.data.nearby == 0;
                    }else if(nearby != 0){
                        return edge.data.nearby == 0 && edge.data.type != "No_interaction";
                    }else{
                        return edge.data.type == inter_type;
                    }
                    }, true);
                  }
            });
            });
            $jq( "#resizable" ).resizable();
    }


    function getMarkItUp(callback){
      Plugin.getPlugin("markitup", function(){
        Plugin.getPlugin("markitup-wiki", callback);
      });
      return;
    }
    
    var Plugin = (function(){
      var plugins = new Array(),
          loading = false,
          pScripts = {  highlight: "/js/jquery/plugins/jquery.highlight-1.1.js",
                        dataTables: "/js/jquery/plugins/dataTables/media/js/jquery.dataTables.min.js",
                        colorbox: "/js/jquery/plugins/colorbox/colorbox/jquery.colorbox-min.js",
                        jGFeed:"/js/jquery/plugins/jGFeed/jquery.jgfeed-min.js",
                        generateFile: "/js/jquery/plugins/generateFile.js",
                        pfam: "/js/pfam/domain_graphics.min.js",
                        markitup: "/js/jquery/plugins/markitup/jquery.markitup.js",
                        "markitup-wiki": "/js/jquery/plugins/markitup/sets/wiki/set.js",
                        cytoscape_web: "/js/jquery/plugins/cytoscapeweb/js/min/cytoscapeweb_all.min.js",
          },
          pStyle = {    dataTables: "/js/jquery/plugins/dataTables/media/css/demo_table.css",
                        colorbox: "/js/jquery/plugins/colorbox/colorbox/colorbox.css",
                        markitup: "/js/jquery/plugins/markitup/skins/markitup/style.css",
                        "markitup-wiki": "/js/jquery/plugins/markitup/sets/wiki/style.css",
          };
          

      
      
      function getScript(name, url, stylesheet, callback) {
        
       function LoadJs(){
           loadFile(url, true, function(){
              plugins[name] = true;
              callback();
           });
        }
        
        if(stylesheet){
         loadFile(stylesheet, false, LoadJs());
        }else{
           LoadJs();
        }
      }
      
      
      function loadFile(url, js, callback) {
        var head = document.documentElement,
            script = document.createElement( js ? "script" : "link"),
            done = false;
        loading = true;
        
        if(js){
          script.src = url;
        }else{
          script.href = url;
          script.rel="stylesheet";
          script.type = "text/css";
        }
        
        function doneLoad(){
            done = true;
            loading = false;
            if(callback)
              callback();   
        }

        if(js){
          script.onload = script.onreadystatechange = function() {
          if(!done && (!this.readyState ||
            this.readyState === "loaded" || this.readyState === "complete")){
            doneLoad();
          
              script.onload = script.onreadystatechange = null;
              if( head && script.parentNode){
                head.removeChild( script );
              }
            }
          };
          
          
        }else{
          script.onload = function () {
            doneLoad();
          }
          // #2
          if (script.addEventListener) {
            script.addEventListener('load', function() {
            doneLoad();
            }, false);
          }
          // #3
          script.onreadystatechange = function() {
            var state = script.readyState;
            if (state === 'loaded' || state === 'complete') {
              script.onreadystatechange = null;
            doneLoad();
            }
          };

          // #4
          var cssnum = document.styleSheets.length;
          var ti = setInterval(function() {
            if (document.styleSheets.length > cssnum) {
              // needs more work when you load a bunch of CSS files quickly
              // e.g. loop from cssnum to the new length, looking
              // for the document.styleSheets[n].href === url
              // ...

              // FF changes the length prematurely  )
            doneLoad();
              clearInterval(ti);

            }
          }, 10);
        }
        
        head.insertBefore( script, head.firstChild);
        return undefined;
      }

      
      function getPlugin(name, callback){
        var script = pScripts[name],
            css = pStyle[name];
        loadPlugin(name, script, css, callback);
        return;
      }
      
      function loadPlugin(name, url, stylesheet, callback){
        if(!plugins[name]){
          getScript(name, url, stylesheet, callback);
        }else{
          if(loading){
            return setTimeout(getPlugin(name, url, stylesheet, callback),1);
          }
          callback(); 
        }
        return;
      }
      
      return {
        getPlugin: getPlugin
      };
    })();
    
    return{
      init: init,
      ajaxGet: ajaxGet,
      hideTextOnFocus: hideTextOnFocus,
      goToAnchor: Scrolling.goToAnchor,
      setLoading: setLoading,
      resetLayout: Layout.resetLayout,
      openAllWidgets: Layout.openAllWidgets,
      displayNotification: displayNotification,
      deleteLayout: Layout.deleteLayout,
      columns: Layout.columns,
      setLayout: Layout.setLayout,
      resetPageLayout: Layout.resetPageLayout,
      search: search,
      search_change: search_change,
      search_species_change: search_species_change,
      openid: openid,
      validate_fields: validate_fields,
      StaticWidgets: StaticWidgets,
      recordOutboundLink: recordOutboundLink,
      comment: comment,
      issue: issue,
      getMarkItUp: getMarkItUp,
      checkSearch: checkSearch,
      scrollToTop: scrollToTop,
      historyOn: historyOn,
      allResults: allResults,
      loadRSS: loadRSS,
      newLayout: Layout.newLayout,
      setupCytoscape: setupCytoscape,
      getPlugin: Plugin.getPlugin,
      reloadWidget: reloadWidget
    }
  })();




 $jq(document).ready(function() {
      $jq.ajaxSetup( {timeout: 12e4 }); //2 minute timeout on ajax requests
      if(!window.WB){
        WB.init();
        window.WB = WB;
        window.$jq = $jq;
      }
 });
 
}(this,document);


if(typeof String.prototype.trim !== 'function') {
  String.prototype.trim = function() {
    return this.replace(/^\s+|\s+$/g, ''); 
  }
}

if(!Object.keys) Object.keys = function(o){
   if (o !== Object(o))
      throw new TypeError('Object.keys called on non-object');
   var ret=[],p;
   for(p in o) if(Object.prototype.hasOwnProperty.call(o,p)) ret.push(p);
   return ret;
}