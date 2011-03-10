function startNotifier(params, interval, inactive) {
  killWorkerOnReload(Notifier(params));
   
  $(document).ready(function() {
    jQuery(function($){
      $.activity.init({
  	interval: interval, 
  	inactive: inactive, 
	
	intervalFn: function(){
	  if (typeof(console) != 'undefined' && typeof(console.log) == 'function'){ console.log("User is idle: " + Math.round((this.now() - this.defaults.lastActive)/1000) + ' sec'); }
	},
	inactiveFn: function(){
	  if (typeof(console) != 'undefined' && typeof(console.warn) == 'function'){ console.warn("User is inactive: " + Math.round((this.now() - this.defaults.lastActive)/1000)  + ' sec'); }
	  killWorker(worker);
	  $.activity.update();
	}
      });
      
    $(document).bind('click mousemove', function(){
	if($.activity.isActive()) {
	  $.activity.update();
	} else {
	  if (typeof(console) != 'undefined' && typeof(console.log) == 'function'){ console.log("User active start worker and reactivate activity check!"); }
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
	  if (typeof(console) != 'undefined' && typeof(console.log) == 'function'){ console.log("RELOAD is NEEDED status: " + event.data); }
	  disableFormOnSubmit('<img src="/images/warning-big.png" style="display:inline; vertical-align:middle; height:28px; width:28px;"><span style="font-size:18px; color:#555> Cache is out-of-date</span>');  
	  
	  self.location = window.location.href;
	  break

	case '304':
	  if (typeof(console) != 'undefined' && typeof(console.log) == 'function'){ console.log("CACHE is UP-TO-DATE status: " + event.data); }
	  break
	  
	default : 
	  if (typeof(console) != 'undefined' && typeof(console.log) == 'function'){ console.log("ERROR: unknown http status " + status); }
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
	if (typeof(console) != 'undefined' && typeof(console.log) == 'function'){ console.log("RELOAD is NEEDED status: " + data); }
	disableFormOnSubmit('<img src="/images/warning-big.png" style="display:inline; vertical-align:middle; height:28px; width:28px;"><span style="font-size:18px; color:#555> Cache is out-of-date</span>');  
	self.location = window.location.href;
	break

      case '304':
	if (typeof(console) != 'undefined' && typeof(console.log) == 'function'){ console.log("CACHE is UP-TO-DATE status: " + data); }
	break
	
      default : 
	if (typeof(console) != 'undefined' && typeof(console.log) == 'function') { console.log("ERROR: unknown http status " + data + typeof(data)); }
	break
    }
  })
}

var killWorker = function(worker) {
  if(worker && typeof(Worker) != 'undefined') {
    if (typeof(console) != 'undefined' && typeof(console.info) == 'function'){ console.info("Kill running worker!"); }
    if (typeof(console) != 'undefined' && typeof(console.info) == 'function'){ console.info("Terminate activity check!"); }
    worker.terminate();
    $(document).unbind($.activity);
  }
}

var killWorkerOnReload = function(worker, intervalID) {
//   $(document).ready(function() {
  $(function(){
    window.onbeforeunload = function(){
      if(worker && typeof(Worker) != 'undefined') {
	if (typeof(console) != 'undefined' && typeof(console.info) == 'function'){ console.info("Terminate all running workers!"); }
	
	worker.terminate();
	if (typeof(console) != 'undefined' && typeof(console.info) == 'function'){ console.info("Unbind activity check!"); }
      }
    }
  });
}
