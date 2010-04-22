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
   function set_tab_focus(tab){
     $("#accordion").accordion('activate',$("#tab_"+tab).children("legend"));
   }

  // using replace instead of trim() see bnc#580561
  function _trim(word){
    return word.replace(/^\s*|\s*$/g,'');
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
     var error = findById(which.parentNode.getElementsByTagName('label'), "groups-error");
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

  // fill user and groups containers
  function _initializeDragContainer(a_groups,containername){
   var container=document.getElementById(containername);
   while(container.hasChildNodes()){
	container.removeChild(container.lastChild);
   }
   for(var i=0;i<a_groups.length;i++){
     var div = document.createElement('div');
     div.setAttribute('id', _trim(a_groups[i]));
     div.setAttribute('class', 'GBox');
     div.innerHTML=_trim(a_groups[i]);
     container.appendChild(div);
   }
  }

  function _find_in_all(group, mygroups){
   var found=false;
   for(i=0;i<mygroups.length;i++){
     if (mygroups[i]==group) found=true;
   }
   return found;
  }

  // open groups "popup" dialog
  function open_groups_dialog(){
   var mygroups=[];
   if ( _trim($('#user_grp_string')[0].value).length>0 )
	 mygroups = $('#user_grp_string')[0].value.split(",");
   _initializeDragContainer(mygroups,'ContainerUser');

   var allgroups = $('#all_grps_string')[0].value.split(",").sort();
   var filtered_groups=[];
   for (var i=0;i<allgroups.length;i++){
     if (!_find_in_all(allgroups[i], mygroups))
	 filtered_groups=filtered_groups.concat([allgroups[i]]);
   }
   _initializeDragContainer(filtered_groups,'ContainerGroups');

   $('#groups').dialog({ buttons: { 'Ok': function() { store_groups(this); }, 'Cancel': function() { $(this).dialog('close'); } } });
   $('#groups').dialog('option', 'width', 580);
   $('#groups').dialog('option', 'position', 'center');
   $('#groups').dialog('open');
  }

  // open popup to select default group
  function open_def_group_dialog(){
   var allgroups = $('#all_grps_string')[0].value.split(",").sort();
   _initializeDragContainer(allgroups,'ContainerDefaultGroup');

   $('#def_group').dialog();
   $('#def_group').dialog('option', 'width', 480);
   $('#def_group').dialog('option', 'position', 'center');
   $('#def_group').dialog('open');
  }

  // store groups from popup dialog
  function store_groups(dlg){
    var user = $('#ContainerUser')[0].childNodes;
    var groups="";
    for (i=0;i<user.length;i++){
     groups+=user[i].innerHTML;
     if (i<user.length-1) groups+=",";
    }
    $('#user_grp_string')[0].value=groups;
    $(dlg).dialog('close');
  }


  function moveItem(e,target){
   // this hack is for support both firefox and chrome
   var item = (typeof(e.srcElement) != "undefined") ? e.srcElement : e.originalTarget;
    if(item.className=='GBox'){
	 $("#"+item.parentNode.id+' #'+item.id).appendTo($('#'+target));
	 var u_size  = $('#ContainerUser')[0].childNodes.length;
	 var u_width  = $('#ContainerUser')[0].clientWidth;
	 var u_cols=(u_width-10)/100;

	 var g_size = $('#ContainerGroups')[0].childNodes.length;
	 var g_width  = $('#ContainerGroups')[0].clientWidth;
	 var g_cols=(g_width-10)/100;
	if ( target=="ContainerUser" && Math.ceil(u_size/u_cols)>Math.ceil(g_size/g_cols) && g_cols>1){
	 u_cols+=1;
	 g_cols-=1;
	}
	if (target=="ContainerGroups" && Math.ceil(u_size/u_cols)<Math.ceil(g_size/g_cols) && u_cols>1){
	 u_cols-=1;
	 g_cols+=1;
	}
	
	 $('#ContainerUser')[0].style.cssText="width: "+u_cols*100+"px;";
	 $('#ContainerGroups')[0].style.cssText="width: "+g_cols*100+"px;";
	 
    }
  }

  function selectItem(e){
   var item = (typeof(e.srcElement) != "undefined") ? e.srcElement : e.originalTarget;
    if(item.className=='GBox'){
    $('#user_groupname')[0].value=item.id;
    $("#def_group").dialog('close');
    }
  }

function validate_login(){
 var login    = $("#user_uid")[0].value;

 return false;
}
 
function propose_home(){
 var login    = $("#user_uid")[0].value;
 var home     = $("#user_home_directory")[0].value;

  home = "/home/"+login;

 if (login.length>0) findById(which.parentNode.getElementsByTagName('input'), "user_home_directory").value = home;
}

function propose_login(){
 var fullname = $("#user_cn")[0].value;
 var login    = $("#user_uid")[0].value;

 if (login.length==0){
  login = fullname.replace(/\s/g, '').toLowerCase();
  $("#user_uid")[0].value = login;
  propose_home();
 }

} 

   function edit_user_validation(){
     valid=false;
     password_validation_enabled = true;
     valid = $('#userForm').validate().element('#user_user_password2');
     valid = valid && $('#userForm').validate().element('#user_uid');
     if (!valid) set_tab_focus("login");
     if (!$('#userForm').validate().element('#user_uid_number')){
       valid=false;
       set_tab_focus("advanced");
     }
     valid = valid && groups_validation();
     return valid;
   }

