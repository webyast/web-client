//TRACK THE FORM CHANGES
var formChanged = false;
function init() {
  $("#on").click(formWasChanged);
  $("#off").click(formWasChanged);
  
  $('#firewallForm .firewall-service').bind('click', formWasChanged);

  $("#firewall-wrapper .action-link").click(
    function(event) {
      if (formChanged == true) {
	event.stopPropagation();
	event.preventDefault();
      
	$.blockUI.defaults.applyPlatformOpacityRules = false;
	$.blockUI({
	  message: $('#unsavedChangesDialog'), 
	  showOverlay: true, 
	  css: { 
	    padding:        10, 
	    margin:         '0 auto', 
	    width:          '280px',
	    left:           '40%', 
	    textAlign:      'center', 
	    color:          '#333', 
	    border:         '5px solid #aaa', 
	    backgroundColor:'#fff',
	    cursor:         'wait',
	    '-webkit-border-radius': '5px', 
	    '-moz-border-radius': '5px',
	    '-webkit-box-shadow': '0 0 2em #222',
	    '-moz-box-shadow': '0 0 2em #222',
	    '-webkit-box-shadow': 'inset 0 0 4px #222',
	    '-moz-box-shadow': 'inset 0 0 4px #222'
	  }
	});   

      $('#yes').click(function() { 
	$.unblockUI(); 
	$('#firewallSubmitButton').click();
      }); 

      $('#no').click(function() { 
	$.unblockUI(); 
	document.location = event.target.href;
	return true; 
      }); 

      $('#cancel').click(function() { 
	$.unblockUI(); 
	return false; 
      }); 
    }
   }
  );
}

function formWasChanged() {
  formChanged = true;
  $('#firewallForm .firewall-service').unbind('click', formWasChanged);
}

$(document).ready(init);

jQuery(function($){
  //SORT SERVICES LIST
  var $list = $('#allowed_services>span');
  $list.css('display', 'inline-block');

  var array = new Array();
  $list = $list.tsort()

  $.each($list, function(i, l){	
    if (jQuery.inArray($(l).text().substr(0, 1).toLowerCase(), array) == -1) {
      array.push($(l).text().substr(0, 1).toLowerCase())
    } 
  });

  var category = -1;
  var lastElement = -1;

  $.each($list, function(i, elem){
    var firstChar = $(elem).text().substr(0, 1).toLowerCase();

    if(array.indexOf(firstChar) != category) {
      $(elem).wrap('<p>').before('<b class="firstChar">' + $(elem).text().substr(0, 1) + '</b>');
      lastElement = i;
      category = array.indexOf(firstChar)
    } else {
      $($(elem)).insertAfter($list[lastElement]);
    }
  });

  var $list = $("#blocked_services>span");
  $list.css('display', 'inline-block');

  var array = new Array();
  $list = $list.tsort()

  $.each($list, function(i, l){	
    if (jQuery.inArray($(l).text().substr(0, 1).toLowerCase(), array) == -1) {
      array.push($(l).text().substr(0, 1).toLowerCase())
    } 
  });

  var category = -1;
  var lastElement = -1;

  $.each($list, function(i, elem){
    var firstChar = $(elem).text().substr(0, 1).toLowerCase();

    if(array.indexOf(firstChar) != category) {
      $(elem).wrap('<p>').before('<b class="firstChar">' + $(elem).text().substr(0, 1) + '</b>');
      lastElement = i;
      category = array.indexOf(firstChar)
    } else {
      $($(elem)).insertAfter($list[lastElement]);
    }
  });
});

function enableFirewallForm() {
  //Description Tooltip
  /*gravity: $.fn.tipsy.autoNS,*/ 
  $('span.firewall-service').tipsy({gravity: 's', delayIn: 500 })
  $('span.firewall-service').removeClass('firewall_disabled');

  //Change color on hover
  $('#allowed_services span.firewall-service').hover(
    function () {
      $(this).css('color', '#8cb219');
    },
    function () {
      $(this).css('color', '');
    }
  );
  
  $('#allowed_services span.firewall-service').bind({
    click: function(event){
      $(this).fadeOut(200);
      $("#fw_services_values input."+$(this).attr("value")).attr("value", "false");
      $("#blocked_services span[value='"+$(this).attr("value")+"']").fadeIn(50).effect("highlight", {color:'#ff6440'}, 300);
    }
  });
  
  //Change color on hover
  $('#blocked_services span.firewall-service').hover(
    function () {
      $(this).css('color', '#ff7640');
    },
    function () {
      $(this).css('color', '');
    }
  );

  $('#blocked_services span.firewall-service').bind({
    click: function(event){
      $(this).fadeOut(200);
      $("#fw_services_values input."+$(this).attr("value")).attr("value", "true");
      $("#allowed_services span[value='"+$(this).attr("value")+"']").fadeIn(50).effect("highlight", {color:'#8cb219'}, 300);
    }
  });
}

function disableFirewallForm() {
  $elements = $('span.firewall-service');
  $elements.addClass('firewall_disabled');
  $elements.unbind('click').unbind('mouseenter mouseleave');
}

// RADIO BUTTONS SWITCHER
$(document).ready(function(){
  var $on = $('#on');
  var $off = $('#off');

  $on.click(function () {
    if($(this).hasClass('selected') == false) {
      $(this).addClass('selected darkShadow');
      $('#indicator').attr('src', 'images/firewall-on-led.png');
      $off.removeClass('selected darkShadow');
      $('#allowed_services').removeClass('firewallForm_disabled');
      $('#blocked_services').removeClass('firewallForm_disabled');

      enableFirewallForm();
      $('#use_firewall').click();
    } 
  });

  $off.click(function () {
    if($(this).hasClass('selected') == false) {
      $(this).addClass('selected darkShadow');
      $('#indicator').attr('src', 'images/firewall-off-grey.png');
      $on.removeClass('selected darkShadow');
      $('#allowed_services').addClass('firewallForm_disabled');
      $('#blocked_services').addClass('firewallForm_disabled');

      disableFirewallForm();
      $('#use_firewall').click();
    }
  });  
});
