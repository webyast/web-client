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

(function($){
  $.fn.extend({
    center: function (element) {
      return this.each(function() {
	var elemTop= $(element).position().top;
	var elemHeight = ($(this).outerHeight(true));
	var top = (elemTop + (elemHeight/2)) - ($(this).height()/2)+2;
	var left = $(element).position().left + ($(element).outerWidth()/2) - ($(this).outerWidth()/2);
	$(this).css({position:'absolute', margin:0, top: (top > 0 ? top : 0)+'px', left: (left > 0 ? left : 0)+'px'});
      });
    },

    right: function (element) {
      return this.each(function() {
	var elemTop= $(element).position().top;
	var elemHeight = ($(this).outerHeight(true));
	var top = (elemTop + (elemHeight/2)) - ($(this).height()/2);
	var left = ($(element).outerWidth()-$(this).width());
	$(this).css({position:'absolute', margin:0, top: (top > 0 ? top : 0)+'px', left: (left > 0 ? left : 0)+'px'});
      });
    }
  }); 
})(jQuery);

function checkUsername($user, $role) {
  var array = new Array();
  var $users = $role.find('span');

  $users.each(function(i,u) {
    array.push($.trim($(u).text()))
  });

  if(jQuery.inArray($user.text(), array) == -1) {
    return false;
  } else {
    return true;
  }
}

function showWarning(id) {
  $warning = $(id).find('span.roles_warning');
  $warning.queue(function(){ 
    setTimeout(function(){ 
      $warning.dequeue(); 
    }, 400 ); 
  }); 

  $warning.center(id).fadeIn(500);
  $warning.fadeIn(500); 

  $warning.queue(function(){ 
    setTimeout(function(){ 
      $warning.dequeue(); 
    }, 500 ); 
  }); 

  $warning.hide('fast'); 
}

function assignUserToRole($user, $role) {
  var parentID = $role.find(':input').attr('id');
  var inputValue = $role.find(':input').val();
    
  $user.attr('alt', parentID);

  if(inputValue.length==0) {
    $role.find(':input').val($user.text());
  } else {
    $role.find(':input').val(inputValue + ',' + $user.text());
  }
}

function trim(string) { return string.replace (/^\s+/, '').replace (/\s+$/, ''); }

jQuery(function($){
  // SHOW and HIDE search toolbox
  $('div#jqueryTab ul.ui-tabs-nav li a').bind('click', function() {
    if($(this).attr('href') == "#assignUsers") {
      $('#toolbox').show(); 
    } else {
      $('#toolbox').hide();
    }
  });

  //EVENT DELIGATION FOR "DYNAMIC" ADDED USERS
  $('img.deleteUser').live('click', function() {
    var $parentNode = $(this).parent();
    var array = $('#' + $parentNode.attr('alt')).val().split(",");
    var result = new Array;
    var subString = $parentNode.text();
    for (var i=0; i<array.length; i++) { if (array[i] != trim(subString)) { result.push(array[i]); } }
     $parentNode.remove();
    $('#' + $parentNode.attr('alt')).val(result.toString());
  });

  //EVENT DELIGATION FOR "DYNAMIC" ADDED USERS
  $('span.assigned').live('hover', function(event){
    if (event.type =='mouseover'){
      $(this).append('<img class="deleteUser" src="../images/delete-user.png">')
      return false;
    }else {
      $(this).find('img').remove();
      return false;
    }
  });
  
  //QUICK SEARCH
  $('#find_user').focus(function(event) {
    $('img#resetSearchField').fadeIn(50);
    $('div.slider-nav a').css('visibility', 'hidden');
  }).focusout(function() {
    $('img#resetSearchField').fadeOut(200);
    $('div.slider-nav a').css('visibility', 'visible');
  });

  //RESET FORM
   $('#resetSearchField').bind('click', function() {
    $('#find_user').val('');
    $('#find_user').keyup();
  });

  //INIT
  $('#find_user').quicksearch('div.slider-content span', {
    'loader': '#loader',
    'show': function () {
      this.style.color = '';
    },
    'hide': function () {
      this.style.color = '#ccc';
    },
    'onBefore': function () {
      $('#loader').css('visibility', 'visible');
    },
    'onAfter': function () {
      var $find = $('#find_user');
      if($find.val() && $find.val().substr(0,1).length !=0 ) {
	var slider = $('div#usersContent.users'); $(slider).addClass('slider');
	target = '#' + $('#find_user').val().substr(0,1);
	var cOffset = $('.slider-content', slider).offset().top;
	var tOffset = $('.slider-content '+target, slider).offset().top;
	var height = $('.slider-nav', slider).height();
	var pScroll = (tOffset - cOffset) - height/8;
	$('.slider-content li', slider).removeClass('selected');
	$(target).addClass('selected');
	$('.slider-content', slider).stop().animate({scrollTop: '+=' + pScroll + 'px'});
      } 
    }
  });

  //   DRAG n DROP
  $('.drag')
    .drag("start",function(ev, dd){
	$( dd.available ).addClass('drop-available');
	return $( this ).clone()
	  .addClass('drag-active')
	  .appendTo( document.body);
      })

    .drag(function( ev, dd ){
      $( dd.proxy ).css({
	top: dd.offsetY,
	left: dd.offsetX
      });
    })

    .drag("end",function( ev, dd ){
      $( dd.available ).removeClass('drop-available');
	if($(dd.drop).hasClass('drop')) {
	  $(dd.proxy).removeClass('drag-active').removeClass('drag');
	} else {
	  $( dd.proxy ).remove();
	}
    });

  $('span.drop')
    .live("drop",function( ev, dd ){
      if(checkUsername($(ev.target), $(this))) {
	showWarning($(this));
	$(this).effect("highlight", {color:'#fbb'}, 400);
	if($(ev.target).hasClass('drag')) { $(ev.target).remove(); }
      } else {
	$(ev.target).removeClass('drag').addClass('assigned'); //user
	$(this).append(ev.target).effect("highlight", {color:'#AEE6A8'}, 400); 
	assignUserToRole($(ev.target), $(this));
      }
  })
});