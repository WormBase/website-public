  $(document).ready(function() {   
      
      $(".bench_update").live('click',function() {
	var url     = $(this).attr("href") + '?ref=' + $(this).attr("ref");
	$("#testa").load(url,   function(response, status, xhr) {
					      if (status == "error") {
						  var msg = "Sorry but there was an error: ";
						  $("#error").html(msg + xhr.status + " " + xhr.statusText);
					      }
					    
				      });
	return false;
      });
       $(".status-bar").load("/rest/auth", function(response, status, xhr) {
	if (status == "error") {
	  var msg = "Sorry but there was an error: ";
	  $("#error").html(msg + xhr.status + " " + xhr.statusText);
	}
      });


    });

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
        var widget_html = widget.html();
        widget.remove();
        $("#widget-holder").append('<li id="'+widget_name+'">'+widget_html+'</li>');
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
    } else {
      nav.attr("load", 1);
      $(content).parent(".widget-container").hide();
    }
    nav.toggleClass("ui-selected");
    $.get(nav.attr("log"));
  return false;
  });

    function addWidgetEffects(widget_container) {
      widget_container.find("div.module-min").addClass("ui-icon ui-icon-triangle-1-s").attr("title", "minimize");;
      widget_container.find("div.module-close").addClass("ui-icon ui-icon-close").hide();
      widget_container.children("footer").hide();

    widget_container.hover(
        function () {
          $(this).children("header").children(".ui-icon").show();
          if($(this).children("header").children("h3").children(".module-min").attr("show") != 1){
            $(this).children("footer").show();
          }
        }, 
        function () {
          $(this).children("header").children(".ui-icon").hide();
          $(this).children("footer").hide();
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
 




