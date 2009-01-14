class PermissionsController < ApplicationController
  layout "main"

  # Checks the tree if there is a node which is set to the value of "grant"
  # and check if the subtree has to be shown
  def showSubtree (tree, grant)
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
              treeShow = showSubtree( branches, grant )
              if (treeShow==true)
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
  
  def constructPermissionTree()
     @permissions.each do |permission|
        sub = @permissionTree
        permissionSplit = permission.attributes["name"].split("-")
        permissionSplit.each do |dir|
           sub = sub[dir] 
        end
        sub[:grant] = permission.attributes["grant"]
        sub[:path] = permission.attributes["name"]
     end
  end

  def buildJavaVariable( tree, level, grant, takeAll, user, javaString )
     tree.each do |key, branch|
        if branch.is_a? Hash
           if (showSubtree(branch, grant) || #there is at least one item set to "grant"
               takeAll)                   #or the rest should be simply taken
              javaString += "#{level}, { label: \"#{key}\", href:\""
              if branch.has_key?(:path)
                javaString += url_for(:controller => controller_name(),
                                      :action => grant ? "revoke" : "grant",
                                      :id => branch[:path],
                                      :user => user,
                                      :only_path => true)
              end
              javaString += "\" },\n"
              #taking the subtrees too
              nextTakeAll = takeAll
              if (branch.has_key?(:grant) &&
                  grant &&
                  branch[:grant] == true)
                  nextTakeAll = true
                  #logger.debug "#{branch[:path]} is granted. So all other subtrees are granted"
              end
              javaString = buildJavaVariable( branch, level+1, grant, nextTakeAll, user, javaString )
           end
        end
     end
     return javaString
  end

  def getPermissions(user, getPermFromServer)
    @currentUser = user
    if getPermFromServer
       path = "/users/#{@currentUser}/permissions.xml"
       @permissions = Permission.find(:all, :from => path)
    end
#    logger.debug "permissions of user #{@currentUser}: #{@permissions.inspect}"
    @permissionTree = Hash.new{ |h,k| h[k] = Hash.new &h.default_proc }
    constructPermissionTree()
#    logger.debug "Complete Tree: #{@permissionTree.to_xml}"

    #@grant_data = "var grant_data = \n [];" 
    @grant_data = buildJavaVariable( @permissionTree, 0, true, false, @currentUser, "var grant_data = \n [" )    
    @grant_data += "];"
#    logger.debug "Grant Tree: #{@grant_data}"

    @revoke_data = buildJavaVariable( @permissionTree, 0, false, false, @currentUser, "var revoke_data = \n [" )    
    @revoke_data += "];"
#    logger.debug "Revoke Tree: #{@revoke_data}"
  end

  def setPermission(user, grant)
    getPermissions(params[:user].rstrip, true)
    error = false
    for i in 0..@permissions.size-1 do
       if  @permissions[i].attributes["name"] == params[:id]
          if @permissions[i].attributes["grant"] != grant
             perm = Permission.new()
             perm.id = @currentUser
             perm.grant = grant
             perm.error_id = 0
             perm.error_string = ""     
             perm.name = params[:id]     

             path = "permissions/#{params[:id]}"
             response = perm.put(path, {}, perm.to_xml)
             retPerm = Hash.from_xml(response.body) 
             logger.debug "Granting returns: #{retPerm.inspect}"
             if retPerm["permissions"][0]["error_id"] == 0
                @permissions[i].attributes["grant"] = grant
             else
                error = true
             end
          else
             logger.debug "Permission already set"
          end
       end
       # reset the rest of the subtree
       if (@permissions[i].attributes["name"].index(params[:id]+"-") == 0 &&
           @permissions[i].attributes["grant"] == true)
          perm = Permission.new()
          perm.id = @currentUser
          perm.grant = false
          perm.error_id = 0
          perm.error_string = ""     
          perm.name = @permissions[i].attributes["name"]

          path = "permissions/#{perm.name}"
          response = perm.put(path, {}, perm.to_xml)
          retPerm = Hash.from_xml(response.body) 
          logger.debug "Granting returns: #{retPerm.inspect}"
          if retPerm["permissions"][0]["error_id"] == 0
             @permissions[i].attributes["grant"] = false
          else
             error = true
          end
       end
    end
    if error
       #build completely new
       getPermissions(params[:user].rstrip,true)
    else
       getPermissions(params[:user].rstrip,false)
    end
  end

  def grant
    setPermission(params[:user].rstrip, true)
    render :action => "index" 
  end

  def revoke
    setPermission(params[:user].rstrip, false)
    render :action => "index" 
  end

  def search
    getPermissions(params[:user].rstrip, true)
    render :action => "index" 
  end

  def index
  end
end
