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

//Tipsy tooltip 
//$(document).ready(function() {
//  $('div.overview a.plugin_link').tipsy({gravity: 'n', delayIn: 500, live:true, opacity: 0.8 });
//});

$(function() {
  var $plugins = $('#webyast_plugins');
  var $data = $plugins.clone();
  var $sortedData = $data.find('li');
  var $filters = $('#filter').find('label.quicksand_button');

   $('#filter label').bind('click', function() {
     $filters.removeClass('quicksand_button_active');
     $(this).addClass('quicksand_button_active');
     
     if($(this).attr('value') == "All") {
        $sortedData = $data.find('li');
     } else {
        $sortedData = $data.find('li[data-type=' + $(this).attr('value') + ']');
     }
     quicksort($plugins, $sortedData)
   })
});

hideFilters = function() {
  $('#filter_all').removeClass('quicksand_button_active');
  $('#hidden_filters').fadeOut();
}

//TODO Save timeout ID and reset if all button is clicked
//TODO Stop timeout if user mouseovered buttons
$(function() {
  var $all = $('#filter_all');
  var $recent = $('#filter_recent');
  $all.click(function() {
    $('#hidden_filters').fadeIn();
    $('#filter_recent').hide();
    $(this).addClass('quicksand_button_active');
  })
});

initTipsyTooltip = function() {
  $('#webyast_plugins').find('li').unbind('mouseenter mouseleave');
  $('#webyast_plugins').find('a.plugin_link').tipsy({gravity: 'n', offset: 17, delayIn: 500, live:false, opacity: 0.7 });
}

var quicksort = function ($plugins, $data) {
 $plugins.find('a').unbind();
 
 $plugins.quicksand($data, {
    duration: 400,
 	  adjustHeight: 'dynamic',
    easing: 'easeInOutQuad'
    }, function() { 
      setTimeout(initTipsyTooltip, 100);
    }
  ); 
}
        
function sortCallbackFunc(a,b){
  if(a.value == b.value){
    if(a.value == b.value){
      return 0;
    }
    return (a.value > b.value) ? -1 : 1;
  }
  return (a.value > b.value) ? -1 : 1;
}


function sortAlphabetically(a,b){
  return $(a).find('strong').innerHTML > $(b).find('strong').innerHTML ? 1 : -1; 
}

//Track recently used modules
//TODO: improve modules tracking, use LIFO (Last In – First Out)
$(function() {
  //console.time('modules_tracking');
  //localStorage.clear()
  if(localstorage_supported() && localStorage.length != 0) { 
    var $list =  $('#webyast_plugins').find('li');
    var array = [];
    var $collection = [];
    
    $list.each(function(index, element) { 
      if($(element).attr('id') in localStorage) {
        array.push({name: $(element).attr('id'), value: localStorage.getItem($(element).attr('id'))})
        //console.log($(element).find('strong').text() + ' ' + localStorage.getItem($(element).attr('id')))
        $collection.push(element)
      }
    });
    

    if(array.length > 5) {
      array = array.sort(sortCallbackFunc).splice(0, 5);
    } else {
      array = array.sort(sortCallbackFunc);
    }
    
    var $sorted = [];
    
    for(i=0; i< array.length; i++) {
      for(j=0; j< $collection.length; j++) {
        if($($collection[j]).attr('id') == array[i].name) {
          $sorted.push($collection[j]);
        }
      }
    }

    //INFO: Control panel index page - insert elements without quick sand animation
    $('#webyast_plugins').html($sorted);
    trackRecent();

  } else {
    var $data = $('#webyast_plugins').clone();
    $data = $data.find('li.main');
    if($data.length > 5) { 
      $data = $data.sort(sortAlphabetically).splice(0, 5); 
    }
    quicksort($('#webyast_plugins'), $data)
    trackRecent();
  }
  //console.timeEnd('modules_tracking');
})

function trackRecent() {
  if(localstorage_supported()) {
   $('#webyast_plugins li').live('click', function(e) {
      if($(this).attr('id') in localStorage) {
        var value = parseInt(localStorage.getItem($(this).attr('id'))) + 1;
        localStorage.setItem($(this).attr('id'), value);
      } else {
        localStorage.setItem($(this).attr('id'), 1);
      }
    });
  }
}

