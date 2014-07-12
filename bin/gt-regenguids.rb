#!/usr/bin/env ruby

# Regenerates all meta files guids from the first argument directory
# and updates all references in the search_directory.
# Useful for making a copy of assets that should not conflict with the originals.
#
# Usage: regenguids.rb directory search_directory

require "securerandom"

if ARGV[0].nil?
    puts "usage: #{$0} search_directory"
end

search_directory = ARGV[0]
unless File.exists? search_directory
    puts "No such directory: #{search_directory}"
end

LOGFILE = File.open("guids.log", "a")

# == Methods ==
def log(str)
    puts str
    LOGFILE << str << "\n"
end

def collect_meta_files(search_directory)
    Dir.glob("#{search_directory}/**/*.meta")
end

def guid_from_meta_file(meta_file)
    contents = File.read(meta_file)
    /guid: ([0-9a-f]{32})/.match(contents)[1]
end

def replace(file, from, to)
    contents = File.read(file)
    ncontents = contents.gsub(from, to)

    if contents != ncontents
        File.open(file, "w") { |f| f << ncontents }
        return true
    else
        return false
    end
end

# == End Methods ==

log "\n\nOperation started on #{Time.now}\n"

meta_files = collect_meta_files(search_directory)
meta_files.each do |meta|
    log ""
    log "Processing file: #{meta[0..-6]}"

    oguid = guid_from_meta_file(meta)
    log "Old GUID: #{oguid}"

    nguid = SecureRandom.hex(16)
    log "New GUID: #{nguid}"

    from = "guid: #{oguid}"
    to =   "guid: #{nguid}"

    log "Replacing meta file"
    replace(meta, from, to)

    log "Replacing all other files\n"

    Dir.glob("**/*") do |file|
        if File.file? file and replace(file, from, to)
            log "Replaced GUID in #{file}"
        end
    end
end

LOGFILE.close