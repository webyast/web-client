(function($){
  $.fn.listWidget = function(callback) {
    var list = this,
        focused;

    $(this).wrap('<div class="list"></div>');

    $(':checkbox', list).live('click.check', function(){
      $row = $(this).parents('tr').eq(0);
      // Show when a checkbox is clicked
      console.log('Clicked: ',$row);
    });

    $('a,input,button,select', list).live('focus', function(e, s, o){
      focused = this;

      // Make sure there are no other highlighted rows
      $('tr.highlighted').removeClass('highlighted');

      // ...and make this one highlighted
      $(focused).parents('tr').addClass('highlighted');
    }).live('keypress', function(){
      // Translate a keypress into a focus event
      $(this).focus();
    });

    $(list).bind('keydown.arrow', function(e, i){
      // A keypress was registered => show the focus ring!
      $(list).removeClass('hideFocus');

      // Handle keyboard presses.
      // TODO: Figure out key repeat
      switch (e.keyCode) {
        // Up
        case 38:
          $(focused).parents('tr').prevAll('tr').find('a:first').focus();
        break;

        // Down
        case 40:
          $(focused).parents('tr').nextAll('tr').find('a:first').focus();
        break;

        default:
          console.info("pressed " + e.keyCode);
      }

    });

    $('tr', list).live('click.row', function(e, i){
      $(list).addClass('hideFocus');
      if ($(this).is('tr,td')) {
        $(this).find('a').focus();
      }
    });

    // Don't show the focus ring by default
    // (It will show up when keyboard nav is used, however)
    $(list).addClass('hideFocus');

    // Focus the first link in the list
    $('tr a:first', list).focus();
    if (callback) { callback(); };
    return this;
  };
  
  $.fn.notify = function (options,callback) {
    
    $container = $(this);
    $container.append(options.button,'<span>'+options.message+'</span>').fadeIn(200);
    $container.oneTime(options.duration,"noteTimer",function () {
      $(this).fadeOut(500,function () {
        $(this).html('');
        if (callback) { callback(); };
      });
    });
    return this;
    //console.log(options.message,options.button);
  }

})(jQuery);
