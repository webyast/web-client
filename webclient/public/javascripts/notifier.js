var AJAXcall = function(params) {
  $.getJSON("/notifier?plugin="+params.module+"&id="+params.id, function(data, textStatus, jqXHR) {
    $('#timeoutMessage').css('background', '#f6f6f6').css('color', '#800000').fadeIn().text('Attention: Cache is out-of-date, performing page refresh!').delay(5000).fadeOut();;
  })
}

// var Notifier = function(worker, params) {
var Notifier = function(params) {
  if(typeof(Worker) == 'undefined') {
    console.info("DEBUG: AJAX call in MAIN THREAD");
    setInterval(AJAXcall, 3000, params);
  } else {
    console.info("DEBUG: AJAX call in WORKER THREAD");
    worker = new Worker("/javascripts/notifier.workers.js");
    
    console.log(params.module)
    if(typeof id === 'undefined') {
      console.log("UNDEFINED")
      console.log(params.id)
    }
    console.log(params.AUTH_TOKEN)
    
    worker.postMessage(params);
    
    worker.onmessage = function(event) {
      if(event.data == 'reload') { location.reload(); }
      if(event.data == '304') { console.log(event.data) }
    };

    worker.onerror = function(error) {
      console.error(error);
    };
    
    return worker;
  }
}

var killWorker = function(worker) {
  console.info("Terminate all running workers!");
  worker.terminate();
}

var killWorkerOnReload = function(worker, intervalID) {
  $(document).ready(function() {
    window.onbeforeunload = function(){
      console.info("Terminate all running workers!");
      worker.terminate();
    }
  });
}