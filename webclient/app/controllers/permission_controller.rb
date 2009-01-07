class PermissionController < ApplicationController
  layout "main"

  def keyFind (tree, findKey)
     return false if !tree
     found = false
     tree.each do |key, branches|
	if key == findKey
           found = true
           break
        else
           found = keyFind( branches, findKey )
           if found == true
              break
           end
        end
     end
     return found
  end

  def constructPermissions ( pattern, level, granted)
     hash = {}
     @permissions.each do |permission|
        if permission.attributes["grant"] == granted 
           if ( pattern.size == 0 || #begin
                pattern == permission.attributes["name"] || #pattern fits completely with the name
                permission.attributes["name"].index(pattern+"-") == 0) #pattern fits

               #evaluate key
               if pattern != permission.attributes["name"]
                  permissionSplit = permission.attributes["name"].split("-")
                  for i in 0..level
                     if i == 0 
                        key = permissionSplit[i]
                     else
                        key = key + "-" + permissionSplit[i]
                     end
                  end
               else
                  key = pattern
               end

               if !keyFind (hash, key)
                 if pattern == permission.attributes["name"]
                    #last branch
                    hash[permission.attributes["name"]] = {}
                 else
                    #construct subtrees

		    if (hash.has_key?(pattern) ||
                       (pattern.size == 0 && hash.size > 0 ))
                       #merging of the already existing hash
                       newHash = constructPermissions( key, level+1, granted)
                       if (pattern.size == 0)
                          # we are root
                          hash = hash.merge(newHash)
                       else
                          hash[pattern] = hash[pattern].merge(newHash)
                       end
                    else
                       if (pattern.size == 0)
                          # we are root
                          hash = constructPermissions( key, level+1, granted)
                       else
                          hash[pattern] = constructPermissions( key, level+1, granted)
                       end
                    end
                 end
              end
           end
        end
     end
     return hash
  end

  def search
    path = "/users/#{params[:user].rstrip}/permissions.xml"
    @permissions = Permission.find(:all, :from => path)
#    logger.debug "permissions of user #{params[:user].rstrip}: #{@permissions.inspect}"

    @grant_tree = constructPermissions( "", 0, true)
#    logger.debug "grant tree #{@grant_tree.inspect}"
    @revoke_tree = constructPermissions ( "", 0, false)
#    logger.debug "revoke tree #{@revoke_tree.inspect}"

    @grant_data = "var grant_data = \n ["
    @grant_data += "];"
    @revoke_data = "var revoke_data = \n ["
    @revoke_data += "];"

    render :action => "index" 
  end

  def index
  end
end
