var xhr = new XMLHttpRequest();

function XHRrequest(url, auth_token) {
  self.url = url;
  self.token = auth_token;
  data='params=user&id=1'
  
  if(xhr) {    
    xhr.open('get', url);
    xhr.setRequestHeader('Content-Type', 'application/x-www-form-urlencoded');
    xhr.send(auth_token);
    
    xhr.onreadystatechange = function() {
      if(xhr.readyState == 4) {
	if (xhr.status == 200) {
	  postMessage(xhr.responseText);
	  setTimeout("XHRrequest(self.url, self.token)", 30000);
	} 
      }
    }
    
  }
}

self.addEventListener('message', function(e) {
  var data = e.data;
  switch (data.plugin) {
    case 'patches':
      var url = '/patch_updates/show_summary?background=true';
      XHRrequest(url, data.token);
      break;
    case 'status':
      var url = '/status/show_summary?background=true';
      XHRrequest(url, data.token);
      break;
    default:
      self.postMessage('Unknown command: ' + data.msg);
  };
}, false);
