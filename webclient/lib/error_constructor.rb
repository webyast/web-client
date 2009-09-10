# To change this template, choose Tools | Templates
# and open the template in the editor.

module ErrorConstructor    
  def construct_error (error)
    #now use stupid unlocalized message
    return error["error"]["description"]
  end
end
