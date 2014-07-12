# Common library

module GT
	def GT::fix_path(path)
		path.gsub("\\", "/")
	end

	def GT::nil_or_empty?(var)
		var.nil? or var.empty?
	end
end