  String.prototype.capitalize = function capitalize () {
    return this.substring(0,1).toUpperCase() + this.substring(1).toLowerCase();
  };

(function($){
  $.fn.refreshPrinters = function (printers) {
    container = this;
    var rows = '';
    

    $.each(printers,function (i,printer){
      //console.log(i,printer);
      if($(container).is('tbody')) {
        var row = '<tr><td class="icon"><div class="container"><img src="icons/' 
        +(printer.type==='remote' ? 'printer-remote-22.png':'printer-22.png') +'" />' 
        +(printer.defaultp ? '<div class="default emblem"></div>': '')
        +'</div></td>'
        +'<td><div class="title'+(printer.defaultp ? ' default': '')+'"><a href="#">' + printer.name + '</a></div>'
        +'<span class="hidden uri">'+printer.URI+'</span>'
        +'<span class="hidden type">'+printer.type+'</span>'      
        +'<span class="hidden shared">'+printer.shared+'</span>'
        +'<span class="hidden status">'+printer.status+'</span>'      
        +'</td>'
        +'</tr>'   
        rows += row;
      } else {
        var row = '<option value="'+i+'"'
        +(printer.defaultp ? ' selected="true"' : '')
        +'>' + printer.name +'</option>'
        rows += row;
      }
    });  
    $(container).html(rows);
    return this;
  };
  $.fn.canAddPrinters = function () {
    var $button = $(this);
    // allow adding if
    // - #autodetected-printers has a selected item
    // - network printers has address, queue and name filled in
    // - Bluetooth in future

    //$('#autodetected-printers').mouseup(function () {
    //  if ($("tr.highlighted", this).get(0)) {
    //    return $button.addClass('default').removeClass('disabled').attr('disabled','true');
    //  }
    //});
    
    //FIXME - I'm too dumb to get this together
    
    if (true) {
      //enable it
      return $button.addClass('default').removeClass('disabled').removeAttr('disabled');
    } else {
      return $button.removeClass('default').addClass('disabled').attr('disabled','true');  
    }
  };
})(jQuery);
