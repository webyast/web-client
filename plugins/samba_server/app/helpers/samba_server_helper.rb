module SambaServerHelper

    def isSMBtrue?(bool)
	return false if bool.nil?
	return (bool == true || bool.downcase == "yes" || bool.downcase == "true" || bool == "1" || bool == 1)
    end

end
