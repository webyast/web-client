   function set_tab_focus(tab){
     $("#accordion").accordion('activate',$("#tab_"+tab).children("legend"));
   }

   function groups_validation(){
     var mygroups = [];
     if ($('#user_grp_string')[0].value.trim().length>0) mygroups = $('#user_grp_string')[0].value.split(",");
     var allgroups = $("#all_grps_string")[0].value.split(",");
     errmsg="";
     for (i=0;i<mygroups.length;i++){
       var found=false;
       for(a=0;a<allgroups.length;a++){
	if (allgroups[a]==mygroups[i]) found=true;
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
     div.setAttribute('id', a_groups[i].trim());
     div.setAttribute('class', 'GBox');
     div.innerHTML=a_groups[i].trim();
     container.appendChild(div);
   }
  }

  function _filter_all_groups(group){
   var mygroups=[];
   if ($('#user_grp_string')[0].value.trim().length>0) mygroups = $('#user_grp_string')[0].value.split(",");
   var found=false;
   for(i=0;i<mygroups.length;i++){
     if (mygroups[i]==group) found=true;
   }
   return !found;
  }

  // open groups "popup" dialog
  function open_groups_dialog(){
   var mygroups=[];
   if ($('#user_grp_string')[0].value.trim().length>0) mygroups = $('#user_grp_string')[0].value.split(",");
   _initializeDragContainer(mygroups,'ContainerUser');

   var allgroups = $('#all_grps_string')[0].value.split(",").sort();
   allgroups=allgroups.filter(_filter_all_groups);
   _initializeDragContainer(allgroups,'ContainerGroups');

   $('#groups').dialog({ buttons: { 'Ok': function() { store_groups(this); }, 'Cancel': function() { $(this).dialog('close'); } } });
   $('#groups').dialog('option', 'width', 580);
   $('#groups').dialog('option', 'position', 'center');
   $('#groups').dialog('open');
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
    if(item.className=='GBox') $('#'+item.id).appendTo($('#'+target));
  }
