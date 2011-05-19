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

//TODO: MODAL: overwritte default icons???
//TODO: MODAL: window on resize -> recenter modalWindow!!!
//TODO: DIALOG: autodetect submit button -> $form.find('input type=submit')? else ???


(function($) {
  var cache = [];
  // Arguments are image paths relative to the current page.
  $.preLoadImages = function() {
    var args_len = arguments.length;
    for (var i = args_len; i--;) {
      var cacheImage = document.createElement('img');
      cacheImage.src = arguments[i];
      cache.push(cacheImage);
    }
  }
})(jQuery)

jQuery.preLoadImages("../images/loading.gif", "../images/dialog-warning.png", "../images/info.png", "../images/close.png");

(function($, undefined){
  $.modalDialog = {
    defaults: {
      mshade: 'modalWindowShade',
      mwindow: 'modalWindow',
      mclose: 'modalWindowClose',

      warning:  '<img src="../images/dialog-warning.png">',
      loading:  '<img id="modal_loading" src="../images/loading.gif">',
      info:  	'<img src="../images/info.png">',

      message: 'Please wait',
      simple: false,
      timeout: 0,
    },

    warning: function(options){
      var options = $.extend(this.defaults, options);
      if(!options.simple) { options.message = '<b class="mwarning">Warning:</b> ' + options.message; }
      popup(options.warning, options.message);
    },

    info: function(options){
      var options = $.extend(this.defaults, options);
      if(!options.simple) { options.message = '<b class="minfo">Info:</b> ' + options.message; }
      popup(options.info, options.message);
    },

    wait: function(options){
      var options = $.extend(this.defaults, options);
      if(!options.simple) { options.message = options.message + ' <b class="mwait">...</b>'; }
      popup(options.loading, options.message);
    },


    dialog: function(options){
      var options = $.extend(this.defaults, options);
      dialog(options.message, options.form);
    },

    confirm_dialog: function(options){
      var options = $.extend(this.defaults, options);
      confirm_dialog(options.message, options.action);
    },

    bind: function(options) {
      var close = '#' + this.defaults.mclose;
      $(function(){
	      $(close).live('click', function(){
	        $.modalDialog.destroy({ timeout: 0});
	      });

	      $(close).live('mouseenter', function(){
	        $(this).attr('src' , 'images/close.png');
	      });

	      $(close).live('mouseleave', function(){
	        $(this).attr('src' , 'images/close-g.png');
	      });
      })
    },

    redirect: function(options) {
       window.location = window.location.protocol + '//' + window.location.host;
    },

    destroy: function() {
      var options = $.extend(this.defaults, options);
      $('#'+options.mshade).remove();
      $('#'+options.mwindow).remove();
    }
  };
})(jQuery);

popup = function(image, message) {
  var defaults = $.modalDialog.defaults;

  $('body').append('<div id="' + defaults.mshade + '">&nbsp;</div>');
  $('body').after('<div id="' + defaults.mwindow + '" class="mpopup">' + '</div>');
  $('#' + defaults.mwindow).wrapInner(image + '<span class="mmessage">' + message + '</span>');

  self.centering(defaults.mwindow);
  
  if($(image).attr('id') == 'modal_loading') {
    setTimeout("$('#modal_loading').attr('src', '../images/loading.gif');",100);
  }
}

//TODO: form.find('input type=submit') ? else ???
dialog = function(message, form) {
  var defaults = $.modalDialog.defaults;


  if(message.split('.').length > 1) {
    question = message.split('.')[0] + '<br/>' + message.split('.')[1];
  }

  $('body').append('<div id="' + defaults.mshade + '">&nbsp;</div>');

  $dialog = '<div id="' + defaults.mwindow + '" class="mdialog">';
    $dialog += '<div class="mleftcontainer">' + defaults.warning + '</div>';
    $dialog += '<div class="mrightcontainer">';
      $dialog += '<div>' + question + '</div>';
      $dialog += '<div  class="mdevider">&nbsp;</div>';
      $dialog += '<div><input type="button" id="no" value="No" /><input type="button" id="yes" value="Yes" /></div>';
    $dialog += '</div>';
  $dialog += '</div>';

  var $mclose = $('<img id="' + defaults.mclose +'"/>').attr('src', '../images/close-g.png');

  $('body').before($dialog);
  $('#'+defaults.mwindow).append($mclose);
  $.modalDialog.bind(defaults.mclose);

  $('#yes').live('click', function(){
    $.modalDialog.destroy();
    $('#'+form).submit();
  });

  $('#no').live('click', function(){
    $.modalDialog.destroy();
    $.modalDialog.wait({message: 'Please wait'});
    setTimeout('$.modalDialog.redirect()', 500);
  });

  self.centering(defaults.mwindow);
}

self.centering = function(mwindow) {
  $('#'+ mwindow).css('top', $(document).height()/2 -  ($('#'+ mwindow).height()/2) - 80);
  $('#'+ mwindow).css('left', $(document).width()/2 -  $('#'+ mwindow).width()/2);
}

