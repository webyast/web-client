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

