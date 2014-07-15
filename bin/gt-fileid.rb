#!/usr/bin/env ruby

# Computes Unity fileID value for script located in external DLL
#
# Usage: fileID class_name [namespace]
#
# Author: Piotr Korzuszek (Genail) <piotr.korzuszek@gmail.com>
# Special thanks to Lambada Knight http://goo.gl/FIp4MP

require 'openssl'

module GT

	def GT::fileid(class_name, namespace="")
		s = "s\0\0\0" + namespace + class_name
		OpenSSL::Digest.digest("MD4", s)[0..3].unpack('l<').first
	end

end

# command line
if __FILE__ == $0
	class_name = ARGV[0]
	namespace = ARGV[1] || ""

	if class_name.nil? or class_name.empty?
		puts "usage: #{$0} class_name [namespace]"
		exit 1
	end

	puts GT.fileid(class_name, namespace)
end