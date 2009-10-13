require 'yast/service_resource'

class PermissionsController < ApplicationController
  before_filter :login_required
  layout "main"

  private
  def client_permissions
    login = YaST::ServiceResource::Session.login
    perm_resource = OpenStruct.new(:href => '/permissions', :singular => false, :interface => 'org.opensuse.yast.webservice.permissions')
    proxy = YaST::ServiceResource.class_for_resource(perm_resource)
    unless proxy
      flash[:notice] = _("Invalid session, please login again.")
      redirect_to( logout_path ) and return nil
    end
    @right_set_permissions = false
    @right_get_permissions = false
    permissions = proxy.find(:all, :params => { :user_id => login, :filter => 'org.opensuse.yast.permissions' })
    permissions.each do |permission|
      if permission.name == "org.opensuse.yast.permissions.write" &&
        permission.grant
        @right_set_permissions = true
      end
      if permission.name == "org.opensuse.yast.permissions.read" &&
        permission.grant
        @right_get_permissions = true
      end
    end
    return proxy
  end

 # Initialize GetText and Content-Type.
  init_gettext "yast_webclient_permission"  # textdomain, options(:charset, :content_type)

  public
  def initialize
  end


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
        #do not regard org.opensuse.yast. in the tree
        if permission.name.starts_with?("org.opensuse.yast.")
          permission_name = permission.name["org.opensuse.yast.".size, permission.name.size-1]
        else
         permission_name = permission.name
        end
        permission_name = permission_name.tr("-", ".")
        permission_split = permission_name.split(".")
        permission_split.each do |dir|
           sub = sub[dir] 
        end
        sub[:grant] = permission.grant
        sub[:path] = permission.name
     end
  end

  def build_data( tree, level, grant, take_all, user, data_list )
     tree.each do |key, branch|
        if branch.is_a? Hash
           if (show_subtree(branch, grant) || #there is at least one item set to "grant"
               take_all)                   #or the rest should be simply taken
              node = Hash.new
              node[:level] = level
              node[:label] = key
              node[:path] = branch[:path] if branch.has_key?(:path)
              #taking the subtrees too
              next_take_all = take_all
              if (branch.has_key?(:grant) &&
                  grant &&
                  branch[:grant] == true)
                  next_take_all = true
                  #logger.debug "#{branch[:path]} is granted. So all other subtrees are granted"
              end
              data_list << node
              data_list = build_data( branch, level+1, grant, next_take_all, user, data_list )
           end
        end
     end
     return data_list
  end

  def get_permissions(user, get_perm_from_server, proxy)
    @current_user = nil
    if get_perm_from_server
      begin
         @permissions = proxy.find(:all, :params => { :user_id => user })
      rescue ActiveResource::ClientError => e
        return YaST::ServiceResource.error(e)
      rescue Exception => e
        es = "AIEEE, #{e}"
        logger.debug es
        return es
      end
    end
    @current_user = user
#   logger.debug "permissions of user #{@current_user}: #{@permissions.inspect}"
    @permission_tree = Hash.new{ |h,k| h[k] = Hash.new &h.default_proc }
    construct_permission_tree()
#    logger.debug "Complete Tree: #{@permission_tree.to_xml}"

    @grant_data = build_data( @permission_tree, 1, true, false, @current_user, [] )    
#    logger.debug "Grant Tree: #{@grant_data.inspect}"

    @revoke_data = build_data( @permission_tree, 1, false, false, @current_user, [] )    
#    logger.debug "Revoke Tree: #{@revoke_data.inspect}"
    return "" # no error
  end


  def set
    proxy = client_permissions
    return unless proxy
    error = get_permissions(params[:user].rstrip, true, proxy)
    if !error.blank?
      flash[:error] = error
      render :action => "index" and return
    end  
    response = true
    params.each do |key, value|
      if value == "grant" || value == "revoke"
        for i in 0..@permissions.size-1 do
          if  @permissions[i].name == key
            @permissions[i].grant = true if value == "grant"
            @permissions[i].grant = false if value == "revoke"
            begin
              @permissions[i].id = params[:user].rstrip
              response =  @permissions[i].save
              logger.debug "writing permissions #{@permissions[i].inspect}: #{response}"
              rescue ActiveResource::ClientError => e
                flash[:error] = YaST::ServiceResource.error(e)
                response = false
                break
            end
          end
        end        
      end
      break unless response
    end
    flash[:notice] = _("Permissions have been set.") if response
    error = get_permissions(params[:user].rstrip, true, proxy)
    flash[:error] = error if !error.blank?
    render :action => "index" 
  end

  def search
    proxy = client_permissions
    return unless proxy
    response = get_permissions(params[:user].rstrip, true, proxy)
    flash[:error] = response unless response.empty?
    render :action => "index" 
  end

  def index
    return unless client_permissions
  end
end
