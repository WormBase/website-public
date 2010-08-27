
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
    var content = $(this).attr("class").split(" ")[1];
    var nav = "#nav-" + content;
    content = "#" + content;
    if ($(nav).attr("load") == 1){
      if($(content).text() == ""){
        var url     = $(nav).attr("href");
        $(content).html("<span id=\"fade\">loading...</span>").show();
        $(content).load(url,
                        function(response, status, xhr) {
                              if (status == "error") {
                              $(content).html(xhr.status + " " + xhr.statusText);
                              }
                          });
      }
      
      $(nav).attr("load", 0);
      $(nav).addClass("ui-selected").show();
      $(content).parent(".widget-container").hide().show();
    } else {
      $(content).parent(".widget-container").hide();
      $(nav).removeClass("ui-selected").show();
      $(nav).attr("load", 1);
    }
  return false;
  });

  // Load a (specific) field or widget dynamically onClick.
  $("a.ajax").click(function() {
      var url     = $(this).attr("href");
      var format  = $(this).text();
//    format  = $(this).text();
  
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
 




