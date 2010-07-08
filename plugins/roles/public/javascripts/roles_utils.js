/**
#--
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
#++
*/
function hide_descrs() {
	$("#descriptions > p").hide();
}

function show_desc(id) {
	hide_descrs();
	$("#"+id+"-description").show();
}

function grant_perm(id) {
	$("#"+id+"-g").css("display","list-item");
	$("#"+id+"-a").css("display","none");
	renew_hidden();
}

function revoke_perm(id){
	$("#"+id+"-a").css("display","list-item");
	$("#"+id+"-g").css("display","none");
	renew_hidden();
}

function renew_hidden(){
	var new_val = [];
	$.each($("#granted_perm li:not(:hidden)"),function(i,val){
		var len = val.id.length;
		new_val.push (val.id.substring(0,len-2))});
	$("#assigned_perms")[0].value = new_val.join(',');

	new_val = [];
	$.each($("#users_assigned li:not(:hidden)"),function(i,val){
		var len = val.id.length;
		new_val.push (val.id.substring(0,len-2))});
	$("#assigned_users")[0].value = new_val.join(',');
}
