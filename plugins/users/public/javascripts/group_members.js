
  // using replace instead of trim() see bnc#580561
  function _trim(word){
    return word.replace(/^\s*|\s*$/g,'');
  }


  // fill members and group containers
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

  // open members "popup" dialog
  function open_users_dialog(){
   var mygroups=[];
   if ( _trim($('#group_members_string')[0].value).length>0 )
	 mygroups = $('#group_members_string')[0].value.split(",");
   _initializeDragContainer(mygroups,'ContainerUser');

   var allgroups = $('#all_users_string')[0].value.split(",").sort();
   var filtered_groups=[];
   for (var i=0;i<allgroups.length;i++){
     if (!_find_in_all(allgroups[i], mygroups))
	 filtered_groups=filtered_groups.concat([allgroups[i]]);
   }
   _initializeDragContainer(filtered_groups,'ContainerGroups');

   $('#members').dialog({ buttons: { 'Ok': function() { store_users(this); }, 'Cancel': function() { $(this).dialog('close'); } } });
   $('#members').dialog('option', 'width', 580);
   $('#members').dialog('option', 'position', 'center');
   $('#members').dialog('open');
  }

  // store members from popup dialog
  function store_users(dlg){
    var user = $('#ContainerUser')[0].childNodes;
    var groups="";
    for (i=0;i<user.length;i++){
     groups+=user[i].innerHTML;
     if (i<user.length-1) groups+=",";
    }
    $('#group_members_string')[0].value=groups;
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

