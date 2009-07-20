$(document).ready(function() {
  
  // Change BG Colour on mouseover and change it back on mouse out
  $('.highlight-bg').mouseover(function() {
    $(this).addClass('grey-bg'); // add class for highlighting
  }).mouseout(function() {
    $(this).removeClass('grey-bg'); // remove class for highlighting
  });
  
  // Make more usable password-input-field
  // http://blog.decaf.de/2009/07/iphone-like-password-fields-using-jquery/
  $('input:password').dPassword({
    duration: 400 // How long will last typed in letter be displayed
  });
  
});
