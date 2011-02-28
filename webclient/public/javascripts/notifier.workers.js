function XHRrequest(module, id, auth_token) {
  var xhr = new XMLHttpRequest();
  
  self.module = module;
  self.auth_token = auth_token;
  
  if(typeof id !== 'undefined') { 
    self.id = id;
    var url = '/notifier?plugin='+self.module+'&id='+self.id; 
  } else {
    var url = '/notifier?plugin='+self.module;
  }
  
  if(xhr) {    
    xhr.open('get', url);
    xhr.setRequestHeader('Content-Type', 'application/x-www-form-urlencoded');
    xhr.send(self.auth_token);
    
    xhr.onreadystatechange = function() {
      if(xhr.readyState == 4) {
	if (xhr.status == 200) {
	  postMessage(xhr.responseText);
	  if(self.id !='#') {
	    setTimeout(XHRrequest, 3000, self.module, self.id, self.auth_token);
	  } else {
	    setTimeout(XHRrequest, 3000, self.module, self.auth_token);
	  }
	} else {
	  postMessage(xhr.status);
	  self.close();
	}
      }
    }
  }
}

onmessage = function(event) {
  var target = event.data;
  XHRrequest(target.module, target.id, target.AUTH_TOKEN);
}
