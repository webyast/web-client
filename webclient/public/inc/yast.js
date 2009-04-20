/* Yast Mockup Javascript */

//default variables
var page = '';

function getPage() {
  return $.query.get('page') ? $.query.get('page') : 'google';
}

function filter() { //filters launcher data for the result menu

  /* filter results */
  var $resContainer = $('#results');
  var findWhat = $query.val();
  
  findWhat = findWhat.toLowerCase().split(' ');
  if (typeof findWhat ==='string') {
    findWhat = [findWhat];
  }
  if (findWhat[0].length<2) {
    $resContainer.hide();
  } else {
    $result.children('li').hide();
    // FIXME this actually does OR, and I'd like to have the words queried with AND'
    // possible solution is to iterate launchers, and doing && using arr.include() from prototify.js
    
      $.each(findWhat,function (i,term) {
        if (term !== '') {
          $('li',$result).find('.tags>span:contains("'+term+'")').parent().parent().show();
        }
        if($('li:visible',$result).length && $('li.selected',$result).length===0) {
          $('li:visible:first',$result).addClass('selected');
        }
      });
    $resContainer.fadeIn(200);   
  }
}

/*
$(document).ready(function () {
  // Patch in firebug lite if firebug is not found.
  if (typeof console === 'undefined') {
    $('head').append('<script src="inc/firebug-lite.js" type="text/javascript"></script>');
  }

  // stupid templating system in javascript
  var pages = ({ 'google': ({
                    'title':    'Configure System',
                    'icon':     'images/suse-logo.png',
                    'content':  'inc/google.html'
                  }),
                  'browse': ({
                    'title':    'Configure System',
                    'icon':     'images/suse-logo.png',
                    'content':  'inc/browse.html'
                  }),
                  'fixme': ({
                    'title':    'Sorry, not done yet',
                    'icon':     'images/suse-logo.png',
                    'content':  'inc/fixme.html'
                  }),
                  'printers': ({
                    'title':    'Printers',
                    'icon':     'icons/yast-printer.png',
                    'content':  'inc/printers.html'
                  })
              });
  //page layout
  page = getPage();
  $('#content').empty().load(pages[page].content, contentLoaded);
  $('#header').load('inc/header.html', function() {
    $('.title',this).html(pages[page].title);
    $('.icon',this).css('background-image','url('+pages[page].icon+')');
    if (page!='google') {
      //set up header navigation
      $('#header').css('cursor','pointer').click(function () {
         window.location = 'index.html';
      }).find('div:first').append('<div class="gohome">return</div>');
    }
  });
  $('#footer').load('inc/footer.html');
});
*/



function browseInit() {

  $.getJSON("controlpanel/modules.json", function (Data) {  
  var $container = $("#browse");
    $.each(Data, function (i,launcher) {
      //FIXME - again, all this DOM assembly is expensive
      var $launcher = $("<div>");
      $launcher.addClass('launcher').addClass('tile')
        .click(function () { window.location=launcher.url; })
        .append('<img src="'+launcher.icon+'">')
        .append('<div>').children('div').addClass('title').text(launcher.title).end()
        .append('<div>').children('div:last').addClass('description').text(launcher.description).end()
        .append('<div>').children('div:last').addClass('groups').text(launcher.groups.join(' '));
      $container.append($launcher);
      $('#all').addClass('active');
    });
    
    //group filtering
    $('#groups .togglebuttons>span').click(function () {
      filterGroup($(this));
    });
    
    function filterGroup($button) {
      var group = $button.attr('id');
      var $launchers = $('#browse');
      var $buttons = $('#groups .togglebuttons>span');
      //select togglebutton
      $buttons.removeClass('active');
      $button.addClass('active');
      //filter
      if (group==='all') {
        $launchers.find('div.launcher').show();
      } else {
        $launchers.find('div.launcher').hide().end()
          .find('div>.groups:contains("'+group+'")').parent().show();
      }
    }
  });
}


function printersInit() {
 
  var printers = [{
        'name'    : 'HP SuperPrinter 2000',
        'type'    : 'local',
        'URI'     : 'usb://usbprinter1',
        'status'  : 'ready',
        'shared'  : false,
        'defaultp' : false
      },{
        'name'    : 'Minolta Magicolor',
        'type'    : 'remote',
        'URI'     : 'ipp://zeus/usbprinter1',
        'status'  : 'ready',
        'shared'  : true,
        'defaultp' : true
      }], detectedPrinters = [{
        'name'    : 'HP USB Printer',
        'type'    : 'local',
        'URI'     : 'usb://usbprinter2',
        'status'  : 'unconfigured',
        'shared'  : false,
        'defaultp' : false
    }],
      $printTable = $('#printer-list'),
      $printerRemove = $('#remove-printer'),
      $defaultPrinterCombo = $('#default-printer'),
      $notifications = $('#notifications'),
      $addPrinterButton = $('#dialog-add-printer'),
      $autoPrinters = $('#autodetected-printers');
  $printTable.find('tbody').refreshPrinters(printers);
  //console.log($printTable);
  $printTable.parents('.list').css('height','200px');

  $('#printer-list').listWidget();
  $defaultPrinterCombo.refreshPrinters(printers);
  $defaultPrinterCombo.change(function () {
    //set new default when the select is changed
    $.each(printers,function (i,printer) {
      printer.defaultp = 0;
    });
    printers[$(this).val()].defaultp = true;
    $printTable.find('tbody').refreshPrinters(printers);
  });
  $printTable.focus(function (e) {
    $('#printer-name').html($(e.target).html());
    $('#printer-type').html($(e.target).parent().siblings('.type').html().capitalize());
    $('#printer-location').html($(e.target).parent().siblings('.uri').html());
    $('#printer-status').html($(e.target).parent().siblings('.status').html().capitalize());
    if ($(e.target).parent().siblings('.shared').html()==='true') {
      $('#printer-shared>input').attr('checked','true');
    } else {
      $('#printer-shared>input').removeAttr('checked');
    }
  }).find('a:first').focus(); //trigger it
  //printer removal

  $printTable.focus(function() {
    $printerRemove.removeAttr('disabled').removeClass('disabled');
  }).blur(function () {
    //doesn't seem to work
    $printerRemove.attr('disabled','true').addClass('disabled');
  });
  $('a:first',$printTable).focus();
  $printerRemove.click(function () {
    var $highlighted = $("#printer-list .highlighted");
    var printerId = $('#printer-list tr').index($highlighted.get(0));
    var $undobutton = new jQuery;
      
    if (printerId>=0) {
      //remove from document, but keep in the printers array for a while
      $('tr:eq('+printerId+')',$printTable).remove();
      $defaultPrinterCombo.find('option:eq('+printerId+')').remove();

      $undobutton = $('<input id="undo-remove" value="Undo" type="submit">').click(function () {
        //undo printer removal
        $printTable.find('tbody').refreshPrinters(printers);

        $defaultPrinterCombo.refreshPrinters(printers);
        $notifications.stopTime("noteTimer");
        $notifications.fadeOut(500,function () {
          $(this).html('');
        });
      }).addClass('button');
      $notifications.notify({
          'message' : 'Printer <strong>' +$highlighted.find('a').html()+ '</strong> has been successfully removed.',
          'button'  : $undobutton,
          'duration': 5000
        }, function () {
          //actualy delete the printer after the timeout
          printers.splice(printerId,1); //FIXME - this is broken
          $printTable.find('tbody').refreshPrinters(printers);
          $defaultPrinterCombo.refreshPrinters(printers);
        });

    }
    return false;
  });
  
  $('#addPrinterDialog').jqm();
  $('#printer-types').tabs();
  $autoPrinters.listWidget().find('tbody').refreshPrinters(detectedPrinters);
  
  //sensitivity of the add button. This doesn't really work. Enabled all the time
  $addPrinterButton.canAddPrinters();

  $('#printer-add-form').submit(function () {
    return false; //prevent form submission
  }).change(function () { //form changes and keypresses on inputs reevaluate the add button sensitivity
    $addPrinterButton.canAddPrinters();
  }).find('input').keyup(function () {
    $addPrinterButton.canAddPrinters();
  });
  $('#dialog-add-printer').click(function () {
    var uri,newPrinter;
    //add a printer
    switch ($('#printer-types li.ui-state-active>a>span').html()) {
      case 'Autodetected':
        if (uri = $('tr.highlighted span.uri',$autoPrinters).html()) {
          name = $('#printer-auto-name').val();
          driver = $('#printer-auto-driver').val();
          newPrinter = {
            'name'    : name,
            'type'    : 'local',
            'URI'     : uri,
            'status'  : 'ready',
            'shared'  : false,
            'defaultp' : false
          }
          printers.push(newPrinter);
          detectedPrinters.pop();
          $autoPrinters.find('tbody').refreshPrinters(detectedPrinters);
          $printTable.find('tbody').refreshPrinters(printers);
          $defaultPrinterCombo.refreshPrinters(printers);
          $('#addPrinterDialog').jqmHide();
        };
        break;
      case 'Network':
        console.log('net');
        break;
    }
  });    

} 




//hook these up after the content loaded
function contentLoaded() {
    /*
  switch (page) {
    case 'printers':
      printersInit();
      var foo = "test";
      break;
    case 'browse':
      browseInit();
      break;
    default:
      googleInit();
  }
    */
}
