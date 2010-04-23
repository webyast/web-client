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
  which.parentNode.parentNode.getElementsByClassName("error")[0].innerHTML = errmsg;
  which.parentNode.parentNode.getElementsByClassName("error")[0].style.display= (errmsg.length==0) ? "none" : "block";
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


function new_user_validation(which){
  var valid = $('#userForm').valid();
  // if UID is invalidate, do Show Details (make it visible)
  if ($("#user_uid_number")[0].className.indexOf("error")!=-1) $('#showdetails')[0].children[0].onclick();
  valid = valid && groups_validation(which.parentNode);
  return valid;
}

function edit_user_validation(which, form){
  valid=false;
  password_validation_enabled = true;
  valid = $(form).validate().element('#user_user_password2');
  valid = valid && $(form).validate().element('#user_uid');
  if (!valid) set_tab_focus("login");
  if (!$(form).validate().element('#user_uid_number')){
    valid=false;
    set_tab_focus("advanced");
  }
  valid = valid && groups_validation(which);
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
 
