function select_many_dialog( kvargs ) {
  function getContents(item) { return item.innerHTML; };
  
  var update = function (obj1,obj2) {
    var new_obj = new Object();
    for (var i in obj1) { new_obj[i] = obj1[i] };
    for (var i in obj2) { new_obj[i] = obj2[i] };
    return new_obj;
  }
  
  var include = function (arr,item) { 
    return arr.indexOf(item) == (-1) ? false : true; 
  }
   // load settings from parameters of default
  var default_settings = {
    kind           : "items",
    title          : "Select items",
    selected_title : "Selected items",
    unselected_title : "Available items",
    tooltip : "Click items to select / unselect"
  };
  // preferably use settings from arguments
  var settings = update(default_settings, kvargs );
  var kind = settings.kind;
  // create a basic dialog html
  var d;
  d  = '<div id="select-' + kind + '-dialog\" style="display:none;" title="'+settings.title+'">\n';
  d += '  <input type="hidden" id="select-' + kind + '-current-id" value=""/>\n';
  d += '  <div class="dialog-container">\n';
  d += '    <h2>'+settings.selected_title+'</h2>\n';
  d += '    <div id="selected-' + kind + '"/>\n';
  d += '  </div>\n';
  d += '  <div class="dialog-container">\n';
  d += '    <h2>'+settings.unselected_title+'</h2>\n';
  d += '    <div id="unselected-' + kind + '"/>\n';
  d += '  </div>\n';
  d += '  <div class="select-tooltip">'+settings.tooltip+'</div>\n';
  d += '</div>';
  $("body").append(d);
  
  // 'map' doesn't work on jQuery arrays for some reason. Don't know why.
  function getSelectedItems() {
    var selected_items = [];
    $("#selected-"+kind).children(":visible").each( function (i) {
      selected_items.push( getContents( this ) );
    });
    return selected_items;
  }
  // say that the html is a dialog
  $("#select-"+kind+"-dialog").dialog({
    autoOpen : false,
    width : 350,
    height: 350,
    modal : true,
    buttons : {
      'Ok': function() {
          settings.storeItems( $("#select-"+kind+"-current-id").attr('value'),
                               getSelectedItems() );
          $(this).dialog('close');
        }, 
      'Cancel': function() { $(this).dialog('close'); }
    }
  });
  var renderItemCond = function(item,cond) {
    display_str = cond(item) ? "" : ' style="display: none"';
    return ('<span class="select-dialog-item" value="'+item+'"' + display_str + '>'+item+'</span>');
  };
 
  function showIf(item, condition) {
    condition ? item.show() : item.hide();
  }

  function setSelected(item, is_being_selected) {
    showIf( $('#selected-'+kind  ).children("[value='"+item+"']") ,   is_being_selected );
    showIf( $('#unselected-'+kind).children("[value='"+item+"']") , ! is_being_selected );
  }

  // create function for opening the dialog
  var open_dialog = function (dialogId) {
    var selected_list = settings.loadItems(dialogId);
    var all_items     = settings.allItems();
    var itemSelected         = function (item) { return include(selected_list,item) };
    var itemUnselected       = function (item) { return ! include(selected_list,item) };
    var renderSelectedItem   = function (item) { return renderItemCond(item, itemSelected) };
    var renderUnselectedItem = function (item) { return renderItemCond(item, itemUnselected) };
    // empty 'selected' and 'unselected' container
    $('#selected-'+kind+',#unselected-'+kind).empty();
    // same dialog can be used for several different selections, we have to save dialog/selection id
    $('#select-'+kind+'-current-id').attr('value',dialogId);
    // fillup new values for selected and unselected items
    $('#selected-'+kind).append(  all_items.map( renderSelectedItem   ).join("\n") );
    $('#unselected-'+kind).append(all_items.map( renderUnselectedItem ).join("\n") );
    // make items selectable/unselectable on click
    $('#unselected-'+kind).children().click( function () { setSelected( this.getAttribute('value'), true ) } );
    $('#selected-'+kind  ).children().click( function () { setSelected( this.getAttribute('value'), false) } );
    // call the dialog
    $('#select-'+kind+'-dialog').dialog('open');
  };
  return open_dialog;
};
