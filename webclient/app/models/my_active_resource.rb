class MyActiveResource < ActiveResource::Base

#This is not defined in AcitveResource 2_1 but in 2_0 and 2_2
unless ActiveResource::Base.instance_methods.include? 'to_xml'
   def to_xml(options={})
      attributes.to_xml({:root => self.class.element_name}.merge(options))
    end
end

end
