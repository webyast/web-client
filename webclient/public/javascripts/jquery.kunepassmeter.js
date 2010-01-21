/*
   Copyrights (C) 2007-2008 David Esperalta <davidesperalta@gmail.com>
   -> Modified by Mathieu BASILI <contact@kune.fr>

   This file is part of Pass Meter jQuery plugin for jQuery

   Pass Meter is free software: you can redistribute it and/or modify
   it under the terms of the GNU General Public License as published
   by the Free Software Foundation, either version 3 of the License,
   or (at your option) any later version.

   Pass Meter is distributed in the hope that it will be useful, but 
   WITHOUT ANY WARRANTY; without even the implied warranty of 
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU 
   General Public License for more details.

   You should have received a copy of the GNU General Public License
   along with Pass Meter. If not, see <http://www.gnu.org/licenses/>.

*/

/*
   ----------------------------------------------------
   Kune Pass Meter jQuery plugin for jQuery version 1.1
   ----------------------------------------------------

   The basics stay the same to use the plugin. The only modification
   is that you can use the plugin to display the strength meter 
   outside the password input.

   You can use this plugin to show a background image into a HTML 
   password input element to indicate the strength of the password.

   This plugin has been probed in the last versions of Firefox,
   Opera, Internet Explorer and Safari, with jQuery 1.2 version.   

   Use is quite simple, as you can view in the example that include
   the plugin. Bassically you can attach and detach password meters
   into HTML password input:

   <code>
	$('input#mypassword').attachPassMeter();
   </code>

   To detach a password meter you can use the other public method:

   <code>
	$('input#mypassword').detachPassMeter();
   </code>  

   You can especify some options to the plugin when call to the 
   first method. The default options are this: 

   <code>
   var options = {
	 imgsPath: './images/',
	 bgRepeat: 'no-repeat',
	 bgPosition: 'center right'
   };
   $('input#mypassword').attachPassMeter(options);
   </code>

   The most important options are the "imagsPath", used by plugin 
   to find the appropiate images to show the password meters.

   If you like, you can use other images in the plugin: only not 
   touch the name of the images, that the plugin needed intact.
   
   If you want to use the meter outside of the input, add the option:
   
   <code>
   var options = {
	 outsideElt = '#myelt'
   };
   $('input#mypassword').attachPassMeter(options);
   </code>
   
   were #myelt could be the class of your element or the id.

   This plugin is inspired by Password strength meter jQuery plugin 
   by Firas Kassem - http://phiras.wordpress.com/ In fact, the main 
   methods of the plugin is taken from the plugin of Firas. Thanks!

   Thanks so much too Mike Alsup for their article jQuery plugin 
   pattern: learningjquery.com/2007/10/a-plugin-development-pattern 
   
   And of course, thanks a lot David for your great plugin !

*/

(function($) {

  /* Public (exposed) methods */

  $.fn.attachPassMeter = function(options){
	var opts = $.extend({}, $.fn.attachPassMeter.defaults, options);
	return this.each(function() {
	  $this = $(this);
	  var o = $.meta ? $.extend({}, opts, $this.data()) : opts;
	  $this.keyup(function(){
		updatePassMeter(this, o);  
	  });
	  updatePassMeter(this, o);
	});
	return true;
  };

  $.fn.detachPassMeter = function(){
	return this.each(function() {
	  $this = $(this);
	  showEmptyPass(this);
	  $this.unbind('keyup');
	});
	return true;
  };  

  /* Public (exposed) default settings */

  $.fn.attachPassMeter.defaults = {
	imgsPath: './images/',
	bgRepeat: 'no-repeat',
	bgPosition: 'center right',
	outsideElt: ''
  };  

  /* Private members */

  var badPassResult = 0;
  var goodPassResult = 1;
  var shortPassResult = -1;
  var emptyPassResult = -2;
  var strongPassResult = 2;

  var badPassImg = 'badpass.png';
  var goodPassImg = 'goodpass.png';  
  var shortPassImg = 'shortpass.png';    
  var strongPassImg = 'strongpass.png';      

  function showBadPass(element, options){
	$(element).css('background-image', 
	 'url('+ options.imgsPath + badPassImg +')');
	return true;  
  };

  function showGoodPass(element, options){
	$(element).css('background-image', 
	 'url('+ options.imgsPath + goodPassImg +')');
	return true; 
  };

  function showShortPass(element, options){
	$(element).css('background-image', 
	 'url('+ options.imgsPath + shortPassImg +')');
	return true; 
  };

  function showStrongPass(element, options){
	$(element).css('background-image', 
	 'url('+ options.imgsPath + strongPassImg +')'); 
	return true; 
  };  

  function showEmptyPass(element){
	$(element).css('background-image', 'none');  
	return true; 
  };    


  function showBadPass2(element, options){
	$(element).html('<img src="'+ options.imgsPath + badPassImg +'" />');
	return true;  
  };

  function showGoodPass2(element, options){
	$(element).html('<img src="'+ options.imgsPath + goodPassImg +'" />');
	return true; 
  };

  function showShortPass2(element, options){
	$(element).html('<img src="'+ options.imgsPath + shortPassImg +'" />');
	return true; 
  };

  function showStrongPass2(element, options){
	$(element).html('<img src="'+ options.imgsPath + strongPassImg +'" />'); 
	return true; 
  };  

  function showEmptyPass2(element){
	$(element).html('');  
	return true; 
  };    



  function updatePassMeter(element, options){
	passStrength = passwordStrength($(element).val());
	if	(options.outsideElt == '')
		{
		$(element).css('background-repeat', options.bgRepeat);    
		$(element).css('background-position', options.bgPosition);        

	switch(passStrength){
	  case badPassResult: showBadPass(element, options); break;
	  case goodPassResult: showGoodPass(element, options); break;        
	  case shortPassResult: showShortPass(element, options); break;  
	  default: case emptyPassResult: showEmptyPass(element); break;              
	  case strongPassResult: showStrongPass(element, options); break;                                
	}
	}
	else
	{
		switch(passStrength){
		  case badPassResult: showBadPass2(options.outsideElt, options); break;
		  case goodPassResult: showGoodPass2(options.outsideElt, options); break;        
		  case shortPassResult: showShortPass2(options.outsideElt, options); break;  
		  default: case emptyPassResult: showEmptyPass2(options.outsideElt); break;              
		  case strongPassResult: showStrongPass2(options.outsideElt, options); break;                                
		}

	}
	return true;
  };  

  function checkRepetition(pLen, str){
	var res = '';
	for(i = 0; i < str.length; i++){
	  var repeated = true;
	  for(j = 0; j < pLen && (j + i + pLen) < str.length; j++){
		repeated = repeated && (str.charAt(j + i) == str.charAt(j + i + pLen));
	  }
	  if(j < pLen){
		repeated = false;
	  }
	  if(repeated){
		i += (pLen - 1);
		repeated = false;
	  }else{
		res += str.charAt(i);
	  }
	}
	return res;
  };       

  function passwordStrength(password){
	var score = 0;
	if(password.length == 0){
	  return emptyPassResult;
	}else if(password.length < 4 ){ 
	  return shortPassResult;
	}
	score += (password.length * 4);
	score += (checkRepetition(1, password).length - password.length);
	score += (checkRepetition(2, password).length - password.length);
	score += (checkRepetition(3, password).length - password.length);
	score += (checkRepetition(4, password).length - password.length);
	// password has 3 numbers
	if(password.match('/(.*[0-9].*[0-9].*[0-9])/')){
	  score += 5;
	} 
	// password has 2 sybols
	if(password.match('/(.*[!,@,#,$,%,^,&,*,?,_,~].*[!,@,#,$,%,^,&,*,?,_,~])/')){
	  score += 5;
	}    
	// password has Upper and Lower chars
	if(password.match('/([a-z].*[A-Z])|([A-Z].*[a-z])/')){
	  score += 10;
	}    
	// password has number and chars
	if(password.match('/([a-zA-Z])/') && password.match('/([0-9])/')){
	  score += 15;
	}
	// password has number and symbol
	if(password.match('/([!,@,#,$,%,^,&,*,?,_,~])/') 
	 && password.match('/([0-9])/')){
	   score += 15;
	}
	// password has char and symbol
	if(password.match('/([!,@,#,$,%,^,&,*,?,_,~])/') 
	 && password.match('/([a-zA-Z])/')){
	   score += 15;
	}
	// password is just a nubers or chars
	if(password.match('/^\w+$/') || password.match('/^\d+$/')){
	  score -= 10;
	}
	if(score < 0){
	  score = 0;
	}
	if(score > 100){
	  score = 100;
	}
	if(score < 34){
	  return badPassResult;
	}
	if(score < 68){
	  return goodPassResult;
	}
	return strongPassResult;
  };

})(jQuery);