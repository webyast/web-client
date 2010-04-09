   function set_tab_focus(tab){
     $("#accordion").accordion('activate',$("#tab_"+tab).children("legend"));
   }

  // using replace instead of trim() see bnc#580561
  function _trim(word){
//    return word.replace(/^s+/g,'').replace(/s+$/g,'');
    return word.replace(/^\s*|\s*$/g,'');
  }

   function groups_validation(){
     var mygroups = [];
     if (_trim($('#user_grp_string')[0].value).length>0) mygroups = $('#user_grp_string')[0].value.split(",");
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
     $("#groups-error")[0].innerHTML = errmsg;
     $("#groups-error")[0].style.display= (errmsg.length==0) ? "none" : "block";
     return (errmsg.length==0);
   }


   function new_user_validation(){
     var valid = $('#userForm').valid();
     // if UID is invalidate, do Show Details (make it visible)
     if ($("#user_uid_number")[0].className.indexOf("error")!=-1) $('#showdetails')[0].children[0].onclick();
     valid = valid && groups_validation();
     return valid;
   }

   function edit_user_validation(){
     valid=false;
     password_validation_enabled = true;
     valid = $('#userForm').validate().element('#user_user_password2');
     if (!valid) set_tab_focus("login");
     if (!$('#userForm').validate().element('#user_uid_number')){
       valid=false;
       set_tab_focus("advanced");
     }
     valid = valid && groups_validation();
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

function findById(where, id){
 var node=null;
 for(var i=0;i<where.length;i++){
  if (where[i].id==id) node=where[i];
 } 
 return node;
}
 
function propose_home(which){
 var login    = findById(which.parentNode.getElementsByTagName('input'), "user_uid").value;
 var home     = findById(which.parentNode.getElementsByTagName('input'), "user_home_directory").value;

  home = "/home/"+login;

 findById(which.parentNode.getElementsByTagName('input'), "user_home_directory").value = home;
}

function propose_login(which){
 var fullname = findById(which.parentNode.getElementsByTagName('input'), "user_cn").value;
 var login    = findById(which.parentNode.getElementsByTagName('input'), "user_uid").value;

 if (login.length==0){
  login = fullname.replace(/\s/g, '').toLowerCase();
  findById(which.parentNode.getElementsByTagName('input'), "user_uid").value = login;
  propose_home(which);
 }

} 

