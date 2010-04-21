
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

