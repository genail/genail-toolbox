#!/usr/bin/env ruby

def path(p)
    unless p.nil?
        p.gsub("\\", "/")
    else
        nil
    end
end

replace_file = "ReplaceFile.rb"

unless File.exists? replace_file
    puts "File ReplaceFile.rb not present!"
    exit 1
end

WORKING_DIR = File.dirname replace_file

require_relative Dir.pwd + "/" + replace_file

# get missing keys from ARGV
missing = {}
ARGV.each do |a|
    if a.include? "="
        key, value = a.split("=")
        missing[key] = value
    end
end

STRINGS.each do |key, value|
    if value.nil?
        if missing.has_key? key
            STRINGS[key] = missing[key]
        else
            puts "missing value for #{key}"
            exit 1
        end
    end
end

puts "What will be replaced:"
p STRINGS

puts "Working directory: #{WORKING_DIR}"

def cut_front(str, num)
    "..." + str[num..-1]
end

def replace(text, from, to, file)
    ntext = text.gsub(from, to)
    if (text != ntext)
        puts "#{from} => #{to} in #{file}}"
    end

    ntext
end

scanned = 0
replaced = 0
Dir["#{WORKING_DIR}/**/*.cs", "#{WORKING_DIR}/**/*.shader"].each do |file|
    scanned += 1

    text = File.read(file)
    orig_text = text

    STRINGS.each do |from, to|
        text = replace(text, from, to, file)
    end

    if (orig_text != text)
        File.open(file, "w") { |f| f << text }
        replaced += 1
    end
end

puts
puts "Summary:"
puts "Replaced strings in #{replaced} of #{scanned} files."