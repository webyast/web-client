$(document).ready(function() {
  
  // Change BG Colour on mouseover and change it back on mouse out
  $('.highlight-bg').mouseover(function() {
    $(this).addClass('grey-bg'); // add class for highlighting
  }).mouseout(function() {
    $(this).removeClass('grey-bg'); // remove class for highlighting
  });

  // Alternating Lines in "Tables"
  $('.alternate-rows > li:even').addClass('alt-bg');

});
