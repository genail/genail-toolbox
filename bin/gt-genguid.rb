#!/usr/bin/env ruby

require 'optparse'
require "securerandom"

module GT
	def GT::genguid()
		nguid = SecureRandom.hex(16)
	end
end

if __FILE__ == $0

    options = {}

    op = OptionParser.new do |opts|
        opts.banner = "Usage: gt-genguid" +
            "\n\nGenerates new GUID to be used in unity meta files and returns it to standard output.\n\n"

        opts.on("-h", "--help", "Shows this help message") do |o|
            options[:help] = o
        end
    end
    op.parse!

    if options[:help]
        puts op.help()
        exit 0
    end

    guid = GT.genguid();
    puts guid
end