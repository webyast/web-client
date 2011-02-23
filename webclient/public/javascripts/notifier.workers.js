function XHRrequest(module, id, auth_token) {
  var xhr = new XMLHttpRequest();
  data='params='+module+'id='+id;
  self.data = data;
  self.auth_token = auth_token;
  if(xhr) {    
    xhr.open('get', '/notifier');
    xhr.setRequestHeader('Content-Type', 'application/x-www-form-urlencoded');
//     xhr.send();
    xhr.send(auth_token);
    
    xhr.onreadystatechange = function() {
      
      if(xhr.readyState == 4) {
	if (xhr.status == 200) {
	  postMessage(xhr.responseText);
	  setTimeout(XHRrequest, 3000, self.data);
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
