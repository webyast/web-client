//Tipsy tooltip 
$(document).ready(function() {
  $('div.overview a.plugin_link').tipsy({gravity: 'n', delayIn: 500, live:true, opacity: 0.8 });
});

//Quick Sand ???????????
(function($) {
  $.fn.sorted = function(customOptions) {
    var options = {
      reversed: true,
      by: function(a) { return a.text(); }
    };
    $.extend(options, customOptions);
    $data = $(this);
    arr = $data.get();
    arr.sort(function(a, b) {
      var valA = options.by($(a));
      var valB = options.by($(b));
      if (options.reversed) {
        return (valA < valB) ? 1 : (valA > valB) ? -1 : 0;
      } else {
        return (valA < valB) ? -1 : (valA > valB) ? 1 : 0;
      }
    });
    
    return $(arr);
  };
})(jQuery);


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
        
        $sortedData = $sortedData.sorted({
        by: function(v) {
          return parseFloat($(v).find('li[data-type=' + $(this).attr('value') + ']'));
        }
      });
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
        setTimeout(hideFilters, 6000)
    })
});

var quicksort = function ($plugins, $data) {
   $plugins.quicksand($data, {
      easing: "swing"
   });
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

//Track recently used modules
$(function() {
  //localStorage.clear()
  //console.time('tracker');
  if(localstorage_supported() && localStorage.length != 0) { 
    var $list =  $('#webyast_plugins').find('li');
    var array = [];
    var $collection = [];
    
    $list.each(function(index, element) { 
      if($(element).attr('id') in localStorage) {
        array.push({name: $(element).attr('id'), value: localStorage.getItem($(element).attr('id'))})
        $collection.push(element)
      }
    });
    

    if(array.length > 5) {
      array = array.sort(sortCallbackFunc).splice(0, 5);
    }
    
    var $sorted = [];
    
    for(i=0; i< array.length; i++) {
      for(j=0; j< $collection.length; j++) {
        if($($collection[j]).attr('id') == array[i].name) {
          $sorted.push($collection[j]);
        }
      }
    }
    
    var $plugins = $('#webyast_plugins');
    quicksort($plugins, $sorted)

    
    $('#webyast_plugins li').live('click', function(e) {
      if($(this).attr('id') in localStorage) {
        var value = parseInt(localStorage.getItem($(this).attr('id'))) + 1;
        localStorage.setItem($(this).attr('id'), value);
        e.preventDefault
        return false;
      } else {
        localStorage.setItem($(this).attr('id'), 1);
        return false;
      }
    });
    

  } else {
    var $data = $('#webyast_plugins').clone();
    $data = $data.find('li.main');
    
    quicksort($('#webyast_plugins'), $data)
    
    if(localstorage_supported()) {
      $('#webyast_plugins li').live('click', function(e) {
        if($(this).attr('id') in localStorage) {
          var value = parseInt(localStorage.getItem($(this).attr('id'))) + 1;
          localStorage.setItem($(this).attr('id'), value);
          e.preventDefault
          return false;
        } else {
          localStorage.setItem($(this).attr('id'), 1);
          return false;
        }
      });
    }
 
  }
//  console.timeEnd('tracker');
})



