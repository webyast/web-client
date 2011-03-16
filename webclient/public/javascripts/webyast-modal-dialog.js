//TODO: MODAL: overwritte default icons???
//TODO: MODAL: window on resize -> recenter modalWindow!!!
//TODO: DIALOG: autodetect submit button -> $form.find('input type=submit')? else ???

(function($, undefined){
  $.modalDialog = {
    defaults: {
      mshade: 'modalWindowShade',
      mwindow: 'modalWindow',
      mclose: 'modalWindowClose',
      
      warning:  '<img src="/images/dialog-warning.png">',
      loading: '<img src="/images/loading.gif">',
      info:  '<img src="/images/info.png">',
 
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
 
    destroy: function() {
      var options = $.extend(this.defaults, options);  
      $('#'+options.mshade).remove();
      $('#'+options.mwindow).remove();
    }
  };
})(jQuery);

popup = function(image, message) {
  var defaults = $.modalDialog.defaults;  
  $.modalDialog.destroy();
  
  $('body').append('<div id="' + defaults.mshade + '"/>');
  $('body').append('<div id="' + defaults.mwindow + '" class="mpopup">' + image + '<span class="mmessage">' + message + '</span>' + '</div>');
  self.centering(defaults.mwindow);
}

//TODO: form.find('input type=submit') ? else ???
dialog = function(message, form) {
  var defaults = $.modalDialog.defaults;  
  $.modalDialog.destroy();
  
  if(message.split('.').length > 1) {
    question = message.split('.')[0] + '<br/>' + message.split('.')[1];
  }
  
  $('body').append('<div id="' + defaults.mshade + '"/>');
  $dialog = '<div id="' + defaults.mwindow + '" class="mdialog">';
    $dialog += '<div class="mleftcontainer">' + defaults.warning + '</div>';
    $dialog += '<div class="mrightcontainer">';
      $dialog += '<div>' + message + '</div>';
      $dialog += '<div  class="mdevider">--------------------------------------------</div>';
      $dialog += '<div><input type="button" id="no" value="No" /><input type="button" id="yes" value="Yes" /></div>';
    $dialog += '</div>';
  $dialog += '</div>';
  
  var $mclose = $('<img id="' + defaults.mclose +'"/>').attr('src', 'images/close-g.png');
  $('body').append($dialog);
  $('#'+defaults.mwindow).append($mclose);
  $.modalDialog.bind(defaults.mclose);
  
  $('#yes').live('click', function(){
    $.modalDialog.destroy();
    $('#'+form).submit();
  }); 

  $('#no').live('click', function(){
    $.modalDialog.destroy();
    $.modalDialog.wait({message: 'Please wait'});
    window.location = window.location.protocol + '//' + window.location.host;
  }); 
      
  self.centering(defaults.mwindow);
}

form = function(form) {
  var defaults = $.modalDialog.defaults;  
  var $form = $('#'+form).clone(true).show();
  var $form = $('#result form').clone(true).show();
  $('body').append('<div id="' + defaults.mshade + '"/>').append('<div id="' + defaults.mwindow + '" class="mform"/>');
  $('#'+defaults.mwindow).html($form).append($mclose);
  $.modalDialog.bind(defaults.mclose);
}

self.centering = function(mwindow) {
//   $('#'+ mwindow).offset({
//     top: $(document).height()/2 -  ($('#'+ mwindow).height()/2) - 80,
//     left: $(document).width()/2 -  $('#'+ mwindow).width()/2
//   })
  
    $('#'+ mwindow).css('top', $(document).height()/2 -  ($('#'+ mwindow).height()/2) - 80);
    $('#'+ mwindow).css('left', $(document).width()/2 -  $('#'+ mwindow).width()/2);
}
