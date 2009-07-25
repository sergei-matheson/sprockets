module Sprockets
  class Directive
    attr_reader :source_file, :line, :number, :name, :argument

    QUOTED_STRING = /(?:"([^"]+|\\"+)*")/
    ANGLED_STRING = /(?:<([^>]+|\\>+)*>)/

    class << self
      def for(source_file, line, number)
        if directive_klass = Directives.find(line)
          directive_klass.new(source_file, line, number)
        end
      end

      def parse(line)
        if matches = full_pattern.match(line)
          matches.captures
        end
      end
      
      protected
        def full_pattern
          @full_pattern ||= /\s*\/\/=\s+#{pattern}\s*$/
        end
        
        def pattern
          /^$/
        end
    end
    
    def initialize(source_file, line, number)
      @source_file     = source_file
      @line, @number   = line, number
      @name, @argument = self.class.parse(line)
    end
    
    protected
      def environment
        source_file.environment
      end
    
      def parse_quoted_string(string)
        QUOTED_STRING.match(string)[1].gsub(/\\"/, "\"")
      end
      
      def parse_angled_string(string)
        ANGLED_STRING.match(string)[1].gsub(/\\>/, "\>")
      end
      
      def raise_load_error
        raise LoadError, 
          "can't find file for #{name} `#{require_location}' " +
          "(line #{number} of #{source_file.pathname})"
      end
  end
end
