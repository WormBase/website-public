
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
  $(".module-load").live('click',function() {
    var mytitle = "#" + $(this).attr("class").split(" ")[1];
    if ($(this).attr("load") == 1){
      if($(mytitle).text() == ""){
        var url     = $(this).attr("href");
        $(mytitle).html("<span id=\"fade\">loading...</span>").show();
        $(mytitle).load(url,
                        function(response, status, xhr) {
                              if (status == "error") {
                              $(mytitle).html(xhr.status + " " + xhr.statusText);
                              }
                          });
      }
      $(mytitle).parent(".widget-container").show();
      $(this).attr("load", 0);
      $(this).addClass("ui-selected").show();
    } else {
      $(mytitle).parent(".widget-container").hide();
      $(this).removeClass("ui-selected").show();
      $(this).attr("load", 1);
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
 




