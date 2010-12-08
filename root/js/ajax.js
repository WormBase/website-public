  $jq(document).ready(function() {   

    $jq(".register-button").live('click',function() {
      
	var reg = $jq(this).closest('#register-form');	
	var email = reg.find("#email");
	var username= reg.find("#username");
	var password = reg.find("#password");
	if(validate_fields(email,username,password,reg.find("#confirm-password")) == false) {
	    return false;
	}
	 
	$jq.ajax({
		  type: "POST",
		  dataType: 'text/x-yaml',
		  url: "/rest/register",
		  data: {username:username.val(),email:email.val(),password:password.val()},
		  success: function(data){
			   if(data==0) {
				alert("The email address has already been registered!"); 
			   }else {
			    $jq.colorbox.close();
			    displayNotification("Thank you for registering at WormBase, a confirmation emaill will be send to you soon.");
			   }
		    },
		  error: function(request,status,error) {
			  alert(request + " " + status + " " + error );
		    }
	  });
      });

  
      $jq(".role-update").live('click',function() {
	$jq.ajax({
		  type: "POST",
		  url : "/rest/update/role/"+$jq(this).attr('id')+"/"+$jq(this).attr('value')+"/"+$jq(this).attr('checked'), 
		  error: function(request,status,error) {
			  alert(request + " " + status + " " + error );
		    }
	  });
    });

     $jq(".issue-delete").live('click',function() {
	  var url= $jq(this).attr("rel");
	   
	  var id=new Array();
	  $jq(".issue-deletebox").filter(":checked").each(function(){
	     id.push($jq(this).attr('name'));
	  });
	  var answer= confirm("Do you really want to delete these issues: #"+id.join(' #'));
	  if(answer){
// 	    var reload = $jq(this).closest('.widget-container').find('.reload');
	    $jq.ajax({
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

    $jq(".issue-submit").live('click',function() {
	    var url= $jq(this).attr("rel");
	    var page= $jq(this).attr("page");
	    var feed = $jq(this).closest('#issues-new');
	    var email = feed.find("#email");
	    var username= feed.find("#display-name");
	    if(email.attr('id') && username.attr('id')) {
	       if(validate_fields(email,username)==false) {return false;}
	    }  
	    $jq.ajax({
	      type: 'POST',
	      url: url,
	      data: {title:feed.find("#title").val(), location: page, content: feed.find("#content").val(), email:email.val() ,username:username.val() ,},
	      success: function(data){
			    if(data==0) {
				   alert("The email address has already been registered!Please sign in."); 
			    }else {
				  displayNotification("Problem Submitted! We will be in touch soon.");
				  feed.closest('#widget-feed').hide(); 
			    }
		      },
	      error: function(request,status,error) {
			    alert(request + " " + status + " " + error);
		      }
	    });

	    return false;

    });

    

        $jq(".user-history").load("/rest/history?count=3", function(response, status, xhr) {
          if (status == "error") {
            var msg = "Sorry but there was an error: ";
            $jq(".user-history").html(msg + xhr.status + " " + xhr.statusText);
          }
        });

    $jq(".list-layouts").load("/rest/layout_list/" + $jq(".list-layouts").attr("type"), function(response, status, xhr) {
          if (status == "error") {
            var msg = "Sorry but there was an error: ";
            $jq(".list-layouts").html(msg + xhr.status + " " + xhr.statusText);
          }
        });


    $jq("div.text-min").live('click',function() {expand($jq(this), $jq(this).next());});
    $jq("div.more").live('click',function() {expand($jq(this).prev(), $jq(this));});
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

    $jq("div.text-min").live('mouseover mouseout',function() {
      $jq(this).next().toggleClass('opaque');
    });

    $jq(".reload").live('click', function() {
      var widget_name = $jq(this).attr("wname");
      $jq("div#" + widget_name + "-content").load("/rest/widget/me/" + widget_name);
    });

      $jq(".bench_update").live('click',function() {
        var wbid     = $jq(this).attr("wbid");
        var id     = $jq(this).attr("id");
        var class     = $jq(this).attr("objclass");
        var type     = $jq(this).attr("type");
        var label     = $jq(this).attr("name");
        var url     = $jq(this).attr("href") + '?name=' + escape(label) + "&id=" + id + "&class=" + class + "&type=" + type;
        $jq("#bench_status").load(url,   function(response, status, xhr) {
                              if (status == "error") {
                              var msg = "Sorry but there was an error: ";
                              $jq("#bench_status").html(msg + xhr.status + " " + xhr.statusText);
                              }
                          });
        $jq("#bench_status").addClass("highlight").delay(3000).queue( function(){ $jq(this).removeClass("highlight"); $jq(this).dequeue();});       
        $jq(".workbench-status-" + id).load("/rest/workbench/star?wbid=" + wbid + "&name=" + escape(label) + "&id=" + id + "&class=" + class + "&type=" + type);
        $jq("div#reports-content").load("/rest/widget/me/reports");
        $jq("div#my_library-content").load("/rest/widget/me/my_library");
      return false;
      });

       $jq(".status-bar").load("/rest/auth", function(response, status, xhr) {
	if (status == "error") {
	  var msg = "Sorry but there was an error: ";
	  $jq("#error").html(msg + xhr.status + " " + xhr.statusText);
	}
      });


    });

  //this function displayes the notification message at the top of the report page
  function displayNotification(message){
        $jq("#notifications").text(message).show().delay(3000).fadeOut(400);
  }

  $jq(".update").live('click',function() {

    $jq(this).text("updating").show();
    var url     = $jq(this).attr("href");
    // Multiple classes specified. Split so I can rejoin.
    var mytitle = $jq(this).attr("class").split(" ");
    $jq("#" + mytitle[1]).load(url,
                    function(response, status, xhr) {
                          if (status == "error") {
                          var msg = "Sorry but there was an error: ";
                          $jq("#error").html(msg + xhr.status + " " + xhr.statusText);
                          }
                          $jq(this).children(".toggle").toggleClass("active");
                      });
        
  return false;
  });


  // used in sidebar view, to open and close widgets when selected
  $jq(".module-load, .module-close").live('click',function() {
    var widget_name = $jq(this).attr("wname");
    var nav = $jq("#nav-" + widget_name);
    var content = "div#" + widget_name + "-content";
    if (nav.attr("load") == 1){
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
        nav.attr("load", 0);
        $jq(content).parents("li").addClass("visible");
        nav.addClass("ui-selected");
      }
      location.href = "#" + widget_name;
    } else {
      nav.attr("load", 1);
      nav.removeClass("ui-selected");
      $jq(content).parents("li").removeClass("visible"); 
    }

    updateLayout();
    return false;
  });

  // used in sidebar view, to open and close widgets when selected
  $jq(".module-load, .module-close").live('open',function() {
    var widget_name = $jq(this).attr("wname");
    var nav = $jq("#nav-" + widget_name);
    var content = "div#" + widget_name + "-content";

    openWidget(widget_name, nav, content, ".left");

    updateLayout();
    return false;
  });

   
    function openWidget(widget_name, nav, content, column){
        nav.attr("load", 0);
        $jq(content).closest("li").appendTo($jq("#widget-holder").children(column));
        var content = $jq(content);
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

    function history_clear(){
        $jq("div#user_history").load("/rest/history?clear=1",   function(response, status, xhr) {
                              if (status == "error") {
                              var msg = "Sorry but there was an error: ";
                              $jq("div#user_history").html(msg + xhr.status + " " + xhr.statusText);
                              }
        });
      }


  // Load a (specific) field or widget dynamically onClick.
  $jq("a.ajax").click(function() {
      var url     = $jq(this).attr("href");
      var format  = $jq(this).text();
  
      // Multiple classes specified. Split so I can rejoin.
      var mytitle = $jq(this).attr("class").split(" ");
      if (format == "yml") {
          format = "text/x-yaml";
      }

      $jq.ajax({
                 type: "GET",
                 url : url,
                 contentType: 'application/x-www-form-urlencoded',
                 dataType: format,
                 success: function(data){
                      //  Add some description prior to dumping the content
                      var content = "<p>REST request for " + url + "<br />Content-Type: " + format + "</p>";
                       $jq("#" + mytitle[1] + ".returned-data").show();
                       $jq("#" + mytitle[1] + ".returned-data").html(content);                         

                        // Embed in <pre> if this is not html
                        if (format == "html") {
                        } else { 
                          data = "<pre>" + data + "</pre>";
                        }

                       $jq("#" + mytitle[1] + ".returned-data").append(data);
                   },
                   error: function(request,status,error) {
                         alert(request + " " + status + " " + error + " " + format);
                   }
        });
  return false;
  });
 




