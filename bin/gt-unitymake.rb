#!/usr/bin/env ruby

require 'fileutils'
require 'pathname'
require 'tmpdir'
require 'zip'

umakefile = ARGV[0]

require_relative 'dllbuilder'

@references = {}

if umakefile.nil?
    umakefile = "umakefile.rb"
    unless File.exists? umakefile
        puts "Usage: #{$0} umakefile.rb"
        exit 1
    end        
elsif not File.exists? umakefile
    puts "File not found: #{umakefile}"
    exit 1
end

require Dir.pwd + "/" + umakefile

def as_array(obj)
    if obj.nil?
        return []
    elsif obj.is_a? Array
        return obj
    else
        return [obj]
    end
end

def matches(file, pattern, simple=false)
    
    if simple
        pattern = pattern.gsub("*", ".*")
    else
        pattern = pattern.gsub(".", "\\.")
        pattern = pattern.gsub("**/*", ".:star:")
        pattern = pattern.gsub("*", "[^/]*")
        pattern = pattern.gsub(":star:", "*")
    end
    
    pattern = Regexp.compile("^" + pattern + "$")

    pattern =~ file
end

def resolve_files(file)
    if file.is_a? Array
        out = file.map { |f| resolve_files(f) }
        return out.flatten
    end

    base = ""
    components = file.split('/')
    components.each do |c|
        unless c.include? '*'
            base << "/" unless base.empty?
            base << c
        else
            break
        end
    end

    list = list_dir(base)

    list.select do |el|
        matches(el, file)
    end
end

def list_dir(dir)
    output = []

    Dir.foreach(dir) do |entry|
        next if entry == "." or entry == ".."

        file = dir + "/" + entry
        if File.directory? file
            output += list_dir(file)
        else
            output.push file
        end
    end

    return output
end

def resolve_references(reference)
    if reference.is_a? Array
        return reference.map { |r| resolve_references(r) }
    end

    if reference == :UnityEditor
        return UNITY_EDITOR_PATH
    elsif reference == :UnityEngine
        return UNITY_ENGINE_PATH
    elsif reference.is_a? String
        if @references.has_key? reference
            return @references[reference]
        else
            raise "Reference not found: #{reference}"
        end
    else
        raise "Reference unknown: #{reference}"
    end
end

def copy_files(files, tempdir)
    files.map do |file|
        path = Pathname.new(file)
        newpath = tempdir + "/" + path.basename.to_s
        FileUtils.cp(file, newpath)
        newpath
    end
end

def gsub_file(file, from, to)
    text = File.read(file)
    text.gsub!(from, to)
    # puts "#{from} => #{to} in #{file}}"
    File.open(file, "w") { |f| f << text }
end

def replace_strings(files)
    if not defined?(STRINGS) or STRINGS.nil?
        return
    end

    if files.is_a? String
        files = [ files ]
    end

    files.each do |file|
        STRINGS.each do |from, to|
            gsub_file(file, from, to)
        end
    end
end

def zip(basedir, files, zipfile)
    if File.exists? zipfile
        File.unlink(zipfile)
    end

    Zip::File.open(zipfile, Zip::File::CREATE) do |zipfile|
        files.each do |file|
            name = file;

            if file.start_with? basedir
                name = file[basedir.length..-1]
                while name.start_with? "/"
                    name = name[1..-1]
                end
            else
                raise "File name #{file} doesn't start with #{basedir}"
            end

            zipfile.add(name, file)
        end
    end
end

#
# Compile bundles
#
unless BUNDLES.nil? or BUNDLES.empty?
    BUNDLES.each do |name, entries|
        puts "Building #{name}..."

        tempdir = Dir.mktmpdir

        begin
            output = entries[:output]
            puts "    Copying files"
            files = as_array(entries[:files])
            files = resolve_files(files)
            files = copy_files(files, tempdir)

            puts "    Connecting references"
            references = as_array(entries[:references])
            references.push :UnityEngine
            references = resolve_references(references)

            puts "    Replacing strings"
            replace_strings(files)

            unless entries[:sources].nil?
                zipname = entries[:sources]
                puts "    Creating zip file #{zipname}"
                zip(tempdir, files, zipname)
            end

            puts "    Compiling"
            builder = DllBuilder.new
            builder.files = files
            builder.references = references
            builder.defines = as_array(entries[:defines])

            puts "    Done"

            unless builder.build(output)
                raise "Aborting due to previous errors."
            end

            @references[name] = output
        rescue Exception => e
            FileUtils.rm_rf(tempdir)
            raise e
        end
    end
end

#
# Copy resources
#
def replace_strings_candidate?(filename)
    accepted = [ ".cs", ".shader" ]
    accepted.include? File.extname(filename)
end

unless RESOURCES.nil? or RESOURCES.empty?
    source = as_array(RESOURCES[:source])
    target = RESOURCES[:target]
    exclude = as_array(RESOURCES[:exclude_filter])

    source.each do |dir|
        list = list_dir(dir)

        # remove based on exclude
        list = list.select do |file|
            exclude.count { |filter| matches(file, filter, true) } == 0
        end

        # copy
        list.each do |file|
            sourcepath = Pathname.new(file)
            targetpath = Pathname.new(target + "/" + file[dir.length..-1])
            FileUtils.mkdir_p(targetpath.dirname)
            FileUtils.cp(sourcepath.cleanpath, targetpath.cleanpath, :verbose => true)

            if replace_strings_candidate? targetpath.cleanpath.to_s
                replace_strings(targetpath.cleanpath.to_s)
            end
        end
    end
end

puts
puts "Succeed!"