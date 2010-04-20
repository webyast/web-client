//BACKUP
//var host ="([A-Za-z0-9])(([\\.\\-]?[a-zA-Z0-9]+)*)"; //\\.([A-Za-z]{2,}
//http://regexlib.com/REDetails.aspx?regexp_id=333
//Hostname part: ([A-Za-z0-9]+)(([\\.\\-]?[a-zA-Z0-9]+)*)\\.([A-Za-z]{2,})
//^([a-zA-Z0-9]([a-zA-Z0-9\-]{0,61}[a-zA-Z0-9])?\.)+[a-zA-Z]{2,6}$)


var protocol = "(http|https|ftp)";
// FQDN: http://regexlib.com/REDetails.aspx?regexp_id=391
var host = "([a-zA-Z0-9](([\\.\\-]?[a-zA-Z0-9]+){0,61}[a-zA-Z0-9]))+[a-zA-Z0-9]*";

// FQDN: http://regexlib.com/REDetails.aspx?regexp_id=391
var fqdn = "([a-zA-Z0-9]([a-zA-Z0-9\\-]{0,61}[a-zA-Z0-9])?\\.)+[a-zA-Z]{2,6}";
var port ="(:[0-9]{1,5}|)";

// IPv4: http://regexlib.com/REDetails.aspx?regexp_id=32
var ipv4 = "^(25[0-5]|2[0-4][0-9]|[0-1]{1}[0-9]{2}|[1-9]{1}[0-9]{1}|[1-9])\\.(25[0-5]|2[0-4][0-9]|[0-1]{1}[0-9]{2}|[1-9]{1}[0-9]{1}|[1-9]|0)\\.(25[0-5]|2[0-4][0-9]|[0-1]{1}[0-9]{2}|[1-9]{1}[0-9]{1}|[1-9]|0)\\.(25[0-5]|2[0-4][0-9]|[0-1]{1}[0-9]{2}|[1-9]{1}[0-9]{1}|[0-9])$";
// IPv6: http://regexlib.com/REDetails.aspx?regexp_id=906 + allow lowercase hexa letters (a-f)
var ipv6 = "(^(([0-9A-Fa-f]{1,4}(((:[0-9A-Fa-f]{1,4}){5}::[0-9A-Fa-f]{1,4})|((:[0-9A-Fa-f]{1,4}){4}::[0-9A-Fa-f]{1,4}(:[0-9A-Fa-f]{1,4}){0,1})|((:[0-9A-Fa-f]{1,4}){3}::[0-9A-Fa-f]{1,4}(:[0-9A-Fa-f]{1,4}){0,2})|((:[0-9A-Fa-f]{1,4}){2}::[0-9A-Fa-f]{1,4}(:[0-9A-Fa-f]{1,4}){0,3})|(:[0-9A-Fa-f]{1,4}::[0-9A-Fa-f]{1,4}(:[0-9A-Fa-f]{1,4}){0,4})|(::[0-9A-Fa-f]{1,4}(:[0-9A-Fa-f]{1,4}){0,5})|(:[0-9A-Fa-f]{1,4}){7}))$|^(::[0-9A-Fa-f]{1,4}(:[0-9A-Fa-f]{1,4}){0,6})$)|^::$)|^((([0-9A-Fa-f]{1,4}(((:[0-9A-Fa-f]{1,4}){3}::([0-9A-Fa-f]{1,4}){1})|((:[0-9A-Fa-f]{1,4}){2}::[0-9A-Fa-f]{1,4}(:[0-9A-Fa-f]{1,4}){0,1})|((:[0-9A-Fa-f]{1,4}){1}::[0-9A-Fa-f]{1,4}(:[0-9A-Fa-f]{1,4}){0,2})|(::[0-9A-Fa-f]{1,4}(:[0-9A-Fa-f]{1,4}){0,3})|((:[0-9A-Fa-f]{1,4}){0,5})))|([:]{2}[0-9A-Fa-f]{1,4}(:[0-9A-Fa-f]{1,4}){0,4})):|::)((25[0-5]|2[0-4][0-9]|[0-1]?[0-9]{0,2})\\.){3}(25[0-5]|2[0-4][0-9]|[0-1]?[0-9]{0,2})$$";
//Username http://regexlib.com/REDetails.aspx?regexp_id=333
var mail = "[A-Za-z0-9](([\\_\\.\\-]?[a-zA-Z0-9]+)*)";

var subnetmask = "^\/([12]?[0-9]|3[0-2])$";
var default_route = "^(0\\.0\\.0\\.0)$";

http://regexlib.com/REDetails.aspx?regexp_id=248
var time = "^(([0-1][0-9])|([2][0-3])):([0-5][0-9]):([0-5][0-9])$";

http://regexlib.com/REDetails.aspx?regexp_id=60
var date = "^[0,1]?\d{1}\/(([0-2]?\d{1})|([3][0,1]{1}))\/(([1]{1}[9]{1}[9]{1}\d{1})|([2-9]{1}\d{3}))$";

//get all labels with class="error" in the input form or fieldset
function getElementsByClass(searchClass, domNode, tagName) {
  var elements = new Array();
  var parent = document.getElementById(domNode);

  var tags = parent.getElementsByTagName(tagName);
  var tcl = " "+searchClass+" ";
  for(i=0,j=0; i<tags.length; i++) {
	 var test = " " + tags[i].className + " ";
	 if (test.indexOf(tcl) != -1) {
		elements[j++] = tags[i];
	 }
  }
  return elements;
}

function validateDomainName(domain)
{
	 jQuery.validator.addMethod(domain, function(value, element) {
		var regExp = new RegExp("^"+fqdn+"$");
      var ip4 = new RegExp(ipv4);
      var ip6 = new RegExp(ipv6);
		return this.optional(element) 
		  || regExp.test(value)
        || ip4.test(value)
        || ip6.test(value);
	 });
}

//Cannot enter valid domain bnc#598102
//use host name regexp instead of domain name (match: suse, suse.de, stealth.suse.de, www.stealth.suse.de)
function validateDomainNameWithAndWithoutTLD(domain)
{
	 jQuery.validator.addMethod(domain, function(value, element) {
		var regExp = new RegExp("^"+host+"$");
		return this.optional(element) 
		  || regExp.test(value)
	 });
}

function validateDomainNameWithPortNumber(domain)
{
	 jQuery.validator.addMethod(domain, function(value, element) {
		var regExp = new RegExp("^"+fqdn+port+"$");
      var ip4 = new RegExp(ipv4);
      var ip6 = new RegExp(ipv6);
		return this.optional(element) 
		  || regExp.test(value)
        || ip4.test(value)
        || ip6.test(value);
	 });
}

function validateIPv4(ip) {
  jQuery.validator.addMethod(ip, function(value, element) {
      var ip4 = new RegExp(ipv4);
		var temp = this.optional(element);
		return this.optional(element) 
        || ip4.test(value)
  });
}

function validateSubnetMask(netmask) {
  jQuery.validator.addMethod(netmask, function(value, element) {
      var ip4 = new RegExp(ipv4);
		var smask = new RegExp(subnetmask);
		return this.optional(element) 
        || ip4.test(value)
		  || smask.test(value)
  });
}

function validateDefaultRoute(ip) {
  jQuery.validator.addMethod(ip, function(value, element) {
      var ip4 = new RegExp(ipv4);
		var def_route = new RegExp(default_route);
		return this.optional(element) 
        || ip4.test(value)
		  || def_route.test(value)
  });
}

function validateHostName(hostname)
{
	 jQuery.validator.addMethod(hostname, function(value, element) {
    var regExp = new RegExp("^"+host+"$");
	 return this.optional(element) 
		|| regExp.test(value);
	 });
}

function validateURL(url)
{
	 jQuery.validator.addMethod(url, function(value, element) {
    var regExp = new RegExp("^"+protocol+"://"+fqdn+"$");
	 return this.optional(element) 
		|| regExp.test(value);
	 });
}

function validateEmail(email)
{
   jQuery.validator.addMethod(email, function(value, element) {
    var regExp = new RegExp("^"+mail+"@"+fqdn+"$");
	 return this.optional(element) 
		|| regExp.test(value);
	 });
}

function validateTime(ctime) {
  jQuery.validator.addMethod(ctime, function(value, element) {
    var regExp = new RegExp(time);
	 return this.optional(element) 
		|| regExp.test(value);
	 });
}

function validateDate(cdate) {
  jQuery.validator.addMethod(cdate, function(value, element) {
    var regExp = new RegExp(date);
	 return this.optional(element) 
		|| regExp.test(value);
	 });
}

