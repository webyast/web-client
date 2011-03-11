var log = function(message) { 
  if (typeof(console) != 'undefined' && typeof(console.log) == 'function'){ console.log(message); } else { return false }
}

function pageRefresh() { self.location = window.location.href; }

//TODO: call twice???
function stopNotifierPlugin(worker) {
  var stop = { stop: function() { return this.timer }};
  var activityTimer = jQuery.extend($.activity, stop);

  if(activityTimer && worker) { 
    worker.terminate();
    clearInterval($.activity.stop()); 
    log("Stop JQuery activity check & terminate running worker!")
  } 
}

function startNotifier(params, interval, inactive) {
  killWorkerOnReload(Notifier(params));

  $(document).ready(function() {
    jQuery(function($){
      $.activity.init({
  	interval: interval, 
  	inactive: inactive, 
	
	intervalFn: function(){
	  log("User is idle: " + Math.round((this.now() - this.defaults.lastActive)/1000) + ' sec');
	},
	inactiveFn: function(){
	  log("User is inactive: " + Math.round((this.now() - this.defaults.lastActive)/1000)  + ' sec');
	  killWorker(worker);
	  $.activity.update();
	}
      });
      
    $(document).bind('click mousemove', function(){
	if($.activity.isActive()) {
	  $.activity.update();
	} else {
	  log("User active start worker and reactivate activity check!");
	  Notifier(params);
	  $.activity.reActivate();
	}
      });
    });
  })
}

var Notifier = function(params) {
  if(typeof(Worker) == 'undefined') {
    setInterval(AJAXcall, 5000, params);
  } else {
    worker = new Worker("/javascripts/notifier.workers.js");
    worker.postMessage(params);
    
    worker.onmessage = function(event) {
      switch(event.data){
	case '200':
	  log("RELOAD is NEEDED: " + event.data);
	  stopNotifierPlugin(this);
	  $('body').append('<div id="warningModalShade"/>').append('<div id="warningModal"><img src="/images/cache-warning.png" style="">Cash is out-of-date!</div>');
	  worker.terminate();
	  setTimeout('pageRefresh()', 2000)
	  break
	case '304':
	  log("CACHE is UP-TO-DATE: " + event.data); 
	  break
	  
	default : 
	  log("ERROR: unknown HTTP status: " + event.data);
	  break
      }
    };

    worker.onerror = function(error) {
      console.error(error);
    };

    return worker;
  }
}

var AJAXcall = function(params) {
  $.getJSON("/notifier?plugin="+params.module+"&id="+params.id, function(data, status, jqXHR) {
    data.NaN? data = data : data = data.toString();
    switch(data){
      case '200':
	log("RELOAD is NEEDED: " + data);
	stopNotifierPlugin(worker);
	$('body').append('<div id="warningModalShade"/>').append('<div id="warningModal"><img src="/images/cache-warning.png" style="">Cash is out-of-date!</div>');
	setTimeout('pageRefresh()', 2000)
	break
      case '304':
	log("CACHE is UP-TO-DATE: " + data); 
	break
      default : 
	log("ERROR: unknown HTTP status: " + data + typeof(data));
	break
    }
  })
}

var killWorker = function(worker) {
  if(worker && typeof(Worker) != 'undefined') {
     stopNotifierPlugin(worker);
  }
}

var killWorkerOnReload = function(worker, intervalID) {
  $(function(){
    window.onbeforeunload = function(){
      if(worker && typeof(Worker) != 'undefined') {
	stopNotifierPlugin(worker);
      }
    }
  });
}
