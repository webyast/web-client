/*
#--
# Webyast Webservice framework
#
# Copyright (C) 2009, 2010 Novell, Inc. 
#   This library is free software; you can redistribute it and/or modify
# it only under the terms of version 2.1 of the GNU Lesser General Public
# License as published by the Free Software Foundation. 
#
#   This library is distributed in the hope that it will be useful, but WITHOUT
# ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
# FOR A PARTICULAR PURPOSE. See the GNU Lesser General Public License for more 
# details. 
#
#   You should have received a copy of the GNU Lesser General Public
# License along with this library; if not, write to the Free Software 
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
#++
*/

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
  if ($('.tab-form').length == true) {
    $('.tab-form fieldset.tabbed').hide();
    var arrTabs = new Array;
    $('.tab-form fieldset legend').each(function(index) {
      var tabTitle = $(this).html();  // get string from legent to have a tab-title
      var tabID = tabTitle.toLowerCase().replace(' ', '_'); // create id compatibel string
      $('.tab-nav').append('<li><a class="' + tabID + '" href="#' + tabID + '">' + tabTitle + '</a></li>'); // make tab bar
      $(this).parent('fieldset.tabbed').attr('id', tabID); // set IDs in tabs
      $('.tab-form fieldset.tabbed:first').show(); //show 1st fieldset
    });

    $('.tab-nav a:first').addClass('selected'); // preselect 1st tab

    $('.tab-nav a').click(function() {
      $(this).closest('.tab-nav').find('a').removeClass('selected'); // remove old selection
      var curTab = $(this).attr('href'); // get current tab
      $(curTab).show().siblings('fieldset.tabbed').hide(); // show current and hide others
      $(this).addClass('selected'); // add class selected to current tab
      return false;
    });
  };
// Accordion: make area expandable by clicking anywhere in the collapsed part
  $(".ui-accordion-header").parent().click( function() {
    if ($(this).is(":has(legend.ui-accordion-header.ui-state-default)")) {
      $(".accordion").accordion('activate',$(this).children(".ui-accordion-header.ui-state-default"));
    };
  });
});
