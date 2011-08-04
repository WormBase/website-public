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
    }
    , 
    facebook: {
        name: 'Facebook',      
        url:  'http://facebook.anyopenid.com/'
//           oauth_version:"2.0",
//           oauth_server:"https://graph.facebook.com/oauth/authorize"
    }, 
    twitter: {
        name: 'Twitter',     
        url: 'http://twitter.com/oauth/authenticate'
    },

    mendeley: { 
         name: 'Mendeley',
         label: 'Your Mendeley account',
         url:   'http://mendeley.com/'
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
 
var providers = $jq.extend({}, providers_large);

var openid = {

	 
	
	img_path: '/img/logos/',
	
	input_id: null,
	provider_url: null,
	
    init: function(input_id) {
        
        var openid_btns = $jq('#openid_btns');
        
        this.input_id = input_id;
        
        $jq('#openid_choice').show();
        $jq('#openid_input_area').empty();
        
        // add box for each provider
	var array = ['','',''];
	var i=0;
        for (id in providers_large) {
		array[i%3] = array[i%3] + this.getBoxHTML(providers_large[id], 'large', '.png'); 
		i++;
        }
        openid_btns.append(array.join('<br/>') ); 
        
        $jq('#openid_form').submit(this.submit);
        
        var box_id ;
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
	 

		$jq('#openid_form').attr("target", "popup");
		var pop_url = '/auth/popup?id='+box_id + '&url=' + provider['url']  + '&redirect=' + window.location ;

		 
		if (provider['label']) {
			 pop_url += '&label=' + provider['label'];	
		} 
		if (! onload) {
				this.popupWin(pop_url);
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
    		url = url.replace('{username}', $jq('#openid_username').val());
    		openid.setOpenIdUrl(url);
    	}
    	return true;
    },
    setOpenIdUrl: function (url) {
    
    	var hidden = $jq('#'+this.input_id);
    	if (hidden.length > 0) {
    		hidden.value = url;
    	} else {
    		$jq('#openid_form').append('<input type="hidden" id="' + this.input_id + '" name="' + this.input_id + '" value="'+url+'"/>');
    	}
    },
    highlight: function (box_id) {
    	
    	// remove previous highlight.
    	var highlight = $jq('#openid_highlight');
    	if (highlight) {
    		highlight.replaceWith($jq('#openid_highlight a')[0]);
    	}
    	// add new highlight.
    	$jq('.'+box_id).wrap('<div id="openid_highlight"></div>');
    },
     
    useInputBox: function (provider) {
   	
		var input_area = $jq('#openid_input_area');
		
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

		$jq('#'+id).focus();
    }
};
