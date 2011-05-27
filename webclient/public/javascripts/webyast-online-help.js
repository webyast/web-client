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

var webyastModules = {
  firewall: "Firewall",
  time: "Time",
  patch: "Updates",
  services: "Services",
  registration: "Registration",
  network: "Network",
  ldap: "LDAP",
  kerberos: "Kerberos",
  activedirectory: "Active Directory",
  repositories: "Repositories",
  users: "Users",
  groups: "Groups",
  mail: "Mail",
  roles: "Roles",
  administrator: "Administrator",
  status: "Status",
  limits: "Limits",
  status_area: "Area"
};

String.prototype.capitalize = function() {
  return this.charAt(0).toUpperCase() + this.slice(1);
}

$(document).ready(function() {
  $('#questionMark').bind('click', function(){
    var pattern = /[a-z]+/ig;
    var path = window.location.pathname;
    var module = (pattern.exec(path)).toString()
    var url = 'onlinehelp' + '/' + webyastModules[module];

    if(webyastModules[module] !== undefined) {
      $('body').append('<div id="onlineHelpModalShade"/>');
      $('body').after('<span id="onlineHelpContent"><span id="onlineHelpLoading"><img id="onlineHelpSpinner" src="images/wait.gif"><span>Please wait ...</span></span></span>');

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
        
      $('a.xref').live('click', function(event){
        event.preventDefault();
        var text = $(this).text().toString();
//        console.log("text " + text)
        for(var m in webyastModules) {
          var module = webyastModules[m].toString();
          var pattern = new RegExp(module);
          var hit  = pattern.test(text); 
              
          if(hit) {
            url = 'onlinehelp' + '/' + module;
            setTimeout(function(){
              $.get(url, function(data){
                 $('#onlineHelpContent').html(data).append(close);
              });
            }, 800);
          }
        }
        return false;
      });
    } else {
      alert("ERROR: Online help for <" + module + "> module is not available!");
    }
  });
});
