# Common library

module GT
	def GT::fix_path(path)
		path.gsub("\\", "/")
	end

	def GT::nil_or_empty?(var)
		var.nil? or var.to_s().empty?
	end

	def GT::path_to_windows(path)
		path.gsub("/", "\\")
	end
end