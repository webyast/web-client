class PermissionController < ApplicationController
  layout "main"


  # Checks the tree if there is a node which is set to the value of "grant"
  def findGrant (tree, grant)
     return false if !tree
     found = false
     tree.each do |key, branches|
	if (key == :grant &&
           branches == grant )
           found = true
           break
        else
           if branches.is_a? Hash
              found = findGrant( branches, grant )
              if found == true
                 break
              end
           end
        end
     end
     return found
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
           if (findGrant(branch, grant) || #there is at least one item set to "grant"
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
              if (branch.has_key?(:grant) &&
                  grant &&
                  branch[:grant] == true)
                  nextTakeAll = true
                  logger.debug "#{branch[:path]} is granted. So all other subtrees are granted"
              end
              javaString = buildJavaVariable( branch, level+1, grant, nextTakeAll, user, javaString )
           end
        end
     end
     return javaString
  end

  def search
    path = "/users/#{params[:user].rstrip}/permissions.xml"
    @permissions = Permission.find(:all, :from => path)
    logger.debug "permissions of user #{params[:user].rstrip}: #{@permissions.inspect}"
    @permissionTree = Hash.new{ |h,k| h[k] = Hash.new &h.default_proc }
    constructPermissionTree()
    logger.debug "Complete Tree: #{@permissionTree.to_xml}"


    @grant_data = buildJavaVariable( @permissionTree, 0, true, false, params[:user].rstrip, "var grant_data = \n [" )    
    @grant_data += "];"
    logger.debug "Grant Tree: #{@grant_data}"

    @revoke_data = buildJavaVariable( @permissionTree, 0, false, false, params[:user].rstrip, "var revoke_data = \n [" )    
    @revoke_data += "];"
    logger.debug "Revoke Tree: #{@revoke_data}"

    render :action => "index" 
  end

  def index
  end
end
