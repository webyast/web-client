#--
# Webyast Webservice framework
#
# Copyright (C) 2009, 2010 Novell, Inc. 
#   This library is free software; you can redistribute it and/or modify
# it only under the terms of version 2.1 of the GNU Lesser General Public
# License as published by the Free Software Foundation. 
#
#   This library is distributed in the hope that it will be useful, but WITHOUT
# ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
# FOR A PARTICULAR PURPOSE. See the GNU Lesser General Public License for more 
# details. 
#
#   You should have received a copy of the GNU Lesser General Public
# License along with this library; if not, write to the Free Software 
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
#++
require "yaml"
require 'gettext'

module YAML
  def YAML.translate(node)
    if node.is_a? Hash
      node.each do |key,data|
        node[key] = translate data
      end
    elsif node.is_a? Array
      counter = 0
      node.each do |data|
        node[counter] = translate data
        counter +=1
      end
    elsif node.is_a? String
      node = node.strip
      if node =~ /^_\(\"/ && node =~ /\"\)$/
        node = _(node[3..node.length-3]) #try to translate it
      end
    end
    return node
  end 

  def YAML.load( io )
    yp = translate parser.load( io )
    return yp
  end

end
