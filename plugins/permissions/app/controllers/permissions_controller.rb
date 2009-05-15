class PermissionsController < ApplicationController
  before_filter :login_required
  layout "main"

 # Initialize GetText and Content-Type.
  init_gettext "yast_webclient_permission"  # textdomain, options(:charset, :content_type)


  # Checks the tree if there is a node which is set to the value of "grant"
  # and check if the subtree has to be shown
  def show_subtree (tree, grant)
     return false if !tree
     show = false
     tree.each do |key, branches|
	if (key == :grant)
           if branches == true
              if (grant == true) #the complete subtree is granted
                 show = true
              else
                 show = false #it make no sense anymore cause the complete subtree is granted
              end
              break # do not calculate the subtrees
           end
           if (tree.size <= 2 &&
               branches == grant)
              #last branch reached, so take this result
              show = true
              break
           end
        else
           if (branches.is_a?(Hash) &&
               branches.size > 0)
              tree_show = show_subtree( branches, grant )
              if (tree_show==true)
                 show = true
                 if (grant==true)
                    break #show it in each case; do not regard root grant
                 end
              end
           end
        end
     end
     return show
  end
  
  def construct_permission_tree()
     @permissions.each do |permission|
        sub = @permission_tree
        permission_split = permission.name.split("-")
        permission_split.each do |dir|
           sub = sub[dir] 
        end
        sub[:grant] = permission.grant
        sub[:path] = permission.name
     end
  end

  def build_java_variable( tree, level, grant, take_all, user, java_string )
     tree.each do |key, branch|
        if branch.is_a? Hash
           if (show_subtree(branch, grant) || #there is at least one item set to "grant"
               take_all)                   #or the rest should be simply taken
              java_string += "#{level}, { label: \"#{key}\", href:\""
              if branch.has_key?(:path) && @write_permission==nil
                java_string += url_for(:controller => controller_name(),
                                      :action => grant ? "revoke" : "grant",
                                      :id => branch[:path],
                                      :user => user,
                                      :only_path => true)
              end
              java_string += "\" },\n"
              #taking the subtrees too
              next_take_all = take_all
              if (branch.has_key?(:grant) &&
                  grant &&
                  branch[:grant] == true)
                  next_take_all = true
                  #logger.debug "#{branch[:path]} is granted. So all other subtrees are granted"
              end
              java_string = build_java_variable( branch, level+1, grant, next_take_all, user, java_string )
           end
        end
     end
     return java_string
  end

  def get_permissions(user, get_perm_from_server)
    @current_user = nil
    if get_perm_from_server
       path = "/users/#{user}/permissions.xml"
       @permissions = Permission.find(:all, :from => path)
       if @permissions[0].error_id != 0
          return @permissions[0].error_string
       end
    end
    @current_user = user
#    logger.debug "permissions of user #{@current_user}: #{@permissions.inspect}"
    @permission_tree = Hash.new{ |h,k| h[k] = Hash.new &h.default_proc }
    construct_permission_tree()
#    logger.debug "Complete Tree: #{@permission_tree.to_xml}"

    #@grant_data = "var grant_data = \n [];" 
    @grant_data = build_java_variable( @permission_tree, 0, true, false, @current_user, "var grant_data = \n [" )    
    @grant_data += "];"
#    logger.debug "Grant Tree: #{@grant_data}"

    @revoke_data = build_java_variable( @permission_tree, 0, false, false, @current_user, "var revoke_data = \n [" )    
    @revoke_data += "];"
#    logger.debug "Revoke Tree: #{@revoke_data}"
    return "" # no error
  end

  def set_permission(user, grant)
    get_permissions(params[:user].rstrip, true)
    error = ""
    for i in 0..@permissions.size-1 do
       if  @permissions[i].name == params[:id]
          if @permissions[i].grant != grant
             perm = Permission.new()
             perm.id = @current_user
             perm.grant = grant
             perm.error_id = 0
             perm.error_string = ""     
             perm.name = params[:id]     

             path = "permissions/#{params[:id]}"
             response = perm.put(path, {}, perm.to_xml)
             ret_perm = Hash.from_xml(response.body) 
             if grant
                logger.debug "Granting returns: #{ret_perm.inspect}"
             else
                logger.debug "Revoking returns: #{ret_perm.inspect}"
             end
             if ret_perm["permissions"][0]["error_id"] == 0
                @permissions[i].grant = grant
             else
                error = ret_perm["permissions"][0]["error_string"]
             end
          else
             logger.debug "Permission already set"
          end
       end
       # reset the rest of the subtree
       if (error == "" &&
           @permissions[i].name.index(params[:id]+"-") == 0 &&
           @permissions[i].grant == true)
          perm = Permission.new()
          perm.id = @current_user
          perm.grant = false
          perm.error_id = 0
          perm.error_string = ""     
          perm.name = @permissions[i].name

          path = "permissions/#{perm.name}"
          response = perm.put(path, {}, perm.to_xml)
          ret_perm = Hash.from_xml(response.body) 
          logger.debug "Granting returns: #{ret_perm.inspect}"
          if ret_perm["permissions"][0]["error_id"] == 0
             @permissions[i].grant = false
          else
             error = ret_perm["permissions"][0]["error_string"]
          end
       end
    end
    if error != ""
       #build completely new
       get_permissions(params[:user].rstrip,true)
    else
       get_permissions(params[:user].rstrip,false)
    end
    return error
  end

  def grant
    error = set_permission(params[:user].rstrip, true)
    if error == ""
       flash[:notice] = _("Permission has been granted.")
    else
       flash[:error] = error
    end
    render :action => "index" 
  end

  def revoke
    error = set_permission(params[:user].rstrip, false)
    if error == ""
       flash[:notice] = _("Permission has been revoked.")
    else
       flash[:error] = error
    end
    render :action => "index" 
  end

  def search
    set_permissions(controller_name)
    flash[:error] = get_permissions(params[:user].rstrip, true)
    render :action => "index" 
  end

  def index
  end
end
