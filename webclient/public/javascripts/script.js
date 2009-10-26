$(document).ready(function() {
  
  // Change BG Colour on mouseover and change it back on mouse out
  $('.highlight-bg').mouseover(function() {
    $(this).addClass('grey-bg'); // add class for highlighting
  }).mouseout(function() {
    $(this).removeClass('grey-bg'); // remove class for highlighting
  });

  // Alternating Lines in "Tables"
  $('.alternate-rows > li:even').addClass('alt-bg');


// Tab-UI ====================================================================

$('.ui-tab-parent').tabs();

$('.ui-tab-parent').bind('tabsselect', function(event, ui) {

    // Objects available in the function context:
    // ui.tab     // anchor element of the selected (clicked) tab
    // ui.panel   // element, that contains the selected/clicked tab contents
    // ui.index   // zero-based index of the selected (clicked) tab
    
    

});



});
