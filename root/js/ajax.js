  $(document).ready(function() {   



        $(".user-history").load("/rest/history?count=3", function(response, status, xhr) {
          if (status == "error") {
            var msg = "Sorry but there was an error: ";
            $("#error").html(msg + xhr.status + " " + xhr.statusText);
          }
        });



      $(".bench_update").live('click',function() {
        var ref     = $(this).attr("ref");
        var id     = $(this).attr("wbid");
        var url     = $(this).attr("href") + '?ref=' + ref;
        $("#bench_status").load(url,   function(response, status, xhr) {
                              if (status == "error") {
                              var msg = "Sorry but there was an error: ";
                              $("#error").html(msg + xhr.status + " " + xhr.statusText);
                              }
                            
                          });
        $("#bench_status").addClass("highlight").delay(3000).queue( function(){ $(this).removeClass("highlight"); $(this).dequeue();});
        $("#workbench-status-" + id).load("/rest/workbench/star?ref=" + ref);
        $("div#reports").load("rest/widget/bench//reports");
        $("div#my_library").load("rest/widget/bench//my_library");
      return false;
      });

       $(".status-bar").load("/rest/auth?path=" + window.location.pathname, function(response, status, xhr) {
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
    var widget_name = $(this).attr("class").split(" ")[1];
    var nav = $("#nav-" + widget_name);
    var content = "div#" + widget_name;

    if (nav.attr("load") == 1){
      nav.attr("load", 0);
      if($(content).text() == ""){
        var widget = $(content).closest("li");
        $("#widget-holder").append('<li id="'+widget_name+'">'+widget.html()+'</li>');
        widget.remove();
        var content = $(content);
        addWidgetEffects(content.parent(".widget-container").hide());
        var url     = $(nav).attr("href");
        content.html("<span id=\"fade\">loading...</span>").show();
        content.load(url,
                        function(response, status, xhr) {
                              if (status == "error") {
                              content.html(xhr.status + " " + xhr.statusText);
                              }
                          });
      }
      $(content).parent(".widget-container").show();
      location.href = "#" + widget_name;
    } else {
      nav.attr("load", 1);
      $(content).parent(".widget-container").hide();
    }
    nav.toggleClass("ui-selected");
    $.get(nav.attr("log"));
  return false;
  });

  // used in sidebar view, to open and close widgets when selected
  $(".module-load, .module-close").live('open',function() {
    var widget_name = $(this).attr("class").split(" ")[1];
    var nav = $("#nav-" + widget_name);
    var content = $("div#" + widget_name);
    nav.attr("load", 0);
    addWidgetEffects(content.parent(".widget-container").hide());
    var url     = $(nav).attr("href");
    content.html("<span id=\"fade\">loading...</span>").show();
    content.load(url,
                    function(response, status, xhr) {
                          if (status == "error") {
                          content.html(xhr.status + " " + xhr.statusText);
                          }
                      });
    content.parent(".widget-container").show();
    nav.toggleClass("ui-selected");
    $.get(nav.attr("log"));
    return false;
  });

    function addWidgetEffects(widget_container) {
      widget_container.find("div.module-min").addClass("ui-icon-large ui-icon-triangle-1-s").attr("title", "minimize");;
      widget_container.find("div.module-close").addClass("ui-icon-large ui-icon-close").hide();
      widget_container.find("#widget-footer").hide();

    widget_container.hover(
        function () {
          $(this).find("#widget-header").children(".ui-icon-large").show();
          if($(this).find("#widget-header").children("h3").children(".module-min").attr("show") != 1){
            $(this).find("#widget-footer").show();
          }
        }, 
        function () {
          $(this).find("#widget-header").children(".ui-icon-large").hide();
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
 




