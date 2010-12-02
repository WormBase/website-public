  $(document).ready(function() {   
      $(".role-update").live('click',function() {
	$.ajax({
		  type: "POST",
		  url : "/rest/update/role/"+$(this).attr('id')+"/"+$(this).attr('value')+"/"+$(this).attr('checked'), 
		  error: function(request,status,error) {
			  alert(request + " " + status + " " + error );
		    }
	  });
    });

     $(".issue-delete").live('click',function() {
	  var url= $(this).attr("rel");
	   
	  var id=new Array();
	  $(".issue-deletebox").filter(":checked").each(function(){
	  
	     id.push($(this).attr('name'));
	  });
	  var answer= confirm("Do you really want to delete these issues: #"+id.join(' #'));
	  if(answer){
// 	    var reload = $(this).closest('.widget-container').find('.reload');
	    $.ajax({
		      type: "POST",
		      url : url,
		      data: {method:"delete",issues:id.join('_')}, 
		      success: function(data){
// 			      reload.trigger('click');
			      window.location.reload(1);
			},
		      error: function(request,status,error) {
			      alert(request + " " + status + " " + error );
			}
	      });
	  } 
    }); 

    $(".issue-submit").live('click',function() {
	    var url= $(this).attr("rel");
	    var page= $(this).attr("page");
	    var feed = $(this).closest('#issues-new');
	    var email = feed.find("#email");
	    var username= feed.find("#display-name");
	    if(email.attr('id') && username.attr('id')) {
	      if( email.val() =="" || username.val() =="") {
		  alert("To report an Issue, you need to provide a username & email address."); return false;
	      }
	      if (validate_email(email.val(),"Not a valid e-mail address!")==false)
		  {email.focus();return false;}
	    }  
	    $.ajax({
	      type: 'POST',
	      url: url,
	      data: {title:feed.find("#title").val(), location: page, content: feed.find("#content").val(), email:email.val() ,username:username.val() ,},
	      success: function(data){
			    displayNotification("Problem Submitted! We will be in touch soon.");
			    feed.closest('#widget-feed').hide(); 
		      },
	      error: function(request,status,error) {
			    alert(request + " " + status + " " + error);
		      }
	    });

	    return false;

    });

    

        $(".user-history").load("/rest/history?count=3", function(response, status, xhr) {
          if (status == "error") {
            var msg = "Sorry but there was an error: ";
            $(".user-history").html(msg + xhr.status + " " + xhr.statusText);
          }
        });

    $(".list-layouts").load("/rest/layout_list/" + $(".list-layouts").attr("type"), function(response, status, xhr) {
          if (status == "error") {
            var msg = "Sorry but there was an error: ";
            $(".list-layouts").html(msg + xhr.status + " " + xhr.statusText);
          }
        });


    $("div.text-min").live('click',function() {expand($(this), $(this).next());});
    $("div.more").live('click',function() {expand($(this).prev(), $(this));});
    function expand(txt, more){
         var h = txt.height();
         if(h<35){h='100%';}else{h='2.6em';}
         txt.css("max-height", "none");
         txt.animate({height:h});
         more.children(".ui-icon").toggleClass('ui-icon-triangle-1-s');
         more.children(".ui-icon").toggleClass('ui-icon-triangle-1-n');
         more.toggleClass('open');

         //expand the shorted items before the text, also
         txt.prev()
            .add(txt.prev().prev().prev())
            .add(txt.prev().prev().prev().prev().children('.paper-title'))
            .toggleClass('ellipsis');
    }

    $("div.text-min").live('mouseover mouseout',function() {
      $(this).next().toggleClass('opaque');
    });

    $(".reload").live('click', function() {
      var widget_name = $(this).attr("wname");
      $("div#" + widget_name + "-content").load("/rest/widget/me/" + widget_name);
    });

      $(".bench_update").live('click',function() {
        var wbid     = $(this).attr("wbid");
        var id     = $(this).attr("id");
        var class     = $(this).attr("objclass");
        var type     = $(this).attr("type");
        var label     = $(this).attr("name");
        var url     = $(this).attr("href") + '?name=' + escape(label) + "&id=" + id + "&class=" + class + "&type=" + type;
        $("#bench_status").load(url,   function(response, status, xhr) {
                              if (status == "error") {
                              var msg = "Sorry but there was an error: ";
                              $("#bench_status").html(msg + xhr.status + " " + xhr.statusText);
                              }
                          });
        $("#bench_status").addClass("highlight").delay(3000).queue( function(){ $(this).removeClass("highlight"); $(this).dequeue();});       
        $(".workbench-status-" + id).load("/rest/workbench/star?wbid=" + wbid + "&name=" + escape(label) + "&id=" + id + "&class=" + class + "&type=" + type);
        $("div#reports-content").load("/rest/widget/me/reports");
        $("div#my_library-content").load("/rest/widget/me/my_library");
      return false;
      });

       $(".status-bar").load("/rest/auth", function(response, status, xhr) {
	if (status == "error") {
	  var msg = "Sorry but there was an error: ";
	  $("#error").html(msg + xhr.status + " " + xhr.statusText);
	}
      });


    });

  //this function displayes the notification message at the top of the report page
  function displayNotification(message){
        $("#notifications").text(message).show().delay(3000).fadeOut(400);
  }

  $(".update").live('click',function() {

    $(this).text("updating").show();
    var url     = $(this).attr("href");
    // Multiple classes specified. Split so I can rejoin.
    var mytitle = $(this).attr("class").split(" ");
    $("#" + mytitle[1]).load(url,
                    function(response, status, xhr) {
                          if (status == "error") {
                          var msg = "Sorry but there was an error: ";
                          $("#error").html(msg + xhr.status + " " + xhr.statusText);
                          }
                          $(this).children(".toggle").toggleClass("active");
                      });
        
  return false;
  });


  // used in sidebar view, to open and close widgets when selected
  $(".module-load, .module-close").live('click',function() {
    var widget_name = $(this).attr("wname");
    var nav = $("#nav-" + widget_name);
    var content = "div#" + widget_name + "-content";
    if (nav.attr("load") == 1){
      if($(content).text().length < 4){
          var column = ".left";
          var holder = $("#widget-holder");
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
        nav.attr("load", 0);
        $(content).parents("li").addClass("visible");
        nav.addClass("ui-selected");
      }
      location.href = "#" + widget_name;
    } else {
      nav.attr("load", 1);
      nav.removeClass("ui-selected");
      $(content).parents("li").removeClass("visible"); 
    }

    updateLayout();
    return false;
  });

  // used in sidebar view, to open and close widgets when selected
  $(".module-load, .module-close").live('open',function() {
    var widget_name = $(this).attr("wname");
    var nav = $("#nav-" + widget_name);
    var content = "div#" + widget_name + "-content";

    openWidget(widget_name, nav, content, ".left");

    updateLayout();
    return false;
  });

   
    function openWidget(widget_name, nav, content, column){
        nav.attr("load", 0);
        $(content).closest("li").appendTo($("#widget-holder").children(column));
        var content = $(content);
        addWidgetEffects(content.parent(".widget-container"));
        var url     = nav.attr("href");
        content.html("<span id=\"fade\">loading...</span>").show();
        content.load(url,
                        function(response, status, xhr) {
                              if (status == "error") {
                              content.html(xhr.status + " " + xhr.statusText);
                              }
                          });
        nav.addClass("ui-selected");
        content.parents("li").addClass("visible");
        return false;
    }




    function addWidgetEffects(widget_container) {
      widget_container.find("div.module-min").addClass("ui-icon-large ui-icon-triangle-1-s").attr("title", "minimize");
      widget_container.find("div.module-close").addClass("ui-icon ui-icon-large ui-icon-close").hide();
      widget_container.find("#widget-footer").hide();
      widget_container.find(".widget-header").children("h3").children("span.hide").hide();

    widget_container.find(".widget-header").hover(
      function () {
        $(this).children("h3").children("span").show();
      },
      function () {
        $(this).children("h3").children("span.hide").hide();
      }
    );

    widget_container.hover(
        function () {
          $(this).find(".widget-header").children(".ui-icon").show();
          if($(this).find(".widget-header").children("h3").children(".module-min").attr("show") != 1){
            $(this).find("#widget-footer").show();
          }
        }, 
        function () {
          $(this).find(".widget-header").children(".ui-icon").hide();
          $(this).find("#widget-footer").hide();
        }
      );

       widget_container.find("div.module-min").hover(
        function () {
          if ($(this).attr("show")!=1){ $(this).addClass("ui-icon-circle-triangle-s");
          }else{ $(this).addClass("ui-icon-circle-triangle-e");}
        }, 
        function () {
          $(this).removeClass("ui-icon-circle-triangle-s").removeClass("ui-icon-circle-triangle-e");
          if ($(this).attr("show")!=1){ $(this).addClass("ui-icon-triangle-1-s");
          }else{ $(this).addClass("ui-icon-triangle-1-e");}
        }
      );

       widget_container.find("div.module-close").hover(
        function () {
          $(this).addClass("ui-icon-circle-close");
        }, 
        function () {
          $(this).removeClass("ui-icon-circle-close").addClass("ui-icon-close");
        }
      );
    }

    function history_clear(){
        $("div#user_history").load("/rest/history?clear=1",   function(response, status, xhr) {
                              if (status == "error") {
                              var msg = "Sorry but there was an error: ";
                              $("div#user_history").html(msg + xhr.status + " " + xhr.statusText);
                              }
        });
      }


  // Load a (specific) field or widget dynamically onClick.
  $("a.ajax").click(function() {
      var url     = $(this).attr("href");
      var format  = $(this).text();
  
      // Multiple classes specified. Split so I can rejoin.
      var mytitle = $(this).attr("class").split(" ");
      if (format == "yml") {
          format = "text/x-yaml";
      }

      $.ajax({
                 type: "GET",
                 url : url,
                 contentType: 'application/x-www-form-urlencoded',
                 dataType: format,
                 success: function(data){
                      //  Add some description prior to dumping the content
                      var content = "<p>REST request for " + url + "<br />Content-Type: " + format + "</p>";
                       $("#" + mytitle[1] + ".returned-data").show();
                       $("#" + mytitle[1] + ".returned-data").html(content);                         

                        // Embed in <pre> if this is not html
                        if (format == "html") {
                        } else { 
                          data = "<pre>" + data + "</pre>";
                        }

                       $("#" + mytitle[1] + ".returned-data").append(data);
                   },
                   error: function(request,status,error) {
                         alert(request + " " + status + " " + error + " " + format);
                   }
        });
  return false;
  });
 




