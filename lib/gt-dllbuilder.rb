GMCS_PATH = "C:/Program Files (x86)/Unity/Editor/Data/Mono/bin/gmcs"
UNITY_ENGINE_PATH = "C:/Program Files (x86)/Unity/Editor/Data/Managed/UnityEngine.dll"
UNITY_EDITOR_PATH = "C:/Program Files (x86)/Unity/Editor/Data/Managed/UnityEditor.dll"


class DllBuilder

    attr_accessor :references
    attr_accessor :files
    attr_accessor :defines
    attr_accessor :verbose

    def initialize
        @verbose = false
    end

    def build(dll_filename)
        if @files.nil? or @files.empty?
            raise "no files to compile!"
        end

        output = "\"#{GMCS_PATH}\" -target:library \"-out:#{dll_filename}\" -delaysign- -reference:#{references_string} #{defines_option} "
        puts output

        @files.each do |file|
            output << '"' + file + "\" "
        end

        # output.gsub!("/", "/")

        puts "executing: #{output}" if @verbose
        system output
    end

    private

    def references_string
        out = ""
        @references.each do |ref|
            out << "," unless out.empty?
            out << '"' + ref + '"'
        end

        return out
    end

    def defines_option
        str = defines_string
        if not str.empty?
            "-define:#{str}"
        end
    end

    def defines_string
        if @defines.nil?
            ""
        else
            @defines.join(";");
        end
    end

end