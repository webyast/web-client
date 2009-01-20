class Yast < MyActiveResource
  self.collection_name = "yast"
  attr_accessor :visibleName
end
