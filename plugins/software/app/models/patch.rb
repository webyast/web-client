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

class Patch < ActiveResource::Base
  extend YastModel::Base
  model_interface :'org.opensuse.yast.system.patches'  # RORSCAN_ITL

  def self.install_patches patches
    to_install = []
    patches.each do |patch|
      to_install << Patch.new({:repo=>nil,
                             :kind=>nil,
                             :name=>nil,
                             :arch=>nil,
                             :version=>nil,
                             :summary=>nil,
                             :resolvable_id=>patch.resolvable_id})
    end
    do_install_patches to_install
  end

  def self.install_patches_by_id ids
    to_install = []
    ids.each do |id|
      to_install << Patch.new({:repo=>nil,
                             :kind=>nil,
                             :name=>nil,
                             :arch=>nil,
                             :version=>nil,
                             :summary=>nil,
                             :resolvable_id=>id})
    end
    do_install_patches to_install
  end

private
  def self.do_install_patches to_install
    to_install.each do |patch|
      begin
        patch.save
      rescue ActiveResource::ServerError => e
#expected exception about installation in progress
      end
    end
  end
end
