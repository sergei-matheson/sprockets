module Sprockets
  class Concatenation
    attr_reader :lines
    
    def initialize
      @lines = []
      @source_files_and_numbers = []
      @source_file_mtimes = {}
    end
    
    def record(source_file, line, number)
      @lines << line
      @source_files_and_numbers << [source_file, number]
      record_mtime_for(source_file)
      line
    end
    
    def to_s
      lines.join
    end

    def mtime
      @source_file_mtimes.values.max
    end
    
    def save_to(filename)
      timestamp = mtime
      File.open(filename, "w") { |file| file.write(to_s) }
      File.utime(timestamp, timestamp, filename)
      true
    end

    protected
      def record_mtime_for(source_file)
        @source_file_mtimes[source_file] ||= source_file.mtime
      end
  end
end
