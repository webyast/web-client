function XHRrequest(module, id, auth_token) {
  var xhr = new XMLHttpRequest();
  self.module = module;
  self.id = id;
  
  url = '/notifier?plugin='+self.module+'&id='+self.id;

  if(xhr) {    
    xhr.open('get', url);
    xhr.setRequestHeader('Content-Type', 'application/x-www-form-urlencoded');
    xhr.send();
    
    xhr.onreadystatechange = function() {
      if(xhr.readyState == 4) {
	if (xhr.status == 200) {
	  postMessage(xhr.responseText);
	  setTimeout(XHRrequest, 3000, self.module, self.id);
	} else {
	  postMessage(xhr.readyState);
	  postMessage(xhr.status);
	  self.close();
	  self.terminate();
	}
      }
    }
  }
}

onmessage = function(event) {
  var target = event.data;
  XHRrequest(target.module, target.id);
}
