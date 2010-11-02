/*
Simple OpenID Plugin
http://code.google.com/p/openid-selector/

This code is licenced under the New BSD License.
*/
 

var providers_large = {
    google: {
        name: 'Google',
        url: 'https://www.google.com/accounts/o8/id'
    },
    yahoo: {
        name: 'Yahoo',      
        url: 'https://me.yahoo.com/'
    },    
    openid: {
        name: 'OpenID',     
        label: 'Enter your OpenID',
        url: null
    }, 
    facebook: {
        name: 'Facebook',      
        url:  'http://facebook.anyopenid.com/'
    }, 
    twitter: {
        name: 'Twitter',     
        url: 'http://twitter.com/oauth/authenticate'
    },
    
    wordpress: {
        name: 'Wordpress',
        label: 'Enter your Wordpress.com username',
        url: 'http://{username}.wordpress.com/'
    },     
    
    aol: {
        name: 'AOL',     
        label: 'Enter your AOL screenname',
        url: 'http://openid.aol.com/{username}/'
    },
     
    livejournal: {
        name: 'LiveJournal',
        label: 'Enter your Livejournal username.',
        url: 'http://{username}.livejournal.com/'
    },
    flickr: {
        name: 'Flickr',        
        label: 'Enter your Flickr username',
        url: 'http://flickr.com/{username}/'
    }, 
    blogger: {
        name: 'Blogger',
        label: 'Your Blogger account',
        url: 'http://{username}.blogspot.com/'
    },
    myopenid: {
        name: 'MyOpenID',
        label: 'Enter your MyOpenID username',
        url: 'http://{username}.myopenid.com/'
    }, 
    myspace: {
        name: 'MySpace',   
	label: 'Enter your MySpace username',
        url: 'http://www.myspace.com/{username}/'
    },
    technorati: {
        name: 'Technorati',
        label: 'Enter your Technorati username',
        url: 'http://technorati.com/people/technorati/{username}/'
    },
    verisign: {
        name: 'Verisign',
        label: 'Your Verisign username',
        url: 'http://{username}.pip.verisignlabs.com/'
    },
    
};
 
var providers = $.extend({}, providers_large);

var openid = {

	cookie_expires: 6*30,	// 6 months.
	cookie_name: 'openid_provider',
	cookie_path: '/',
	
	img_path: '/img/logos/',
	
	input_id: null,
	provider_url: null,
	
    init: function(input_id) {
        
        var openid_btns = $('#openid_btns');
        
        this.input_id = input_id;
        
        $('#openid_choice').show();
        $('#openid_input_area').empty();
        
        // add box for each provider
	var array = ['','',''];
	var i=0;
        for (id in providers_large) {
		array[i%3] = array[i%3] + this.getBoxHTML(providers_large[id], 'large', '.png'); 
		i++;
        }
        openid_btns.append(array.join('<br/>') ); 
        
        $('#openid_form').submit(this.submit);
        
        var box_id = this.readCookie();
        if (box_id) {
        	this.signin(box_id, true);
        }  
    },
    getBoxHTML: function(provider, box_size, image_ext) {
            
        var box_id = provider["name"].toLowerCase();
        return '<a title="'+provider["name"]+'" href="javascript: openid.signin(\''+ box_id +'\');"' +
        		' style="background: #FFF url(' + this.img_path + box_id + image_ext+') no-repeat center center" ' + 
        		'class="' + box_id + ' openid_' + box_size + '_btn"></a>';    
    
    },
    /* Provider image click */
    signin: function(box_id, onload) {
    
    	var provider = providers[box_id];
  		if (! provider) {
  			return;
  		}
		
		this.highlight(box_id);
		this.setCookie(box_id);

		$('#openid_form').attr("target", "popup");
		var pop_url = '/auth/popup?id='+box_id;
		  
		if (provider['label']) {
			pop_url = pop_url + '&label=' + provider['label'] + '&url=' + provider['url'] ;
// 			this.useInputBox(provider);
// 			this.provider_url = provider['url'];
			if (! onload) {
				this.popupWin(pop_url);
			}
			
		} else {
			
			this.setOpenIdUrl(provider['url']);
			if (! onload) {
				this.popupWin(pop_url);
				$('#openid_form').submit();
			}	
		}

		 
    },

    popupWin: function(url) {
	var h = 400;
	var w = 600;
	var screenx = (screen.width/2) - (w/2 );
	var screeny = (screen.height/2) - (h/2);
	//Open the window.
	var win2 = window.open(url,"popup","status=no,resizable=yes,height="+h+",width="+w+",left=" + screenx + ",top=" + screeny + ",toolbar=no,menubar=no,scrollbars=no,location=no,directories=no");
	win2.focus();
    },
    /* Sign-in button click */
    submit: function() {
        
    	var url = openid.provider_url; 
    	if (url) {
    		url = url.replace('{username}', $('#openid_username').val());
    		openid.setOpenIdUrl(url);
    	}
    	return true;
    },
    setOpenIdUrl: function (url) {
    
    	var hidden = $('#'+this.input_id);
    	if (hidden.length > 0) {
    		hidden.value = url;
    	} else {
    		$('#openid_form').append('<input type="hidden" id="' + this.input_id + '" name="' + this.input_id + '" value="'+url+'"/>');
    	}
    },
    highlight: function (box_id) {
    	
    	// remove previous highlight.
    	var highlight = $('#openid_highlight');
    	if (highlight) {
    		highlight.replaceWith($('#openid_highlight a')[0]);
    	}
    	// add new highlight.
    	$('.'+box_id).wrap('<div id="openid_highlight"></div>');
    },
    setCookie: function (value) {
    
		var date = new Date();
		date.setTime(date.getTime()+(this.cookie_expires*24*60*60*1000));
		var expires = "; expires="+date.toGMTString();
		
		document.cookie = this.cookie_name+"="+value+expires+"; path=" + this.cookie_path;
    },
    readCookie: function () {
		var nameEQ = this.cookie_name + "=";
		var ca = document.cookie.split(';');
		for(var i=0;i < ca.length;i++) {
			var c = ca[i];
			while (c.charAt(0)==' ') c = c.substring(1,c.length);
			if (c.indexOf(nameEQ) == 0) return c.substring(nameEQ.length,c.length);
		}
		return null;
    },
    useInputBox: function (provider) {
   	
		var input_area = $('#openid_input_area');
		
		var html = '';
		var id = 'openid_username';
		var value = '';
		var label = provider['label'];
		var style = '';
		
		if (label) {
			html = '<p>' + label + '</p>';
		}
		if (provider['name'] == 'OpenID') {
			id = this.input_id;
			value = 'http://';
			style = 'background:#FFF url('+this.img_path+'openid-inputicon.gif) no-repeat scroll 0 50%; padding-left:18px;';
		}
		html += '<input id="'+id+'" type="text" style="'+style+'" name="'+id+'" value="'+value+'" />' + 
					'<input id="openid_submit" type="submit" value="Sign-In"/>';
		
		input_area.empty();
		input_area.append(html);

		$('#'+id).focus();
    }
};
