/*
#--
# Webyast Webservice framework
#
# Copyright (C) 2009, 2010 Novell, Inc. 
#   This library is free software; you can redistribute it and/or modify
# it only under the terms of version 2.1 of the GNU Lesser General Public
# License as published by the Free Software Foundation. 
#
#   This library is distributed in the hope that it will be useful, but WITHOUT
# ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
# FOR A PARTICULAR PURPOSE. See the GNU Lesser General Public License for more 
# details. 
#
#   You should have received a copy of the GNU Lesser General Public
# License along with this library; if not, write to the Free Software 
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
#++
*/


// TODO: remove the indicator bar after testing
// Find the way to save the indicator length between page reloads

function sessionTimeout(expirationDate) {
  // Don't start the timer if user is logged out
  var logout_path =  window.location.protocol + "//" + window.location.host + "/logout";
  var loged_out = String(window.location.protocol + "//" + window.location.host + "/session/");
  var current_location = String(window.location);

  // Get the session expires date from back-end
  var now = Math.round(new Date().getTime() / 1000);
  var expiresIn = expirationDate-now;
  //var colors = new Array ('#ef2213', '#f04e46', '#ef6c3f', '#f0984e', '#f0bb46', '#f0e14e', '#eee53f', '#dbe53f', '#bae53f', '#abdf3f');

  //DEBUGGG
  //expiresIn  = 5 //just for test
  //var logContainer = jQuery("div.timer_logpanel");

  expiresIn = expiresIn-300; // show warning message 5 minutes before the session expires
    
  // check current location and start timer if user is logged on
  if(current_location.match(loged_out) == null) {
    //$("#progress-bar").css("display", "block"); 
    jQuery.fjTimer({ 
      interval: 1000,
      repeat: expiresIn, 
      tick: function(counter, timerId) { 
	  //timeLeft = (expiresIn - (counter+1));
	  //dynamicWidth = ((timeLeft*100 / expiresIn) * (document.body.clientWidth/100));
	  //step = (((timeLeft/10)*100)/expiresIn).toFixed(0);
	    
	  //DEBUGGG
	  //timeLeftUntilMessageAppears = (messageAppears - counter);
	  //$("div.timer_logpanel").text("Expire in "+ timeLeft + "!" + " Message in " + timeLeftUntilMessageAppears + "! " + "Tenner " +  step ); 
	  //$("#progress-level").css("width", dynamicWidth); 
	  //$("#progress-level").css("background-color", colors[step]); 
	  
	  //timeLeft = (expiresIn - (counter+1));
	  //console.log(timeLeft);
      },
      onComplete: function() {
	//$("#progress-level").slideUp();
	$("#timeoutMessage").slideDown(); // show the warning bar
	
	messageTimeout = 30;  
	
	jQuery.fjTimer({ 
	  interval: 1000,
	  repeat: messageTimeout, 
	  tick: function(counter, timerId) { 
	    $("#counter").text(" " + (messageTimeout-counter) + " "); 
	  },
	  onComplete: function() {
	    $("#timeoutMessage").slideUp(); // show the warning bar
	    location = logout_path; // redirect to logout page and stop all counters
	  }
	});
      }
    });
  }    
}