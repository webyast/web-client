/*
# Copyright (c) 2009-2010 Novell, Inc.
# 
# All Rights Reserved.
# 
# This program is free software; you can redistribute it and/or modify it
# under the terms of version 2 of the GNU General Public License
# as published by the Free Software Foundation.
# 
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU General Public License for more details.
# 
# You should have received a copy of the GNU General Public License
# along with this program; if not, contact Novell, Inc.
# 
# To contact Novell about this file by physical or electronic mail,
# you may find current contact information at www.novell.com
*/

// using replace instead of trim() see bnc#580561
function _trim(word){
  return word.replace(/^\s*|\s*$/g,'');
}

function _getElementsByClassName(node, classname)  {
    if(!node) node = document.getElementsByTagName("body")[0];
    var a = [];
    var re = new RegExp('\\b' + classname + '\\b');
    var els = node.getElementsByTagName("*");
    for(var i=0,j=els.length; i<j; i++)
        if(re.test(els[i].className))a.push(els[i]);
    return a;
}



 // onsubmit handler
 function form_handler(sid) {
   if ($('#form_' + sid).valid())
   {
     disable_forms();
     $('#progress_' + sid).show();
     return true;
   }
   else
   {
     return false;
   }
 }

// delete button handler
function delete_handler(which, progress){
 if (which.childElementCount == 2 && which.children[0].firstChild.textContent == "Delete"){
  which.childNodes[0].onclick="return false;";
  which.childNodes[0].href="";
  disable_forms();
  $(progress).show();
 }
}

function members_validation(which){
  var mygroups = [];
  if (_trim(which.value).length>0) mygroups = which.value.split(",");
  var allgroups = $("#all_users_string")[0].value.split(",");
  errmsg="";
  for (i=0;i<mygroups.length;i++){
    var found=false;
    for(a=0;a<allgroups.length;a++){
     if (allgroups[a]==_trim(mygroups[i])) found=true;
    }
    if (!found){
     errmsg = mygroups[i]+" "+"is not valid user!" ;
    }
  }
  _getElementsByClassName(which.parentNode.parentNode, 'error')[0].innerHTML = errmsg;
  _getElementsByClassName(which.parentNode.parentNode, 'error')[0].style.display= (errmsg.length==0) ? "none" : "block";
  return (errmsg.length==0);
}


function set_tab_focus(tab){
  $("#accordion").accordion('activate',$("#tab_"+tab).children("legend"));
}


function findById(where, id){
 var node=null;
 for(var i=0;i<where.length;i++){
  if (where[i].id==id) node=where[i];
 }
 return node;
}


function groups_validation(which){
  var mygroups = _trim(findById(which.parentNode.getElementsByTagName('input'), "user_grp_string").value);
  if (mygroups.length>0) mygroups = mygroups.split(",");
  var allgroups = $("#all_grps_string")[0].value.split(",");
  errmsg="";
  for (i=0;i<mygroups.length;i++){
    var found=false;
    for(a=0;a<allgroups.length;a++){
     if (allgroups[a]==_trim(mygroups[i])) found=true;
    }
    if (!found){
     errmsg = mygroups[i]+" "+"is not valid group!" ;
    }
  }
  set_tab_focus("groups")
  var error = findById(which.parentNode.parentNode.parentNode.getElementsByTagName('label'), "groups-error");
  error.innerHTML = errmsg;
  error.style.display= (errmsg.length==0) ? "none" : "block";
  return (errmsg.length==0);
}

function def_group_validation(which){
  var mygroup = _trim(findById(which.parentNode.getElementsByTagName('input'), "user_groupname").value);
  var allgroups = $("#all_grps_string")[0].value.split(",");
  errmsg="";

   if (mygroup.length>0){
    var found=false;
    for(a=0;a<allgroups.length;a++){
     if (allgroups[a]==_trim(mygroup)) found=true;
    }
    if (!found){
     errmsg = mygroup+" "+"is not valid group!" ;
    }
   }

  set_tab_focus("groups")
  var error = findById(which.parentNode.parentNode.parentNode.getElementsByTagName('label'), "def-group-error");
  error.innerHTML = errmsg;
  error.style.display= (errmsg.length==0) ? "none" : "block";
  return (errmsg.length==0);
}

function new_user_validation(which){
  var valid = true;
  if (valid && ($('#form_').validate().element('#user_uid')==false || $('#form_').validate().element('#user_user_password')==false)){
	$(".fieldset-group.ui-tabs").tabs('select',"#tab_login");
	valid = false;
  }
  if (valid && (groups_validation($('#user_grp_string')[0])==false || def_group_validation($('#user_groupname')[0])==false)){
	$(".fieldset-group.ui-tabs").tabs('select',"#tab_groups");
	valid = false;
  }
  if (valid && $('#form_').validate().element('#user_uid_number')==false){
	$(".fieldset-group.ui-tabs").tabs('select',"#tab_advanced");
	valid = false;
  }

  return valid;
}

function edit_user_validation(which, username){
  var valid = true;
  var form = '#form_'+username;
  if (valid && ($(form).validate().element(form+' #user_uid')==false || $(form).validate().element(form+' #user_user_password')==false || $(form).validate().element(form+' #user_user_password2')==false)){
	$(".tabs_"+username).tabs('select',"#tab_login_"+username);
	valid = false;
  }
  if (valid && (groups_validation($(form+' #user_grp_string')[0])==false || def_group_validation($(form+' #user_groupname')[0])==false)){
	$(".tabs_"+username).tabs('select',"#tab_groups_"+username);
	valid = false;
  }
  if (valid && $(form).validate().element(form+' #user_uid_number')==false){
	$(".tabs_"+username).tabs('select',"#tab_advanced_"+username);
	valid = false;
  }

  return valid;

}


function propose_home(which){
 var login    = findById(which.parentNode.getElementsByTagName('input'), "user_uid").value;
 var home     = findById(which.parentNode.getElementsByTagName('input'), "user_home_directory").value;

  home = "/home/"+login;

 if (login.length>0) findById(which.parentNode.getElementsByTagName('input'), "user_home_directory").value = home;
}

function propose_login(which){
 var fullname = findById(which.parentNode.getElementsByTagName('input'), "user_cn").value;
 var login    = findById(which.parentNode.getElementsByTagName('input'), "user_uid").value;

 if (login.length==0){
  login = fullname.replace(/\s/g, '').toLowerCase();
  findById(which.parentNode.getElementsByTagName('input'), "user_uid").value = login;
  propose_home(which.parentNode);
 }
} 
 
