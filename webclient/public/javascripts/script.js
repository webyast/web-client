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

// $('.ui-tab-parent').tabs('.ui-tab-parent > fieldset');
// $('.tabs').tabs('fieldset');

// $('.ui-tab-parent').bind('tabsselect', function(event, ui) {
// 
//     // Objects available in the function context:
//     // ui.tab     // anchor element of the selected (clicked) tab
//     // ui.panel   // element, that contains the selected/clicked tab contents
//     // ui.index   // zero-based index of the selected (clicked) tab
//     
//     
// 
// });

$('.tab-form fieldset').hide();

var arrTabs = new Array;

$('.tab-form fieldset legend').each(function(index) {
  var tabTitle = $(this).html();  // get string from legent to have a tab-title
  var tabID = tabTitle.toLowerCase().replace(' ', '_'); // create id compatibel string
  
  $('.tab-nav').append('<li><a href="#' + tabID + '">' + tabTitle + '</a></li>'); // make tab bar
  
  $(this).parent('fieldset').attr('id', tabID);
  
  $('.tab-form fieldset:first').show();
});

$('.tab-nav a').click(function() {
  // var curTab = $(this).attr('href').substr(1);
  var curTab = $(this).attr('href');
  // alert(curTab);
  $(curTab).show().siblings('fieldset').hide();
});




});
