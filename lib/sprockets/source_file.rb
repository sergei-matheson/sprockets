module Sprockets
  class SourceFile
    attr_reader :environment, :pathname

    def initialize(environment, pathname)
      @environment = environment
      @pathname = pathname
    end

    def find(location, kind = :file)
      pathname.parent_pathname.find(location, kind)
    end
    
    def ==(source_file)
      pathname == source_file.pathname
    end
    
    def mtime
      File.mtime(pathname.absolute_location)
    rescue Errno::ENOENT
      Time.now
    end
    
    def each_line
      File.open(pathname.absolute_location) do |file|
        file.each_line do |line|
          yield line, file.lineno
        end
      end
    end
  end
end
