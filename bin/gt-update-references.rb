#!/usr/bin/env ruby

# Updates all references (guid + fileID) in the search directory.
# Won't change any meta files.
#
# Usage: gt-update-references --searchdir search_directory --guid guid [--fileid fileid] [-v]
#
# Author: Piotr Korzuszek (Genail) <piotr.korzuszek@gmail.com>

require 'optparse'
require 'pp'

require_relative '../lib/gt-commons'

module GT
    @@verbose = false
    def GT::verbose=(val)
        @@verbose = val
    end

    def GT::log(str)
        puts str if @@verbose
    end

    def GT::update_references(search_dir, from_guid, to_guid, from_fileid=nil, to_fileid=nil)
        updated_count = 0
        log "Replacing guid from #{from_guid} to #{to_guid}..."

        search_dir = GT.fix_path(search_dir)

        files = GT.collect_files(search_dir)
        #pp files
        files.each do |file|
            contents = File.read(file)

            replaced = contents.gsub("guid: #{from_guid}", "guid: #{to_guid}")

            unless GT.nil_or_empty? from_fileid and GT.nil_or_empty? to_fileid
                replaced = replaced.gsub("fileID: #{from_fileid}, guid: #{to_guid}", "fileID: #{to_fileid}, guid: #{to_guid}")
            end

            if replaced != contents
                log "Updating file #{file}..."
                updated_count += 1
                File.open(file, "w") { |f| f << replaced }
            end
        end
    end

    def GT::collect_files(search_dir)
        files = Dir.glob("#{search_dir}/**/*.*")
        files.select { |i| i.end_with?(
            ".unity",
            ".prefab",
            ".mat",
            ".asset",
            ".cubemap",
            ".flare",
            ".compute",
            ".controller",
            ".anim",
            ".overrideController",
            ".mask",
            ".physicsMaterial",
            ".physicsMaterial2D",
            ".guiskin",
            ".fontsettings")
        }
    end
end

if __FILE__ == $0

    options = {}

    op = OptionParser.new do |opts|
        opts.banner = "Usage: gt-update-references -s dir --from-guid guid1 --to-guid guid2 [-v] [--from-fileid fileid] [--to-fileid fileid]" +
            "\n\nUpdates all references (guid + fileID) in the search directory. Meta files are kept unchanged.\n\n"

        opts.on("-s", "--searchdir dir", "Directory to search in") do |o|
            options[:search_dir] = o;
        end

        opts.on("--from-guid guid", "GUID to look for") do |o|
            options[:from_guid] = o
        end

        opts.on("--to-guid guid", "new GUID to set") do |o|
            options[:to_guid] = o
        end

        opts.on("--from-fileid fileid", "fileID to look for") do |o|
            options[:from_fileid] = o
        end

        opts.on("--to-fileid fileid", "new fileID to set") do |o|
            options[:to_fileid] = o
        end

        opts.on("-h", "--help", "Shows this help message") do |o|
            options[:help] = o
        end

        opts.on("-v", "--verbose", "Run verbosely") do |o|
            options[:verbose] = o
        end
    end

    op.parse!

    if options[:help]
        puts op.help
        exit 0
    end

    if GT.nil_or_empty? options[:search_dir] or
       GT.nil_or_empty? options[:from_guid] or
       GT.nil_or_empty? options[:to_guid]

        puts "Invalid usage"
        puts op.help
        exit 1
    end

    GT.verbose = options[:verbose]
    GT.update_references(
        options[:search_dir],
        options[:from_guid],
        options[:to_guid],
        options[:from_fileid],
        options[:to_fileid])
end