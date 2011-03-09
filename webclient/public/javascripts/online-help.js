$(document).ready(function() {
  String.prototype.capitalize = function() {
    return this.charAt(0).toUpperCase() + this.slice(1);
  }

  $('#questionMark').bind('click', function(){
    var currentURL = window.location.toString().split("/");

    switch(currentURL[currentURL.length-1]) {
      case 'activedirectory':
	url = "onlinehelp/Active Directory";
	break;
      case 'users':
	url = "onlinehelp/" + currentURL[currentURL.length-1].capitalize();
	break;
      case 'firewall':
	url = "onlinehelp/" + currentURL[currentURL.length-1].capitalize();
	break;
      case 'mail':
	url = "onlinehelp/" + currentURL[currentURL.length-1].capitalize();
	break;
      case 'groups':
	url = "onlinehelp/" + currentURL[currentURL.length-1].capitalize();
	break;
      case 'kerberos':
	url = "onlinehelp/" + currentURL[currentURL.length-1].capitalize();
	break;
      case 'ldap':
	url = "onlinehelp/" + currentURL[currentURL.length-1].toUpperCase();
	break;
      case 'network':
	url = "onlinehelp/" + currentURL[currentURL.length-1].capitalize();
	break;
      case 'registration':
	url = "onlinehelp/" + currentURL[currentURL.length-1].capitalize();
	break;
      case 'roles':
	url = "onlinehelp/" + currentURL[currentURL.length-1].capitalize();
	break;
      case 'repositories':
	url = "onlinehelp/Repositories";
	break;
      case 'status':
	url = "onlinehelp/" + currentURL[currentURL.length-1].capitalize();
	break;
      case 'services':
	url = "onlinehelp/" + currentURL[currentURL.length-1].capitalize();
	break;
      case 'administrator':
	url = "onlinehelp/" + currentURL[currentURL.length-1].capitalize();
	break;
      case 'patch_updates':
	url = "onlinehelp/Updates";
	break;
      case 'time':
	url = "onlinehelp/" + currentURL[currentURL.length-1].capitalize();
	break;
      default:
	url = "#";
	break;
    }

    
    if(url !='#') {
      $('body').append('<div id="onlineHelpModalShade"/>');
      $('#questionMark').after('<span id="onlineHelpContent"><span id="onlineHelpLoading"><img id="onlineHelpSpinner" src="images/wait.gif"><span>Please wait ...</span></span></span>');

      var close = $('<img id="closeOnlineHelpDialog" />').attr('src', 'images/close-g.png');

      setTimeout(function(){
	$.get(url, function(data){
	  $('#onlineHelpContent').html(data).append(close);
	});
      }, 800);
      

      $('#closeOnlineHelpDialog').live('click', function(){
	$('#onlineHelpModalShade').remove();
	$('#onlineHelpContent').remove();
      });

      $('#closeOnlineHelpDialog').live('mouseover', function(){
	$(this).attr('src', 'images/close.png');
      });
    
      $('#closeOnlineHelpDialog').live('mouseout', function(){
	$(this).attr('src', 'images/close-g.png');
      });

    } else {
      alert("ERROR: broken URL!");
    }
  });
});